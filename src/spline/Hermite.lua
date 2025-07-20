--|| Modules ||--
local Spline = require("./Spline")
local Matrix = require("../mathLib/Matrix")
local Transform = require("../mathLib/Transform")
local Quaternion = require("../mathLib/Quaternion")
local Bezier = require("./Bezier")
local Transform = require("../mathLib/Transform")

--|| Variables ||--
local characteristicMatrix = Matrix.new({
	{ 1,  0,  0,  0},
	{ 0,  1,  0,  0},
	{-3, -2,  3, -1},
	{ 2,  1, -2,  1}
})

--|| Class ||--
local Hermite = {}
Hermite.__index = Hermite
Hermite.type = "Hermite"
setmetatable(Hermite, Spline)

type HermiteProperties = {
	velocities: {Transform.Position}
}

export type Hermite = setmetatable<HermiteProperties, typeof(Hermite)> & Spline.Spline

-- 1st and 3rd point are the end points. 2nd and 4th are the velocities.
function Hermite.new(transforms: Transform.Transform): Hermite
	assert(#transforms == 4, "Hermite should have 4 points")
	local self = Spline.new(transforms, characteristicMatrix)
	
	return setmetatable(self, Hermite)
end

function Hermite.getEndPositions(self: Hermite): {Transform.Transform}
	return {
		self.positions[1],
		self.positions[3]
	}
end

return Hermite
