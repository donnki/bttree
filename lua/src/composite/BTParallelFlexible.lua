local BTParallelFlexible = class("BTParallelFlexible", BTNode)

------------------
-- BTParallelFlexible evaluates all children, if all children fails evaluation, it fails. 
-- Any child passes the evaluation will be regarded as active.
-- BTParallelFlexible ticks all active children, if all children ends, it ends.
-- NOTE: Order of child node added does matter!

-- BTParallelFlexible【松散检查并行结点】
-- BTParallelFlexible和BTParallel有点类似，它会评估所有子结点，
-- 只要其中一个子结点评估成功，则BTParallelFlexible评估成功
-- 所有评估成功的子结点才会执行tick。
-- 当所有子结点返回Ended时，BTParallelFlexible返回Ended
function BTParallelFlexible:ctor(name, precondition, properties)
	BTNode.ctor(self, name, precondition, properties)
	
	self._activeList = {}
end

function BTParallelFlexible:doEvaluate()
	local numActiveChildren = 0
	for i,child in ipairs(self.children) do
		if child:evaluate() then
			self._activeList[i] = true
			numActiveChildren = numActiveChildren + 1
		else
			self._activeList[i] = false
		end
	end
	if numActiveChildren == 0 then
		return false
	end
	return true
end

function BTParallelFlexible:tick(delta)
	self:debugSetHighlight(true)
	local numActiveChildren = 0
	for i,child in ipairs(self.children) do
		local active = self._activeList[i]
		if active then
			local result = child:tick(delta)
			if result == bt.BTResult.Running then
				numActiveChildren = numActiveChildren + 1
			end
		end
	end
	if numActiveChildren == 0 then
		return bt.BTResult.Ended
	end
	self:debugDrawLineTo(self.children)
	return bt.BTResult.Running
end

function BTParallelFlexible:clear()
	for k,v in ipairs(self.children) do
		v:clear()
	end
	self:debugSetHighlight(false)
end

function BTParallelFlexible:addChild(node)
	BTNode.addChild(self, node)
	table.insert(self._activeList, false)
end

function BTParallelFlexible:removeChild(node)
	local index = BTNode.removeChild(self, node)
	table.remove(self._activeList, index)
end

return BTParallelFlexible
