package.path = package.path..";../../?/init.lua"
package.path = package.path..";../../?.lua"

require 'torch'
require 'rl'
require 'nn'
require 'utils'
require 'football'


local sim = nil

local learningRate = 0.0001

local agents = {}
local state = nil

local trialCounter = 0
local trainingCounter = 0
local averageReward = 0
local numSteps = 0
local numIters = 0
local maxIters = 100
local averages = {}

function buildAgent(learningRate)
  local modelMean2 = nn.Sequential():add(nn.Linear(10, 1))
  local modelStdev2 = nn.Sequential():add(nn.Linear(10, 1)):add(nn.Exp())
  local model2 = nn.ConcatTable()
  model2:add(modelMean2):add(modelStdev2)

  local model = nn.Sequential():add(nn.Linear(6, 10)):add(nn.Tanh()):add(model2)
  --local model = nn.Sequential():add(nn.Linear(6, 10)):add(nn.Sigmoid()):add(nn.Linear(10, 8)):add(nn.Tanh()):add(nn.Linear(8,2))



  local policy = rl.GaussianPolicy(1)
  local optimizer = rl.StochasticGradientDescent(model:getParameters())
  agent = rl.Reinforce(model, policy, optimizer)

  agent:setLearningRate(learningRate)

  -- NOTE: we may want to initiate the parameters here

  return agent
end


function init(numAttackers, size, offset, defenderStart, defenderLength)
  sim = Football(numAttackers, size, offset, defenderStart, defenderLength)

  -- put the two identical agents into the table
  for i = 1,2 do
    table.insert(agents, buildAgent(learningRate))
  end

  state = torch.Tensor(sim:reset())
  -- this is for the episodic method
  utils.callFunctionOnObjects("startTrial", agents)

  return sim
end


function step(iterationsLimit, trajectoriesLimit)

  if sim.terminal then
    state = torch.Tensor(sim:reset())

    -- this is for the episodic method
    utils.callFunctionOnObjects("startTrial", agents)
  end

  --print("action")
  local actions = utils.callFunctionOnObjects("getAction", agents, {{state}})
  --print("post action")

  --print("num actions " .. #actions[1])



  local r, sprime, t = sim:step(actions) -- take a step for four lions

  utils.callFunctionOnObjects("step", agents, {{state, r}})

  averageReward = averageReward + r
  numSteps = numSteps + 1

  -- go the the next state
  state = torch.Tensor(sprime)
  numIters = numIters + 1
  -- for episodic method
  if t or numIters == 20 then
    utils.callFunctionOnObjects("endTrial", agents)
    sim.terminal = true
    --sim:reset()
    --if t then
      trialCounter = trialCounter + 1
    --end
    numIters = 0

    -- only learn after so many trajectories collected
    if trialCounter == trajectoriesLimit then
      utils.callFunctionOnObjects("learn", agents, {{nil, nil}})

      --print("learn once")

      trainingCounter = trainingCounter + 1
      trialCounter = 0

      print("iteration: ".. trainingCounter..", average is ".. (averageReward/trajectoriesLimit))
      averages[trainingCounter] = (averageReward/trajectoriesLimit)
      numSteps = 0
      averageReward = 0

      -- training is finished
      if trainingCounter == iterationsLimit then
        return true
      end
    end
  end

  -- training is not end
  return false

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

  while not finished do
    finished = step(iterations, sampleSize)
  end
  writedata("multiagentReinforce.out")
  print("finished writing")

end


main()

