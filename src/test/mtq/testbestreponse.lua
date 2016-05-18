package.path = package.path..";../../?/init.lua"
package.path = package.path..";../../?.lua"



require 'torch'
require 'nn'
require 'rl'

local game = require 'mtq.MaxTwoQuadratic'
local GradientDescentBestResponse = require 'alg.BestResponse'
local TransitionTable = require 'alg.TransitionTable'
local Search = require 'alg.LBFGSB'

local paramLowerBound = -0.05
local paramUpperBound = 0.05

local totalIteration = 15000

function makeCritic()
	return nn.Sequential():add(nn.Linear(3, 10)):add(nn.Tanh()):add(nn.Linear(10, 10)):add(nn.ReLU()):add(nn.Linear(10,1))
end

function makeModel(learningRate)
	local searchPoints = {{0,0},{-19,-19},{-13,-13},{-5,-5},{-5,6},{7,3},{-15,5},{5,-15},{-19,19},{19,-19}}

	local criticArgs = {lrStart = 0.000001, lrEnd = 0.0000001, lIteration = totalIteration}
	                             
	
	
--	local modelMean1 = nn.Sequential():add(nn.Linear(1, 1))
--	local modelStdev1 = nn.Sequential():add(nn.Linear(1, 1)):add(nn.Exp())
--	local model1 = nn.ConcatTable()
--	model1:add(modelMean1)
--	model1:add(modelStdev1)
	
	local model1 = nn.Sequential():add(nn.Linear(1,1))
	local critic1 = makeCritic()
	local search1 = LBFGSB.new(1, 2, {20, 20}, {-20,-20})
	local policy1 = rl.GaussianPolicy(1, 7)
	local buffer1 = TransitionTable.new({maxSize = 500,numActor = 2,actionDim = 1,stateDim = 1})
	local optimizer1 = rl.StochasticGradientDescent(model1:getParameters())
	local agent1 = GradientDescentBestResponse.new(model1, policy1, optimizer1, 1, critic1, criticArgs, searchPoints, search1, buffer1)
	agent1:setLearningRate(learningRate)
	agent1:setAdditionalLearningRate(criticArgs.lrStart)
	agent1:initiateParameters(paramLowerBound,paramUpperBound,paramLowerBound,paramUpperBound)
		
	local model2 = nn.Sequential():add(nn.Linear(1,1))
	local critic2 = makeCritic()
	local search2 = LBFGSB.new(1, 2, {20, 20}, {-20,-20})
	local policy2 = rl.GaussianPolicy(1, 7)
	local buffer2 = TransitionTable.new({maxSize = 500,numActor = 2,actionDim = 1,stateDim = 1})
	local optimizer2 = rl.StochasticGradientDescent(model2:getParameters())
	local agent2 = GradientDescentBestResponse.new(model2, policy2, optimizer2, 2, critic2, criticArgs, searchPoints, search2, buffer2)
	agent2:setLearningRate(learningRate)
	agent2:setAdditionalLearningRate(criticArgs.lrStart)
	agent2:initiateParameters(paramLowerBound,paramUpperBound,paramLowerBound,paramUpperBound)
	
	

	
	return agent1, agent2
end


function main()

	local startIteration = 1000
	local agent1, agent2 = makeModel(0.000000001)
	local state = torch.Tensor({1})
	
	print("model1")
	local temp1 = agent1.model:forward(state)
	print(temp1)
	print("model2")
	local temp2 = agent2.model:forward(state)
	print(temp2)
	
	for i = 1,totalIteration do
		local action1 = agent1:getAction(state)[1]
		local action2 = agent2:getAction(state)[1]

		local r, _ = game:step(action1,action2)


		agent1:learn(state, r, nil, {action1, action2}, i, startIteration)
		agent2:learn(state, r, nil, {action1, action2}, i, startIteration)
		
		
		if i%(50*10)==0 then
			print("iteration "..i)
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







