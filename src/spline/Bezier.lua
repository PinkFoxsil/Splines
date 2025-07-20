--|| Modules ||--
local Spline = require("./Spline")
local bernsteinPolynomialUtil = require("../util/bernsteinPolynomialUtil")
local Matrix = require("../mathLib/Matrix")
local AABB = require("../mathLib/AABB")
local transformUtil = require("../util/transformUtil")
local quaternionInterpolation = require("../util/quaternionInterpolation")
local Transform = require("../mathLib/Transform")
local Quaternion = require("../mathLib/Quaternion")

--|| Variables ||--
local binomialCoefficent = bernsteinPolynomialUtil.getBinomialCoefficent
local getBasisPolynomials = bernsteinPolynomialUtil.getBasisPolynomials
local getCumulativeBasisPolynomials = bernsteinPolynomialUtil.getCumulativeBasisPolynomials

local characteristicMatrix = Matrix.new({
	{ 1,  0,  0,  0},
	{-3,  3,  0,  0},
	{ 3, -6,  3,  0},
	{-1,  3, -3,  1}
})

--|| Class ||--
local Bezier = {}
Bezier.__index = Bezier
Bezier.type = "Bezier"
setmetatable(Bezier, Spline)

type BezierProperties = {}

export type Bezier = setmetatable<BezierProperties, typeof(Bezier)> & Spline.Spline

function Bezier.new(transforms: {Transform.Transform}): Bezier
	local self = Spline.new(transforms, characteristicMatrix)
	
	return setmetatable(self, Bezier)
end

function Bezier.sampleTanget(self: Bezier, t: number): Transform.Position
	assert(t >= 0 and t <= 1, "t must be a value between 0 and 1")
	assert(#self.positions > 2, "there aren't any points to calculate a curve")
	
	local n = #self.positions - 1
	local inverseT = 1 - t
	local point1Pos = self.positions[1]
	local point2Pos = self.positions[2]
	
	local tanget = inverseT^n * point2Pos - point1Pos

	for i = 1, n - 1 do
		local b = binomialCoefficent(n - 1, i)
		point1Pos = self.positions[i + 1]
		point2Pos = self.positions[i + 2]
		tanget += b * inverseT^(n - i) * (t^i) * (point2Pos - point1Pos)
	end

	return tanget * n
end

function Bezier.sampleRotation(self: Bezier, t: number): number | Quaternion.Quaternion
	assert(0 <= t and t <= 1, "t must be a value between 0 and 1")
	assert(#self.rotations > 0, "there aren't any points to calculate a curve")

	local degree = #self.rotations - 1

	if self.rotationType == "Angle" then
		local basisPolynomials = getBasisPolynomials(degree, t)
		local rotation = basisPolynomials[1] * self.rotations[1]

		for i = 2, #basisPolynomials do
			local basisPolynomial = basisPolynomials[i]
			rotation += basisPolynomial * self.rotations[i + 1]
		end
		
		return rotation
	end
	
	if self.rotationType == "Quaternion" then
		local cummulativeBasisPolynomials = getCumulativeBasisPolynomials(degree, t)
		return quaternionInterpolation.cumulative(self.rotations, cummulativeBasisPolynomials, t)
	end
end

function Bezier.samplePosition(self: Bezier, t: number): Transform.Position
	assert(0 <= t and t <= 1, "t must be a value between 0 and 1")
	assert(#self.positions > 0, "there aren't any points to calculate a curve")
	
	local n = #self.positions - 1
	local basisPolynomials = getBasisPolynomials(n, t)
	
	local position = basisPolynomials[1] * self.positions[1]
	
	for i = 2, #basisPolynomials do
		local basisPolynomial = basisPolynomials[i]
		position += basisPolynomial * self.positions[i]
	end
	
	return position
end

function Bezier.getCoefficents(self: Bezier): Spline.Coefficents
	local positionMatrix = Matrix.rowReverse(self.positions)
	local extremaMatrix = positionMatrix * self.characteristicMatrix

	return {
		a = extremaMatrix[1][1] * 3,
		b = extremaMatrix[1][2] * 2,
		c = extremaMatrix[1][3]
	}
end

function Bezier.getEndPositions(self: Bezier): {Transform.Position}
	return {
		self.positions[1],
		self.positions[#self.positions]
	}
end

return Bezier
