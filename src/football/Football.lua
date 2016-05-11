require 'torch'

--[[
Continuous version of the attacker and defender in http://www.cs.toronto.edu/~fritz/absps/nips00-bs.pdf
]]--
local Football = torch.class('Football')


function Football:__init(numAttackers, size, offset, defenderStart, defenderLength)
  self.size = size
  self.offset = offset or 0.0
  self.defenderStart = defenderStart or 5
  self.field = ContinuousField(size, size)
  self.defenderLength = defenderLength
  self.numAttackers = numAttackers
  self.attackers = {}
  for i = 1, numAttackers do
    self.attackers[i] = Attacker(self.size, self.field, self.size / i, self.size - self.offset)
  end
	self.terminal = false

  self.defender = Defender(self.size, self.attackers, self.field, self.defenderStart, self.defenderLength)

end

function Football:reset()
  for i = 1, self.numAttackers do
    self.attackers[i]:reset(self.size / i, self.size - self.offset)
  end
  self.defender:reset(self.defenderStart)

  local coords = {}
  -- now make the input values
  for i = 1, #self.attackers do
    table.insert(coords, self.attackers[i]:getX())
    table.insert(coords, self.attackers[i]:getY())
  end

  table.insert(coords, self.defender:getX())
  table.insert(coords, self.defender:getY())

  self.terminal = false

  return coords
end


function Football:step(actions)
  self.defender:step()

  local t = false
  local r = 0.0
  -- then step the attackers
  for i, a in ipairs(self.attackers) do
    reward, terminate = a:step(actions[i], self.defender)
    r = r + reward
    t = t or terminate -- terminated if one of the attackers reached endzone
    if t == true then
      --print("REACHED ENDZONE!!")
    end
  end

  local coords = {}
  -- now make the input values
  for i = 1, #self.attackers do
    table.insert(coords, self.attackers[i]:getX())
    table.insert(coords, self.attackers[i]:getY())
  end

  table.insert(coords, self.defender:getX())
  table.insert(coords, self.defender:getY())

  self.terminal = t
  -- return the reward
  return r, coords, self.terminal
end


function Football:getAttackers()
  return self.attackers
end

function Football:getDefender()
  return self.defender
end

function Football:getIsTerminal()
  return self.terminal
end

function Football:getDefenderPoints()
  return self.defender:getDefenderPoints()
end
