----------------------------------------------------------------
--Timer
--Version 2.01
--Last updated 05/10/2020
----------------------------------------------------------------
local point = script.Parent
local properties = point.Properties
local settings = require(game:GetService("ReplicatedStorage").Settings)
local official = game:GetService("ReplicatedStorage").Official
local active = false

properties.Owned.Changed:Connect(function(owned)
	if owned and not active then
		active = true
		local addTime
		if properties.Owner.Value == settings.Global.Teams.Attackers then
			addTime = -1
		elseif properties.Owner.Value == settings.Global.Teams.Defenders then
			if settings.CapturePoint.rollbackEnabled then
				addTime = settings.CapturePoint.rollbackMultiplier
			else
				addTime = settings.CapturePoint.maxTime
			end
		end
		repeat
			if properties.Time.Value + addTime > settings.CapturePoint.maxTime then
				properties.Time.Value = settings.CapturePoint.maxTime
			else
				properties.Time.Value = properties.Time.Value + addTime
				if properties.Time.Value == 0 then
					properties.Captured.Value = true
					active = false
				end
			end
			wait(1)
		until
			not active or not official.Value
	end
end)

properties.Owner.Changed:Connect(function()
	active = false
end)