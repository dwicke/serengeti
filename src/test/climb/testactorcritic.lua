package.path = package.path..";../../?/init.lua"
package.path = package.path..";../../?.lua"

require 'torch'
require 'nn'
require 'rl'

local game = require 'climb.Climb'
local DiscreteBestResponse = require 'alg.DiscreteQActorCritic'

local counter = {["11"]= 0,["12"]=0,["13"]=0,["21"]=0,["22"]=0,["23"]=0,["31"]=0,["32"]=0,["33"]=0}

function maxIndex(tensor)
	local max, index = -1,-1
	for i = 1, tensor:nElement() do
		if tensor[i] > max then
			index = i
			max = tensor[i]
		end
	end
	
	return ""..index
end


function main()
	
	local model1 = nn.Sequential():add(nn.Linear(1, 3)):add(nn.SoftMax())
	local policy1 = rl.SoftmaxPolicy(3)
	local model2 = nn.Sequential():add(nn.Linear(1, 3)):add(nn.SoftMax())
	local policy2 = rl.SoftmaxPolicy(3)
	local optimizer1 = rl.StochasticGradientDescent(model1:getParameters())
	local optimizer2 = rl.StochasticGradientDescent(model2:getParameters())

	local agent1 = DiscreteQActorCritic.new(model1, policy1, optimizer1) -- this is agent 1
	local agent2 = DiscreteQActorCritic.new(model2, policy2, optimizer2) -- this is agent 2
	
	agent1:setLearningRate(0.00000001)
	agent1:setAdditionalLearningRate(0.1)
	agent1:initiateParameters(-0.5,0.5)
	agent2:setLearningRate(0.00000001)
	agent2:setAdditionalLearningRate(0.1)
	agent2:initiateParameters(-0.5,0.5)
	
	local state = torch.Tensor({1})
	
	
--	print("model1")
--	local temp1 = agent1.model:forward(state)
--	print(temp1)
--	print("model2")
--	local temp2 = agent2.model:forward(state)
--	print(temp2)
	
	for i = 1,3000 do
		local action1 = agent1:getAction(state)
		local action2 = agent2:getAction(state)
		local r, _ = game:step(action1,action2)
		--local r, _ = game:step(action1,-10)
		
		local verbose = false

		agent1:learn(state, r, nil, action1, i)
		agent2:learn(state, r, nil, action2, i)
		
		
		
--		if i%(50*10)==0 then
--			print("iteration "..i)
--			print("model1")
--			local temp1 = agent1.model:forward(state)
--			print(temp1)
--			print("model2")
--			local temp2 = agent2.model:forward(state)
--			print(temp2)
--		end
			
	end
	
--	print("model1")
--	local temp1 = agent1.model:forward(state)
--	print(temp1)
--	print("model2")
--	local temp2 = agent2.model:forward(state)
--	print(temp2)
	
	local temp1 = agent1.model:forward(state)
	local temp2 = agent2.model:forward(state)
	local max1 = maxIndex(temp1)
	local max2 = maxIndex(temp2)
	
	counter[max1..max2] = counter[max1..max2] + 1
	
	
	
--	for i = 1, 3 do
--		print(agent1.Q[i][1].." "..agent1.Q[i][2].." "..agent1.Q[i][3])
--	end
--	
--	for i = 1, 3 do
--		print(agent2.Q[i][1].." "..agent2.Q[i][2].." "..agent2.Q[i][3])
--	end
end

--main()

for i = 1,500 do
	main()
end

print(counter["11"])
print(counter["12"])
print(counter["13"])
print(counter["21"])
print(counter["22"])
print(counter["23"])
print(counter["31"])
print(counter["32"])
print(counter["33"])





