require 'torch'

local GradientDescentSearch = torch.class('GradientDescentSearch')



function GradientDescentSearch:__init(critic)
	self.params, self.grads = critic
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


function BestResponse:learn(s, r, sprime, actions, i)
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
	end
	
	self.replay:add(s, torch.Tensor(actions), r, sprime, t)

	-- have computation here, since we are doing a lot of optimization
	self:updateQValue(batch, self.searchPoint)
	
	-- do one more search to find out 
	local optimalActions = self.searchMethod:search(self.critic, self.searchPoint) 
	
	-- then we replace the action with our action, to determine the on-our-policy Q value
	optimalActions[i] = actions[i]
	
	-- construct the sample 
	local jointAction = torch.Tensor(optimalActions)
	local featureSize = s:nElement()
	local jointActionSize = jointAction:nElement()
	local input = torch.Tensor(featureSize + jointActionSize)
	
	input:narrow(1, 1, featureSize):copy(s)
	input:narrow(1, 1 + featureSize, jointActionSize):copy(jointAction)
	
	local qa = self.critic:forward(torch.Tensor(input))
	
	
	policyGradient:mul(qa)
	self.optimizer:gradientAscent(policyGradient)
	
end

function BestResponse:updateQValue(sampleBatch, searchPoint)

end



return BestResponse