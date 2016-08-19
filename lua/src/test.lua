require("global")
require("BTInit")

--init btroot
local btroot
function init()
	local binder = {isUnderControl=function()return true end,targetValid=function()return true end,notAimed=function()return true end,isBeforeAttack=function()return true end,isAfterAttack=function()return true end,targetNotValid=function()return true end}
	btroot = bt.loadFromJson("../../examples/ai.json", binder)
	btroot:activate(binder)
end

--tick per frame 
function update(dt)
	if btroot:evaluate() then
        btroot:tick(dt)
    end
end

init()
update()