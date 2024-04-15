local Players = game:GetService("Players")

local rblxosFTP = require(script.Parent.Parent.Packages.rblxosFTP)
local rblxos = require(script.Parent.Parent.Packages.rblxos)

rblxosFTP.init()

rblxos.vfs.createDirectory("C:", "replicated")
rblxos.vfs.createRawFile("C:/replicated", "test", "yops")

Players.PlayerAdded:Connect(function(player: Player)
	task.wait(5)

	rblxosFTP.replicateDirectoryTo("C:/replicated", player)
end)
