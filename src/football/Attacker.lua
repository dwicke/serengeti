require 'torch'


local Attacker = torch.class('Attacker')

-- Constructor
function Attacker:__init(maxFieldSize, field, xpos, ypos)


end

function Attacker:reset(xpos, ypos)


end

function Attacker:step(action, defender)
  dir = self:rotate(self.maxStep, 0, action[1])
  oldx = self.xpos
  oldy = self.ypos
  self.xpos = self.field:stx(self.xpos + dir[1])
  self.ypos = self.field:sty(self.ypos + dir[2])

  -- now check if I have passed through the defender, and which case I must not move
  if checkIntersect({oldx, oldy}, {self.xpos, self.ypos}, defender:getStart(), defender:getEnd()) == True then
    self.xpos = oldx
    self.ypos = oldy
  end

  -- and check to see if I have passed into the endzone and in which case return 1
  if self.ypos < endzone then
    return 1.0
  end

  return 0.0
end


function Lion:rotate(x, y, theta)
  sinTheta = math.sin(theta)
  cosTheta = math.cos(theta)
  xp = cosTheta * x + -sinTheta * y
  yp = sinTheta * x + cosTheta * y
  return {xp, yp}
end

-- Checks if two line segments intersect. Line segments are given in form of ({x,y},{x,y}, {x,y},{x,y}).
-- taken from https://love2d.org/wiki/General_math
function checkIntersect(l1p1, l1p2, l2p1, l2p2)
  local function checkDir(pt1, pt2, pt3) return math.sign(((pt2.x-pt1.x)*(pt3.y-pt1.y)) - ((pt3.x-pt1.x)*(pt2.y-pt1.y))) end
  return (checkDir(l1p1,l1p2,l2p1) ~= checkDir(l1p1,l1p2,l2p2)) and (checkDir(l2p1,l2p2,l1p1) ~= checkDir(l2p1,l2p2,l1p2))
end
