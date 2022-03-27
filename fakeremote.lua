local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer

return {
	new = function(Type)
		local BindableOnEvent = Instance.new('BindableEvent')
		
		local EmptyFunction = function() end
		local FakeRemote = {OnServerEvent = BindableOnEvent.Event, FireServer = EmptyFunction, OnServerInvoke = EmptyFunction, InvokeServer = EmptyFunction} -- set all possible functions for syntax purposes
		
		local OnEvent
		local FireEvent
		
		local Bindable
		if Type == 'RemoteEvent' then
			OnEvent = 'OnServerEvent'
			FireEvent = 'FireServer'
			
			Bindable = false
		elseif Type == 'RemoteFunction' then
			OnEvent = 'OnServerInvoke'
			FireEvent = 'InvokeServer'
			
			Bindable = true
		end
		
		if OnEvent == nil and FireEvent == nil and Bindable == nil then
			error('fakeremote.new requires a valid remote type!')
		end
		
		FakeRemote[FireEvent] = function(Self, ...) -- :FireServer equivalent
			local Function = Self[OnEvent]
			if not Function then error('No function set.') end
			
			if typeof(Function) == 'RBXScriptSignal' then
				local Return = BindableOnEvent:Fire(LocalPlayer, ...)
				return Return
			end
			
			return Function(LocalPlayer, ...)
		end
		
		if Bindable == true then -- Remote functions will have their own function set
			BindableOnEvent:Destroy()
			
			return FakeRemote
		end
		
		FakeRemote[OnEvent] = BindableOnEvent.Event
		FakeRemote['Destroy'] = function(Self)
			if Self == FakeRemote then
				BindableOnEvent:Destroy()
				
				for Index, _ in pairs(FakeRemote) do
					FakeRemote[Index] = nil
				end
			else
				Self:Destroy()
			end
		end

		return FakeRemote
	end,
}
