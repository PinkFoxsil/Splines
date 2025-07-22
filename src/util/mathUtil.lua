local mathUtil = {}

function mathUtil.quadraticEquation(a: number, b: number, c: number): { min: number, max: number }
	assert(a ~= 0, "Value 'a' cannot be equal to 0")

	local sqrt = math.sqrt(b * b - 4 * a * c)
	local inverseA2 = 1 / (a * 2)

	return {
		min = (-b - sqrt) * inverseA2,
		max = (-b + sqrt) * inverseA2,
	}
end

function mathUtil.isInRange(val: number, min: number, max: number): boolean
	assert(min <= max, `The min: {min}, is greater than max: {max}`)

	if val < min then
		return false
	end

	if val > max then
		return false
	end

	return true
end

return mathUtil
