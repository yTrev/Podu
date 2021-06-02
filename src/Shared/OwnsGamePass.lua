--!strict
-- Roblox Services --
local MarketplaceService = game:GetService('MarketplaceService')

-- Modules --
local Promise = require(script.Parent.Parent.Parent.Promise)
type Promise = typeof(Promise.resolve())

local userOwnsGamepassAsync: (number, number) -> Promise = Promise.promisify(function(userId: number, gamePassId: number)
	return MarketplaceService:UserOwnsGamePassAsync(userId, gamePassId)
end)

return function(userId: number, gamePassId: number): Promise
	return userOwnsGamepassAsync(userId, gamePassId)
end
