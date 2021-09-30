----------------------------------------------------------------
--MainScript
--Version 2.0
--Last updated 05/11/2020
----------------------------------------------------------------
local players = game:GetService("Players")
local replicated = game:GetService("ReplicatedStorage")
local settings = require(replicated.Settings)
local official = replicated.Official
local timer = replicated.Time
local serverWon = false
local pointsCaptured = 0
local serverCode = ""
local capturePoints = settings.Global.CapturePoints

local KickAllPlayers = function(message)
	for i, player in pairs(players:GetPlayers()) do
		print("Kicking "..player.Name)
		player:Kick(message)
	end
end

local RespawnAllPlayers = function()
	for i, player in pairs(players:GetPlayers()) do
		print("Respawning "..player.Name)
		player:LoadCharacter()
	end
end

local CheckIfAlly = function(player)
	print("Checking if "..player.Name.." is an ally")
	table.foreach(settings.Global.Allies,function(i)
		if player:IsInGroup(settings.Global.Allies[i]) then
			return true
		end
	end)
	return false
end

local AssignTeam = function(player)
	if player:IsInGroup(settings.Global.defendersGroupID) or (settings.Global.allowAllies and CheckIfAlly(player)) then
		player.Team = settings.Global.Teams.Defenders
		print("Successfully assigned "..player.Name.." to "..player.Team.Name)
	else
		player.Team = settings.Global.Teams.Attackers
		print("Successfully assigned "..player.Name.." to "..player.Team.Name)
	end
end

local GenerateServerCode = function()
	local numbers = {0,1,2,3,4,5,6,7,8,9}
	local letters = "abcdefghijklmnopqrstuvwxyz"
	for i = 1, settings.Global.winCodeLength do
		local bool = math.random(0,1)
		if bool == 0 then
			local random = math.random(1,10)
			serverCode = serverCode..numbers[random]
		else
			local random = math.random(1,26)
			serverCode = serverCode..(string.sub(letters,random,random))
		end
	end
	replicated.ServerCode.Value = serverCode
end

local Win = function(team)
	serverWon, official.Value = true,false
	print(team.Name.." won. Win code: "..serverCode)
	wait(5)
	KickAllPlayers(team.Name.." won. Win code: "..serverCode)
end

local Capture = function(point)
	print(point.name.." has been captured by "..settings.Global.Teams.Attackers.Name)
	pointsCaptured = pointsCaptured + 1
	if pointsCaptured == table.getn(capturePoints) then
		Win(settings.Global.Teams.Attackers)
	end
end

local StartRaid = function()
	print("Server is now official")
	official.Value = true
	table.foreach(capturePoints,function(i)
		capturePoints[i].Point.Properties.Time.Value = settings.CapturePoint.maxTime
		capturePoints[i].Point.Properties.Size.Value = capturePoints[i].Point.Size.Y
	end)
	timer.Value = settings.Global.timeLimit
	RespawnAllPlayers()
	repeat
		timer.Value = timer.Value - 1
		if timer.Value == 0 then
			if settings.Global.overtimeEnabled then
				print("Overtime is enabled on this server, starting overtime")
				repeat
					local pointsRemaining = 0
					table.foreach(capturePoints,function(i)
						if not capturePoints[i].Point.Properties.Captured.Value then
							if not (capturePoints[i].Point.Properties.Owner.Value == settings.Global.Teams.Defenders and capturePoints[i].Point.Properties.Owned.Value) then
								pointsRemaining = pointsRemaining + 1
							end
						end
					end)
					wait(1/settings.Global.tickrate)
				until
					pointsRemaining == 0 or serverWon
				if not serverWon then
					Win(settings.Global.Teams.Defenders)
				end
			else
				print("Overtime is not enabled on this server")
				Win(settings.Global.Teams.Defenders)
			end
		end
		wait(1)
	until
		serverWon
end

local CheckForOfficialStatus = function()
	print("Checking if server is official")
	local attackers = table.getn(settings.Global.Teams.Attackers:GetPlayers())
	local defenders = table.getn(settings.Global.Teams.Defenders:GetPlayers())
	if attackers >= settings.Global.attackersRequired and defenders >= settings.Global.defendersRequired then
		StartRaid()
	end
end

local InitializePoints = function(setting)
	print("Initializing capture points")
	table.foreach(capturePoints,function(i)
		local properties = capturePoints[i].Point.Properties:GetChildren()
		table.foreach(properties,function(x)
			if properties[x].Name == "Captured" then
				print("Binding Changed event for "..properties[x].Name.."property on "..capturePoints[i].Name)
				properties[x].Changed:Connect(function(value)
					Capture(capturePoints[i])
				end)
			end
		end)
	end)
end

players.PlayerAdded:connect(function(player)
	print(player.Name.." has joined the server")
	player.Changed:Connect(function(property)
		if property == "Team" and not official.Value and not serverWon then
			CheckForOfficialStatus()
		end
	end)
	AssignTeam(player)
end)

InitializePoints()
GenerateServerCode()