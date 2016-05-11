package.path = package.path..";../?/init.lua"
package.path = package.path..";../?.lua"

require 'torch'
require 'rl'
require 'nn'
require 'utils'
require 'serengeti'


local sim = nil

local learningRate = 0.001

local agents = {}
local state = nil

local trialCounter = 0
local trainingCounter = 0
local averageReward = 0
local numSteps = 0
local averages = {}


function buildAgent(learningRate)
  local modelMean2 = nn.Sequential():add(nn.Linear(15, 1))
  local modelStdev2 = nn.Sequential():add(nn.Linear(15, 1)):add(nn.Exp())
  local model2 = nn.ConcatTable()
  model2:add(modelMean2):add(modelStdev2)

  local model = nn.Sequential():add(nn.Linear(10, 15)):add(nn.Tanh()):add(model2)
  --local model = nn.Sequential():add(nn.Linear(6, 10)):add(nn.Sigmoid()):add(nn.Linear(10, 8)):add(nn.Tanh()):add(nn.Linear(8,2))



  local policy = rl.GaussianPolicy(1)
  local optimizer = rl.StochasticGradientDescent(model:getParameters())
  agent = rl.GPOMDP(model, policy, optimizer)

  agent:setLearningRate(learningRate)

  -- NOTE: we may want to initiate the parameters here

  return agent
end


function init(numLions, size)
	sim = serengeti.Serengeti(numLions, size)
	
	-- put the four identical agents into the table
	for i = 1,4 do
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
			averages[trainingCounter] = averageReward/trajectoriesLimit
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
	io.output(file)
	for i, v in ipairs(averages) do
		io.output(i .. ", " .. v .. "\n")
	end
	io.close(file)
end

