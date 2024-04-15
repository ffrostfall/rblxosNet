local rblxosFTP = require(script.Parent.Parent.Packages.rblxosFTP)
local rblxos = require(script.Parent.Parent.Packages.rblxos)
rblxosFTP.init()

rblxosFTP.onDirectoryReplication(function(name)
	print(name)

	print(rblxos.vfs.readFile("C:/repl/replicated", "test"):read())
end)
