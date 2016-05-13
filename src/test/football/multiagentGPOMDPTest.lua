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
local winner = {}
local numWins = 0

function buildAgent(learningRate, net)
  local modelMean2 = nn.Sequential():add(nn.Linear(10, 1))
  local modelStdev2 = nn.Sequential():add(nn.Linear(10, 1)):add(nn.Exp())
  local model2 = nn.ConcatTable()
  model2:add(modelMean2):add(modelStdev2)

  local model = nn.Sequential():add(nn.Linear(6, 10)):add(nn.Tanh()):add(model2)
  --local model = nn.Sequential():add(nn.Linear(6, 10)):add(nn.Sigmoid()):add(nn.Linear(10, 8)):add(nn.Tanh()):add(nn.Linear(8,2))

  if net ~= nil then
    model = net
  end

  local policy = rl.GaussianPolicy(1)
  local optimizer = rl.StochasticGradientDescent(model:getParameters())
  agent = rl.GPOMDP(model, policy, optimizer)

  agent:setLearningRate(learningRate)

  -- NOTE: we may want to initiate the parameters here

  return agent
end

function initWithNetwork(numAttackers, size, offset, defenderStart, defenderLength, net)
  sim = Football(numAttackers, size, offset, defenderStart, defenderLength)
  agents = {}
  winner = {}
  trainingCounter = 0
  trialCounter = 0
  averageReward = 0
  numSteps = 0
  numIters = 0
  numWins = 0

  -- put the two identical agents into the table
  for i = 1,2 do
    table.insert(agents, buildAgent(learningRate, net[i]))
  end

  state = torch.Tensor(sim:reset())
  -- this is for the episodic method
  utils.callFunctionOnObjects("startTrial", agents)

  return sim

end

function init(numAttackers, size, offset, defenderStart, defenderLength)
  sim = Football(numAttackers, size, offset, defenderStart, defenderLength)
  agents = {}
  winner = {}
  trainingCounter = 0
  trialCounter = 0
  averageReward = 0
  numSteps = 0
  numIters = 0
  numWins = 0

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
    numWins = numWins + 1
    if t == true then
      winner[numWins] = sim:getWinner()
      --print("step i = " .. numWins .. " winner = " .. winner[numWins])
    else
      winner[numWins] = 0
      --print("step i = " .. numWins .. " winner = " .. winner[numWins])
    end

    -- only learn after so many trajectories collected
    if trialCounter == trajectoriesLimit then
      utils.callFunctionOnObjects("learn", agents, {{nil, nil}})

      --print("learn once")

      trainingCounter = trainingCounter + 1
      trialCounter = 0

      --print("iteration: ".. trainingCounter..", average is ".. (averageReward/trajectoriesLimit))
      averages[trainingCounter] = (averageReward/trajectoriesLimit)

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
function writeWinnerdata(filename)
  file = io.open (filename, "w")

  for i, v in ipairs(winner) do
    file:write(i .. ", " .. v .. "\n")
  end
  file:close()
end

function writeNetworks()
  for i, v in ipairs(agents) do
    torch.save("agent"..i..".network", v.model)
  end
end

function loadNetworks(numAgents)
  local nets = {}
  for i=1, numAgents do
    nets[i] = torch.load("./football/agent"..i..".network")
  end
  return nets
end

local iterations = 1000
local sampleSize = 50
local numAttackers = 2
local size = 3
local offset = 0
local defenderStart = 0
local defenderLength = .75
function main()
  --local sim = init(numAttackers, size, offset, defenderStart, defenderLength)

  local finished = false

  for i=1, 5 do
    local sim = init(numAttackers, size, offset, defenderStart, defenderLength)
    finished = false
    while not finished do
      finished = step(iterations, sampleSize)
    end
    --writeNetworks()
    writedata("s3multiagentGPOMDP" .. i .. ".out")
    --writeWinnerdata("s3multiagentGPOMDPWinner".. i .. ".out")
    averages = {}
    winner = {}

    print("finished writing" .. i)
  end
end


--main()

