local Climb = {}

Climb.matrix = {{10,-30,4},{-30,7,6},{0,0,5}}

function Climb:step(actionOne, actionTwo)
	local terminated = true
	local reward = self.matrix[actionOne][actionTwo]
	return reward, terminated
end



return Climb