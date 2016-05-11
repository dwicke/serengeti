require 'torch'


local Gazelle = torch.class('Gazelle')

-- Constructor
function Gazelle:__init(maxFieldLength, lions, field, stepSize)
	self.xpos = 0
	self.ypos = maxFieldLength / 2
	self.maxFieldLength = maxFieldLength
	self.lions = lions
	self.field = field
	self.stepSize = stepSize
	self.dead = -1
	self.deathRange = 2
end


function Gazelle:reset(xpos, ypos)
	self.xpos = 0--xpos
	self.ypos = self.maxFieldLength / 2-- ypos
	self.dead = -1
end

function Gazelle:step()
	if self.dead == 1 then
		return
	end
	xp = 0.0
	yp = 0.0
	for i, l in ipairs(self.lions) do
		vx, vy = self.field:tv(l:getX(), self.xpos, l:getY(), self.ypos)
		vLen = math.sqrt(vx*vx + vy*vy)
		scale = (self.maxFieldLength - vLen) / vLen
		xp = xp + vx * scale
		yp = yp + vy * scale
	end
	xp = -1*xp
	yp = -1*yp

	len = math.sqrt(xp*xp + yp*yp)
	if len > 0.01 then
		xp = xp * (self.stepSize / len)
		yp = yp * (self.stepSize / len)
	else
		print("Gazelle is not moving!")
	end
	self.xpos = self.field:stx(self.xpos + xp)
	self.ypos = self.field:sty(self.ypos + yp)
end

-- returns -1 if not dead
-- returns 1 if dead
function Gazelle:isDead()
	--print("Checking if Gazelle is dead")
	for i, l in ipairs(self.lions) do
		vx, vy = self.field:tv(self.xpos, l:getX(), self.ypos, l:getY())
		--print("distance is".. math.sqrt(vx*vx + vy*vy) .. " l(x,y) = ".. l:getX() .. ", " .. l:getY())
		if math.sqrt(vx*vx + vy*vy) <= self.deathRange then
			self.dead = 1
			return true
		end
	end
	self.dead = -1
	return false
end


function Gazelle:getX()
	return self.xpos
end

function Gazelle:getY()
	return self.ypos
end


