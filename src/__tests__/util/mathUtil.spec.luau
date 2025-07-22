local JestGlobals = require(script.Parent.Parent.Parent.Parent.DevPackages.JestGlobals)

local it = JestGlobals.it
local expect = JestGlobals.expect

local mathUtil = require(script.Parent.Parent.Parent.util.mathUtil)

it("finds the quadratic min and max of a = 5, b = 6, and c = 1", function()
	expect(mathUtil.quadraticEquation(5, 6, 1)).toEqual({
		min = -1,
		max = -0.2,
	})
end)
