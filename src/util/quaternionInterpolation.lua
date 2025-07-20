--|| Modules ||--
local Quaternion = require("../mathLib/Quaternion")

--|| Main ||--
local quaternionInterpolation = {}

function quaternionInterpolation.deCasteljau(quaternions: { Quaternion.Quaternion }, t): Quaternion.Quaternion
	for i = #quaternions, 1, -1 do
		for j = 1, i - 1 do
			local q0 = quaternions[j]
			local q1 = quaternions[j + 1]

			quaternions[j] = q0:slerp(q1, t)
		end
	end

	return quaternions[1]
end

function quaternionInterpolation.fastDeCasteljau(quaternions: { Quaternion.Quaternion }, t): Quaternion.Quaternion
	for i = #quaternions, 1, -1 do
		for j = 1, i - 1 do
			local q0 = quaternions[j]
			local q1 = quaternions[j + 1]

			quaternions[j] = q0:fastSlerp(q1, t)
		end
	end

	return quaternions[1]
end

function quaternionInterpolation.barryGoldman(
	q0: Quaternion.Quaternion,
	q1: Quaternion.Quaternion,
	q2: Quaternion.Quaternion,
	q3: Quaternion.Quaternion,
	t: number
): Quaternion.Quaternion
	local t0 = t + 1

	local a = q0:slerp(q1, t0)
	local b = q1:slerp(q2, t)
	local c = q2:slerp(q3, t - 1)

	local d = a:slerp(b, t0 / 2)
	local e = b:slerp(c, t / 2)

	return d:slerp(e, t)
end

function quaternionInterpolation.fastBarryGoldman(
	q0: Quaternion.Quaternion,
	q1: Quaternion.Quaternion,
	q2: Quaternion.Quaternion,
	q3: Quaternion.Quaternion,
	t: number
): Quaternion.Quaternion
	local t0 = t + 1

	local a = q0:fastSlerp(q1, t0)
	local b = q1:fastSlerp(q2, t)
	local c = q2:fastSlerp(q3, t - 1)

	local d = a:fastSlerp(b, t0 / 2)
	local e = b:fastSlerp(c, t / 2)

	return d:fastSlerp(e, t)
end

function quaternionInterpolation.cumulative(
	quaternions: { Quaternion.Quaternion },
	weights: { number }
): Quaternion.Quaternion
	local res = quaternions[1]

	for i = 2, #quaternions do
		local q0 = quaternions[i - 1]
		local q1 = quaternions[i]

		res *= (q0 ^ -1 * q1):normalize() ^ weights[i]
	end

	return res
end

function quaternionInterpolation.getControlQuaternions(
	quaternions: { Quaternion.Quaternion },
	tension: number,
	continuity: number,
	bias: number
): { Quaternion.Quaternion }
	local minT = (1 - tension)
	local minC = (1 - continuity)
	local plusC = (1 + continuity)
	local minB = (1 - bias)
	local plusB = (1 + bias)

	local minTmulPlusC = minT * plusC
	local minTmulMinC = minT * minC

	local a = minTmulPlusC * plusB
	local b = minTmulMinC * minB
	local c = minTmulMinC * plusB
	local d = minTmulPlusC * minB

	local qIn = quaternions[2]:rotationTo(quaternions[1])
	local qOut = quaternions[3]:rotationTo(quaternions[2])
	local rhoIn = qIn:map()
	local rhoOut = qOut:map()

	local function omega(weightIn, weightOut)
		return (weightIn * rhoIn + weightOut * rhoOut) / 2
	end

	return {
		Quaternion.exp(-omega(c, d) / 3) * quaternions[2],
		Quaternion.exp(omega(a, b) / 3) * quaternions[2],
	}
end

function quaternionInterpolation.double(q0: Quaternion.Quaternion, q1: Quaternion.Quaternion): Quaternion.Quaternion
	return 2 * q0:dot(q1) * q1 - q0
end

function quaternionInterpolation.bisect(q0: Quaternion.Quaternion, q1: Quaternion.Quaternion): Quaternion.Quaternion
	return (q0 + q1):normalize()
end

function quaternionInterpolation.getShoemakeControlQuaternions(
	quaternions: { Quaternion.Quaternion }
): { Quaternion.Quaternion }
	local a =
		quaternionInterpolation.bisect(quaternionInterpolation.double(quaternions[1], quaternions[2]), quaternions[3])

	return {
		a,
		quaternionInterpolation.double(a, quaternions[2]):normalize(),
	}
end

return quaternionInterpolation
