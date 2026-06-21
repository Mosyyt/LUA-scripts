local Library = loadstring(
	game:HttpGet("https://raw.githubusercontent.com/Bebo-Mods/Scripts/master/YouWontDoAnythingWithThat.lua")
)()

-- Window
local Window = Library:Create({ ToggleKey = Enum.KeyCode.Insert })

function initialiseMain(window)
	--- #region Service Imports

	local PlayerService = game:GetService("Players")

	--- #endregion Service Imports
end

function initialiseVisuals(window)
	--- #region Service Imports

	local PlayerService = game:GetService("Players")

	--- #endregion Service Imports

	local VisualsTab = window:Tab({
		Name = "Visuals",
		Description = "~ Codexus Hub ~ Bebo Mods",
		Icon = "rbxassetid://11254763826", -- Tab Icon
		Color = Color3.new(0.811765, 0.313725, 0.247059), -- Tab Colour
		Hidden = false, -- IGNORE THIS
	})

	--- @type thread | nil
	local visualThread = nil

	VisualsTab:Toggle({
		Name = "Murderer ESP",
		Default = false,
		Callback = function(state)
			if state then
				local murderer = nil
				repeat
					for i, v in ipairs(PlayerService:GetChildren()) do
						-- Check for Knife.
						if v.Backpack:FindFirstChild("Knife") then
							murderer = v.Character
							break
						elseif v.Character then
							-- Check v.Character:FindFirstChild("Knife")
							local knifeItem = v.Character:FindFirstChild("Knife")
							if not knifeItem then
							else
								murderer = v.Character
							end
						end
					end
					task.wait(1)
				until murderer

				local highlight = Instance.new("Highlight", murderer)
				highlight.Name = "ESP"
				highlight.Adornee = murderer
				highlight.FillColor = Color3.fromRGB(255,0,0)
				highlight.FillTransparency = 0.5
			else
				for _, plr in PlayerService:GetPlayers() do
					if plr.Character and plr.Character:FindFirstChild("ESP") then
						plr.Character.ESP:Destroy()
						break
					end
				end
			end
		end,
	})

	VisualsTab:Toggle({
		Name = "Sherif ESP",
		Default = false,
		Callback = function(state2)
			if state2 then
				local murderer = nil
				repeat
					for i, v in ipairs(PlayerService:GetChildren()) do
						-- Check for Knife.
						if v.Backpack:FindFirstChild("Gun") then
							murderer = v.Character
							break
						elseif v.Character then
							-- Check v.Character:FindFirstChild("Knife")
							local knifeItem = v.Character:FindFirstChild("Gun")
							if not knifeItem then
							else
								murderer = v.Character
							end
						end
					end
					task.wait(1)
				until murderer

				local highlight = Instance.new("Highlight", murderer)
				highlight.Name = "ESP"
				highlight.Adornee = murderer
				highlight.FillColor = Color3.fromRGB(0, 0, 255)
				highlight.FillTransparency = 0.5
			else
				for _, plr in PlayerService:GetPlayers() do
					if plr.Character and plr.Character:FindFirstChild("ESP") then
						plr.Character.ESP:Destroy()
						break
					end
				end
			end
		end,
	})

	VisualsTab:Slider({
		Name = "Knife Reach",
		Min = 1, -- Min Val
		Max = 100, -- Max Val
		Default = 5, -- Default Val
		Callback = function(val)
		local toolInBackpack = (PlayerService.LocalPlayer.Backpack and PlayerService.LocalPlayer.Backpack:FindFirstChild("Knife")) or nil
		local toolInCharacter = (not toolInBackpack and PlayerService.LocalPlayer.Character and PlayerService.LocalPlayer.Character:FindFirstChild("Knife")) or nil
			if toolInBackpack or toolInCharacter then
				(toolInBackpack or toolInCharacter).Handle.Size = Vector3.new(val,val,val)
			end
		end
	})
	


end

initialiseMain(Window)
initialiseVisuals(Window)
-- IMPLEMENT!
