local MaxTwoQuadratic = {}




-- action1 and action2 should be in the range of [0,4]
function MaxTwoQuadratic:step(action1, action2)
	--assert(-4<=action1 and action1<= 4,"action1 is not in the valid range")
	--assert(-4<=action2 and action2<= 4,"action2 is not in the valid range")

	local terminal = true
	local h1 = 100
	local h2 = 20
	local s1 = 4.0
	local s2 = 32.0
	local f1 = h1*(1 - ((action1/s1)*(action1/s1)) - ((action2/s1)*(action2/s1))) + 200
	local f2 = h2*(1 - ((action1/s2)*(action1/s2)) - ((action2/s2)*(action2/s2))) + 100

	return math.max(f1,f2,0), terminal
end


return MaxTwoQuadratic