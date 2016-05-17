require 'torch'

local BestResponse, parent = torch.class('BestResponse','rl.Incremental')



function BestResponse:__init(model, actor, optimizer, agentNum, critic, searchPoints, searchMethod, replay)
	parent.__init(self, model, actor.actNum)
	self.actor = actor
	self.optimizer = optimizer
	self.gamma = gamma or 1
	self.agentNum = agentNum
	self.critic = critic
	self.criticParams, self.criticGrads = self.critic:getParameters()
	self.searchPoints = searchPoints
	self.searchMethod = searchMethod
	self.replay = replay 
	self.qlr = nil
end

--add another learning rate for  Q-learning
function BestResponse:setAdditionalLearningRate(qlr)
	self.qlr = qlr
end

function BestResponse:initiateParameters(lower, upper)
	self.optimizer.params:uniform(lower, upper)
end

function BestResponse:getAction(s)
	-- get the parameters for the distribution of the stochastic policy
	local parameters = self.model:forward(s)
	
	-- sample from the distribution 
	local action = self.actor:getAction(parameters)
	
	return action
end


function BestResponse:learn(s, r, sprime, actions, iteration)
	-- since our gradient of the policy may get changed due to the computation of compatible feature,
	-- we have to save that first
	-- first clear out the accumulated gradients	
	self.optimizer.grads:zero()
	local dLogPolicyDOutput = self.actor:backward()
	self.model:backward(s, dLogPolicyDOutput)

	local policyGradient = self.optimizer.grads:clone()
	
	local t = (sprime==nil)
	
	local actionTable, k = nil,1
	if type(actions[1]) == 'table' then
		for i = 1, #actions do
			for j = 1,#actions[i] do
				actionTable[k] = actions[i][j]
				k = k+1
			end
		end
	else
		actionTable = actions -- actions is already a table of elements
	end
	
	local featureSize = s:nElement()
	local jointActionSize = #actionTable
	self.replay:add(s, torch.Tensor(actions), r, sprime, t)
	local batchSize = 100
	local batch = self.replay:sample(batchSize)
	-- have computation here, since we are doing a lot of optimization
	self:updateQValue(batch, self.searchPoint, featureSize, jointActionSize)
	
	-- do one more search to find out the optimal action
	local _, optimalActions = self.searchMethod:search(self.critic, s, self.searchPoints, self.criticGrads, iteration) 
	
	if iteration%500 == 0 then
		print(_)
		for j = 1,#optimalActions do
			print("action "..j.." is ")
			print(optimalActions[j])
		end
	end
	
	-- then we replace the action with our action, to determine the on-our-policy Q value
	optimalActions[self.agentNum] = actions[self.agentNum]
	
	-- construct the sample 
	local jointAction = torch.Tensor(optimalActions)
	featureSize = s:nElement()
	jointActionSize = jointAction:nElement()
	local input = torch.Tensor(featureSize + jointActionSize)
	
	
	input:narrow(1, 1, featureSize):copy(s)
	input:narrow(1, 1 + featureSize, jointActionSize):copy(jointAction)
	
	local qa = self.critic:forward(input)

	
--	policyGradient:mul(qa[1]) -- qa is tensor, we convert it to number
--	self.optimizer:gradientAscent(policyGradient)
	
end

function BestResponse:updateQValue(sampleBatch, searchPoint, featureSize, jointActionSize)

	-- first compute the target value for each transition tuple
	-- this should be the most computation costly function in the algorithm
	local yVector = torch.Tensor(#sampleBatch,1):fill(0)
	local xMatrix = torch.Tensor(#sampleBatch, featureSize + jointActionSize)
	
--	for i = 1, #sampleBatch do
--		print("input is")
--		print(sampleBatch[i][1])
--		print("r is ")
--		print(sampleBatch[i][2])
--	end
	print("sampleBatch num is "..#sampleBatch)
	
	for i = 1, #sampleBatch do
		xMatrix[i]:copy(sampleBatch[i][1]) -- prepare the x
	end
	
	-- compute the q value 
	local qsa = self.critic:forward(xMatrix)
	
	-- prepare the target
	for i = 1, #sampleBatch do
		-- first get the sprime for optimization
		local y = 0
		local r = sampleBatch[i][2]
		local terminal = sampleBatch[i][4]

		
		if terminal then
			yVector[i] = r - qsa[i][1]
		else
			-- search the maxq value in state sprime
			local maxQ, _ = self.searchMethod:search(self.critic, sampleBatch[i][3], self.searchPoint, self.criticGrads) 
			y = r + self.gamma * maxQ - qsa[i] -- target, which is also the dLoss/dOutput 
			yVector[i] = y  -- prepare the y
		end
		
	end
	
	self.critic:forward(xMatrix)
	
	self.criticGrads:zero()
	
	self.critic:backward(xMatrix, yVector)
	
	self.criticParams:add(self.qlr, self.criticGrads)
end



return BestResponse