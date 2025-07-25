local JestGlobals = require(script.Parent.Parent.Parent.DevPackages.JestGlobals)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local fn = JestGlobals.jest.fn

local arrayUtil = require(script.Parent.arrayUtil)

describe("map", function()
	local function increment(val: number): number
		return val + 1
	end

	it("returns a table of elements ran through callback function", function()
		local res = arrayUtil.map({ 1, 2, 5 }, increment)
		expect(res).toEqual({ 2, 3, 6 })
	end)

	it("calls the callback function as many times as there are elements", function()
		local mock, mockFn = fn()
		arrayUtil.map({ 1, 2, 5 }, mockFn)
		expect(mock).toHaveBeenCalledTimes(3)
	end)
end)
