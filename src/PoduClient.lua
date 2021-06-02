--!strict
--[[
	PoduClient:OwnsGamePass(gamePassId: number): Promise
	PoduClient:PromptPurchaseOf(productType: ProductType, productId: number): Promise
	PoduClient:PromptDevProductPurchase(productId: number): Promise
	PoduClient:GetProductInfo(assetId: number, infoType: Enum.InfoType): Promise
]]

-- Roblox Services --
local MarketplaceService = game:GetService('MarketplaceService')
local Players = game:GetService('Players')

-- Modules --
local Promise = require(script.Parent.Parent.Promise)
local OwnsGamePass = require(script.Parent.Shared.OwnsGamePass)
local ProductTypeFunctions = require(script.Parent.Shared.ProductType)

-- Variables --
type Promise = typeof(Promise.resolve())

local Player: Player = Players.LocalPlayer

local PoduClient = {}

local getProductInfo: (number, Enum.InfoType) -> (Promise) = Promise.promisify(function(assetId: number, infoType: Enum.InfoType)
	return MarketplaceService:GetProductInfo(assetId, infoType)
end)

function PoduClient:OwnsGamePass(gamePassId: number): Promise
	return OwnsGamePass(Player.UserId, gamePassId)
end

function PoduClient:GetProductInfo(assetId: number, infoType: Enum.InfoType): Promise
	return getProductInfo(assetId, infoType)
end

function PoduClient:PromptPurchaseOf(productType: any, productId: number): Promise
	return ProductTypeFunctions[productType](Player, productId)
end

function PoduClient:PromptDevProductPurchase(productId: number)
	MarketplaceService:PromptProductPurchase(Player, productId)
end

return PoduClient
