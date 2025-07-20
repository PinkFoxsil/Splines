--!strict

local binomialTable = {}

function binomialTable.insert(n: number, k: number, value: number)
	if not binomialTable[n] then
		binomialTable[n] = {}
	end

	binomialTable[n][k] = value
end

function binomialTable.find(n: number, k: number): number?
	if not binomialTable[n] then
		return nil
	end

	return binomialTable[n][k]
end

local bernsteinPolynomialUtil = {}

function bernsteinPolynomialUtil.getBinomialCoefficent(n: number, k: number): number
	local prexistingRes = binomialTable.find(n, k)
	if prexistingRes then
		return prexistingRes
	end

	if n < k then
		binomialTable.insert(n, k, 0)
		return 0
	end

	if k == 0 or n == k then
		binomialTable.insert(n, k, 1)
		return 1
	end

	if n - 1 == k then
		binomialTable.insert(n, k, n)
		return n
	end

	local res = 1

	for i = 1, k do
		res *= (n + 1 - i) / i
	end

	binomialTable.insert(n, k, res)
	return res
end

function bernsteinPolynomialUtil.getBasisPolynomial(n: number, v: number, val: number): number
	return bernsteinPolynomialUtil.getBinomialCoefficent(n, v) * val ^ v * (1 - val) ^ (n - v)
end

function bernsteinPolynomialUtil.getBasisPolynomials(n: number, val: number): {}
	local res = {}

	for i = 0, n do
		table.insert(res, bernsteinPolynomialUtil.getBasisPolynomial(n, i, val))
	end

	return res
end

function bernsteinPolynomialUtil.getCumulativeBasisPolynomials(n: number, val: number): { number }
	local res = {}

	for i = 0, n do
		local sum = 0

		for j = i, n do
			sum += bernsteinPolynomialUtil.getBasisPolynomial(n, j, val)
		end

		table.insert(res, sum)
	end

	return res
end

return bernsteinPolynomialUtil
