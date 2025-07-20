--|| Modules ||--
local Quaternion = require("./Quaternion")

--|| Class ||--
local Transform = {}
Transform.__index = Transform
Transform.__type = "Transform"

export type Position = Vector3 | Vector2
export type Rotation = number | Quaternion.Quaternion
export type RotationType = "Angle" | "Quaternion"

type TransformProperties = {
	position: Position,
	rotation: Rotation,
	rotationType: RotationType,
}

export type Transform = typeof(setmetatable({} :: TransformProperties, Transform))

function Transform.new(position: Position, rotation: Rotation?): Transform
	local self = setmetatable({}, Transform)

	self.position = position
	self.rotation = rotation or self:getDefaultRotation()
	self.rotationType = self:getRotationType()

	return self
end

function Transform.getRotationType(self: Transform): RotationType
	if type(self.rotation) == "number" then
		return "Angle"
	end

	if self.rotation.__type == "Quaternion" then
		return "Quaternion"
	end

	error("Transform doesn't have a rotation!")
end

function Transform.getDefaultRotation(self: Transform): Rotation
	local positionType = typeof(self.position)

	if positionType == "Vector3" then
		return Quaternion.unitQuaternion()
	end

	if positionType == "Vector2" then
		return 0
	end

	error("Transform doesn't have a position!")
end

function Transform.__add(self: Transform, vect: Position)
	return Transform.new(self.position + vect :: any, self.rotation)
end

return Transform
