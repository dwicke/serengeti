require 'torch'


local Lion = torch.class('Lion');

-- Constructor
function Lion:__init(xpos, ypos, theta, learner)
  print ("created lion")
  self.xpos = xpos
  self.ypos = ypos
  self.theta = theta
  self.learner = learner or 1
end

function Lion:getX()
  print("theta = " .. self.xpos)
  return self.xpos
end
function Lion:getY()
  return self.ypos
end


function Lion:step()

end
