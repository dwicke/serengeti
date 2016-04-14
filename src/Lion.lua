require 'torch'
require 'utils.lua'


local Lion = torch.class('benchmark.Lion');

-- Constructor
function Lion:__init(xpos, ypos, theta, learner)
  self.xpos = xpos
  self.ypos = ypos
  self.theta = theta
  self.learner = learner
end


function Lion:step()

end
