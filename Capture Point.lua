----------------------------------------------------------------
--CapturePointScript
--Version 3.0
--Last updated 05/10/2020
----------------------------------------------------------------
local point = script.Parent
local properties = point.Properties
local official = game:GetService("ReplicatedStorage").Official
local settings = require(game:GetService("ReplicatedStorage").Settings)
local owner, controller = nil
local owned = false

local CheckOwnership = function(size)
	if size == settings.CapturePoint.maxSize then
		owned = true
	else
		owned = false
		if size == settings.CapturePoint.minSize then
			owner = controller
			point.BrickColor = owner.TeamColor
		end
	end
end

local GetPlayersNearPosition = function(position)
	local nearbyPlayers = {[settings.Global.Teams.Attackers.Name] = {}, [settings.Global.Teams.Defenders.Name] = {}}
	local playerList = game:GetService("Players"):GetPlayers()
	table.foreach(playerList,function(i)
		local player = playerList[i]
		if player.Character then
			if player:DistanceFromCharacter(position) < settings.CapturePoint.captureDistance and player.Character.Humanoid.Health > 0 then
				table.insert(nearbyPlayers[player.Team.Name],player)
			end
		end
	end)
	return nearbyPlayers
end

local GetControllingTeam = function(nearbyPlayers)
	local attackers = table.getn(nearbyPlayers[settings.Global.Teams.Attackers.Name])
	local defenders = table.getn(nearbyPlayers[settings.Global.Teams.Defenders.Name])
	if attackers > defenders then
		return settings.Global.Teams.Attackers
	elseif defenders > attackers then
		return settings.Global.Teams.Defenders
	else
		return nil
	end
end

local ResizePoint = function(multiplier,size)
	local increment
	if controller then
		local maxIncrementNegative, maxIncrementPositive = math.abs(settings.CapturePoint.minSize - size), math.abs(settings.CapturePoint.maxSize - size)
		if owner == controller then
			if settings.CapturePoint.increment*multiplier > maxIncrementPositive then
				increment = maxIncrementPositive
			else
				increment = settings.CapturePoint.increment*multiplier
			end
		else
			if settings.CapturePoint.increment*multiplier > maxIncrementNegative then
				increment = -maxIncrementNegative
			else
				increment = -settings.CapturePoint.increment*multiplier
			end
		end
	else
		increment = 0
	end
	point.Size = Vector3.new(point.Size.X,point.Size.Y + increment, point.Size.Z + increment)
end

local UpdateProperties = function()
	properties.Owner.Value = owner
	properties.Owned.Value = owned
	properties.Controller.Value = controller
	properties.Size.Value = point.Size.Y
end

local Main = function()
	while official.Value and not properties.Captured.Value do
		local nearbyPlayers = GetPlayersNearPosition(point.Position)
		controller = GetControllingTeam(nearbyPlayers)
		if controller then
			ResizePoint(table.getn(nearbyPlayers[controller.Name]),point.Size.Y)
			CheckOwnership(point.Size.Y)
		end
		UpdateProperties()
		wait(1/settings.Global.tickrate)
	end
end

official.Changed:Connect(Main)