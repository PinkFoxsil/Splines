--|| Modules ||--
local Type = require("../Type")
local Transform = require("../mathLib/Transform")
local Quaternion = require("../mathLib/Quaternion")
local cframeUtil = require("./cframeUtil")
local arrayUtil = require("./arrayUtil")

--|| Main ||--
local transformUtil = {}

function transformUtil.getTransformFromVector2(vect2: Vector2): Transform.Transform
	return Transform.new(vect2)
end

function transformUtil.getTransformFromVector3(vect3: Vector3): Transform.Transform
	return Transform.new(vect3)
end

function transformUtil.getTransformFromCFrame(cframe: CFrame): Transform.Transform
	local rotationMatrix = cframeUtil.getCFrameRotationMatrix(cframe)
	return Transform.new(cframe.Position, Quaternion.fromRotationMatrix(rotationMatrix))
end

local transformConvertFunctions: { [Type.PositionData]: (Type.PositionData) -> Transform.Transform } = {
	["Vector2"] = transformUtil.getTransformFromVector2,
	["Vector3"] = transformUtil.getTransformFromVector3,
	["CFrame"] = transformUtil.getTransformFromCFrame,
}

function transformUtil.checkIfTransform(value: Type.PositionData | Transform.Transform): boolean
	return if value and (value :: Transform.Transform).__type == "Transform" then true else false
end

function transformUtil.getTransform(value: Type.PositionData | Transform.Transform): Transform.Transform?
	local valueType = typeof(value)
	local convertFunction = transformConvertFunctions[valueType]

	if convertFunction then
		return convertFunction(value)
	end

	local isTransform = transformUtil.checkIfTransform(value)
	return if isTransform then value :: Transform.Transform else nil
end

function transformUtil.getTransforms(values: { Type.PositionData | Transform.Transform }): { Transform.Transform }
	local transforms = {}

	for _, value in values do
		local transform = transformUtil.getTransform(value)
		table.insert(transforms, transform)
	end

	return transforms
end

function transformUtil.getTransformPosition(transform: Transform.Transform): Transform.Position
	return transform.position
end

function transformUtil.getTransfromPositions(transforms: { Transform.Transform }): { Transform.Position }
	return arrayUtil.map(transforms, transformUtil.getTransformPosition)
end

function transformUtil.getTransformRotation(transform: Transform.Transform): Transform.Rotation
	return transform.rotation
end

function transformUtil.getTransformRotations(transforms: { Transform.Transform }): { Transform.Rotation }
	return arrayUtil.map(transforms, transformUtil.getTransformRotation)
end

return transformUtil
