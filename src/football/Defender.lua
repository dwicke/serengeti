require 'torch'


local Defender = torch.class('Defender')

-- Constructor
function Defender:__init(maxFieldSize, attackers, field, ypos)
  self.attackers = attackers
  self.field = field
  self.ypos = ypos
  self.xpos = maxFieldSize / 2.5

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
      vx = field:tdx(l:getX(), self.xpos)
      if vx ~= 0.0 then
        sign = vx / math.abs(vx)
      else
        sign = 0.0
      end
    end
  end
  self.xpos = self.xpos + sign
end
