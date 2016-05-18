require 'torch'
require 'alg.BestResponse'

local GradientDescentBestResponse, parent = torch.class('GradientDescentBestResponse','BestResponse')



function GradientDescentBestResponse:__init(model, actor, optimizer, agentNum, critic, searchPoints, searchMethod)
	parent.__init(self, model, actor, optimizer, agentNum, critic, searchPoints, searchMethod)
end





function GradientDescentBestResponse:updateQValue(sampleBatch, searchPoint)
	
end



return GradientDescentBestResponse