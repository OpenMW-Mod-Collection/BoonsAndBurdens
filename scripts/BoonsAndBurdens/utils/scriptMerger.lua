---@omw-context local | global
local vfs = require("openmw.vfs")

local M = {}

--- Merges handler tables from multiple Lua files, supporting multiple handler types.
--- @param folderPath string
--- @return table<string, table<string, function>>
M.mergeAllHandlers = function(folderPath)
    local merged = {}

    -- Temporary storage: all[handlerType][handlerName] = { {source=path, func=fn}, ... }
    local all = {}

    for filePath in vfs.pathsWithPrefix(folderPath) do
        if filePath:match("%.lua$") then
            local modulePath = filePath:gsub("%.lua$", "")
            local ok, newHandlers = pcall(require, modulePath)

            if not ok then
                print(("Failed to require '%s': %s\n"):format(modulePath, newHandlers))
            elseif type(newHandlers) == "table" then
                for handlerType, handlers in pairs(newHandlers) do
                    if type(handlers) == "table" then
                        all[handlerType] = all[handlerType] or {}

                        for name, func in pairs(handlers) do
                            if type(func) == "function" then
                                all[handlerType][name] = all[handlerType][name] or {}
                                table.insert(all[handlerType][name], { source = modulePath, func = func })
                            end
                        end
                    end
                end
            end
        end
    end

    -- Create dispatcher functions for each handler type and name
    for handlerType, handlers in pairs(all) do
        merged[handlerType] = {}
        local isEngineHandler = handlerType == "engineHandlers"

        for name, entries in pairs(handlers) do
            if isEngineHandler and name == "onSave" then
                -- Collect each script's saved data separately, keyed by its source file
                merged[handlerType][name] = function(...)
                    local result = {}
                    for _, entry in ipairs(entries) do
                        result[entry.source] = entry.func(...)
                    end
                    return result
                end
            elseif isEngineHandler and name == "onLoad" then
                -- Route each script's own saved data (or nil, first run) back to it
                merged[handlerType][name] = function(data, ...)
                    data = data or {}
                    for _, entry in ipairs(entries) do
                        entry.func(data[entry.source], ...)
                    end
                end
            else
                -- Default behavior: call every handler, ignore return values
                merged[handlerType][name] = function(...)
                    for _, entry in ipairs(entries) do
                        entry.func(...)
                    end
                end
            end
        end
    end

    return merged
end

return M
