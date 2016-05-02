package.path = package.path..";../?/init.lua"
package.path = package.path..";../?.lua"
require 'torch'
require 'serengeti'

s = serengeti.Serengeti(3)
isDead = -1

-- gets called once at the very beginning
function love.load()
  s:initialization()
end

function love.update()
  isDead = s:step()
  print("is Dead = " .. isDead)
end

function love.draw()

  if isDead == -1 then
    love.graphics.setColor(255, 0,0)
    -- draw the lions (red circle)

    for i, coords in ipairs(s:getLionCoordinates()) do
      love.graphics.circle("fill", coords[1], coords[2], 15, 100)
    end
    --love.graphics.circle("fill", 300, 300, 15, 100) -- Draw white circle with 100 segments.
    love.graphics.setColor(0, 0, 255)
    love.graphics.circle("fill", 300, 300, 50, 5)   -- Draw red circle with five segments.


    -- draw the gazelle (green circle)
    love.graphics.setColor(0, 255, 0)
    gazelleCoords = s:getGazelleCoordinates()
    love.graphics.circle("fill", gazelleCoords[1], gazelleCoords[2], 15, 100) -- Draw white circle with 100 segments.

    love.graphics.setColor(255,255,255)
    love.graphics.polygon('line', 0,0, 600,0, 600,600, 0,600)
  end
  --love.graphics.translate(10 + i, 10)
  --love.graphics.print("Text", 5, 5)   -- will effectively render at 15x15
end
