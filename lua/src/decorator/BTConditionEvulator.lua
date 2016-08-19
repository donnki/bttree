--[[
	Evaluates the specified conditional task. If the 
conditional task returns success then the child task 
is run and the child status is returned. If the 
conditional task does not return success then the 
child task is not run and a failure status is immediately 
returned. The conditional task is only evaluated once 
at the start.
--]]
