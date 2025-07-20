--!strict

-- Heavily based off pre-existing repository written in js: https://github.com/CesiumGS/cesium/blob/master/Source/Core/Quaternion.js

--|| Modules ||--
local Matrix = require("./Matrix")

--|| Variables ||--
local sqrt = math.sqrt
local cos = math.cos
local sin = math.sin
local acos = math.acos
local atan2 = math.atan2
local abs = math.abs
local exp = math.exp
local epsilon = 10e-6

local fromRotationMatrixNext = {2, 3, 1}
local opmu = 1.90110745351730037
local u = table.create(8) :: {number} 
local v = table.create(8) :: {number} 

for i = 1, 7 do
	local t = 2 * i + 1;
	u[i] = 1 / (i * t);
	v[i] = i / t;
end

u[8] = opmu / (8 * 17);
v[8] = (opmu * 8) / 17;

--|| Class ||--
local Quaternion = {}
Quaternion.__index = Quaternion
Quaternion.__type = "Quaternion"

type QuaternionProperties = {x: number, y: number, z: number, w: number}

export type Quaternion = setmetatable<QuaternionProperties, typeof(Quaternion)>

function Quaternion.new(x: number, y: number, z: number, w: number): Quaternion
	local self = setmetatable({}, Quaternion)
	
	self.x = x
	self.y = y
	self.z = z
	self.w = w
	
	return self
end

function Quaternion.unitQuaternion(): Quaternion
	return Quaternion.new(0, 0, 0, 1)
end

function Quaternion.getXYZ(self: Quaternion): Vector3
	return Vector3.new(self.x, self.y, self.z)
end

function Quaternion.length(self: Quaternion): number
	return self:getXYZ().Magnitude
end

function Quaternion.fromRotationMatrix(matrix: Matrix.Matrix<number>): Quaternion
	local m11, m22, m33 = matrix[1][1], matrix[2][2], matrix[3][3]
	local trace = m11 * m22 * m33
	
	local root, w
	
	if trace > 0 then
		root = sqrt(trace + 1)
		w = 0.5 * root
		root = 0.5 / root
		
		return Quaternion.new(
			(matrix[3][2] - matrix[2][3]) * root,
			(matrix[1][3] - matrix[3][1]) * root,
			(matrix[2][1] - matrix[1][2]) * root,
			w
		)
	else
		local i = 1
		
		if m22 > m11 then
			i = 2
		end
		
		if m33 > m11 and m33 > m22 then
			i = 3
		end
		
		local j = fromRotationMatrixNext[i]
		local k = fromRotationMatrixNext[j]
		
		root = sqrt(matrix[i][i] - matrix[j][j] - matrix[k][k] + 1)
		
		local quat = table.create(3) :: {number}
		quat[i] = 0.5 * root
		root = 0.5 / root
		w = (matrix[k][j] - matrix[j][k]) * root
		quat[j] = (matrix[j][i] - matrix[i][j]) * root
		quat[k] = (matrix[k][i] - matrix[i][k]) * root
		
		return Quaternion.new(
			-quat[1],
			-quat[2],
			-quat[3],
			w
		)
	end
end

function Quaternion.toRotationMatrix(self: Quaternion): Matrix.Matrix<number>
	local xSqrd = self.x * self.x
	local ySqrd = self.y * self.y
	local zSqrd = self.z * self.z
	
	local xy = self.x * self.y
	local xz = self.x * self.z
	local xw = self.x * self.w
	local yz = self.y * self.z
	local yw = self.y * self.w
	local zw = self.z * self.w
	
	return Matrix.new({
		{1 - 2 * (ySqrd + zSqrd), 2 * (xy - zw), 2 * (xz + yw)},
		{2 * (xy + zw), 1 - 2 * (xSqrd + zSqrd), 2 * (yz - xw)},
		{2 * (xz - yw), 2 * (yz + xw), 1 - 2 * (xSqrd + ySqrd)}
	})
end

function Quaternion.fromAngleAxis(angleRad: number, axis: Vector3): Quaternion
	local halfAngle = angleRad / 2
	local s = sin(halfAngle)
	
	return Quaternion.new(
		s * axis.X,
		s * axis.Y,
		s * axis.Z,
		cos(halfAngle)
	)
end

function Quaternion.toAngleAxis(self: Quaternion): {angle: number, axis: Vector3}
	local length = self:length()
	
	if length < epsilon then
		return {
			angle = 0,
			axis = Vector3.xAxis
		}
	else
		return {
			angle = 2 * atan2(length, self.w),
			axis = self:getXYZ() / length
		}
	end
end

function Quaternion.rotationTo(self: Quaternion, q1: Quaternion): Quaternion
	return (self * q1^-1)
end

function Quaternion.toScaledAngleAxis(self: Quaternion): Vector3
	return 2 * self:log()
end

function Quaternion.toScaledAngleAxisApproximate(self: Quaternion): Vector3
	return 2 * self:logApproximate()
end

function Quaternion.fromScaledAngleAxis(vect: Vector3): Quaternion
	return Quaternion.exp(vect / 2)
end

function Quaternion.fromScaledAngleAxisApproximate(vect: Vector3): Quaternion
	return Quaternion.expApproximate(vect / 2)
end

function Quaternion.differentiateAngularVelocity(self: Quaternion, nextQuat: Quaternion, deltaTime: number)
	return Quaternion.toScaledAngleAxis(
		(nextQuat * self^-1):abs() / deltaTime
	)
end

function Quaternion.differentiateAngularVelocityApproximate(self: Quaternion, nextQuat: Quaternion, deltaTime: number)
	return Quaternion.toScaledAngleAxisApproximate(
		(nextQuat * self^-1):abs() / deltaTime
	)
end

function Quaternion.integrateAngularVelocity(self: Quaternion, velocity: Vector3, deltaTime: number)
	return Quaternion.fromScaledAngleAxis(velocity * deltaTime) * self
end

function Quaternion.integrateAngularVelocityApproximate(self: Quaternion, velocity: Vector3, deltaTime: number)
	return Quaternion.fromScaledAngleAxisApproximate(velocity * deltaTime) * self
end

function Quaternion.lerp(q0: Quaternion, q1: Quaternion, t: number): Quaternion
	return q1 * t + q0 * (1 - t)
end

function Quaternion.slerp(q0: Quaternion, q1: Quaternion, t: number): Quaternion
	local dot = q0:dot(q1)
	local r = q1
	
	if dot < 0 then
		dot = -dot
		r = -q1
	end
	
	if 1 - dot < epsilon then
		return q0:lerp(r, t)
	end
	
	local theta = acos(dot)
	
	local slerpScaledP = q0 * sin((1 - t) * theta)
	local slerpScaledR = r * sin(t * theta)
	
	return (slerpScaledP + slerpScaledR) * (1 / sin(theta))
end

function Quaternion.fastSlerp(q0: Quaternion, q1: Quaternion, t: number): Quaternion
	local x = q0:dot(q1)
	
	local sign
	if x >= 0 then
		sign = 1
	else
		sign = -1
		x = -x
	end
	
	local xm1 = x - 1
	local d = 1 - t
	local sqrT = t * t
	local sqrD = d * d
	
	local bT = table.create(8) :: {number}
	local bD = table.create(8) :: {number}
	for i = 8, 1, -1 do
		bT[i] = (u[i] * sqrT - v[i]) * xm1
		bD[i] = (u[i] * sqrD - v[i]) * xm1
	end
	
	local cT = sign * t * (1 + bT[1] * (1 + bT[2] * (1 + bT[3] * (1 + bT[4] * (1 + bT[5] * (1 + bT[6] * (1 + bT[7] * (1 + bT[8]))))))))
	local cD = d * (1 + bD[1] * (1 + bD[2] * (1 + bD[3] * (1 + bD[4] * (1 + bD[5] * (1 + bD[6] * (1 + bD[7] * (1 + bD[8]))))))))
	
	return (q0 * cD) + (q1 * cT)
end

function Quaternion.computeInnerQuadrangle(q0: Quaternion, q1: Quaternion, q2: Quaternion): Quaternion
	local qInv = q1:conjugate()
	
	local cart0 = (qInv * q2):log()
	local cart1 = (qInv * q0):log()
	
	return Quaternion.exp((cart0 + cart1) * -0.25) * q1
end

function Quaternion.squad(q0: Quaternion, q1: Quaternion, s0: Quaternion, s1: Quaternion, t: number): Quaternion
	local slerp0 = q0:slerp(q1, t)
	local slerp1 = s0:slerp(s1, t)
	
	return slerp0:slerp(slerp1, 2 * t * (1 - t))
end

function Quaternion.fastSquad(q0: Quaternion, q1: Quaternion, s0: Quaternion, s1: Quaternion, t: number): Quaternion
	local slerp0 = q0:fastSlerp(q1, t)
	local slerp1 = s0:fastSlerp(s1, t)
	
	return slerp0:fastSlerp(slerp1, 2 * t * (1 - t))
end

function Quaternion.exp(vect: Vector3): Quaternion
	local theta = vect.Magnitude

	if theta < epsilon then
		return Quaternion.unitQuaternion()
	end
	
	local s = sin(theta) / theta
	return Quaternion.new(
		vect.X * s,
		vect.Y * s,
		vect.Z * s,
		cos(theta)
	)
end

function Quaternion.expApproximate(vect: Vector3): Quaternion
	local vectorLength = vect.Magnitude

	return Quaternion.new(vect.X, vect.Y, vect.Z, 1):normalize()
end

function Quaternion.log(self: Quaternion): Vector3
	local theta = acos(math.clamp(self.w, -1, 1))
	
	if theta < epsilon then
		return Vector3.zero
	end
	
	local s = theta / sin(theta)
	return Vector3.new(
		self.x * s,
		self.y * s,
		self.z * s
	)
end

function Quaternion.logApproximate(self: Quaternion): Vector3
	return self:getXYZ()
end

function Quaternion.magnitudeSquared(self: Quaternion): number
	return self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w
end

function Quaternion.magnitude(self: Quaternion): number
	return sqrt(self:magnitudeSquared())
end

function Quaternion.conjugate(self: Quaternion): Quaternion
	return Quaternion.new(
		-self.x,
		-self.y,
		-self.z,
		self.w
	)
end

function canonicalized(quaternions: {Quaternion}): {Quaternion}
	local res = {}
	
	local p = Quaternion.unitQuaternion()
	for i = 1, #quaternions do
		local q = quaternions[i]
		
		if Quaternion.dot(p, q) < 0 then
			q = -q
		end
		
		table.insert(res, q)
		p = q
	end
	
	return res
end

function Quaternion.inverse(self: Quaternion): Quaternion
	local magnitude = self:magnitudeSquared()

	if magnitude == 0 then
		magnitude = epsilon
	end
	
	return self:conjugate() / magnitude
end

function Quaternion.inverseMagnitude(self: Quaternion): number
	local magnitude = self:magnitude()
	
	if magnitude == 0 then
		magnitude = epsilon
	end
	
	return 1 / magnitude
end

function Quaternion.abs(self: Quaternion): Quaternion
	return if self.w < 0 then -self else self
end

function Quaternion.normalize(self: Quaternion): Quaternion
	return self * self:inverseMagnitude()
end

function Quaternion.dot(q0: Quaternion, q1: Quaternion): number
	return q0.x * q1.x + q0.y * q1.y + q0.z * q1.z + q0.w * q1.w
end

function Quaternion.multiplyByScalar(q0: Quaternion, val: number): Quaternion
	return Quaternion.new(
		q0.x * val, 
		q0.y * val,
		q0.z * val,
		q0.w * val
	)
end

function Quaternion.multiplyByQuaternion(q0: Quaternion, q1: Quaternion)
	return Quaternion.new(
		q0.w * q1.x + q0.x * q1.w + q0.y * q1.z - q0.z * q1.y,
		q0.w * q1.y - q0.x * q1.z + q0.y * q1.w + q0.z * q1.x,
		q0.w * q1.z + q0.x * q1.y - q0.y * q1.x + q0.z * q1.w,
		q0.w * q1.w - q0.x * q1.x - q0.y * q1.y - q0.z * q1.z
	)
end

function Quaternion.__mul(self: Quaternion, b: Quaternion | number): Quaternion
	return if type(b) == "number" then self:multiplyByScalar(b) else self:multiplyByQuaternion(b)
end

function Quaternion.divideByScalar(self: Quaternion, val: number): Quaternion
	local inverseVal = 1 / val
	return Quaternion.multiplyByScalar(self, inverseVal)
end

function Quaternion.__div(self: Quaternion, b: number): Quaternion
	return self:divideByScalar(b)
end

function Quaternion.__unm(self: Quaternion): Quaternion
	return Quaternion.new(
		-self.x,
		-self.y,
		-self.z,
		-self.w
	)
end

function Quaternion.__add(self: Quaternion, b: Quaternion): Quaternion
	return Quaternion.new(
		self.x + b.x,
		self.y + b.y,
		self.z + b.z,
		self.w + b.w
	)
end

function Quaternion.__sub(self: Quaternion, b: Quaternion): Quaternion
	return Quaternion.new(
		self.x - b.x,
		self.y - b.y,
		self.z - b.z,
		self.w - b.w
	)
end

function Quaternion.__pow(self: Quaternion, scaler: number): Quaternion
	if scaler == -1 then
		return self:inverse()
	end
	
	if scaler == 0 then
		return Quaternion.unitQuaternion()
	end
	
	if scaler == 1 then
		return self
	end
	
	return Quaternion.exp(self:log() * scaler)
end

function Quaternion.__tostring(self: Quaternion): string
	return `\{x: {self.x}, y: {self.y}, z: {self.z}, w: {self.w}}`
end

return Quaternion
