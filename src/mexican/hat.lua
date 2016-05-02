local hat = {}




-- action1 and action2 should be in the range of [0,4]
function hat:step(action1, action2)
	--assert(-4<=action1 and action1<= 4,"action1 is not in the valid range")
	--assert(-4<=action2 and action2<= 4,"action2 is not in the valid range")

	local terminal = true

	local sigma = 1
	local denominator = math.pi*math.pow(sigma,4)
	
	local offset = 0.0
	local sumSquare = (action1-offset)*(action1-offset) + (action2-offset)*(action2-offset)
	local sumFourth = math.pow(action1-offset,4) + math.pow(action2-offset,4)
	local firstTerm = (1-(sumFourth/(2*sigma*sigma)))
	local secondTerm = math.exp(-(sumSquare/(2*sigma*sigma)))
	local numerator = firstTerm * secondTerm


	return numerator*50/denominator-10, terminal
end


return hat