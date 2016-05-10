package.path = package.path..";../../?/init.lua"
package.path = package.path..";../../?.lua"



require 'test.football.control'


local iterations = 4000
local sampleSize = 10
local numAttackers = 2
local size = 10
local offset = 2
local defenderStart = 2
local defenderLength = 6
function main()
  local sim = init(numAttackers, size, offset, defenderStart, defenderLength)

  local finished = false

  while not finished do
    finished = step(iterations, sampleSize)
  end

end


main()
