local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Podu = require(ReplicatedStorage.Podu)

-- User owns gamepass?
Podu
	:OwnsGamePass(12345678)
	:andThen(function(owns: boolean)
		if owns then
			print(':D')
		else
			print(':(')
		end
	end)
	:catch(warn)
