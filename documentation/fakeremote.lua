local FakeRemoteLink = 'https://github.com/its-asia/convert-utility/blob/main/fakeremote.lua'
local FakeRemote = loadstring(game:HttpGet(FakeRemoteLink, true))()

-- add the script above, at the beginning of your convert
-- old script below

local Remote = Instance.new('RemoteEvent')

-- new script below

local Remote = FakeRemote.new('RemoteEvent')

-- below code will now work
-- (fire client and onclientevent dont work!)

Remove.OnServerEvent:Connect(function(Player, Print) print(Print) end) -- Player will ALWAYS be the localplayer
Remote:FireServer('Hello, world!')
