-- Roblox Services --
local MarketplaceService = game:GetService('MarketplaceService')

-- Modules --
local ModuleManager = require(script.Parent.ModuleManager)

local getProductInfo: (number, Enum.InfoType) -> (any)

ModuleManager:onModuleUpdate('Promise', function(newPromiseModule: ModuleScript)
	getProductInfo = newPromiseModule.promisify(function(assetId: number, infoType: Enum.InfoType)
		return MarketplaceService:GetProductInfo(assetId, infoType)
	end)
end)

return function(assetId: number, infoType: Enum.InfoType): any
	return getProductInfo(assetId, infoType)
end
