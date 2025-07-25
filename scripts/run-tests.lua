local ServerScriptService = game:GetService("ServerScriptService")
local root = ServerScriptService.SplineService
local Jest = require(root.DevPackages.Jest)

local runCLI = Jest.runCLI

local processServiceExists, ProcessService = pcall(function()
	return game:GetService("ProcessService")
end)

-- https://discord.com/channels/385151591524597761/1217881206884929706/1372514179776516228

local status, result = runCLI(root.src, {
	verbose = true,
	ci = false,
}, { root.src }):awaitStatus()

if status == "Rejected" then
	print(result)
end

if status == "Resolved" and result.results.numFailedTestSuites == 0 and result.results.numFailedTests == 0 then
	if processServiceExists then
		ProcessService:ExitAsync(0)
	end
end

if processServiceExists then
	ProcessService:ExitAsync(1)
end

return nil
