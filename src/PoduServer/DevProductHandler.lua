--!strict
-- Services --
local MarketplaceService = game:GetService('MarketplaceService')
local Players = game:GetService('Players')

-- Modules --
local Throttle = require(script.Parent.Utils.Throttle)
local Promise = require(script.Parent.Parent.Parent.Promise)
local Enums = require(script.Parent.Parent.Shared.Enums)

-- Variables --
local waitingPromises: { [string]: WaitingPromise } = {}
local promptResults = Enums.PromptResult

local purchaseGranted = Enum.ProductPurchaseDecision.PurchaseGranted
local notProcessedYet = Enum.ProductPurchaseDecision.NotProcessedYet

type Promise = typeof(Promise.resolve())
type WaitingPromise = {
	resolve: (any) -> Promise,
	reject: () -> Promise,
}
type ReceiptInfo = {
	PlayerId: number,
	PlaceIdWherePurchased: number,
	PurchaseId: string,
	ProductId: number,
	CurrencyType: Enum.CurrencyType,
	CurrencySpent: number,
}

type ProductCallback = (ReceiptInfo) -> (boolean)

local DevProductHandler = {
	Callbacks = {},
}

local function getId(userId: number, productId: number): string
	return string.format('%d_%d', userId, productId)
end

function DevProductHandler._handle(player: Player, productId: number): Promise
	local id: string = getId(player.UserId, productId)
	local waitingPromise: WaitingPromise? = waitingPromises[id]
	if waitingPromise then
		return Promise.resolve(promptResults.Denied)
	else
		local newPromise: Promise = Promise.new(function(resolve, reject)
			waitingPromises[id] = {
				resolve = resolve,
				reject = reject,
			}
		end)

		MarketplaceService:PromptProductPurchase(player, productId)

		return newPromise
	end
end

function DevProductHandler:SetCallbacks(callbacks)
	self.Callbacks = callbacks
end

do
	local function processReceipt(receiptInfo: ReceiptInfo)
		local purchaseId: string = receiptInfo.PurchaseId

		local id: string = getId(receiptInfo.PlayerId, receiptInfo.ProductId)
		local waitingPromise: WaitingPromise? = waitingPromises[id]

		local function returnDecision(decision, failed: boolean?): Enum.ProductPurchaseDecision
			if waitingPromise then
				local decisionEnum: string
				if failed then
					decisionEnum = promptResults.Failed
				else
					decisionEnum = decision == purchaseGranted and promptResults.Purchased
						or decision == notProcessedYet and promptResults.Cancelled
				end

				waitingPromise.resolve(decisionEnum)
				waitingPromises[id] = nil
			end

			return decision
		end

		local success: boolean, result: boolean | string = Throttle('GetAsync', purchaseId)
		if result then
			return returnDecision(Enum.ProductPurchaseDecision.PurchaseGranted)
		elseif not success then
			error('Data store error: ' .. tostring(result))
		end

		local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if not player then
			return returnDecision(Enum.ProductPurchaseDecision.NotProcessedYet)
		end

		local callbackSuccess: boolean = pcall(DevProductHandler.Callbacks[receiptInfo.ProductId], receiptInfo, player)
		if callbackSuccess then
			while player:IsDescendantOf(game) do
				local setSuccess: boolean = Throttle('SetAsync', purchaseId, true)
				if setSuccess then
					break
				end
			end

			return returnDecision(Enum.ProductPurchaseDecision.PurchaseGranted)
		else
			return returnDecision(Enum.ProductPurchaseDecision.NotProcessedYet)
		end
	end

	MarketplaceService.ProcessReceipt = processReceipt

	-- I really don't like to use deprecated events, but I don't have
	-- any alternative right now
	MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId: number, productId: number, isPurchased: boolean)
		if not isPurchased then
			local id = getId(userId, productId)
			local waitingPromise: WaitingPromise = waitingPromises[id]
			if waitingPromise then
				waitingPromise.resolve(promptResults.Cancelled)

				waitingPromises[id] = nil
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		local userId: string = tostring(player.UserId)

		for id: string, promise: WaitingPromise in pairs(waitingPromises) do
			local isValid: boolean = string.find(id, userId, 1) == 1
			if isValid then
				promise.reject()
				waitingPromises[id] = nil
			end
		end
	end)
end

return DevProductHandler
