local ServerScriptService = game:GetService("ServerScriptService")
local root = ServerScriptService.SplineService
local packages = root.DevPackages
local Jest = require(packages.Jest)

local runCLI = Jest.runCLI

local processServiceExists, ProcessService = pcall(function()
	return game:GetService("ProcessService")
end)

local status, result = runCLI(root.src, {
	verbose = false,
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
