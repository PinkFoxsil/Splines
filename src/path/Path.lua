local Spline = require("../spline/Spline")
local Bezier = require("../spline/Bezier")
local CatmullRom = require("../spline/CatmullRom")

local Path = {}
Path.__index = Path

type PathProperties = {
	splines: {Spline.Spline}
}

export type Path = typeof(setmetatable({} :: PathProperties, Path))

function Path.new(splines: {Spline.Spline}?): Path
	local self = {}
	
	self.splines = splines or {}
	
	return setmetatable(self, Path)
end

function Path.constructCatmullRom(points: {Vector3}): Path
	local path = Path.new()
	
	path.splines[1] = CatmullRom.new({
		(2*points[1] - points[2]),
		points[1],
		points[2],
		points[3]
	})
	
	for i = 1, #points - 3 do
		local splinePoints = {}
		for j = i, math.min(#points, i + 3) do
			splinePoints[#splinePoints+1] = points[j]
		end

		path.splines[#path.splines+1] = CatmullRom.new(splinePoints)
	end
	
	path.splines[#path.splines+1] = CatmullRom.new({
		points[#points-2],
		points[#points-1],
		points[#points],
		(2*points[#points] - points[#points-1]),
	})
	
	return path
end

function Path.setSplineLookupTables(self: Path, sampleAmount: number)
	for _, spline in self.splines do
		spline:setLookUpTable(sampleAmount)
	end
end

function Path.getLength(self: Path, sampleAmount: number?): number
	local totalLength = 0
	
	for _, spline in self.splines do
		totalLength += spline:getLength(sampleAmount)
	end
	
	return totalLength
end

function Path.findSplineByT(self: Path, t: number): {spline: Spline.Spline, t: number}
	assert(0 <= t and t < #self.splines, "t must be a value between 0 and the spline amount")

	local i = math.floor(t)
	return {
		spline = self.splines[i + 1],
		t = t - i
	}
end

function Path.sampleDist(self: Path, dist: number, sampleAmount: number?): Spline.Sample
	assert(dist >= 0, "dist must be a positive value")
	
	local i = 1
	while i <= #self.splines do
		local spline = self.splines[i]
		
		local splineLength = spline:getLength(sampleAmount)
		
		if dist < splineLength then
			local t = spline:distToT(dist)
			return spline:sample(t)
		end
		
		dist -= splineLength
		i += 1
	end
	
	return self.splines[#self.splines]:sample(1)
end

function Path.sample(self: Path, t: number): {position: Vector3, tanget: Vector3}
	local res = Path.findSplineByT(self, t)
	return res.spline:sample(res.t)
end

function Path.sampleTanget(self: Path, t: number): Vector3
	local res = Path.findSplineByT(self, t)
	return res.spline:sampleTanget(res.t)
end

function Path.samplePosition(self: Path, t: number): Vector3
	local res = Path.findSplineByT(self, t)
	return res.spline:samplePosition(res.t)
end

return Path
