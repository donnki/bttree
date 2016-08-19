local BTNode = bt.BTNode
local BTPrioritySelector = class("BTPrioritySelector", BTNode)

-----------------
-- BTPrioritySelector【优先选择结点】
-- 按优先顺序开始评估子结点，当某个子结点评估失败时，才开始评估下一个子结点
-- 一旦某个子结点评估成功，则BTPrioritySelector评估成功，并开始执行该子结点的tick，
-- 直至该子结点返回Ended时，BTPrioritySelector返回Ended。

-- 若无任何子结点评估成成，则BTPrioritySelector评估失败。
-- 注意：先加入（排在上面）的子结点顺序优先级更高。
function BTPrioritySelector:ctor(name, precondition, properties)
	BTNode.ctor(self, name,  precondition, properties)
	self._activeChild = nil
end

function BTPrioritySelector:doEvaluate()
	self:debugClearDrawNode()
	self:debugSetHighlight(true)
	for k,v in ipairs(self.children) do
		if v:evaluate() then
			if self._activeChild ~= nil and self._activeChild ~= v then
				self._activeChild:clear()
			end
			self._activeChild = v
			return true
		end
	end

	if self._activeChild then
		self._activeChild:clear()
		self._activeChild = nil
	end
	return false
end

function BTPrioritySelector:clear()
	if self._activeChild then
		self._activeChild:clear()
		self._activeChild = nil
	end
	self:debugSetHighlight(false)
end
function BTPrioritySelector:tick(delta)
	if not self._activeChild then
		return bt.BTResult.Ended
	end
	self:debugDrawLineTo({self._activeChild})
	local result = self._activeChild:tick(delta)
	if result ~= bt.BTResult.Running then
		self._activeChild:clear()
		self._activeChild = nil
	end
	
	return result
end

return BTPrioritySelector