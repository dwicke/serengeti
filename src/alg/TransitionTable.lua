require 'torch'

local TransitionTable = torch.class('TransitionTable')


function TransitionTable:__init(args)
	self.maxSize = args.maxSize
	self.numActor = args.numActor
	self.actionDim = args.actionDim
	self.stateDim = args.stateDim
	self.numEntries = 0
    self.insertIndex = 0
    
    self.s = torch.Tensor(self.maxSize, self.stateDim):fill(0)
    self.sprime = torch.Tensor(self.maxSize, self.stateDim):fill(0)
   	-- this store the joint action value
    self.a = torch.Tensor(self.maxSize, self.numActor*self.actionDim):fill(0)
    self.r = torch.Tensor(self.maxSize):fill(0)
    self.t = torch.ByteTensor(self.maxSize):fill(0)
end


function TransitionTable:reset()
    self.numEntries = 0
    self.insertIndex = 0
end


function TransitionTable:size()
    return self.numEntries
end


function TransitionTable:empty()
    return self.numEntries == 0
end


function TransitionTable:sampleOne()
    assert(self.numEntries > 1)
    
    local index = torch.random(1, self.numEntries)
    
    return self:get(index)
end


function TransitionTable:get(index)
	return {self.s[index], self.a[index], self.r[index], self.sprime[index], self.t[index]}
end

function TransitionTable:sample(batchSize)
    local batchSize = batchSize or 1
    
    local buffer = {}
    
	if batchSize > self.numEntries then
		for i = 1, self.numEntries do
    		buffer.insert(buffer, self:get(i))
    	end
    else
    	for i = 1,batchSize do
    		table.insert(buffer, self:simpleOne())
    	end
	end    
    return buffer
end


-- s is tensor of state feature
-- a is the tensor of joint actions
function TransitionTable:add(s, a, r, sprime, term)
    assert(s, 'State cannot be nil')
    assert(a, 'Action cannot be nil')
    assert(r, 'Reward cannot be nil')

    -- increase until at full capacity
    if self.numEntries < self.maxSize then
        self.numEntries = self.numEntries + 1
    end

    -- Always insert at next index, then wrap around
    self.insertIndex = self.insertIndex + 1
    -- Overwrite oldest experience once at capacity
    if self.insertIndex > self.maxSize then
        self.insertIndex = 1
    end

    -- Overwrite (s,a,r,t) at insertIndex
    self.s[self.insertIndex] = s:clone()
    self.a[self.insertIndex] = a:clone()
    self.r[self.insertIndex] = r
    
    
    if term then
        self.t[self.insertIndex] = 1
    else
        self.t[self.insertIndex] = 0
        self.sprime[self.insertIndex] = sprime:clone()
    end
end
