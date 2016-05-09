require 'torch'


local Attacker = torch.class('Attacker')

-- Constructor
function Attacker:__init(maxFieldSize, field, xpos, ypos)


end

function Attacker:reset(xpos, ypos)


end

function Attacker:step(action)
  dir = self:rotate(self.maxStep, 0, action[1])
  oldx = self.xpos
  oldy = self.ypos
  self.xpos = self.field:stx(self.xpos + dir[1])
  self.ypos = self.field:sty(self.ypos + dir[2])
end


function Lion:rotate(x, y, theta)
  sinTheta = math.sin(theta)
  cosTheta = math.cos(theta)
  xp = cosTheta * x + -sinTheta * y
  yp = sinTheta * x + cosTheta * y
  return {xp, yp}
end
