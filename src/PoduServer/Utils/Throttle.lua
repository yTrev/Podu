--!strict
-- Roblox Services --
local RunService = game:GetService('RunService')
local DataStoreService = require(script.Parent.Parent.Parent.Parent.MockDataStoreService)

-- Modules --
local Promise = require(script.Parent.Parent.Parent.Parent.Promise)

-- Constants --
local METHODS = {
	GetAsync = Enum.DataStoreRequestType.GetAsync,
	SetAsync = Enum.DataStoreRequestType.SetIncrementAsync,
}

-- Variables --
type Promise = typeof(Promise.resolve())
type pack = { [number]: string, n: number }
type queueMember = {
	resolve: (string | boolean) -> (Promise),
	reject: (string | boolean) -> (Promise),
	args: pack,
}

local purchaseHistory: GlobalDataStore = DataStoreService:GetDataStore('PurchaseHistory')

-- stylua: ignore
local queue: {[Enum.DataStoreRequestType]: { queueMember }} = {}

local callMethod = Promise.promisify(function(method: string, ...)
	return purchaseHistory[method](purchaseHistory, ...)
end)

return function(method: string, ...)
	local methodEnum: Enum.DataStoreRequestType = METHODS[method]

	if DataStoreService:GetRequestBudgetForRequestType(methodEnum) > 0 then
		return callMethod(method, ...):await()
	end

	if not queue[methodEnum] then
		queue[methodEnum] = {}

		coroutine.wrap(function()
			RunService.Heartbeat:Wait()

			while #queue[methodEnum] > 0 do
				local currentRequest: queueMember = table.remove(queue[methodEnum], 1)

				while DataStoreService:GetRequestBudgetForRequestType(methodEnum) == 0 do
					RunService.Heartbeat:Wait()
				end

				local success: boolean, result: boolean | string = callMethod(table.unpack(currentRequest.args)):await()
				if success then
					currentRequest.resolve(result)
				else
					currentRequest.reject(result)
				end
			end

			queue[methodEnum] = nil
		end)()
	end

	local packArgs: pack = table.pack(method, ...)
	local newPromise = Promise.new(function(resolve, reject)
		table.insert(queue[methodEnum], {
			resolve = resolve,
			reject = reject,
			args = packArgs,
		})
	end)

	return newPromise:await()
end
