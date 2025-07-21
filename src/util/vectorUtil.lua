--!strict

local vectorUtil = {}

function vectorUtil.vectorToTable(vect: Vector3 | Vector2): { x: number, y: number, z: number? }
	local vectTable = {
		x = vect.X,
		y = vect.Y,
		z = nil :: number?,
	}

	if typeof(vect) == "Vector3" then
		vectTable.z = vect.Z
	end

	return vectTable
end

function vectorUtil.tableToVector(vectTable: { x: number, y: number, z: number? }): Vector3 | Vector2
	return if vectTable.z
		then Vector3.new(vectTable.x, vectTable.y, vectTable.z)
		else Vector2.new(vectTable.x, vectTable.y)
end

return vectorUtil
