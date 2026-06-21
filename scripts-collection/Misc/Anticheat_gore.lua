local function newcclosure_c(...)
    print(
        "hookfunction sucks, I have given up on securing this trash, detect it game devs :kms:")
    return ...
end

for _, fun in next, getgc() do
    if typeof(fun) == "function" and islclosure(fun) and
        not isexecutorclosure(fun) then
        local consts = debug.getconstants(fun)

        if table.find(consts, "Detected") and table.find(consts, "crash") then
            local oldId = getthreadidentity()
            setthreadidentity(2)
            hookfunction(fun,
                         newcclosure_c(function(...)
                return task.wait(9e9)
            end))
            setthreadidentity(oldId)
            print("Found main crash function!")
        end

        for _, const in pairs(consts) do
            if type(const) == "string" and const:lower():match("maindetection") then
                print("Found -> Detection function | Match ---> " .. const)
                hookfunction(fun, newcclosure_c(function(...)
                    print("Intercepted MainDetection")
                    return task.wait(9e9)
                end))
            end

            if type(const) == "string" and
                const:lower():match("disallowed service") then
                print("Found -> AntiAFK fix hook. | Match ---> " .. const)
                hookfunction(fun, newcclosure_c(function(...)
                    return
                end))
            end

            if type(const) == "string" and
                const:lower():match(":: adonis anti cheat::") then
                print("Found -> ADONIS ANTI CHEAT! | Match ---> " .. const)
                hookfunction(fun, newcclosure_c(function(...)
                    print("Adonis anticheat murderer 69420 edition")
                    return task.wait(9e9)
                end))
            end

            if type(const) == "string" and
                const:lower():match("exploit detected") then
                print("Found -> Exploit detector | Match ---> " .. const)
                hookfunction(fun, newcclosure_c(function(...)
                    print("Intercepted exploit detection")
                    return false
                end))
            end

            if type(const) == "string" and const:lower():match("method 0x") and
                const:lower():match("anti") then
                print(
                    "Found function matching constant... -> anti* + Method 0x*  | Match ---> " ..
                        const)
                hookfunction(fun, newcclosure_c(function(...)
                    print("Intercepted Method 0x* wildcard.")
                    return false
                end))
            end
        end
    end
end

local dbgInfoHook;
-- debug.info hook.
dbgInfoHook = hookfunction(debug.info, newcclosure_c(function(...)
    if checkcaller() then
        return dbgInfoHook(...)
    else
        return nil
    end
end))
