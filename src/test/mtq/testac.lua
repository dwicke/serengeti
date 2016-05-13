package.path = package.path..";../../?/init.lua"
package.path = package.path..";../../?.lua"

require 'torch'
require 'nn'
require 'rl'

local game = require 'mtq.MaxTwoQuadratic'
game.stochastic = false

function makeModel(learningRate, alr, vlr)

	
--	local modelMean1 = nn.Sequential():add(nn.Linear(1, 1))
--	local modelStdev1 = nn.Sequential():add(nn.Linear(1, 1)):add(nn.Exp())
--	local model1 = nn.ConcatTable()
--	model1:add(modelMean1)
--	model1:add(modelStdev1)
	
	local model1 = nn.Sequential():add(nn.Linear(1,1))
	local policy1 = rl.GaussianPolicy(1,6)
	local optimizer1 = rl.StochasticGradientDescent(model1:getParameters())
	local agent1 = rl.ActorCritic(model1, policy1, optimizer1, 1, 1)
	agent1:setLearningRate(learningRate)
	agent1:initiateParameters(0.5,1.0)
	agent1:setAdditionalLearningRate(alr, vlr)


--	local modelMean2 = nn.Sequential():add(nn.Linear(1, 1))
--	local modelStdev2 = nn.Sequential():add(nn.Linear(1, 1)):add(nn.Exp())
--	local model2 = nn.ConcatTable()
--	model2:add(modelMean2)
--	model2:add(modelStdev2)

	local model2 = nn.Sequential():add(nn.Linear(1,1))
	local policy2 = rl.GaussianPolicy(1,6)
	local optimizer2 = rl.StochasticGradientDescent(model2:getParameters())
	local agent2 = rl.ActorCritic(model2, policy2, optimizer2, 1, 1)
	agent2:setLearningRate(learningRate)
	agent2:initiateParameters(0.5,1.0)
	agent2:setAdditionalLearningRate(alr, vlr)

	
	return agent1, agent2
end


function main()
	local agent1, agent2 = makeModel(0.00003, 0.00005, 0.00005)
	local state = torch.Tensor({1})
	
	print("model1")
	local temp1 = agent1.model:forward(state)
	print(temp1[1])
	--print(temp1[2])
	print("model2")
	local temp2 = agent2.model:forward(state)
	print(temp2[1])
	--print(temp2[2])
	
	for i = 1,40000*50 do
		local action1 = agent1:getAction(state)[1]
		local action2 = agent2:getAction(state)[1]
--		print("action1 is")
--		print(action1)
--		print("action2 is")
--		print(action2)
		local r, _ = game:step(action1,action2)
		--local r, _ = game:step(action1,-10)
		
		local verbose = false
--		if i > 40000 then
--			verbose = true
--		end
		agent1:learn(state, r, nil)
		agent2:learn(state, r, nil)
		
		
		
		if i%(50*10)==0 then
			print("iteration "..i)
			print("model1")
			--print(agent1.optimizer.params)
			local temp1 = agent1.model:forward(state)
			print(temp1[1])
			--print(temp1[2])
			print("model2")
			--print(agent2.optimizer.params)
			local temp2 = agent2.model:forward(state)
			print(temp2[1])
			--print(temp2[2])
		end
		
	end
	
	print("model1")
	local temp1 = agent1.model:forward(state)
	print(temp1[1])
	--print(temp1[2])
	print("model2")
	local temp2 = agent2.model:forward(state)
	print(temp2[1])
	--print(temp2[2])

	


end


main()







