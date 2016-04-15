require 'torch'
require 'utils.lua'


local Gazelle = torch.class('benchmark.Gazelle');

-- Constructor
function Gazelle:__init(xpos, ypos, theta, maxFieldLength, lions, field, stepSize)
  self.xpos = xpos
  self.ypos = ypos
  self.theta = theta
  self.maxFieldLength = maxFieldLength
  self.lions = lions
  self.field = field
  self.stepSize = stepSize
end


function Gazelle:step()
  xp = 0.0
  yp = 0.0
  for l in self.lions do
    vx, vy = self.field:tv(l:getX(), l:getY(), xpos, ypos)
    vLen = math.sqrt(vx*vx + vy*vy)
    scale = (self.maxFieldLength - vLen) / vLen
    xp = xp + vx * scale
    yp = yp + vy * scale
  end
  xp = -1*xp
  yp = -1*yp

  len = math.sqrt(xp*xp + yp*yp)
  if len > 0 then
    xp = xp * (self.stepSize / len)
    yp = yp * (self.stepSize / len)
  else
    print("Gazelle is not moving!")
  end
  self.xpos = self.field:stx(self.xpos + xp)
  self.ypos = self.field:sty(self.ypos + yp)
end

-- returns -1 if not dead
-- returns 1 if dead
function Gazelle:isDead()

  for l in self.lions do
    vx, vy = self.field:tv(l.getX(), l.getY(), self.xpos, self.ypos)
    if math.sqrt(vx*vx + vy*vy) <= 1.0 then
      return 1
    end
  end
  return -1
end


