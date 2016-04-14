require 'torch'
require 'utils.lua'


local Gazelle = torch.class('benchmark.Gazelle');

-- Constructor
function Gazelle:__init(xpos, ypos, theta, maxFieldLength, lions)
  self.xpos = xpos
  self.ypos = ypos
  self.theta = theta
  self.maxFieldLength = maxFieldLength
  self.lions = lions
end


function Gazelle:step()

end


function Gazelle:stx(x, width):
  if x >= 0 then
    if x < width then
      return x
    end
    return x - width
  end
  return x + width;
end

function Gazelle:tdx(x1, x2, width)
  
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

function Gazelle:sty(y, height):
  if y >= 0 then
    if y < height then
      return y
    end
    return y - height
  end
  return y + height;
end

function Gazelle:tdy(y1, y2, height)

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


function Gazelle:tv()

