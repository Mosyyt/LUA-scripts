-- #region Anti Tampering prelude
--- Gets the executor's Request function.
--- @return function Returns a client able to issue HttpRequest, which takes in an HttpRequest table as a parameter; UNC Spec -> https://github.com/unified-naming-convention/NamingStandard/blob/main/api/misc.md#request
function GetRequestFunction()
	return request or (syn and syn.request) or (http and http.request) or http_request
end

function IsScriptObfuscated()
	return (LPH_OBFUSCATED or _77Crash)
end

function CrashObfuscatorVM()
	if LPH_OBFUSCATED then
		LPH_CRASH()
	end
	if _77Crash then
		_77Crash()
	end
end

if rconsoleprint then
	hookfunction(
		rconsoleprint,
		newcclosure(function(...)
			return nil
		end)
	)
end
if consoleprint then
	hookfunction(
		consoleprint,
		newcclosure(function(...)
			return nil
		end)
	)
end

local functions = {
	rconsoleprint,
	print,
	setclipboard,
	rconsoleerr,
	rconsolewarn,
	warn,
	error,
}

for _, v in next, functions do
	local old
	old = hookfunction(
		v,
		newcclosure(function(...)
			local args = { ... }
			for i, v in next, args do
				if tostring(i):find("http") or tostring(v):find("http") then
					if IsScriptObfuscated() then
						CrashObfuscatorVM()
					end
					while true do
					end
				end
			end
			return old(...)
		end)
	)
end

if _G.ID then
	if IsScriptObfuscated() then
		CrashObfuscatorVM()
	end
	while true do
	end
end
setmetatable(_G, {
	__newindex = function(...)
		if select(2, ...) == "ID" then
			if IsScriptObfuscated() then
				CrashObfuscatorVM()
			end
			while true do
			end
		end
	end,
})

if islclosure(GetRequestFunction()) then
	if IsScriptObfuscated() then
		CrashObfuscatorVM()
	end
	while true do
	end
end

-- #endregion Anti Tamperimg prelude
