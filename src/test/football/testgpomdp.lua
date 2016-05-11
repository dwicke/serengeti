package.path = package.path..";../?/init.lua"
package.path = package.path..";../?.lua"

require 'torch'
require 'rl'
require 'nn'
require 'utils'
require 'football'


local sim = nil

local learningRate = 0.001

local agents = {}
local state = nil

local trialCounter = 0
local trainingCounter = 0
local averageReward = 0
local numSteps = 0


function buildAgent(learningRate)
  local model = nn.Sequential():add(nn.Linear(6, 4)):add(nn.Sigmoid()):add(nn.Linear(4,1))
  local policy = rl.GaussianPolicy(1, 1.0)
  local optimizer = rl.StochasticGradientDescent(model:getParameters())
  agent = rl.GPOMDP(model, policy, optimizer)

  agent:setLearningRate(learningRate)

  -- NOTE: we may want to initiate the parameters here

  return agent
end


function init(numAttackers, size, offset, defenderStart, defenderLength)
  sim = Football(numAttackers, size, offset, defenderStart, defenderLength)

  -- put the four identical agents into the table
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

  local r, sprime, t = sim:step(actions) -- take a step for four lions

  utils.callFunctionOnObjects("step", agents, {{state, r}})

  averageReward = averageReward + r
  numSteps = numSteps + 1

  -- go the the next state
  state = torch.Tensor(sprime)

  -- for episodic method
  if t then
    utils.callFunctionOnObjects("endTrial", agents)
    trialCounter = trialCounter + 1

    -- only learn after so many trajectories collected
    if trialCounter == trajectoriesLimit then
      utils.callFunctionOnObjects("learn", agents, {{nil, nil}})

      print("learn once")

      trainingCounter = trainingCounter + 1
      trialCounter = 0

      print("average is ".. (averageReward/trajectoriesLimit))
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


