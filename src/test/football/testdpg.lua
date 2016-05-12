package.path = package.path..";../?/init.lua"
package.path = package.path..";../?.lua"

require 'torch'
require 'rl'
require 'nn'
require 'utils'
require 'football'


local sim = nil

local learningRate = 0.0003
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
  local model1 = nn.Sequential():add(nn.Linear(6, 3)):add(nn.Tanh()):add(nn.Linear(3,1))
  local optimizer1 = rl.StochasticGradientDescent(model1:getParameters())
  local agent = rl.LinearIncrementalDPG(model1, optimizer1, "Q", 1, 6, 1)
  agent:setLearningRate(learningRate)
  --agent:initiateParameters(1.5,2)
  agent:initiateParameters(0,.1)
  agent:setAdditionalLearningRate(otherLR, otherLR)
  agent:setActionStdev(.1)

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
          sampleTot = sampleTot + (totReward / numIters)
          print("avg rew = " .. totReward/numIters)
        end -- end if
      end -- end while
    end -- end sampleJ for
    averages[runI] = sampleTot / numSamples
    --print("average of run ".. runI .. " is: " .. averages[runI])
  end -- end runI for

end


function doRun()

  local actions = utils.callFunctionOnObjects("getAction", agents, {{state}})

  local r, sprime, t = sim:step(actions) -- take a step for four lions

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
