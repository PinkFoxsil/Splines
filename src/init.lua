--|| Modules ||--
local Spline = require("@self/spline/Spline")
local Linear = require("@self/spline/Linear")
local Bezier = require("@self/spline/Bezier")
local Hermite = require("@self/spline/Hermite")
local CatmullRom = require("@self/spline/CatmullRom")
local BSpline = require("@self/spline/BSpline")
local Cardinal = require("@self/spline/Cardinal")
local SplineVisual = require("@self/visualizer/SplineVisual")
local Path = require("@self/path/Path")
local Transform = require("@self/mathLib/Transform")
local transformUtil = require("@self/util/transformUtil")

--|| Type ||--
type SplineInput = Vector2 | Vector3 | CFrame | Transform.Transform

--|| Main ||--
local SplineService = {}

-- Transform for optomized splines:

SplineService.newTransfrom = Transform.new

-- Creating Splines:

-- Linear splines are simply the lerp between 2 points.
-- Usefull for when interpolation doesn't matter.
function SplineService.createLinear(positions: { SplineInput }): Linear.Linear
	assert(#positions == 2, "Linear splines take 2 positions")
	local transforms = transformUtil.getTransforms(positions)

	return Linear.new(transforms)
end

-- Beizer splines take 2 to an infinate amount of points.
-- 1st point is the start, last point it the end.
-- Use cases: shapes, fonts, and Vector Graphics.
function SplineService.createBezier(positions: { SplineInput }): Bezier.Bezier
	assert(#positions >= 2, "Bezier splines take 2 or more points")
	local transforms = transformUtil.getTransforms(positions)

	return Bezier.new(transforms)
end

-- Hermite splines take 2 points and 2 velocities that extend from those points.
-- Use Case: animation, physics sim, and interpolation
function SplineService.createHermite(positions: { SplineInput }): Hermite.Hermite
	assert(#positions == 4, "Hermite splines take 4 positions")
	local transforms = transformUtil.getTransforms(positions)

	return Hermite.new(transforms)
end

-- Catmull-Rom splines take exactly 4 points.
-- 2nd point is the start, 3rd point is the end.
-- Use cases: aniamtion and path smoothing.
function SplineService.createCatmullRom(positions: { SplineInput }): CatmullRom.CatmullRom
	assert(#positions == 4, "Catmull-Rom splines take 4 points")
	local transforms = transformUtil.getTransforms(positions)

	return CatmullRom.new(transforms)
end

-- Cardinal splines take exactly 4 points.
-- 2nd point is the start, 3rd point is the end.
-- Cardinal splines are flexiable versions of the Catmull-Rom, allowing
-- you to specify how the curve smooths with scale.
function SplineService.createCardinal(positions: { SplineInput }, scale: number): Cardinal.Cardinal
	assert(#positions == 4, "Cardinal splines take 4 points")
	assert(0 <= scale and scale <= 1, "Scale must be a value between 0 and 1")
	local transforms = transformUtil.getTransforms(positions)

	return Cardinal.new(transforms, scale)
end

-- B-Spline splines take exactly 4 points.
-- 2nd point is the start, 3rd point is the end.
-- Use cases: curvature-sensitive shapes and animations, or camera animation.
function SplineService.createBSpline(positions: { SplineInput }): BSpline.BSpline
	assert(#positions == 4, "B-Spline splines take 4 points")
	local transforms = transformUtil.getTransforms(positions)

	return BSpline.new(transforms)
end

-- Creating Path:

-- Creates connection between multiple splines.
function SplineService.createPath(splines: { Spline.Spline }): Path.Path
	return Path.new(splines)
end

-- Creates multiple Catmull-Rom splines that pass through the given points.
function SplineService.createCatmullRomPath(positions: { SplineInput }): Path.Path
	local transforms = transformUtil.getTransforms(positions)

	return Path.constructCatmullRom(transforms)
end

-- Spline Visualization (for debugging purposes):

-- Outlines the spline with parts.
function SplineService.viewSpline(
	spline: Spline.Spline,
	partAmount: number?,
	properties: { color: Color3?, transparency: number?, thickness: number? }?
): SplineVisual.SplineVisual
	return SplineVisual.outline(spline, partAmount, properties)
end

-- Samples position along the spline with the relative t value and creates a part.
function SplineService.viewSplineTPositions(
	spline: Spline.Spline,
	partAmount: number?,
	properties: { color: Color3?, transparency: number?, diameter: number? }?
): SplineVisual.SplineVisual
	return SplineVisual.createFromT(spline, partAmount, properties)
end

-- Samples position along the spline with the relative distance value and creates a part.
function SplineService.viewSplineDistancePositions(
	spline: Spline.Spline,
	sampleAmount: number?,
	distance: number?,
	properties: { color: Color3?, transparency: number?, diameter: number? }?
): SplineVisual.SplineVisual
	return SplineVisual.createFromDistance(spline, sampleAmount, distance, properties)
end

-- Creates and animates parts along the spline with the relative t value.
function SplineService.animateSplineTPositions(
	spline: Spline.Spline,
	partAmount: number?,
	speed: number?,
	properties: { color: Color3?, transparency: number?, diameter: number? }?
): SplineVisual.SplineVisual
	return SplineVisual.animateFromT(spline, partAmount, speed, properties)
end

-- Creates and animates parts along the spline with the relative distance value.
function SplineService.animateSplineDistancePositions(
	spline: Spline.Spline,
	partAmount: number?,
	speed: number?,
	distance: number?,
	properties: { color: Color3?, transparency: number?, diameter: number? }?
): SplineVisual.SplineVisual
	return SplineVisual.animateFromDistance(spline, partAmount, speed, distance, properties)
end

-- Creates a part representing the bounding box of the spline.
function SplineService.viewBoundingBox(
	spline: Spline.Spline,
	properties: { color: Color3?, transparency: number? }?
): SplineVisual.SplineVisual
	return SplineVisual.createAABB(spline, properties)
end

-- Creates parts where the curve changes in direction relative to world axises.
function SplineService.viewCurveExtrema(spline: Spline.Spline, size: number?): SplineVisual.SplineVisual
	return SplineVisual.createExtremaPoints(spline, size)
end

-- Creates a duck that rotates along the curve.
function SplineService.animateSplineTRotation(spline: Spline.Spline, speed: number?)
	return SplineVisual.animateRotation(spline, speed)
end

return SplineService
