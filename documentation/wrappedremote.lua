-- any time .Parent is changed
-- you MUST do .Instance.Parent

-- example
-- local Remote = (github stuff)
-- workspace.Baseplate.Parent = Remote.Instance

local Services = {}
local MetaServices = {__index = function(self, Index) return rawget(Services, Index) or game:GetService(Index) end}

setmetatable(Services, MetaServices)

local LocalPlayer = Services.Players.LocalPlayer
if LocalPlayer == nil then
	repeat task.wait() LocalPlayer = Services.Players.LocalPlayer
	until LocalPlayer ~= nil
end

return function(Remote)
	local ServerBindable = Instance.new('BindableEvent')
	local ClientBindable = Instance.new('BindableEvent')

	local CustomProperties = {
		OnServerInvoke = function() end,
		OnClientInvoke = function() end,
	}

	local Override = {
		OnServerEvent = ServerBindable.Event,
		OnClientEvent = ClientBindable.Event,

		FireServer = function(self, ...)
			ServerBindable:Fire(LocalPlayer, ...)
		end,

		FireClient = function(self, Player, ...)
			ClientBindable:Fire(...)
		end,

		FireAllClients = function(self, ...)
			ClientBindable:Fire(...)
		end,

		InvokeServer = function(self, ...)
			local OnInvoke = CustomProperties.OnServerInvoke
			local Type = typeof(OnInvoke)

			if Type ~= 'function' then
				error('attempt to call a ' .. Type .. ' value')

				return
			end

			OnInvoke(LocalPlayer, ...)
		end,

		InvokeClient = function(self, Player, ...)
			local OnInvoke = CustomProperties.OnClientInvoke
			local Type = typeof(OnInvoke)

			if Type ~= 'function' then
				error('attempt to call a ' .. Type .. ' value')

				return
			end

			OnInvoke(...)
		end,
	}

	local UserData = newproxy(true)
	local MetaTable = getmetatable(UserData)

	Override.Instance = Remote
	MetaTable.__index = function(self, Index)
		return Override[Index] or CustomProperties[Index] or Remote[Index]
	end

	MetaTable.__newindex = function(self, Index, Value)
		if CustomProperties[Index] then
			CustomProperties[Index] = Value

			return
		end

		Remote[Index] = Value
	end

	MetaTable.__metatable = 'The metatable is locked'
	MetaTable.__tostring = function() return tostring(Remote) end

	return UserData
end
