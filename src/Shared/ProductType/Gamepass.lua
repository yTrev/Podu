--!strict
-- Roblox Services --
local MarketplaceService = game:GetService('MarketplaceService')

-- Modules --
local OwnsGamePass = require(script.Parent.Parent.Parent.Shared.OwnsGamePass)
local Enums = require(script.Parent.Parent.Parent.Shared.Enums)
local ModuleManager = require(script.Parent.Parent.ModuleManager)
local Promise

ModuleManager:onModuleUpdate('Promise', function(newPromiseModule: ModuleScript)
	Promise = newPromiseModule
end)

local GamepassPurchased: RBXScriptSignal = MarketplaceService.PromptGamePassPurchaseFinished

return function(player: Player, gamepassId: number)
	return OwnsGamePass(player.UserId, gamepassId):andThen(function(owns: boolean)
		if not owns then
			local finishedPurchase: any = Promise.fromEvent(GamepassPurchased, function(plr: Player, passId: number)
				return plr == player and passId == gamepassId
			end):andThen(function(_, _, wasPurchased: boolean)
				return wasPurchased and Enums.PromptResult.Purchased or Enums.PromptResult.Cancelled
			end)

			MarketplaceService:PromptGamePassPurchase(player, gamepassId)

			return finishedPurchase
		else
			return Promise.resolve(Enums.PromptResult.AlreadyPurchased)
		end
	end)
end
