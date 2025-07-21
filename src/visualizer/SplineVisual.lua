--|| Services ||--
local RunService = game:GetService("RunService")

--|| Modules ||--
local gizmoz = require("../util/gizmoz")
local Spline = require("../spline/Spline")

--|| Varibles ||--
local splineVisuals = {}

--|| Main ||--
local SplineVisual = {}
SplineVisual.__index = SplineVisual

type SplineVisualProperties = {
	updateFunction: () -> (),
	isPlaying: boolean,
	age: number,
	parts: { Instance },
}

export type SplineVisual = typeof(setmetatable({} :: SplineVisualProperties, SplineVisual))

function SplineVisual.new(): SplineVisual
	local self = setmetatable({}, SplineVisual)

	self.updateFunction = nil
	self.isPlaying = false
	self.age = 0
	self.parts = {}

	table.insert(splineVisuals, self)

	return self
end

function SplineVisual.stop(self: SplineVisual)
	for _, part in self.parts do
		part:Destroy()
	end

	self.isPlaying = false
end

function SplineVisual:pause()
	self.isPlaying = false
end

function SplineVisual:resume()
	self.isPlaying = true
end

function SplineVisual.outline(
	spline: Spline.Spline,
	partAmount: number?,
	properties: { color: Color3?, transparency: number?, thickness: number? }?
)
	local newPartAmount = partAmount or 20
	local newProperties = properties or {}
	local color = newProperties.color or Color3.new(1, 1, 1)
	local transparency = newProperties.transparency or 0
	local thickness = newProperties.thickness or 0.25

	local splineVisual = SplineVisual.new()

	local previousPos = spline:samplePosition(0)
	for i = 1, newPartAmount do
		local t = i / newPartAmount
		local pos = spline:samplePosition(t)
		local part = gizmoz.createLine(previousPos, pos, {
			color = color,
			transparency = transparency,
			thickness = thickness,
		})

		table.insert(splineVisual.parts, part)

		previousPos = pos
	end

	return splineVisual
end

function SplineVisual.createFromT(
	spline: Spline.Spline,
	partAmount: number?,
	properties: { color: Color3?, transparency: number?, diameter: number? }?
): SplineVisual
	local newPartAmount = partAmount or 20
	local newProperties = properties or {}
	local color = newProperties.color or Color3.new(1, 1, 1)
	local transparency = newProperties.transparency or 0
	local diameter = newProperties.diameter or 0.25

	local splineVisual = SplineVisual.new()

	for i = 0, newPartAmount do
		local t = i / newPartAmount
		local pos = spline:samplePosition(t)
		local part = gizmoz.createSphere(pos, {
			color = color,
			transparency = transparency,
			diameter = diameter,
		})

		table.insert(splineVisual.parts, part)
	end

	return splineVisual
end

function SplineVisual.createFromDistance(
	spline: Spline.Spline,
	sampleAmount: number?,
	distance: number?,
	properties: { color: Color3?, transparency: number?, size: number? }?
): SplineVisual
	local newSampleAmount = sampleAmount or 20
	local newDistance = distance or 1
	local newProperties = properties or {}
	local color = newProperties.color or Color3.new(1, 1, 1)
	local transparency = newProperties.transparency or 0
	local diameter = newProperties.diameter or 0.25

	local splineVisual = SplineVisual.new()
	local splineLength = spline:getLength(newSampleAmount)

	for i = 0, splineLength, newDistance do
		local t = spline:distToT(i)
		local pos = spline:samplePosition(t)
		local part = gizmoz.createSphere(pos, {
			color = color,
			transparency = transparency,
			diameter = diameter,
		})

		table.insert(splineVisual.parts, part)
	end

	return splineVisual
end

function SplineVisual.animateFromT(
	spline: Spline.Spline,
	partAmount: number?,
	speed: number?,
	properties: { color: Color3?, transparency: number?, diameter: number? }?
): SplineVisual
	local newPartAmount = partAmount or 20
	local newSpeed = speed or 1
	local newProperties = properties or {}
	local color = newProperties.color or Color3.new(1, 1, 1)
	local transparency = newProperties.transparency or 0
	local diameter = newProperties.diameter or 1

	local splineVisual = SplineVisual.new()

	for i = 1, newPartAmount do
		splineVisual.parts[i] = gizmoz.createSphere(Vector3.zero, {
			color = color,
			transparency = transparency,
			diameter = diameter,
		})
	end

	splineVisual.updateFunction = function()
		local t = (splineVisual.age * newSpeed) % 1
		for i = 1, newPartAmount do
			local newT = (t + i / newPartAmount) % 1
			splineVisual.parts[i].Position = spline:samplePosition(newT)
		end
	end

	splineVisual.isPlaying = true

	return splineVisual
end

function SplineVisual.animateFromDistance(
	spline: Spline.Spline,
	sampleAmount: number?,
	speed: number?,
	distance: number?,
	properties: { color: Color3?, transparency: number?, diameter: number? }?
): SplineVisual
	local newSampleAmount = sampleAmount or 20
	local newSpeed = speed or 1
	local newDistance = distance or 1
	local newProperties = properties or {}
	local color = newProperties.color or Color3.new(1, 1, 1)
	local transparency = newProperties.transparency or 0
	local diameter = newProperties.diameter or 1

	local splineVisual = SplineVisual.new()
	local splineLength = spline:getLength(newSampleAmount)

	for i = 0, splineLength, newDistance do
		local t = spline:distToT(i)
		local pos = spline:samplePosition(t)
		local part = gizmoz.createSphere(pos, {
			color = color,
			transparency = transparency,
			diameter = diameter,
		})

		table.insert(splineVisual.parts, part)
	end

	splineVisual.updateFunction = function()
		local dist = (splineVisual.age * newSpeed)
		local index = 1

		for i = 0, splineLength, newDistance do
			local addedDist = (i + dist) % splineLength
			local t = spline:distToT(addedDist)
			splineVisual.parts[index].Position = spline:samplePosition(t)
			index += 1
		end
	end

	splineVisual.isPlaying = true

	return splineVisual
end

function SplineVisual.createAABB(
	spline: Spline.Spline,
	properties: { color: Color3?, transparency: number? }?
): SplineVisual
	local newProperties = properties or {}

	local splineVisual = SplineVisual.new()
	local boundingBox = spline:getBoundingBox()

	local part = gizmoz.createBox(boundingBox.min, boundingBox.max, newProperties)
	table.insert(splineVisual.parts, part)

	return splineVisual
end

local axises = {
	x = Vector3.xAxis,
	y = Vector3.yAxis,
	z = Vector3.zAxis,
}

local hues = {
	x = 0,
	y = 120,
	z = 240,
}

function SplineVisual.createExtremaPoints(self: SplineVisual, spline: Spline.Spline, modelScale: number?)
	local newModelScale = modelScale or 1
	local splineVisual = SplineVisual.new()

	local derivativeTs = spline:getDerivateZeros()
	for axis, ts in derivativeTs do
		for _, t in ts do
			local pos = self:sampleTransform(t).position
			local part =
				gizmoz.createPointLine(pos, axises[axis], { hue = hues[axis], size = 5 }):ScaleTo(newModelScale)

			table.insert(splineVisual.parts, part)
		end
	end

	return splineVisual
end

function SplineVisual.animateRotation(spline: Spline.Spline, speed: number)
	speed = speed or 1

	local splineVisual = SplineVisual.new()

	local duck = gizmoz.createDuck(CFrame.new())
	table.insert(splineVisual.parts, duck)

	splineVisual.updateFunction = function()
		local t = (splineVisual.age * speed) % 1
		splineVisual.parts[1].CFrame = spline:sampleCFrame(t)
	end

	splineVisual.isPlaying = true

	return splineVisual
end

-- TODO: add control points visual

--|| Events ||--
local function onFrame(deltaTime: number)
	for _, splineVisual in splineVisuals do
		if splineVisual.updateFunction and splineVisual.isPlaying then
			splineVisual.age += deltaTime
			splineVisual.updateFunction()
		end
	end
end

RunService.Heartbeat:Connect(onFrame)

--|| Return ||--
return SplineVisual
