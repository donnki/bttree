--[[ 
	The inverter task will invert the return value of the 
 child task after it has finished executing. 
 	If the child returns success, the inverter task will 
 return failure. If the child returns failure, the 
 inverter task will return success.
--]]