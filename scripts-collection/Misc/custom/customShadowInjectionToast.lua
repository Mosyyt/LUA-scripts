--[[
	Roblox2Lua
	----------
	
	This code was generated using
	Deluct's Roblox2Lua plugin.
]]
--

local shadow_injection_notif = Instance.new("ScreenGui")
shadow_injection_notif.IgnoreGuiInset = false
shadow_injection_notif.ResetOnSpawn = true
shadow_injection_notif.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
shadow_injection_notif.Name = "ShadowInjectionNotif"
shadow_injection_notif.Parent = game:GetService("RunService").IsStudio() and game:GetService("StarterGui")
	or (gethui and gethui())
	or game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.BorderColor3 = Color3.new(0, 0, 0)
frame.BorderSizePixel = 0
frame.Position = UDim2.new(0.717999995, 550, 0.0930000022, 0)
frame.Size = UDim2.new(0, 504, 0, 119)
frame.Visible = true
frame.Parent = shadow_injection_notif

local shadow_logo = Instance.new("ImageLabel")
shadow_logo.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
shadow_logo.Active = true
shadow_logo.BackgroundColor3 = Color3.new(1, 1, 1)
shadow_logo.BorderColor3 = Color3.new(0, 0, 0)
shadow_logo.BorderSizePixel = 0
shadow_logo.Position = UDim2.new(0.0264284648, 0, 0.0736133978, 0)
shadow_logo.Size = UDim2.new(0, 101, 0, 100)
shadow_logo.Visible = true
shadow_logo.Name = "Shadow_Logo"
shadow_logo.Parent = frame

local accent = Instance.new("ImageLabel")
accent.BackgroundColor3 = Color3.new(0, 0.917647, 1)
accent.BorderColor3 = Color3.new(0, 0, 0)
accent.BorderSizePixel = 0
accent.Size = UDim2.new(0, 5, 0, 119)
accent.Visible = true
accent.Name = "Accent"
accent.Parent = frame

local content = Instance.new("TextBox")
content.CursorPosition = -1
content.Font = Enum.Font.SourceSans
content.PlaceholderColor3 = Color3.new(0, 0, 0)
content.Text = "Shadow has been loaded, you may now execute scripts!"
content.TextColor3 = Color3.new(1, 1, 1)
content.TextSize = 28
content.TextWrapped = true
content.TextXAlignment = Enum.TextXAlignment.Left
content.TextYAlignment = Enum.TextYAlignment.Top
content.BackgroundColor3 = Color3.new(1, 1, 1)
content.BackgroundTransparency = 1
content.BorderColor3 = Color3.new(0, 0, 0)
content.BorderSizePixel = 0
content.Position = UDim2.new(0.25999999, 0, 0.382999986, 0)
content.Size = UDim2.new(0, 330, 0, 61)
content.Visible = true
content.Name = "Content"
content.Parent = frame

local title = Instance.new("TextBox")
title.CursorPosition = -1
title.Font = Enum.Font.Unknown
title.Text = "Shadow has been Loaded!"
title.TextColor3 = Color3.new(0.415686, 0.572549, 1)
title.TextSize = 31
title.TextWrapped = true
title.BackgroundColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.BorderColor3 = Color3.new(0, 0, 0)
title.BorderSizePixel = 0
title.Position = UDim2.new(0.300000012, 0, 0.0933333337, 0)
title.Size = UDim2.new(0, 301, 0, 28)
title.Visible = true
title.ZIndex = 5
title.Name = "Title"
title.Parent = frame

local toast_hider = Instance.new("LocalScript")
toast_hider.Name = "ToastHider"
toast_hider.Parent = shadow_injection_notif

--// Scripts

-- ToastHider
task.spawn(function()
	local script = toast_hider

	local frame = script.Parent.Frame

	local TweenService = game:GetService("TweenService")

	local tweenData = TweenInfo.new(2.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

	local oldPos = frame.Position

	local newPos = UDim2.new(frame.Position.X.Scale, 1, frame.Position.Y.Scale, frame.Position.Y.Offset)

	local anim = TweenService:Create(frame, tweenData, {
		Position = newPos,
	})

	print("(Starter) Tween starting...")
	task.wait(1)

	anim:Play()
	anim.Completed:Wait()
	print("(Starter) Tween completed.")

	task.wait(4)

	local anim = TweenService:Create(frame, tweenData, {
		Position = oldPos,
	})

	print("(Hiding) Tween starting...")
	anim:Play()
	anim.Completed:Wait()
	print("(Hiding) Tween completed...")

	print("Animation Completed.")
end)
