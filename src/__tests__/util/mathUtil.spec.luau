local JestGlobals = require(script.Parent.Parent.Parent.Parent.DevPackages.JestGlobals)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

local mathUtil = require(script.Parent.Parent.Parent.util.mathUtil)

describe("quadraticEquation", function()
	it("finds the min and max of a = 5, b = 6, and c = 1 to be -1 and -0.2 respectivly", function()
		expect(mathUtil.quadraticEquation(5, 6, 1)).toEqual({
			min = -1,
			max = -0.2,
		})
	end)

	it("finds the min and max of a = -5, b = 6, and c = 1 to be near 1.35 and -0.15 respectivly", function()
		local res = mathUtil.quadraticEquation(-5, 6, 1)
		expect(res.min).toBeCloseTo(1.3483314, 3)
		expect(res.max).toBeCloseTo(-0.1483314, 3)
	end)

	it("throws an error when a == 0", function()
		expect(function()
			return mathUtil.quadraticEquation(0, 1, 1)
		end).toThrow("Value 'a' cannot be equal to 0")
	end)
end)

describe("isInRange", function()
	it("is true when val is between the min and max", function()
		expect(mathUtil.isInRange(2, 1, 3)).toBeTruthy()
	end)

	it("is false when val is outside of the min and max", function()
		expect(mathUtil.isInRange(4, -1, 1)).toBeFalsy()
	end)

	it("is true when val equals min", function()
		expect(mathUtil.isInRange(-1, -1, 1)).toBeTruthy()
	end)

	it("is true when val equals max", function()
		expect(mathUtil.isInRange(1, -1, 1)).toBeTruthy()
	end)

	it("throws when min is greater than max", function()
		expect(function()
			return mathUtil.isInRange(0, 2, 1)
		end).toThrow("The min: 2, is greater than max: 1")
	end)
end)
