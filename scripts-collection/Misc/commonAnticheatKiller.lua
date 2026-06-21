local function newcclosure_c(...)
	local execName = identifyexecutor():lower()
	if not execName:match("nihon") and not execName:match("shadow") then
		print(
			"Your xploit is trash m8. It won't do cclosure correctly, so cope with lclosure and detection vectors :fire:"
		)
		return ...
	end

	if execName:match("shadow") or execName:match("sirhurt") then
		if spoofclosure then
			print("Sweet, found spoof")
			return spoofclosure
		end
	end

	return newcclosure(...)
end

for _, fun in next, getgc() do
	if typeof(fun) == "function" and islclosure(fun) and not isexecutorclosure(fun) then
		local upvals = debug.getupvalues(fun)
		local consts = debug.getconstants(fun)
		local oldId = getthreadidentity()

		if
			(
				table.find(upvals, "c")
				and table.find(upvals, "r")
				and table.find(upvals, "a")
				and table.find(upvals, "s")
				and table.find(upvals, "h")
			)
			or (
				table.find(consts, "c")
				and table.find(consts, "r")
				and table.find(consts, "a")
				and table.find(consts, "s")
				and table.find(consts, "h")
			)
		then
			setthreadidentity(2)
			hookfunction(
				fun,
				newcclosure_c(function(...)
					return task.wait(9e9)
				end)
			)
			setthreadidentity(oldId)
			print("Found Adonis crash function! [Forked Adonis]")
		end

		if table.find(consts, "Detected") and table.find(consts, "crash") then
			setthreadidentity(2)
			hookfunction(
				fun,
				newcclosure_c(function(...)
					return task.wait(9e9)
				end)
			)
			setthreadidentity(oldId)
			print("Found main crash function!")
		end

		for _, const in pairs(consts) do
			if type(const) == "string" and const:lower():match("disallowed service") then
				print("Found -> AntiAFK fix hook. | Match ---> " .. const)
				hookfunction(
					fun,
					newcclosure_c(function(...)
						return
					end)
				)
			end

			if type(const) == "string" and const:lower():match(":: adonis anti cheat::") then
				print("Found -> ADONIS ANTI CHEAT! | Match ---> " .. const)
				hookfunction(
					fun,
					newcclosure_c(function(...)
						print("Adonis anticheat murderer 69420 edition")
						return task.wait(9e9)
					end)
				)
			end

			if type(const) == "string" and const:lower():match("exploit detected") then
				print("Found -> Exploit detector | Match ---> " .. const)
				hookfunction(
					fun,
					newcclosure_c(function(...)
						print("Intercepted exploit detection")
						return false
					end)
				)
			end

			if type(const) == "string" and const:lower():match("method 0x") and const:lower():match("anti") then
				print("Found function matching constant... -> anti* + Method 0x*  | Match ---> " .. const)
				hookfunction(
					fun,
					newcclosure_c(function(...)
						print("Intercepted Method 0x* wildcard.")
						return false
					end)
				)
			end
		end
		setthreadidentity(oldId)
	end
end

local dbgInfoHook
-- debug.info hook.
dbgInfoHook = hookfunction(
	getrenv().debug.info,
	newcclosure_c(function(...)
		if checkcaller() then
			return dbgInfoHook(...)
		else
			return nil
		end
	end)
)
