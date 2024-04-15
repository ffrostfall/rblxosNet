local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local remotes = require(script.remotes)
local rblxos = require(ReplicatedStorage.Packages.rblxos)

type entry = {
	[string]: entry | string,
}
type content = {
	fileName: string,
	fileContent: entry,
}
type recursiveDirectory = { [string]: string | recursiveDirectory }
local function buildRecursiveDirectory(directoryPath: string): recursiveDirectory
	local fileNames = rblxos.vfs.filesInDirectory(directoryPath)
	local structure = {}

	for _, fileName in fileNames do
		local fileKind = rblxos.vfs.getFileKind(directoryPath, fileName)

		if fileKind == "file" then
			structure[fileName] = rblxos.vfs.readFile(directoryPath, fileName):read()
		elseif fileKind == "dir" then
			structure[fileName] = buildRecursiveDirectory(directoryPath .. "/" .. fileName) :: any
		end
	end

	return structure :: any
end

local function recursiveDirectoryDeserializer(path: string, directory: recursiveDirectory)
	for fileName, fileContent in directory do
		if typeof(fileContent) == "table" then
			rblxos.vfs.createDirectory(path, fileName)
			local newPath = path .. "/" .. fileName
			recursiveDirectoryDeserializer(newPath, fileContent)
		else
			rblxos.vfs.createRawFile(path, fileName, fileContent)
		end
	end
end

local replicationCallback = function(_: string) end

local rblxosFTP = {}

function rblxosFTP.init()
	remotes.init()
	rblxos.vfs.createDirectory("C:", "repl")

	if RunService:IsClient() then
		remotes.clientListen(function(fileContent: content)
			rblxos.vfs.createDirectory("C:/repl", fileContent.fileName)

			recursiveDirectoryDeserializer(`C:/repl/{fileContent.fileName}`, fileContent.fileContent)
			replicationCallback(fileContent.fileName)
		end)
	end
end

function rblxosFTP.onDirectoryReplication(callback: (name: string) -> ())
	replicationCallback = callback
end

function rblxosFTP.replicateDirectoryTo(directoryPath: string, player: Player)
	assert(RunService:IsServer(), "This function can only be called on the server")

	remotes.fireClient(player, {
		fileName = string.match(directoryPath, "%w+$") or "invalid",
		fileContent = buildRecursiveDirectory(directoryPath),
	})
end

return rblxosFTP
