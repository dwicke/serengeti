package.path = package.path..";../../?/init.lua"
package.path = package.path..";../../?.lua"

require 'torch'
require 'rl'
require 'nn'
require 'utils'
require 'football'


local sim = nil

local learningRate = 0.001
local otherRate = 0.0005
local agents = {}
local state = nil

local trialCounter = 0
local trainingCounter = 0
local averageReward = 0
local numSteps = 0
local numIters = 0
local maxIters = 100
local averages = {}

function buildAgent(learningRate, otherLR)

  --local model1 = nn.Sequential():add(nn.Linear(6,1))
  local model1 = nn.Sequential():add(nn.Linear(6, 4)):add(nn.Sigmoid()):add(nn.Linear(4,2))
  local optimizer1 = rl.StochasticGradientDescent(model1:getParameters())
  local agent = rl.LinearIncrementalDPG(model1, optimizer1, "Q", 2, 6, 1)
  agent:setLearningRate(learningRate)
  --agent:initiateParameters(1.5,2)
  agent:initiateParameters(0.0,0.1)
  agent:setAdditionalLearningRate(otherLR, otherLR)
  agent:setActionStdev(0.000001)

  return agent
end


function init(numAttackers, size, offset, defenderStart, defenderLength)
  sim = Football(numAttackers, size, offset, defenderStart, defenderLength)

  -- put the two identical agents into the table
  for i = 1,2 do
    table.insert(agents, buildAgent(learningRate, otherRate))
  end

  state = torch.Tensor(sim:reset())

  return sim
end


function step(numRuns, numSamples)


  for runI = 1, numRuns do
    local sampleTot = 0.0
    for sampleJ = 1, numSamples do
      local numIters = 0
      local term = false
      local totReward = 0
      while term == false do
        numIters = numIters + 1
        local r, t = doRun()
        totReward = totReward + r
        if t or numIters == 20 then
          term = true
          state = torch.Tensor(sim:reset())
          --print("avg rew = " .. totReward)
        end -- end if
      end -- end while
      sampleTot = sampleTot + totReward
    end -- end sampleJ for
    averages[runI] = sampleTot / numSamples
    print("average of run ".. runI .. " is: " .. averages[runI])
  end -- end runI for

end


function doRun()

  local actions = utils.callFunctionOnObjects("getAction", agents, {{state}})
  local action1, action2 = actions[1][1], actions[1][2]


  local r, sprime, t = sim:step({{action1}, {action2}})

  -- go the the next state
  local sprime = torch.Tensor(sprime)
  local verbose = false
  utils.callFunctionOnObjects("learn", agents, {{state, r, sprime, verbose}})
  state = sprime

  return r, t
end

function writedata(filename)
  file = io.open (filename, "w")

  for i, v in ipairs(averages) do
    file:write(i .. ", " .. v .. "\n")
  end
  file:close()
end



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
