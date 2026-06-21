--! Code extracted from codexus's misc project -> betterinit.lua
if not cloneref then
	if (debug and debug.getregistry) or getreg then
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
	else
		getgenv().cloneref = newcclosure(function(...)
			return ...
		end)
	end
end

local Helpers = {}

--- Generates a Random string. Not cryptographically secure.
--- @param length number The length of the string.
--- @return string rngString The randomly generated string.
function Helpers.RandomStringGenerator(length)
	if not length then
		length = math.random(0, 20)
	end
	local sets = { { 97, 122 }, { 65, 90 }, { 48, 57 } } -- a-z, A-Z, 0-9
	local str = ""

	for _ = 1, length do
		math.randomseed(os.clock() / length ^ 5)
		local charset = sets[math.random(1, #sets)]
		str = str .. string.char(math.random(charset[1], charset[2]))
	end

	return str
end

--- Protects a GUI from getting detected. Milage may vary due to executor's implementation.
--- Remarks: The ScreenGui will be parented after this call. Do not modify the Parent!
--- @param screenGui ScreenGui The screen GUI that should be protected.
function Helpers.ProtectGui(screenGui)
	if gethui then
		-- Get Hidden UI is here.
		screenGui.Parent = gethui()
	elseif syn and syn.protect_gui then
		-- Synapse :heart:
		syn.protect_gui(screenGui)
		screenGui.Parent = cloneref(game:GetService("CoreGui"))
	else
		-- We have no safer bet being honest.
		screenGui.Parent = cloneref(game:GetService("CoreGui"))
	end
end

return Helpers
