--!strict
-- Roblox Services --
local MarketplaceService = game:GetService('MarketplaceService')

-- Modules --
local ModuleManager = require(script.Parent.ModuleManager)

local userOwnsGamepassAsync: (number, number) -> any
ModuleManager:onModuleUpdate('Promise', function(newPromiseModule: ModuleScript)
	userOwnsGamepassAsync = newPromiseModule.promisify(function(userId: number, gamePassId: number)
		return MarketplaceService:UserOwnsGamePassAsync(userId, gamePassId)
	end)
end)

return function(userId: number, gamePassId: number): any
	return userOwnsGamepassAsync(userId, gamePassId)
end
