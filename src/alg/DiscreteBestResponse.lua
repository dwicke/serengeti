require 'torch'

local DiscreteBestResponse, parent = torch.class('DiscreteBestResponse','rl.Incremental')



function DiscreteBestResponse:__init(model, actor, optimizer, agentNum)
	parent.__init(self, model, actor.actNum)
	self.actor = actor
	self.optimizer = optimizer
	self.gamma = gamma or 1
	self.agentNum = agentNum
	self.Q = {}
	
	for i = 1,actor.actNum do
		local actionValue = {}
		for j = 1, actor.actNum do
			table.insert(actionValue, 0)
		end
		table.insert(self.Q, actionValue)
	end
	
end

--add another learning rate for  Q-learning
function DiscreteBestResponse:setAdditionalLearningRate(qlr)
	self.qlr = qlr
end

function DiscreteBestResponse:initiateParameters(lower, upper)
	self.optimizer.params:uniform(lower, upper)
end

function DiscreteBestResponse:getAction(s)
	-- get the parameters for the distribution of the stochastic policy
	local parameters = self.model:forward(s)
	
	-- sample from the distribution 
	local action = self.actor:getAction(parameters)
	
	return action
end


function DiscreteBestResponse:learn(s, r, sprime, actions, i)
	-- since our gradient of the policy may get changed due to the computation of compatible feature,
	-- we have to save that first
	-- first clear out the accumulated gradients	
	self.optimizer.grads:zero()
	local dLogPolicyDOutput = self.actor:backward()
	self.model:backward(s, dLogPolicyDOutput)

	local policyGradient = self.optimizer.grads:clone()

	-- we first learn the q value
	-- very simple, no next state
	self.Q[actions[1]][actions[2]] = (1 - self.qlr) * self.Q[actions[1]][actions[2]] + self.qlr * r
	
	-- then we search the optimal point, optimization here
	local index1, index2 = -1, -1
	local max = -10000 -- suppose this is the smallest
	for i = 1, self.actNum do
		for j = 1, self.actNum do
			if self.Q[i][j] > max then
				index1 = i
				index2 = j
				max = self.Q[i][j]
			end
		end
	end
	
	-- get the best response q value
	local qa = nil
	if self.agentNum == 1 then
		qa = self.Q[actions[1]][index2]
	else
		qa = self.Q[index1][actions[2]]
	end
	
	if i > 0 then
		policyGradient:mul(qa)
		self.optimizer:gradientAscent(policyGradient)
	end	
end





return DiscreteBestResponse