--|| Services ||--
local RunService = game:GetService("RunService")

--|| Modules ||--
local gizmoz = require("../util/gizmoz")
local Matrix = require("../mathLib/Matrix")
local Spline = require("../spline/Spline")

--|| Varibles ||--
local splineVisuals = {}

--|| Main ||--
local SplineVisual = {}
SplineVisual.__index = SplineVisual

type SplineVisualProperties = {}

export type SplineVisual = setmetatable<SplineVisualProperties, typeof(SplineVisual)>

function SplineVisual.new(): SplineVisual
	local self = setmetatable({}, SplineVisual)
	
	self.updateFunction = nil
	self.isPlaying = false
	self.age = 0
	self.parts = {}
	
	table.insert(splineVisuals, self)
	
	return self
end

function SplineVisual:stop()
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
	properties: {color: Color3?, transparency: number?, thickness: number?}?)
	
	partAmount = partAmount or 20
	properties = properties or {}
	local color = properties.color or Color3.new(1, 1, 1)
	local transparency = properties.transparency or 0
	local thickness = properties.thickness or 0.25
	
	local splineVisual = SplineVisual.new()
	
	local previousPos = spline:samplePosition(0)
	for i = 1, partAmount do
		local t = i / partAmount
		local pos = spline:samplePosition(t)
		local part = gizmoz.createLine(previousPos, pos, {
			color = color,
			transparency = transparency,
			thickness = thickness
		})
		
		table.insert(splineVisual.parts, part)
		
		previousPos = pos
	end
	
	return splineVisual
end

function SplineVisual.createFromT(
	spline: Spline.Spline, 
	partAmount: number, 
	properties: {color: Color3?, transparency: number?, diameter: number?}?
): SplineVisual
	
	partAmount = partAmount or 20
	properties = properties or {}
	local color = properties.color or Color3.new(1, 1, 1)
	local transparency = properties.transparency or 0
	local diameter = properties.diameter or 0.25
	
	local splineVisual = SplineVisual.new()

	for i = 0, partAmount do
		local t = i / partAmount
		local pos = spline:samplePosition(t)
		local part = gizmoz.createSphere(pos, {
			color = color,
			transparency = transparency,
			diameter = diameter
		})
		
		table.insert(splineVisual.parts, part)
	end
	
	return splineVisual
end

function SplineVisual.createFromDistance(
	spline: Spline.Spline, 
	sampleAmount: number?, 
	distance: number?, 
	properties: {color: Color3?, transparency: number?, size: number?}?
): SplineVisual
	
	sampleAmount = sampleAmount or 20
	distance = distance or 1
	properties = properties or {}
	local color = properties.color or Color3.new(1, 1, 1)
	local transparency = properties.transparency or 0
	local diameter = properties.diameter or 0.25
	
	local splineVisual = SplineVisual.new()
	local splineLength = spline:getLength(sampleAmount)
	
	for i = 0, splineLength, distance do
		local t = spline:distToT(i)
		local pos = spline:samplePosition(t)
		local part = gizmoz.createSphere(pos, {
			color = color,
			transparency = transparency,
			diameter = diameter
		})
		
		table.insert(splineVisual.parts, part)
	end
	
	return splineVisual
end

function SplineVisual.animateFromT(
	spline: Spline.Spline, 
	partAmount: number,
	speed: number?,
	properties: {color: Color3?, transparency: number?, diameter: number?}?
): SplineVisual

	partAmount = partAmount or 20
	speed = speed or 1
	properties = properties or {}
	local color = properties.color or Color3.new(1, 1, 1)
	local transparency = properties.transparency or 0
	local diameter = properties.diameter or 1
	
	local splineVisual = SplineVisual.new()

	for i = 1, partAmount do
		splineVisual.parts[i] = gizmoz.createSphere(Vector3.zero, {
			color = color,
			transparency = transparency,
			diameter = diameter
		})
	end

	splineVisual.updateFunction = function()
		local t = (splineVisual.age*speed) % 1
		for i = 1, partAmount do
			local newT = (t + i/partAmount) % 1
			splineVisual.parts[i].Position = spline:samplePosition(newT)
		end
	end
	
	splineVisual.isPlaying = true
	
	return splineVisual
end

function SplineVisual.animateFromDistance(
	spline: Spline.Spline, 
	sampleAmount: number,
	speed: number?,
	distance: number?,
	properties: {color: Color3?, transparency: number?, diameter: number?}?
): SplineVisual

	sampleAmount = sampleAmount or 20
	speed = speed or 1
	distance = distance or 1
	properties = properties or {}
	local color = properties.color or Color3.new(1, 1, 1)
	local transparency = properties.transparency or 0
	local diameter = properties.diameter or 1

	local splineVisual = SplineVisual.new()
	local splineLength = spline:getLength(sampleAmount)

	for i = 0, splineLength, distance do
		local t = spline:distToT(i)
		local pos = spline:samplePosition(t)
		local part = gizmoz.createSphere(pos, {
			color = color,
			transparency = transparency,
			diameter = diameter
		})

		table.insert(splineVisual.parts, part)
	end

	splineVisual.updateFunction = function()
		local dist = (splineVisual.age*speed)
		local index = 1
		
		for i = 0, splineLength, distance do
			local addedDist = (i + dist) % splineLength
			local t = spline:distToT(addedDist)
			splineVisual.parts[index].Position = spline:samplePosition(t)
			index += 1
		end
	end

	splineVisual.isPlaying = true

	return splineVisual
end

function SplineVisual.createAABB(spline: Spline.Spline, properties: {color: Color3?, transparency: number?}?): SplineVisual
	properties = properties or {}
	
	local splineVisual = SplineVisual.new()
	local boundingBox = spline:getBoundingBox()
	
	local part = gizmoz.createBox(boundingBox.min, boundingBox.max, properties)
	table.insert(splineVisual.parts, part)
	
	return splineVisual
end

local axises = {
	x = Vector3.xAxis,
	y = Vector3.yAxis,
	z = Vector3.zAxis
}

local hues = {
	x = 0,
	y = 120,
	z = 240
}

function SplineVisual.createExtremaPoints(spline: Spline.Spline, modelScale: number?)
	modelScale = modelScale or 1
	local splineVisual = SplineVisual.new()
	
	local derivativeTs = spline:getDerivateZeros()
	local derivativeAxisValues = {x = {}, y = {}, z = {}}
	for axis, ts in derivativeTs do
		for _, t in ts do
			local pos = self:sampleTransform(t).position
			local part = gizmoz.createPointLine(pos, axises[axis], {hue = hues[axis], size = 5}):ScaleTo(modelScale)

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
