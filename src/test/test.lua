require 'torch'
require 'serengeti'

s = serengeti.Serengeti(3)
s:initialization()
print(s:step())
