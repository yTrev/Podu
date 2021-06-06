local ModuleManager = {
	callbacks = {},
}

function ModuleManager:onModuleUpdate(moduleName: string, callback: (ModuleScript) -> ())
	local moduleCallbacks = self.callbacks[moduleName]
	if not moduleCallbacks then
		moduleCallbacks = {}
		self.callbacks[moduleName] = moduleCallbacks
	end

	table.insert(moduleCallbacks, callback)
end

function ModuleManager:setModule(name, module: ModuleScript | any)
	if typeof(module) == 'Instance' then
		module = require(module)
	end

	local callbacks = self.callbacks[name]
	if callbacks then
		for _, callback in ipairs(callbacks) do
			callback(module)
		end
	end
end

return ModuleManager
