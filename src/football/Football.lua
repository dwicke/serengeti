require 'torch'

--[[
Continuous version of the attacker and defender in http://www.cs.toronto.edu/~fritz/absps/nips00-bs.pdf
]]--
local Football = torch.class('Football')


function Football:__init(numAttackers, size, offset, defenderStart)
  self.size = size
  offset = offset or 0.0
  defenderStart = defenderStart or 5
  field = football.ContinuousField(size, size)
  self.attackers = {}
  for i = 1, numAttackers do
    self.attackers = Attacker(size, field, size / i, size - offset)
  end


  self.defender = Defender(size, attackers, field, defenderStart)

end

function Football:reset()


end


function Football:step(actions)
  self.defender:step()

  -- then step the attackers
  for i, a in ipairs(self.attackers) do
    a:step(actions[i], self.defender)
  end

  -- now check if one of the attackers has reached the endzone

end





