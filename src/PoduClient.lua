--!strict
--[[
	PoduClient:OwnsGamePass(gamePassId: number): Promise
	PoduClient:PromptPurchaseOf(productType: ProductType, productId: number): Promise
	PoduClient:PromptDevProductPurchase(productId: number): Promise
	PoduClient:GetProductInfo(assetId: number, infoType: Enum.InfoType): Promise

	PoduClient:OnGamePassPurchase(callback: (player: Player, gamePassId: number, wasPurchased: boolean) -> ())
]]

-- Roblox Services --
local MarketplaceService = game:GetService('MarketplaceService')
local Players = game:GetService('Players')

-- Modules --
local OwnsGamePass = require(script.Parent.Shared.OwnsGamePass)
local ProductTypeFunctions = require(script.Parent.Shared.ProductType)
local GetProductInfo = require(script.Parent.Shared.GetProductInfo)
local ModuleManager = require(script.Parent.Shared.ModuleManager)

-- Variables --
local Player: Player = Players.LocalPlayer

local PoduClient = {
	Enum = require(script.Parent.Shared.Enums),
}

function PoduClient:OwnsGamePass(gamePassId: number): any
	return OwnsGamePass(Player.UserId, gamePassId)
end

function PoduClient:GetProductInfo(assetId: number, infoType: Enum.InfoType): any
	return GetProductInfo(assetId, infoType)
end

function PoduClient:PromptPurchaseOf(productType: any, productId: number): any
	return ProductTypeFunctions[productType](Player, productId)
end

function PoduClient:PromptDevProductPurchase(productId: number)
	MarketplaceService:PromptProductPurchase(Player, productId)
end

function PoduClient:OnGamePassPurchase(callback)
	return MarketplaceService.PromptGamePassPurchaseFinished:Connect(callback)
end

function PoduClient:SetPromiseModule(promiseModule: ModuleScript | any)
	ModuleManager:setModule('Promise', promiseModule)
end

return PoduClient
