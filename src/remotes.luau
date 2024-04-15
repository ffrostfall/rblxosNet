local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local transferRemote: RemoteEvent

local remotes = {}

function remotes.init()
	if RunService:IsServer() then
		transferRemote = Instance.new("RemoteEvent")
		transferRemote.Name = "TransferRemote"
		transferRemote.Parent = ReplicatedStorage
	else
		transferRemote = ReplicatedStorage:WaitForChild("TransferRemote")
	end
end

function remotes.serverListen(callback: (player: Player, content: { [any]: any }) -> ())
	transferRemote.OnServerEvent:Connect(function(player, content)
		if typeof(content) ~= "table" then
			return
		end

		callback(player, content)
	end)
end

function remotes.clientListen(callback: (content: { [any]: any }) -> ())
	transferRemote.OnClientEvent:Connect(function(content)
		callback(content)
	end)
end

function remotes.fireServer(content: { [any]: any })
	transferRemote:FireServer(content)
end

function remotes.fireClient(player: Player, content: { [any]: any })
	transferRemote:FireClient(player, content)
end

return remotes
