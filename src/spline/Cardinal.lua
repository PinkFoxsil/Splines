--|| Modules ||--
local Spline = require("./Spline")
local Matrix = require("../mathLib/Matrix")
local Transform = require("../mathLib/Transform")

--|| Class ||--
local Cardinal = setmetatable({}, Spline)
Cardinal.__index = Cardinal
Cardinal.type = "Cardinal"
setmetatable(Cardinal, Spline)

type CardinalProperties = {}

export type Cardinal = typeof(setmetatable({} :: CardinalProperties & Spline.Spline, Cardinal))

function Cardinal.new(transforms: { Transform.Transform }, s: number): Cardinal
	assert(#transforms == 4, "Cardinal should only have 4 points")
	local self = Spline.new(
		transforms,
		Matrix.new({
			{ 0, 1, 0, 0 },
			{ -s, 0, s, 0 },
			{ 2 * s, s - 3, 3 - 2 * s, -s },
			{ -s, 2 - s, s - 2, s },
		})
	)

	return setmetatable(self, Cardinal)
end

return Cardinal
