local BTNode = bt.BTNode
local BTPrecondition = class("BTPrecondition", BTNode)

function BTPrecondition:ctor(name, precondition, properties, func)
	BTNode.ctor(self, name, precondition, properties)

	self.func = func
end

function BTPrecondition:check()
	if self.func then
		return self.func()
	end
	return true
end

function BTPrecondition:tick(delta)
	local t = self:check()
	if t then
		return bt.BTResult.Ended
	else
		return bt.BTResult.Running
	end
end

return BTPrecondition