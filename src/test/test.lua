package.path = package.path..";../?/init.lua"
package.path = package.path..";../?.lua"
require 'torch'
require 'serengeti'

s = serengeti.Serengeti(3)
s:initialization()
print(s:step())
