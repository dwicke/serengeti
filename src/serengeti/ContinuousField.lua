require 'torch'


local ContinuousField = torch.class('serengeti.ContinuousField');


function ContinuousField:__init(width, height)
	--parent.__init()
	self.width = width
	self.height = height
end

function ContinuousField:stx(x, width)
	width = width or self.width
	if x >= 0 then
		if x < width then
			return x
		end
		return x - width
	end
	return x + width;
end

function ContinuousField:tdx(x1, x2, width)

	if math.abs(x1- x2) <= (width / 2) then
		return x1 - x2
	end
	dx = self:stx(x1, width) - self:stx(x2, width)
	if dx * 2 > width then
		return dx - width
	end
	if dx * 2 < -width then
		return dx + width
	end
	return dx

end

function ContinuousField:sty(y, height)
	height = height or self.height
	if y >= 0 then
		if y < height then
			return y
		end
		return y - height
	end
	return y + height;
end

function ContinuousField:tdy(y1, y2, height)

	if math.abs(y1- y2) <= (height / 2) then
		return y1 - y2
	end
	dy = self:sty(y1, height) - self:sty(y2, height)
	if dy * 2 > height then
		return dy - height
	end
	if dy * 2 < -height then
		return dy + height
	end
	return dy

end


function ContinuousField:tv(x1, x2, y1, y2)
	return self:tdx(x1,x2, self.width), self:tdy(y1, y2, self.height)
end

