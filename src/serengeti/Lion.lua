require 'torch'


local Lion = torch.class('Lion');

-- Constructor
function Lion:__init(xpos, ypos, theta, maxStep, field, learner)
  print ("created lion")
  self.xpos = xpos
  self.ypos = ypos
  self.theta = theta
  self.maxStep = maxStep
  self.field = field
  self.learner = learner or 1
end

function Lion:getX()
  return self.xpos
end
function Lion:getY()
  return self.ypos
end


function Lion:step()
  dir = self:rotate(self.maxStep, 0, math.random()*2*math.pi)
  self.xpos = self.field:stx(self.xpos + dir[1])
  self.ypos = self.field:sty(self.ypos + dir[2])
  --xpos = self.field:stx(self.xpos + dir[1])
  --ypos = self.field:sty(self.ypos + dir[2])
  --print("dist = " math.sqrt((xpos - self.xpos)*(xpos - self.xpos) + (ypos - self.ypos)*(ypos - self.ypos)))


end



function Lion:rotate(x, y, theta)
  sinTheta = math.sin(theta)
  cosTheta = math.cos(theta)
  xp = cosTheta * self.xpos + -sinTheta * self.ypos
  yp = sinTheta * self.xpos + cosTheta * self.ypos
  return {xp, yp}
end
