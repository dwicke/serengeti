require 'torch'
require 'nn'
require 'rl'

local hat = require 'mexican.hat'




function main()
	-- the model, input is just a single number as the state number
	-- than we do a linearly transformation and then output three values and squash them into a distribution
	local modelMean1 = nn.Sequential():add(nn.Linear(1, 1))
	local modelStdev1 = nn.Sequential():add(nn.Linear(1, 1)):add(nn.Exp())
	local model1 = nn.ConcatTable()
	model1:add(modelMean1)
	model1:add(modelStdev1)
	
	local policy1 = rl.GaussianPolicy(1)
	local optimizer1 = rl.StochasticGradientDescent(model1:getParameters())
	local agent1 = rl.Reinforce(model1, policy1, optimizer1)
	agent1:setLearningRate(0.001)
	
	
	local modelMean2 = nn.Sequential():add(nn.Linear(1, 1))
	local modelStdev2 = nn.Sequential():add(nn.Linear(1, 1)):add(nn.Exp())
	local model2 = nn.ConcatTable()
	model2:add(modelMean2)
	model2:add(modelStdev2)
	
	local policy2 = rl.GaussianPolicy(1)
	local optimizer2 = rl.StochasticGradientDescent(model2:getParameters())
	local agent2 = rl.Reinforce(model2, policy2, optimizer2)
	agent2:setLearningRate(0.001)
	
	local state = torch.Tensor({1})
	
	print("model1")
	local temp1 = model1:forward(state)
	print(temp1[1])
	print(temp1[2])
	print("model2")
	local temp2 = model2:forward(state)
	print(temp2[1])
	print(temp2[2])
	
	for i = 1,2000 do
		local average1, average2 = 0,0
		-- repeat 100 trials
		for j = 1,100 do
			agent1:startTrial()
			agent2:startTrial()
			local action1 = agent1:getAction(state)[1]
			local action2 = agent2:getAction(state)[1]
--			print("action1 is")
--			print(action1)
--			print("action2 is")
--			print(action2)
			local r, _ = hat:step(agent1:getAction(state)[1],agent2:getAction(state)[1])
			--local r, _ = hat:step(agent1:getAction(state)[1],0)
			--print(r)
			agent1:step(state, r)
			agent2:step(state, r)
			agent1:endTrial()
			agent2:endTrial()
			average1 = average1 + r
			average2 = average2 + r
		end
		agent1:learn(nil, nil)
		agent2:learn(nil, nil)
		average1 = average1/100
		average2 = average2/100
		if i%50==0 then
			--print("the norm of gradient is "..optimizer1.grads:norm().." and "..optimizer2.grads:norm())
			print("average is")
			print(average1)
			print("model1")
			local temp1 = model1:forward(state)
			print(temp1[1])
			print(temp1[2])
			print("model2")
			local temp2 = model2:forward(state)
			print(temp2[1])
			print(temp2[2])
		end
	end
	
	print("model1")
	local temp1 = model1:forward(state)
	print(temp1[1])
	print(temp1[2])
	print("model2")
	local temp2 = model2:forward(state)
	print(temp2[1])
	print(temp2[2])
	


end


main()







