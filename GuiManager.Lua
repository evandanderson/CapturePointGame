----------------------------------------------------------------
--GuiScript
--Version 1.12
--Last updated 05/12/2020
----------------------------------------------------------------
player = game:GetService("Players").LocalPlayer
replicated = game:GetService("ReplicatedStorage")
local settings = require(game:GetService("ReplicatedStorage").Settings)
local capturePoints = settings.Global.CapturePoints
game:GetService("StarterGui"):SetCoreGuiEnabled("Health", false)
	
local UpdateGui = function(data)
	if player:FindFirstChild("PlayerGui") then
		if player.PlayerGui:FindFirstChild("ScreenGui") then
			local gui = player.PlayerGui.ScreenGui
			if data.Function == "CapturePoint" then
				if data.Property == "Time" then
					local size = UDim2.new(data.Value/settings.CapturePoint.maxTime,0,gui[data.Point.Name].Sliders.Time.Size.Y.Scale,0)
					gui[data.Point.Name].Sliders.Time:TweenSize(size,"Out","Quad",.5,true)
					local position = UDim2.new(data.Value/settings.CapturePoint.maxTime,0,gui[data.Point.Name].Sliders.Timer.Position.Y.Scale,0)
					gui[data.Point.Name].Sliders.Timer:TweenPosition(position,"Out","Quad",.5,true)
					local minutes = math.floor(data.Value/60)
					local seconds = data.Value-(minutes*60) --if <60 thgebn
					if seconds < 10 then
						seconds = "0"..seconds
					end
					gui[data.Point.Name].Sliders.Timer.Time.Text = minutes..":"..seconds
				elseif data.Property == "Size" then
					local size = UDim2.new((data.Value-settings.CapturePoint.minSize)/(settings.CapturePoint.maxSize-settings.CapturePoint.minSize),0,gui[data.Point.Name].Sliders.Owner.Size.Y.Scale,0)
					gui[data.Point.Name].Sliders.Owner:TweenSize(size,"Out","Linear",0.1,true)
				elseif data.Property == "Controller" then
					if data.Value then
						gui[data.Point.Name].Letter.BackgroundColor3 = data.Value.TeamColor.Color
						gui[data.Point.Name].Letter.BackgroundTransparency = 0
					else
						gui[data.Point.Name].Letter.BackgroundColor3 = Color3.new(255,255,255)
						gui[data.Point.Name].Letter.BackgroundTransparency = 1
					end
				elseif data.Property == "Owner" and data.Value then
					gui[data.Point.Name].Sliders.Time.BackgroundColor3 = data.Value.TeamColor.Color
					gui[data.Point.Name].Sliders.Owner.BackgroundColor3 = data.Value.TeamColor.Color
				elseif data.Property == "Captured" then
					gui[data.Point.Name].BackgroundColor3 = gui[data.Point.Name].Sliders.Owner.BackgroundColor3
					gui[data.Point.Name].Sliders.Owner.Size = UDim2.new(0,0,0,0)
					gui[data.Point.Name].Letter.BackgroundTransparency = 1
				end
			elseif data.Function == "Official" then
				if data.Value then
					gui.ServerStatus.Text = "official"
					gui.ServerCode.Text = "server: "..replicated.ServerCode.Value
					gui.ServerCode.Visible = true
				else
					gui.ServerStatus.Text = "unofficial"
					gui.ServerCode.Visible = false
				end
			elseif data.Function == "ServerTime" then
				local minutes = math.floor(data.Value/60)
				local seconds = data.Value-(minutes*60)
				if seconds < 10 then
					seconds = "0"..seconds
				end
				gui.ServerTimer.Text = minutes..":"..seconds
			elseif data.Function == "Show" then
				gui[data.Element.Name].Sliders.Timer.Visible = data.Value
			elseif data.Function == "Health" then
				gui.Health.Health.Text = math.ceil(data.Value)
				gui.Health.Bar:TweenSize(UDim2.new(data.Value/100,0,gui.Health.Bar.Size.Y.Scale,0),"Out","Quad",0.5,true)
				gui.Health.Bar.BackgroundColor3 = Color3.fromRGB(255-math.floor((data.Value/100)*255),math.floor((data.Value/100)*255),0)
			end
		end
	end
end

local BindProperties = function()
	table.foreach(capturePoints,function(i)
		print("Binding Changed event for all properties of "..capturePoints[i].Name)
		local properties = capturePoints[i].Point.Properties:GetChildren()
		table.foreach(properties,function(x)
			properties[x].Changed:Connect(function(value)
				UpdateGui({["Function"] = "CapturePoint",["Point"] = capturePoints[i],["Property"] = properties[x].Name,["Value"] = value;})
			end)
		end)
	end)
end

local BindTimeEvent = function()
	print("Binding Changed event for Time")
	replicated.Time.Changed:Connect(function(value)
		UpdateGui({["Function"] = "ServerTime",["Value"] = value})
	end)
end

local BindOfficialEvent = function()
	print("Binding Changed event for Official")
	replicated.Official.Changed:Connect(function(value)
		UpdateGui({["Function"] = "Official",["Value"] = value})
	end)
end

local BindHoverEvent = function()
	if player:FindFirstChild("PlayerGui") then
		if player.PlayerGui:FindFirstChild("ScreenGui") then
			local gui = player.PlayerGui.ScreenGui
			local elements = gui:GetChildren()
			table.foreach(elements,function(i)
				if string.sub(elements[i].Name,1,13) == "Capture Point" then
					print("Binding Hover event for "..elements[i].Name)
					elements[i].MouseEnter:Connect(function()
						UpdateGui({["Function"] = "Show",["Element"] = elements[i],["Value"] = true})
					end)
					elements[i].MouseLeave:Connect(function()
						UpdateGui({["Function"] = "Show",["Element"] = elements[i],["Value"] = false})
					end)
				end
			end)
		end
	end
end

BindHealthEvent = function()
	print("Binding Health event for "..player.Name)
	player.Character:WaitForChild("Humanoid").HealthChanged:Connect(function(health)
		UpdateGui({["Function"] = "Health",["Value"] = health})
	end)
end

BindProperties()
BindTimeEvent()
BindOfficialEvent()
BindHoverEvent()
BindHealthEvent()
UpdateGui({["Function"] = "Health",["Value"] = 100})
UpdateGui({["Function"] = "Official",["Value"] = replicated.Official.Value})