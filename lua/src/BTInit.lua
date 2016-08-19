bt = {}

json = require("cjson")

bt.BTNode = require("BTNode")
bt.BTAction = require("action.BTAction")
bt.BTPrecondition = require("BTPrecondition")

bt.BT_TREE_NODE = {
	BTCondition 		= "condition.BTCondition",
	
	BTPrioritySelector 	= "composite.BTPrioritySelector",
	BTSequence 			= "composite.BTSequence",
	BTParallel 			= "composite.BTParallel",
	BTParallelFlexible 	= "composite.BTParallelFlexible",

	BTRunAction 		= "action.BTRunAction",
	BTWaitAction 		= "action.BTWaitAction",
}


bt.BTResult = {
	Ended = 1,
	Running = 2,
}
bt.BTActionStatus = {
	Ready = 1,
	Running = 2,
}

--调试日志开关
BTLogEnabled = true
--调试UI开关
BTDrawEnabled = true

function bt.Log(...)
	if BTLogEnabled then
		print("[BTLOG] ", ...)
	end
end


function bt.loadFromJson(path, binder)
	local index = 0
	if io.exists(path) then
        local data = json.decode(io.readfile(path))
        local function loadChild(key)
			if data.nodes[key] then
				local node = data.nodes[key]
				local precondition = nil
				if node.properties.precondition and node.properties.precondition ~= "" then
					if binder and binder[node.properties.precondition] then
						precondition = bt.BTPrecondition.new(node.title, nil, node.properties, handler(binder, binder[node.properties.precondition]))
					else
						bt.Log("Precondition not found: ", node.properties.precondition)
					end
				end
				if bt.BT_TREE_NODE[node.name] then
					local treeNode = require(bt.BT_TREE_NODE[node.name]).new(node.title, precondition, node.properties)
					if node.children then
						for i,child in ipairs(node.children) do
							treeNode:addChild(loadChild(child))
						end
					end
					treeNode.id = index 
					index = index + 1
					treeNode.display = node.display
					return treeNode
				else
					bt.Log("No BTNode: ", node.name)
				end
				
			else
				bt.Log("Key: ", key , " not found!")
			end
		end 
		local root = loadChild(data.root)
		return root
    else
        bt.Log("File: "..path.." not Found!")
    end
end

--Using Cococs2dx to Debug
function bt._genDisplayTree(root, nodeRoot, drawNode, activeDrawNode)
	local node = cc.Node:create()
	node:setPosition(root.display.x, -root.display.y)
	root.display.node = node
	root.display.drawNode = activeDrawNode
	local name = root.name
	local t,t2 = name:find("<.*>")
	if t then
		local key = name:sub(t+1, t2-1)
		name = (name:gsub("<.*>", root.properties[key]))
		-- print(name)
	end

	local text = name.."("..root.id..")\n"
	if root.properties and root.properties.precondition then
		text = text.."前置条件："..root.properties.precondition.."\n"
	end
	
	text = text..root.__cname
	display.newTTFLabel({text=text, size=20}):setTag(1):addTo(node)

	for i,child in ipairs(root.children) do
		bt._genDisplayTree(child, nodeRoot, drawNode, activeDrawNode)
		drawNode:drawLine(cc.p(node:getPosition()), cc.p(child.display.x, -child.display.y), cc.c4f(0,1,1,0.2))
	end
	nodeRoot:addChild(node)
end

--Using Cococs2dx to Debug
function bt.debugDisplayTree(root)
	local nodeRoot = display.newNode()
	local drawNode = cc.DrawNode:create()
	local activeDrawNode = cc.DrawNode:create()
	nodeRoot:addChild(drawNode)
	nodeRoot:addChild(activeDrawNode)
	bt._genDisplayTree(root, nodeRoot, drawNode, activeDrawNode)
	return nodeRoot
end

return bt