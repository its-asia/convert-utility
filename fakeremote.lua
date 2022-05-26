local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer

return {
	new = function(Type)
		local BindableOnEvent = Instance.new('BindableEvent')

		local EmptyFunction = function() end
		
		local Remote = Instance.new('RemoteEvent')
		
		local FakeRemote = {OnServerEvent = BindableOnEvent.Event, FireServer = EmptyFunction, OnServerInvoke = EmptyFunction, InvokeServer = EmptyFunction} -- set all possible functions for syntax purposes
		local FakeRemoteMetatable = {}

		local OnEvent
		local ClientOnEvent
		
		local FireEvent
		local ClientFireEvent
		
		local FireAll = 'FireAllClients'

		local Bindable
		if Type == 'RemoteEvent' then
			OnEvent = 'OnServerEvent'
			ClientOnEvent = 'OnClientEvent'
			
			FireEvent = 'FireServer'
			ClientFireEvent = 'FireClient'

			Bindable = false
		elseif Type == 'RemoteFunction' then
			OnEvent = 'OnServerInvoke'
			ClientOnEvent = 'OnClientInvoke'
			
			FireEvent = 'InvokeServer'
			ClientFireEvent = 'InvokeClient'

			Bindable = true
		end

		if OnEvent == nil and FireEvent == nil and Bindable == nil then
			error('fakeremote.new requires a valid remote type!')
		end

		FakeRemote[FireEvent] = function(Self, ...) -- :FireServer equivalent
			local Function = Self[OnEvent]
			if not Function then error('No function set.') end

			if typeof(Function) == 'RBXScriptSignal' then
				return BindableOnEvent:Fire(LocalPlayer, ...)
			end

			return Function(LocalPlayer, ...)
		end

		FakeRemote[ClientFireEvent] = FakeRemote[FireEvent]
		FakeRemote[FireAll] = FakeRemote[FireEvent]

		if Bindable == true then -- Remote functions will have their own function set
			BindableOnEvent:Destroy()

			return FakeRemote
		end

		FakeRemote[OnEvent] = BindableOnEvent.Event
		FakeRemote[ClientOnEvent] = FakeRemote[OnEvent]
		
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
		
		FakeRemoteMetatable.__index = function(self, index)
			return rawget(FakeRemote, index) or Remote[index]
		end
		
		return setmetatable(FakeRemote, FakeRemoteMetatable)
	end,
}
