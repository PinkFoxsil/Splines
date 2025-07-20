local pointLine = script.Parent.Parent.assets
local duckMesh = script.Duck

local folder = Instance.new("Folder")
folder.Name = "Gizmoz"
folder.Parent = workspace

type partProperties = {
	color: Color3?,
	transparency: number?,
	material: Enum.Material?,
	name: string?,
}

local gizmoz = {}

function gizmoz.createSphere(position: Vector3, properties: { diameter: number? } & partProperties): Part
	local diameter = properties.diameter or 1
	local color = properties.color or Color3.new(0, 1, 0)
	local transparency = properties.transparency or 0.5
	local material = properties.material or Enum.Material.SmoothPlastic
	local name = properties.name or "Sphere"

	local part = Instance.new("Part")
	part.Name = name
	part.Size = Vector3.one * diameter
	part.Position = position
	part.Color = color
	part.Transparency = transparency
	part.Material = material
	part.Shape = Enum.PartType.Ball
	part.Anchored = true
	part.CanCollide = false
	part.Parent = folder

	return part
end

function gizmoz.createBox(position1: Vector3, position2: Vector3, properties: partProperties): Part
	local color = properties.color or Color3.new(0, 1, 0)
	local transparency = properties.transparency or 0.5
	local material = properties.material or Enum.Material.SmoothPlastic
	local name = properties.name or "Box"

	local p1ToP2 = position2 - position1

	local part = Instance.new("Part")
	part.Name = name
	part.Size = p1ToP2
	part.Position = position1 + p1ToP2 / 2
	part.Color = color
	part.Transparency = transparency
	part.Material = material
	part.Anchored = true
	part.CanCollide = false
	part.Parent = folder

	return part
end

function gizmoz.createLine(
	position1: Vector3,
	position2: Vector3,
	properties: partProperties & { thickness: number? }
): Part
	local color = properties.color or Color3.new(0, 1, 0)
	local transparency = properties.transparency or 0.5
	local material = properties.material or Enum.Material.SmoothPlastic
	local name = properties.name or "Line"
	local thickness = properties.thickness or 1

	local middlePosition = (position1 + position2) / 2
	local distance = (position2 - position1).Magnitude

	local part = Instance.new("Part")
	part.Name = name
	part.Size = Vector3.new(thickness, thickness, distance)
	part.CFrame = CFrame.lookAt(middlePosition, position2)
	part.Color = color
	part.Transparency = transparency
	part.Material = material
	part.Anchored = true
	part.CanCollide = false
	part.Parent = folder

	return part
end

function gizmoz.createPointLine(
	position: Vector3,
	direction: Vector3,
	properties: { hue: number?, size: number? }
): Model
	local newPointLine = pointLine:Clone()
	newPointLine:PivotTo(CFrame.new(position))

	if properties.size then
		newPointLine:ScaleTo(properties.size)
	end

	local hue = properties.hue and properties.hue / 359 or 0.5
	local brightColor = Color3.fromHSV(hue, 1, 1)
	local darkColor = Color3.fromHSV(hue, 1, 0.25)

	local mainPoint = newPointLine.SplinePoint
	mainPoint.Color = brightColor

	local innerPoint = newPointLine.Inner
	innerPoint.Color = darkColor

	local centerBeam = newPointLine.CenterBeam
	centerBeam.Color = ColorSequence.new(brightColor)

	local outerBeam = newPointLine.OuterBeam
	outerBeam.Color = ColorSequence.new(darkColor)

	local attachment0 = mainPoint.Attachment0
	local offset0 = attachment0.CFrame.Position.Magnitude * direction
	mainPoint.Attachment0.CFrame = CFrame.new(offset0)

	local attachment1 = mainPoint.Attachment1
	local offset1 = attachment1.CFrame.Position.Magnitude * -direction
	mainPoint.Attachment1.CFrame = CFrame.new(offset1)

	newPointLine.Parent = folder

	return newPointLine
end

function gizmoz.createDuck(cframe: CFrame): MeshPart
	local duck = duckMesh:Clone()
	duck.CFrame = cframe
	duck.Parent = folder

	return duck
end

return gizmoz
