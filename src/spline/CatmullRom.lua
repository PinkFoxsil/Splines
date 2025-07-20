--|| Modules ||--
local Spline = require("./Spline")
local Matrix = require("../mathLib/Matrix")
local Transform = require("../mathLib/Transform")

--|| Variables ||--
local characteristicMatrix = Matrix.new({
	{ 0,  2,  0,  0},
	{-1,  0,  1,  0},
	{ 2, -5,  4, -1},
	{-1,  3, -3,  1}
}) / 2

--|| Class ||--
local CatmullRom = setmetatable({}, Spline)
CatmullRom.__index = CatmullRom
CatmullRom.type = "CatmullRom"
setmetatable(CatmullRom, Spline)

type CatmullRomProperties = {}

export type CatmullRom = setmetatable<CatmullRomProperties, typeof(CatmullRom)> & Spline.Spline

function CatmullRom.new(transforms: {Transform.Transform}): CatmullRom
	assert(#transforms == 4, "Catmull-Rom should have 4 points")
	local self = Spline.new(transforms, characteristicMatrix)

	return setmetatable(self, CatmullRom)
end

return CatmullRom

