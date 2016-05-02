require 'torch'


local Serengeti = torch.class('serengeti.Serengeti');

-- Constructor
function Serengeti:__init(numLions)
  --parent.__init()

  self.numLions = numLions
  self.width = 600
  self.height = 600
  self.max = math.sqrt((self.width/2)*(self.width/2) + (self.height/2)*(self.height/2))
  self.lionJump = 1
  self.gazelleJump = 3
  self.minPosition = 0
  self.maxPosition = 600
  self.field = serengeti.ContinuousField(self.width, self.height)
end


-- set the position and velocity of the robot
function Serengeti:initialization()
  self.lions = {}

  for i = 1, self.numLions do
    self.lions[i] = Lion(torch.uniform(self.minPosition,self.maxPosition), torch.uniform(self.minPosition,self.maxPosition), math.random()*2*math.pi, lionJump, self.field)
    print("lions i = " .. i .. " x = " ..self.lions[i]:getX())
  end

  self.gazelle = Gazelle(torch.uniform(self.minPosition,self.maxPosition), torch.uniform(self.minPosition,self.maxPosition), self.max, self.lions, self.field, self.gazelleJump)
end


function Serengeti:step()


  self.gazelle:step()

  for i = 1, self.numLions do
    self.lions[i]:step()
  end

  --for i = 1, self.numLions do
    --self.lions[i]:checkDist()
  --end

  return self.gazelle:isDead()
end


function Serengeti:getLionCoordinates()
  coords = {}
  print("getting coordinates")
  for i,l in ipairs(self.lions) do
    coords[i] = {l:getX(), l:getY()}
    --print("lion[" ..i .. "]  = {" .. coords[i][1] .. ", " .. coords[i][2] .. "}")
  end
  return coords
end

function Serengeti:getGazelleCoordinates()
  print("gaz x = " .. self.gazelle:getX() .. " y = " .. self.gazelle:getY())
  return {self.gazelle:getX(), self.gazelle:getY()}
end



