package.path = package.path..";../../?/init.lua"
package.path = package.path..";../../?.lua"



require 'test.football.testgpomdp'


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

  while not finished do
    finished = step(iterations, sampleSize)
  end
  writedata("multiagentFixedStdGPOMDP.out")
  print("finished writing")

end


main()
