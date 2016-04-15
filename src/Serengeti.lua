require 'torch'
require 'utils.lua'


local Serengeti = torch.class('benchmark.Serengeti');

-- Constructor
function Serengeti:__init(numLions)
  parent.__init()

  self.numLions = numLions
  self.width = 10
  self.height = 10
  self.max = math.sqrt((self.width/2)*(self.width/2) + (self.height/2)*(self.height/2))
  self.lionJump = 2
  self.gazelleJump = 3

end


-- set the position and velocity of the robot
function Serengeti:initialization()
  self.lions = {}
  for i = 1, self.numLions do
    self.lions[i] = Lion(torch.uniform(self.minPosition,self.maxPosition), torch.uniform(self.minPosition,self.maxPosition), torch.uniform(self.minRotation,self.maxRotation))
  end
  self.gazelle = Gazelle(torch.uniform(self.minPosition,self.maxPosition), torch.uniform(self.minPosition,self.maxPosition), max, lions, ContinuousField(self.width, self.height))
end


function Serengeti:step()


  self.gazelle:step()

  for i = 1, self.numLions do
    self.lions[i]:step()
  end

  return self.gazelle:isDead()
end


