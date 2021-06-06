--!strict
--[[
	PoduServer:PromptPurchaseOf(player: Player, productType: ProductType, productId: number): Promise
	PoduServer:PromptDevProductPurchase(player: Player, productId: number): Promise
	PoduServer:OwnsGamePass(userId: number, gamePassId: number): Promise
	PoduServer:GetProductInfo(assetId: number, infoType: Enum.InfoType): Promise

	PoduServer:OnGamePassPurchase(callback: (player: Player, gamePassId: number, wasPurchased: boolean) -> ())

	PoduServer:SetCallbacks(callbacks: {[number]: (receiptInfo, player: Player) -> (boolean)})
]]

-- Roblox Services --
local Players = game:GetService('Players')
local MarketplaceService = game:GetService('MarketplaceService')

-- Modules --
local ProductTypeFunctions = require(script.Parent.Shared.ProductType)
local DevProductHandler = require(script.DevProductHandler)
local OwnsGamePass = require(script.Parent.Shared.OwnsGamePass)
local GetProductInfo = require(script.Parent.Shared.GetProductInfo)
local ModuleManager = require(script.Parent.Shared.ModuleManager)

local Promise

-- Variables --
local Utils: Folder = script.Utils
local PlayersPromises: { [Player]: PromiseList? } = {}

type PromiseList = { [Player]: { [any]: any } }

local PoduServer = {
	Enum = require(script.Parent.Shared.Enums),
	Utils = Utils,
}

local function storePromise(player: Player, promise: any): any
	local playerPromises: PromiseList? = PlayersPromises[player]
	if not playerPromises then
		playerPromises = {}
		PlayersPromises[player] = playerPromises
	end

	if promise:getStatus() == Promise.Status.Started then
		local id = newproxy(false)
		local newPromise: any = Promise.resolve(promise)
		playerPromises[id] = newPromise

		newPromise:finally(function()
			playerPromises[id] = nil
		end)

		return newPromise
	else
		return promise
	end
end

function PoduServer:OnGamePassPurchase(callback)
	return MarketplaceService.PromptGamePassPurchaseFinished:Connect(callback)
end

function PoduServer:GetProductInfo(assetId: number, infoType: Enum.InfoType): any
	return GetProductInfo(assetId, infoType)
end

function PoduServer:PromptPurchaseOf(player: Player, productType: any, productId: number): any
	return storePromise(player, ProductTypeFunctions[productType](player, productId))
end

function PoduServer:PromptDevProductPurchase(player: Player, productId: number): any
	return storePromise(player, DevProductHandler._handle(player, productId))
end

function PoduServer:OwnsGamePass(...): any
	return OwnsGamePass(...)
end

function PoduServer:SetPromiseModule(promiseModule: ModuleScript | any)
	ModuleManager:setModule('Promise', promiseModule)
end

PoduServer.SetCallbacks = DevProductHandler.SetCallbacks

ModuleManager:onModuleUpdate('Promise', function(newPromiseModule: ModuleScript)
	Promise = newPromiseModule
end)

-- Cancel all promises when player left
Players.PlayerRemoving:Connect(function(player: Player)
	local playerPromises: PromiseList? = PlayersPromises[player]
	if playerPromises then
		for _, promise in pairs(playerPromises) do
			promise:cancel()
		end

		PlayersPromises[player] = nil
	end
end)

return PoduServer
