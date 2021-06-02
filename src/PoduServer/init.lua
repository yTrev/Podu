--!strict
--[[
	PoduServer:PromptPurchaseOf(player: Player, productType: ProductType, productId: number): Promise
	PoduServer:PromptDevProductPurchase(player: Player, productId: number): Promise
	PoduServer:OwnsGamePass(userId: number, gamePassId: number): Promise

	PoduServer:SetCallbacks(callbacks: {[number]: (receiptInfo, userId: number) -> ()})
]]

-- Roblox Services --
local Players = game:GetService('Players')

-- Modules --
local Promise = require(script.Parent.Parent.Promise)
local ProductTypeFunctions = require(script.Parent.Shared.ProductType)
local DevProductHandler = require(script.DevProductHandler)
local OwnsGamePass = require(script.Parent.Shared.OwnsGamePass)

-- Variables --
local Utils: Folder = script.Utils
local PlayersPromises: { [Player]: PromiseList? } = {}

type Promise = typeof(Promise.resolve())
type PromiseList = {
	[Player]: { [any]: Promise },
}

local PoduServer = {
	DefaultTimeout = 10,
	Enum = require(script.Parent.Shared.Enums),
	Utils = Utils,
}

local function storePromise(player: Player, promise: Promise): Promise
	local playerPromises: PromiseList? = PlayersPromises[player]
	if not playerPromises then
		playerPromises = {}
		PlayersPromises[player] = playerPromises
	end

	if promise:getStatus() == Promise.Status.Started then
		local id = newproxy(false)
		local newPromise: Promise = Promise.resolve(promise)
		playerPromises[id] = newPromise

		newPromise:finally(function()
			playerPromises[id] = nil
		end)

		return newPromise
	else
		return promise
	end
end

function PoduServer:PromptPurchaseOf(player: Player, productType: any, productId: number): Promise
	return storePromise(player, ProductTypeFunctions[productType](player, productId))
end

function PoduServer:PromptDevProductPurchase(player: Player, productId: number): Promise
	return storePromise(player, DevProductHandler._handle(player, productId))
end

function PoduServer:OwnsGamePass(...): Promise
	return OwnsGamePass(...)
end

PoduServer.SetCallbacks = DevProductHandler.SetCallbacks

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
