----------------------------------------------------------------
--ToolManager
--Version 2.0
--Last updated 05/11/2020
----------------------------------------------------------------
player = game:GetService("Players").LocalPlayer
actions = game:GetService("ContextActionService")
game:GetService("StarterGui"):SetCoreGuiEnabled('Backpack', false)
local toolEquipped = nil
	
local KeyListener = function(tool,inputState)
	if player.Character and inputState == Enum.UserInputState.Begin then
		local humanoid = player.Character.Humanoid
		if toolEquipped == tool then
			toolEquipped = nil
			humanoid:UnequipTools()
		else
			toolEquipped = tool
			humanoid:EquipTool(player.Backpack[tool])
		end
	end
end

actions:BindAction("Valkyrie",KeyListener,false,Enum.KeyCode.One)
actions:BindAction("Sword",KeyListener,false,Enum.KeyCode.Two)