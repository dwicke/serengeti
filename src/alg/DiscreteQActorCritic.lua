require 'torch'

local DiscreteQActorCritic, parent = torch.class('DiscreteQActorCritic','rl.Incremental')



function DiscreteQActorCritic:__init(model, actor, optimizer)
	parent.__init(self, model, actor.actNum)
	self.actor = actor
	self.optimizer = optimizer
	self.gamma = gamma or 1
	self.Q = {}
	
	
	-- since we ignoring the other, we just need q table, not joint-q table
	for i = 1,actor.actNum do
		table.insert(self.Q, 0)
	end
	
end

--add another learning rate for  Q-learning
function DiscreteQActorCritic:setAdditionalLearningRate(qlr)
	self.qlr = qlr
end

function DiscreteQActorCritic:initiateParameters(lower, upper)
	self.optimizer.params:uniform(lower, upper)
end

function DiscreteQActorCritic:getAction(s)
	-- get the parameters for the distribution of the stochastic policy
	local parameters = self.model:forward(s)
	
	-- sample from the distribution 
	local action = self.actor:getAction(parameters)
	
	return action
end


function DiscreteQActorCritic:learn(s, r, sprime, a, i)
	-- since our gradient of the policy may get changed due to the computation of compatible feature,
	-- we have to save that first
	-- first clear out the accumulated gradients	
	self.optimizer.grads:zero()
	local dLogPolicyDOutput = self.actor:backward()
	self.model:backward(s, dLogPolicyDOutput)

	local policyGradient = self.optimizer.grads:clone()

	-- we first learn the q value
	-- very simple, no next state
	self.Q[a] = (1 - self.qlr) * self.Q[a] + self.qlr * r
	
	local qa = self.Q[a]
	if i > 0 then
		policyGradient:mul(qa)
		self.optimizer:gradientAscent(policyGradient)
	end	
end





return DiscreteQActorCritic