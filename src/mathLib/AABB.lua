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

type AABBProperties = {
	min: Type.Vector,
	max: Type.Vector
}

export type AABB = setmetatable<AABBProperties, typeof(AABB)>

function AABB.new(min: Type.Vector, max: Type.Vector): AABB
	local self = setmetatable({}, AABB)
	
	self.min = min
	self.max = max
	
	return self
end

function AABB.fromVectors(vects: {Type.Vector}): AABB
	return AABB.new(
		vects[1]:Min(unpack(vects, 2)), 
		vects[1]:Max(unpack(vects, 2))
	)
end

function AABB.updateAxisValue(self: AABB, axis: Type.Axis, value: number)
	local minTable = vectorUtil.vectorToTable(self.min)
	local maxTable = vectorUtil.vectorToTable(self.max)
	
	minTable[axis] = mathMin(self.min[axis], value)
	maxTable[axis] = mathMax(self.max[axis], value)
	
	self.min = vectorUtil.tableToVector(minTable)
	self.max = vectorUtil.tableToVector(maxTable)
end

function AABB.updateAxisValues(self: AABB, axis: Type.Axis, values: {number})
	local minTable = vectorUtil.vectorToTable(self.min)
	local maxTable = vectorUtil.vectorToTable(self.max)

	minTable[axis] = mathMin(self.min[axis], unpack(values))
	maxTable[axis] = mathMax(self.max[axis], unpack(values))

	self.min = vectorUtil.tableToVector(minTable)
	self.max = vectorUtil.tableToVector(maxTable)
end

return AABB
