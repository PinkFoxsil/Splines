--|| Services ||--
local SplineService = require(script.Parent.Parent)

--|| Variables ||--
local newTransfrom = SplineService.newTransfrom

--|| Tests ||--

-- Test Linear
local linearSpline = SplineService.createLinear({
	CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0),
	CFrame.new(10, 10, 0) * CFrame.Angles(0, math.rad(90), math.rad(90)),
})

SplineService.viewSpline(linearSpline, 15, { thickness = 0.1 })
SplineService.viewBoundingBox(linearSpline)
SplineService.animateSplineTPositions(linearSpline, 10, 0.2, { color = Color3.new(0, 0, 0), diameter = 0.2 })
SplineService.animateSplineTRotation(linearSpline, 0.25)

-- Test Bezier
local bezierSpline = SplineService.createBezier({
	CFrame.new(0, 0, 10) * CFrame.Angles(0, 0, 0),
	CFrame.new(3.3, 3.3, 12.5) * CFrame.Angles(0, math.rad(30), math.rad(30)),
	CFrame.new(6.6, 6.6, 7.5) * CFrame.Angles(0, math.rad(60), math.rad(60)),
	CFrame.new(10, 10, 10) * CFrame.Angles(0, math.rad(90), math.rad(90)),
})

SplineService.viewSpline(bezierSpline, 15, { color = Color3.new(1, 0, 0), thickness = 0.1 })
SplineService.viewBoundingBox(bezierSpline)
SplineService.animateSplineTPositions(bezierSpline, 10, 0.2, { color = Color3.new(0, 0, 0), diameter = 0.2 })
SplineService.animateSplineTRotation(bezierSpline, 0.25)

-- Test Hermite
local hermiteSpline = SplineService.createHermite({
	newTransfrom(Vector3.new(0, 0, 20), 0),
	newTransfrom(Vector3.new(10, 10, 5), 30),
	newTransfrom(Vector3.new(10, 10, 20), 90),
	newTransfrom(Vector3.new(10, 10, 5), 60),
})

SplineService.viewSpline(hermiteSpline, 15, { color = Color3.new(0, 0, 1), thickness = 0.1 })
SplineService.viewBoundingBox(hermiteSpline)
SplineService.animateSplineTPositions(hermiteSpline, 10, 0.2, { color = Color3.new(0, 0, 0), diameter = 0.2 })

-- Test Catmull-Rom
local catmullRomSpline = SplineService.createCatmullRom({
	newTransfrom(Vector3.new(-10, -10, 20), 0),
	newTransfrom(Vector3.new(0, 0, 30), 30),
	newTransfrom(Vector3.new(10, 10, 30), 60),
	newTransfrom(Vector3.new(20, 20, 40), 90),
})

SplineService.viewSpline(catmullRomSpline, 15, { color = Color3.new(0, 1, 0.7), thickness = 0.1 })
SplineService.viewBoundingBox(catmullRomSpline)
SplineService.animateSplineTPositions(catmullRomSpline, 10, 0.2, { color = Color3.new(0, 0, 0), diameter = 0.2 })

-- Test Cardinal
local cardinalSpline = SplineService.createCardinal({
	newTransfrom(Vector3.new(-10, -10, 30), 0),
	newTransfrom(Vector3.new(0, 0, 40), 30),
	newTransfrom(Vector3.new(10, 10, 40), 60),
	newTransfrom(Vector3.new(20, 20, 50), 90),
}, 0.2)

SplineService.viewSpline(cardinalSpline, 15, { color = Color3.new(0, 1, 0.7), thickness = 0.1 })
SplineService.viewBoundingBox(cardinalSpline)
SplineService.animateSplineTPositions(cardinalSpline, 10, 0.2, { color = Color3.new(0, 0, 0), diameter = 0.2 })

-- Test B-Spline
local bSplineSpline = SplineService.createBSpline({
	newTransfrom(Vector3.new(-10, -10, 40), 0),
	newTransfrom(Vector3.new(0, 0, 50), 30),
	newTransfrom(Vector3.new(10, 10, 50), 60),
	newTransfrom(Vector3.new(20, 20, 60), 90),
})

SplineService.viewSpline(bSplineSpline, 15, { color = Color3.new(1, 1, 0), thickness = 0.1 })
SplineService.viewBoundingBox(bSplineSpline)
SplineService.animateSplineTPositions(bSplineSpline, 10, 0.2, { color = Color3.new(0, 0, 0), diameter = 0.2 })
