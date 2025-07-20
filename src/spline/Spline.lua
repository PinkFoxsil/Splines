--|| Modules ||--
local Type = require("../Type")
local Matrix = require("../mathLib/Matrix")
local AABB = require("../mathLib/AABB")
local Transform = require("../mathLib/Transform")
local Quaternion = require("../mathLib/Quaternion")
local arrayUtil = require("../util/arrayUtil")
local mathUtil = require("../util/mathUtil")
local cframeUtil = require("../util/cframeUtil")
local transformUtil = require("../util/transformUtil")
local errorMsgs = require("../constants/errorMsgs")

--|| Variables ||--
local defaultSampleAmount = script:GetAttribute("defaultSampleAmount")
local isInRange = mathUtil.isInRange
local getTOutOfRangeErrorMsg = errorMsgs.getTOutOfRangeErrorMsg

--|| Class ||--
local Spline = {}
Spline.__index = Spline

type SplineProperties = {
	transforms: {Transform.Transform},
	rotationType: Transform.RotationType,
	rotations: {Transform.Rotation},
	positions: {Transform.Position},
	rotationMatrix: Matrix.Matrix<Transform.Rotation>,
	positionMatrix: Matrix.Matrix<Transform.Position>,
	characteristicMatrix: Matrix.Matrix<number>?,
	lookUpTable: {number}
}

export type Spline = setmetatable<SplineProperties, typeof(Spline)>

function Spline.new(transforms: {Transform.Transform}, characteristicMatrix: Matrix.Matrix<number>?): Spline
	local self = {}

	self.transforms = transforms
	self.rotationType = self.transforms[1].rotationType
	self.rotations = transformUtil.getTransformRotations(self.transforms)
	self.positions = transformUtil.getTransfromPositions(self.transforms)
	self.rotationMatrix = Matrix.collum(self.rotations)
	self.positionMatrix = Matrix.collum(self.positions)
	self.characteristicMatrix = characteristicMatrix

	return setmetatable(self, Spline)
end

function Spline.sampleCFrame(self: Spline, t: number): CFrame
	assert(isInRange(t, 0, 1), getTOutOfRangeErrorMsg(t))
	assert(self.rotationType == "Quaternion", "Can't sample a CFrame when the spline rotations are in 2D / 1-angle")
	
	local position = self:samplePosition(t)
	local rotation = self:sampleRotation(t) :: Quaternion.Quaternion
	
	return CFrame.new(position) * cframeUtil.getCFrameFromQuaternion(rotation)
end

function Spline.sampleTransform(self: Spline, t: number): Transform.Transform
	assert(isInRange(t, 0, 1), getTOutOfRangeErrorMsg(t))
	
	local position = self:samplePosition(t)
	local rotation = self:sampleRotation(t)

	return Transform.new(position, rotation)
end

function Spline.sampleRotation(self: Spline, t: number): Transform.Rotation
	if self.rotationType == "Angle" then
		return (self:getWeights(t) * self.rotationMatrix)[1][1]
	else
		
	end
end

function Spline.samplePosition(self: Spline, t: number): Transform.Position
	assert(isInRange(t, 0, 1), getTOutOfRangeErrorMsg(t))

	return (self:getWeights(t) * self.positionMatrix)[1][1]
end

function Spline.sampleTanget(self: Spline, t: number): Transform.Position
	assert(isInRange(t, 0, 1), getTOutOfRangeErrorMsg(t))

	return (self:getDerivativeWeights(t) * self.positionMatrix)[1][1]
end

function Spline.getWeights(self: Spline, t: number): Matrix.Matrix<number>
	return Matrix.row({1, t, t^2, t^3}) * self.characteristicMatrix
end

function Spline.getDerivativeWeights(self: Spline, t: number): Matrix.Matrix<number>
	return Matrix.row({0, 1, 2*t, 3*t^2}) * self.characteristicMatrix
end

export type Coefficents = {
	a: Transform.Position,
	b: Transform.Position,
	c: Transform.Position
}

function Spline.getCoefficents(self: Spline): Coefficents
	local extremaMatrix = self.characteristicMatrix * self.positionMatrix
	
	return {
		a = extremaMatrix[4][1] * 3,
		b = extremaMatrix[3][1] * 2,
		c = extremaMatrix[2][1]
	}
end

export type Extremas = {
	x: number,
	y: number,
	z: number
}

function Spline.getTExtrema(self: Spline): Extremas
	local coefficents = self:getCoefficents()
	local a, b, c = coefficents.a, coefficents.b, coefficents.c

	return {
		x = mathUtil.quadraticEquation(a.x, b.x, c.x),
		y = mathUtil.quadraticEquation(a.y, b.y, c.y),
		z = mathUtil.quadraticEquation(a.z, b.z, c.z)
	}
end

export type DerivativeZeros = {
	x: {number},
	y: {number},
	z: {number}
}

function Spline.getDerivateZeros(self: Spline): DerivativeZeros
	local tExtrema = self:getTExtrema()

	local derivativeTValues = {x = {}, y = {}, z = {}}

	for axis, range in tExtrema do
		for _, t in range do
			if 0 < t and t < 1 then
				table.insert(derivativeTValues[axis], t)
			end
		end
	end
	
	return derivativeTValues
end

function Spline.getEndPositions(self: Spline): {Transform.Position}
	return {
		self.positions[2],
		self.positions[3]
	}
end

function Spline.getBoundingBox(self: Spline): AABB.AABB
	assert(#self.positions == 4, "can only get bounding box for a spline with 4 points")
	local endPoints = self:getEndPositions()
	
	local aabb = AABB.fromVectors({
		endPoints[1],
		endPoints[2]
	})
	
	local derivativeTs = self:getDerivateZeros()
	
	-- Get derivativeTs positions
	local derivativeAxisValues = {x = {}, y = {}, z = {}}
	for axis, ts in derivativeTs do
		for _, t in ts do
			local pos = self:samplePosition(t)
			table.insert(derivativeAxisValues[axis], pos[axis])
		end
	end
	
	for axis, values in derivativeAxisValues do
		aabb:updateAxisValues(axis, values)
	end
	
	return aabb
end

function Spline.setLookUpTable(self: Spline, sampleAmount: number): {number}
	local newLookUpTable = {0}

	local lastPosition = self:samplePosition(0)
	
	for i = 1, sampleAmount do
		local position = self:samplePosition(i / sampleAmount)
		
		local distance = (position - lastPosition).magnitude + newLookUpTable[i]

		newLookUpTable[i+1] = distance
		lastPosition = position
	end

	self.lookUpTable = newLookUpTable
	return self.lookUpTable
end

function Spline.getLookUpTable(self: Spline, sampleAmount: number?): {number}
	return self.lookUpTable or self:setLookUpTable(sampleAmount or defaultSampleAmount)
end

function Spline.distToT(self: Spline, dist: number, sampleAmount: number?): number
	local LUT = self:getLookUpTable(sampleAmount)

	for i = 1, #LUT - 1 do
		if LUT[i] <= dist and dist < LUT[i+1] then
			local lerp = (dist - LUT[i]) / (LUT[i+1] - LUT[i])
			return ((1-lerp)*(i-1) + lerp*i) / (#LUT-1)
		end
	end

	return dist / self:getLength()
end

function Spline.getLength(self: Spline, sampleAmount: number?): number
	local LUT = self:getLookUpTable(sampleAmount)
	
	return LUT[#LUT]
end

return Spline