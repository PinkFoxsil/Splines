local Matrix = {}
Matrix.__index = Matrix

export type Matrix<T> = typeof(setmetatable({} :: { { T } }, Matrix))

function Matrix.new<T>(value: { { T } }): Matrix<T>
	return setmetatable(value, Matrix)
end

function Matrix.row<T>(value: { T }): Matrix<T>
	return Matrix.new({ value })
end

function Matrix.rowReverse<T>(value: { T }): Matrix<T>
	local newMatrix = Matrix.new({ {} })

	for i = #value, 1, -1 do
		local newIndex = #newMatrix[1] + 1
		newMatrix[1][newIndex] = value[i]
	end

	return newMatrix
end

function Matrix.collum<T>(value: { T }): Matrix<T>
	local newMatrix = Matrix.new({ {} })

	for i = 1, #value do
		newMatrix[i] = { value[i] }
	end

	return newMatrix
end

function Matrix.scale<T>(self: Matrix<T>, value: number): Matrix<T>
	local result = Matrix.new({ {} })

	for rowIndex = 1, #self do
		result[rowIndex] = {}
		for collumIndex = 1, #self[rowIndex] do
			result[rowIndex][collumIndex] = self[rowIndex][collumIndex] :: any * value
		end
	end

	return result
end

function Matrix.dot<T, K>(self: Matrix<T>, matrix: Matrix<K>): Matrix<T | K>
	assert(
		#self[1] == #matrix,
		`The number of columns in the first matrix should match the number of rows in the secound. Matrix_1 size: [column: {#self[1]}, row: {#self}], Matrix_2 size: [column: {#matrix[1]}, row: {#matrix}`
	)

	local result = Matrix.new({ {} })

	for rowAIndex = 1, #self do
		result[rowAIndex] = {}
		for collumBIndex = 1, #matrix[1] do
			result[rowAIndex][collumBIndex] = self[rowAIndex][1] * matrix[1][collumBIndex] :: any
			for rowBIndex = 2, #matrix do
				result[rowAIndex][collumBIndex] += self[rowAIndex][rowBIndex] * matrix[rowBIndex][collumBIndex] :: any
			end
		end
	end

	return result
end

function Matrix.__mul<T, K>(self: Matrix<T>, value: Matrix<K> | number): Matrix<T | K>
	return if type(value) == "number" then Matrix.scale(self, value) else Matrix.dot(self, value)
end

function Matrix.__div<T, K>(self: Matrix<T>, value: number): Matrix<T>
	local result = Matrix.new({ {} })

	for rowIndex = 1, #self do
		result[rowIndex] = {}
		for collumIndex = 1, #self[rowIndex] do
			result[rowIndex][collumIndex] = self[rowIndex][collumIndex] :: any / value
		end
	end

	return result
end

return Matrix
