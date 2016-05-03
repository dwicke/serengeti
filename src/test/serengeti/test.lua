package.path = package.path..";../../?/init.lua"
package.path = package.path..";../../?.lua"



require 'test.serengeti.control'


local iterations = 4000
local sampleSize = 10
function main()
	local sim = init(4, 10)

	local finished = false
	
	while not finished do
		finished = step(iterations, sampleSize)
	end

end


main()
