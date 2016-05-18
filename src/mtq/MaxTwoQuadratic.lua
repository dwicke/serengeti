local MaxTwoQuadratic = {}


MaxTwoQuadratic.stochastic = false

-- action1 and action2 should be in the range of [0,4]
function MaxTwoQuadratic:step(action1, action2)
	--assert(-4<=action1 and action1<= 4,"action1 is not in the valid range")
	--assert(-4<=action2 and action2<= 4,"action2 is not in the valid range")

	local terminal = true
	local x1,y1,x2,y2 = -15,-15,15,15
	local h1,h2 = 100,20
	local s1,s2 = 3,32.0
	local f1 = h1*(1 - (((action1-x1)/s1)*((action1-x1)/s1)) - (((action2-y1)/s1)*((action2-y1)/s1))) + 50
	local f2 = h2*(1 - (((action1-x2)/s2)*((action1-x2)/s2)) - (((action2-y2)/s2)*((action2-y2)/s2))) - 50

	local ret = math.max(f1, f2, -150)
	if self.stochastic then
		ret = ret + torch.normal(0, 10)
	end
	
	return math.max(f1,f2,-150), terminal
end


return MaxTwoQuadratic