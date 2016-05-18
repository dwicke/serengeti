

require 'torch'
require 'luawrapper'
require 'nn'

local LBFGSB = torch.class('LBFGSB')


function LBFGSB:__init(featureSize, numVariables, upperBounds, lowerBounds)
	self.featureSize = featureSize
	self.variable = getInputArray()
	self.numVariables = numVariables
	setNumberVars(numVariables)
	setUpperBound(upperBounds)
	setLowerBound(lowerBounds)
end

-- NOTE: since the C code for LBFGSB is doing minimization, thus, we need to times -1 for f and grads
function LBFGSB:search(func, partial, input, funcGrads, iteration)
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
		
		-- batch normalization start here
--		local batchNormalizationInputTensor = torch.Tensor(1, inputTensor:nElement())
--		batchNormalizationInputTensor[1]:copy(inputTensor)
--
--		local f = func:forward(batchNormalizationInputTensor)
--		local v = f[1][1]
		-- batch normalization ends here
		
		local f = func:forward(inputTensor)
		local v = f[1]
		
		--print("value is "..v)
		if v > maxValue then
			maxValue = v
			optimal = {}
			for k = 1, self.numVariables do
				table.insert(optimal, self.variable[k])
			end
		end
	end
	
	if iteration > 1000 and iteration%500 == 0 then
		print("maxValue is "..maxValue..", optimal is "..optimal[1]..", "..optimal[2])
	end
--	for i = 1,#optimal do
--		print("optimal is"..optimal[i])
--	end
	


	assert(maxValue ~= -100000000)
	
	
	return maxValue, optimal
	
end

function LBFGSB:updateValue(inputTensor, func, funcGrads)
	-- first get the new coordinates and put in tensor
	for i = 1, self.numVariables do
		inputTensor[self.featureSize + i] = self.variable[i]
	end

	local f = func:forward(inputTensor)
	setf(-(f[1]))  -- f is a tensor, we convert it to number

	-- not sure if we need this, but to be safe, we do this
	funcGrads:zero()
	-- get the gradient with respect to input, not weights
	local gradsInput = func:backward(inputTensor, torch.Tensor{1})
	local gradsTable = {}
	for i = 1, self.numVariables do
		table.insert(gradsTable, -gradsInput[self.featureSize+i])
	end
	setGrad(gradsTable)
end



function LBFGSB:updateValueWithBatchNormalization(inputTensor, func, funcGrads)
	-- first get the new coordinates and put in tensor
	for i = 1, self.numVariables do
		inputTensor[self.featureSize + i] = self.variable[i]
	end
	
	local batchNormalizationInputTensor = torch.Tensor(1, inputTensor:nElement())
	batchNormalizationInputTensor[1]:copy(inputTensor)

	--print(batchNormalizationInputTensor)
	local f = func:forward(batchNormalizationInputTensor)
	setf(-(f[1][1]))  -- f is a tensor, we convert it to number

	-- not sure if we need this, but to be safe, we do this
	funcGrads:zero()
	-- get the gradient with respect to input, not weights
	local gradsInput = func:backward(batchNormalizationInputTensor, torch.Tensor(1,1):fill(1))
	
	--print(gradsInput)
	local gradsTable = {}
	for i = 1, self.numVariables do
		table.insert(gradsTable, -gradsInput[1][self.featureSize+i])
	end
	setGrad(gradsTable)
end



function LBFGSB:pulse()
	return pulseLBFGSB()
end


return LBFGSB