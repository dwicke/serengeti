require 'torch'

math.sign = math.sign or function(x) return x<0 and -1 or x>0 and 1 or 0 end
local Attacker = torch.class('Attacker')

-- Constructor
function Attacker:__init(maxFieldSize, field, xpos, ypos)

  self.xpos = xpos
  self.ypos = ypos
  self.field = field
  self.maxFieldSize = maxFieldSize
  self.maxStep = 1
  self.endzone = 0
end

function Attacker:reset(xpos, ypos)
  self.xpos = xpos
  self.ypos = ypos
end

function Attacker:step(action, defender)
  dir = self:rotate(self.maxStep, 0, action[1])
  oldx = self.xpos
  oldy = self.ypos
  self.xpos = self.field:stx(self.xpos + dir[1])
  self.ypos = self.field:sty(self.ypos + dir[2])


  defenderLoc = defender:getDefenderPoints()


  -- if my new x position is greater than the max step size (due to wrapping) then
  if math.abs(oldx - self.xpos) > self.maxFieldSize then
    -- create the point at which it wraps around

    if oldx < self.xpos then
      -- I have wrapped on the low end to the high end
      -- so then we have x = 0 be the second point
      -- subtract since y decreases going up...
      midpointLow = {0, oldy - math.abs(oldx - self.xpos)*math.tan(action[1])}
      midpointHigh = {self.maxFieldSize, oldy - math.abs(oldx - self.xpos)*math.tan(action[1])}
    else
      -- I have wrapped from the high end to the low end
      midpointLow = {self.maxFieldSize, oldy - math.abs(oldx - self.xpos)*math.tan(action[1])}
      midpointHigh = {0, oldy - math.abs(oldx - self.xpos)*math.tan(action[1])}
    end


    if #defenderLoc == 2 then
      intersects = self:checkIntersect({oldx, oldy}, midpointLow, defenderLoc[1], defenderLoc[2]) or self:checkIntersect(midpointHigh, {self.xpos, self.ypos}, defenderLoc[1], defenderLoc[2])
    else -- it crosses
      intersects = self:checkIntersect({oldx, oldy}, midpointLow, defenderLoc[1], defenderLoc[2]) or self:checkIntersect(midpointHigh, {self.xpos, self.ypos}, defenderLoc[1], defenderLoc[2]) or self:checkIntersect({oldx, oldy}, midpointLow, defenderLoc[3], defenderLoc[4]) or self:checkIntersect(midpointHigh, {self.xpos, self.ypos}, defenderLoc[3], defenderLoc[4])
    end

  else -- does not wrap around
    intersects = self:checkIntersect({oldx, oldy}, {self.xpos, self.ypos}, defenderLoc[1], defenderLoc[2])

    if #defenderLoc > 2 then
      intersects = intersects or self:checkIntersect({oldx, oldy}, {self.xpos, self.ypos}, defenderLoc[3], defenderLoc[4])
    end
  end


  -- now check if I have passed through the defender, and which case I must not move
  if intersects == True then
    self.xpos = oldx
    self.ypos = oldy
    return -30, False -- blocked
  end

  -- and check to see if I have passed into the endzone and in which case return 1
  if self.ypos < self.endzone then
    return 10.0, True -- reached endzone
  end

  return -1.0, False -- unblocked
end


function Attacker:rotate(x, y, theta)
  sinTheta = math.sin(theta)
  cosTheta = math.cos(theta)
  xp = cosTheta * x + -sinTheta * y
  yp = sinTheta * x + cosTheta * y
  return {xp, yp}
end

-- Checks if two line segments intersect. Line segments are given in form of ({x,y},{x,y}, {x,y},{x,y}).
-- taken from https://love2d.org/wiki/General_math
function Attacker:checkIntersect(l1p1, l1p2, l2p1, l2p2)
  local function checkDir(pt1, pt2, pt3) return math.sign(((pt2[1]-pt1[1])*(pt3[2]-pt1[2])) - ((pt3[1]-pt1[1])*(pt2[2]-pt1[2]))) end
  return (checkDir(l1p1,l1p2,l2p1) ~= checkDir(l1p1,l1p2,l2p2)) and (checkDir(l2p1,l2p2,l1p1) ~= checkDir(l2p1,l2p2,l1p2))
end


function Attacker:getX()
  return self.xpos
end
function Attacker:getY()
  return self.ypos
end


