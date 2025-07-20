--|| Modules ||--
local Matrix = require("../mathLib/Matrix")
local Quaternion = require("../mathLib/Quaternion")

--|| Main ||--
local cframeUtil = {}

function cframeUtil.getCFrameRotationMatrix(cframe: CFrame): Matrix.Matrix<number>
	local xVect = cframe.XVector
	local yVect = cframe.YVector
	local zVect = cframe.ZVector

	return Matrix.new({
		{xVect.X, yVect.X, zVect.X},
		{xVect.Y, yVect.Y, zVect.Y},
		{xVect.Z, yVect.Z, zVect.Z}
	})
end

function cframeUtil.getCFrameFromQuaternion(quaternion: Quaternion.Quaternion): CFrame
	return CFrame.new(0, 0, 0, quaternion.x, quaternion.y, quaternion.z, quaternion.w)
end

return cframeUtil
