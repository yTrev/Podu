local Players = game:GetService('Players')

local Podu = require(game.ReplicatedStorage.Podu)
local PromptResult = Podu.Enums.PromptResult

Players.PlayerAdded:Connect(function(player: Player)
	wait(5)

	Podu
		:PromptDevProductPurchase(player, 123456789)
		:andThen(function(result)
			if result == PromptResult.Purchase then
				print('Purchased!')
			elseif result == PromptResult.Cancelled then
				print('Cancelled!')
			end
		end)
		:finally(warn)
end)
