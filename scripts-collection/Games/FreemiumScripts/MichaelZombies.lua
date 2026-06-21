--- Gets the executor's Request function.
--- @return function Returns a client able to issue HttpRequest, which takes in an HttpRequest table as a parameter; UNC Spec -> https://github.com/unified-naming-convention/NamingStandard/blob/main/api/misc.md#request
function GetRequestFunction()
	return request or (syn and syn.request) or (http and http.request) or http_request
end

--- Gets the body of an HttpRequest using GetRequestFunction() as the HttpClient.
--- @return string A String that is the body of the HttpResponse
function GetRequestBodyFromUrl(urlLink)
	local req = GetRequestFunction()

	if req then
		local resp = req({ Url = urlLink, Method = "GET" })
		if resp.Success then
			return resp.Body
		else
			return game:HttpGet(urlLink)
		end
	elseif pcall(function()
		return game.HttpGet
	end) then
		print("Using Deprecated Request method")
		return game:HttpGet(urlLink)
	else
		error("CANNOT PERFORM REQUEST!!!")
	end
end
--- @return boolean Returns a boolean that signifies if the script is obfuscated by either Luraph or 77Obfuscator
function IsScriptObfuscated()
	return (_77Crash or LPH_OBFUSCATED)
end

-- Services
-- Player Service.
local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Local player reference from PlayerService
local LocalPlayer = PlayerService.LocalPlayer
-- Local player character.
local LocalPlayerCharacter = LocalPlayer.Character

-- Connections, to keep state correctly.

-- Update the character if the player, for example, DIES!
LocalPlayer.CharacterAdded:Connect(function(char)
	WaitNextHeartBeat() -- Character may not be ready right away...
	LocalPlayerCharacter = char
end)

local function Noclip()
	for i, v in pairs(LocalPlayerCharacter:GetDescendants()) do
		if v:IsA("BasePart") and v.CanCollide == true then
			v.CanCollide = false
			LocalPlayerCharacter.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
		end
	end
end

function FreezeLocalPlayerCharacter()
	local nofall = LocalPlayerCharacter.HumanoidRootPart:FindFirstChild("FREEZED_CHAR")
	if nofall then
		return nofall
	end
	nofall = Instance.new("BodyVelocity", LocalPlayerCharacter.HumanoidRootPart)
	nofall.Name = "FREEZED_CHAR"
	nofall.Velocity = Vector3.new(0, 0, 0)
	return nofall
end

function UnfreezeLocalPlayerCharacter()
	local nofallObj = LocalPlayerCharacter:FindFirstChild("HumanoidRootPart"):FindFirstChild("FREEZED_CHAR")
	if not nofallObj then
		return false
	end
	nofallObj:Destroy()
	return true
end

function TweenToObject(object, speed, offset)
	if not offset then
		offset = Vector3.new(0, -3, 0)
	end
	local info = TweenInfo.new(
		(LocalPlayerCharacter.HumanoidRootPart.Position - object.CFrame.Position).Magnitude / speed,
		Enum.EasingStyle.Linear
	)
	local tween = TweenService:Create(LocalPlayerCharacter.HumanoidRootPart, info, { CFrame = object.CFrame + offset })
	local nofall
	local noclipConnection

	if UnfreezeLocalPlayerCharacter() then
		nofall = FreezeLocalPlayerCharacter()
	end

	noclipConnection = game:GetService("RunService").Stepped:Connect(Noclip)
	tween:Play()

	tween.Completed:Connect(function()
		UnfreezeLocalPlayerCharacter()
		noclipConnection:Disconnect()
	end)
	return tween
end

function TweenToPostion(cframe, speed, offset)
	if not offset then
		offset = Vector3.new(0, 3, 0)
	end

	local info = TweenInfo.new(
		(LocalPlayerCharacter.HumanoidRootPart.Position - cframe.Position).Magnitude / speed,
		Enum.EasingStyle.Linear
	)
	local tween = TweenService:Create(LocalPlayerCharacter.HumanoidRootPart, info, { CFrame = cframe + offset })
	local nofall
	local noclipConnection

	if UnfreezeLocalPlayerCharacter() then
		nofall = FreezeLocalPlayerCharacter()
	end

	noclipConnection = game:GetService("RunService").Stepped:Connect(Noclip)
	tween:Play()

	tween.Completed:Connect(function()
		UnfreezeLocalPlayerCharacter()
		noclipConnection:Disconnect()
	end)
	return tween
end

function WaitNextHeartBeat()
	return RunService.Heartbeat:Wait()
end

-- Library
local Library = loadstring(
	GetRequestBodyFromUrl("https://raw.githubusercontent.com/Bebo-Mods/Scripts/master/YouWontDoAnythingWithThat.lua")
)()

-- Window
local Window = Library:Create({ ToggleKey = Enum.KeyCode.Insert })
function CreatePlayerTab(window)
	-- Tab
	local PlayerTab = window:Tab({
		Name = "Player",
		Description = "Modifications to the player",
		Icon = "rbxassetid://6031215978", -- Tab Icon
		Color = Color3.new(0.811765, 0.313725, 0.247059), -- Tab Colour
		Hidden = false, -- IGNORE THIS
	})

	-- #region Knife Aura

	local knifeAuraDistance = 15 -- Stub value for Kinfe Aura

	PlayerTab:Slider({
		Name = "Knife Aura Distance",
		Min = 5,
		Max = 32,
		Default = 15,
		Callback = function(sliderValue)
			knifeAuraDistance = sliderValue
		end,
	})

	--- @type thread | nil
	local knifeAuraThread = nil

	PlayerTab:Toggle({
		Name = "Knife Aura",
		Default = false, -- Default Value
		Callback = function(enableKnifeAura)
			if knifeAuraThread then
				task.cancel(knifeAuraThread)
				knifeAuraThread = nil -- Disconnect, doesn't matter, we will disconnect it anyways lmao
			end
			if enableKnifeAura then
				knifeAuraThread = task.spawn(function()
					while WaitNextHeartBeat() do
						-- Contains all the zombies in the game
						local zombiesTable = workspace.Ignore.Zombies:GetChildren()

						for _, zombie in next, zombiesTable do
							local humanoid = zombie:FindFirstChild("Humanoid")
							-- The zombie has a humanoid and is alive, so is our player and it has a primary part.
							if
								humanoid
								and humanoid.Health > 0
								and LocalPlayerCharacter
								and LocalPlayerCharacter.PrimaryPart
							then
								-- If we are on the desired magintude, kinfe!
								if
									(LocalPlayerCharacter.PrimaryPart.Position - zombie.PrimaryPart.Position).Magnitude
									<= knifeAuraDistance
								then
									LocalPlayerCharacter.Remotes.Knifing:FireServer(true)
									WaitNextHeartBeat()
									ReplicatedStorage.Framework.Remotes.KnifeHitbox:FireServer(zombie)
									WaitNextHeartBeat()
									LocalPlayerCharacter.Remotes.Knifing:FireServer(false)
								end
							end
						end
					end
				end)
			end
		end,
	})

	-- #endregion Knife Aura
	local infiniteJumpConnection = nil

	PlayerTab:Toggle({
		Name = "Infinite Jump",
		Default = false,
		Callback = function(enableInfiniteJump)
			if infiniteJumpConnection then
				infiniteJumpConnection:Disconnect()
			end
			if enableInfiniteJump then
				infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
					if LocalPlayerCharacter then
						LocalPlayerCharacter.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
					else
						window:Notify({
							Name = "No player found!",
							Text = "The script has lost its reference to the player, please try again in a bit!",
							Duration = 5,
							Callback = function()
								LocalPlayerCharacter = LocalPlayer.Character
							end, -- Callback when the notification ends <Not required in this case!>
						})
					end
				end)
			end
		end,
	})

	local walkspeedSteppedConnection = nil

	PlayerTab:Slider({
		Name = "Walkspeed",
		Default = LocalPlayerCharacter.Humanoid.WalkSpeed,
		Min = 16,
		Max = 300,
		Callback = function(newWalkspeed)
			if walkspeedSteppedConnection then
				walkspeedSteppedConnection:Disconnect()
			end
			walkspeedSteppedConnection = RunService.Stepped:Connect(function()
				if LocalPlayerCharacter and LocalPlayerCharacter.Humanoid then
					LocalPlayerCharacter.Humanoid.WalkSpeed = newWalkspeed
				end
			end)
		end,
	})

	local noclipSteppedConnection = nil

	PlayerTab:Toggle({
		Name = "No clip",
		Default = false,
		Callback = function(enableNoClip)
			if noclipSteppedConnection then
				noclipSteppedConnection:Disconnect()
			end

			if enableNoClip then
				noclipSteppedConnection = RunService.Stepped:Connect(function()
					if LocalPlayerCharacter then
						for _, descendant in pairs(LocalPlayerCharacter:GetDescendants()) do
							if descendant:IsA("BasePart") then
								descendant.CanCollide = not enableNoClip
							end
						end
					else
						window:Notify({
							Name = "No player found!",
							Text = "The script has lost its reference to the player, please try again in a bit!",
							Duration = 5,
							Callback = function()
								LocalPlayerCharacter = LocalPlayer.Character
							end, -- Callback when the notification ends <Not required in this case!>
						})
					end
				end)
			end
		end,
	})

	local autoBarrierThread = nil
	PlayerTab:Toggle({
		Name = "Auto Barrier",
		Default = false,
		Callback = function(state)
			if state then
				autoBarrierThread = task.spawn(function()
					local barriersDescendants = game:GetService("Workspace")["_Barriers"]:GetDescendants()
					while task.wait(1) do
						for _, item in pairs(barriersDescendants) do
							if
								item.Name == "FixBarrier"
								and game.Players.LocalPlayer:DistanceFromCharacter(item.CFrame.Position) <= 10
							then
								-- Check for broken barriers (GET THE PARENT OF THE ITEM AND CHECK THE BARRIERS FOR TRANSPARENCY!)
								local breakables = item.Parent.Breakables:GetChildren()
								game.Players.LocalPlayer.Character.Remotes.UpdateHoverObject:FireServer(item)
								for _, part in ipairs(breakables) do
									if
										part.Transparency == 1
										and game.Players.LocalPlayer:DistanceFromCharacter(item.CFrame.Position)
									then -- Broken
										game.Players.LocalPlayer.Character.Remotes.UpdateInputHold:FireServer(true)
										task.wait(2.6)
									end
									game.Players.LocalPlayer.Character.Remotes.UpdateInputHold:FireServer(false)
								end
							end
						end
					end
				end)
			else
				if autoBarrierThread then
					task.cancel(autoBarrierThread)
				end
			end
		end,
	})

	local autoBuyPerkThread = nil
	PlayerTab:Toggle({
		Name = "Auto Purchase Perk",
		Default = false,
		Callback = function(state)
			if state then
				autoBuyPerkThread = task.spawn(function()
					local perkMachineFolderChildren = game:GetService("Workspace")["_PerkMachines"]:GetChildren()
					while task.wait(1) do
						for _, item in pairs(perkMachineFolderChildren) do
							local purchasePrompt = item:FindFirstChild("PurchasePerk")
							if
								purchasePrompt
								and game.Players.LocalPlayer:DistanceFromCharacter(purchasePrompt.CFrame.Position)
									<= 14
							then
								game.Players.LocalPlayer.Character.Remotes.UpdateHoverObject:FireServer(purchasePrompt)

								game.Players.LocalPlayer.Character.Remotes.UpdateInputHold:FireServer(true)
								task.wait(1.5)
								game.Players.LocalPlayer.Character.Remotes.UpdateInputHold:FireServer(false)
							end
						end
					end
				end)
			else
				if autoBuyPerkThread then
					task.cancel(autoBuyPerkThread)
				end
			end
		end,
	})

	local autoDoorBuyThread = nil
	PlayerTab:Toggle({
		Name = "Auto Buying Doors",
		Default = false,
		Callback = function(state)
			if state then
				autoDoorBuyThread = task.spawn(function()
					local doorChildren = game:GetService("Workspace")["_Doors"]:GetChildren()

					if #doorChildren == 1 then
						return -- There is only the server's controller "DoorController" in the folder, there is nothing else to buy, so kill this task.
					end

					while task.wait(1) do
						doorChildren = game:GetService("Workspace")["_Doors"]:GetChildren() -- Refresh

						if #doorChildren == 1 then
							break -- There is only the server's controller "DoorController" in the folder, there is nothing else to buy, so kill this task.
						end
						for _, doorModel in pairs(doorChildren) do
							local purchasePart = doorModel:FindFirstChild("PurchaseDoor")
							if
								purchasePart
								and game.Players.LocalPlayer:DistanceFromCharacter(purchasePart.CFrame.Position)
									<= 10
							then
								game.Players.LocalPlayer.Character.Remotes.UpdateHoverObject:FireServer(purchasePart)

								game.Players.LocalPlayer.Character.Remotes.UpdateInputHold:FireServer(true)
								task.wait(1)

								game.Players.LocalPlayer.Character.Remotes.UpdateInputHold:FireServer(false)
							end
						end
					end
				end)
			else
				if autoDoorBuyThread then
					task.cancel(autoDoorBuyThread)
				end
			end
		end,
	})

	-- Returns true it fixed any barriers, false if it did not.
	local function FixBarriers_TweenTo(speed)
		if not speed then
			speed = 60
		end
		local barriersDescendants = game:GetService("Workspace")["_Barriers"]:GetDescendants()
		local oldCFrame = LocalPlayerCharacter.HumanoidRootPart.CFrame
		local tpd = false
		for _, item in pairs(barriersDescendants) do
			local totalWaitTime = 1.2
			if item.Name == "FixBarrier" then
				-- Check for broken barriers (GET THE PARENT OF THE ITEM AND CHECK THE BARRIERS FOR TRANSPARENCY!)
				local breakables = item.Parent.Breakables:GetChildren()
				game.Players.LocalPlayer.Character.Remotes.UpdateHoverObject:FireServer(item)
				local brokenTables = 0
				for _, part in ipairs(breakables) do
					if
						part.Transparency == 1
						and game.Players.LocalPlayer:DistanceFromCharacter(item.CFrame.Position)
					then -- Broken
						brokenTables = brokenTables + 1
					end
					game.Players.LocalPlayer.Character.Remotes.UpdateInputHold:FireServer(false)
				end
				if brokenTables ~= 0 then
					local tweenItem = TweenToObject(item, speed, Vector3.new(-2, -2, -2))
					tweenItem.Completed:Wait()
					FreezeLocalPlayerCharacter()

					LocalPlayerCharacter.Remotes.UpdateHoverObject:FireServer(item)
					LocalPlayerCharacter.Remotes.UpdateInputHold:FireServer(true)
					task.wait(totalWaitTime * brokenTables)
					LocalPlayerCharacter.Remotes.UpdateInputHold:FireServer(false)
					LocalPlayerCharacter.Remotes.UpdateHoverObject:FireServer(nil)
					tpd = true
				end
			end
		end
		if tpd then
			TweenToPostion(oldCFrame, speed, Vector3.new(0, 0, 0))
		end
		return tpd
	end

	PlayerTab:Button({
		Name = "Fix all Barriers",
		Callback = function()
			task.spawn(function()
				Window:Notify({
					Name = "Fixing Barriers",
					Text = "Attempting to fix all barriers! This may take a few seconds, avoid getting close to interactables!",
					Duration = 10,
					Callback = function()
						return
					end, -- Callback when the notification ends
				})
			end)
			FixBarriers_TweenTo()
		end,
	})

	PlayerTab:Label({
		Text = "Enable Kinfe Aura before enabling round farming, else things may not work as expected",
	})

	local tweenFarmRoundSpeed = 60 -- Stub value for Farm Rounds
	local farmRoundThread = nil
	PlayerTab:Toggle({
		Name = "Farm Rounds",
		Default = false,
		Callback = function(enableRoundFarming)
			if enableRoundFarming then
				farmRoundThread = task.spawn(function()
					local MAX_ATTEMPT_NUMBER = 50
					local MAX_KILL_ATTEMPTS = 420
					local doorChildren = workspace._Doors:GetChildren() -- Refresh
					local zombiesFolder = game:GetService("Workspace").Ignore.Zombies
					local playerPointsContainer = game:GetService("Players").LocalPlayer.MatchData.Points
					local currentRoundContainer =
						game:GetService("Players").LocalPlayer.PlayerGui.GameUI.Default.RoundNumFrame.RoundNum

					local availableKnifes = (function() -- Small function to get the names of all viable knifes
						local list = game:GetService("ReplicatedStorage").Framework.Knives:GetChildren()
						local tableNames = {}
						for i, v in ipairs(list) do
							if v.Name then
								table.insert(tableNames, v.Name)
							end
						end
						return tableNames
					end)()
					local perkMachineFolder = workspace._PerkMachines

					local function AvailablePerksForPurchase()
						local pTable = perkMachineFolder:GetChildren()
						local ownedPerks = LocalPlayerCharacter.CharStats.Perks:GetChildren()

						if #pTable - #ownedPerks > 1 then
							return true
						else
							return false
						end
					end

					local function HasGameStarted()
						return LocalPlayer.InGame.Value and LocalPlayer.IsReady.Value
					end

					--- @return number currentRound The current round
					local function GetCurrentRoundNumber()
						return currentRoundContainer.Value
					end

					--- @return number currentPoints The current points the player has
					local function GetPlayerPoints()
						return playerPointsContainer.Value
					end

					local UPD_KNIFE_MEMO = nil
					local function GetUpgradedKnifeBuy()
						if UPD_KNIFE_MEMO then
							return UPD_KNIFE_MEMO
						end
						local wallBuys = workspace._WallBuys:GetChildren()

						for _, buy in ipairs(wallBuys) do
							if table.find(availableKnifes, buy.Name) then
								UPD_KNIFE_MEMO = buy
								return buy
							end
						end

						return nil
					end

					--- @param machine Instance The machine to verify the "usability" from.
					local function IsPerkMachineUsable(machine)
						local light = machine:FindFirstChildWhichIsA("Light", true)

						if not light.Enabled or light.Brightness == 0 then
							return false -- Machine cannot be used. Else it would emmit light!
						else
							return true
						end
					end

					--- @return boolean isUpgradedKnife Whether or not the knife is upgraded.
					local function HasUpgradedKnife()
						return LocalPlayerCharacter.CharStats.Knife.Value ~= "Classic" -- the name of the Knife is different than the original knife, meaning, it is probably upgraded.
					end

					local function CalculateOffset(item)
						if item.Name == "Jerome" then
							return Vector3.new(0, 6.5, 0)
						else
							return Vector3.new(0, 5, 0)
						end
					end

					local function AreAvailableBarriersToFix()
						local barriersDescendants = game:GetService("Workspace")["_Barriers"]:GetDescendants()
						for _, item in pairs(barriersDescendants) do
							if item.Name == "FixBarrier" then
								-- Check for broken barriers (GET THE PARENT OF THE ITEM AND CHECK THE BARRIERS FOR TRANSPARENCY!)
								local breakables = item.Parent.Breakables:GetChildren()
								for _, part in ipairs(breakables) do
									if part.Transparency == 1 then
										return true
									end
								end
							end
						end
						return false -- No barriers available.
					end

					while WaitNextHeartBeat() do
						while not HasGameStarted() do
							print("AUTOFARM: GAMESTARTED->FALSE")
							task.wait(5)
						end

						local tweened = false
						local oldCframe = LocalPlayerCharacter.HumanoidRootPart.CFrame
						--- @type Instance
						for _, item in pairs(zombiesFolder:GetChildren()) do
							if item.ClassName == "Model" then
								local attemptNumber = 0
								local humanoid = item:FindFirstChild("Humanoid", true) -- Recursive

								while not humanoid and WaitNextHeartBeat() and attemptNumber < MAX_ATTEMPT_NUMBER do -- Wait a heartbeat if there is no humanoid, and try to get it
									humanoid = item:FindFirstChild("Humanoid", true) -- Recursive
									print("AUTO FARM: Waiting for zombie humanoid...")
									attemptNumber = attemptNumber + 1
								end
								local killAttempts = 0
								if attemptNumber < MAX_ATTEMPT_NUMBER then
									print("AUTO FARM: ZOMBIE KILLING STAGE")
									while
										humanoid.Health
										and humanoid.Health > 0
										and humanoid.RootPart
										and killAttempts < MAX_KILL_ATTEMPTS
									do
										local tween =
											TweenToObject(humanoid.RootPart, tweenFarmRoundSpeed, CalculateOffset(item))
										task.wait(0.1)
										tween:Pause()
										tween:Cancel()
										tweened = true
										FreezeLocalPlayerCharacter()
										killAttempts = killAttempts + 1
									end

									if killAttempts >= MAX_KILL_ATTEMPTS then
										print("AUTO FARM: ZOMBIE KILL ATTEMPTS->REACHEDMAX!")
										print("AUTO FARM: STATE->NEXT")
										break
									end
								else
									print(
										"AUTO FARM: ZOMBIE SKIPPED! NO HUMANOID FOUND IN "
											.. MAX_ATTEMPT_NUMBER
											.. " HEARTBEAT(S)."
									)
								end
							end
						end
						if tweened then
							print("AUTO FARM: RESTORE POS STAGE")
							local tween = TweenToPostion(oldCframe, tweenFarmRoundSpeed, Vector3.new(0, 0, 0))
							tween.Completed:Wait()
							FreezeLocalPlayerCharacter()
						end
						local shouldFixBarriers = AreAvailableBarriersToFix()
						if #zombiesFolder:GetChildren() < 5 and shouldFixBarriers then
							-- The zombies folder has few zombies, normally close to end of the round, TWEEN AND FIX ALL BARRIERS!
							print("AUTO FARM: BARRIER STAGE")
							tweened = FixBarriers_TweenTo(tweenFarmRoundSpeed)
							FreezeLocalPlayerCharacter()
							task.wait(0.3)
							if tweened then
								print("AUTO FARM: RESTORE POS STAGE")
								local tween = TweenToPostion(oldCframe, tweenFarmRoundSpeed, Vector3.new(0, 0, 0))
								tween.Completed:Wait()
								FreezeLocalPlayerCharacter()
							end
						elseif not shouldFixBarriers then
							print("AUTO FARM: BARRIER STAGE SKIPPED; NO FIXABLE BARRIERS FOUND!")
							task.wait(5)
						end

						if GetPlayerPoints() >= 3000 and not HasUpgradedKnife() and GetUpgradedKnifeBuy() then
							local target = GetUpgradedKnifeBuy() -- Memoized

							local tweenTarget = target:FindFirstChildOfClass("Part")
								or target:FindFirstChildOfClass("BasePart")

							if tweenTarget then
								local tween = TweenToObject(tweenTarget, tweenFarmRoundSpeed)

								tween.Completed:Wait() -- Wait tween.

								local buyHover = nil
								-- Find first child that contains the buy prefix
								for _, child in ipairs(target:GetChildren()) do
									if child.Name:match("Purchase") then
										buyHover = child
										break
									end
								end

								if not buyHover then
									print("AUTO FARM: UPGRADE_KNIFE_BUY_FAILURE->TRUE")
								else
									-- Valid buy.
									LocalPlayerCharacter.Remotes.UpdateHoverObject:FireServer(buyHover)
									LocalPlayerCharacter.Remotes.UpdateInputHold:FireServer(true)
									task.wait(2)
									LocalPlayerCharacter.Remotes.UpdateInputHold:FireServer(false)
									LocalPlayerCharacter.Remotes.UpdateHoverObject:FireServer(nil)
									if HasUpgradedKnife() then
										print("AUTO FARM: UPGRADED_KNIFE_BUY_SUCCESS->TRUE")
									end
								end
							else
								print("AUTO FARM: UPGRADED_KNIFE_BUY_FAILURE->TRUE")
							end
						end

						if GetPlayerPoints() >= 4000 and AvailablePerksForPurchase() then
							-- TODO: FIX IMPLEMENTATION
							print("AUTO FARM: MID POINT COUNT!->BUYING ONE PERK")
							local perksTable = perkMachineFolder:GetChildren()
							local ownedPerks = LocalPlayerCharacter.CharStats.Perks
							local ownedPerksTable = ownedPerks:GetChildren()
							local oldOwnedPerks = #ownedPerksTable
							for _, perkMachine in ipairs(perksTable) do
								if perkMachine.ClassName == "Model" and IsPerkMachineUsable(perkMachine) then
									print("[!DBG!]: Found Park Machine")
									-- Perk machine localized.
									local purchasePart = perkMachine:FindFirstChild("PurchasePerk")

									if purchasePart then
										local tween = TweenToObject(purchasePart, tweenFarmRoundSpeed)
										print("AUTOFARM: BUYPERKS->TWEENSTARTED!")
										tween.Completed:Wait()
										FreezeLocalPlayerCharacter()
										print("AUTOFARM: BUYPERKS->TWEENCOMPLETED!")

										game.Players.LocalPlayer.Character.Remotes.UpdateHoverObject:FireServer(
											purchasePart
										)

										game.Players.LocalPlayer.Character.Remotes.UpdateInputHold:FireServer(true)
										task.wait(1)

										game.Players.LocalPlayer.Character.Remotes.UpdateInputHold:FireServer(false)
										ownedPerksTable = ownedPerks:GetChildren()
										if oldOwnedPerks ~= #ownedPerksTable then
											print("AUTOFARM: BUYPERKS->PERKBOUGHT!!")
											UnfreezeLocalPlayerCharacter()
											break
										else
											print("AUTOFARM: BUYPERKS->PERKBUYFAILED!!")
										end
									else
										print("[!DBG!]: FAILED TO GET PURCHASEPART!")
									end
								elseif perkMachine.ClassName == "Model" then
									print("AUTOFARM: FOUND PERK MACHINE, BUT WAS UNUSABLE!")
								end
							end
						end

						-- We are at a high point value. Crazy
						if GetPlayerPoints() >= 5000 and #doorChildren > 1 then
							-- Go to the nearest door...
							print("AUTO FARM: HIGH POINT COUNT!->BUYING ONE DOOR")

							local oldDoorCount = #doorChildren
							for _, doorModel in pairs(doorChildren) do
								local purchasePart = doorModel:FindFirstChild("PurchaseDoor")
								if purchasePart then
									local tween = TweenToObject(purchasePart, tweenFarmRoundSpeed)
									print("AUTOFARM: BUYDOORS->TWEENSTARTED!")
									tween.Completed:Wait()
									FreezeLocalPlayerCharacter()
									print("AUTOFARM: BUYDOORS->TWEENCOMPLETED!")
									game.Players.LocalPlayer.Character.Remotes.UpdateHoverObject:FireServer(
										purchasePart
									)

									game.Players.LocalPlayer.Character.Remotes.UpdateInputHold:FireServer(true)
									task.wait(1)

									game.Players.LocalPlayer.Character.Remotes.UpdateInputHold:FireServer(false)
									LocalPlayerCharacter.Remotes.UpdateHoverObject:FireServer(nil)
									doorChildren = game:GetService("Workspace")["_Doors"]:GetChildren()
									if oldDoorCount ~= #doorChildren then
										print("AUTOFARM: BUYDOORS->DOORBOUGHT!")
										UnfreezeLocalPlayerCharacter()
										break
									else
										print("AUTOFARM: BUYDOORS->DOORBUYFAILED!")
									end
								end
							end
						end
					end
				end)
			else
				if farmRoundThread then
					task.cancel(farmRoundThread)
				end
				UnfreezeLocalPlayerCharacter()
			end
		end,
	})

	PlayerTab:Slider({
		Name = "Round Farm Speed (Tween)",
		Min = 20,
		Max = 3000,
		Default = 60,
		Callback = function(sliderValue)
			tweenFarmRoundSpeed = sliderValue
		end,
	})

	if not IsScriptObfuscated() then
		print("AUTO BUY MYSTERY BOX DEVNOTE! | THIS FEATURE HAS NOT BEEN FINISHED! IT WON'T WORK!! LMFAO")
		local autoMysteryBoxBuyThread = nil
		PlayerTab:Toggle({
			Name = "Auto Buy Mystery Box",
			Default = false,
			Callback = function(state)
				if state then
					autoMysteryBoxBuyThread = task.spawn(function()
						local mysteryBoxReference = nil
						local interactableReference = nil
						local function getInteractableReferenceFromBoxReference() end
						local function getBoxReference()
							local doorChildren = game:GetService("Workspace")["_MapComponents"]:GetChildren()

							for indx, val in ipairs(doorChildren) do
								if val.Name == "MysteryBox" then
									val.Destroying:Connect(function()
										-- Refresh the reference in this scope
										mysteryBoxReference = getBoxReference()
										task.wait(1)
										interactableReference = getInteractableReferenceFromBoxReference()
									end)
									return val
								end
							end
						end
						mysteryBoxReference = getBoxReference()
						interactableReference = getInteractableReferenceFromBoxReference()
						while task.wait(1) do
						end
					end)
				else
					if autoMysteryBoxBuyThread then
						task.cancel(autoMysteryBoxBuyThread)
					end
				end
			end,
		})
	end

	PlayerTab:Slider({
		Name = "Field of View",
		Default = workspace.CurrentCamera.FieldOfView,
		Min = 50,
		Max = 120,
		Callback = function(newFov)
			WaitNextHeartBeat() -- Wait for the next heartbeat
			ReplicatedStorage.Game.Remotes.Settings.SetSettingData:FireServer(
				LocalPlayer.UserSettings.Graphics.FieldOfView,
				newFov
			)
		end,
	})
end

function CreateVisualsTab(window)
	-- Tab
	local VisualsTab = window:Tab({
		Name = "Visuals",
		Description = "ESP",
		Icon = "rbxassetid://11254763826", -- Tab Icon
		Color = Color3.new(0.811765, 0.313725, 0.247059), -- Tab Colour
		Hidden = false, -- IGNORE THIS
	})

	-- Table containing connections to the Zombies added and removed.
	local zombieEspConnections = table.create(1, nil)
	local zombiesEspTable = {}
	VisualsTab:Toggle({
		Name = "Zombies ESP",
		Default = false,
		Callback = function(enableZombiesESP)
			if not enableZombiesESP and zombieEspConnections then
				for _, connection in next, zombieEspConnections do
					connection:Disconnect()
				end
				table.clear(zombieEspConnections)

				for _, espItem in next, zombiesEspTable do
					if espItem and espItem.Parent then
						espItem.Adornee = nil
						espItem.Parent = nil
						espItem:Destroy()
					end
				end
				table.clear(zombiesEspTable)
			end

			if enableZombiesESP then
				local zombiesFolder = game:GetService("Workspace").Ignore.Zombies
				zombieEspConnections[1] = zombiesFolder.ChildAdded:Connect( ---@param child Instance
					function(child)
						task.wait(1)
						local hum = child:FindFirstChildOfClass("Humanoid")
						if not hum then
							local ctr = 0
							while ctr < 10 and not hum do
								ctr = ctr + 1
								task.wait(1)
								hum = child:FindFirstChildOfClass("Humanoid")
							end

							if hum and not IsScriptObfuscated() then
								print(
									"[DBG]: CHILD DIDN'T HAVE A HUMANOID, BUT IT APPEARED " .. ctr .. " SECONDS LATER!"
								)
							elseif not hum and not IsScriptObfuscated() then
								print("[DBG]: CHILD DOES NOT HAVE A HUMANOID! HELLHOUND PERHAPS?")
							end
						end
						if not hum then
							if not LPH_OBFUSCATED then
								print("[DBG]: CHILD DID NOT LOAD A HUMANOID IN APPROXIMATELY 10 SECONDS, HELLHOUND?")
							end
						end

						task.wait(1) -- Roblox replication being gay again

						local highlight = Instance.new("Highlight", gethui()) -- Create highlight, parent to gethui() to avoid possible detections!
						highlight.Adornee = child
						highlight.FillColor = Color3.fromRGB(0, 0, 255)
						highlight.FillTransparency = 0.5
						table.insert(zombiesEspTable, highlight)
						-- Called when the Destroy method is called on the zombie
						child.Destroying:Connect(function()
							if highlight then
								highlight.Parent = nil
								highlight.Adornee = nil
								highlight:Destroy()
							end
						end)
					end
				)

				-- Make the ESP for all the currently available zombies
				for _, zombie in next, zombiesFolder:GetChildren() do
					local highlight = Instance.new("Highlight", gethui()) -- Create highlight, parent to gethui() to avoid possible detections!
					highlight.Adornee = zombie
					highlight.FillColor = Color3.fromRGB(0, 0, 255)
					highlight.FillTransparency = 0.5
					table.insert(zombiesEspTable, highlight)
					-- Called when the Destroy method is called on the zombie
					zombie.Destroying:Connect(function()
						if highlight then
							highlight.Parent = nil
							highlight.Adornee = nil
							highlight:Destroy()
						end
					end)
				end
			end
		end,
	})

	-- Table containing connections to the Boxes added and removed.
	local mysteryBoxEspConnections = table.create(1, nil)
	local mysteryBoxEspTable = {}
	VisualsTab:Toggle({
		Name = "Mystery Box ESP",
		Default = false,
		Callback = function(enablePlayersESP)
			if not enablePlayersESP and mysteryBoxEspConnections then
				for _, connection in next, mysteryBoxEspConnections do
					connection:Disconnect()
				end
				table.clear(mysteryBoxEspConnections)

				for _, espItem in next, mysteryBoxEspTable do
					if espItem and espItem.Parent then
						espItem.Adornee = nil
						espItem.Parent = nil
						espItem:Destroy()
					end
				end
				table.clear(mysteryBoxEspTable)
			end

			if enablePlayersESP then
				local mysteryBoxFolder = game:GetService("Workspace")["_MapComponents"].MysteryBox
				mysteryBoxEspConnections[1] = mysteryBoxFolder.ChildAdded:Connect(function(child)
					task.wait(1) -- Wait till things load-in, yes, absurd, peak-scripting.
					local highlight = Instance.new("Highlight", gethui()) -- Create highlight, parent to gethui() to avoid possible detections!
					highlight.Adornee = child
					highlight.FillColor = Color3.fromRGB(41, 21, 0)
					highlight.FillTransparency = 0.5
					table.insert(mysteryBoxEspTable, highlight)
					-- Called when the Destroy method is called on the zombie
					child.Destroying:Connect(function()
						if highlight then
							highlight.Parent = nil
							highlight.Adornee = nil
							highlight:Destroy()
						end
					end)
				end)

				-- Make the ESP for all the currently available zombies
				for _, box in next, mysteryBoxFolder:GetChildren() do
					local highlight = Instance.new("Highlight", gethui()) -- Create highlight, parent to gethui() to avoid possible detections!
					highlight.Adornee = box
					highlight.FillColor = Color3.fromRGB(41, 21, 0)
					highlight.FillTransparency = 0.5
					table.insert(mysteryBoxEspTable, highlight)
					-- Called when the Destroy method is called on the zombie
					box.Destroying:Connect(function()
						if highlight then
							highlight.Parent = nil
							highlight.Adornee = nil
							highlight:Destroy()
						end
					end)
				end
			end
		end,
	})

	-- Table containing connections to the BParts added and removed.
	local buildingPartsEspConnections = table.create(1, nil)
	local buildingPartsEspTable = {}
	VisualsTab:Toggle({
		Name = "Building Parts ESP",
		Default = false,
		Callback = function(enablePlayersESP)
			if not enablePlayersESP and buildingPartsEspConnections then
				for _, connection in next, buildingPartsEspConnections do
					connection:Disconnect()
				end
				table.clear(buildingPartsEspConnections)

				for _, espItem in next, buildingPartsEspTable do
					if espItem and espItem.Parent then
						espItem.Adornee = nil
						espItem.Parent = nil
						espItem:Destroy()
					end
				end
				table.clear(buildingPartsEspTable)
			end

			if enablePlayersESP then
				local function BeautifyPartName(name)
					if name == "QuamtexFuse" then
						return "Quamtex Fuse"
					end
					if name == "RopeStraps" then
						return "Rope Straps"
					end
					if name == "ColdFrame" then
						return "Cold Frame"
					end
					return name -- Not set.
				end
				local partsFolder = game:GetService("Workspace")["_Parts"]
				buildingPartsEspConnections[1] = partsFolder.ChildAdded:Connect(function(child)
					task.wait(1) -- Wait till things load-in, yes, absurd, peak-scripting.
					local highlight = Instance.new("Highlight", gethui()) -- Create highlight, parent to gethui() to avoid possible detections!
					highlight.Adornee = child
					highlight.FillColor = Color3.fromRGB(41, 21, 0)
					highlight.FillTransparency = 0.5
					highlight.OutlineColor = Color3.fromRGB(206, 54, 54)

					local bill = Instance.new("BillboardGui", gethui())
					bill.AlwaysOnTop = true
					bill.Enabled = true
					bill.Adornee = child
					bill.LightInfluence = 1
					bill.Size = UDim2.new(0, 20, 0, 20)

					local frame = Instance.new("Frame", bill)

					local text = Instance.new("TextLabel", frame)
					text.Name = "lmap!"
					text.TextSize = 16
					text.Size = UDim2.new(0, 30, 0, 30)
					text.BackgroundTransparency = 1
					text.Font = Enum.Font.SourceSansBold
					text.TextScaled = true
					text.TextWrapped = true
					text.Text = BeautifyPartName(child.Name)
					text.TextColor3 = Color3.new(1, 1, 1)

					table.insert(buildingPartsEspTable, highlight)
					table.insert(buildingPartsEspTable, bill)
					table.insert(buildingPartsEspTable, frame)
					table.insert(buildingPartsEspTable, text)
					-- Called when the Destroy method is called on the bpart
					child.Destroying:Connect(function()
						if highlight then
							highlight.Parent = nil
							highlight.Adornee = nil
							highlight:Destroy()
						end
						if bill then
							bill.Parent = nil
							bill.Adornee = nil
							bill:Destroy()
						end
						if frame then
							frame.Parent = nil
							frame:Destroy()
						end
						if text then
							text.Parent = nil
							text.Adornee = nil
							text:Destroy()
						end
					end)
				end)

				-- Make the ESP for all the currently available zombies
				for _, part in next, partsFolder:GetChildren() do
					local highlight = Instance.new("Highlight", gethui()) -- Create highlight, parent to gethui() to avoid possible detections!
					highlight.Adornee = part
					highlight.FillColor = Color3.fromRGB(41, 21, 0)
					highlight.FillTransparency = 0.5
					highlight.OutlineColor = Color3.fromRGB(206, 54, 54)

					local bill = Instance.new("BillboardGui", gethui())
					bill.AlwaysOnTop = true
					bill.Enabled = true
					bill.Adornee = part
					bill.LightInfluence = 1
					bill.Size = UDim2.new(0, 20, 0, 20)

					local frame = Instance.new("Frame", bill)

					local text = Instance.new("TextLabel", frame)
					text.Name = "lmap!"
					text.TextSize = 16
					text.Size = UDim2.new(0, 30, 0, 30)
					text.BackgroundTransparency = 1
					text.Font = Enum.Font.SourceSansBold
					text.TextScaled = true
					text.TextWrapped = true
					text.Text = BeautifyPartName(part.Name)
					text.TextColor3 = Color3.new(1, 1, 1)

					table.insert(buildingPartsEspTable, highlight)
					table.insert(buildingPartsEspTable, bill)
					table.insert(buildingPartsEspTable, frame)
					table.insert(buildingPartsEspTable, text)
					-- Called when the Destroy method is called on the bpart
					part.Destroying:Connect(function()
						if highlight then
							highlight.Parent = nil
							highlight.Adornee = nil
							highlight:Destroy()
						end
						if bill then
							bill.Parent = nil
							bill.Adornee = nil
							bill:Destroy()
						end
						if frame then
							frame.Parent = nil
							frame:Destroy()
						end
						if text then
							text.Parent = nil
							text.Adornee = nil
							text:Destroy()
						end
					end)
				end
			end
		end,
	})
end

function CreateGameplayTab(window)
	-- Tab
	local GameplayTab = window:Tab({
		Name = "Gameplay",
		Description = "Modifications to the Gameplay",
		Icon = "rbxassetid://11254763826", -- Tab Icon
		Color = Color3.new(0.811765, 0.313725, 0.247059), -- Tab Colour
		Hidden = false, -- IGNORE THIS
	})

	local collectPowerUpsConnection = nil
	GameplayTab:Toggle({
		Name = "Collect Powerups",
		Default = false,
		Callback = function(enableCollectPowerups)
			if collectPowerUpsConnection then
				collectPowerUpsConnection:Disconnect()
				collectPowerUpsConnection = nil
			end

			if enableCollectPowerups then
				collectPowerUpsConnection = game.Workspace.Ignore["_Powerups"].ChildAdded:Connect(function(child)
					WaitNextHeartBeat() -- Wait next heartbeat
					child.Position = LocalPlayerCharacter.PrimaryPart.CFrame.Position
				end)
			end
		end,
	})

	--[[ #region Always Headshot

    local alwaysHeadShot = false
    GameplayTab:Toggle({
        Name = "Always Headshot",
        Default = false,
        Callback = function(enableAlwaysHeadshot)
            alwaysHeadShot = enableAlwaysHeadshot
        end
    })
    -- We don't wanna hook EVERY time! Just do it once!
    local function rngVec3()
        local top = 0.1
        local bottom = 0
        return Vector3.new(math.random(bottom, top), math.random(bottom, top),
                           math.random(bottom, top))
    end
    local oldAlwaysHeadShotHook;
    oldAlwaysHeadShotHook = hookmetamethod(game, "__namecall",
                                           newcclosure(function(self, ...)
        -- Only replace when we are told to by the headshot toggle.
        -- self is sometimes overlooked, and may cause a detection vector.
        if self and getnamecallmethod() == "FireServer" and self.Name ==
            "FireBullet" then
            local args = {...}
            -- Length of args should be two.
            if #args ~= 2 then
                game:GetService("Players").LocalPlayer:Kick(
                    "Codexus Hub -> Incorrect params recieved on hook, game devs are possibly trying to detect the script, inform the developers")
            end
            local coordinate, num = args[1], args[2]

            -- Get closest zombi.
            --- @type Instance | nil
            local closestToCoordinate = nil
            local dist = math.huge

            for _, zombie in ipairs(workspace.Ignore.Zombies:GetChildren()) do
                if zombie.PrimaryPart then
                    local diff = LocalPlayer:DistanceFromCharacter(
                                     zombie.PrimaryPart.CFrame.Position)
                    if diff < dist then
                        dist = diff;
                        closestToCoordinate = zombie;
                    end
                else
                    local primaryPart =
                        zombie:FindFirstChild("HumanoidRootPart")
                    if not primaryPart then
                        warn("Missing primary part")
                    end

                    local diff = LocalPlayer:DistanceFromCharacter(
                                     primaryPart.CFrame.Position)
                    if diff < dist then
                        dist = diff;
                        closestToCoordinate = zombie;
                    end
                end
            end

            -- Magic num == unix timestamp
            local magicNum = tick()
            if not closestToCoordinate then
                print("Failed to find closest!")
                return nil
            end

            print(closestToCoordinate.Name)
            local head = closestToCoordinate:FindFirstChild("Head")
            if head then
                print("Found head")
                return oldAlwaysHeadShotHook(self,
                                             head.CFrame.Position + rngVec3(),
                                             magicNum)
            else -- Failed to get Head, use Torso instead.
                local torso = closestToCoordinate:FindFirstChild("Torso")
                if not torso then
                    print("Default hit")
                    return oldAlwaysHeadShotHook(self, coordinate, magicNum)
                end
                print("Aiming Torso")
                -- Aim at torso else
                return oldAlwaysHeadShotHook(self,
                                             torso.CFrame.Position + rngVec3(),
                                             magicNum)
            end

        end

        return oldAlwaysHeadShotHook(self, ...)
    end))
    -- #endregion Always Headshot]]
	-- #region Gun play Modification

	GameplayTab:Button({
		Name = "No Recoil",
		Callback = function()
			for _, gcVal in pairs(getgc(true)) do
				if type(gcVal) == "table" and rawget(gcVal, "CAMERA_RECOIL") and not rawget(gcVal, "KNIFE_NAME") then
					gcVal.CAMERA_RECOIL = {
						IDLE = function()
							return Vector3.new(0)
						end,
						CROUCH = function()
							return Vector3.new(0)
						end,
						AIM = function()
							return Vector3.new(0)
						end,
					}
					task.wait(0.1)
				end

				-- You shall not modify the table of Knife's they break the game.
				-- Still, warn about it on the dev console.
				if not LPH_OBFUSCATED and type(gcVal) == "table" and rawget(gcVal, "KNIFE_NAME") then
					warn("Skipped over table -> References a Knife")
				end
			end
			task.spawn(function()
				window:Notify({
					Name = "No Recoil",
					Text = "No Recoil has been enabled",
					Duration = 5,
					Callback = function()
						return
					end, -- Callback when the notification ends <Not required in this case!>
				})
			end)
		end,
	})

	GameplayTab:Button({
		Name = "Automatic Fire",
		Callback = function()
			for _, gcVal in pairs(getgc(true)) do
				if type(gcVal) == "table" and rawget(gcVal, "FIRE_TYPE") then
					gcVal.FIRE_TYPE = "AUTO"
					task.wait(0.1)
				end
			end

			task.spawn(function()
				window:Notify({
					Name = "Automatic Fire",
					Text = "Automatic Fire has been enabled",
					Duration = 5,
					Callback = function()
						return
					end, -- Callback when the notification ends <Not required in this case!>
				})
			end)
		end,
	})

	-- Index into table with "RPM"
	local function getFirerateTable()
		local fireratesTable = {}
		for _, gcVal in pairs(getgc(true)) do
			if type(gcVal) == "table" and rawget(gcVal, "RPM") then
				table.insert(fireratesTable, gcVal)
				task.wait(0.1)
			end
		end
		return fireratesTable
	end

	local fireRateTable = getFirerateTable()

	-- Waiting for the fire rate table...
	while not fireRateTable do
		task.wait(1)
		fireRateTable = getFirerateTable()
	end
	-- State variable for marking first usage of UI. Thanks shitty UI lib!
	local firstUsage = false

	GameplayTab:Slider({
		Name = "Fire Rate",
		Min = 200, -- Min Val
		Max = 2000, -- Max Val
		Default = 200, -- Default Val
		Callback = function(val)
			if not firstUsage then
				firstUsage = true
				return
			end
			if not fireRateTable then
				fireRateTable = getFirerateTable() -- Our reference might have been lost, get it again >:)
			end
			for _, tableT in ipairs(fireRateTable) do
				tableT.RPM = val -- Easier to store the reference instead of loop every time; props for us!
			end
		end,
	})

	GameplayTab:Button({
		Name = "No bullet spread",
		Callback = function()
			for _, gcVal in pairs(getgc(true)) do
				if type(gcVal) == "table" and rawget(gcVal, "SPREAD") then
					gcVal.SPREAD = {
						DEFAULT = 0,
						MIN = 0,
						MAX = 0,
						CROUCH_REDUCTION = 0,
						AIM_REDUCTION = 0,
						WALK_ADDITION = 0,
					}
				end
			end

			task.spawn(function()
				window:Notify({
					Name = "No spread",
					Text = "No spread has been activated.",
					Duration = 5,
					Callback = function()
						return
					end, -- Callback when the notification ends <Not required in this case!>
				})
			end)
		end,
	})

	-- Index into table with "PENETRATION"
	local function getPenetrationTable()
		local penetrationTable = {}
		for _, gcVal in pairs(getgc(true)) do
			if type(gcVal) == "table" and rawget(gcVal, "PENETRATION") then
				table.insert(penetrationTable, gcVal)
				task.wait(0.1)
			end
		end
		return penetrationTable
	end

	local penetrationTable = getPenetrationTable()

	-- Waiting for the penetration table...
	while not penetrationTable do
		task.wait(1)
		penetrationTable = getPenetrationTable()
	end

	firstUsage = false
	GameplayTab:Slider({
		Name = "Bullet Penetration",
		Min = 1, -- Min Val
		Max = 100, -- Max Val
		Default = 1, -- Default Val
		Callback = function(val)
			if not firstUsage then
				firstUsage = true
				return
			end
			if not penetrationTable then
				penetrationTable = getPenetrationTable() -- Our reference might have been lost, get it again >:)
			end
			for _, tableT in ipairs(penetrationTable) do
				tableT.PENETRATION = val -- Easier to store the reference instead of loop every time; props for us!
			end
		end,
	})

	-- Index into table with "BULLET_SPEED"
	local function getBulletSpeedTable()
		local bulletSpeedTables = {}
		for _, gcVal in pairs(getgc(true)) do
			if type(gcVal) == "table" and rawget(gcVal, "BULLET_SPEED") then
				table.insert(bulletSpeedTables, gcVal)
				task.wait(0.1)
			end
		end
		return bulletSpeedTables
	end

	local bulletSpeedTable = getBulletSpeedTable()

	-- Waiting for the bullet speed table...
	while not bulletSpeedTable do
		task.wait(1)
		bulletSpeedTable = getBulletSpeedTable()
	end
	firstUsage = false

	GameplayTab:Slider({
		Name = "Bullet Speed",
		Min = 20, -- Min Val
		Max = 2000, -- Max Val
		Default = 20, -- Default Val
		Callback = function(val)
			if not firstUsage then
				firstUsage = true
				return
			end
			if not bulletSpeedTable then
				bulletSpeedTable = getBulletSpeedTable() -- Our reference might have been lost, get it again >:)
			end
			for _, tableT in ipairs(bulletSpeedTable) do
				tableT.BULLET_SPEED = val -- Easier to store the reference instead of loop every time; props for us!
			end
		end,
	})

	local instantReloadThread = nil

	GameplayTab:Toggle({
		Name = "Instantaneous Reload",
		Default = false, -- Default Value
		Callback = function(enableInstantReload)
			if instantReloadThread then
				task.cancel(instantReloadThread) -- Cancel task
			end

			if enableInstantReload then
				instantReloadThread = task.spawn(function()
					while WaitNextHeartBeat() do
						if LocalPlayerCharacter then
							LocalPlayerCharacter.Remotes.Reload:FireServer()
						else
							window:Notify({
								Name = "No player found!",
								Text = "The script has lost its reference to the player, please try again in a bit!",
								Duration = 5,
								Callback = function()
									LocalPlayerCharacter = LocalPlayer.Character
								end, -- Callback when the notification ends <Not required in this case!>
							})
						end
					end
				end)
			end
		end,
	})

	-- #endregion Gun play Modification
end

CreatePlayerTab(Window)
CreateGameplayTab(Window)
CreateVisualsTab(Window)
