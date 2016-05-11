package.path = package.path..";../?/init.lua"
package.path = package.path..";../?.lua"
package.path = package.path..";../../../PolicyGradient/src/?/init.lua"
require 'torch'
require 'singleAgentTest'


local stepInteval = nil
local stepTimer = nil
local s = nil
local iterations = 4000
local sampleSize = 5
local numAttackers = 2
--[[local fieldSize = 10
local offset = 2
local defenderStart = 2
local defenderLength = 6]]--

local numAttackers = 2
local fieldSize = 1
local offset = 0
local defenderStart = 0
local defenderLength = .25

local circleRadius = .15
local scale = 100

-- gets called once at the very beginning
function love.load()
  s = init(numAttackers, fieldSize, offset, defenderStart, defenderLength)

  stepInteval = 0.05 -- second
  stepTimer = stepInteval
end

function love.update(dt)
  stepTimer = stepTimer - dt

  -- time is up, need to take a step
  if stepTimer < 0 then
    -- one step in simulation
    step(iterations, sampleSize)

    -- reset the timer
    stepTimer = stepInteval
  end
end

function love.draw()

  --print("is terminal = " .. tostring(s:getIsTerminal()))
  if not s:getIsTerminal() then

    love.graphics.setColor(255, 0,0)
    -- draw the attackers (red circle)

    local last = 0.0
    for i, atk in ipairs(s:getAttackers()) do
      love.graphics.circle("fill", atk:getX()*scale, atk:getY()*scale, circleRadius * scale, 100)
    end



    -- draw the defender (green circle)
    love.graphics.setColor(0, 255, 0)
    pts = s:getDefenderPoints()
    for i=1, #pts do
      if (i % 2) == 1 then
        love.graphics.line(pts[i][1]*scale, pts[i][2]*scale, pts[i+1][1]*scale, pts[i+1][2]*scale)
      end
    end



    love.graphics.setColor(255,255,255)
    love.graphics.polygon('line', 0,0, fieldSize*scale,0, fieldSize*scale,fieldSize*scale, 0,fieldSize*scale)
  end
  --love.graphics.translate(10 + i, 10)
  --love.graphics.print("Text", 5, 5)   -- will effectively render at 15x15
end
