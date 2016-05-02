package.path = package.path..";../../?/init.lua"
package.path = package.path..";../../?.lua"



require 'test.serengeti.control'


local iterations = 4000

function main()
	local sim = init()

	local finished = false
	
	while not finished do
		finished = step(iteration)
	end

end


main()