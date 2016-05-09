package.path = package.path..";../../?/init.lua"
package.path = package.path..";../../?.lua"

require 'torch'
require 'nn'
require 'rl'

local game = require 'mtq.MaxTwoQuadratic'

function makeModel(learningRate, alr, vlr)

	
	local model1 = nn.Sequential():add(nn.Linear(1,1))
	local optimizer1 = rl.StochasticGradientDescent(model1:getParameters())
	local agent1 = rl.LinearIncrementalDPG(model1, optimizer1, "Q", 1, 1, 1)
	agent1:setLearningRate(learningRate)
	agent1:setAdditionalLearningRate(alr, vlr)
	agent1:setActionStdev(10)

	
	
	
	local model2 = nn.Sequential():add(nn.Linear(1,1))
	local optimizer2 = rl.StochasticGradientDescent(model2:getParameters())
	local agent2 = rl.LinearIncrementalDPG(model2, optimizer2, "Q", 1, 1, 1)
	agent2:setLearningRate(learningRate)
	agent2:setAdditionalLearningRate(alr, vlr)
	agent2:setActionStdev(10)

	
	return agent1, agent2
end


function main()
	local agent1, agent2 = makeModel(0.0003, 0.0005, 0.0005)
	local state = torch.Tensor({1})
	
	print("model1")
	local temp1 = agent1.model:forward(state)
	print(temp1)
	print("model2")
	local temp2 = agent2.model:forward(state)
	print(temp2)
	
	for i = 1,40000*50 do
		local action1 = agent1:getAction(state)[1]
		local action2 = agent2:getAction(state)[1]
--		print("action1 is")
--		print(action1)
--		print("action2 is")
--		print(action2)
		local r, _ = game:step(action1,action2)
		--local r, _ = game:step(agent1:getAction(state)[1],-10)
		agent1:learn(state, r, nil)
		agent2:learn(state, r, nil)
		
		
		
		if i%(50*50)==0 then
			print("model1")
			--print(agent1.optimizer.params)
			local temp1 = agent1.model:forward(state)
			print(temp1)
			print("model2")
			--print(agent2.optimizer.params)
			local temp2 = agent2.model:forward(state)
			print(temp2)
		end
		
	end
	
	print("model1")
	local temp1 = agent1.model:forward(state)
	print(temp1)
	print("model2")
	local temp2 = agent2.model:forward(state)
	print(temp2)

	


end


main()







