require 'torch'


local ContinuousField = torch.class('ContinuousField')

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


function ContinuousField:sty(y, height)
  height = height or self.height
  if y >= 0 then
    if y < height then
      return y
    end
    return height
  end
  return -1.0 -- endzone
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
