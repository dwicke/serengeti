require 'torch'


local Defender = torch.class('Defender')

-- Constructor
function Defender:__init(maxFieldSize, attackers, field, ypos, defenderLength)
  self.attackers = attackers
  self.field = field
  self.ypos = ypos
  self.xpos = maxFieldSize / 2.5
  self.defenderLength = defenderLength
  self.maxFieldSize

end

function Defender:reset(xpos, ypos)
  self.ypos = ypos
  self.xpos = xpos
end

function Defender:step()
  -- find the agent closest to the defender and move in the x direction toward it one unit

  sign = 1
  minDist = maxFieldSize + 1
  for i, l in ipairs(self.attackers) do
    if l:getY() - self.ypos < minDist then
      vx = field:tdx(l:getX(), self.xpos) -- get the dist in the x direction (while wrapping around)
      if vx ~= 0.0 then
        sign = vx / math.abs(vx)
      else
        sign = 0.0
      end
    end
  end
  self.xpos = self.xpos + sign
end

-- returns a set of four points so defined so that the first two points correspond
-- to the beginning and end of the first segment and the next two points correspond
-- to the second segment that wraps around to the other side of the field.
-- so if not on the other side of the field.
function Defender:getDefenderPoints()

  endX = field:stx(self.xpos + self.defenderLength)

  if endX < self.xpos then
    -- then I have wrapped around and need to return 4 points
    return {{self.xpos, self.ypos}, {self.maxFieldSize, self.ypos},{0, self.ypos}, {endX, self.ypos}}
  end
   -- otherwise I am just a regular two point line segment
  return {{self.xpos, self.ypos}, {endX, self.ypos}}
end


