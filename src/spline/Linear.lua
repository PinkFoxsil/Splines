--|| Modules ||--
local Spline = require("./Spline")
local AABB = require("../mathLib/AABB")
local Type = require("../Type")
local mathUtil = require("../util/mathUtil")
local Transform = require("../mathLib/Transform")
local Quaternion = require("../mathLib/Quaternion")

--|| Variables ||--
local isInRange = mathUtil.isInRange

--|| Class ||--
local Linear = {}
Linear.__index = Linear
Linear.type = "Linear"
setmetatable(Linear, Spline)

type LinearProperties = {}

export type Linear = setmetatable<LinearProperties, typeof(Linear)> & Spline.Spline

function Linear.new(transforms: {Transform.Transform}): Linear
	assert(#transforms == 2, "Linear splines take 2 positions")
	local self = Spline.new(transforms)
	
	return setmetatable(self, Linear)
end

function Linear.sampleTanget(self: Linear, t: number): Transform.Position
	assert(isInRange(t, 0, 1), "t must be a value between 0 and 1")

	return self.positions[2] - self.positions[1]
end

function Linear.sampleRotation(self: Linear, t: number): Transform.Rotation
	assert(isInRange(t, 0, 1), "t must be a value between 0 and 1")
	
	if self.transforms[1].rotationType == "Angle" then
		local r1 = self.rotations[1]
		local r2 = self.rotations[2]
		
		return Linear.linearInterpolation(r1, r2, t)
	end
	
	if self.transforms[1].rotationType == "Quaternion" then
		local r1 = self.rotations[1] :: Quaternion.Quaternion
		local r2 = self.rotations[2] :: Quaternion.Quaternion
		
		return r1:slerp(r2, t)
	end
end

function Linear.samplePosition(self: Linear, t: number): Transform.Position
	assert(isInRange(t, 0, 1), "t must be a value between 0 and 1")

	local p1 = self.positions[1]
	local p2 = self.positions[2]
	
	return Linear.linearInterpolation(p1, p2, t)
end

function Linear.linearInterpolation<T>(val1: T, val2: T, t: number): T
	assert(isInRange(t, 0, 1), "t must be a value between 0 and 1")
	
	return (1-t)*val1 + t*val2
end

function Linear.getBoundingBox(self: Linear): AABB.AABB
	return AABB.fromVectors(self.positions)
end

return Linear
