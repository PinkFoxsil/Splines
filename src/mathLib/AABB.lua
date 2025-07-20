--|| Modules ||--
local vectorUtil = require("../util/vectorUtil")
local Type = require("../Type")

--|| Variables ||--
local mathMin = math.min
local mathMax = math.max
local unpack = table.unpack

--|| Class ||--

-- Abbrivation stands for Axis Aligned Bounding Box
local AABB = {}
AABB.__index = AABB

type Vector = Vector3 | Vector2

type AABBProperties = {
	min: Vector,
	max: Vector,
}

export type AABB = typeof(setmetatable({} :: AABBProperties, AABB))

function AABB.new(min: Vector, max: Vector): AABB
	local self = setmetatable({}, AABB)

	self.min = min
	self.max = max

	return self
end

function AABB.fromVectors(vects: { Vector }): AABB
	return AABB.new((vects[1] :: Vector3):Min(unpack(vects, 2)), (vects[1] :: Vector3):Max(unpack(vects, 2)))
end

function AABB.updateAxisValue(self: AABB, axis: Type.Axis, value: number)
	local minTable = vectorUtil.vectorToTable(self.min)
	local maxTable = vectorUtil.vectorToTable(self.max)

	minTable[axis] = mathMin((self.min :: any)[axis], value)
	maxTable[axis] = mathMax((self.min :: any)[axis], value)

	self.min = vectorUtil.tableToVector(minTable)
	self.max = vectorUtil.tableToVector(maxTable)
end

function AABB.updateAxisValues(self: AABB, axis: Type.Axis, values: { number })
	local minTable = vectorUtil.vectorToTable(self.min)
	local maxTable = vectorUtil.vectorToTable(self.max)

	minTable[axis] = mathMin((self.min :: any)[axis], unpack(values))
	maxTable[axis] = mathMax((self.min :: any)[axis], unpack(values))

	self.min = vectorUtil.tableToVector(minTable)
	self.max = vectorUtil.tableToVector(maxTable)
end

return AABB
