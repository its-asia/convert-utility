-- any time .Parent is changed
-- you MUST do .Instance.Parent

-- example
-- local Remote = (github stuff)
-- workspace.Baseplate.Parent = Remote.Instance

local Services = {}
local MetaServices = {__index = function(self, Index) return rawget(Services, Index) or game:GetService(Index) end}

setmetatable(Services, MetaServices)

return function(Remote)
	local Override = {}
	
	local UserData = newproxy(true)
	local MetaTable = getmetatable(UserData)
	
	Override.Instance = Remote
	MetaTable.__index = function(self, Index)
		return Override[Index] or Remote[Index]
	end
	
	MetaTable.__newindex = function(self, Index, Value)
		Remote[Index] = Value
	end
	
	MetaTable.__metatable = 'The metatable is locked'
	MetaTable.__tostring = function() return tostring(Remote) end
	
	return UserData
end
