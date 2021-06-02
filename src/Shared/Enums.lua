local function lockEnum(enumName: string, values)
	local function protected(_, key)
		error(string.format('%q (%s) is not a valid member of %s', tostring(key), typeof(key), tostring(enumName)))
	end

	return setmetatable(values, {
		__index = protected,
		__newindex = protected,
		__tostring = function()
			return enumName
		end,
	})
end

local function enum(name: string, enums: { string })
	local newEnum = {}

	for _, memberName: string in pairs(enums) do
		local longName: string = string.format('%s.%s', name, memberName)
		newEnum[memberName] = longName
	end

	return lockEnum(name, newEnum)
end

return {
	ProductType = enum('ProductType', { 'Gamepass' }),
	PromptResult = enum('PromptResult', { 'Purchased', 'Cancelled', 'Denied', 'AlreadyPurchased', 'Failed' }),
}
