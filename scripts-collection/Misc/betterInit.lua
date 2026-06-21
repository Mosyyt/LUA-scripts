--[[
    Lua Init.
    A Lua initialization script for Exploits.
    Implements common exploit functionality in pure luau and makes some behavior standard.
    Contains Roblox LSP-compatible documentation.

    This script is not final.
    It is suceptible to change.
    Nothing written here is set in stone.

    Originally written by @77seven. [Discord] (bullshitinnitfixed9000.lua)
    Modified by @usrdottik [Discord] (luainit.lua)

	- Contributors:
		- https://v3rmillion.net/member.php?action=profile&uid=491136 [Fixed bad newcclosure implementation]

    - Credits:
        https://github.com/plusgiant5/TaaprWareV2/blob/main/Release/bin/InitScript.lua
        https://v3rmillion.net/showthread.php?tid=1075607
        https://v3rmillion.net/showthread.php?tid=1213326
        https://v3rmillion.net/showthread.php?tid=1211933

    Simple disclaimer: Some of this code has been taken, sometimes,
    straight from the aformentioned places (You will notice because of the differences on the way the error messages are done!).
    I have touched some of the code and added comments. I'd categorize this more of a recompilation of a lot of things,
    mostly to cope with the current scene where every executor is missing a piece of everything
]]
local _ = ""

if not getgenv then
	local genv = {}
	--- Returns the Global environment of the executor as a table.
	--- @return table globalenv The table that represents the global executor environment.
	function getgenv()
		return genv
	end
end

if getgenv().forceEnable or not getgenv().isreadonly then
	--- Returns whether or not the given table is read only
	--- Remarks: This function will call table.isfrozen(t)!
	--- @param t table The table to check the information of.
	--- @return boolean isReadonly True if the table is readonly, false if it is not
	function isreadonly(t)
		return table.isfrozen(t)
	end
	getgenv().isreadonly = newcclosure(isreadonly)
end

if getgenv().forceEnable or not getgenv().hookmetamethod then
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

if not pcall(function()
	return game.HttpGet
end) then
	local _isA = game.IsA
	local function isA(self, className)
		return _isA(self, className)
	end
	local function wrappedReq(url)
		if not url then
			error("Expected Url as argument, got nil. Invalid parameter #1.")
		end
		if typeof(url) ~= "string" then
			error("Expected string as argument, got " .. typeof(url) .. ". Invalid parameter #1.")
		end
		return request({ Url = url, Method = "GET" })
	end
	local cWrappedReq = newcclosure(wrappedReq)
	local oldI
	oldI = hookmetamethod(
		game,
		"__index",
		newcclosure(function(...)
			local self = select(1, ...)
			local index = select(2, ...)
			if
				checkcaller()
				and typeof(self) == "Instance"
				and isA(self, "DataModel")
				and (index == "HttpGet" or index == "HttpGetAsync")
			then
				return cWrappedReq
			end
			return oldI(...)
		end)
	)

	local oldN
	oldN = hookmetamethod(
		game,
		"__namecall",
		newcclosure(function(...)
			local self = select(1, ...)
			local namecall = getnamecallmethod()
			if
				checkcaller()
				and rawequal(self, game)
				and (rawequal(namecall, "HttpGet") or rawequal(namecall, "HttpGetAsync"))
			then
				local args = { ... }
				if #args < 1 then
					error("Expected Url as argument, got nil. Invalid parameter #1.")
				end
				if typeof(args[1]) ~= "string" then
					error("Expected string as argument, got " .. typeof(args[1]) .. ". Invalid parameter #1.")
				end
				local url = args[1]
				return cWrappedReq(url)
			end
			return oldN(...)
		end)
	)

	print("Missing HttpGet on datamodel, added.")
end

if not getgenv().wait then
	getgenv().wait = task.wait
end
if not getgenv().spawn then
	getgenv().spawn = task.spawn
end

if getgenv().forceEnable or not getgenv().newcclosure then
	--- Wraps the given closure into a CClosure.
	--- @param f function The function to wrap onto a CClosure.
	--- @return function newCClosure The closure, but now identifying itself as a C closure.
	function newcclosure(f)
		if not iscclosure(f) then
			return coroutine.wrap(function(...)
				local args = { ... }
				while true do
					args = { coroutine.yield(f(unpack(args))) }
				end
			end)
		else
			return f
		end
	end
	getgenv().newcclosure = coroutine.wrap(function(f)
		while true do
			f = coroutine.yield(newcclosure(f))
		end
	end)
end

if getgenv().forceEnable or not getgenv().iscclosure then
	--- Get whether or not the given closure is a C closure.
	--- @param f function The function to check the type of.
	--- @return boolean isCClosure True if it is a C closure, false if it is not a C closure.
	function iscclosure(f)
		return debug.info(f, "s") == "[C]"
	end
	getgenv().iscclosure = newcclosure(iscclosure)
end

if getgenv().forceEnable or not getgenv().islclosure then
	--- Get whether or not the given closure is an L closure.
	--- @param f function The function to check the type of.
	--- @return boolean isLClosure True if it is an L closure, false if it is not an L closure.
	function islclosure(f)
		return not iscclosure(f)
	end
	getgenv().islclosure = newcclosure(islclosure)
end

if getgenv().forceEnable or not getgenv().newlclosure then
	--- Wraps the given closure into an LClosure.
	--- @param func function The function to wrap into an LClosure.
	--- @return function newLClosure the closure, but now identfies as a Lua Closure.
	function newlclosure(func)
		if not islclosure(func) then
			return function(...)
				func(...)
			end
		else
			return func
		end
	end
	getgenv().newlclosure = newcclosure(newlclosure)
end

if getgenv().forceEnable or not getgenv().cloneref then
	if (debug.getregistry or getreg) and rawget then
		local Part = Instance.new("Part")
		local lua_reg = debug.getregistry or getreg
		for _, regVal in next, lua_reg() do
			if type(regVal) == "table" and #regVal then
				if rawget(regVal, "__mode") == "kvs" then
					for _, tableVal in next, regVal do
						-- We found the table containing the references.
						if tableVal == Part then
							getgenv().InstanceList = regVal
							break
						end
					end
				end
			end
		end
		-- Destroy the part.
		Part:Destroy()

		--- Allows you to clone a reference, and modify it, without the game knowing about it.
		--- @param instance Instance The instance you wish to clone.
		--- @return Instance Instance A copy of the instance.
		function cloneref(instance)
			if not getgenv().InstanceList then
				error("No instance list found on the global executor environment, Initialization error!")
			end
			for b, c in next, getgenv().InstanceList do
				if c == instance then
					getgenv().InstanceList[b] = nil
					return instance
				end
			end
		end

		getgenv().cloneref = newcclosure(cloneref)
	elseif rconsoleprint then
		if not debug.getregistry and not getreg then
			rconsoleprint("[WARN] Lua Init: Cannot initialize cloneref! Missing debug.getregistry | getreg!")
		else
			rconsoleprint("[WARN] Lua Init: Cannot initialize cloneref! Missing rawget")
		end
	end
end

if getgenv().forceEnable or not getgenv().fireproximityprompt then
	--- Fires a proximity prompt.
	--- @param prompt ProximityPrompt The proximity prompt to fire.
	--- @param instantFire boolean Whether or not the prompt should be instantly fired.
	function fireproximityprompt(prompt, instantFire)
		if prompt.ClassName ~= "ProximityPrompt" then
			local name = prompt.ClassName
			if not name then
				name = "Unknown"
			end
			error(
				"The given element at positional argument #1 is not a 'ProximityPrompt', rather a '"
					.. name
					.. "'. Error at argument #1."
			)
		end
		local promptHoldDuration = prompt.HoldDuration
		if instantFire and promptHoldDuration > 0 then
			prompt.HoldDuration = 0
		end
		prompt:InputHoldBegin()
		if not instantFire then
			task.wait(prompt.HoldDuration)
		end
		prompt:InputHoldEnd()
		-- Revert if re-written.
		prompt.HoldDuration = promptHoldDuration
	end
	getgenv().fireproximityprompt = newcclosure(fireproximityprompt)
end

if getgenv().forceEnable or not getgenv().firesignal then
	--- Fire a signal. This function will send any of the parameters given to it (After 'signal') to the called Signals as arguments.
	--- @param signal RBXScriptConnection Fires the given signal.
	function firesignal(signal, ...)
		if typeof(signal) ~= "RBXScriptSignal" then
			error(
				"The given signal is not of the correct type! It identifies as type '"
					.. typeof(signal)
					.. "' but the function expects one of type RBXScriptSignal. Error at argument #1."
			)
		end
		for _, v in pairs(getconnections(signal)) do
			pcall(v.Function, ...)
		end
	end
	getgenv().firesignal = newcclosure(firesignal)
end

if getgenv().forceEnable or not getgenv().fireclickdetector then
	--- Fires a ClickDetector.
	--- @param clickDetector ClickDetector The click detector that the function will fire.
	--- @param useRightMouseButton boolean Whether or not the Right Mouse Button should be fired instead of the Left Mouse Click.
	function fireclickdetector(clickDetector, useRightMouseButton)
		if typeof(clickDetector) ~= "Instance" then
			error(
				"The given ClickDetector does not inherit from 'Instance' as expected, rather from '"
					.. typeof(clickDetector)
					.. "'. Error at argument #1."
			)
		elseif clickDetector.ClassName ~= "ClickDetector" then
			error(
				"The given ClickDetector does not have ClassName 'ClickDetector' as expected, rather has ClassName '"
					.. clickDetector.ClassName
					.. "'. Error at argument #1."
			)
		end

		-- Some games check first if the user hovered before allowing to fire.
		firesignal(clickDetector.MouseHoverEnter)
		if useRightMouseButton then
			firesignal(clickDetector.RightMouseClick)
		else
			firesignal(clickDetector.MouseClick)
		end
		firesignal(clickDetector.MouseHoverLeave)
	end
	getgenv().fireclickdetector = newcclosure(fireclickdetector)
end

if getgenv().forceEnable or not getgenv().isnetworkowner then
	local playerService = game:GetService("Players")
	--- Verifies if the LocalPlayer owns the given BasePart (Simulates its Physics).
	--- @param instance BasePart The part to check ownership of.
	--- @return boolean isNetworkOwner True if the LocalPlayer owns the given BasePart.
	function isnetworkowner(instance)
		if typeof(instance) ~= "Instance" then
			error("invalid argument #1 to 'isnetworkowner' (Instance expected)")
		end
		if instance:IsA("BasePart") then
			error("invalid argument #1 to 'isnetworkowner' (BasePart expected)")
		end

		local simulationRadius = playerService.LocalPlayer.SimulationRadius
		local char = playerService.LocalPlayer.Character or playerService.LocalPlayer.CharacterAdded:Wait()
		local humanoidRootPart = char:FindFirstChildOfClass("Humanoid").RootPart

		if humanoidRootPart then
			if instance.Anchored then
				return false
			end
			if
				instance:IsDescendantsOf(char)
				or (humanoidRootPart.Position - instance.Position).Magnitude <= simulationRadius
			then
				return true
			end
		end
		return false
	end
	getgenv().isnetworkowner = newcclosure(isnetworkowner)
end

if getgenv().forceEnable or not getgenv().getproperties then
	local configs = {
		AllowNotScriptableProperties = false,
		AllowHiddenProperties = true,
	}

	local dump = game:GetService("HttpService"):JSONDecode(
		game:HttpGetAsync(
			"https://setup.rbxcdn.com/"
				.. game:HttpGetAsync("https://setup.rbxcdn.com/versionQTStudio")
				.. "-API-Dump.json"
		)
	)
	local function SupportedClasses()
		local Instances = {}
		local Classes = {}

		local function getpropertiesfromdump(tabletocheck, inserttable)
			for i, member in tabletocheck do
				if member.MemberType == "Property" then
					--- @type table
					local Tags = member.Tags

					if Tags then
						-- Not Deprecated.
						if not table.find(Tags, "Deprecated") then
							-- Object isn't scriptable, but we were told to add the member anyways.
							if table.find(Tags, "NotScriptable") and configs.AllowNotScriptableProperties then
								table.insert(inserttable, member.Name)
								-- Object is hidden, but we were told to suck it, and add the member anyawys.
							elseif table.find(Tags, "Hidden") and configs.AllowHiddenProperties then
								table.insert(inserttable, member.Name)
							else
								-- Member isn't deprecated. Add it.
								table.insert(inserttable, member.Name)
							end
						end
					else
						-- There aren't any tags lmao.
						table.insert(inserttable, member.Name)
					end
				end
			end
		end

		for i, v in dump.Classes do
			if v.Superclass == "<<<ROOT>>>" then
				getpropertiesfromdump(v.Members, Instances)
			else
				Classes[v.Name] = (function()
					local Properties = {}
					getpropertiesfromdump(v.Members, Properties)
					return Properties
				end)()
			end
		end

		for i, ClassTable in Classes do
			for i, v in Instances do
				table.insert(ClassTable, v)
			end
		end

		return Classes
	end

	getgenv().getproperties = newcclosure(function(obj)
		if typeof(obj) == "Instance" then
			local Class = SupportedClasses[obj.ClassName]
			local Properties = {}

			for i, v in Class do
				Properties[v] = gethiddenproperty(obj, v)
			end

			return Properties
		else
			error("Expected 'Instance' for argument #1. Got " .. typeof(obj) .. " instead! Error at argument #1")
		end
	end)
end

if getgenv().forceEnable or not getgenv().getreg then
	if not debug.getregistry and rconsoleprint then
		rconsoleprint(
			"[WARN] Lua Init: No debug.getregistry and getreg available, some functions may not be possible to implement!"
		)
	else
		getgenv().getreg = debug.getregistry
	end
end

if getgenv().forceEnable or not getgenv().getsenv then
	if getgenv().getreg then
		--- Gets the environment of a script from the lua registry.
		--- @param mScript LocalScript The LocalScript to get the environment of.
		--- @return nil | table scriptEnvironment Returns the environment of the script as a function. May return nil if not found!
		function getsenv(mScript)
			if typeof(mScript) ~= "Instance" then
				error(
					"Expected argument #1 to be of type 'Instance', but it is of type '"
						.. typeof(mScript)
						.. "'. Invalid argument #1."
				)
			end
			if mScript.ClassName ~= "LocalScript" then
				error(
					"Expected argument #1 to be of Class 'LocalScript', but it is of Class '"
						.. mScript.ClassName
						.. "'. Invalid argument #1."
				)
			end

			local lua_reg = getgenv().getreg

			for _, regVal in next, lua_reg() do
				if typeof(regVal) == "function" and getfenv(regVal).script == mScript then
					return getfenv(regVal)
				end
			end
			return nil
		end
		getgenv().getsenv = newcclosure(getsenv)
	else
		if not debug.getregistry and not getreg and rconsoleprint then
			rconsoleprint("[WARN] Lua Init: Cannot implement getsenv! Missing debug.getregistry | getreg")
		end
	end
end

if getgenv().forceEnable or not getgenv().getmenv then
	if getgenv().getreg then
		--- Gets the environment of a module script from the lua registry.
		--- @param mScript ModuleScript The ModuleScript to get the environment of.
		--- @return nil | table scriptEnvironment Returns the environment of the script as a function. May return nil if not found!
		function getmenv(mScript)
			if typeof(mScript) ~= "Instance" then
				error(
					"Expected argument #1 to be of type 'Instance', but it is of type '"
						.. typeof(mScript)
						.. "'. Invalid argument #1."
				)
			end
			if mScript.ClassName ~= "ModuleScript" then
				error(
					"Expected argument #1 to be of Class 'ModuleScript', but it is of Class '"
						.. mScript.ClassName
						.. "'. Invalid argument #1."
				)
			end

			local lua_reg = getgenv().getreg

			for _, regVal in next, lua_reg() do
				if typeof(regVal) == "function" and getfenv(regVal).script == mScript then
					return getfenv(regVal)
				end
			end
			return nil
		end
		getgenv().getmenv = newcclosure(getmenv)
	else
		if not debug.getregistry and not getreg and rconsoleprint then
			rconsoleprint("[WARN] Lua Init: Cannot implement getmenv! Missing debug.getregistry | getreg")
		end
	end
end

if getgenv().forceEnable or not getgenv().getnilinstances then
	if getgenv().getreg then
		local lua_reg = getgenv().getreg
		--- Get all the instances that are parented to nil and that have a reference.
		--- @return table nilInstnces A table containing all the instances in the game that are currently parented to nil.
		function getnilinstances()
			local nilTable = {}
			for _, regVal in next, lua_reg() do
				if typeof(regVal) == "table" then
					for _, tableItem in next, regVal do
						if typeof(tableItem) == "Instance" and tableItem.Parent == nil then
							table.insert(nilTable, tableItem)
						end
					end
				end
			end
			return nilTable
		end
		getgenv().getnilinstances = newcclosure(getnilinstances)
	else
		if not debug.getregistry and not getreg and rconsoleprint then
			rconsoleprint("[WARN] Lua Init: Cannot implement getnilinstances! Missing debug.getregistry | getreg")
		end
	end
end

if getgenv().forceEnable or not getgenv().getinstances then
	if getgenv().getreg then
		local lua_reg = getgenv().getreg
		--- Get all the instances that have a reference.
		--- @return table nilInstnces A table containing all the instances in the game.
		function getinstances()
			local instanceTable = {}
			for _, regVal in next, lua_reg() do
				if typeof(regVal) == "table" then
					for _, tableItem in next, regVal do
						if typeof(tableItem) == "Instance" then
							table.insert(instanceTable, tableItem)
						end
					end
				end
			end
			return instanceTable
		end
		getgenv().getinstances = newcclosure(getinstances)
	else
		if not debug.getregistry and not getreg and rconsoleprint then
			rconsoleprint("[WARN] Lua Init: Cannot implement getinstances! Missing debug.getregistry | getreg")
		end
	end
end

if getgenv().forceEnable or not getgenv().getthreads then
	if getgenv().getreg then
		local lua_reg = getgenv().getreg
		--- Gets all the threads available in the game
		--- @return table nilInstnces A table containing all the threads that the game has a reference to..
		function getthreads()
			local threadTable = {}
			for _, regVal in next, lua_reg() do
				if typeof(regVal) == "thread" then
					table.insert(threadTable, regVal)
				end
			end
			return threadTable
		end
		getgenv().getthreads = newcclosure(getthreads)
	else
		if not debug.getregistry and not getreg and rconsoleprint then
			rconsoleprint("[WARN] Lua Init: Cannot implement getthreads! Missing debug.getregistry | getreg")
		end
	end
end

if getgenv().forceEnable or not getgenv().getscripts then
	local lua_reg = debug.getregistry or getreg
	if lua_reg then
		if not getgenv().InstanceList then -- Initialize InstanceList if not initialized already.
			local Part = Instance.new("Part")
			for _, regVal in next, lua_reg() do
				if type(regVal) == "table" and #regVal then
					if rawget(regVal, "__mode") == "kvs" then
						for _, tableVal in next, regVal do
							-- We found the table containing the references.
							if tableVal == Part then
								getgenv().InstanceList = regVal
								break
							end
						end
					end
				end
			end
			-- Destroy the part.
			Part:Destroy()
		end

		--- Gets all the scripts available in the game.
		--- @param includeCoreScripts boolean Whether or not the function should also include CoreScript(s) into the search.
		--- @return table gameScripts All the LocalScript(s), ModuleScript(s) and (optionally) CoreScript(s) instanciated in the game
		function getscripts(includeCoreScripts)
			local t = {}
			--- @type Instance
			for _, instance in ipairs(getgenv().InstanceList) do
				if
					instance:IsA("LocalScript")
					or instance:IsA("ModuleScript")
					or (includeCoreScripts and instance:IsA("CoreScript"))
				then
					table.insert(t, instance)
				end
			end
			return t
		end

		getgenv().getscripts = newcclosure(getscripts)
	else
		rconsoleprint("[WARN] Lua Init: Cannot initialize getscripts! Missing debug.getregistry | getreg!")
	end
end

if getgenv().forceEnable or not getgenv().getmodules then
	local lua_reg = debug.getregistry or getreg
	if lua_reg then
		if not getgenv().InstanceList then -- Initialize InstanceList if not initialized already.
			local Part = Instance.new("Part")
			for _, regVal in next, lua_reg() do
				if type(regVal) == "table" and #regVal then
					if rawget(regVal, "__mode") == "kvs" then
						for _, tableVal in next, regVal do
							-- We found the table containing the references.
							if tableVal == Part then
								getgenv().InstanceList = regVal
								break
							end
						end
					end
				end
			end
			-- Destroy the part.
			Part:Destroy()
		end

		--- Gets all the ModuleScripts on the game.
		--- @return table gameScripts All the ModuleScript(s) instanciated in the game
		function getmodules()
			local t = {}
			--- @type Instance
			for _, instance in ipairs(getgenv().InstanceList) do
				if instance:IsA("ModuleScript") then
					table.insert(t, instance)
				end
			end
			return t
		end

		getgenv().getmodules = newcclosure(getmodules)
	else
		rconsoleprint("[WARN] Lua Init: Cannot initialize getmodules! Missing debug.getregistry | getreg!")
	end
end

if getgenv().forceEnable or not getgenv().gethui then
	if sethiddenproperty then
		--- @type Instance
		local coreGuiRef = game:GetService("CoreGui")
		--- @type table | nil
		local childAddedConnections = nil
		--- @type table | nil
		local descendantAddedConnections = nil

		if getconnections then
			descendantAddedConnections = getconnections(coreGuiRef.DescendantAdded)
			childAddedConnections = getconnections(coreGuiRef.ChildAdded)
			-- Prevent game from reading the ChildAdded event in CoreGui until we are finished creating the child.
			for _, cnn in next, childAddedConnections do
				cnn:Disable() -- Disable connections...
			end

			-- Prevent game from reading the DescendantAdded event in CoreGui, to avoid them finding the gethui() folder via it.
			for _, cnn in next, descendantAddedConnections do
				cnn:Disable() -- Disable connections...
			end
		end

		local function randomString(stringLength)
			local array = table.create(stringLength, "TOTALLY_NOT_GETHUI_STUB!!!")
			for i = 1, stringLength do
				array[i] = string.char(math.random(0, 256))
			end
			return table.concat(array)
		end

		local folder = Instance.new("Folder", coreGuiRef)
		folder.Name = "totallynotabadgethuiimplementationguys" .. randomString(69)
		--- Avoid indexing... | PoV: Yeah this is more of a meme, it doesn't wanna work on my Fluxus install (lol)
		sethiddenproperty(folder, "RobloxLocked", true)
		if getconnections then
			-- Restore Events.
			for _, cnn in next, childAddedConnections do
				cnn:Enable() -- Enable connections...
			end
		end

		-- #region Hooks

		local huiParent = folder.Parent
		local huiName = folder.Name

		local findFirstChild = game.FindFirstChild
		local getDescendants = game.GetDescendants
		local isDescendantOf = game.IsDescendantOf
		local isAncestorOf = game.IsAncestorOf
		--- This hook watches for FindFirstChild-style attacks and more, and tries to deal with them!
		local oldNamecallFindFirstChild
		oldNamecallFindFirstChild = hookmetamethod(
			game,
			"__namecall",
			newcclosure(function(...)
				local self = select(1, ...)
				if self and not checkcaller() then
					local namecall = getnamecallmethod()
					if namecall == "FindFirstChild" then
						local args = { ... }
						local beRecursive = false
						local targetObject = nil

						if #args == 2 then
							targetObject = args[1]
							beRecursive = args[2]
						elseif #args == 1 then
							targetObject = args[1]
							beRecursive = false
						else
							-- Instantly return.
							return oldNamecallFindFirstChild(...)
						end
						if targetObject == huiName then
							return nil -- This is probably gethui()
						end

						if self == huiParent or beRecursive then
							-- This may be an attack vector, modify path!
							local found = findFirstChild(targetObject, beRecursive)

							if found == folder then -- Hide the gethui() folder.
								return nil
							else
								return found -- This is not parented to our gethui
							end
						else
							return oldNamecallFindFirstChild(...)
						end
					end

					if namecall == "WaitForChild" then
						local args = { ... }
						local targetObjectName = nil

						if #args > 0 then
							targetObjectName = args[1]
						else
							-- Instantly return, not what we expected.
							return oldNamecallFindFirstChild(...)
						end
						if targetObjectName == huiName then
							return nil -- This is probably gethui()
						end
						return oldNamecallFindFirstChild(...)
					end

					if namecall == "GetDescendants" then
						local args = { ... }

						if #args ~= 0 then
							-- Invalid parameters, GetDecendants only accepts self.
							return oldNamecallFindFirstChild(...)
						end

						-- Self is gethui or a descendant of it.
						if self == cloneref(folder) or isDescendantOf(self, cloneref(folder)) then
							return {}
						end

						return oldNamecallFindFirstChild(...)
					end
					if namecall == "GetChildren" then
						if self == cloneref(folder) or isDescendantOf(self, cloneref(folder)) then
							return nil
						else
							return oldNamecallFindFirstChild(...)
						end
					end
				end
				return oldNamecallFindFirstChild(...)
			end)
		)

		-- #endregion Hooks

		--- Returns an 'hidden' folder in CoreGui.
		--- @return Folder hiddenFolder Returns n 'hidden' folder inside CoreGui.
		function gethui()
			return folder
		end

		getgenv().gethui = newcclosure(gethui)
	else
		if not sethiddenproperty and rconsoleprint then
			rconsoleprint("[WARN] Lua Init: Cannot implement gethui! Missing sethiddenproperty")
		end
	end
end

if getgenv().forceEnable or not getgenv().request then
	--- Defines an HttpResponse class.
	--- @class HttpResponse
	local HttpResponse = {
		--- The body of the response.
		Body = "",
		--- The status code sent by the server
		StatusCode = 200,
		--- The status message sent by the server.
		StatusMessage = "OK",
		--- The headers sent by the server as a response.
		Headers = {},
	}
	--- Makes an HTTP request.
	--- @param httpRequestTable HttpRequest Table containing all the parameters used when doing the Http request.
	--- @return HttpResponse response The http response sent by the server.
	function request(httpRequestTable)
		if typeof(httpRequestTable) ~= "table" then
			error(
				"Invalid argument given to request. Expected table, got '"
					.. typeof(httpRequestTable)
					.. "' instead. Invalid argument #1."
			)
		end

		local httpService = game:GetService("HttpService")
		local event = Instance.new("BindableEvent")
		local rbxRequest = httpService.RequestInternal

		--- @type HttpResponse
		local response
		task.spawn(function()
			response = rbxRequest(httpService, httpRequestTable)
			event.Event:Fire()
		end)

		event.Event:Wait()
		return response
	end
	getgenv().request = newcclosure(request)
end

if getgenv().forceEnable or not getgenv().getthread then
	getgenv().getthread = coroutine.running
end

-- Get script bytecode MUST be implemented to get a disassembler or decompiler.
if getgenv().forceEnable or getgenv().getscriptbytecode then
	if not getgenv().disassemble then
		local cachedDisasm = newcclosure(
			loadstring(game:HttpGet("https://raw.githubusercontent.com/TheSeaweedMonster/Celery/main/decompile.lua"))()
		)
		--- The Celery Disassmebler.
		--- @param dScript LocalScript | ModuleScript The script to disassemble
		--- @param showOpCodes boolean Whether or not the disassembler should print out the OPCodes
		function __true__disassembler__(dScript, showOpCodes)
			return cachedDisasm(dScript, showOpCodes)
		end

		--- Calls a LuaU disassembler (Has arg guard).
		--- @param dScript Instance The script to disassemble.
		function __guarded__disassembler__(dScript)
			if typeof(dScript) ~= "Instance" then
				error(
					"Disassemble only accepts Instances, but you provided a "
						.. typeof(dScript)
						.. " instead! Invalid argument #1."
				)
			end
			if dScript.ClassName ~= "ModuleScript" and dScript.ClassName ~= "LocalScript" then
				error(
					"Disassemble can only accept LocalScript(s) and ModuleScript(s), but you provided a "
						.. dScript.ClassName
						.. " instead! Invalid argument #1."
				)
			end

			if #getscriptbytecode(dScript) == 0 then
				error("Disassembly cannot continue. Failed to get script bytecode!")
			end

			return __true__disassembler__(dScript, true)
		end
		getgenv().disassemble = newcclosure(__guarded__disassembler__)
	end

	if not getgenv().decompile then
		-- Simple, yet, free decompiler.
		getgenv().decompile = getgenv().disassemble
	end
elseif rconsoleprint then
	rconsoleprint("[WARN] Lua Init: Cannot possibly implenent disassemble & decompile! Missing getscriptbytecode")
end

if getgenv().forceEnable or not getgenv().checkcaller then
	-- This is the cheapest implementation possible, your executor should have this by default.
	local _ = ""
	--- This function checks if the thread identity of the running thread is that of what is expected (>5) for exploit execution.
	--- Remarks: This is just checking thread identity, your Executor is probably a better option.
	--- @return boolean isExecutorThread Returns whether or not the thread running this code is an executor thread.
	function checkcaller()
		-- Exploits normally run at 7, but just for extended compatibility, lets use this.
		return getthreadidentity() >= 5
	end
	getgenv().checkcaller = newcclosure(checkcaller)
end

if getgenv().forceEnable or not getgenv().GetObjects then
	local insetService = game:GetService("InsertService")

	--- Returns loaded objects from a URL
	--- @return Instance object The object that was loaded from the provided URL.
	function GetObjects(url)
		if not typeof(url) == "string" then
			error("Expected a string. Got " .. typeof(url) .. " instead. Invalid argument #1")
		end
		if not url:match("://") then
			error("Expected a URL, the provided string does not match the pattern. Invalid argument #1.")
		end
		return insetService:LoadLocalAsset(url)
	end

	getgenv().GetObjects = newcclosure(GetObjects)
end

-- DEV NOTE: This saveinstance causes Dex to explode, don't use it.
if false then
	if getgenv().forceEnable and not getgenv().saveinstance then
		--- @type function
		local saveInstance = loadstring(game:HttpGet("https://pastebin.com/raw/ha0PZgNz"))()
		getgenv().saveinstance = newcclosure(saveInstance)
	end
end

if getgenv().forceEnable or not getgenv().isrbxactive then
	local IS_ROBLOX_ACTIVE = true
	local UserInputService = game:GetService("UserInputService")

	UserInputService.WindowFocused:Connect(function()
		IS_ROBLOX_ACTIVE = true
	end)

	UserInputService.WindowFocusReleased:Connect(function()
		IS_ROBLOX_ACTIVE = false
	end)

	--- Returns whether or not Roblox is the currently focused window.
	--- @return boolean isRbxActive If true, Roblox's is window is in focus, false if it is not.
	function isrbxactive()
		return IS_ROBLOX_ACTIVE
	end

	getgenv().isrbxactive = newcclosure(isrbxactive)
end

if getgenv().forceEnable or not getgenv().clonefunction then
	--- Clones the given function, and returns a function of the same type.
	--- @param f function The function to clone.
	--- @return function function The cloned function.
	function clonefunction(f)
		if typeof(f) ~= "function" then
			error("Expected 'function' for argument #1, got " .. typeof(f) .. " instead! Invalid argument #1.")
		end
		if iscclosure(f) then
			return newlclosure(f)
		else
			return newcclosure(f)
		end
	end

	getgenv().clonefunction = newcclosure(clonefunction)
end

if getgenv().forceEnable or not getgenv().getthreadidentity then
	--- Gets the thread identity of the caller.
	--- Remarks: This attempts to access normally restricted APIs that you may access on high identities, if we fail, we will get our thread identity in the error message :)
	--- @return number threadIdentity The thread identity of the caller as a number.
	function getthreadidentity()
		local success, error = xpcall(game.GetPropertyChangedSignal, function(p1, p2)
			return p1, p2
		end, game:GetService("StudioData"), "SrcUniverseId")
		if success then
			return 7
		else
			-- This means we were not max privilages, yet, our error message contains our identity level, scrape it.
			local secondHalf = string.split(error, "identity (")[2]
			-- The next char has our thread identity.
			return tonumber(string.gsub(secondHalf, 1, 1))
		end
	end
end

if getgenv().forceEnable or not getgenv().getpropvalue then
	--- Gets a property from an instance, it will not error with hidden properties.
	--- @param instance Instance The instance to modify the property of.
	--- @param propName string The name of the property
	--- @return boolean success Whether or not the operation was successful.
	function getpropvalue(instance, propName)
		if typeof(instance) ~= "Instance" then
			error(
				"Invalid argument #1. The given instance is not of type Instance, rather of type "
					.. typeof(instance)
					.. "!"
			)
		end
		if typeof(propName) ~= "string" then
			error(
				"Invalid argument #2. The property name is expected to be of type string, not of type "
					.. typeof(propName)
					.. "!"
			)
		end
		local success, result = xpcall(game.GetPropertyChangedSignal, function(inst, propN)
			return inst, propN
		end, instance, propName)

		if not success then
			if result:match("not a valid") then
				error("Invalid argument #2. The given property is not a valid one!")
			end
		end
		success, result = pcall(function()
			return instance[propName]
		end)

		return result
	end
	getgenv().getpropvalue = newcclosure(getpropvalue)
end

if getgenv().forceEnable or not getgenv().setpropvalue then
	--- Sets a property in an instance, it will not error with hidden properties.
	--- @param instance Instance The instance to modify the property of.
	--- @param propName string The name of the property
	--- @param propValue any The value of the property.
	--- @return boolean success Whether or not the operation was successful.
	function setpropvalue(instance, propName, propValue)
		if typeof(instance) ~= "Instance" then
			error(
				"Invalid argument #1. The given instance is not of type Instance, rather of type "
					.. typeof(instance)
					.. "!"
			)
		end
		if typeof(propName) ~= "string" then
			error(
				"Invalid argument #2. The property name is expected to be of type string, not of type "
					.. typeof(propName)
					.. "!"
			)
		end
		if typeof(propValue) == "nil" then
			error("Invalid argument #3. The given value is not a valid one, it is nil.")
		end
		local success, err = xpcall(game.GetPropertyChangedSignal, function(inst, propN)
			return inst, propN
		end, instance, propName)

		if not success then
			if err:match("not a valid") then
				error("Invalid argument #2. The given property is not a valid one!")
			end
		end
		success, err = pcall(function()
			instance[propName] = propValue
		end)

		return success
	end
	getgenv().setpropvalue = newcclosure(setpropvalue)
end

if getgenv().forceEnable or not getgenv().setsimulationradius then
	local PlayerService = game:GetService("Players")
	--- Sets a the game's simulation radius
	--- @param newRadius number The simulation radius.
	--- @param newMaxRadius number The new maxiumum simulation radius.
	function setsimulationradius(newRadius, newMaxRadius)
		if typeof(newRadius) ~= "number" then
			error(
				"Invalid argument #1. The given new simulation radius is not a number, rather a "
					.. typeof(newRadius)
					.. "!"
			)
		end

		if typeof(newMaxRadius) ~= "number" then
			error(
				"Invalid argument #2. The given new maximum simulation radius is not a number, rather a "
					.. typeof(newMaxRadius)
					.. "!"
			)
		end

		if not setpropvalue(PlayerService.LocalPlayer, "SimulationRadius", newRadius) then
			error("Failed to set new simulation radius!")
		end
		if not setpropvalue(PlayerService.LocalPlayer, "MaxSimulationRadius", newMaxRadius) then
			error("Failed to set new maximum simulation radius!")
		end
	end

	getgenv().setsimulationradius = newcclosure(setsimulationradius)
end

if getgenv().forceEnable or not getgenv().getexecutioncontext then
	local RunService = game:GetService("RunService")
	--- @class ExecutionContext
	local DECLARATION = {
		--- The script is being executed on Roblox Studio.
		Studio = "Studio",
		--- The script is being executed on a Roblox Server.
		Server = "Server",
		--- The script is being executed on the Roblox Client.
		Client = "Client",
		--- The script is being executed on an unknown Context.
		Unknown = "???",
	}

	--- Gets the current Execution Context
	--- @return ExecutionContext execContext The current execution context.
	function getexecutioncontext()
		if RunService:IsStudio() then
			return DECLARATION.Studio
		elseif RunService:IsClient() then
			return DECLARATION.Client
		elseif RunService:IsServer() then
			return DECLARATION.Server
		else
			return DECLARATION.Unknown
		end
	end

	getgenv().getexecutioncontext = newcclosure(getexecutioncontext)
end

if getgenv().forceEnable or not getgenv().getfflag then
	local sObj = settings()
	--- Gets a Fast Flag from the Roblox environment.
	--- @param fflagName string THe name of the fast flag to get the value of.
	--- @return boolean flagValue The value of the fast flag queried.
	function getfflag(fflagName)
		return sObj:GetFFlag(fflagName)
	end

	getgenv().getfflag = newcclosure(getfflag)
end

if getgenv().forceEnable or not getgenv().bit then
	--- The standard executor bit library. Used to perform bit operations, uses Roblox's standard bit32 library in the back-end.
	local bit = {
		rrotate = bit32.rrotate,
		lrotate = bit32.lrotate,
		bor = bit32.bor,
		bxor = bit32.bxor,
		band = bit32.band,
		bnot = bit32.bnot,
		btest = bit32.btest,
		rshift = bit32.rshift,
		lshift = bit32.lshift,
		arshift = bit32.arshift,
	}

	--- Performs an addition on the given values. Allows for overflows.
	--- @param num_first number The first operand of the addition.
	--- @param num_second number The second operand of the addition.
	--- @return number result The result of the matemathical operation.
	bit.badd = newcclosure(function(num_first, num_second)
		return num_first + num_second
	end)

	--- Performs a substraction on the given values. Allows for overflows.
	--- @param num_first number The first operand of the substraction.
	--- @param num_second number The second operand of the substraction.
	--- @return number result The result of the matemathical operation.
	bit.bsub = newcclosure(function(num_first, num_second)
		return num_first - num_second
	end)

	--- Performs a division on the given values. Allows for overflows.
	--- @param num_first number The first operand of the division.
	--- @param num_second number The second operand of the division.
	--- @return number result The result of the matemathical operation.
	bit.bdiv = newcclosure(function(num_first, num_second)
		return num_first / num_second
	end)

	--- Performs a multiplication on the given values. Allows for overflows.
	--- @param num_first number The first operand of the multiplication.
	--- @param num_second number The second operand of the multiplication.
	--- @return number result The result of the matemathical operation.
	bit.bmul = newcclosure(function(num_first, num_second)
		return num_first * num_second
	end)

	--- Converts the given number into one that can be used
	--- @param num number The number to convert to be used in bit operations.
	--- @return number bitNum A number in which you may perform bit-wise operations on.
	bit.tobit = newcclosure(function(num)
		num = num % (bit32.bxor(num, 32))
		if num > 0x80000000 then -- 0x80000000 -> Max Int32 value.
			num = num - bit32.bxor(num, 32)
		end
		return num
	end)

	--- Performs a bit-wise swap on the given number.
	--- @param num number THe number to bit-wise swap.
	--- @return number bitwisedNumber The number, bit-wise'd.
	bit.bswap = newcclosure(function(num)
		local BYTE_SIZE = 8
		local MAX_BYTE_VALUE = 255

		num = num % bit.bxor(2, 32)

		local a = bit.band(num, MAX_BYTE_VALUE)
		num = bit.rshift(num, BYTE_SIZE)

		local b = bit.band(num, MAX_BYTE_VALUE)
		num = bit.rshift(num, BYTE_SIZE)

		local c = bit.band(num, MAX_BYTE_VALUE)
		num = bit.rshift(num, BYTE_SIZE)

		local d = bit.band(num, MAX_BYTE_VALUE)
		num = bit.tobit(bit.lshift(bit.lshift(bit.lshift(a, BYTE_SIZE) + b, BYTE_SIZE) + c, BYTE_SIZE) + d)
		return num
	end)

	--- Converts the given value into a Hexadecimal format.
	--- @param num number The number to convert into hexadecimal format.
	--- @param hex number The number of hex digits that should be returned. Defaults to 8 if un-set.
	--- @return string hexString The number in hexadecimal format.
	bit.tohex = newcclosure(function(num, hex)
		if not hex then
			hex = 8 -- Default hex.
		end
		local up

		if hex <= 0 then
			if hex == 0 then
				return ""
			end
			up = true
			hex = -hex
		end

		num = num % (2 ^ 32)
		num = bit.band(num, 16 ^ hex - 1)
		return ("%0" .. hex .. (up and "X" or "a")):format(num)
	end)

	--- Rotates a number to the right the given amount of times.
	--- @param number number The number to rotate.
	--- @param rotateBy number The amount of times it should be rotated by.
	bit.ror = newcclosure(function(number, rotateBy)
		return bit.tobit(bit.rrotate(bit.bxor(number % 2, 32), rotateBy % 32))
	end)

	--- Rotates a number to the left the given amount of times.
	--- @param number number The number to rotate.
	--- @param rotateBy number The amount of times it should be rotated by.
	bit.rol = newcclosure(function(number, rotateBy)
		return bit.tobit(bit.lrotate(bit.bxor(number % 2, 32), rotateBy % 32))
	end)

	getgenv().bit = table.freeze(bit)
end

if getgenv().forceEnable or not getgenv().isactor then
	--- Gets whether or not the given Instance has an actor.
	--- @param instance Instance The Instance to check if it is an actor.
	--- @return boolean hasActor True if the given Instance has an Actor attached to it, false if it does not.
	function isactor(instance)
		--- The instance has an actor if GetActor() returns something that is not nil.
		return instance:GetActor() ~= nil
	end
	getgenv().isactor = newcclosure(isactor)
end
