local BTAction = bt.BTAction
local BTWaitAction = class("BTWaitAction", BTAction)

function BTWaitAction:enter()
	BTAction.enter(self)
	self._duration = 0
	self._endTime = self.database:getBattleValue(self.properties.key)
end

function BTWaitAction:exit()
	BTAction.exit(self)
end

function BTWaitAction:execute(delta)
	self._duration = self._duration + delta
	local result = self._duration < self._endTime and bt.BTResult.Running or bt.BTResult.Ended
	return result
		
end
return BTWaitAction