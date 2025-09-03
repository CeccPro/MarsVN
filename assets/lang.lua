local langs = {}
local lang_dir = (debug.getinfo(1, 'S').source:match("^@(.+)[/\\][^/\\]+$") or ".") .. "/langs/"

local function scanLangs()
    local files = {}
    local p = io.popen('dir /b "'..lang_dir..'"')
    if p then
        for file in p:lines() do table.insert(files, file) end
        p:close()
    end
    for _, file in ipairs(files) do
        if file:match("%.lua$") then
            local langCode = file:match("([%w_]+)%.lua$")
            langs[langCode] = dofile(lang_dir..file)
        end
    end
end

scanLangs()
return langs
