searchMethod:search(self.critic, sampleBatch[i][3], self.searchPoint)

require 'torch'
require 'luawrapper'
require 'nn'

local LBFGSB = torch.class('LBFGSB')


function LBFGSB:__init(featureSize, numVariables, upperBounds, lowerBounds)
	self.featureSize = featureSize
	self.variable = getInputArray()
	self.numVariables = numVarialbes
	setNumberVars(numVariables)
	setUpperBound(upperBounds)
	setLowerBound(lowerBounds)
end

-- NOTE: since the C code for LBFGSB is doing minimization, thus, we need to times -1 for f and grads
function LBFGSB:search(func, partial, input, funcGrads)
	-- first prepare the input for the approximator
	local inputTensor = torch.Tensor(self.featureSize + self.numVariables):fill(0)

	-- fill the part in
	inputTensor:narrow(1, 1, self.featureSize):copy(partial)

	-- let's hope the max is greater than this
	local maxValue = -100000000
	local optimal = {}

	local numStartPoints = #input
	for i = 1, numStartPoints do
		local startPoints = input[i]
		assert(self.numVariables == #startPoints)

		-- set the start points, both for optimization and approximator
		for j = 1, #startPoints do
			self.variable[j] = startPoints[j]
		end

		self:updateValue(inputTensor, func, funcGrads)

		-- start to optimize
		startLBFGSB()

		while self:pulse() == false do
			self:updateValue(inputTensor, func, funcGrads)
		end

		-- get the final value and optimal action
		for j = 1, self.numVariables do
			inputTensor[self.featureSize + j] = self.variable[j]
		end

		local f = func:forward(inputTensor)

		if f > max then
			max = f
			optimal = {}
			for j = 1, self.numVariables do
				table.insert(optimal, self.variable[j])
			end
		end
	end
	
	assert(max ~= -100000000)
	
	return max, optimal
	
end

function LBFGSB:updateValue(inputTensor, func, funcGrads)
	-- first get the new coordinates and put in tensor
	for i = 1, self.numVariables do
		inputTensor[self.featureSize + i] = self.variable[i]
	end

	local f = func:forward(inputTensor)
	setf(-f)

	-- not sure if we need this, but to be safe, we do this
	funcGrads:zero()
	-- get the gradient with respect to input, not weights
	local gradsInput = func:backward(inputTensor, f)
	local gradsTable = {}
	for j = 1, self.numVariables do
		table.insert(gradsTable, -gradsInput[self.featureSize+j])
	end
	setGrad(gradsTable)
end



function LBFGSB:pulse()
	return pulseLBFGSB()
end
