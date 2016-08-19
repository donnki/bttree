local BTNode = bt.BTNode
local BTSequence = class("BTSequence", BTNode)

-----------------
-- BTSequence evaluteas the current active child, or the first child (if no active child).
-- 
-- If passed the evaluation, BTSequence ticks the current active child, or the first child (if no active child available),
-- and if it's result is BTEnded, then change the active child to the next one.

-- BTSequence【序列结点】
-- 1) BTSequence评估当前被激活的子结点（若当前无被激活子结点，则评估第一个子结点）
-- 2) 如果当前被激活的子结点评估失败，则BTSequence评估失败
-- 3) 否则执行当前被激活子结点的tick，直至该结点返回Ended，
-- 4) 若BTSequence里的子结点全部执行完毕返回Ended，则BTSequence返回Ended
-- 5) BTSequence开始将下一个子结点设为激活，重新开始第一步评估。
function BTSequence:ctor(name, precondition, properties)
	BTNode.ctor(self, name, precondition, properties)
	self._activeIndex = 0
	self._activeChild = nil
end

function BTSequence:doEvaluate()
	self:debugSetHighlight(true)
	local ret = false

	if self._activeChild then
		ret = self._activeChild:evaluate()
		if not ret then
			self._activeChild:clear()
			self._activeChild = nil
			self._activeIndex = 0
		end
	else
		ret = self.children[1]:evaluate()
	end
	return ret
end

function BTSequence:tick(delta)
	if self._activeChild == nil then
		self._activeIndex = 1
		self._activeChild = self.children[1]
	end

	local result = self._activeChild:tick(delta)
	if result == bt.BTResult.Ended then
		self._activeIndex = self._activeIndex + 1
		if self._activeIndex > #self.children then
			self._activeChild:clear()
			self._activeChild = nil
			self._activeIndex = 0
		else
			self._activeChild:clear()
			self._activeChild = self.children[self._activeIndex]
			result = bt.BTResult.Running
		end
	end
	self:debugDrawLineTo(self.children, self._activeIndex)
	-- self:debugByID(14, "~~~~~", result)
	return result
end

function BTSequence:clear()
	if self._activeChild then
		self._activeChild = nil
		self._activeIndex = 0
	end

	for k,v in ipairs(self.children) do
		v:clear()
	end
	self:debugSetHighlight(false)
end
return BTSequence