package.path = package.path..";../../?/init.lua"
package.path = package.path..";../../?.lua"



require 'test.football.testdpg'


local iterations = 3500
local sampleSize = 50
local numAttackers = 2
local size = 1
local offset = 0
local defenderStart = 0
local defenderLength = .25
function main()
  local sim = init(numAttackers, size, offset, defenderStart, defenderLength)

  local finished = false

  --for i=1, iterations do
    step(iterations, sampleSize)
  --end
  --writedata("multiagentDPG.out")
  print("finished writing")

end


main()
