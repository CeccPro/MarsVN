local debug = {}

function debug.log(msg)
    local str = os.date("[%Y-%m-%d %H:%M:%S] ") .. tostring(msg)
    print(str)
    if not logfile then
        logfile = io.open("debug.log", "a")
    end
    if logfile then
        logfile:write(str .. "\n")
        logfile:flush()
    end
end

function debug.close()
    if logfile then logfile:close() logfile = nil end
end

return debug