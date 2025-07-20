local arrayUtil = {}

function arrayUtil.map<T, K>(t: {T}, callBack: (T) -> (K)): {K}
	local newT = {}
	
	for _, element in t do
		table.insert(newT, callBack(element))
	end
	
	return newT
end

return arrayUtil
