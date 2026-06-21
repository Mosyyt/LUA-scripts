--- START METADATA PRELUDE


-- Bundler Name: Luarmor Bundler
-- Bundler Written by @usrdottik
-- Bundler Version: 1.0.0
-- Bundled Scripts:
--	Game Identifier: 3846592040 | Is Premium Only: False
--	Game Identifier: 3104101863 | Is Premium Only: False
--	Game Identifier: 1785526629 | Is Premium Only: True
--	Game Identifier: 4383934650 | Is Premium Only: False
--	Game Identifier: 847722000 | Is Premium Only: False
--	Game Identifier: 3772683742 | Is Premium Only: False
--	Game Identifier: 4730278139 | Is Premium Only: False
--	Game Identifier: 4987467534 | Is Premium Only: False



--- END METADATA PRELUDE | START FUNCTIONS


function IsKeySystemLink()
    if LRM_UserNote then
        return LRM_UserNote == "not_premium"
    else
        error("Luarmor variables missing. This may not be a Luarmor environment.")
    end
end


--- END FUNCTIONS | START CODE



if game.GameId == 3846592040 then
--- Defines the default settings for the Hub when loaded, this will be applied to the GUI.
local HubSettings = {
	-- MAIN SECTION!

	--- Determines whether or not the Always Perfect Dodge should be enabled.
	EnableAlwaysPerfectDodge = false,
	--- Determines whether or not the Automatic Doctor should be enabled.
	AutomaticDoctor = false,
	--- Determines whether or not the Automatic Perfect Weapon Skill (Meta Method Hook) should be enabled.
	EnableAlwaysPerfectWeaponSkill = false,
	--- Determines whether or not Fall Damage should be nullified.
	DisableFallDamage = false,

	--- Legacy Main Tab Flower farm settings.
	Old_FlowerFarm = {
		--- Whether or not the Flower Farm should be enabled
		EnableFlowerFarm = false,
		--- Whether or not the hub should automatically hop servers after farming flowers.
		HopServersAfterFarm = false,

		--- The loadstring that will be ran before the teleport. This loads the settings after the fact. This is a blantant copy of the code.
		CustomLoadString = [[
            function GetRequestFunction() return request or (syn and syn.request) or (http and http.request) or http_request end
            function GetRequestBodyFromUrl(urlLink)
                local req = GetRequestFunction()
                if req then
                    local resp = req({ Url = urlLink })
                    if resp.Success then return resp.Body else return game:HttpGet(urlLink)end
                elseif pcall(function()return game.HttpGetend) then
                    print("Using Deprecated Request method")
                    return game:HttpGet(urlLink)
                else
                    error("CANNOT PERFORM REQUEST!!!")
                end
            end

            getgenv().CODEX_HUB_SETTINGS = {
                EnableFlowerFarm = true,
                HopServersAfterFarm = true,
            }

            loadstring(GetRequestBodyFromUrl("https://api.sussy.dev/v1/KeySystem/Assets/GetPublicFile?fileName=Codexus_Hub_loader.lua"), true)()
        ]],
	},

	-- PLAYER SECTION!

	--- Determines whether or not the Infinite Jump feature is enabled.
	EnableInfiniteJump = false,
	--- Determines whether or not the Hacked Walk Speed should be enabled.
	EnableHackedWalkspeed = false,
	--- Determines whether or not the Hacked Jump Power should be enabled.
	EnableHackedJumpPower = false,
	--- Determines whether or not the Anti-AFK should be enabled.
	EnableAntiAFK = false,

	-- MISC SECTION!

	--- Determines whether or not the In-Game console spam disabler should be enabled.
	DisableGamePrintSpam = true,
	--- Determines whether or not the experimental features are enabled on the hub.
	ExperimentsEnabled = true,
	--- Whether or not Codexus Hub should automatically disable the AntiCheat on Arcane Lineage (tl;dr: Adonis Killer)
	DisableAnticheat = true,
}

if getgenv().CODEX_HUB_SETTINGS then
	print("Loaded custom settings!")
	HubSettings = getgenv().CODEX_HUB_SETTINGS
end

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

--- Crashes the obfuscator's Lua bytecode interpreter, if it is obfuscated.
function CrashObfuscatorVM()
	if IsScriptObfuscated() then
		if LPH_OBFUSCATED then
			LPH_CRASH()
		end
		if _77Crash then
			_77Crash()
		end
	end
end

--- Should allow the player to noclip, doesn't work for some reason :headstone:
function Noclip()
	local lp = game:GetService("Players").LocalPlayer
	for i, v in pairs(lp.Character:GetDescendants()) do
		if v:IsA("BasePart") and v.CanCollide == true then
			v.CanCollide = false
		end
	end
end

function DisableNoClip()
	local lp = game:GetService("Players").LocalPlayer
	for i, v in pairs(lp.Character:GetDescendants()) do
		if v:IsA("BasePart") and v.CanCollide == false then
			v.CanCollide = true
		end
	end
end

if getgenv().identifyexecutor and getgenv().identifyexecutor() == "Shadow" then
	--- Hooks a table's metamethod.
	--- Remark: This function will fall-back to raw metatable hooking if hookfunction is not available or is not working!
	--- @param table table The table containing the metatable you wish to hook.
	--- @param metaMethod string The name of the metamethod you wish to hook.
	--- @param newFunction function The function you wish to hook it with.
	function hookmetamethod(table, metaMethod, newFunction)
		local getMt = getrawmetatable or debug.getmetatable

		if not getMt then
			error("The exploit has no getrawmetatable or debug.getmetatable. You cannot use this function.")
		end

		local mt = getMt(table)

		if not mt then
			error("The given table has no valid metatable. Invalid argument 'table' #1")
		end

		-- Some basic metamethod check.
		if not string.match(metaMethod, "__") then
			error("The metamethod given does not seem to be a valid one. Invalid argument '" .. metaMethod .. "' #2")
		end

		-- Make RW if not RW already.
		if isreadonly(mt) then
			-- Make table RW
			setreadonly(mt, false)
		end

		-- Convert the given lclosure into a cclosure automatically if not the case.
		if islclosure(newFunction) then
			newFunction = newcclosure(newFunction)
		end

		--- @type function | nil
		local hookedFunctionOld = nil

		if not hookfunction then
			if rconsoleprint then
				rconsoleprint("[WARN] Lua Init: No hookfunction available! Falled back to raw metatable hooking.")
			end
			hookedFunctionOld = rawget(mt, metaMethod)
			rawset(mt, metaMethod, newFunction)
		else
			hookedFunctionOld = hookfunction(mt[metaMethod], newFunction)
		end
		-- Make RO
		if not isreadonly(mt) then
			setreadonly(mt, true)
		end

		return hookedFunctionOld
	end
	getgenv().hookmetamethod = newcclosure(hookmetamethod)
end

function hopServers(wnd)
	print("Hopping servers...")
	task.spawn(function()
		wnd:Notify({
			Name = "Hopping servers...",
			Text = "The script is hopping servers! Please wait!",
			Duration = 5,
		})
	end)
	local serverHop = (loadstring(
		GetRequestBodyFromUrl("https://api.sussy.dev/v1/KeySystem/Assets/GetPublicFile?fileName=serverhop.lua")
	))()
	local queueTp = queueonteleport or queue_on_teleport

	if not queueTp then
		task.spawn(function()
			wnd:Notify({
				Name = "The script could not be 'prepared' for after the teleport!",
				Text = "Remember to reload it yourself!",
				Duration = 5,
			})
		end)
	else
		queueTp(HubSettings.Old_FlowerFarm.CustomLoadString)
		task.wait(1)
	end

	task.spawn(function()
		serverHop:Teleport(game.PlaceId)
	end)
end

--- Yields the current thread until the next game Heartbeat.
function WaitNextHeartBeat()
	game:GetService("RunService").Heartbeat:Wait()
end

--- Contains all the functions used to modify the player and access the game's state.
--- Remarks -> This is a Singleton.
--- @class PlayerFunctions
local PlayerFunctions = {
	--- The "ReplicatedStorage" Roblox Service.
	--- @type ReplicatedStorage
	ReplicatedStorage = nil,
	--- The "Players" Roblox Service.
	--- @type Players
	PlayerService = nil,
	--- The Local Player.
	--- @type Player
	LocalPlayer = nil,
	--- The local player's GUI.
	--- @type PlayerGui
	PlayerGui = nil,
	--- The telporting service
	--- @type TeleportService
	TeleportService = nil,
}

---Initializes a PlayerFunctions instance.
--- @param self PlayerFunctions Self, instance.
function PlayerFunctions.Initialize(self)
	self.ReplicatedStorage = game:GetService("ReplicatedStorage")
	self.PlayerService = game:GetService("Players")
	self.TeleportService = game:GetService("TeleportService")
	self.LocalPlayer = self.PlayerService.LocalPlayer
	self.PlayerGui = self.LocalPlayer.PlayerGui
end

--- Poppulates a table with the attacks that are available to use for the player and returns it.
--- @param self PlayerFunctions Self, instance.
function PlayerFunctions.GetAttacksTable(self)
	local scrollingFrameSkillsTable =
		self.LocalPlayer.PlayerGui.Combat.ActionBG.AttacksPage.ScrollingFrame:GetChildren()
	local attacksTable = {}

	--- @type Instance
	for _, item in next, scrollingFrameSkillsTable do
		if item.ClassName and item.ClassName == "TextButton" then
			table.insert(attacksTable, item.Name)
		end
	end
	table.insert(attacksTable, #attacksTable)
	return attacksTable
end

--- Gets all the available Weapon skills (Scrapes PlayerGui)
--- @param self PlayerFunctions Self, instance.
function PlayerFunctions.GetWeaponSkillTable(self)
	local screenGuiWeaponSkillsTable = self.PlayerGui.Combat:GetChildren()

	local weaponSkillTable = {}

	for i, v in next, screenGuiWeaponSkillsTable do
		if v.Name:match("QTE") then
			local weapon = v.Name:gsub("QTE", "")
			table.insert(weaponSkillTable, weapon)
		end
	end

	table.insert(weaponSkillTable, #weaponSkillTable)
	return weaponSkillTable
end

--- Gets all the inventory items of the Player.
--- @param self PlayerFunctions Self, instance.
function PlayerFunctions.GetPlayerInventoryItems(self)
	local inventoryItems = {}
	local inventoryElements = self.PlayerGui.Inventory.Inventory:GetChildren()

	for i, v in ipairs(inventoryElements) do
		if v.ClassName == "TextButton" then
			table.insert(inventoryItems, { v.Text, tonumber(v.AmountLabel.Text) })
		end
	end
	return inventoryItems
end

--- Compares the items the player has available with those in their inventory to test and see if they are there.
--- @param self PlayerFunctions Self, instance.
--- @param itemName string The name of the item to check for.
function PlayerFunctions.HasItemOnInventory(self, itemName)
	local inventoryElements = self.PlayerGui.Inventory.Inventory:GetChildren()
	for i, v in ipairs(inventoryElements) do
		if v.ClassName == "TextButton" and v.Text == itemName then
			return true
		end
	end
	return false
end

--- Predicate. Obtain whether or not the player is currently in a fight
--- @param self PlayerFunctions Self, instance.
--- @return boolean isOnFight True if the player is currently on a fight, false if they are not.
function PlayerFunctions.IsOnFight(self)
	local LocalPlayerCharacter = self.LocalPlayer.Character
	return LocalPlayerCharacter and LocalPlayerCharacter:FindFirstChild("FightInProgress")
end
--- Equips an item.
--- @param self PlayerFunctions Self, instance.
--- @param itemName string The name of the item to equip.
function PlayerFunctions.EquipItem(self, itemName)
	self.ReplicatedStorage.Remotes.Information.InventoryManage:FireServer("Equip", itemName)
end

--- Uses an item.
--- @param self PlayerFunctions Self, instance.
--- @param itemName string The name of the item to equip.
function PlayerFunctions.UseItem(self, itemName)
	self.ReplicatedStorage.Remotes.Information.InventoryManage:FireServer("Use", itemName)
end

--- Freezes the Player on place by adding a BodyVelocity Instance onto its HumanoidRootPart.
--- Remarks: THIS FUNCTION WILL LITERALLY FREEZE THE PLAYER!
--- @param self PlayerFunctions Self, instance.
--- @return BodyVelocity bodyVelocity The body velocity that is locking the player tight onto place.
function PlayerFunctions.FreezeLocalPlayerCharacter(self)
	local LocalPlayer = self.LocalPlayer
	local nofall = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("FREEZED_CHAR")
	if nofall then
		return nofall
	end
	nofall = Instance.new("BodyVelocity", LocalPlayer.Character.HumanoidRootPart)
	nofall.Name = "FREEZED_CHAR"
	nofall.Velocity = Vector3.new(0, 0, 0)
	return nofall
end

--- Unfreezes the Player.
--- Remarks: This function will revert what FreezeLocalPlayerCharacter does (obviously)!
--- @param self PlayerFunctions Self, instance.
--- @return boolean unfrozenSuccessfully Whether or not the player was unfrozen successfully.
function PlayerFunctions.UnfreezeLocalPlayerCharacter(self)
	local LocalPlayer = self.LocalPlayer
	local nofallObj = LocalPlayer.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("FREEZED_CHAR")
	if nofallObj then
		nofallObj:Destroy()
		return true
	end
	return false
end

function InitializeHooks()
	-- #region !!!FUNCTION HOOKS!!!

	local oldErr
	oldErr = hookfunction(error, function(...)
		if checkcaller() then
			return oldErr(...)
		elseif HubSettings.DisableGamePrintSpam then
			return
		end

		return oldErr(...)
	end)

	local oldPrint
	oldPrint = hookfunction(print, function(...)
		if checkcaller() then
			return oldPrint(...)
		elseif HubSettings.DisableGamePrintSpam then
			return
		end

		return oldPrint(...)
	end)

	local oldWarn
	oldWarn = hookfunction(warn, function(...)
		if checkcaller() then
			return oldWarn(...)
		elseif HubSettings.DisableGamePrintSpam then
			return
		end

		return oldWarn(...)
	end)
	-- #endregion !!!FUNCTION HOOKS!!!

	-- #region !!!METAMETHOD HOOKS!!!

	local oldDodge
	oldDodge = hookmetamethod(game, "__namecall", function(...)
		local self = select(1, ...)
		local t = select(2, ...)
		local name = select(3, ...)

		if
			(self and t and name == "DodgeMinigame")
			and typeof(t) == "table"
			and getnamecallmethod() == "FireServer"
			and self.Name == "RemoteFunction"
			and HubSettings.EnableAlwaysPerfectDodge
		then
			local newArgs = {
				[1] = { [1] = true, [2] = true },
				[2] = "DodgeMinigame",
			}
			return oldDodge(self, unpack(newArgs))
		end

		return oldDodge(...)
	end)

	local oldNoFall
	oldNoFall = hookmetamethod(game, "__namecall", function(...)
		local self = select(1, ...)
		local remoteName = select(2, ...)
		local remoteValue = select(3, ...)
		if
			not checkcaller()
			and (self and remoteName and remoteValue)
			and getnamecallmethod() == "FireServer"
			and self.Name == "EnviroEffects"
			and typeof(remoteValue) == "number"
			and remoteValue > 0
			and remoteName == "Fall"
			and HubSettings.DisableFallDamage
		then
			return nil
		end
		return oldNoFall(...)
	end)

	local alwaysPerfectQuickTimeEvent
	alwaysPerfectQuickTimeEvent = hookmetamethod(game, "__namecall", function(...)
		local self = select(1, ...)
		local quickTimeEvent = select(3, ...)
		if
			self
			and quickTimeEvent
			and typeof(select(2, ...)) == "boolean"
			and getnamecallmethod() == "FireServer"
			and self.Name == "RemoteFunction"
			and HubSettings.EnableAlwaysPerfectWeaponSkill
		then
			if string.gmatch(quickTimeEvent, "*QTE") then
				return alwaysPerfectQuickTimeEvent(self, unpack({ true, quickTimeEvent }))
			end
		end

		return alwaysPerfectQuickTimeEvent(...)
	end)

	-- #endregion !!!METAMETHOD HOOKS!!!
end

function initializeMainTab(window)
	-- #region Service Imports
	local PlayerService = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local LocalPlayer = PlayerService.LocalPlayer
	local LocalPlayerCharacter = LocalPlayer.Character
	LocalPlayer.CharacterAdded:Connect(function(character)
		LocalPlayerCharacter = character
	end)
	-- #endregion Service Imports

	--- @type Folder
	local MobsFolder = workspace.Living

	local MainTab = window:Tab({
		Name = "Main",
		Description = "~ Codexus Hub ~|~ Press Insert ~",
		Icon = "rbxassetid://11254763826", -- Tab Icon
		Color = Color3.new(0.811765, 0.313725, 0.247059), -- Tab Colour
		Hidden = false, -- IGNORE THIS
	})

	MainTab:Label({
		Text = "Hover over to the left of the GUI to see the other available tabs!",
	})

	--- @type thread | nil
	local levelUpThread = nil
	MainTab:Toggle({
		Name = "Auto Level up [EXPERIMENTAL]",
		Default = false,
		Callback = function(enableLvlup)
			if levelUpThread then
				task.cancel(levelUpThread)
				levelUpThread = nil
			end
			if enableLvlup then
				levelUpThread = task.spawn(function()
					while task.wait(10) do
						--- Gets the cost to level up (tuple of costType[0], quantity[1])
						--- @return number turnNumber The number that represents the cost.
						local function GetLevelupCost(item)
							--- @class LevelUpRequirementType
							local types = {
								["Gold"] = "Gold",
								["Essence"] = "Essence",
							}
							local type = types.Essence
							if item:gmatch("([0-9]+).*g")() then
								-- This is requesting essence
								type = types.Gold
							end
							print()
							-- ([0-9]+) -> Regex Match all NUMBERS!
							return { type, tonumber(item:gmatch("([0-9]+)")()) }
						end

						local function CanLevelUp(cost, typeOfCost)
							if not cost then
								return nil
							end
							if typeOfCost == "Gold" then
								local pMoney =
									tonumber(game:GetService("Players").LocalPlayer.PlayerGui.HUD.Holder.Gold.Text)
								return cost <= pMoney
							elseif typeOfCost == "Essence" then
								local pEssence =
									tonumber(game:GetService("Players").LocalPlayer.PlayerGui.HUD.Holder.Essence.Text)
								return cost <= pEssence
							else
								return nil
							end
						end

						-- TP To mat.
						-- Fake input.
						-- Tp to guy. ( game:GetService("Workspace").NPCs.Aretim (Part) )
						-- Fake Input for dialogue.
						-- Wait for Skill menu (5 seconds)
						-- TIMEDOUT -> Missing requirements
						-- Found -> Fire selection (Get skill points from UI)
						-- Profit.

						local mats = workspace.Mats:GetChildren()

						-- rng num for entropy to avoid tracking of ANY kind.
						local rngN = math.random(1, #mats)

						local selectedMat = mats[rngN]

						local tpPoint = selectedMat:FindFirstChildOfClass("Part")

						game:GetService("Players").LocalPlayer.Character.PrimaryPart.CFrame = tpPoint.CFrame

						local VirtualInputManager = game:GetService("VirtualInputManager")
						task.wait(0.5)
						VirtualInputManager:SendKeyEvent(true, "M", false, nil)
						VirtualInputManager:SendKeyEvent(false, "M", false, nil)
						task.wait(0.5)

						local soulMaster = game:GetService("Workspace").NPCs.Aretim

						repeat
							task.wait(1)
						until game:GetService("Players").LocalPlayer
								:DistanceFromCharacter(soulMaster.CFrame.Position) < 300

						-- OPT -> FREEZE CHAR!
						game:GetService("Players").LocalPlayer.Character.PrimaryPart.CFrame = soulMaster.CFrame

						local pGui = game:GetService("Players").LocalPlayer.PlayerGui
						-- TPd to Aretim, now we want to fire until the Dialog GUI appears.
						repeat
							VirtualInputManager:SendKeyEvent(true, "E", false, nil)
							VirtualInputManager:SendKeyEvent(false, "E", false, nil)
							task.wait(1)
						until pGui:FindFirstChild("NPCDialogue")

						local function triggerLevelup()
							task.wait(0.5)
							local dialogueScreen = pGui:WaitForChild("NPCDialogue")
							if dialogueScreen then
								-- This remote event signals the dialog issued.
								local remoteEvent = dialogueScreen:WaitForChild("RemoteEvent")

								pGui.NPCDialogue.BG:WaitForChild("Options")

								local options = pGui.NPCDialogue.BG.Options:GetChildren()
								local selectedOption
								local refuseOption
								for _, opt in ipairs(options) do
									-- Match for buttons which contain the "Yes" text, to cure us
									if
										opt
										and opt.ClassName == "TextButton"
										and opt.Text:match("Show me his light")
									then
										selectedOption = opt
									else
										refuseOption = opt
									end
								end
								if selectedOption then
									print("found")
									local s = GetLevelupCost(selectedOption.Text)

									local lUpType = s[1]
									local lCost = s[2]

									print(lUpType, lCost)

									if CanLevelUp(lCost, lUpType) then
										remoteEvent:FireServer(selectedOption)
										return true
									else
										remoteEvent:FireServer(refuseOption)
										return false
									end
								else
									return false
								end
							end
						end

						triggerLevelup()
						task.wait(3)

						task.wait(5)
						VirtualInputManager:SendKeyEvent(true, "M", false, nil)
						VirtualInputManager:SendKeyEvent(false, "M", false, nil)
						task.wait(1)
					end
				end)
			end
		end,
	})

	--- @type thread | nil
	local dataRollbackThread = nil

	MainTab:Toggle({
		Name = "Data Rollback",
		Default = false,
		Callback = function(state)
			if dataRollbackThread then
				pcall(task.cancel, dataRollbackThread)
			end
			if state then
				dataRollbackThread = task.spawn(function()
					local maxEntropy = 18
					while task.wait() do
						local selectedEntropyThisCycle = math.random(6, maxEntropy)
						for i = 1, selectedEntropyThisCycle, 1 do
							ReplicatedStorage.Remotes.Data.UpdateHotbar:FireServer({
								[1] = string.char(math.random(129, 255)),
							})
						end
					end
				end)
			end
		end,
	})

	MainTab:Button({
		Name = "Rejoin",
		Callback = function()
			if #PlayerService:GetPlayers() <= 1 then
				PlayerFunctions.PlayerService.LocalPlayer:Kick("Rejoining! This may take some")
				task.wait()
				PlayerFunctions.TeleportService:Teleport(game.PlaceId, PlayerFunctions.LocalPlayer)
			else
				PlayerFunctions.TeleportService:TeleportToPlaceInstance(
					game.PlaceId,
					game.JobId,
					PlayerFunctions.LocalPlayer
				)
			end
		end,
	})

	local merchantChildAddedCnn = nil
	MainTab:Toggle({
		Name = "Teleport to Mysterious Merchant",
		Default = false,
		Callback = function(state)
			if state then
				task.spawn(function()
					window:Notify({
						Name = "Mysterious Merchant Notifier/Teleporter",
						Text = "You will be notified and teleported when the Mysterious Merchant spawns in.",
						Duration = 10,
					})
				end)

				for _, v in ipairs(workspace.NPCs:GetChildren()) do
					if v.Name == "Mysterious Merchant" then
						window:Notify({
							Name = "Mysterious Merchant has Spawned!",
							Text = "Teleporting in 5 seconds...",
							Duration = 5,
						})
						local part = v.PrimaryPart
						if not part then
							part = v:FindFirstChildOfClass("Part")
						end
						if not part then
							part = v:FindFirstChildOfClass("BasePart")
						end
						if not part then
							window:Notify({
								Name = "Mysterious Merchant",
								Text = "Failed to find Mysterious Merchant!",
							})
						end
						LocalPlayerCharacter.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 4, 0)
					end
				end

				merchantChildAddedCnn = workspace.NPCs.ChildAdded:Connect(function(c)
					if c.Name == "Mysterious Merchant" then
						window:Notify({
							Name = "Mysterious Merchant has Spawned!",
							Text = "Teleporting in 5 seconds...",
							Duration = 5,
						})
						local part = c.PrimaryPart
						if not part then
							part = c:FindFirstChildOfClass("Part")
						end
						if not part then
							part = c:FindFirstChildOfClass("BasePart")
						end
						if not part then
							window:Notify({
								Name = "Mysterious Merchant",
								Text = "Failed to find Mysterious Merchant!",
							})
						end
						LocalPlayerCharacter.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 4, 0)
					end
				end)
			else
				if merchantChildAddedCnn then
					merchantChildAddedCnn:Disconnect()
					merchantChildAddedCnn = nil
				end
			end
		end,
	})

	MainTab:Button({
		Name = "Remove Fog",
		Callback = function()
			--- @type Instance Lighting Service Descendant
			for _, instance in pairs(game:GetService("Lighting"):GetDescendants()) do
				instance:Destroy() -- Destroys every effect on the lighting service
			end
		end,
	})

	-- #region Game Printing Hijack
	MainTab:Toggle({
		Name = "Disable game console spam",
		Default = HubSettings.DisableGamePrintSpam,
		Callback = function(state)
			HubSettings.DisableGamePrintSpam = state
		end,
	})

	-- #endregion Game Printing Hijack

	-- #region Auto Attack [SIMPLE]
	local attacksTable = PlayerFunctions:GetAttacksTable()
	local selectedAttack = "Strike" -- Stub to avoid crash.
	local attacksDrop = MainTab:Dropdown({
		Name = "Attacks",
		Items = attacksTable,
		Callback = function(newSelectedAttack)
			selectedAttack = newSelectedAttack
		end,
	})

	MainTab:Button({
		Name = "Refresh dropdown",
		Callback = function()
			attacksDrop:Clear()
			attacksDrop:UpdateList({
				Items = PlayerFunctions:GetAttacksTable(),
				Replace = true, --- Whether or not to clear the dropdown when updating
			}) -- update Dropdown with a list
		end,
	})

	local attackPlayers = false

	MainTab:Toggle({
		Name = "Attack Players [Auto Attack]",
		Default = false,
		Callback = function(state)
			attackPlayers = state
		end,
	})

	local autoStrikeThread = nil
	MainTab:Toggle({
		Name = "Auto Attack",
		Default = false,
		Callback = function(state1)
			if autoStrikeThread then
				task.cancel(autoStrikeThread)
				autoStrikeThread = nil
			end

			if state1 then
				autoStrikeThread = task.spawn(function()
					while task.wait(1) do
						if LocalPlayerCharacter:FindFirstChild("FightInProgress") then
							local Mobs = MobsFolder:GetChildren()
							--- @type nil | table
							local excluded = nil
							if not attackPlayers then
								local playersTable = PlayerService:GetChildren()
								excluded = {}
								-- Not the most efficient filter, but works.
								--- @type Player
								for _, player in ipairs(playersTable) do
									table.insert(excluded, player.Name)
								end
							end

							for i = 1, #Mobs do
								local mob = Mobs[i]
								if not excluded or excluded and not table.find(excluded, mob.Name) then
									local mobFightProg = mob:FindFirstChild("FightInProgress")
									local plrFightProg = LocalPlayerCharacter:FindFirstChild("FightInProgress")
									if
										mob.Name ~= LocalPlayer.Name
										and plrFightProg
										and mobFightProg
										and mobFightProg.Value == plrFightProg.Value
									then
										LocalPlayer.PlayerGui.Combat.CombatHandle.RemoteFunction:InvokeServer(
											"Attack",
											selectedAttack,
											{ ["Attacking"] = mob }
										)
										break
									end
								end
							end
						end
					end
				end)
			end
		end,
	})

	-- #endregion Auto Attack [SIMPLE]

	MainTab:Toggle({
		Name = "Always Perfect Dodge",
		Default = HubSettings.EnableAlwaysPerfectDodge,
		Callback = function(enableAlwaysPerfectBlock)
			HubSettings.EnableAlwaysPerfectDodge = enableAlwaysPerfectBlock
		end,
	})

	MainTab:Toggle({
		Name = "No fall damage",
		Default = HubSettings.DisableFallDamage,
		Callback = function(enableDisableFallDamage)
			HubSettings.DisableFallDamage = enableDisableFallDamage
		end,
	})

	-- #region Automatic Doctor

	--- @type thread | nil
	local autoDoctorThread = false
	MainTab:Toggle({
		Name = "Automatic Doctor (Heals you if you are less health than your max!)",
		Default = HubSettings.AutomaticDoctor,
		Callback = function(state)
			HubSettings.AutomaticDoctor = state

			if autoDoctorThread then
				task.cancel(autoDoctorThread)
				autoDoctorThread = nil
			end
			if state then
				autoDoctorThread = task.spawn(function()
					while task.wait(0.5) do
						if not PlayerFunctions:IsOnFight() then
							local lpHum = LocalPlayerCharacter:FindFirstChildOfClass("Humanoid")
							if lpHum then
								if lpHum.Health ~= lpHum.MaxHealth then
									local old = lpHum.RootPart.CFrame

									local firstDoctor = workspace.NPCs:FindFirstChild("Doctor")
									--- @type Part
									local tpPoint = firstDoctor:FindFirstChild("Head")

									if not tpPoint then
										firstDoctor:FindFirstChild("HumanoidRootPart")
									end

									if not tpPoint then
										tpPoint = firstDoctor:FindFirstChild("Torso")
									end

									PlayerFunctions:FreezeLocalPlayerCharacter()
									lpHum.RootPart.CFrame = tpPoint.CFrame
									task.wait(0.5)
									-- #region Heal Player (LOGIC)
									local VirtualInputManager = game:GetService("VirtualInputManager")
									local pGui = LocalPlayer.PlayerGui

									repeat
										print("TRIGGERING_NPC_DIALOG")
										-- FAKE INPUT
										VirtualInputManager:SendKeyEvent(true, "E", false, nil)
										VirtualInputManager:SendKeyEvent(false, "E", false, nil)
										task.wait(0.1)
									until pGui:FindFirstChild("NPCDialogue")
									-- SCRAPE UI INFO AND AUTOMATICALLY INTERACT!

									task.wait(0.5)
									local dialogueScreen = pGui:WaitForChild("NPCDialogue")
									if dialogueScreen then
										-- This remote event signals the dialog issued.
										local remoteEvent = dialogueScreen:WaitForChild("RemoteEvent")

										pGui.NPCDialogue.BG:WaitForChild("Options")

										local options = pGui.NPCDialogue.BG.Options:GetChildren()
										local selectedOption
										for _, opt in ipairs(options) do
											-- Match for buttons which contain the "Yes" text, to cure us
											if opt and opt.ClassName == "TextButton" and opt.Text:match("Yes") then
												selectedOption = opt
												break
											end
										end
										if selectedOption then
											remoteEvent:FireServer(selectedOption)
										else
											print("FAILED TO FIND")
										end
									end
									-- #endregion Heal Player (LOGIC)
									lpHum.RootPart.CFrame = old
									PlayerFunctions:UnfreezeLocalPlayerCharacter()
								end
							else
								task.wait(1) -- Wait longer
							end
						end
					end
				end)
			end
		end,
	})

	-- #endregion Automatic Doctor
	MainTab:Toggle({
		Name = "Always Perfect Weapon Skill",
		Default = HubSettings.EnableAlwaysPerfectWeaponSkill,
		Callback = function(enableAlwaysPerfectSkill)
			HubSettings.EnableAlwaysPerfectWeaponSkill = enableAlwaysPerfectSkill
		end,
	})

	MainTab:Button({
		Name = "Hop Server",
		Callback = function()
			hopServers(window)
		end,
	})

	--- @type RBXScriptConnection
	local walkInFightsConnection
	MainTab:Toggle({
		Name = "Be able to walk during fights",
		Default = false,
		Callback = function(enableWalkInFights)
			if walkInFightsConnection then
				walkInFightsConnection:Disconnect()
				walkInFightsConnection = nil
			end
			if enableWalkInFights then
				walkInFightsConnection = RunService.Stepped:Connect(function()
					if LocalPlayerCharacter.PrimaryPart.Anchored == true then
						LocalPlayerCharacter.PrimaryPart.Anchored = false
					end
				end)
			end
		end,
	})

	--[[
        MainTab:Button({
            Name = "[Fast Wipe]",
            Callback = function()
                LocalPlayerCharacter.Humanoid.Health = 0
                window:Notify({
                    Name = "Notification",
                    Text = "This was supposed to be god mode but patched sorry guys",
                    Duration = 20,
                })
            end
        })
    ]]
	local inventoryTable = {}
	for _, itemTable in next, PlayerFunctions:GetPlayerInventoryItems() do
		local itemName = itemTable[1]
		table.insert(inventoryTable, itemName)
	end
	table.insert(inventoryTable, #inventoryTable)
	local targetItem = inventoryTable[1]
	table.freeze(inventoryTable)
	MainTab:Dropdown({
		Name = "Select Item",
		Items = inventoryTable,
		Callback = function(selectedItem)
			targetItem = selectedItem
		end,
	})

	MainTab:Button({
		Name = "Refresh Dropdown",
		Callback = function()
			if table.isfrozen(inventoryTable) then
				setreadonly(inventoryTable, false)
			end -- Ignore immutability of list.
			table.clear(inventoryTable)
			for _, itemTable in next, PlayerFunctions:GetPlayerInventoryItems() do
				local itemName = itemTable[1]
				table.insert(inventoryTable, itemName)
			end
			table.insert(inventoryTable, #inventoryTable)
			targetItem = inventoryTable[1]
			table.freeze(inventoryTable)
		end,
	})

	--- @type number
	local dropRate = 3
	MainTab:Slider({
		Name = "Drop rate",
		Min = 5,
		Max = 50,
		Default = 20,
		Callback = function(selectedDropRate)
			dropRate = selectedDropRate
		end,
	})

	--- @type thread | nil
	local autoDropThread = nil
	MainTab:Toggle({
		Name = "Auto Drop",
		Default = false,
		Callback = function(state)
			if autoDropThread then
				task.cancel(autoDropThread)
				autoDropThread = nil
			end
			if state then
				local remote = ReplicatedStorage:WaitForChild("Remotes")
					:WaitForChild("Information")
					:WaitForChild("InventoryManage")
				autoDropThread = task.spawn(function()
					while task.wait(1) do
						for i = 0, dropRate do
							remote:FireServer("Drop", targetItem)
						end
					end
				end)
			end
		end,
	})
end

function initializeTeleports(window)
	-- #region Service Imports
	local PlayerService = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local LocalPlayer = PlayerService.LocalPlayer
	local LocalPlayerCharacter = LocalPlayer.Character
	LocalPlayer.CharacterAdded:Connect(function(character)
		LocalPlayerCharacter = character
	end)
	-- #endregion Service Imports

	local TeleportTab = window:Tab({
		Name = "Teleports",
		Description = "Some Teleports",
		Icon = "rbxassetid://6034684937", -- Tab Icon
		Color = Color3.new(0.349019, 0, 1), -- Tab Colour
		Hidden = false, -- IGNORE THIS
	})

	local Spawns = { "Caldera", "Blades", "Ruins", "Westwood", 3 }
	local QuestNPCSTable = { "ReaperSpike", "Hythera", "Narthana" }
	local NPCSTable = { "Aretim", "PurgNPC" }

	for i, v in pairs(workspace.NPCs.Quest:GetChildren()) do
		if v:IsA("Model") then
			table.insert(QuestNPCSTable, v.Name)
		end
	end
	for i, v in pairs(workspace.NPCs:GetChildren()) do
		if v:IsA("Model") then
			table.insert(NPCSTable, v.Name)
		end
	end

	TeleportTab:Dropdown({
		Name = "Spawns",
		Items = Spawns,
		Callback = function(spawnPointName)
			-- @type Folder
			local spawns = workspace.Spawns

			local spawnPoint = spawns:FindFirstChild(spawnPointName, true)

			for _, child in pairs(spawnPoint:GetDescendants()) do
				if child:IsA("ProximityPrompt") then
					LocalPlayerCharacter.PrimaryPart.CFrame = spawnPoint.CFrame
					child.HoldDuration = 0
					-- Users don't want to enter Soul selection.
					--[[
                        task.wait(0.25);
                        fireproximityprompt(child);
                        task.wait(0.25);
                    ]]
				end
			end
		end,
	})
	TeleportTab:Dropdown({
		Name = "Quest NPCs",
		Items = QuestNPCSTable,
		Callback = function(npcQuest)
			--- @type Folder
			local folder = workspace.NPCs.Quest

			local questNpc = folder:FindFirstChild(npcQuest)

			if not questNpc then
				window:Notify({
					Name = "Whoops!",
					Text = "This is funny. We have failed to find " .. npcQuest .. " we are sorry...",
					Duration = 5,
				})
				return -- Ret
			end

			LocalPlayerCharacter.PrimaryPart.CFrame = questNpc.PrimaryPart.CFrame
		end,
	})

	TeleportTab:Dropdown({
		Name = "NPC Teleports",
		Items = NPCSTable,
		Callback = function(npcName)
			--- @type Folder
			local folder = workspace.NPCs

			local npc = folder:FindFirstChild(npcName)

			if not npc then
				window:Notify({
					Name = "Whoops!",
					Text = "This is funny. We have failed to find " .. npcName .. " we are sorry...",
					Duration = 5,
				})
				return -- Ret
			end

			LocalPlayerCharacter.PrimaryPart.CFrame = npc.PrimaryPart.CFrame
		end,
	})
end

function initializePlayer(window)
	-- #region Service Imports
	local PlayerService = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local LocalPlayer = PlayerService.LocalPlayer
	local LocalPlayerCharacter = LocalPlayer.Character
	LocalPlayer.CharacterAdded:Connect(function(character)
		LocalPlayerCharacter = character
	end)
	-- #endregion Service Imports

	local PlayerTab = window:Tab({
		Name = "Player",
		Description = "Player Tab",
		Icon = "rbxassetid://6031215978", -- Tab Icon
		Color = Color3.new(1, 0.968627, 0), -- Tab Colour
		Hidden = false, -- IGNORE THIS
	})

	PlayerTab:Button({
		Name = "Reset Character",
		Callback = function()
			LocalPlayerCharacter.Humanoid.Health = 0
		end,
	})

	--- @type RBXScriptConnection | nil
	local noclipConnection = nil
	PlayerTab:Toggle({
		Name = "Noclip",
		Default = false,
		Callback = function(enableNoClip)
			if noclipConnection then
				noclipConnection:Disconnect()
				noclipConnection = nil
			end

			if enableNoClip then
				noclipConnection = game:GetService("RunService").Stepped:Connect(function()
					Noclip()
				end)
			end
		end,
	})

	local infiniteJumpConnection = nil
	PlayerTab:Toggle({
		Name = "Infinite Jump",
		Default = HubSettings.EnableInfiniteJump,
		Callback = function(enableInfiniteJump)
			HubSettings.EnableInfiniteJump = enableInfiniteJump
			if infiniteJumpConnection then
				infiniteJumpConnection:Disconnect()
			end
			if enableInfiniteJump then
				infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
					if LocalPlayerCharacter and LocalPlayerCharacter:FindFirstChild("Humanoid") then -- First humanoid found; hijack the second humanoid.
						LocalPlayerCharacter.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
						--- @type Humanoid
						local puppetHumanoid = LocalPlayerCharacter:FindFirstChild("Hum", true)
						puppetHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
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

	--- @type RBXScriptConnection | nil
	local jumpPowerSteppedConnection = nil
	PlayerTab:Toggle({
		Name = "Enable Hacked Jumppower",
		Default = HubSettings.EnableHackedJumpPower,
		Callback = function(enableHackedJp)
			HubSettings.EnableHackedJumpPower = enableHackedJp

			if not HubSettings.EnableHackedJumpPower and jumpPowerSteppedConnection then
				jumpPowerSteppedConnection:Disconnect()
			end
		end,
	})

	PlayerTab:Slider({
		Name = "Jump Power",
		Default = LocalPlayerCharacter.Humanoid.JumpPower,
		Min = 16,
		Max = 300,
		Callback = function(newJumpPower)
			if jumpPowerSteppedConnection then
				jumpPowerSteppedConnection:Disconnect()
			end
			if HubSettings.EnableHackedJumpPower then
				jumpPowerSteppedConnection = RunService.Heartbeat:Connect(function()
					if LocalPlayerCharacter and LocalPlayerCharacter:FindFirstChild("Humanoid") then
						LocalPlayerCharacter.Humanoid.JumpPower = newJumpPower
					end
				end)
			end
		end,
	})

	--- @type RBXScriptConnection | nil
	local walkspeedSteppedConnection = nil
	PlayerTab:Toggle({
		Name = "Enable Hacked Walkspeed",
		Default = HubSettings.EnableHackedWalkspeed,
		Callback = function(enableHackedWs)
			HubSettings.EnableHackedWalkspeed = enableHackedWs
			if not enableHackedWs and walkspeedSteppedConnection then
				walkspeedSteppedConnection:Disconnect()
			end
		end,
	})

	PlayerTab:Slider({
		Name = "Walkspeed",
		Default = LocalPlayerCharacter.Humanoid.WalkSpeed,
		Min = 16,
		Max = 300,
		Callback = function(newWalkspeed)
			if walkspeedSteppedConnection then
				walkspeedSteppedConnection:Disconnect()
			end
			if HubSettings.EnableHackedWalkspeed then
				walkspeedSteppedConnection = RunService.Stepped:Connect(function()
					if LocalPlayerCharacter and LocalPlayerCharacter:FindFirstChild("Humanoid") then
						LocalPlayerCharacter.Humanoid.WalkSpeed = newWalkspeed
					end
				end)
			end
		end,
	})

	local idleConnection = nil
	local DISCONNECTED_AFK_CNN = false
	PlayerTab:Toggle({
		Name = "Anti AFK",
		Default = HubSettings.EnableAntiAFK,
		Callback = function(antiAfkState)
			HubSettings.EnableAntiAFK = antiAfkState
			if idleConnection then
				idleConnection:Disconnect()
				idleConnection = nil
			end

			if antiAfkState then
				local VirtualUser = game:GetService("VirtualUser")

				if not DISCONNECTED_AFK_CNN then
					DISCONNECTED_AFK_CNN = true
					print("[AFK] Disabled Connections to LP.IDLED!")
					local connections = getconnections(LocalPlayer.Idled)

					for _, v in ipairs(connections) do
						v:Disable()
					end
				end

				idleConnection = LocalPlayer.Idled:Connect(function()
					VirtualUser:CaptureController()
					VirtualUser:ClickButton2(Vector2.new())
					task.spawn(function()
						window:Notify({
							Name = "Anti AFK Triggered!",
							Text = "Roblox attempted to kick you, but the anti afk prevented it :)",
						})
					end)
				end)
			end
		end,
	})
end

function initalizeAutomatics(window)
	-- #region Service Imports
	local PlayerService = game:GetService("Players")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local LocalPlayer = PlayerService.LocalPlayer
	local LocalPlayerCharacter = LocalPlayer.Character
	LocalPlayer.CharacterAdded:Connect(function(character)
		LocalPlayerCharacter = character
	end)
	-- #endregion Service Imports

	local AutoTab = window:Tab({
		Name = "Automatics",
		Description = "Automatics tab",
		-- Icon = "rbxassetid://6031215978", -- Tab Icon
		Color = Color3.new(1, 0.968627, 0), -- Tab Colour
		Hidden = false, -- IGNORE THIS
	})

	-- #region Automatic Potion Brewing

	local waitBetweenBrews = 0
	AutoTab:Slider({
		Name = "Wait between adding ingredients (ms)",
		Min = 0,
		Max = 200,
		Default = 16,
		Callback = function(brewWait)
			if brewWait == 0 then
				waitBetweenBrews = 0
				return
			end
			waitBetweenBrews = brewWait / 1000
		end,
	})

	local potionsRecipes = {
		["Abhorrent Elixir"] = { "Everthistle", "Everthistle", "Cryastem" },
		["Alluring Elixir"] = { "Everthistle", "Everthistle", "Carnastool" },
		["Ferrus Skin Potion"] = {
			"Carnastool",
			"Carnastool",
			"Sand Core",
			"Mushroom Cap",
		},
		["Heartbreaking Elixir"] = {
			"Everthistle",
			"Everthistle",
			"Everthistle",
			"Carnastool",
		},
		["Invisibility Potion"] = {
			"Driproot",
			"Driproot",
			"Everthistle",
			"Haze Chunk",
		},
		["Minor Absortion Potion"] = { "Hightail", "Mushroom Cap" },
		["Heartstoothing Remedy"] = {
			"Everthistle",
			"Everthistle",
			"Everthistle",
			"Cryastem",
		},
		["Minor Energy Elixir"] = { "Everthistle", "Carnastool" },
		["Minor Empowering Elixir"] = { "Sand Core", "Cryastem", "Carnastool" },
		["Small Health Potion"] = { "Everthistle", "Slime Chunk" },
		["Light of Grace"] = {
			"Phoenix Tear",
			"Crylight",
			"Haze Chunk",
			"Sand Core",
			"Driproot",
		},
	}
	local potionsTable = {
		"Abhorrent Elixir",
		"Alluring Elixir",
		"Ferrus Skin Potion",
		"Heartbreaking Elixir",
		"Invisibility Potion",
		"Minor Absortion Potion",
		"Heartstoothing Remedy",
		"Minor Energy Elixir",
		"Minor Empowering Elixir",
		"Small Health Potion",
		"Light of Grace",
	}
	table.insert(potionsTable, #potionsTable) -- Insert num, bebo UI weirdness lmao.
	local selectedPotionName = "Abhorrent Elixir"
	local selectedPotion = { "Everthistle", "Everthistle", "Cryastem" }
	AutoTab:Dropdown({
		Name = "Potion List",
		Items = potionsTable,
		Callback = function(selectedPotionElement)
			selectedPotion = potionsRecipes[selectedPotionElement]
			selectedPotionName = selectedPotionElement
		end,
	})

	local autoPotionThread = nil
	AutoTab:Toggle({
		Name = "Auto Brew Potion",
		Default = false,
		Callback = function(enableAutoPotion)
			if autoPotionThread then
				task.cancel(autoPotionThread)
				autoPotionThread = nil
			end

			if enableAutoPotion then
				autoPotionThread = task.spawn(function()
					local requiredIngredients = selectedPotion
					local foundIngredientsOnInv = {}
					for _, itemTable in next, PlayerFunctions:GetPlayerInventoryItems() do
						local requiredAmount = 0
						local itemName = itemTable[1]
						local itemAmount = itemTable[2]
						for i = 1, #requiredIngredients do
							if itemName == requiredIngredients[i] then
								requiredAmount = 1 + requiredAmount
								table.insert(foundIngredientsOnInv, itemName)
							end
						end

						print("Required " .. requiredAmount .. " of " .. itemName)

						if requiredAmount > itemAmount then
							task.spawn(function()
								window:Notify({
									Name = "Auto Brew Potion",
									Text = "This potion requires "
										.. requiredAmount
										.. " of "
										.. itemName
										.. " but you only have "
										.. itemAmount
										.. " of it!",
									Duration = 20,
								})
							end)
							return
						end
					end

					if #requiredIngredients ~= #foundIngredientsOnInv then
						task.spawn(function()
							window:Notify({
								Name = "Auto Brew Potion",
								Text = "This potion requires an ingredient you do not have, becuase of it, you can not brew it.",
								Duration = 15,
							})
						end)
						return
					end

					local canBrew = true
					local selectedCauldronForBrewing = workspace.Cauldrons:FindFirstChild("Cauldron")
					task.wait(1)
					LocalPlayerCharacter.PrimaryPart.CFrame = selectedCauldronForBrewing.Water.CFrame
						+ Vector3.new(0, 8, 0)

					local ingredientAddProximityPrompt = selectedCauldronForBrewing.Water.ProximityPrompt
					local mixIngredientsClickDetector = selectedCauldronForBrewing.Stick.ClickDetector
					while canBrew do
						local requiredIngredients = selectedPotion
						local foundIngredientsOnInv = {}
						for _, itemTable in next, PlayerFunctions:GetPlayerInventoryItems() do
							local requiredAmount = 0
							local itemName = itemTable[1]
							local itemAmount = itemTable[2]
							for i = 1, #requiredIngredients do
								if itemName == requiredIngredients[i] then
									requiredAmount = 1 + requiredAmount
									table.insert(foundIngredientsOnInv, itemName)
								end
							end

							print("Required " .. requiredAmount .. " of " .. itemName)

							if requiredAmount > itemAmount then
								task.spawn(function()
									window:Notify({
										Name = "Auto Brew Potion",
										Text = "This potion requires "
											.. requiredAmount
											.. " of "
											.. itemName
											.. " but you only have "
											.. itemAmount
											.. " of it!",
										Duration = 20,
									})
								end)
								canBrew = false
								return
							end
						end

						if #requiredIngredients ~= #foundIngredientsOnInv then
							task.spawn(function()
								window:Notify({
									Name = "Auto Brew Potion",
									Text = "This potion requires an ingredient you do not have, becuase of it, you can not brew it.",
									Duration = 15,
								})
							end)
							return
						end

						local Cam = workspace.CurrentCamera
						local Pos = LocalPlayerCharacter.PrimaryPart.Position
						local lookAt = selectedCauldronForBrewing.Water.Position

						local oldCameraCFrame = Cam.CFrame
						Cam.CFrame = CFrame.new(Pos, lookAt)

						task.spawn(function()
							window:Notify({
								Name = "Auto Brew Potion",
								Text = "Resetting Cauldron...",
								Duration = 5,
							})
						end)
						-- Reset cauldron
						fireclickdetector(mixIngredientsClickDetector)
						task.wait(0.01)

						-- We are assured to have the ingredients, move your ass, put the element in your hand, and start cooking jessie.
						for i = 1, #requiredIngredients do
							-- The ingredients are named, so we can use remotes to equip.
							local actionName = "Equip"
							local itemName = requiredIngredients[i]

							game:GetService("ReplicatedStorage").Remotes.Information.InventoryManage
								:FireServer(actionName, itemName)

							task.spawn(function()
								window:Notify({
									Name = "Auto Brew Potion",
									Text = "Adding " .. itemName .. " to Cauldron...",
									Duration = 5,
								})
							end)

							task.wait(0.01 + waitBetweenBrews)

							fireproximityprompt(ingredientAddProximityPrompt)
							task.wait(0.05 + waitBetweenBrews) -- Lease time...
						end

						task.spawn(function()
							window:Notify({
								Name = "Auto Brew Potion",
								Text = "Mixing Cauldron...",
								Duration = 5,
							})
						end)
						task.wait(0.064)
						fireclickdetector(mixIngredientsClickDetector)
						Cam.CFrame = oldCameraCFrame
						task.spawn(function()
							window:Notify({
								Name = "Auto Brew Potion",
								Text = selectedPotionName .. " has been brewed. Continuing to brew it!",
								Duration = 5,
							})
						end)
					end
				end)
			end
		end,
	})
	-- #endregion Automatic Potion Brewing

	if HubSettings.ExperimentsEnabled then
		--- @type RBXScriptConnection | nil
		local connection = nil
		AutoTab:Toggle({
			Name = "Enable Dropped Items Watcher/Teleporter",
			Default = false,
			Callback = function(state)
				if connection then
					connection:Disconnect()
					connection = nil
				end
				if state then
					local droppedFolder = workspace:FindFirstChild("Dropped")
					local lock = false
					connection = droppedFolder.ChildAdded:Connect(function(child)
						repeat
							task.wait(0.2)
						until not lock

						lock = true
						xpcall(function()
							task.spawn(function()
								window:Notify({
									Name = "Dropped Items Watcher",
									Text = "An item has been dropped. Teleporting to it...",
									Duration = 5,
								})
							end)
							local ogCoordFrame = LocalPlayerCharacter.PrimaryPart.CFrame

							local part = child.PrimaryPart
							if not part then
								part = child:FindFirstChildWhichIsA("Part", true)
							end
							if not part then
								part = child:FindFirstChildWhichIsA("BasePart", true)
							end
							if not part then
								window:Notify({
									Name = "Dropped Items Watcher",
									Text = "Can not teleport! The dropped item has no Instance with a CFrame on it!",
									Duration = 5,
								})
								return
							end

							PlayerFunctions:FreezeLocalPlayerCharacter()

							LocalPlayerCharacter.PrimaryPart.CFrame = part.CFrame + Vector3.new(0, 1, 0)
							task.wait(0.5)
							LocalPlayerCharacter.PrimaryPart.CFrame = ogCoordFrame
							PlayerFunctions:UnfreezeLocalPlayerCharacter()
						end, function()
							window:Notify({
								Name = "Dropped Items Watcher",
								Text = "Whoops! The Dropped Items Watcher has faced an exception...",
								Duration = 5,
							})
						end)
						lock = false
					end)
					local ogCoordFrame = LocalPlayerCharacter.PrimaryPart.CFrame

					for _, item in pairs(droppedFolder:GetChildren()) do
						local part = item.PrimaryPart
						if not part then
							part = item:FindFirstChildWhichIsA("Part", true)
						end
						if not part then
							part = item:FindFirstChildWhichIsA("BasePart", true)
						end

						if not part then
							window:Notify({
								Name = "Dropped Items Watcher",
								Text = "Can not teleport! The dropped item has no Instance with a CFrame on it!",
								Duration = 5,
							})
						end

						if part then
							PlayerFunctions:FreezeLocalPlayerCharacter()

							LocalPlayerCharacter.PrimaryPart.CFrame = part.CFrame + Vector3.new(0, 1, 0)
							task.wait(0.5)
						end
					end

					LocalPlayerCharacter.PrimaryPart.CFrame = ogCoordFrame
					PlayerFunctions:UnfreezeLocalPlayerCharacter()
				end
			end,
		})
	end

	-- #region Automatic Farm

	if true then
		AutoTab:Label({ Text = "~~~ Automatic Farming Settings ~~~" })
		--- @class TargetTypes
		local TargetTypes = {
			["LowestHealth"] = "LowestHealth",
			["MostHealth"] = "MostHealth",
		}
		--- The different settings the FSM can use to change its behaviour.
		--- @class AutoFarmFSMSettings
		local AutoFarmFSMSettings = {
			--- Use the attacks in a smart manner, choosing the most powerful attack (Greedy).
			["SmartAttackUsage"] = false,
			--- The target the FSE will prioritise.
			["TargetType"] = TargetTypes.LowestHealth,
			--- The health in which the player is considered to be in a warning state, they should heal!
			["WarningHealth"] = 20,
			--- The health in which the player is considered to be in danger.
			["DangerHealth"] = 10,
			--- The amount of movements the player should attempt before attempting to escape a fight.
			["MovementsBeforeFleeing"] = 25,
			--- Whether or not the doctor should be abused for free healing.
			["UseDoctorHeal"] = true,
			--- Whether or not the Auto Level Up module should be enabled
			["EnableAutoLevelUp"] = true,
			--- The distribution of the skills (Sent as Remote parameters)!
			["SkillDistribution"] = { 0, 0, 0, 0, 0 },
			--- The area to farm at; this is an Instance. Not a string.
			["FarmArea"] = nil,
			--- The probability that a Level Up attempt happens.
			["LevelUpChance"] = 50,
		}

		--- The different actions the FSM can use during fights.
		--- @class AutoFarmFSMActions
		local AutoFarmFSMActions = {
			--- The FSM will attack.
			["Attack"] = "Attack",
			--- The FSM will use an item to help their controlled player.
			["UseItem"] = "UseItem",
			--- The FSM should run away from combat; they yield.
			["Escape"] = "Escape",
			--- The FSM has either lost its reference to the puppet humanoid, or the player has died.
			["Dead"] = "Dead",
		}

		--- The different states the Farming FSM can be at at any given time.
		--- This is basically an Enum, but in a table. Thank lua.
		--- @class AutoFarmFSMStates
		local AutoFarmFSMStates = {
			--- The FSM can change to SearchingFight.
			["Idle"] = "Idle",
			--- The FSM can change to Idle and OnFight.
			["SearchingFight"] = "SearchingFight",
			--- The FSM can change to SearchingFight, Attacking, Defending and Healing.
			["Fighting"] = "Fighting",
		}

		--- Definition for the AttackData class.
		--- @class AttackData
		local ATTACK_DATA_DEFINITION = {
			--- Marks the name of the attack.
			AttackName = "",
			--- Marks if the current attack is usable.
			IsAttackUsable = false,
			--- Marks in how many in-game turns the attack will be usable
			UsableIn = 0,
		}

		local priortyLabelText = "Chosen Attacks: Strike, "
		local priorityTableReference = nil
		local possibleAttacks = PlayerFunctions:GetAttacksTable()

		--- The list by priority for attacks.
		local selectedAttacks = { "Strike" }
		local attacksDrop = AutoTab:Dropdown({
			Name = "Attacks",
			Items = possibleAttacks,
			Callback = function(newSelectedAttack)
				-- Only add if it is not already added!
				if not table.find(selectedAttacks, newSelectedAttack) then
					table.insert(selectedAttacks, newSelectedAttack)
					if priorityTableReference then
						priortyLabelText = priortyLabelText .. newSelectedAttack .. ", "
						priorityTableReference:SetText(priortyLabelText)
					end
				end
			end,
		})

		AutoTab:Button({
			Name = "Refresh dropdown (Will clear list!)",
			Callback = function()
				attacksDrop:Clear()
				attacksDrop:UpdateList({
					Items = PlayerFunctions:GetAttacksTable(),
					Replace = true,
				})
				selectedAttacks = {}
				priortyLabelText = "Chosen Attacks: "
				if priorityTableReference then
					priorityTableReference:SetText(priortyLabelText)
				end
			end,
		})

		AutoTab:Button({
			Name = "Clear chosen usable attacks",
			Callback = function()
				selectedAttacks = {}
				priortyLabelText = "Chosen Attacks: "
				if priorityTableReference then
					priorityTableReference:SetText(priortyLabelText)
				end
			end,
		})

		priorityTableReference = AutoTab:Label({ Text = priortyLabelText })
		AutoTab:Slider({
			Name = "Limit before Escaping",
			Min = 20,
			Max = 300,
			Default = 20,
			Callback = function(val)
				AutoFarmFSMSettings.MovementsBeforeFleeing = val
			end,
		})

		AutoTab:Dropdown({
			Name = "Attack Priority (Target) ->",
			Items = { TargetTypes.LowestHealth, TargetTypes.MostHealth, 2 },
			--- @param selected TargetTypes Target type.
			Callback = function(selected)
				AutoFarmFSMSettings.TargetType = selected
			end,
		})

		--- Marks whether or not the FSM should ignore smart attacks and use the Greedy algorithm for deciding attacks..
		AutoTab:Toggle({
			Name = "Use Provided Attack List",
			Default = false,
			Callback = function(s)
				AutoFarmFSMSettings.SmartAttackUsage = s
			end,
		})

		--- Marks whether or not the FSM should attempt to heal using the in-game free healing (Doctor)
		AutoTab:Toggle({
			Name = "Use Doctor for Healing",
			Default = true,
			Callback = function(s)
				AutoFarmFSMSettings.UseDoctorHeal = s
			end,
		})

		AutoTab:Dropdown({
			Name = "Attack Priority (Target) ->",
			Items = { TargetTypes.LowestHealth, TargetTypes.MostHealth, 2 },
			--- @param selected TargetTypes Target type.
			Callback = function(selected)
				AutoFarmFSMSettings.TargetType = selected
			end,
		})

		local farmingAreas = {}
		local FOUND_LIST_IGNORE = {}

		for _, val in ipairs(workspace.Encounters:GetChildren()) do
			if not table.find(FOUND_LIST_IGNORE, val.Name) then
				table.insert(farmingAreas, val)
				table.insert(FOUND_LIST_IGNORE, val.Name)
			end
		end
		table.insert(farmingAreas, #farmingAreas)
		AutoFarmFSMSettings.FarmArea = farmingAreas[1]
		AutoTab:Dropdown({
			Name = "Farming Area",
			Items = farmingAreas,
			Callback = function(selected)
				AutoFarmFSMSettings.FarmArea = selected
			end,
		})

		AutoTab:Toggle({
			Name = "Enable Auto Level Up [WARNING: BANNABLE!]",
			Default = false,
			Callback = function(state)
				AutoFarmFSMSettings.EnableAutoLevelUp = state
			end,
		})

		AutoTab:Slider({
			Name = "Level Up Attempt Probability",
			Min = 0,
			Max = 100,
			Default = AutoFarmFSMSettings.LevelUpChance,
			Callback = function(val)
				AutoFarmFSMSettings.LevelUpChance = val
			end,
		})
		--- @type boolean | nil
		local enableExtendedSkills = nil
		AutoTab:Toggle({
			Name = "Enable extended skill distribution (Allows 4 skills to be used)",
			Default = false,
			Callback = function(state)
				enableExtendedSkills = state
			end,
		})

		local textRef = "Selected Level Up ->"
		local textRefOg = textRef
		priorityTableReference = AutoTab:Label({ Text = textRef })

		local levelUps = { "Strength", "Arcane", "Endurance", "Speed", "Luck", 5 }
		AutoTab:Dropdown({
			Name = "Level Up [Skill Select]",
			Items = levelUps,
			Callback = function(selected)
				local sum = 0
				for i, v in ipairs(AutoFarmFSMSettings.SkillDistribution) do
					sum = v + sum
				end

				if (sum > 2 and not enableExtendedSkills) or (sum > 3 and enableExtendedSkills) then
					window:Notify({
						Name = "You may allocate a certain amount of skills",
						Text = "You may only allocate three skills. Four if extended with the toggle. Trying to bypass this results in an in-game ban!",
						Duration = 10,
					})
					return
				end

				if selected == "Strength" then
					textRef = textRef .. " Strength, "
					AutoFarmFSMSettings.SkillDistribution[1] = AutoFarmFSMSettings.SkillDistribution[1] + 1
				elseif selected == "Arcane" then
					textRef = textRef .. " Arcane, "
					AutoFarmFSMSettings.SkillDistribution[2] = AutoFarmFSMSettings.SkillDistribution[2] + 1
				elseif selected == "Endurance" then
					textRef = textRef .. " Endurance, "
					AutoFarmFSMSettings.SkillDistribution[3] = AutoFarmFSMSettings.SkillDistribution[3] + 1
				elseif selected == "Speed" then
					textRef = textRef .. " Speed, "
					AutoFarmFSMSettings.SkillDistribution[4] = AutoFarmFSMSettings.SkillDistribution[4] + 1
				elseif selected == "Luck" then
					textRef = textRef .. " Luck, "
					AutoFarmFSMSettings.SkillDistribution[5] = AutoFarmFSMSettings.SkillDistribution[5] + 1
				end
				priorityTableReference:SetText(textRef)
			end,
		})

		AutoTab:Button({
			Name = "Clear Level Up skills",
			Callback = function()
				AutoFarmFSMSettings.SkillDistribution = { 0, 0, 0, 0, 0 }
				priorityTableReference:SetText(textRefOg)
				textRef = textRefOg
			end,
		})

		--- @type thread | nil
		local autoFarmThread = nil
		local autoFarmKill = true
		AutoTab:Toggle({
			Name = "Auto Farm",
			Default = false,
			Callback = function(state)
				if autoFarmThread then
					autoFarmKill = true
					autoFarmThread = nil
				end

				if state then
					autoFarmKill = false
					autoFarmThread = task.spawn(function()
						local currentState = AutoFarmFSMStates.Idle
						local previousState = AutoFarmFSMStates.Idle
						local MobsFolder = workspace.Living

						--- This function iterates through all "Living" things in the Workspace, and compares their FightInProgress values to see who is with and against who in fights.
						--- @param player Model The player model.
						--- @param includePlayers boolean Whether or not this should include players.
						--- @return table Returns a table containing all "Living" things that are fighting the given player. Zero if there are none. The table is of type Model
						local function GetMobsOnFightWith(player, includePlayers)
							local isOnFight = player:FindFirstChild("FightInProgress")

							if not isOnFight then
								return table.create(0, nil)
							end
							local excludees = nil
							if not includePlayers then
								excludees = {}
								for _, v in ipairs(PlayerService:GetChildren()) do
									--- @type Player
									local player = v
									table.insert(excludees, player.Name)
								end
							end

							local finalTable = {}
							for _, v in pairs(MobsFolder:GetChildren()) do
								if v.Name ~= player.Name then
									--- @type Model
									local mob = v
									if excludees then
										if not table.find(excludees, mob.Name) then
											-- Value is not excluded, meaning, not a player

											--- @type Model
											local fightInProgressOfMob = mob:FindFirstChild("FightInProgress")
											if
												fightInProgressOfMob
												and fightInProgressOfMob.Value == isOnFight.Value
											then
												table.insert(finalTable, mob)
											end
										end
									else
										local fightInProgressOfMob = mob:FindFirstChild("FightInProgress")
										if fightInProgressOfMob and fightInProgressOfMob.Value == isOnFight.Value then
											table.insert(finalTable, mob)
										end
									end
								end
							end
							return finalTable
						end
						--- This function returns a table containing a table that contains information on the available moves of the player
						--- @return table attackDataTable A table with information of attacks the player can use.
						local function GetLocalPlayerAvalableMoves()
							local scrollingFrameSkillsTable =
								LocalPlayer.PlayerGui.Combat.ActionBG.AttacksPage.ScrollingFrame:GetChildren()
							local attacksAvailable = {}

							if not scrollingFrameSkillsTable then
								-- Return good old strike in case of a failure
								print("FSM: LP AVAILABLE MOVS ERR")
								return "Strike"
							end

							-- item.CD.Count.Visible -> True => The movement is not locked because yes; It is locked becuase we need to wait turns.
							-- item.CD.Count.Text -> number => The number of turns until this movement is available
							-- item.CD.Visible -> True => Move not available this turn [GENERAL!]
							for _, item in next, scrollingFrameSkillsTable do
								if item.ClassName and item.ClassName == "TextButton" then
									print("Found attack with name " .. item.Name)
									if item.CD.Count.Visible then
										print("Attack usable in " .. item.CD.Count.Text .. " turns")
										attacksAvailable[item.Name] = {
											AttackName = item.Name,
											IsAttackUsable = false,
											UsableIn = tonumber(item.CD.Count.Text),
										}
									elseif not item.CD.Visible then
										attacksAvailable[item.Name] = {
											AttackName = item.Name,
											IsAttackUsable = true,
											UsableIn = 0,
										}
										print("Attack usable in the current turn")
									end
								end
							end

							return table.freeze(attacksAvailable)
						end

						--- Get state of the fight; In what turn is the current fight at?
						--- @return number turnNumber The number that represents the current turn on the fight.
						local function GetMovementNumber()
							--- @type string
							local rawData = LocalPlayer.PlayerGui.Combat.ActionBG.TurnCounter.Text

							-- ([0-9]+) -> Regex Match all NUMBERS!
							return tonumber(rawData:gmatch("([0-9]+)")())
						end

						--- Gets all the attacks that can be used by the player.
						--- @return table usableAttacks A table containing all the attacks the player can use.
						local function GetUsableAttacks()
							-- Available moves holds the following properties:
							-- - AttackName -> The name of the attack
							-- - IsAttackUsable -> When will this attack be usable (Turns until)
							-- - UsableIn -> The amount of turns in which the attack will be usable.
							local availableMoves = GetLocalPlayerAvalableMoves()
							local usableMoves = {}
							for _, move in availableMoves do
								if move.IsAttackUsable then
									table.insert(usableMoves, move)
								end
							end
							return table.freeze(usableMoves)
						end

						--- @return Model model The parented instance of the humanoid with the lowest health on the table
						local function GetHumanoidModelWithLowestHealth(table)
							local lowestHealthSeen = math.huge
							local refToHumanoidParent = nil
							--- @type Model item
							for _, item in ipairs(table) do
								local firstHumanoid = item:FindFirstChildOfClass("Humanoid")
								if firstHumanoid then
									print(lowestHealthSeen)
									print(firstHumanoid.Health)
									if lowestHealthSeen > firstHumanoid.Health then
										lowestHealthSeen = firstHumanoid.Health
										refToHumanoidParent = item
									end
								end
							end
							return refToHumanoidParent
						end
						--- @return Model The parented instance of the humanoid with the highest health on the table
						local function GetHumanoidModelWithHighestHealth(table)
							local highestHealthSeen = 0
							local refToHumanoidParent = nil
							--- @type Model item
							for _, item in ipairs(table) do
								local firstHumanoid = item:FindFirstChildOfClass("Humanoid")

								if firstHumanoid then
									if highestHealthSeen < firstHumanoid.Health then
										highestHealthSeen = firstHumanoid.Health
										refToHumanoidParent = item
									end
								end
							end
							return refToHumanoidParent
						end

						local function HasHealingItems()
							local inv = PlayerFunctions:GetPlayerInventoryItems()

							for _, itemTable in next, inv do
								local itemName = itemTable[1]

								if itemName:lower():match("heal") then
									return true
								end
							end
							return false
						end

						local humanoidForSmartAction = LocalPlayerCharacter:FindFirstChildOfClass("Humanoid")
						--- Gets the most optimal action for the current situation.
						--- @return AutoFarmFSMActions Returns the smartest action to do in the current situation.
						local function ChooseSmartestAction()
							-- TODO: IMPLEMENT FULLY!

							if not humanoidForSmartAction then
								print("FSM: ATTACKACT->DEAD")

								print("FSM: WAITINGFORREVIVAL->START")
								humanoidForSmartAction = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
									or LocalPlayer.CharacterAdded:Wait():FindFirstChildOfClass("Humanoid")
								print("FSM: WAITINGFORREVIVAL->ENDED")
								print("FSM: REFRESHED_HUMANOID_REFERENCE->COMPLETED!")
								return AutoFarmFSMActions.Dead
							end

							if
								AutoFarmFSMSettings.MovementsBeforeFleeing < GetMovementNumber()
								or AutoFarmFSMSettings.DangerHealth >= humanoidForSmartAction.Health
							then
								print("FSM: ATTACKACT->FLEE")
								return AutoFarmFSMActions.Escape
							end

							if
								AutoFarmFSMSettings.WarningHealth >= humanoidForSmartAction.Health
								and HasHealingItems()
							then
								print("FSM: ATTACKACT->HEAL_USEITEM")
								return AutoFarmFSMActions.UseItem
							end

							print("FSM: ATTACKACT->ATTACK")
							-- Default to fighting.
							return AutoFarmFSMActions.Fight
						end

						--- Waits for the Decide UI to pop up.
						--- Yields the current thread until the UI becomes Visible!
						local function WaitForDeciding(timeout)
							---  @type Frame
							local decidingUi = LocalPlayer.PlayerGui.Combat.Deciding

							if not timeout then
								timeout = 9999
							end

							local time = 0
							print("FSM: FDECIDING->STARTED")
							repeat
								time = time + 1
								task.wait(1)
								print("FSM: FTOUT->" .. time .. "/" .. timeout)
							-- Only wait if we are in a fight, and the enemy is deciding.
							until not PlayerFunctions:IsOnFight()
								or not decidingUi.Visible
								or time > timeout
							print("FSM: FDECIDING->FINISHED")
							-- If the time is over timeout, that means that we timed out!
							return timeout < time
						end

						--- Obtain if there is a mob deciding (UI CHECK)
						--- @return boolean isDeciding Whether or not there is "someone" deciding.
						local function IsDeciding()
							---  @type Frame
							local decidingUi = LocalPlayer.PlayerGui.Combat.Deciding
							return decidingUi.Visible
						end

						--- Escapes the current battle.
						local function EscapeBattle()
							LocalPlayer.PlayerGui.Combat.CombatHandle.Escape:FireServer()

							if WaitForDeciding(3) and not PlayerFunctions:IsOnFight() then
								task.spawn(function()
									window:Notify({
										Name = "Auto Farm",
										Text = "Fight escaped successfully!",
										Duration = 5,
									})
								end)
								return true
							end
							task.spawn(function()
								window:Notify({
									Name = "Auto Farm",
									Text = "Failed to escape fight!",
									Duration = 5,
								})
							end)

							return false
						end

						--- Attacks the given target with the attack given.
						--- @param target Model The target of the attack.
						--- @param selectedAttack string The name of the attack
						local function AttackTarget(target, selectedAttack)
							print("FSM: ATTACKATTEMPTED")
							LocalPlayer.PlayerGui.Combat.CombatHandle.RemoteFunction:InvokeServer(
								"Attack",
								selectedAttack,
								{
									["Attacking"] = target,
								}
							)
						end

						--- Chooses an attack choosen by a small algorithm.
						--- @return string attackName The name of the attack that has been chosen.
						local function SelectAttack(beGreedy)
							local attackList = GetUsableAttacks()
							local possibleAttacks = {}
							for _, attackData in attackList do
								-- local attackName = attackData.AttackName
								-- local usableIn = attackData.UsableIn
								local isUsable = attackData.IsAttackUsable

								if isUsable then
									table.insert(possibleAttacks, attackData)
								end
							end

							-- If our settings call for greedyness or we have no preferred attacks, fallback to greedyness.
							if beGreedy or #selectedAttacks == 0 then
								-- We assume the newest, and strongest skill in the belt of the player is the one that comes on top of all of them.
								-- Due to this, this is a greedy choice, not one that considers anything other than the index of the attack.
								return possibleAttacks[1].AttackName
							else
								-- We assume we don't want the strongest skill yet, we want to save it a bit later on, so we just throw some dices...
								-- Impl: Two random numbers are generated from the lengths of our attack lists. We find if the attack we selected in the possible move list is valid in our
								-- priority list, and if in our priority rng num is below the found index, then we use that attack, else, retry.
								local MAX_ATTEMPT_COUNTER = 200
								local foundAttack = false
								local attemptCount = 0
								local attackSelected = nil
								repeat
									print("FSM SELATK->ATM->" .. attemptCount .. "/" .. MAX_ATTEMPT_COUNTER)
									local rngNum_selectedAttack = math.random(1, #selectedAttacks)
									local rngNum = math.random(1, #possibleAttacks)

									local selected = possibleAttacks[rngNum]

									local found = table.find(selectedAttacks, selected.AttackName)
									if found then
										if found < rngNum_selectedAttack then
											-- Dices were rolled successfully!
											foundAttack = true
											attackSelected = selected
										end
									end
									task.wait() -- Avoid lock.

									if attemptCount > MAX_ATTEMPT_COUNTER then
										-- Fallback to greedy algorithm.
										return possibleAttacks[1].AttackName
									end
									print("FSM SELATK->RNG_ATT!")
									attemptCount = attemptCount + 1
								until foundAttack
								print("FSM SELATK->SELECTEDATK->" .. attackSelected.AttackName)
								return attackSelected.AttackName -- Return the name of the attack
							end
						end

						local function AiLoop()
							print("FSM: STATE->" .. currentState)

							if currentState == AutoFarmFSMStates.Idle then
								-- It should never be on idle, just on the start.
								if PlayerFunctions:IsOnFight() then
									print("FSM: SWITCH_STATE->FIGHTING")
									previousState = AutoFarmFSMStates.Idle
									currentState = AutoFarmFSMStates.Fighting
								else
									print("FSM: SWITCH_STATE->SEARCHFORFIGHT")
									previousState = AutoFarmFSMStates.Idle
									currentState = AutoFarmFSMStates.SearchingFight
								end
								return -- Complete FSM Tick.
							end

							if currentState == AutoFarmFSMStates.Fighting then
								local selectedAction = ChooseSmartestAction()

								if not HubSettings.EnableAlwaysPerfectDodge then
									HubSettings.EnableAlwaysPerfectDodge = true
									print("FSM: ENABLED->AUTO_DODGE[HOOKVER]")
								end

								if selectedAction == AutoFarmFSMActions.Fight then
									if IsDeciding() then
										print("FSM: DECIDING_DETECTED->STARTWAIT")
										WaitForDeciding()
										print("FSM: DECIDING_DETECTED->ENDEDWAIT")
									end

									--- @type table
									local inCurrentFight = GetMobsOnFightWith(LocalPlayerCharacter, false)
									--- @type Instance | nil
									local target = nil

									-- Select target based on health, current available setting.
									if AutoFarmFSMSettings.TargetType == TargetTypes.LowestHealth then
										target = GetHumanoidModelWithLowestHealth(inCurrentFight)
									elseif AutoFarmFSMSettings.TargetType == TargetTypes.MostHealth then
										target = GetHumanoidModelWithHighestHealth(inCurrentFight)
									end

									if target == nil then
										task.wait(1)
										if not PlayerFunctions:IsOnFight() then
											print(
												"FSM: SWITCH_STATE->SEARCHFORFIGHT | REASON->LP_LEFT_FIGHT+TARGET_NIL"
											)
											previousState = AutoFarmFSMStates.Fighting
											currentState = AutoFarmFSMStates.SearchingFight
										end
										return
									end
									--- @type string
									local attackSelected = ""
									if AutoFarmFSMSettings.SmartAttackUsage then
										--- @type string
										attackSelected = SelectAttack(false)
									else
										--- @type string
										attackSelected = SelectAttack(true)
									end
									AttackTarget(target, attackSelected)

									-- After an attack, the enemy will normally swap into Deciding its next move (UI ELEMENT!)
									if WaitForDeciding(2) then
										print("FSM: ATTACKSUCCESS->TRUE!")
									else
										print("FSM: ATTACKSUCCESS->FALSE!")
									end
								elseif selectedAction == AutoFarmFSMActions.Escape then
									EscapeBattle()
									return
								elseif selectedAction == AutoFarmFSMActions.UseItem and HasHealingItems() then
									-- I only know of HEALING items, so we are just gonna consume the first one of those!
									local inv = PlayerFunctions:GetPlayerInventoryItems()

									for _, itemTable in next, inv do
										local itemName = itemTable[1]
										local itemAmount = itemTable[2]

										if itemName:lower():match("heal") then
											-- TODO: Use this item, and break out of loop.
										end
									end
								end
								return -- Complete FSM Tick.
							end

							if currentState == AutoFarmFSMStates.SearchingFight then
								task.wait(0.5) -- Wait half a second, fights take a while to come back, and FindFirstChild is fairly expensive!
								if not PlayerFunctions:IsOnFight() then
									-- Compute action for healing.

									local pHumanoid = LocalPlayerCharacter:FindFirstChildOfClass("Humanoid")

									if pHumanoid then
										print("FSM: SEARCHINGFIGHT->CHECK_HUMANOID")
										-- HEALING PRODECURE
										if
											pHumanoid.Health ~= pHumanoid.MaxHealth
											and AutoFarmFSMSettings.UseDoctorHeal
										then
											print(
												"FSM: SEARCHINGFIGHT->CHECK_HUMANOID->NOT_FULL_HEALTH->HEALING_WITH_DOCTOR"
											)
											local old = pHumanoid.RootPart.CFrame

											local firstDoctor = workspace.NPCs:FindFirstChild("Doctor")
											--- @type Part
											local tpPoint = firstDoctor:FindFirstChild("Head")

											if not tpPoint then
												firstDoctor:FindFirstChild("HumanoidRootPart")
											end

											if not tpPoint then
												tpPoint = firstDoctor:FindFirstChild("Torso")
											end

											PlayerFunctions:FreezeLocalPlayerCharacter()
											pHumanoid.RootPart.CFrame = tpPoint.CFrame
											task.wait(0.5)
											-- #region Heal Player (LOGIC)
											local VirtualInputManager = game:GetService("VirtualInputManager")
											local pGui = LocalPlayer.PlayerGui

											repeat
												print("TRIGGERING_NPC_DIALOG")
												-- FAKE INPUT
												VirtualInputManager:SendKeyEvent(true, "E", false, nil)
												VirtualInputManager:SendKeyEvent(false, "E", false, nil)
												task.wait(0.1)
											until pGui:FindFirstChild("NPCDialogue")
											-- SCRAPE UI INFO AND AUTOMATICALLY INTERACT!
											task.wait(0.5)
											local dialogueScreen = pGui:WaitForChild("NPCDialogue")
											if dialogueScreen then
												-- This remote event signals the dialog issued.
												local remoteEvent = dialogueScreen:WaitForChild("RemoteEvent")

												pGui.NPCDialogue.BG:WaitForChild("Options")

												local options = pGui.NPCDialogue.BG.Options:GetChildren()
												local selectedOption
												for _, opt in ipairs(options) do
													-- Match for buttons which contain the "Yes" text, to cure us
													if
														opt
														and opt.ClassName == "TextButton"
														and opt.Text:match("Yes")
													then
														selectedOption = opt
														break
													end
												end
												if selectedOption then
													remoteEvent:FireServer(selectedOption)
												else
													print("FAILED TO FIND")
												end
											end
											-- #endregion Heal Player (LOGIC)
											pHumanoid.RootPart.CFrame = old
											PlayerFunctions:UnfreezeLocalPlayerCharacter()
										end

										-- LEVEL UP PROCEDURE
										if
											AutoFarmFSMSettings.EnableAutoLevelUp
											and math.random(0, 500) < AutoFarmFSMSettings.LevelUpChance -- 5x less chances, it would trigger too often else!
										then
											print("FSM: ATTEMPTING LEVEL UP!")
											--- Gets the cost to level up (tuple of costType[0], quantity[1])
											--- @return number turnNumber The number that represents the cost.
											local function GetLevelupCost(item)
												--- @type LevelUpRequirementType
												local types = {
													["Gold"] = "Gold",
													["Essence"] = "Essence",
												}
												local type = types.Essence
												if item:gmatch("([0-9]+)g")() then
													-- This is requesting essence
													type = types.Gold
												end
												print(item:gmatch("([0-9]+)")())
												-- ([0-9]+). -> Regex Match all NUMBERS!
												return { type, tonumber(item:gmatch("([0-9]+)")()) }
											end

											local function CanLevelUp(cost, typeOfCost)
												if not cost then
													return nil
												end
												if typeOfCost == "Gold" then
													local pMoney = tonumber(
														game:GetService("Players").LocalPlayer.PlayerGui.HUD.Holder.Gold.Text
															:gmatch("([0-9]+)")()
													)
													return cost <= pMoney
												elseif typeOfCost == "Essence" then
													local pEssence = tonumber(
														game:GetService("Players").LocalPlayer.PlayerGui.HUD.Holder.Essence.Text
															:gmatch("([0-9]+)")()
													)
													return cost <= pEssence
												else
													return nil
												end
											end

											-- TP To mat.
											-- Fake input.
											-- Tp to guy. ( game:GetService("Workspace").NPCs.Aretim (Part) )
											-- Fake Input for dialogue.
											-- Wait for Skill menu (5 seconds)
											-- TIMEDOUT -> Missing requirements
											-- Found -> Fire selection (Get skill points from UI)
											-- Profit.

											local OLDPOS = LocalPlayerCharacter.HumanoidRootPart.CFrame

											local mats = workspace.Mats:GetChildren()

											-- rng num for entropy to avoid tracking of ANY kind.
											local rngN = math.random(1, #mats)

											local selectedMat = mats[rngN]

											local tpPoint = selectedMat:FindFirstChildOfClass("Part")

											game:GetService("Players").LocalPlayer.Character.PrimaryPart.CFrame = tpPoint.CFrame
												+ Vector3.new(0, 5, 0)
											task.wait(1)
											local VirtualInputManager = game:GetService("VirtualInputManager")
											task.wait(0.5)
											VirtualInputManager:SendKeyEvent(true, "M", false, nil)
											VirtualInputManager:SendKeyEvent(false, "M", false, nil)
											task.wait(0.5)

											local soulMaster = game:GetService("Workspace").NPCs.Aretim

											repeat
												task.wait(1)
											until game:GetService("Players").LocalPlayer
													:DistanceFromCharacter(soulMaster.CFrame.Position) < 300

											-- OPT -> FREEZE CHAR!
											game:GetService("Players").LocalPlayer.Character.PrimaryPart.CFrame =
												soulMaster.CFrame

											local pGui = game:GetService("Players").LocalPlayer.PlayerGui
											-- TPd to Aretim, now we want to fire until the Dialog GUI appears.
											repeat
												VirtualInputManager:SendKeyEvent(true, "E", false, nil)
												VirtualInputManager:SendKeyEvent(false, "E", false, nil)
												task.wait(1)
											until pGui:FindFirstChild("NPCDialogue") and not PlayerFunctions:IsOnFight()

											if
												not pGui:FindFirstChild("NPCDialogue") or PlayerFunctions:IsOnFight()
											then
												print("FSM: AUTOLEVEL INTERRUPTED!->NO_NPC_DIALOGUE")
												return -- FSM TICK
											end

											local function triggerLevelup()
												task.wait(0.5)
												local dialogueScreen = pGui:WaitForChild("NPCDialogue")
												if dialogueScreen then
													-- This remote event signals the dialog issued.
													local remoteEvent = dialogueScreen:WaitForChild("RemoteEvent")

													pGui.NPCDialogue.BG:WaitForChild("Options")

													local options = pGui.NPCDialogue.BG.Options:GetChildren()
													local selectedOption
													local refuseOption
													for _, opt in ipairs(options) do
														-- Match for buttons which contain the "Yes" text, to cure us
														if
															opt
															and opt.ClassName == "TextButton"
															and opt.Text:match("Show me his light")
														then
															selectedOption = opt
														else
															refuseOption = opt
														end
													end
													if selectedOption then
														print("found")
														local s = GetLevelupCost(selectedOption.Text)

														local lUpType = s[1]
														local lCost = s[2]

														print(lUpType, lCost)

														if CanLevelUp(lCost, lUpType) then
															remoteEvent:FireServer(selectedOption)
															return true
														else
															remoteEvent:FireServer(refuseOption)
															return false
														end
													else
														return false
													end
												end
											end

											if not PlayerFunctions:IsOnFight() and triggerLevelup() then
												local statPoints =
													LocalPlayer.PlayerGui.HUD.StatAllocate.StatPoints.Text
												task.wait(1)
												local availableStatPoints = tonumber(statPoints:gmatch("([0-9]+)")())
												if availableStatPoints and availableStatPoints ~= 0 then
													print("FSM: LEVELUP->POINTSFOUND->" .. availableStatPoints)
													local rVar = AutoFarmFSMSettings.SkillDistribution

													-- SAFETY CHECK TO AVOID BANS!

													local sum = 0
													for _, val in ipairs(rVar) do
														sum = sum + val
													end

													while sum > availableStatPoints - 1 do
														window:Notify({
															Name = "Auto Farm",
															Text = "Wronly set skill point allocation, this may get you banned! We have stopped the execution of the script for 1 minute for you to fix it! Once it is, restart execution to before your character meditated, the required skill points are "
																.. sum
																.. " but you only have "
																.. availableStatPoints
																.. " points! Re-configure for the farming to proceed",
															Duration = 60,
														})

														sum = 0
														for _, val in ipairs(rVar) do
															sum = sum + val
														end
													end
													print(unpack(rVar))
													ReplicatedStorage.Remotes.Information.StatAllocation:FireServer(
														unpack(rVar)
													)
													task.wait(7)
													VirtualInputManager:SendKeyEvent(true, "M", false, nil)
													VirtualInputManager:SendKeyEvent(false, "M", false, nil)
													task.wait(5)
												end
											elseif not PlayerFunctions:IsOnFight() then
												print("FSM: LEVEL UP FAILED! MISSING RESOURCES?")
												task.wait(7)
												VirtualInputManager:SendKeyEvent(true, "M", false, nil)
												VirtualInputManager:SendKeyEvent(false, "M", false, nil)
												task.wait(5)
											end
											LocalPlayerCharacter.HumanoidRootPart.CFrame = OLDPOS
										end
									end

									return -- Complete FSM Tick.
								else
									print("FSM: SWITCH_STATE->FIGHTING")
									previousState = AutoFarmFSMStates.SearchingFight
									currentState = AutoFarmFSMStates.Fighting
								end
							end

							print("FSM: PREV_STATE->" .. previousState)
						end

						local OLD_POSITION = LocalPlayerCharacter.HumanoidRootPart.CFrame

						LocalPlayerCharacter.HumanoidRootPart.CFrame = AutoFarmFSMSettings.FarmArea.CFrame
							+ Vector3.new(0, 5, 0)

						local oldNofall = HubSettings.DisableFallDamage
						HubSettings.DisableFallDamage = true

						while not autoFarmKill and task.wait() do -- Wait heartbeat at least!
							print("FSM: TICK->START")
							AiLoop()
							print("FSM: TICK->END")
						end

						print("FSM: TERMINATED! DISPOSING AND RESTORING STATE!")
						LocalPlayerCharacter.HumanoidRootPart.CFrame = OLD_POSITION
						HubSettings.DisableFallDamage = oldNofall
					end)
				end
			end,
		})
	end
	-- #endregion Automatic Farm

	-- #region Automatic Flower Farm

	if true then
		AutoTab:Label({ Text = "~~~ Automatic Flower Farming ~~~" })
		local AutoFlowerFarmStateMachineSettings = {
			-- Whether or not the FSM should force the player to have an Abhorrent Elixir on them to work.
			["ForceAbhorrent"] = true,
		}

		AutoTab:Toggle({
			Name = "Auto Flower Farm: Force Use Abhorrent Elixir",
			Default = true,
			Callback = function(state)
				AutoFlowerFarmStateMachineSettings.ForceAbhorrent = state
			end,
		})

		local AutoFlowerFarmStatesTable = {
			-- Can transition to WaitingForFlowers, ObtainingFlowers and TakingPotion
			["Idle"] = "Idle",
			-- Can only transition to TakingPotion and Idle.
			["WaitingForFlowers"] = "WaitingForFlowers",
			-- Can only transition to WaitingForFlowers and TakingPotion (ONLY IF IT REQUIRES AN ABHORRENT ELIXIR!)
			["ObtainingFlowers"] = "ObtainingFlowers",
			-- Can only transition to its previous state; returns control to the previous state after it finishes.
			["TakingPotion"] = "TakingPotion",
		}
		local stopFlowerFarm = false
		local autoFlowerFarmThread = nil
		AutoTab:Toggle({
			Name = "Auto Flower Farm",
			Default = false,
			Callback = function(state)
				if state then
					stopFlowerFarm = false
					autoFlowerFarmThread = task.spawn(function()
						print("FSM: Setting up Locals...")
						local starterCframe = LocalPlayerCharacter.PrimaryPart.CFrame
						local currentState = "Idle"
						local previousState = "Idle"
						local additionalState = {
							-- Indicates whether the previous state successfully executed.
							["wasPreviousStateSuccessful"] = true,
							-- The potion for TakingPotion to consume.
							["PotionTarget"] = "",
							-- When was the last potion taken at?
							["PotionTakenAt"] = 0,
						}
						local flowersFolderReference = workspace:FindFirstChild("SpawnedItems")
						if not flowersFolderReference then
							task.spawn(function()
								window:Notify({
									Name = "Auto Flower Farm",
									Text = "Failed to obtain the flowers folder! Cannot continue execution...",
									Duration = 5,
								})
							end)
							return
						end

						--- @return table Containing all valid flowers.
						local function EnumerateValidFlowers()
							local children = flowersFolderReference:GetChildren()

							local validFlowersTable = {}
							for _, child in ipairs(children) do
								local valid = child:FindFirstChild("ClickDetector", true)
								if valid then
									table.insert(validFlowersTable, child)
								end
							end
							return validFlowersTable
						end

						local function LockIfOnFight()
							if LocalPlayerCharacter:FindFirstChild("FightInProgress") then
								task.spawn(function()
									window:Notify({
										Name = "Auto Flower Farm",
										Text = "Whoops! The player has been dragged onto a fight! The farming has been paused until the fight has been addressed...",
										Duration = 10,
									})
								end)

								-- Wait until the fight stops to continue.
								repeat
									task.wait(1)
								until LocalPlayerCharacter:FindFirstChild("FightInProgress") == nil
							end
						end

						local function AiLoop()
							flowersFolderReference = workspace.SpawnedItems

							if currentState == AutoFlowerFarmStatesTable.Idle then
								local hasAbhorrent = PlayerFunctions:HasItemOnInventory("Abhorrent Elixir")
								-- We are on idle, we want to switch to TakingPotions (If possible) and then -> WaitingForFlowers || ObtainingFlowers
								if
									hasAbhorrent
									and previousState ~= AutoFlowerFarmStatesTable.TakingPotion
									and AutoFlowerFarmStateMachineSettings.ForceAbhorrent
								then
									-- Set state.
									currentState = AutoFlowerFarmStatesTable.TakingPotion
									previousState = AutoFlowerFarmStatesTable.Idle

									additionalState.PotionTarget = "Abhorrent Elixir"
									return -- Return for next FSM tick. | Next state => TakingPotions
								elseif not hasAbhorrent and AutoFlowerFarmStateMachineSettings.ForceAbhorrent then
									window:Notify({
										Name = "Auto Flower Farm",
										Text = "Cannot farm flowers without an Abhorrent Elixir on your inventory!",
										Duration = 5,
									})
									return -- Return for next FSM tick. | Next state => Idle
								end

								if
									not AutoFlowerFarmStateMachineSettings.ForceAbhorrent
									or previousState == AutoFlowerFarmStatesTable.TakingPotion
								then
									task.spawn(function()
										window:Notify({
											Name = "Auto Flower Farm",
											Text = "Starting flower farming...",
											Duration = 5,
										})
									end)
									-- Set state
									previousState = currentState
									currentState = AutoFlowerFarmStatesTable.WaitingForFlowers
									return -- Return for next FSM tick. | Next state => WaitingForFlowers
								end
							end

							if currentState == AutoFlowerFarmStatesTable.TakingPotion then
								local potionToConsume = additionalState.PotionTarget
								PlayerFunctions:EquipItem(potionToConsume)
								task.wait(1) -- Leeway for server...
								PlayerFunctions:UseItem(potionToConsume)
								task.wait(2) -- Leeway for server...

								-- Set state.
								additionalState.PotionTakenAt = tick() -- Current Unix Epoch.
								currentState = previousState
								previousState = AutoFlowerFarmStatesTable.TakingPotion
								return -- Return for next FSM tick. | Next state => PreviousState
							end

							if currentState == AutoFlowerFarmStatesTable.WaitingForFlowers then
								if
									previousState == AutoFlowerFarmStatesTable.ObtainingFlowers
									or previousState == AutoFlowerFarmStatesTable.Idle
								then
									print("FSM: State->WaitingForFlowers")
									-- We want to wait a bit, and return the control to the previous state if flowers spawned, the previous state being ObtainingFlowers
									local validFlowers = EnumerateValidFlowers()
									local flowerSpawned = #validFlowers ~= 0
									print("FSM: VALIDFLOWERSFOUND->" .. #validFlowers)
									print("FSM: ADVANCETOFARM->" .. tostring(flowerSpawned))
									local conn = flowersFolderReference.ChildAdded:Connect(function(child)
										task.wait(3)
										local found = child:FindFirstChild("ClickDetector", true)
										flowerSpawned = found ~= nil
										print("FSM: Recieved FOUNDFLOWER")
									end)

									local flowerSpawned_Notification = previousState
										== AutoFlowerFarmStatesTable.ObtainingFlowers
									if flowerSpawned_Notification then
										task.spawn(function()
											window:Notify({
												Name = "Auto Flower Farm",
												Text = "Waiting for Flowers to spawn...",
												Duration = 5,
											})
										end)
									end

									repeat
										task.wait(1) -- Wait Heartbeat...
									until flowerSpawned or stopFlowerFarm
									conn:Disconnect()
									conn = nil

									if stopFlowerFarm then
										return -- FSM Tick End | FSM has been ordered to finish working.
									end

									if flowerSpawned_Notification then
										task.spawn(function()
											window:Notify({
												Name = "Auto Flower Farm",
												Text = "A flower has spawned! Going for it...",
												Duration = 5,
											})
										end)
									end
									-- Set state.
									currentState = AutoFlowerFarmStatesTable.ObtainingFlowers
									previousState = AutoFlowerFarmStatesTable.WaitingForFlowers
									return -- Return for next FSM tick. | Next state => ObtainingFlowers
								end

								-- Normally an Abhorrent lasts 60 seconds, but you can not trust networking! A bit of leeway is always cool.
								if
									(tick() - additionalState.PotionTakenAt) > 60 + 2
									and #flowersFolderReference:GetChildren() > 5
									and AutoFlowerFarmStateMachineSettings.ForceAbhorrent
								then
									if not PlayerFunctions:HasItemOnInventory("Abhorrent Elixir") then
										window:Notify({
											Name = "Auto Flower Farm",
											Text = "Farming can not continue; the Abhorrent Elixir has worn off, but there isn't any on the inventory to use!",
											Duration = 5,
										})
										previousState = currentState
										currentState = "Idle"
										return -- Return for next FSM tick. | Next State => Idle
									end

									window:Notify({
										Name = "Auto Flower Farm",
										Text = "Taking Abhorrent Elixir... [Potion possibly wore off!]",
									})
									-- Set state.
									previousState = currentState
									currentState = AutoFlowerFarmStatesTable.TakingPotion
									additionalState.PotionTarget = "Abhorrent Potion"
									return -- Return for next FSM tick. | Next state => TakingPotion
								end
							end

							if currentState == AutoFlowerFarmStatesTable.ObtainingFlowers then
								local targetFlowers = EnumerateValidFlowers()

								if #targetFlowers == 0 then
									window:Notify({
										Name = "Auto Flower Farm",
										Text = "All flowers available have been collected.",
										Duration = 5,
									})
									LocalPlayerCharacter.PrimaryPart.CFrame = starterCframe
									previousState = currentState
									currentState = AutoFlowerFarmStatesTable.WaitingForFlowers
									return -- Return for next FSM tick. | Next state => WaitingForFlowers
								end

								print("FSM: State->ObtainingFlowers")

								print("FSM: NOCLIP->ENABLED")
								Noclip()
								-- We are probably in the effect of an abhorrent, and there HAS to be flowers on the folder, step through each of them and fire their click detectors.

								for _, flower in pairs(targetFlowers) do
									PlayerFunctions:FreezeLocalPlayerCharacter()
									LockIfOnFight()
									-- Sort only flowers
									if flower:FindFirstChild("Handle") then
										-- Main, primary part of the flower.
										-- Type: BasePart
										local flowerPrimaryPart = flower.Handle

										-- Set CFrame of player...
										PlayerFunctions:UnfreezeLocalPlayerCharacter()
										LocalPlayerCharacter.PrimaryPart.CFrame = flowerPrimaryPart.CFrame
											+ Vector3.new(0, -4, 0)
										PlayerFunctions:FreezeLocalPlayerCharacter()
										if
											LocalPlayer:DistanceFromCharacter(flowerPrimaryPart.CFrame.Position) < 8
											and flowerPrimaryPart:FindFirstChild("ClickPart")
											and flowerPrimaryPart.ClickPart:FindFirstChild("ClickDetector")
										then
											print("FSM: Firing Click Detector!")
											task.wait(0.20)
											fireclickdetector(flowerPrimaryPart.ClickPart.ClickDetector, 5)
											task.wait(0.20)
											LockIfOnFight()
										end
										-- break -- Get first flower and tick.
									end
									PlayerFunctions:UnfreezeLocalPlayerCharacter()
									if stopFlowerFarm then
										return -- Early return, FSM terminated.
									end
								end
								-- Revert CFrame back to original.
								PlayerFunctions:UnfreezeLocalPlayerCharacter()
								LocalPlayerCharacter.PrimaryPart.CFrame = starterCframe
								print("FSM: NOCLIP->DISABLED")
								DisableNoClip()

								previousState = currentState
								currentState = AutoFlowerFarmStatesTable.WaitingForFlowers
								return -- Return for next FSM tick. | Next state => WaitingForFlowers
							end
						end

						print("FSM: Starting ticking...")
						print(stopFlowerFarm)

						while not stopFlowerFarm and task.wait() do -- Wait heartbeat at least!
							print("FSM Tick Start.")
							AiLoop()
							print("FSM Tick End.")
						end

						if stopFlowerFarm then
							print("FSM Disposed | Restoring player position | Removing Connections...")
							autoFlowerFarmThread = nil -- kms
							PlayerFunctions:UnfreezeLocalPlayerCharacter()
							DisableNoClip()
							LocalPlayerCharacter.PrimaryPart.CFrame = starterCframe
						end
					end)
				else
					stopFlowerFarm = true
				end
			end,
		})
	end
	-- #endregion Automatic Flower Farm
end

if HubSettings.DisableAnticheat then
	print("Not hooking; already completed in prelude.")
	print("Hooking Anticheat functions...")
	loadstring(GetRequestBodyFromUrl("https://api.sussy.dev/v1/KeySystem/Assets/GetPublicFile?fileName=ackill.lua"))()
	print("Hooks completed!")
end
PlayerFunctions:Initialize()
local Library = (loadstring(
	GetRequestBodyFromUrl("https://raw.githubusercontent.com/Bebo-Mods/Scripts/master/YouWontDoAnythingWithThat.lua")
))()
local Window = Library:Create({ ToggleKey = Enum.KeyCode.Insert })

if not game:IsLoaded() then -- Wait for the game to load completely before proceeding with the script.
	task.spawn(function()
		Window:Notify({
			Name = "Waiting for the game to load...",
			Text = "The script is waiting for the game to finish loading before proceeding.",
			Duration = 5,
		})
	end)
	game.Loaded:Once(function()
		Window:Notify({
			Name = "Game loaded! Proceeding with script...",
			Text = "The game has finished loading, and the script may now load!",
			Duration = 5,
			Callback = function()
				return
			end, -- Callback when the notification ends
		})
	end)

	game.Loaded:Wait() -- Wait until it fires Loaded for the first time
end

InitializeHooks()
initializeMainTab(Window)
initializeTeleports(Window)
initializePlayer(Window)
initalizeAutomatics(Window)
end;

if game.GameId == 3104101863 then
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
end;

if game.GameId == 1785526629 then

if IsKeySystemLink() then
    game:GetService("Players").LocalPlayer:Kick("[Loader] This script is Premium Only! Get access to it on our Discord server!")
    task.wait(1)
    return
end
if not LRM_IsUserPremium then
	game:GetService("Players").LocalPlayer:Kick("[Loader] This script is Premium Only. Get it on our Discord server!")
	task.wait(1)
	if LPH_OBFUSCATED then
		LPH_CRASH()
	end
	return
end

local Players = game.Players
local rs = game:GetService("RunService")
local lp = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayerCharacter = lp.Character or lp.CharacterAdded:Wait()
lp.CharacterAdded:Connect(function(character)
	LocalPlayerCharacter = character
end)
local Library = loadstring(
	game:HttpGet("https://raw.githubusercontent.com/Bebo-Mods/Scripts/master/YouWontDoAnythingWithThat.lua")
)()

local Window = Library:Create({
	ToggleKey = Enum.KeyCode.Insert,
})

--- Util function.
function grabWeapon()
	for _, v in pairs(LocalPlayerCharacter:GetChildren()) do
		local damagePart = v:FindFirstChildWhichIsA("BasePart")
		if damagePart and string.find(damagePart.Name, "Damage") then
			return v, damagePart
		end
	end
end

local CODEX_SHARED_STATE = {
	EnableNoFall = true,
}

function initialiseHooks()
	local oldNoFall
	oldNoFall = hookmetamethod(game, "__namecall", function(...)
		if not CODEX_SHARED_STATE.EnableNoFall then
			return oldNoFall(...) -- Return immediately.
		end

		local self = select(1, ...)

		if not checkcaller() and getnamecallmethod() == "FireServer" and self and self.Name == "FallDamage" then
			local args = { ... }
			if #args < 2 then
				return oldNoFall(...) -- Not target
			elseif typeof(args[2]) == "number" then
				args[2] = -1 -- Modify 2, 1 is self.
				return oldNoFall(unpack(args))
			end
		end
		return oldNoFall(...)
	end)
end

function initialiseMain(window)
	local Tab = window:Tab({
		Name = "~~ Dystovia ~~ Main ~~",
		Description = "~~ Codexus Hub [Premium Only] ~~",
		Icon = "rbxassetid://11254763826", -- Tab Icon
		Color = Color3.new(0.811765, 0.313725, 0.247059), -- Tab Colour
		Hidden = false, -- IGNORE THIS
	})

	-- STRICT DEPENDENCIES ON THIS CODE! THANKS BEBO, DAMN YOU!

	local weapon, damagePart = grabWeapon()
	local MobsNameFolder = game:GetService("ReplicatedStorage").MobDrops
	local MobsFolder = workspace.MobFolder
	local mobs = {}

	for i, v in pairs(MobsNameFolder:GetChildren()) do
		table.insert(mobs, v.Name) -- Mob names, somehow.
	end
	table.insert(mobs, #mobs)
	--- @type string | nil
	local selectedMob = nil
	--- @type Instance | nil
	local currentMob = nil
	
	Tab:Dropdown({
		Name = "Select A Mob",
		Items = mobs, -- Table
		Callback = function(Dotikk)
			selectedMob = Dotikk
		end,
	})

	--- @type nil | RBXScriptConnection
	local farmSelectionConnection = nil
	Tab:Toggle({
		Name = "Farm selected mob",
		Default = false,
		Callback = function(enableFarming)
			if enableFarming then
				local function FindNextValidMob()
					local mobs = MobsFolder:GetChildren()
					for i = 1, #mobs do
						local v = mobs[i]
						local humanoid = v:FindFirstChildOfClass("Humanoid")
						if
							v.Name == selectedMob
							and humanoid
							and humanoid.Health > 0
							and v:FindFirstChild("HumanoidRootPart")
						then
							return v
						end
					end
				end
				local function MoveToNextMob()
					if currentMob ~= nil and MobsFolder and MobsFolder:FindFirstChild(selectedMob) then
						currentMob = currentMob or FindNextValidMob()

						if currentMob then
							local humanoid = currentMob:FindFirstChildOfClass("Humanoid")
							if humanoid and humanoid.Health > 0 then
								repeat
									task.wait()

									LocalPlayerCharacter.HumanoidRootPart.CFrame = currentMob:GetPivot()
											* CFrame.Angles(math.rad(-90), 0, 0)
										+ Vector3.new(0, 6, 0)
								until not currentMob or not farmSelectionConnection or humanoid.Health == 0
							end
							currentMob = FindNextValidMob()
						end
					end
				end

				farmSelectionConnection = rs.Heartbeat:Connect(function()
					MoveToNextMob()
				end)
			else
				if farmSelectionConnection then
					farmSelectionConnection:Disconnect()
					farmSelectionConnection = nil
				end
			end
		end,
	})

	--- @type nil | RBXScriptConnection
	local mobInstaKillConnection = nil

	Tab:Toggle({
		Name = "Mob Instant Kill",
		Callback = function(enableInstantKill)
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			if enableInstantKill then
				mobInstaKillConnection = rs.Heartbeat:Connect(function()
					local Mobs = MobsFolder:GetChildren()
					for i = 1, #Mobs do
						local v = Mobs[i]
						local MobDistanceTOPlayer = (
							LocalPlayerCharacter.HumanoidRootPart.Position - v:GetPivot().Position
						).Magnitude
						if
							MobDistanceTOPlayer < 12
							and v:FindFirstChild("MobArea")
							and v:FindFirstChildOfClass("Humanoid").Health ~= 0
						then
							for _ = 1, 6, 1 do
								ReplicatedStorage.Events.DamageEvents.DamageDetect:FireServer(
									true,
									"Attack",
									v.MobArea,
									damagePart
								)
							end -- Call 6 times.
						end
					end
				end)
			else
				if mobInstaKillConnection then
					mobInstaKillConnection:Disconnect()
					mobInstaKillConnection = nil
				end
			end
		end,
	})

	Tab:Section({ Name = "~~ Reach ~~" })

	local reachDistance = 16
	Tab:Slider({
		Name = "Reach Distance",
		Min = 1,
		Max = 80,
		Default = 16,
		Callback = function(selectedVal)
			reachDistance = selectedVal
		end,
	})

	--- @type nil | RBXScriptConnection
	local connectionReachWeapon = nil

	Tab:Toggle({
		Name = "Weapon Reach",
		Callback = function(enableWeaponReach)
			if connectionReachWeapon and connectionReachWeapon.Connected then
				connectionReachWeapon:Disconnect()
			end

			if enableWeaponReach then
				connectionReachWeapon = rs.Heartbeat:Connect(function()
					for _, v in pairs(MobsFolder:GetChildren()) do
						local mobArea = v:FindFirstChild("MobArea")
						if mobArea then
							local distance = (mobArea.Position - LocalPlayerCharacter.HumanoidRootPart.Position).Magnitude
							if distance <= reachDistance then
								if damagePart then
									firetouchinterest(damagePart, mobArea, 0)
									firetouchinterest(damagePart, mobArea, 1)
								end
							end
						end
					end
				end)
			end
		end,
	})
end

function initialiseTeleports(window)
	local Tab = window:Tab({
		Name = "~~ Dystovia ~~ Teleports ~~",
		Description = "~~ Codexus Hub [Premium Only] ~~",
		Icon = "rbxassetid://3926305904", -- Tab Icon
		Color = Color3.new(0.909803, 1, 0.317647), -- Tab Colour
		Hidden = false, -- IGNORE THIS
	})

	local ruins = {}

	for _, ruinInstance in ipairs(workspace.Ruins:GetChildren()) do
		table.insert(ruins, ruinInstance.Name)
	end
	table.insert(ruins, #ruins)

	Tab:Dropdown({
		Name = "Ruin Teleport",
		Items = ruins, -- Tabel
		Callback = function(ruinName)
			LocalPlayerCharacter:PivotTo(workspace.Ruins[ruinName]:GetPivot())
		end,
	})
end

function initialiseMisc(window)
	local PlayerService = game:GetService("Players")

	local Tab = window:Tab({
		Name = "~~ Dystovia ~~ Miscellaneous ~~",
		Description = "~~ Codexus Hub [Premium Only] ~~",
		Icon = "rbxassetid://3926305904", -- Tab Icon
		Color = Color3.new(0.384313, 0.631372, 1), -- Tab Colour
		Hidden = false, -- IGNORE THIS
	})

	local ChestsTable = {}
	local selectedChest
	local function UpdateChests()
		ChestsTable = {}
		for _, v in pairs(workspace.Chests:GetChildren()) do
			local chestName = v.Name
			if not table.find(ChestsTable, chestName) then
				table.insert(ChestsTable, v.Name)
			end
		end
	end
	UpdateChests()

	Tab:Section({ Name = "~~ Chests ~~" })
	local ChestsDropdown = Tab:Dropdown({
		Name = "Select Chest",
		Items = ChestsTable, -- Tabel
		Callback = function(itemName)
			selectedChest = itemName
		end,
	})
	Tab:Button({
		Name = "TP To Chest",
		Callback = function()
			LocalPlayerCharacter:PivotTo(workspace.Chests[selectedChest]:GetPivot())
		end
	})
	workspace.Chests.ChildAdded:Connect(function()
		UpdateChests()
		ChestsDropdown:UpdateList({
			Items = ChestsTable,
			Replace = true,
		})
	end)

	workspace.Chests.ChildRemoved:Connect(function()
		UpdateChests()
		ChestsDropdown:UpdateList({
			Items = ChestsTable,
			Replace = true,
		})
	end)

	Tab:Label({ Text = "Go near a chest and toggle to Dupe" })

	--- @type nil | thread
	local dupeThread = nil
	Tab:Toggle({
		Name = "Dupe Chest Items",
		Default = false,
		Callback = function(akiw12)
			if dupeThread then
				task.cancel(dupeThread)
			end

			if akiw12 then
				local function ChestDupe()
					for _, v in pairs(workspace.Chests:GetChildren()) do
						local itemsInsideItem = v:FindFirstChild("Item")
						local distance = (v:GetPivot().Position - LocalPlayerCharacter.HumanoidRootPart.Position).Magnitude
						if itemsInsideItem and distance <= 50 then
							for _, item in pairs(itemsInsideItem:GetChildren()) do
								game.ReplicatedStorage.Events.ItemEvents.ItemPickup:FireServer(v, item.Name, "Chest")
								task.wait(0.2)
							end
						end
					end
				end
				dupeThread = task.spawn(function()
					while task.wait(1) do
						ChestDupe()
					end
				end)
			end
		end,
	})


	Tab:Section({
		Name = "~~ Others ~~",
	})
	local moneyamout
	Tab:Textbox({
		Name = "Store Money Ammount",
		Default = "Money Ammount Here", -- Default Text in the box
		Callback = function(txt)
			moneyamout = txt
		end
	})
	Tab:Button({
		Name = "Store Money",
		Callback = function()
			game:GetService("ReplicatedStorage").Events.Saving.GoldStoring:FireServer(tonumber(moneyamout))
		end
	})
	
	local selectedScroll
	local ScrollsTable = {}

	local function UpdateScrolls()
		ScrollsTable = {}  -- Clear the existing table
		for _, v in pairs(ReplicatedStorage.Items[lp.Name.."Items"]:GetChildren()) do
			if string.find(v.Name, "Scroll") then
				local scrollName = v.Name
				if not table.find(ScrollsTable, scrollName) then
					table.insert(ScrollsTable, scrollName)
				end
			end
		end
	end
	
	UpdateScrolls()

	local ScrollNamesDropdown = Tab:Dropdown({
		Name = "Select Scroll",
		Items = ScrollsTable, -- Tabel
		Callback = function(ScrollNa90)
			selectedScroll = ScrollNa90
		end,
	})

	ReplicatedStorage.Items[lp.Name.."Items"].ChildAdded:Connect(function(ScrollName)
		if string.find(ScrollName.Name, "Scroll") then
			UpdateScrolls()
			ScrollNamesDropdown:UpdateList({
				Items = ScrollsTable,
				Replace = true,
			})
		end
	end)

	ReplicatedStorage.Items[lp.Name.."Items"].ChildRemoved:Connect(function(ScrollName2)
		if string.find(ScrollName2.Name, "Scroll") then
			UpdateScrolls()
			ScrollNamesDropdown:UpdateList({
				Items = ScrollsTable,
				Replace = true,
			})
		end
	end)

	--- @type nil | thread
	local AutoSelectedScroll = nil
	Tab:Toggle({
		Name = "Use Selected Scroll",
		Default = false,
		Callback = function(Statenier)
			if AutoSelectedScroll then
				task.cancel(AutoSelectedScroll)
			end

			if Statenier then
				local function UseScroll()
					game:GetService("ReplicatedStorage").Events.ItemEvents.UseScroll:FireServer(selectedScroll)
				end
				AutoSelectedScroll = task.spawn(function()
					while task.wait(1) do
						UseScroll()
					end
				end)
			end
		end,
	})

	--- @type nil|RBXScriptConnection
	local propChangedSigInfStamina = nil

	Tab:Toggle({
		Name = "Infinite Stamina",
		Default = false,
		Callback = function(state)
			if propChangedSigInfStamina and propChangedSigInfStamina.Connected then
				propChangedSigInfStamina:Disconnect()
			end

			if state then
				local leadStats = PlayerService.LocalPlayer.LeadStats
				propChangedSigInfStamina = leadStats.Stamina:GetPropertyChangedSignal("Value"):Connect(function()
					game:GetService("Players").LocalPlayer.LeadStats.Stamina.Value = leadStats.MaxStamina.Value
				end)
			end
		end,
	})

	--- @type nil|RBXScriptConnection
	local propChangedSigDodgeCooldown = nil

	Tab:Toggle({
		Name = "No Dodge Cooldown",
		Default = false,
		Callback = function(state)
			if propChangedSigDodgeCooldown and propChangedSigDodgeCooldown.Connected then
				propChangedSigDodgeCooldown:Disconnect()
			end

			if state then
				propChangedSigDodgeCooldown = LocalPlayerCharacter.Dodging
					:GetPropertyChangedSignal("Value")
					:Connect(function()
						LocalPlayerCharacter.Dodging.Value = false
					end)
			end
		end,
	})

	--- @type nil|RBXScriptConnection
	local propChangedSigNoKnockback = nil
	Tab:Toggle({
		Name = "Anti Knockback",
		Default = false,
		Callback = function(state)
			if propChangedSigNoKnockback and propChangedSigNoKnockback.Connected then
				propChangedSigNoKnockback:Disconnect()
			end

			if state then
				propChangedSigNoKnockback = LocalPlayerCharacter.Knockbacked
					:GetPropertyChangedSignal("Value")
					:Connect(function()
						LocalPlayerCharacter.Knockbacked.Value = false
					end)
			end
		end,
	})

	--- @type nil | thread
	local pickupThread = nil
	Tab:Toggle({
		Name = "Auto Loot Pick Up",
		Default = false,
		Callback = function(state)
			if pickupThread then
				task.cancel(pickupThread)
			end

			if state then
				local function pickupLootAuto()
					for _, v in pairs(game.workspace.LootFolder:GetChildren()) do
						local itemsInsideItem = v:FindFirstChild("Item")
						if itemsInsideItem then
							for _, item in pairs(itemsInsideItem:GetChildren()) do
								ReplicatedStorage.Events.ItemEvents.ItemPickup:FireServer(v, item.Name)
								break
							end
						end
					end
				end
				pickupThread = task.spawn(function()
					while task.wait(1) do
						pickupLootAuto()
					end
				end)
			end
		end,
	})

	--- @type nil | thread
	local herbFarm = nil
	Tab:Toggle({
		Name = "Auto Farm Herbs",
		Default = false,
		Callback = function(herbAutoF)
			if herbFarm then
				task.cancel(herbFarm)
			end

			if herbAutoF then
				local function pickupHerbs()
					for _, v in pairs(workspace.Herbs:GetChildren()) do
						for _, Herb in pairs(v:GetChildren()) do
							if Herb:IsA("Model") and Herb:FindFirstChild("BasePart") then
								lp.Character:PivotTo(Herb:GetPivot())
								local distance = (Herb:GetPivot().Position - lp.Character.HumanoidRootPart.Position).Magnitude
								if distance <= 20 then
									task.wait(0.1)
									game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
								end
								task.wait(0.1)
							end
						end
					end
				end
				herbFarm = task.spawn(function()
					while task.wait(0.1) do
						pickupHerbs()
					end
				end)
			end
		end,
	})
end

initialiseHooks()
initialiseMain(Window)
initialiseTeleports(Window)
initialiseMisc(Window)
end;

if game.GameId == 4383934650 then
local Players = game:GetService("Players")
local rs = game:GetService("RunService")
local lp = Players.LocalPlayer
local character = lp.Character
local rps = game.ReplicatedStorage.Remotes

local UIS = game:GetService("UserInputService")
local Library = loadstring(game:HttpGet(
                               "https://raw.githubusercontent.com/Bebo-Mods/Scripts/master/YouWontDoAnythingWithThat.lua"))()
local Distance
local Distance2
local ShootingPower
local Goals
local previousGoal
local WalkSPEED
local JumpPOWER
function highlight(Goal)
    local Highlight = Instance.new("Highlight", Goal)
    Highlight.Enabled = true
    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Highlight.FillColor = Color3.fromRGB(10, 10, 10)
    Highlight.OutlineColor = Color3.fromRGB(85, 105, 230)
    Highlight.FillTransparency = 0
    Highlight.OutlineTransparency = 0
end
-- Window
local Window = Library:Create({ToggleKey = Enum.KeyCode.Insert})

-- Tab
local Tab = Window:Tab({
    Name = "Striker Odyessy",
    Description = "Codexus Hub",
    Icon = "rbxassetid://11254763826", -- Tab Icon
    Color = Color3.new(0.811765, 0.313725, 0.247059), -- Tab Colour
    Hidden = false -- IGNORE THIS
})
-- Section
Tab:Section({Name = "~Functions~"})

Tab:Label({Text = "I advice going team 1 kinda keep in mind that is the Beta"})

Tab:Dropdown({
    Name = "Select Goal",
    Items = {"Gates1", "Gates2", 4}, -- Table
    Callback = function(item)
        Goals = item
        if previousGoal and previousGoal:FindFirstChild("Highlight") then
            previousGoal.Highlight:Destroy()
        end

        previousGoal = workspace.GameField:FindFirstChild(Goals)

        if previousGoal then highlight(previousGoal) end
    end
})

local AutoGoalsConnection

Tab:Toggle({
    Name = "Auto Goals",
    Default = false, -- Default Value
    Callback = function(enabled)
        if enabled then
            AutoGoalsConnection = rs.Heartbeat:Connect(function()
                if character then
                    local ball = character:FindFirstChild("Ball")
                    if ball then
                        local goal = workspace.GameField:FindFirstChild(Goals)
                        if goal and goal.Name == "Gates2" then
                            local goalPosition = goal.PrimaryPart.Position
                            character.PrimaryPart.CFrame = CFrame.new(
                                                               goalPosition) +
                                                               Vector3.new(50,
                                                                           8, 20)
                            character:SetPrimaryPartCFrame(CFrame.lookAt(
                                                               character.PrimaryPart
                                                                   .Position,
                                                               goalPosition))
                            lp.Character.Humanoid:ChangeState(11)
                            task.wait(.2)
                            rps.UseKeyboardSkillRemote:FireServer("PunchBall",
                                                                  ball, 4,
                                                                  ball.Ball
                                                                      .CFrame
                                                                      .LookVector,
                                                                  ball.Ball
                                                                      .CFrame
                                                                      .LookVector)
                        elseif goal and goal.Name == "Gates1" then
                            local goalPosition = goal.Hitbox.Position
                            character.PrimaryPart.CFrame = CFrame.new(
                                                               goalPosition) +
                                                               Vector3.new(50,
                                                                           3, 10)
                            character:SetPrimaryPartCFrame(CFrame.lookAt(
                                                               character.PrimaryPart
                                                                   .Position,
                                                               goalPosition))
                            lp.Character.Humanoid:ChangeState(11)
                            rps.UseKeyboardSkillRemote:FireServer("PunchBall",
                                                                  ball, 7,
                                                                  ball.Ball
                                                                      .CFrame
                                                                      .LookVector,
                                                                  ball.Ball
                                                                      .CFrame
                                                                      .LookVector)
                        end
                    end
                end
            end)
        else
            if AutoGoalsConnection then
                AutoGoalsConnection:Disconnect()
                AutoGoalsConnection = nil
            end
        end
    end
})

Tab:Button({
    Name = "Grab Ball",
    Callback = function()
        Retards1 = Players:GetPlayers()
        for i = 1, #Retards1 do
            local v1 = Retards1[i]
            if v1.Name ~= lp.Name and v1.Character:FindFirstChild("Ball") and
                lp:DistanceFromCharacter(v1.Character.PrimaryPart.Position) <
                700 and v1.Character.Humanoid.Health > 0 and
                v1.Character:FindFirstChild("HumanoidRootPart") then
                rps.UseKeyboardSkillRemote:FireServer("TackleBegin")
                rps.UseKeyboardSkillRemote:FireServer("Tackle",
                                                      v1.Character.Ball.Ball,
                                                      v1.Character.Ball.Ball
                                                          .CFrame)
                break
            end
        end
    end
})

Tab:Slider({
    Name = "Tackle Aura Distance",
    Min = 1, -- Min Val
    Max = 25, -- Max Val
    Default = 10, -- Default Val
    Callback = function(val) Distance = val end
})

Tab:Toggle({
    Name = "Tackle Aura",
    Default = false, -- Default Value
    Callback = function(state22)
        if state22 then
            TackleAura = rs.Heartbeat:Connect(function()
                if TackleAura then
                    Retards = Players:GetPlayers()
                    for i = 1, #Retards do
                        local v = Retards[i]
                        if v.Name ~= lp.Name and
                            v.Character:FindFirstChild("Ball") and
                            lp:DistanceFromCharacter(
                                v.Character.PrimaryPart.Position) < Distance and
                            v.Character.Humanoid.Health > 0 and
                            v.Character:FindFirstChild("HumanoidRootPart") then
                            rps.UseKeyboardSkillRemote:FireServer("TackleBegin")
                            rps.UseKeyboardSkillRemote:FireServer("Tackle",
                                                                  v.Character
                                                                      .Ball.Ball,
                                                                  v.Character
                                                                      .Ball.Ball
                                                                      .CFrame)
                        end
                    end
                end
            end)
            return
        end
        TackleAura:Disconnect()
    end
})
Tab:Slider({
    Name = "Take Ball Aura Distance",
    Min = 1, -- Min Val
    Max = 25, -- Max Val
    Default = 10, -- Default Val
    Callback = function(val1) Distance2 = val1 end
})

Tab:Toggle({
    Name = "Take Ball Aura",
    Default = false, -- Default Value
    Callback = function(state221)
        if state221 then
            TakeBallAura = rs.Heartbeat:Connect(function()
                if TackleAura then
                    Retards3 = Players:GetPlayers()
                    for i = 1, #Retards3 do
                        local v3 = Retards3[i]
                        if v3.Name ~= lp.Name and
                            v3.Character:FindFirstChild("Ball") and
                            lp:DistanceFromCharacter(
                                v3.Character.PrimaryPart.Position) < Distance2 and
                            v3.Character.Humanoid.Health > 0 and
                            v3.Character:FindFirstChild("HumanoidRootPart") then
                            rps.PunchRemote:FireServer("TakeBall",
                                                       v3.Character.Ball.Ball)
                        end
                    end
                end
            end)
            return
        end
        TakeBallAura:Disconnect()
    end
})
Tab:Slider({
    Name = "Shot Power",
    Min = 1, -- Min Val
    Max = 7, -- Max Val
    Default = 4, -- Default Val
    Callback = function(val31) ShootingPower = val31 end
})

local inputConnection -- Variable to store the event connection

Tab:Toggle({
    Name = "Modify Power",
    Default = false,
    Callback = function(bool)
        if bool then
            if not inputConnection then
                inputConnection = UIS.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and
                        lp.Character:FindFirstChild("Ball") then
                        rps.UseKeyboardSkillRemote:FireServer("PunchBall",
                                                              lp.Character:FindFirstChild(
                                                                  "Ball"),
                                                              ShootingPower,
                                                              lp.Character:FindFirstChild(
                                                                  "Ball").Ball
                                                                  .CFrame
                                                                  .LookVector,
                                                              lp.Character:FindFirstChild(
                                                                  "Ball").Ball
                                                                  .CFrame
                                                                  .LookVector)
                    end
                end)
            end
        else
            if inputConnection then
                inputConnection:Disconnect()
                inputConnection = nil
            end
        end
    end
})

local Tab2 = Window:Tab({
    Name = "Player",
    Description = "Player Tab",
    Icon = "rbxassetid://6031215978", -- Tab Icon
    Color = Color3.new(1, 0.968627, 0), -- Tab Colour
    Hidden = false -- IGNORE THIS
})

Tab2:Slider({
    Name = "Walkspeed",
    Min = 1, -- Min Val
    Max = 200, -- Max Val
    Default = 16, -- Default Val
    Callback = function(val312val312)
        WalkSPEED = val312val312
        character:FindFirstChildOfClass('Humanoid'):GetPropertyChangedSignal(
            "WalkSpeed"):Connect(function()
            character.Humanoid.WalkSpeed = WalkSPEED
        end)
        character.Humanoid.WalkSpeed = WalkSPEED
    end
})
Tab2:Slider({
    Name = "Jump Power",
    Min = 1, -- Min Val
    Max = 200, -- Max Val
    Default = 30, -- Default Val
    Callback = function(val312val3121)
        JumpPOWER = val312val3121
        character:FindFirstChildOfClass('Humanoid'):GetPropertyChangedSignal(
            "WalkSpeed"):Connect(function()
            character.Humanoid.JumpPower = JumpPOWER
        end)
        character.Humanoid.JumpPower = JumpPOWER
    end
})
-- Accessing settings tab
local SettingsTab = Window.SettingsTab
Window:Notify({
    Name = "Notification",
    Text = "Press Insert To Toggle GUI",
    Duration = 5,
    Callback = function() return end -- Callback when the notification ends
})
end;

if game.GameId == 847722000 then
-- TODO: Clean up ESP code.
-- TODO: Fix bugs in Full Bright
-- TODO: Mostly, rewrite Game Events, due to broken features.
-- ! ANTI-TAMPERING/KEY SYSTEM CHECK
-- ! WHITELIST_KEY IS SET BY THE LOADER, IF UNSET, KICK!
if getfenv().WHITELIST_KEY == nil then
    game.Players.LocalPlayer:Kick("You are not allowed to use this script.")
end

-- ! LOAD GUI

-- ! INITIALIZE LIBRARY
Library = loadstring(game:HttpGet(
                         "https://raw.githubusercontent.com/Bebo-Mods/Scripts/master/YouWontDoAnythingWithThat.lua"))()

-- ! INITIALIZATION FUNCTIONS

function initializeMiscTab()
    local Tab = Window:Tab({
        Name = "Misc",
        Icon = "rbxassetid://13260871719",
        Description = "Miscellaneous"
    })

    local fullbrightCnn = nil
    Tab:Button({
        Name = "Full Bright",
        Callback = function()
            local function setFullBright()
                local replicatedStg = game:GetService("ReplicatedStorage")
                replicatedStg.NightProperties.Brightness.Value = 6
                replicatedStg.DayProperties.Brightness.Value = 6
                replicatedStg.NightProperties.ClockTime.Value = 13
                replicatedStg.DayProperties.ClockTime.Value = 13

                replicatedStg.NightProperties["ColorShift_Top"].Value =
                    Color3.new(1, 1, 1)
                replicatedStg.DayProperties["ColorShift_Top"].Value =
                    Color3.new(1, 1, 1)

                replicatedStg.DayProperties["Ambient"].Value = Color3.new(1, 1,
                                                                          1)
                replicatedStg.NightProperties["Ambient"].Value = Color3.new(1,
                                                                            1, 1)
                replicatedStg.CurrentLightingProperties["Ambient"].Value =
                    Color3.new(1, 1, 1)
                replicatedStg.CurrentLightingProperties2["Ambient"].Value =
                    Color3.new(1, 1, 1)
                replicatedStg.Ambient.Value = Color3.new(1, 1, 1)
            end
            setFullBright()
            fullbrightCnn = game:GetService("RunService").Heartbeat:Connect(
                                function()
                    task.wait(10)
                    setFullBright()
                end)
        end
    })
    local infSprintClosure = loadstring(game:HttpGet(
                                            ("https://pastebin.com/raw/UJWKsHXC"),
                                            true))
    local infStaminaSet = false
    local sprintUnsetRemovalConnection = nil
    local sprintSetOnAddedConnection = nil

    Tab:Button({
        Name = "Infinite Stamina",
        Callback = function()
            if game.Players.LocalPlayer.Character == nil then
                Window:Notify({
                    Title = "Your character does not exist",
                    Text = "Infinite stamina not set. Please spawn before triggering it, this is only going to happen this first time!",
                    Duration = 5
                })
                return
            end

            if infStaminaSet then
                Window:Notify({
                    Title = "Infinite Stamina",
                    Text = "Infinite stamina is already enabled!",
                    Duration = 5
                })
                return
            end

            if sprintUnsetRemovalConnection == nil then
                sprintUnsetRemovalConnection =
                    game.Players.LocalPlayer.CharacterRemoving:Connect(
                        function(char)
                            infStaminaSet = false
                        end)
            end
            if sprintSetOnAddedConnection == nil then
                sprintSetOnAddedConnection =
                    game.Players.LocalPlayer.CharacterAdded:Connect(
                        function(char)
                            infStaminaSet = true
                            task.wait(3)
                            infSprintClosure()
                        end)
            end

            infSprintClosure()
            infStaminaSet = true
        end
    })

    local fovHbCnn = nil
    Tab:Slider({
        Name = "Fog Render Distance",
        Default = game:GetService("ReplicatedStorage").CurrentLightingProperties
            .FogEnd.Value,
        Min = 0,
        Max = 1000,
        Callback = function(fogDistance)
            if fovHbCnn then fovHbCnn:Disconnect() end
            local replicatedStg = game:GetService("ReplicatedStorage")
            replicatedStg.DayProperties.FogEnd.Value = fogDistance
            replicatedStg.NightProperties.FogEnd.Value = fogDistance

            fovHbCnn = game:GetService("RunService").Heartbeat:Connect(
                           function()
                    game:GetService("ReplicatedStorage").CurrentLightingProperties
                        .FogEnd.Value = fogDistance
                end)
        end
    })
    heartBeatGameEventsCnn = nil
    heartBeatPlayerDownedCnn = nil
    Tab:Toggle({
        Name = "Game Events",
        Default = false,
        Callback = function(state)
            -- LOCALS FOR EVENTS SYSTEM
            alertedPowerLow = false
            alertedNightStarted = true
            alertedNightOrDayCycle = false
            alertedRakeSpawned = false
            alertedRakeAttackPlayer = false
            alertedRakeChasing = false
            alertedBloodHour = false
            alertedTurningDayTime = false
            rakeWorkspaceReference = nil
            -- (END) LOCALS FOR EVENTS SYSTEM
            if state and heartBeatGameEventsCnn == nil then
                local replicatedStorage = game:GetService("ReplicatedStorage")
                heartBeatGameEventsCnn =
                    game:GetService("RunService").Heartbeat:Connect(function()
                        if not alertedPowerLow and
                            replicatedStorage.PowerValues.PowerLevel.Value /
                            replicatedStorage.PowerValues.PPMS.Value < 20 then
                            alertedPowerLow = true
                            Window:Notify({
                                Title = "Power Status:",
                                Text = "The power will run out soon, around " ..
                                    replicatedStorage.PowerValues.PowerLevel
                                        .Value /
                                    replicatedStorage.PowerValues.PPMS.Value ..
                                    " seconds left!",
                                Duration = 10,
                                Callback = function()
                                    return
                                end
                            })
                        end

                        -- Restore switch.
                        if alertedPowerLow and
                            replicatedStorage.PowerValues.PowerLevel.Value > 500 then
                            alertedPowerLow = false
                        end

                        if replicatedStorage.Night.Value == true and
                            replicatedStorage.Timer.Value > 450 and
                            not alertedNightStarted then
                            alertedBloodHour = false -- Restore when false.
                            alertedNightStarted = true
                            alertedNightOrDayCycle = false
                            alertedRakeSpawned = false
                            Window:Notify({
                                Title = "Night started",
                                Text = "The in-game night cycle has started.",
                                Duration = 10,
                                Callback = function()
                                    return
                                end
                            })
                        end

                        if replicatedStorage.Timer.Value <= 15 and
                            replicatedStorage.Timer.Value > 0 and
                            not alertedNightOrDayCycle then
                            alertedNightOrDayCycle = true
                            if replicatedStorage.Night.Value then
                                Window:Notify({
                                    Title = "Night ends soon",
                                    Text = "The in-game night will end in " ..
                                        replicatedStorage.Timer.Value ..
                                        " seconds.",
                                    Duration = 15,
                                    Callback = function()
                                        return
                                    end
                                })
                            else
                                Window:Notify({
                                    Title = "Night starts soon",
                                    Text = "The in-game night will start in " ..
                                        replicatedStorage.Timer.Value ..
                                        " seconds.",
                                    Duration = 15,
                                    Callback = function()
                                        return
                                    end
                                })
                            end
                        end

                        if replicatedStorage.Timer.Value == 0 then
                            alertedNightOrDayCycle = false
                            alertedNightStarted = false
                        end

                        if rakeWorkspaceReference and not alertedRakeSpawned then
                            alertedRakeSpawned = true
                            Window:Notify({
                                Title = "The Rake Status",
                                Text = "The Rake has spawned in the map.",
                                Duration = 15,
                                Callback = function()
                                    return
                                end
                            })
                        end

                        if game:GetService("ReplicatedStorage").InitiateBloodHour
                            .Value == true and not alertedBloodHour then
                            alertedBloodHour = true
                            Window:Notify({
                                Title = "Blood Hour started",
                                Text = "The blood hour has started",
                                Duration = 10,
                                Callback = function()
                                    return
                                end
                            })
                        end

                        if rakeWorkspaceReference == nil then
                            rakeWorkspaceReference = false -- Stub.
                            task.spawn(function()
                                while workspace:FindFirstChild("Rake") == nil do
                                    task.wait(5)
                                end
                                rakeWorkspaceReference =
                                    workspace:FindFirstChild("Rake")
                            end)
                        end

                        if rakeWorkspaceReference then
                            local monster =
                                rakeWorkspaceReference:FindFirstChild("Monster")

                            if monster == nil then
                                return
                            end

                            if monster.WalkSpeed > 29 and
                                not game:GetService("ReplicatedStorage").InitiateBloodHour
                                    .Value and not alertedTurningDayTime then
                                alertedTurningDayTime = true
                                Window:Notify({
                                    Title = "The Rake AI",
                                    Text = "The rake is hiding back to its base (Turning daytime)!",
                                    Duration = 10,
                                    Callback = function()
                                        return
                                    end
                                })
                            end
                            if monster.WalkSpeed > 16 and not alertedRakeChasing then
                                alertedRakeChasing = true
                                Window:Notify({
                                    Title = "The Rake AI",
                                    Text = "The rake is chasing somebody",
                                    Duration = 10,
                                    Callback = function()
                                        return
                                    end
                                })
                            end
                            if alertedRakeChasing and monster.WalkSpeed == 13 then
                                alertedRakeChasing = false
                                Window:Notify({
                                    Title = "The Rake AI",
                                    Text = "The rake has stopped chasing",
                                    Duration = 10,
                                    Callback = function()
                                        return
                                    end
                                })
                            end

                            if not alertedRakeAttackPlayer and monster.WalkSpeed <=
                                10 then
                                alertedRakeAttackPlayer = true
                                Window:Notify({
                                    Title = "The Rake AI",
                                    Text = "The rake has possibly attacked somebody",
                                    Duration = 5,
                                    Callback = function()
                                        return
                                    end
                                })
                            end
                            if alertedRakeAttackPlayer and monster.WalkSpeed >
                                10 then
                                alertedRakeAttackPlayer = false -- Do magic.
                            end
                        end
                    end)
                local downedPlayers = {}
                cleanupTask = task.spawn(function()
                    while task.wait(40) and heartBeatPlayerDownedCnn do
                        downedPlayers = {}
                    end
                    local cpy = cleanupTask
                    cleanupTask = nil
                    task.cancel(cpy)
                end)
                local function ShowGuiForPlayerDowned(v)
                    if v.Character.Downed.Value == true then
                        downedPlayers[v.Name] = true
                        Window:Notify({
                            Title = "A Player has been downed!",
                            Text = v.Character.Name .. " has been downed",
                            Duration = 10,
                            Callback = function()
                                return
                            end
                        })
                    end
                end
                heartBeatPlayerDownedCnn =
                    game:GetService("RunService").Heartbeat:Connect(function()
                        for i, v in ipairs(game.Players:GetChildren()) do
                            if downedPlayers[v.Name] == nil and v and
                                v.Character and v.Character.Downed then
                                ShowGuiForPlayerDowned(v)
                            end -- This code compiles, highlighting and LSP being gay
                        end
                    end)
            end

            if not state and heartBeatGameEventsCnn and heartBeatPlayerDownedCnn then
                heartBeatGameEventsCnn:Disconnect()
                heartBeatPlayerDownedCnn:Disconnect()
                if cleanupTask then task.cancel(cleanupTask) end
            end
        end
    })
end

function initializeVisualsTab()
    local espItems = {}
    local Tab = Window:Tab({
        Name = "Visuals",
        Description = "Visuals Tab (ESP)",
        Icon = "rbxassetid://6523858394", -- Tab Icon
        Hidden = false -- IGNORE THIS
    })

    local destroyingRakeConnection = nil
    local rakeStateKeeper = nil
    Tab:Toggle({
        Name = "The Rake ESP",
        Default = false,
        Description = "Marks the Rake using an ESP!",
        Callback = function(state)
            local espOrigin_ = workspace:FindFirstChild("Rake") -- Just for setting Parent

            local espName = "The Rake"

            local function DestroyRakeESP()
                if espItems == nil then return end

                for i, value in ipairs(espItems) do
                    if value["Identifier"] == "Rake" then
                        if value["Glow"] then
                            value["Glow"]:Destroy()
                        end

                        if value["Text"] and value["Text"] == "The Rake" then
                            value["Text"]:Destroy()
                        end

                        if value["BillboardObject"] then
                            value["BillboardObject"]:Destroy()
                        end

                        table.remove(espItems, i)
                        return
                    end
                end
            end

            local function CreateRakeESP(espOrigin)
                espBillboard = Instance.new("BillboardGui")
                espBillboard.Name = "ESP_BILL"
                espBillboard.AlwaysOnTop = true
                espBillboard.LightInfluence = 1
                espBillboard.Size = UDim2.new(0, 100, 0, 20)
                espBillboard.StudsOffset = Vector3.new(0, 1, 0)
                espBillboard.Adornee = espOrigin
                espBillboard.Parent = espOrigin -- gethui()

                espText = Instance.new("TextLabel")
                espText.Name = "ESPLabel"
                espText.BackgroundTransparency = 1
                espText.Size = UDim2.new(1, 0, 1, 0)
                espText.Font = Enum.Font.SourceSansBold
                espText.FontSize = Enum.FontSize.Size14
                espText.TextColor3 = Color3.new(1, 1, 1) -- change text to something idfk
                espText.TextStrokeTransparency = 0.5
                espText.TextScaled = true
                espText.TextWrapped = true
                espText.Text = espName
                espText.Parent = espBillboard

                espGlow = Instance.new("BoxHandleAdornment")
                espGlow.Name = "ESPBox"
                espGlow.Adornee = espOrigin
                espGlow.AlwaysOnTop = true
                espGlow.Size = Vector3.new(2, 6, 3)
                espGlow.Color3 = Color3.new(0.9, 0.3, 0.41)
                espGlow.Transparency = 0.7
                espGlow.ZIndex = 1
                espGlow.Parent = espOrigin -- gethui()

                table.insert(espItems, {
                    Glow = espGlow,
                    Text = espText,
                    BillboardObject = espBillboard,
                    Identifier = "Rake"
                })
            end

            local refRake = espOrigin_
            local createdEsp = false
            if state then
                if rakeStateKeeper == nil then
                    rakeStateKeeper = task.spawn(function()
                        while true do
                            task.wait(5)
                            if refRake == nil then
                                while workspace:FindFirstChild("Rake") == nil do
                                    task.wait(5)
                                end
                                refRake = workspace:FindFirstChild("Rake")
                                CreateRakeESP(refRake)
                                if destroyingRakeConnection == nil then
                                    destroyingRakeConnection =
                                        refRake.Destroying:Connect(function()
                                            DestroyRakeESP()
                                            refRake = nil
                                            createdEsp = false
                                        end)
                                end
                            end
                        end
                    end)
                end
                if refRake then CreateRakeESP(refRake) end
                if destroyingRakeConnection then
                    destroyingRakeConnection:Disconnect()
                    destroyingRakeConnection = nil
                end
                if destroyingRakeConnection == nil and refRake then
                    destroyingRakeConnection =
                        refRake.Destroying:Connect(function()
                            DestroyRakeESP()
                            refRake = nil
                            createdEsp = false
                        end)
                end
            else
                DestroyRakeESP()
            end
        end
    })

    local plrAddedCnn = nil
    local plrRemovedCnn = nil
    Tab:Toggle({
        Name = "Players ESP",
        Default = false,
        Callback = function(state)
            local espName = "The Rake"

            local function DestroyEsp(espId)
                if espItems == nil then return end

                for i, value in ipairs(espItems) do
                    if value["Identifier"] == espId then
                        if value["Glow"] then
                            value["Glow"]:Destroy()
                        end

                        if value["Text"] and value["Text"] ~= "Rake" then
                            value["Text"]:Destroy()
                        end

                        if value["BillboardObject"] then
                            value["BillboardObject"]:Destroy()
                        end

                        table.remove(espItems, i)
                        return
                    end
                end
            end

            local function CreateEsp(espOrigin, espName, identifier)
                espBillboard = Instance.new("BillboardGui")
                espBillboard.Name = "ESP_BILL"
                espBillboard.AlwaysOnTop = true
                espBillboard.LightInfluence = 1
                espBillboard.Size = UDim2.new(0, 100, 0, 20)
                espBillboard.StudsOffset = Vector3.new(0, 1, 0)
                espBillboard.Adornee = espOrigin
                espBillboard.Parent = espOrigin -- gethui()

                espText = Instance.new("TextLabel")
                espText.Name = "ESPLabel"
                espText.BackgroundTransparency = 1
                espText.Size = UDim2.new(1, 0, 1, 0)
                espText.Font = Enum.Font.SourceSansBold
                espText.FontSize = Enum.FontSize.Size14
                espText.TextColor3 = Color3.new(1, 1, 1) -- change text to something idfk
                espText.TextStrokeTransparency = 0.5
                espText.TextScaled = true
                espText.TextWrapped = true
                espText.Text = espName
                espText.Parent = espBillboard

                espGlow = Instance.new("BoxHandleAdornment")
                espGlow.Name = "ESPBox"
                espGlow.Adornee = espOrigin
                espGlow.AlwaysOnTop = true
                espGlow.Size = Vector3.new(4, 6, 3)
                espGlow.Color3 = Color3.new(0.4, 0.7, 0.5)
                espGlow.Transparency = 0.7
                espGlow.ZIndex = 1
                espGlow.Parent = espOrigin -- gethui()

                table.insert(espItems, {
                    Glow = espGlow,
                    Text = espText,
                    BillboardObject = espBillboard,
                    Identifier = identifier
                })
            end

            local refRake = nil
            local createdEsp = false
            if state then
                for i, v in ipairs(game.Players:GetChildren()) do
                    if v.UserId ~= game.Players.LocalPlayer.UserId and
                        v.Character and v.Character:FindFirstChild("Humanoid") then
                        local uid = v.UserId
                        CreateEsp(v.Character, v.Character.Name, uid)
                        v.CharacterAdded:Connect(function(char)
                            task.wait(2)

                            CreateEsp(char, char.Name, uid)
                        end)
                        v.CharacterRemoving:Connect(function()
                            task.wait(2)

                            DestroyEsp(uid)
                        end)
                    end
                end
                if plrAddedCnn == nil then
                    plrAddedCnn =
                        game:GetService("Players").PlayerAdded:Connect(function(
                            playerObject)
                            local uid = playerObject.UserId
                            playerObject.CharacterAdded:Connect(function(char)
                                task.wait(2)

                                CreateEsp(char, char.Name, uid)
                            end)
                            playerObject.CharacterRemoving:Connect(function()
                                task.wait(2)

                                DestroyEsp(uid)
                            end)
                        end)
                    plrRemovedCnn =
                        game:GetService("Players").PlayerRemoving:Connect(
                            function(player)
                                DestroyEsp(player.UserId)
                            end)
                end
            else
                for i, v in ipairs(game.Players:GetChildren()) do
                    if v.Character and v.Character:FindFirstChild("Humanoid") then
                        DestroyEsp(v.UserId)
                    end
                end
                if plrAddedCnn then plrAddedCnn:Disconnect() end
                if plrRemovedCnn then plrRemovedCnn:Disconnect() end
            end
        end
    })
end

-- ! INITIALIZE WINDOW.
Window = Library:Create({ToggleKey = Enum.KeyCode.Insert})

initializeMiscTab()
initializeVisualsTab()
end;

if game.GameId == 3772683742 then
pcall(function() game:GetService("Workspace").Live.Script:Destroy() end)

local Players = game:GetService("Players")
local rs = game:GetService("RunService")
local lp = Players.LocalPlayer
local infjumpenabled = false

local Library = loadstring(game:HttpGet(
                               "https://raw.githubusercontent.com/Bebo-Mods/Scripts/master/YouWontDoAnythingWithThat.lua"))()
local Tools = {
    "Nagi Nagi no mi", "Suke Suke no mi", "Guru Guru no mi", "Sube Sube No mi",
    "Dark Magic (Simon)", "Purple Flare", "Airwalk", "Blaze", "Mera Mera no mi",
    "Zushi Zushi no mi", "Goro Goro no mi", "Suna Suna no mi",
    "Moku Moku no mi", "Yami Yami no mi", "Gomu Gomu no mi", "Pika Pika no mi",
    "Hie Hie no mi", "Anti Magic", "Sunshine (Escanor)"
}

local Mobs = {}
local Quests = {}
local SelectedMob
local SelectedQuest
local Distance
local CurrentMob

for i, v in pairs(game.workspace.Live:GetChildren()) do
    table.insert(Mobs, v.Name)
end
for i, v in pairs(game:GetService("Workspace").QuestBoards:GetDescendants()) do
    if string.find(v.Name, "Defeat") then table.insert(Quests, v.Name) end
end
function RemoveTableDupes(tab)
    local hash = {}
    local res = {}
    for _, v in ipairs(tab) do
        if (not hash[v]) then
            res[#res + 1] = v
            hash[v] = true
        end
    end
    return res
end
Mobs = RemoveTableDupes(Mobs)

-- Window
local Window = Library:Create({ToggleKey = Enum.KeyCode.Insert})

-- Tab
local Tab = Window:Tab({
    Name = "Project XXL",
    Description = "Codexus Hub",
    Icon = "rbxassetid://11254763826", -- Tab Icon
    Color = Color3.new(0.811765, 0.313725, 0.247059), -- Tab Colour
    Hidden = false -- IGNORE THIS
})
-- Section
Tab:Section({Name = "~Functions~"})
Tab:Label({Text = "Enjoy!!"})

Tab:Dropdown({
    Name = "Select Mob",
    Items = {table.unpack(Mobs)}, -- Table
    Callback = function(MobSelected) SelectedMob = MobSelected end
})

Tab:Slider({
    Name = "Mob Distance",
    Min = 1, -- Min Val
    Max = 8, -- Max Val
    Default = 5, -- Default Val
    Callback = function(DSSA) Distance = DSSA end
})
local FarmSelected
Tab:Toggle({
    Name = "Farm Mob",
    Default = false,
    Callback = function(state22)
        if state22 then
            FarmSelected = rs.Heartbeat:connect(function()
                if not CurrentMob or not CurrentMob:FindFirstChild("Humanoid") or
                    not CurrentMob:FindFirstChild("HumanoidRootPart") then
                    CurrentMob = nil
                    Mobs = game.workspace.Live:GetChildren()
                    for i = 1, #Mobs do
                        local v = Mobs[i]
                        if v.Name == SelectedMob and v ~= nil and
                            v.Humanoid.Health > 0 and
                            v:FindFirstChild("HumanoidRootPart") then
                            CurrentMob = v
                            break
                        end
                    end
                end

                if CurrentMob then
                    lp.Character.Humanoid:ChangeState(11)
                    lp.Character.HumanoidRootPart.CFrame =
                        CurrentMob.HumanoidRootPart.CFrame *
                            CFrame.Angles(math.rad(-90), 0, 0) +
                            Vector3.new(0, Distance, 0)
                end
            end)
            return
        end
        FarmSelected:Disconnect()
    end
})

Tab:Dropdown({
    Name = "Select Quest",
    Items = {table.unpack(Quests)}, -- Table
    Callback = function(Quest) SelectedQuest = Quest end
})
local AutoQuest
Tab:Toggle({
    Name = "Auto Quest",
    Default = false, -- Default Value
    Callback = function(ss11)
        if ss11 then
            AutoQuest = rs.Heartbeat:Connect(function()
                if AutoQuest then
                    if lp.PlayerGui.Menu.QuestFrame.Visible == false then
                        game:GetService("ReplicatedStorage").RemoteEvents
                            .ChangeQuestRemote:FireServer(game:GetService(
                                                              "ReplicatedStorage").Quests[SelectedQuest])
                    end
                end
            end)
            return
        end
        AutoQuest:Disconnect()
    end
})
local ChestFarm
Tab:Toggle({
    Name = "Chest Farm",
    Default = false, -- Default Value
    Callback = function(ss112)
        if ss112 then
            ChestFarm = rs.Heartbeat:Connect(function()
                if ChestFarm then
                    local Chests =
                        game:GetService("Workspace").Chests:GetChildren()
                    for i = 1, #Chests do
                        local v = Chests[i]
                        if v.Transparency == 0 then
                            game:GetService("Players").LocalPlayer.Character
                                .HumanoidRootPart.CFrame = v.CFrame
                            break
                        end
                    end
                end
            end)
            return
        end
        ChestFarm:Disconnect()
    end
})
local KillAura
Tab:Toggle({
    Name = "Kill Aura",
    Default = false, -- Default Value
    Callback = function(ss1122)
        if ss1122 then
            KillAura = rs.Heartbeat:Connect(function()
                if KillAura then
                    local Mobss1 = game.workspace.Live:GetChildren()
                    for i = 1, #Mobss1 do
                        local x = Mobss1[i]
                        if x:FindFirstChild("Humanoid").Health > 0 and
                            x:FindFirstChild("HumanoidRootPart") and
                            lp:DistanceFromCharacter(x.HumanoidRootPart.Position) <
                            15 then
                            game:GetService("ReplicatedStorage").RemoteEvents
                                .BladeCombatRemote:FireServer(false,
                                                              x.HumanoidRootPart
                                                                  .Position,
                                                              x.HumanoidRootPart
                                                                  .CFrame)
                        end
                    end
                end
            end)
            return
        end
        KillAura:Disconnect()
    end
})
local AntiMobs
Tab:Toggle({
    Name = "Anti Mobs",
    Default = false, -- Default Value
    Callback = function(AntiMobs2)
        if AntiMobs2 then
            AntiMobs = rs.Heartbeat:Connect(function()
                if AntiMobs then
                    local Mobss = game.workspace.Live:GetChildren()
                    for i = 1, #Mobss do
                        local v = Mobss[i]
                        if v:FindFirstChild("Humanoid").Health > 0 and
                            v:FindFirstChild("HumanoidRootPart") and
                            lp:DistanceFromCharacter(v.HumanoidRootPart.Position) <
                            12 then
                            v.HumanoidRootPart.CFrame = lp.Character
                                                            .HumanoidRootPart
                                                            .CFrame +
                                                            Vector3.new(10, 0, 0)
                        end
                    end
                end
            end)
            return
        end
        AntiMobs:Disconnect()
    end
})
local Tab2 = Window:Tab({
    Name = "Player",
    Description = "Player Tab",
    Icon = "rbxassetid://6031215978", -- Tab Icon
    Color = Color3.new(1, 0.968627, 0), -- Tab Colour
    Hidden = false -- IGNORE THIS
})
Tab2:Button({
    Name = "Reset Character",
    Callback = function()
        game.Players.LocalPlayer.Character.Humanoid.Health = 0
    end
})

Tab2:Button({
    Name = "BTools",
    Callback = function()
        local tool1 = Instance.new("HopperBin",
                                   game.Players.LocalPlayer.Backpack)
        local tool2 = Instance.new("HopperBin",
                                   game.Players.LocalPlayer.Backpack)
        local tool3 = Instance.new("HopperBin",
                                   game.Players.LocalPlayer.Backpack)
        local tool4 = Instance.new("HopperBin",
                                   game.Players.LocalPlayer.Backpack)
        local tool5 = Instance.new("HopperBin",
                                   game.Players.LocalPlayer.Backpack)
        tool1.BinType = "Clone"
        tool2.BinType = "GameTool"
        tool3.BinType = "Hammer"
        tool4.BinType = "Script"
        tool5.BinType = "Grab"
    end
})

Tab2:Toggle({
    Name = "Noclip",
    Default = false, -- Default Value
    Callback = function(NoclIp)
        _G.NoclIp2 = NoclIp or false
        game:GetService("RunService").Stepped:connect(function()
            if _G.NoclIp2 then
                pcall(function()
                    lp = game:service "Players".LocalPlayer
                    lp.Character.Head.CanCollide = false
                    lp.Character.LowerTorso.CanCollide = false
                    lp.Character.UpperTorso.CanCollide = false
                    lp.Character.HumanoidRootPart.CanCollide = false
                    if lp.Character:FindFirstChild "Badge" then
                        lp.Character.Badge.CanCollide = false
                    end
                end)
            end
        end)
    end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infjumpenabled then
        game:GetService("Players").LocalPlayer.Character.Humanoid:ChangeState(
            "Jumping")
    end
end)

Tab2:Toggle({
    Name = "Inf Jump",
    Default = false, -- Default Value
    Callback = function(InfJUmp) infjumpenabled = InfJUmp end
})

Tab2:Slider({
    Name = "Walkspeed",
    Min = 1,
    Max = 300,
    Default = 16,
    Callback = function(value)
        _G.HackedJumpPower = (value)

        local Plrs = game:GetService("Players")

        local MyPlr = Plrs.LocalPlayer
        local MyChar = MyPlr.Character

        if MyChar then
            local Hum = MyChar.Humanoid
            Hum.Changed:connect(function()
                Hum.JumpPower = _G.HackedJumpPower
            end)
            Hum.JumpPower = _G.HackedJumpPower
        end

        MyPlr.CharacterAdded:connect(function(Char)
            MyChar = Char
            repeat wait() until Char:FindFirstChild("Humanoid")
            local Hum = Char.Humanoid
            Hum.Changed:connect(function()
                Hum.JumpPower = _G.HackedJumpPower
            end)
            Hum.JumpPower = _G.HackedJumpPower
        end)
    end
})

Tab2:Slider({
    Name = "Walkspeed",
    Min = 1,
    Max = 300,
    Default = 16,
    Callback = function(value)
        _G.HackedWalkSpeed = (value)

        local Plrs = game:GetService("Players")

        local MyPlr = Plrs.LocalPlayer
        local MyChar = MyPlr.Character

        if MyChar then
            local Hum = MyChar.Humanoid
            Hum.Changed:connect(function()
                Hum.WalkSpeed = _G.HackedWalkSpeed
            end)
            Hum.WalkSpeed = _G.HackedWalkSpeed
        end

        MyPlr.CharacterAdded:connect(function(Char)
            MyChar = Char
            repeat wait() until Char:FindFirstChild("Humanoid")
            local Hum = Char.Humanoid
            Hum.Changed:connect(function()
                Hum.WalkSpeed = _G.HackedWalkSpeed
            end)
            Hum.WalkSpeed = _G.HackedWalkSpeed
        end)
    end
})
local Tab3 = Window:Tab({
    Name = "Fruit Sniper",
    Description = "Snipe Fruits",
    Icon = "rbxassetid://6034684937", -- Tab Icon
    Color = Color3.new(0.564705, 0, 1), -- Tab Colour
    Hidden = false -- IGNORE THIS
})
local Option1
local Option2
local Option3
local Option4
local Option5
local Option6
Tab3:Dropdown({
    Name = "Select Fruit 1",
    Items = {table.unpack(Tools)}, -- Table
    Callback = function(Value1) Option1 = Value1 end
})

Tab3:Dropdown({
    Name = "Select Fruit 2",
    Items = {table.unpack(Tools)}, -- Table
    Callback = function(Value2) Option2 = Value2 end
})

Tab3:Dropdown({
    Name = "Select Fruit 3",
    Items = {table.unpack(Tools)}, -- Table
    Callback = function(Value3) Option3 = Value3 end
})

Tab3:Dropdown({
    Name = "Select Fruit 4",
    Items = {table.unpack(Tools)}, -- Table
    Callback = function(Value4) Option4 = Value4 end
})

Tab3:Dropdown({
    Name = "Select Fruit 5",
    Items = {table.unpack(Tools)}, -- Table
    Callback = function(Value5) Option5 = Value5 end
})

Tab3:Dropdown({
    Name = "Select Fruit 6",
    Items = {table.unpack(Tools)}, -- Table
    Callback = function(Value6) Option6 = Value6 end
})
local SnipeFruit
Tab3:Toggle({
    Name = "Auto Snipe Selected",
    Default = false,
    Callback = function(Snipe) SnipeFruit = Snipe end
})

spawn(function()
    while task.wait(1) do
        if SnipeFruit then
            local Sniper = game.workspace:GetChildren()
            for i = 1, #Sniper do
                local v = Sniper[i]
                if v:IsA("Tool") and string.find(v.Name, Option1) or
                    string.find(v.Name, Option2) or string.find(v.Name, Option3) or
                    string.find(v.Name, Option4) or string.find(v.Name, Option5) or
                    string.find(v.Name, Option6) then
                    v.Handle.CFrame = game.Players.LocalPlayer.Character
                                          .PrimaryPart.CFrame
                end
            end
        end
    end
end)
Window:Notify({
    Name = "Notification",
    Text = "Press Insert To Toggle GUI",
    Duration = 5,
    Callback = function() return end -- Callback when the notification ends
})
end;

if game.GameId == 4730278139 then
local Players = game:GetService("Players")
local rs = game:GetService("RunService")
local lp = Players.LocalPlayer
local character = lp.Character

local Library =
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Bebo-Mods/Scripts/master/YouWontDoAnythingWithThat.lua"))(

)
local Distance
local HitboxSize
local WalkSPEED
local JumpPOWER

-- Window
local Window =
    Library:Create(
    {
        ToggleKey = Enum.KeyCode.Insert
    }
)

-- Tab
local Tab =
    Window:Tab(
    {
        Name = "Untitled Boxing Game",
        Description = "Codexus Hub",
        Icon = "rbxassetid://11254763826", -- Tab Icon
        Color = Color3.new(0.811765, 0.313725, 0.247059), -- Tab Colour
        Hidden = false -- IGNORE THIS
    }
)
-- Section
Tab:Section(
    {
        Name = "~Functions~"
    }
)
Tab:Label({
	Text = "To avoid kicking use the kill aura in rings only and also fighiting multiple enemies"
})

Tab:Slider(
    {
        Name = "Kill Aura Distance",
        Min = 1, -- Min Val
        Max = 17, -- Max Val
        Default = 10, -- Default Val
        Callback = function(val)
            Distance = val
        end
    }
)

Tab:Toggle(
    {
        Name = "Kill Aura",
        Default = false,
        Callback = function(state22)
            KillAura = state22
        end
    }
)

spawn(function()
    while true do
        task.wait(0.8)
        
        if KillAura then
            local localCharacter = lp.Character
            if not localCharacter then
                break
            end
            local humanoidRootPart = localCharacter:FindFirstChild("HumanoidRootPart")
            
            for _, player in ipairs(Players:GetPlayers()) do
                local character = player.Character
                if character and character ~= localCharacter then
                    local position = character.PrimaryPart.Position
                    local humanoid = character.Humanoid
                    if lp:DistanceFromCharacter(position) <= Distance and humanoid.Health > 0 and humanoidRootPart then
                        game:GetService("ReplicatedStorage").RemoteEvents.HandleEquip:FireServer(true)
                        
                        local A_1 = {
                            ["Victim"] = character,
                            ["Character"] = localCharacter,
                            ["IsHeavy"] = true,
                            ["CurrentHeavy"] = 1,
                            ["CurrentPunch"] = 1,
                            ["CurrentCombo"] = 2
                        }
                        game:GetService("ReplicatedStorage").RemoteEvents.TryAttack:FireServer(A_1)
                        
                        break
                    end
                end
            end
        end
    end
end)

Tab:Slider(
    {
        Name = "Hitbox Size",
        Min = 1, -- Min Val
        Max = 50, -- Max Val
        Default = 15, -- Default Val
        Callback = function(val)
            HitboxSize = val
        end
    }
)
local HitboxConnection = nil -- Initialize hitbox connection

local function ModifyHitboxSize(size)
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game:GetService("Players").LocalPlayer then
            pcall(function()
                player.Character.HumanoidRootPart.Size = size
                player.Character.HumanoidRootPart.Transparency = 0.8
                player.Character.HumanoidRootPart.BrickColor = BrickColor.new("Really black")
                player.Character.HumanoidRootPart.Material = "Neon"
                player.Character.HumanoidRootPart.CanCollide = false
            end)
        end
    end
end

local function ToggleCallback(state)
    if state then
        HitboxConnection = rs.Heartbeat:Connect(function()
            ModifyHitboxSize(Vector3.new(HitboxSize, HitboxSize, HitboxSize))
        end)
    else
        if HitboxConnection then
            HitboxConnection:Disconnect()
            HitboxConnection = nil
            -- Reset hitbox sizes when the toggle is turned off
            ModifyHitboxSize(Vector3.new(2, 2, 1))
        end
    end
end

Tab:Toggle(
    {
        Name = "Hitbox",
        Default = false,
        Callback = ToggleCallback
    }
)
Tab:Button(
    {
        Name = "Inf Dash",
        Callback = function()
            local mt = getrawmetatable(game)
            local old = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall =
                newcclosure(
                function(self, ...)
                    local args = {...}
                    if getnamecallmethod() == "FireServer" and self.Name == "TryDash" then
                        args[1] = "YOUR MOM"
                    end
                    return old(self, unpack(args))
                end
            )
        end
    }
)


local Tab2 =
    Window:Tab(
    {
        Name = "Player",
        Description = "Player Tab",
        Icon = "rbxassetid://6031215978", -- Tab Icon
        Color = Color3.new(1, 0.968627, 0), -- Tab Colour
        Hidden = false -- IGNORE THIS
    }
)

Tab2:Slider(
    {
        Name = "Walkspeed",
        Min = 1, -- Min Val
        Max = 200, -- Max Val
        Default = 16, -- Default Val
        Callback = function(val312val312)
            WalkSPEED = val312val312
            character:FindFirstChildOfClass("Humanoid"):GetPropertyChangedSignal("WalkSpeed"):Connect(
                function()
                    character.Humanoid.WalkSpeed = WalkSPEED
                end
            )
            character.Humanoid.WalkSpeed = WalkSPEED
        end
    }
)
Tab2:Slider(
    {
        Name = "Jump Power",
        Min = 1, -- Min Val
        Max = 200, -- Max Val
        Default = 30, -- Default Val
        Callback = function(val312val3121)
            JumpPOWER = val312val3121
            character:FindFirstChildOfClass("Humanoid"):GetPropertyChangedSignal("WalkSpeed"):Connect(
                function()
                    character.Humanoid.JumpPower = JumpPOWER
                end
            )
            character.Humanoid.JumpPower = JumpPOWER
        end
    }
)
-- Accessing settings tab
local SettingsTab = Window.SettingsTab

Window:Notify({
	Name = "Notification",
	Text = "Press Insert To Toggle GUI",
	Duration = 5,
	Callback = function() return end -- Callback when the notification ends
})
end;

if game.GameId == 4987467534 then
local PlayerService = game:GetService("Players")
local LocalPlayer = PlayerService.LocalPlayer
local LocalPlayerCharacter = PlayerService.LocalPlayer.Character or PlayerService.LocalPlayer.CharacterAdded:Wait()
PlayerService.LocalPlayer.CharacterAdded:Connect(function(character)
	LocalPlayerCharacter = character
end)

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager =
	loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(
	game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua")
)()

local Window = Fluent:CreateWindow({
	Title = "Residence Masacre",
	SubTitle = "by Codexus Hub",
	TabWidth = 160,
	Size = UDim2.fromOffset(580, 460),
	Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.Insert, -- Used when theres no MinimizeKeybind
})

local Tabs = {
	Main = Window:AddTab({ Title = "Main", Icon = "code-2" }),
	Visuals = Window:AddTab({ Title = "Visuals", Icon = "view" }),
	Credits = Window:AddTab({ Title = "Credits", Icon = "thumbs-up" }),
	Misc = Window:AddTab({ Title = "Miscellaneous", Icon = "book-mark" }),
	Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

local Options = Fluent.Options

Fluent:Notify({
	Title = "GUI Loaded!",
	Content = "The GUI has been loaded! Thanks for using it, " .. LocalPlayer.DisplayName .. "!",
	Duration = 5, -- Set to nil to make the notification not disappear
})

function initialiseMain(tabs)
	--- @type thread | nil
	local autoWireFixerThread = nil
	local autoWireFixerToggle = tabs.Main:AddToggle(
		"auto_wire",
		{ Title = "Enable Auto Wire", Description = "Automatically completes the wire mini-game", Default = false }
	)

	autoWireFixerToggle:OnChanged(function()
		if autoWireFixerThread then
			task.cancel(autoWireFixerThread)
		end
		if Options.auto_wire.Value then
			autoWireFixerThread = task.spawn(function()
				while task.wait(0.5) do
					local wireRemote = game:GetService("ReplicatedStorage").Remotes.ClickWire
					for i, v in pairs(game:GetService("Workspace").FuseBox.Wires:GetChildren()) do
						for i, p in pairs(v:GetChildren()) do
							if p:IsA("ParticleEmitter") then
								if p.Enabled then
									wireRemote:FireServer(p.Parent)
								end
							end
						end
					end
				end
			end)
		end
	end)

	--- @type RBXScriptConnection | nil
	local infiniteStaminaConnection = nil
	local infiniteStaminaToggle = tabs.Main:AddToggle(
		"inf_stamina",
		{ Title = "Enable Infinite Stamina", Description = "Bypasses the Stamina limit", Default = false }
	)

	infiniteStaminaToggle:OnChanged(function()
		if infiniteStaminaConnection and infiniteStaminaConnection.Connected then
			infiniteStaminaConnection:Disconnect()
		end

		if Options.inf_stamina.Value then
			infiniteStaminaConnection = LocalPlayer.Character
				:WaitForChild("Sprint")
				:WaitForChild("Stam")
				:GetPropertyChangedSignal("Value")
				:Connect(function()
					local stamina = LocalPlayer.Character.Sprint.Stam

					if stamina.Value < 4.5 then
						stamina.Value = 4.5
					end
				end)
		end
	end)

	--- @type RBXScriptConnection | nil
	local infiniteStaminaConnection = nil
	local infiniteStaminaToggle = tabs.Main:AddToggle(
		"inf_oxy",
		{ Title = "Enable Infinite Oxygen", Description = "Bypasses the Oxygen limit", Default = false }
	)

	infiniteStaminaToggle:OnChanged(function()
		if infiniteStaminaConnection and infiniteStaminaConnection.Connected then
			infiniteStaminaConnection:Disconnect()
		end

		if Options.inf_oxy.Value then
			infiniteStaminaConnection = LocalPlayer.Character
				:WaitForChild("Breath")
				:GetPropertyChangedSignal("Value")
				:Connect(function()
					local breath = LocalPlayer.Character.Breath

					if breath.Value < 19 then
						breath.Value = 19
					end
				end)
		end
	end)

	--- @type RBXScriptConnection | nil
	local autoPowerConnection = nil
	local autoPowerToggle = tabs.Main:AddToggle(
		"auto_pow",
		{ Title = "Automatic Power", Description = "Automatically refuels the power for Oxygen", Default = false }
	)

	autoPowerToggle:OnChanged(function()
		if autoPowerConnection and autoPowerConnection.Connected then
			autoPowerConnection:Disconnect()
		end

		local fuel = workspace.Shack.Generator.Fuel

		if fuel.Value < 80 then
			task.wait()
			local clickDetector = workspace.Shack.JerryCan:FindFirstChildOfClass("ClickDetector")
			fireclickdetector(clickDetector)
			task.wait(0.01)
			clickDetector = workspace.Shack.Generator:FindFirstChildOfClass("ClickDetector")
			fireclickdetector(clickDetector)
		end

		if Options.auto_pow.Value then
			autoPowerConnection = workspace.Shack.Generator.Fuel:GetPropertyChangedSignal("Value"):Connect(function()
				if fuel.Value < 80 then
					task.wait()
					local clickDetector = workspace.Shack.JerryCan:FindFirstChildOfClass("ClickDetector")
					fireclickdetector(clickDetector)
					task.wait(0.01)
					clickDetector = workspace.Shack.Generator:FindFirstChildOfClass("ClickDetector")
					fireclickdetector(clickDetector)
				end
			end)
		end
	end)

	--- @type thread | nil
	local windowNotifierThread = nil
	local windowNotifierToggle = tabs.Main:AddToggle("window_notifier", {
		Title = "Enable Window Notifier",
		Description = "Notifies you when the Mutant is on the Window",
		Default = false,
	})

	windowNotifierToggle:OnChanged(function()
		if windowNotifierThread then
			task.cancel(windowNotifierThread)
		end

		if Options.window_notifier.Value then
			windowNotifierThread = task.spawn(function()
				local mutant = workspace:FindFirstChild("Mutant")
				local windows = workspace:FindFirstChild("Windows"):GetChildren()
				while task.wait() do
					for _, window in pairs(windows) do
						local windowPivot = window:GetPivot()
						local winPos = windowPivot.Position
						local monsterPivot = mutant:GetPivot()
						local monsterPos = monsterPivot.Position

						if (winPos - monsterPos).Magnitude <= 5 then
							Fluent:Notify({
								Title = "The Mutant is on the Window!",
								Content = "The mutant appears to be on the Window that gives to the room '"
									.. window.RoomName.Value
									.. "' of the house, go scare it! ASAP!",
								Duration = 5, -- Set to nil to make the notification not disappear
							})
							task.wait(5)
						end
					end
				end
			end)
		end
	end)

	--- @type thread | nil
	local autoPlayThread = nil
	local autoPlayToggle = tabs.Main:AddToggle("auto_play", {
		Title = "Enable Auto Play",
		Description = "Plays the game for you, detects when the Mutant is on a Window, and turns on the light for the room, Automatically!",
		Default = false,
	})

	autoPlayToggle:OnChanged(function()
		if autoPlayThread then
			task.cancel(autoPlayThread)
		end

		if Options.auto_play.Value then
			autoPlayThread = task.spawn(function()
				local mutant = workspace:FindFirstChild("Mutant")
				local windows = workspace:FindFirstChild("Windows"):GetChildren()
				local lights = workspace:FindFirstChild("Lights"):GetChildren()
				while task.wait() do
					for _, window in pairs(windows) do
						local windowPivot = window:GetPivot()
						local winPos = windowPivot.Position
						local monsterPivot = mutant:GetPivot()
						local monsterPos = monsterPivot.Position

						local windowRoomName = window.RoomName.Value
						if (winPos - monsterPos).Magnitude <= 5 then
							Fluent:Notify({
								Title = "The Mutant is on the Window!",
								Content = "The mutant appears to be on the Window that gives to the room '"
									.. windowRoomName
									.. "' of the house, turning light on automatically!",
								Duration = 5, -- Set to nil to make the notification not disappear
							})

							local targetClickDetector = nil

							for _, light in pairs(lights) do
								local lightCfg = light:FindFirstChildOfClass("Configuration")

								if lightCfg.RoomName.Value == windowRoomName then
									targetClickDetector = light.Switch.Detector:FindFirstChildOfClass("ClickDetector")
									break
								end
							end

							fireclickdetector(targetClickDetector)
							task.wait(1)
							fireclickdetector(targetClickDetector)
							task.wait(1)
							task.wait(3)
						end
					end
				end
			end)
		end
	end)

	Tabs.Main:AddButton({
		Title = "Auto Camera",
		Description = "Claims all the cameras for the games' camera system",
		Callback = function()
			local claimedCameras = 0
			for index, value in pairs(game:GetService("Workspace").TempCameras:GetChildren()) do
				local detector = value:FindFirstChildOfClass("ClickDetector")
				if not detector then
					Fluent:Notify({
						Title = "Huh, this is weird...",
						Content = "We did not expect this, but a camera is missing something for us to claim it!",
						Duration = 5, -- Set to nil to make the notification not disappear
					})
				else
					detector.MaxActivationDistance = 69420
					task.wait(0.1)
					fireclickdetector(detector)
					claimedCameras = claimedCameras + 1
				end
			end

			if claimedCameras > 0 then
				Fluent:Notify({
					Title = "All " .. claimedCameras .. " have been claimed!",
					Content = "All the available cameras have been claimed and can now be accessed on the in-game camera system!",
					Duration = 5, -- Set to nil to make the notification not disappear
				})
			else
				Fluent:Notify({
					Title = "All cameras were already claimed before!",
					Content = "All the available cameras were already claimed, there was no need to use this!",
					Duration = 5, -- Set to nil to make the notification not disappear
				})
			end
		end,
	})

	tabs.Main:AddButton({
		Title = "Get all items",
		Description = "Gets all the items in the game. If you get none, first use the Radio to do things work",
		Callback = function()
			for _, child in pairs(workspace.Doors:GetChildren()) do
				if child.Name == "Door" then
					for _, descendant in pairs(child:GetDescendants()) do
						if descendant and descendant:IsA("ClickDetector") then
							fireclickdetector(descendant)
						end
					end
				end
			end

			-- The player hasn't grabbed a flashlight.
			if not LocalPlayerCharacter:FindFirstChild("Flashlight") then
				if
					workspace:FindFirstChild("Flashlight")
					and workspace.Flashlight.Handle:FindFirstChildOfClass("ClickDetector")
				then
					fireclickdetector(workspace.Flashlight.Handle:FindFirstChildOfClass("ClickDetector"))
				end

				task.wait(1)
			end

			for _, descendant in pairs(workspace.ItemSpots:GetDescendants()) do
				if descendant and descendant:IsA("ClickDetector") then
					fireclickdetector(descendant)
				end
			end
		end,
	})

	tabs.Main:AddButton({
		Title = "Toggle All Doors",
		Description = "This will Open or Close all the doors in the game",
		Callback = function()
			for _, child in pairs(workspace.Doors:GetChildren()) do
				if child.Name == "Door" then
					for _, descendant in pairs(child:GetDescendants()) do
						if descendant and descendant:IsA("ClickDetector") then
							fireclickdetector(descendant)
						end
					end
				end
			end
		end,
	})

	tabs.Main:AddButton({
		Title = "Toggle All Closets",
		Description = "This will Open or Close all the closets in the game [Trolling time]",
		Callback = function()
			for _, child in pairs(workspace.Doors:GetChildren()) do
				if child.Name == "Closet" then
					for _, descendant in pairs(child:GetDescendants()) do
						if descendant and descendant:IsA("ClickDetector") then
							fireclickdetector(descendant)
						end
					end
				end
			end
		end,
	})

	tabs.Main:AddButton({
		Title = "Infinite Flashlight Battery",
		Description = "Makes your Flashlight battery infinite (Requires Flashlight)",
		Callback = function()
			local flashlight = LocalPlayerCharacter:FindFirstChild("Flashlight")

			if not flashlight then
				Fluent:Notify({
					Title = "No Flashlight Found!",
					Content = "The script has not found a flashlight on you, did you grab it?",
					Duration = 5, -- Set to nil to make the notification not disappear
				})
				return
			end
			local batteryNumValue = flashlight:FindFirstChild("Battery")
			local flashlightCharges = flashlight:FindFirstChild("Charges")
			local isUpgradedFlashlight = flashlight:FindFirstChild("Upgraded")

			if batteryNumValue then
				batteryNumValue.Value = math.huge
			end
			if flashlightCharges then
				flashlightCharges.Value = math.huge
			end
			if isUpgradedFlashlight then
				isUpgradedFlashlight.Value = true
			end
		end,
	})

	local enableFBright = false
	Tabs.Main:AddButton({
		Title = "Full Bright",
		Description = "Enables Full Bright",
		Callback = function()
			task.wait(0.1)
			local lightService = game:GetService("Lighting")
			if lightService:FindFirstChild("Atmosphere") then
				lightService.Atmosphere.Density = 0
				lightService.Atmosphere.Haze = 1
				lightService.Ambient = Color3.fromRGB(128, 128, 128)
			end

			if lightService:FindFirstChild("BloodSky") then
				lightService.BloodSky:Destroy()
				Fluent:Notify({
					Title = "Full Bright",
					Content = "The blood sky has been removed as part of the Full Bright",
					Duration = 5, -- Set to nil to make the notification not disappear
				})
			end

			enableFBright = true
		end,
	})

	local oldHook
	oldHook = hookmetamethod(
		game,
		"__index",
		newcclosure(function(...)
			if not enableFBright or checkcaller() then
				return oldHook(...)
			end

			local table = select(1, ...)
			local index = select(2, ...)

			if not table or not index then
				return oldHook(...)
			end

			if tostring(table) == "Atmosphere" and index == "Density" then
				return 0
			end

			if tostring(table) == "Atmosphere" and index == "Haze" then
				return 1
			end

			if tostring(table) == "Lighting" and index == "Ambient" then
				return Color3.fromRGB(140, 140, 140)
			end

			return oldHook(...)
		end)
	)

	local oldNewIndexHook
	oldNewIndexHook = hookmetamethod(
		game,
		"__newindex",
		newcclosure(function(...)
			if not enableFBright or checkcaller() then
				return oldNewIndexHook(...)
			end

			local table = select(1, ...)
			local index = select(2, ...)
			local value = select(3, ...)

			if not table or not index or not value then
				return oldNewIndexHook(...)
			end

			if tostring(table) == "Atmosphere" and index == "Density" then
				return value
			end

			if tostring(table) == "Atmosphere" and index == "Haze" then
				return value
			end

			if tostring(table) == "Lighting" and index == "ClockTime" then
				return value
			end

			if tostring(table) == "Lighting" and index == "Ambient" then
				return value
			end

			return oldNewIndexHook(...)
		end)
	)
end

function initialiseVisuals(tabs)
	local monsterEspToggle = tabs.Visuals:AddToggle(
		"monster_esp",
		{ Title = "Monster ESP", Description = "ESP for the Mutant, the Main enemy of the game", Default = false }
	)

	monsterEspToggle:OnChanged(function()
		local function CreateContainer()
			local folder = Instance.new("Folder", gethui())
			folder.Name = "Container"
			return folder
		end

		if Options.monster_esp.Value then
			local monster = game:GetService("ReplicatedStorage"):FindFirstChild("Mutant")

			if not monster then
				monster = workspace:FindFirstChild("Mutant")
			end

			local target = monster:IsA("ObjectValue") and monster.Value or monster

			if not target then
				error("Failed to find monster for ESP!")
			end

			local container = gethui():FindFirstChild("Container") or CreateContainer()

			local highlight = Instance.new("Highlight", container) -- Create highlight, parent to gethui() to avoid possible detections!
			highlight.Adornee = target
			highlight.FillColor = Color3.fromRGB(41, 21, 0)
			highlight.FillTransparency = 0.5
			highlight.OutlineColor = Color3.fromRGB(206, 54, 54)

			local bill = Instance.new("BillboardGui", container)
			bill.AlwaysOnTop = true
			bill.Enabled = true
			bill.Adornee = target
			bill.LightInfluence = 1
			bill.Size = UDim2.new(0, 20, 0, 20)

			local frame = Instance.new("Frame", bill)

			local text = Instance.new("TextLabel", frame)
			text.Name = "lmap!"
			text.TextSize = 24
			text.Size = UDim2.new(0, 30, 0, 30)
			text.BackgroundTransparency = 1
			text.Font = Enum.Font.SourceSansBold
			text.TextScaled = true
			text.TextWrapped = true
			text.Text = "Silly Goose"
			text.TextColor3 = Color3.new(1, 1, 1)
		else
			if gethui():FindFirstChild("Container") then
				gethui().Container:Destroy()
			end
		end
	end)

	local playerEspToggle = tabs.Visuals:AddToggle(
		"player_esp",
		{ Title = "Players ESP", Description = "ESP for the players, your allies... hopefully (LOL)", Default = false }
	)

	playerEspToggle:OnChanged(function()
		local function CreateContainer()
			local folder = Instance.new("Folder", gethui())
			folder.Name = "Players_Container"
			return folder
		end

		local function GetPlayerCharacters()
			local chars = {}
			for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
				if player ~= LocalPlayer then
					table.insert(chars, player.Character)
				end
			end
			return chars
		end

		if Options.player_esp.Value then
			local playerCharacters = GetPlayerCharacters()

			local container = gethui():FindFirstChild("Players_Container") or CreateContainer()

			for _, target in pairs(playerCharacters) do
				local folder = Instance.new("Folder", container)
				local highlight = Instance.new("Highlight", folder) -- Create highlight, parent to gethui() to avoid possible detections!
				highlight.Adornee = target
				highlight.FillColor = Color3.fromRGB(128, 167, 104)
				highlight.FillTransparency = 0.5
				highlight.OutlineColor = Color3.fromRGB(54, 62, 206)

				local bill = Instance.new("BillboardGui", folder)
				bill.AlwaysOnTop = true
				bill.Enabled = true
				bill.Adornee = target
				bill.LightInfluence = 1
				bill.Size = UDim2.new(0, 20, 0, 20)

				local frame = Instance.new("Frame", bill)

				local text = Instance.new("TextLabel", frame)
				text.Name = "plrname"
				text.TextSize = 24
				text.Size = UDim2.new(0, 30, 0, 30)
				text.BackgroundTransparency = 1
				text.Font = Enum.Font.SourceSansBold
				text.TextScaled = true
				text.TextWrapped = true
				text.Text = target.Name
				text.TextColor3 = Color3.new(1, 1, 1)
				target.Destroying:Connect(function()
					folder:Destroy()
				end)
			end
		else
			if gethui():FindFirstChild("Players_Container") then
				gethui().Players_Container:Destroy()
			end
		end
	end)
end

function initialiseCredits(tabs)
	tabs.Credits:AddParagraph({
		Title = "Hello! Thanks for using Codexus Hub!",
	})
end

function initialiseMisc(tabs)
	tabs.Misc:AddButton({
		Title = "Anti AFK",
		Description = "Prevents the game from kicking you due to inactivity",
		Callback = function()
			for _, f in pairs(getconnections(LocalPlayer.Idled)) do
				f:Disable()
			end
			Fluent:Notify({
				Title = "Anti AFK Loaded!",
				Content = "The game will no longer kick you due to inactivity!",
				Duration = 5, -- Set to nil to make the notification not disappear
			})
		end,
	})

	tabs.Misc:AddButton({
		Title = "Bypass BTools and Fly Anti Cheat",
		Description = "Bypasses the Anti-Fly and Anti-BTools",
		Callback = function()
			local foundTargets = false
			for _, closure in pairs(getgc(false)) do
				if typeof(closure) == "function" and islclosure(closure) and not isexecutorclosure(closure) then
					local constants = debug.getconstants(closure)

					for _, v in pairs(constants) do
						if typeof(v) == "string" then
							if v:find("Possible exploit") or v:find("Fly script") or v:find("Btools") then
								hookfunction(closure, function()
									print("hi dev, your ac sucks :heart:")
								end)
								foundTargets = true
							end
						end
					end
				end
			end

			if foundTargets then
				Fluent:Notify({
					Title = "Bypass Loaded!",
					Content = "The game will no longer try to kick you if you try to fly or use BTools!",
					Duration = 5, -- Set to nil to make the notification not disappear
				})
			else
				Fluent:Notify({
					Title = "Bypass Failed to Load!",
					Content = "The bypass has failed to load, perhaps the game was updated and the bypass, patched!",
					Duration = 5, -- Set to nil to make the notification not disappear
				})
			end
		end,
	})

	tabs.Misc:AddButton({
		Title = "Server Hop",
		Description = "Hops game servers",
		Callback = function()
			game:GetService("TeleportService"):Teleport(game.PlaceId)
		end,
	})
end

function initialiseEverything()
	initialiseMain(Tabs)
	initialiseVisuals(Tabs)
	initialiseCredits(Tabs)
	initialiseMisc(Tabs)

	SaveManager:SetLibrary(Fluent)
	InterfaceManager:SetLibrary(Fluent)
	SaveManager:IgnoreThemeSettings()
	SaveManager:SetIgnoreIndexes({})
	InterfaceManager:SetFolder("CodexusHubFree")
	SaveManager:SetFolder("CodexusHubFree/ResidenceMassacre")
	InterfaceManager:BuildInterfaceSection(Tabs.Settings)
	SaveManager:BuildConfigSection(Tabs.Settings)
	Window:SelectTab(1)
	SaveManager:LoadAutoloadConfig()
end

initialiseEverything()
end;



--- END CODE


