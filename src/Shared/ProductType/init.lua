--!strict
local Enums = require(script.Parent.Parent.Shared.Enums)

local ProductTypeFunctions = {}
for _: number, module: Instance in ipairs(script:GetChildren()) do
	ProductTypeFunctions[Enums.ProductType[module.Name]] = require(module)
end

return ProductTypeFunctions
