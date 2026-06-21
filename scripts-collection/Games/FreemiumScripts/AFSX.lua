--[[
- Npc Teleports
- Area Teleports
- Farm Power
- Farm Chickra 
- Farm Durablity 
- Farm Sword 
- Auto Start Quests 
- Smart Power Farm (Go To Zones With Multis)
- Fruit ESP 
- Fruit Farm 
- Fruit Notifier 
- Farm Players 
- Auto Roll Champions 
- Crate Farm ( Done ) 
- Mobs Farm ( Done ) 
- Kill Aura ( Done )
- Inf Stamina ( Done )
- Farm All Stats At Once
- Auto Claim Achievements ( Done )
- Areas ESP
- Auto Upgrade Stats
- Redeem All Codes ( Done ) Auto Updates btw 
]]
local Players = game:GetService("Players")
local rs = game:GetService("RunService")
local lp = Players.LocalPlayer
local Characters = workspace.Scriptable.Mobs

function removeNumbersFromString(inputStr)
	local result = inputStr:gsub("%d+", "")
	return result
end
function renameMob(originalMobName)
	local newMobName = removeNumbersFromString(originalMobName)
	return newMobName
end
function UpdateMobs()
	for i, v in pairs(Characters:GetChildren()) do
		if v:IsA("Model") then
			local originalMobName = v.Name
			local renamedMobName = renameMob(originalMobName)
			v.Name = renamedMobName
		end
	end
end

UpdateMobs()
Characters.ChildAdded:Connect(UpdateMobs)

local Library = loadstring(
	game:HttpGet("https://raw.githubusercontent.com/Bebo-Mods/Scripts/master/YouWontDoAnythingWithThat.lua")
)()
local SelectedMob
local mobs = {}
local CurrentMob
local Distance

for i, v in next, Characters:GetChildren() do
	table.insert(mobs, v.Name)
end

function RemoveTableDupes(tab)
	local hash = {}
	local res = {}
	for _, v in ipairs(tab) do
		if not hash[v] then
			res[#res + 1] = v
			hash[v] = true
		end
	end
	return res
end

mobs = RemoveTableDupes(mobs)

table.sort(mobs, function(a, b)
	return a < b
end)
local function noclip()
	for i, v in pairs(lp.Character:GetChildren()) do
		if v:IsA("BasePart") and v.CanCollide == true then
			v.CanCollide = false
			lp.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
		end
	end
end
function Addtosring(inputStr)
	local number = inputStr:match("(%d+)$")
	if number then
		local result = inputStr:gsub(number .. "$", "_" .. number)
		return result
	else
		return inputStr
	end
end
local Window = Library:Create({
	ToggleKey = Enum.KeyCode.Insert,
})

-- Tab
local Tab = Window:Tab({
	Name = "Anime Fighting Simulator",
	Description = "Codexus Hub",
	Icon = "rbxassetid://11254763826", -- Tab Icon
	Color = Color3.new(0.811765, 0.313725, 0.247059), -- Tab Colour
	Hidden = false, -- IGNORE THIS
})
Tab:Dropdown({
	Name = "Select Mob",
	Items = mobs, -- Table
	Callback = function(Mob)
		SelectedMob = Mob
	end,
})
Tab:Slider({
	Name = "Mob Distance",
	Min = 1, -- Min Val
	Max = 8, -- Max Val
	Default = 5, -- Default Val
	Callback = function(DSSA)
		Distance = DSSA
	end,
})

local FarmSelected

Tab:Toggle({
	Name = "Farm Mob",
	Default = false,
	Callback = function(state1)
		if state1 then
			FarmSelected = rs.Heartbeat:Connect(function()
				if
					not CurrentMob
					or not CurrentMob:FindFirstChild("Humanoid")
					or CurrentMob:FindFirstChild("Humanoid").Health == 0
					or not CurrentMob:FindFirstChild("HumanoidRootPart")
				then
					CurrentMob = nil
					local Mobs = Characters:GetChildren()
					for i = 1, #Mobs do
						local v = Mobs[i]
						if
							v.Name == SelectedMob
							and v.Humanoid.Health > 0
							and v:FindFirstChild("HumanoidRootPart")
							and lp.Character
						then
							CurrentMob = v
							break
						end
					end
				end

				if CurrentMob then
					noclip()
					lp.Character.HumanoidRootPart.CFrame = CurrentMob.HumanoidRootPart.CFrame
							* CFrame.Angles(math.rad(90), 0, 0)
						+ Vector3.new(0, -Distance, 0)
					game:GetService("ReplicatedStorage").Events["Stats/RemoteFunction"]
						:InvokeServer("TrainStat", "Strength")
				end
			end)
		else
			if FarmSelected then
				FarmSelected:Disconnect()
			end
		end
	end,
})

Tab:Button({
	Name = "Inf Stamina",
	Callback = function()
		game:GetService("ReplicatedStorage").Events["Stamina/RemoteEvent"]:FireServer("Use", 0 / 0)
	end,
})
local FarmCrates
Tab:Toggle({
	Name = "Farm Crates",
	Default = false,
	Callback = function(state12)
		if state12 then
			FarmCrates = rs.Heartbeat:Connect(function()
				local rareCrate = nil
				for _, v in pairs(workspace.Scriptable.Crates:GetChildren()) do
					if v.Name == "rare" then
						rareCrate = v
						break
					end
				end
				if rareCrate then
					lp.Character.PrimaryPart.CFrame = rareCrate:GetPivot()
				else
					for _, v in pairs(workspace.Scriptable.Crates:GetChildren()) do
						lp.Character.PrimaryPart.CFrame = v:GetPivot()
					end
				end
				game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
			end)
		else
			if FarmCrates then
				FarmCrates:Disconnect()
			end
		end
	end,
})
local ClaimAchievements
Tab:Toggle({
	Name = "Auto Claim Achievements",
	Default = false,
	Callback = function(ClaimAchievements2)
		if ClaimAchievements2 then
			ClaimAchievements = rs.Heartbeat:Connect(function()
				for i, v in
					pairs(
						game:GetService("Players").LocalPlayer.PlayerGui.Menu.PagesContainer.Achievements.container.Content["1"]
							:GetChildren()
					)
				do
					if v:FindFirstChildOfClass("ImageButton") then
						game:GetService("ReplicatedStorage").Events["Achievements/RemoteEvent"]
							:FireServer("ClaimAchievement", Addtosring(v.Name))
						break
					end
				end
				task.wait(2)
			end)
		else
			if ClaimAchievements then
				ClaimAchievements:Disconnect()
			end
		end
	end,
})
local Codes = {}

Tab:Button({
	Name = "Redeem All Codes",
	Callback = function()
		pcall(function()
			local Url = "https://www.thegamer.com/roblox-anime-fighting-simulator-x-codes/"
			local Body = game:HttpGet(Url):gsub("%s", "")
			local Range = Body:find("AllAnimeFightingSimulatorXCodes</h2>")
			local NewBody = Body:sub(Range, Range + 1000)

			for Code in string.gmatch(NewBody, "<strong>[%w]+%p*</strong>") do
				Code = Code:gsub("<strong>", ""):gsub("</strong>", "")
				if Code ~= "Active" and Code ~= "Expired" then
					table.insert(Codes, Code)
				end
			end
		end)

		for i, code in ipairs(Codes) do
			game:GetService("ReplicatedStorage").Events["Codes/RemoteFunction"]:InvokeServer("Redeem", code)
			task.wait(1)
		end
	end,
})
