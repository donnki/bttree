local BTNode = bt.BTNode
local BTAction = class("BTAction", BTNode)

function BTAction:ctor(name, precondition, properties)
	BTNode.ctor(self, name, precondition, properties)
	self._status = bt.BTActionStatus.Ready
end

function BTAction:enter()
	bt.Log(self.database.__cname.." On enter action: ", self.name)
	self:debugSetHighlight(true)
end

function BTAction:exit()
	bt.Log(self.database.__cname.." On exit action: ", self.name)
	self:debugSetHighlight(false)
end

function BTAction:execute(delta)

	return bt.BTResult.Ended
end

function BTAction:clear()
	if self._status ~=  bt.BTActionStatus.Ready then
		self:exit()
		self._status = bt.BTActionStatus.Ready
	end
end

function BTAction:tick(delta)
	local result = bt.BTResult.Ended
	if self._status == bt.BTActionStatus.Ready then
		self:enter()
		self._status = bt.BTActionStatus.Running
	end

	if self._status == bt.BTActionStatus.Running then
		result = self:execute(delta)
		if result ~= bt.BTResult.Running then
			self:exit()
			self._status = bt.BTActionStatus.Ready
		end
	end
	return result
end

function BTAction:addChild(node)
	bt.Log("ERROR: BTAction: Cannot add a node into BTAction..")
end

function BTAction:removeChild(node)
	bt.Log("ERROR: BTAction: Cannot remove a node into BTAction.")
end
return BTAction