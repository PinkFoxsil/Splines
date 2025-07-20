--|| Modules ||--
local Spline = require("./Spline")
local Matrix = require("../mathLib/Matrix")
local Transform = require("../mathLib/Transform")

--|| Variables ||--
local characteristicMatrix = Matrix.new({
	{ 1, 4, 1, 0 },
	{ -3, 0, 3, 0 },
	{ 3, -6, 3, 0 },
	{ -1, 3, -3, 1 },
}) / 6

--|| Class ||--
local BSpline = setmetatable({}, Spline)
BSpline.__index = BSpline
BSpline.type = "BSpline"
setmetatable(BSpline, Spline)

type BSplineProperties = {}

export type BSpline = typeof(setmetatable({} :: BSplineProperties & Spline.Spline, BSpline))

function BSpline.new(points: { Transform.Transform }): BSpline
	assert(#points == 4, "B-Spline should have 4 points")
	local self = Spline.new(points, characteristicMatrix)

	return setmetatable(self, BSpline)
end

function BSpline.getEndPositions(self: BSpline): { Transform.Position }
	return {
		self:samplePosition(0),
		self:samplePosition(1),
	}
end

return BSpline
