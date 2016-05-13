require 'torch'


local Lion = torch.class('Lion');

-- Constructor
function Lion:__init(maxStep, field)
	print ("created lion")
	self.xpos = 0
	self.ypos = 0
	self.theta = 0
	self.maxStep = maxStep
	self.field = field
end

function Lion:reset(xpos, ypos, theta)
	self.xpos = xpos
	self.ypos = ypos
	self.theta = theta
end

function Lion:getX()
	return self.xpos
end


function Lion:getY()
	return self.ypos
end


function Lion:step(action)
	--dir = self:rotate(self.maxStep, 0, math.random()*2*math.pi)
	dir = self:rotate(self.maxStep, 0, action[1])
	oldx = self.xpos
	oldy = self.ypos
	self.xpos = self.field:stx(self.xpos + dir[1])
	self.ypos = self.field:sty(self.ypos + dir[2])

	--print("action " .. action[1] .. "  old (x, y) = " .. oldx .. ", " .. oldy .. " new x,y = " .. self.xpos .. ", " .. self.ypos)
	--xpos = self.field:stx(self.xpos + dir[1])
	--ypos = self.field:sty(self.ypos + dir[2])
	--print("dist = " math.sqrt((xpos - self.xpos)*(xpos - self.xpos) + (ypos - self.ypos)*(ypos - self.ypos)))

end

function Lion:colidedWith(l)
	vx, vy = self.field:tv(self.xpos, l:getX(), self.ypos, l:getY())
	if math.sqrt(vx*vx + vy*vy) <= 2.0 then
			return 0.0
	end
	return 0.0
end


function Lion:rotate(x, y, theta)
	sinTheta = math.sin(theta)
	cosTheta = math.cos(theta)
	xp = cosTheta * x + -sinTheta * y
	yp = sinTheta * x + cosTheta * y
	return {xp, yp}
end
