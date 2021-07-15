--!strict
-- Roblox Services --
local MarketplaceService = game:GetService('MarketplaceService')

-- Modules --
local ModuleManager = require(script.Parent.ModuleManager)

local userOwnsGamePassAsync: (number, number) -> any
ModuleManager:onModuleUpdate('Promise', function(newPromiseModule: ModuleScript)
	userOwnsGamePassAsync = newPromiseModule.promisify(function(userId: number, gamePassId: number)
		return MarketplaceService:UserOwnsGamePassAsync(userId, gamePassId)
	end)
end)

return function(userId: number, gamePassId: number): any
	return userOwnsGamePassAsync(userId, gamePassId)
end
