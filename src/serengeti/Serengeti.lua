require 'torch'


local Serengeti = torch.class('serengeti.Serengeti')

-- Constructor
function Serengeti:__init(numLions, size)

	self.numLions = numLions
	self.width = size
	self.height = size
	self.max = math.sqrt((self.width/2)*(self.width/2) + (self.height/2)*(self.height/2))
	self.lionJump = 1
	self.gazelleJump = 3
	self.minPosition = 0
	self.maxPosition = size
	self.field = serengeti.ContinuousField(self.width, self.height)
	self.terminal = false

	self.lions = {}
	for i = 1, self.numLions do
		self.lions[i] = Lion(self.lionJump, self.field)
	end
	
	self.gazelle = Gazelle(self.max, self.lions, self.field, self.gazelleJump)
end


-- set the position and velocity of the agents
function Serengeti:reset()

	-- random put the lions and gazelle
	for i = 1, self.numLions do
		self.lions[i]:reset(torch.uniform(self.minPosition,self.maxPosition), 
			torch.uniform(self.minPosition,self.maxPosition),
			math.random()*2*math.pi)
		--print("lions i = " .. i .. " x = " ..self.lions[i]:getX())
	end

	self.gazelle:reset(torch.uniform(self.minPosition,self.maxPosition), 
		torch.uniform(self.minPosition,self.maxPosition))
		
	self.terminal = false

	local coords = self:getLionCoordinates()
	local gazelle = self:getGazelleCoordinates()
	
	for i = 1,#gazelle do
		table.insert(coords, gazelle[i])
	end
	
	return coords

end


function Serengeti:step(actions)

	local reward = -1

	self.gazelle:step()

	for i = 1, self.numLions do
		self.lions[i]:step(actions[i])
	end

	for i = 1, self.numLions do
		for j = i+1, self.numLions do
			reward = reward + self.lions[i]:colidedWith(self.lions[j])
		end
	end


	if self.gazelle:isDead() then
		self.terminal = true
		reward = 1
	end

	local coords = self:getLionCoordinates()
	local gazelle = self:getGazelleCoordinates()

	for i = 1,#gazelle do
		table.insert(coords, gazelle[i])
	end

	return reward, coords, self.terminal

end


function Serengeti:getLionCoordinates()
	local coords = {}
	--print("getting coordinates")
	for i,l in ipairs(self.lions) do
		table.insert(coords, l:getX() * l:getX())
		table.insert(coords, l:getY() * l:getY())

		table.insert(coords, l:getX())
		table.insert(coords, l:getY())

		table.insert(coords, l:getX() * l:getY())
		table.insert(coords, l:getY() * l:getY())
	end
	--print(coords)
	return coords
end

function Serengeti:getGazelleCoordinates()
	--print("gaz x = " .. self.gazelle:getX() .. " y = " .. self.gazelle:getY())
	return {self.gazelle:getX(), self.gazelle:getY()}
end

function Serengeti:getIsTerminal()
	return self.terminal
end

function Serengeti:basisFunction(coords)



end



