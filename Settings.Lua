local settings = {
	Global = {
		defendersGroupID = 164096;
		attackersRequired = 0;
		defendersRequired = 0;
		timeLimit = 25*60;
		overtimeEnabled = true;
		tickrate = 128;
		winCodeLength = 8;
		allowAllies = false;
		Allies = {};
		Teams = {
			Attackers = game:GetService("Teams")["Attackers"];
			Defenders = game:GetService("Teams")["Defenders"];
		};
		CapturePoints = {
			workspace:FindFirstChild("Capture Point A");
			workspace:FindFirstChild("Capture Point B");
			workspace:FindFirstChild("Capture Point C");
		};
	};
	CapturePoint = {
		captureDistance = 5;
		increment = 0.025;
		minSize = 1;
		maxSize = 5;
		maxTime = 10;
		rollbackEnabled = true;
		rollbackMultiplier = 3;
	};
}
return settings
