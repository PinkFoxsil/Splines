local errorMsgs = {}

function errorMsgs.getTOutOfRangeErrorMsg(tValue: number): string
	return `The value t is outside of 0 and 1 range. t: {tValue}`
end

return errorMsgs
