package.path = package.path..";../?/init.lua"
package.path = package.path..";../?.lua"
package.path = package.path..";../../../PolicyGradient/src/?/init.lua"
require 'torch'
require 'control'


local stepInteval = nil
local stepTimer = nil
local s = nil
local isDead = nil
local iterations = 4000
local sampleSize = 100
local numLions = 4
local fieldSize = 10
local circleRadius = .25
local scale = 10

-- gets called once at the very beginning
function love.load()
  s = init(numLions, fieldSize)

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
		-- draw the lions (red circle)

    local last = 0.0
		for i, coords in ipairs(s:getLionCoordinates()) do
      --print("coords = " .. tostring(coords) .. " " .. tostring(i))
      if (i % 2) == 0 then
        love.graphics.circle("fill", last * scale, coords *scale, circleRadius * scale, 100)
      else
        last = coords
      end
		end



		-- draw the gazelle (green circle)
		love.graphics.setColor(0, 255, 0)
		gazelleCoords = s:getGazelleCoordinates()
		love.graphics.circle("fill", gazelleCoords[1] * scale, gazelleCoords[2] * scale, circleRadius * scale, 100) -- Draw white circle with 100 segments.

		love.graphics.setColor(255,255,255)
		love.graphics.polygon('line', 0,0, fieldSize * scale,0, fieldSize * scale,fieldSize * scale, 0,fieldSize * scale)
	end
	--love.graphics.translate(10 + i, 10)
	--love.graphics.print("Text", 5, 5)   -- will effectively render at 15x15
end
