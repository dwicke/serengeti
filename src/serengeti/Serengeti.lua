require 'torch'


local Serengeti = torch.class('serengeti.Serengeti');

-- Constructor
function Serengeti:__init(numLions)
  --parent.__init()

  self.numLions = numLions
  self.width = 10
  self.height = 10
  self.max = math.sqrt((self.width/2)*(self.width/2) + (self.height/2)*(self.height/2))
  self.lionJump = 2
  self.gazelleJump = 3
  self.minPosition = 0
  self.maxPosition = 10
  self.minRotation = 0
  self.maxRotation = 360
end


-- set the position and velocity of the robot
function Serengeti:initialization()
  self.lions = {}
  for i = 1, self.numLions do
    self.lions[i] = Lion(torch.uniform(self.minPosition,self.maxPosition), torch.uniform(self.minPosition,self.maxPosition), torch.uniform(self.minRotation,self.maxRotation))
    print("lions i = " .. i .. " x = " ..self.lions[i]:getX())
  end

  self.gazelle = Gazelle(torch.uniform(self.minPosition,self.maxPosition), torch.uniform(self.minPosition,self.maxPosition), self.max, self.lions, serengeti.ContinuousField(self.width, self.height), self.gazelleJump)
end


function Serengeti:step()


  self.gazelle:step()

  for i = 1, self.numLions do
    self.lions[i]:step()
  end

  return self.gazelle:isDead()
end


function Serengeti:getLionCoordinates()
  coords = {}
  print("getting coordinates")
  for i,l in ipairs(self.lions) do
    coords[i] = {l:getX()*30, l:getY()*30}
    print("lion[" ..i .. "]  = {" .. coords[i][1] .. ", " .. coords[i][2] .. "}")
  end
  return coords
end

function Serengeti:getGazelleCoordinates()
  return {self.gazelle:getX()*30, self.gazelle:getY()*30}
end



