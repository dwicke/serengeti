require 'torch'


local Gazelle = torch.class('Gazelle');

-- Constructor
function Gazelle:__init(xpos, ypos, maxFieldLength, lions, field, stepSize)
  self.xpos = xpos
  self.ypos = ypos
  self.maxFieldLength = maxFieldLength
  self.lions = lions
  self.field = field
  self.stepSize = stepSize
  self.dead = -1
end


function Gazelle:step()
  if self.dead == 1 then
    return
  end
  xp = 0.0
  yp = 0.0
  for i, l in ipairs(self.lions) do
    vx, vy = self.field:tv(l:getX(), l:getY(), self.xpos, self.ypos)
    vLen = math.sqrt(vx*vx + vy*vy)
    scale = (self.maxFieldLength - vLen) / vLen
    xp = xp + vx * scale
    yp = yp + vy * scale
  end
  xp = -1*xp
  yp = -1*yp

  len = math.sqrt(xp*xp + yp*yp)
  if len > 0.01 then
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
  print("Checking if Gazelle is dead")
  for i, l in ipairs(self.lions) do
    vx, vy = self.field:tv(self.xpos, self.ypos, l:getX(), l:getY())
    print("distance is".. math.sqrt(vx*vx + vy*vy) .. " l(x,y) = ".. l:getX() .. ", " .. l:getY())
    if math.sqrt(vx*vx + vy*vy) <= 50.0 then
      self.dead = 1
      return 1
    end
  end
  self.dead = -1
  return -1
end


function Gazelle:getX()
  return self.xpos
end

function Gazelle:getY()
  return self.ypos
end


