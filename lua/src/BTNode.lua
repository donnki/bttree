local BTNode = class("BTNode")

function BTNode:ctor(name, precondition, properties)
	self.name = name
	self.precondition = precondition
	self.properties = properties
	self.children = {}
	self.interval = 0
	self.lastTimeEvaluated = 0
	self.activated = false
	self.database = nil
	self.tmp = 0

end

function BTNode:activate(database)
	if self.activated then
		return
	end

	self.database = database
	if self.precondition then
		self.precondition:activate(database)
	end
	if #self.children > 0 then
		for k,child in ipairs(self.children) do
			child:activate(database)
		end
	end
	self.activated = true
end

function BTNode:doEvaluate()
	return true
end

function BTNode:evaluate()
	local coolDownOK = self:_checkTimer()
	local ret = self.activated and coolDownOK and 
		(self.precondition == nil or self.precondition:check()) and self:doEvaluate()
	
	return ret
end

function BTNode:tick(delta)
	return bt.BTResult.Ended
end

function BTNode:clear()
end

function BTNode:addChild(node)
	if node then
		table.insert(self.children, node)
	end
end

function BTNode:removeChild(node)
	if node then
		for k,v in ipairs(self.children) do
			if v == node then
				table.remove(self.children, k)
				return v
			end
		end
	end
end

function BTNode:_checkTimer()
	return true
end

function BTNode:debugClearDrawNode()
	if BTDrawEnabled and self.display.drawNode then
		self.display.drawNode:clear()
	end
end

function BTNode:debugDrawLineTo(nodes, index)
	if BTDrawEnabled and self.display.drawNode then
		if not index then index = #nodes end
		for i=1,index do
			local v = nodes[i]
			self.display.drawNode:drawLine(cc.p(self.display.node:getPosition()), cc.p(v.display.node:getPosition()), cc.c4f(0,1,0,0.4))
		end
	end
end

function BTNode:debugSetHighlight(flag)
	-- print(self.__cname, self.display.node)
	if BTDrawEnabled and self.display.node then
		if flag then
			self.display.node:getChildByTag(1):setColor(cc.c3b(0,255,0))
		else
			self.display.node:getChildByTag(1):setColor(cc.c3b(255,255,255))
		end
	end
end

function BTNode:debugByID(id, ...)
	if self.id == id then
		self.tmp = self.tmp + 1
		print(self.tmp, ...)
	end
end
return BTNode

