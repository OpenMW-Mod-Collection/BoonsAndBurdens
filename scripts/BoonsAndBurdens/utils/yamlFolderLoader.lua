---@diagnostic disable: cast-local-type
---@omw-context global|local
-- Usage:
--   local yamlFolderLoader = require("scripts.YourMod.utils.yamlFolderLoader")
--
--   local config = yamlFolderLoader.load("scripts/YourMod/config/")
--   local blacklist = yamlFolderLoader.loadLookup("scripts/YourMod/blacklist/")
--   if blacklist[someId:lower()] then ... end
--
--   -- Optional opts (shared by both functions):
--   local config = yamlFolderLoader.load("scripts/YourMod/config/", {
--       logPrefix = "[YourMod]",
--       silent = false,
--       extensions = { "yaml", "yml" },
--       transform = function(data, filePath)
--           -- e.g. lowercase all string values recursively
--           return data
--       end,
--   })
--
-- Merge behavior (load):
--   - Tables are merged recursively (deep merge).
--   - Array-like tables (sequential integer keys starting at 1) are
--     concatenated, not overwritten.
--   - Non-table values (strings, numbers, booleans) from later files
--     overwrite earlier ones with the same key.
--
-- Merge behavior (loadLookup):
--   - Each file's parsed data must itself be an array-like table (a plain
--     list of values). Every value across every file becomes a key in the
--     result, mapped to `true`.
--   - If a file's data is a mapping instead of a list, it's skipped with a
--     warning, since it has no unambiguous list of values to key by.
--
-- Files are processed in the order returned by vfs.pathsWithPrefix, which
-- is not guaranteed to be alphabetical - keep that in mind if load order
-- matters for scalar overwrites.

local vfs = require("openmw.vfs")
local markup = require("openmw.markup")

local yamlFolderLoader = {}

---Checks whether a table is array-like (sequential integer keys starting at 1).
---@param t table
---@return boolean
local function isArray(t)
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then
            return false
        end
    end
    return true
end

---Recursively merges src into dst in place. Arrays are concatenated,
---mapping tables are merged key by key, and scalars overwrite.
---@param dst table destination table, mutated in place
---@param src table source table to merge into dst
---@return table dst the same table passed in, returned for convenience
local function deepMerge(dst, src)
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dst[k]) == "table" then
                if isArray(v) and isArray(dst[k]) then
                    for _, item in ipairs(v) do
                        table.insert(dst[k], item)
                    end
                else
                    deepMerge(dst[k], v)
                end
            else
                -- Deep-copy src's table into dst to avoid shared references
                local copy = {}
                deepMerge(copy, v)
                dst[k] = copy
            end
        else
            dst[k] = v
        end
    end
    return dst
end

---@class YamlFolderLoaderOpts
---@field logPrefix string|nil Prefix prepended to log/warning output. Defaults to "[yamlFolderLoader]".
---@field silent boolean|nil If true, suppresses all print output. Defaults to false.
---@field extensions string[]|nil File extensions (without dot) to accept. Defaults to { "yaml", "yml" }.
---@field transform (fun(data: table, filePath: string): table)|nil
---    Optional callback applied to each file's parsed data before merging.
---    Receives the raw parsed table and the VFS path it came from, and must
---    return a table (either the same table mutated, or a replacement) that
---    will be merged into the final result.

---Internal: iterates matching YAML files under prefix, parsing and
---optionally transforming each one, and invokes onFileLoaded(data, filePath)
---for each successfully processed file.
---@param prefix string
---@param opts YamlFolderLoaderOpts
---@param onFileLoaded fun(data: table, filePath: string)
---@return number filesLoaded
local function forEachYamlFile(prefix, opts, onFileLoaded)
    local logPrefix = opts.logPrefix or "[yamlFolderLoader]"
    local silent = opts.silent or false
    local extensions = opts.extensions or { "yaml", "yml" }
    local transform = opts.transform

    local extSet = {}
    for _, ext in ipairs(extensions) do
        extSet[ext:lower()] = true
    end

    ---@param msg string
    local function log(msg)
        if not silent then
            print(logPrefix .. " " .. msg)
        end
    end

    local loaded = 0

    for filePath in vfs.pathsWithPrefix(prefix) do
        local ext = filePath:match("%.([%a%d]+)$")
        if ext and extSet[ext:lower()] then
            local ok, data = pcall(markup.loadYaml, filePath)
            if not ok then
                log("WARNING: could not parse " .. filePath .. ": " .. tostring(data))
            elseif type(data) ~= "table" then
                log("WARNING: " .. filePath .. " did not contain a YAML mapping/list, skipping")
            else
                if transform then
                    local tOk, tData = pcall(transform, data, filePath)
                    if not tOk then
                        log("WARNING: transform failed on " .. filePath .. ": " .. tostring(tData))
                        tData = nil
                    elseif type(tData) ~= "table" then
                        log("WARNING: transform for " .. filePath .. " did not return a table, ignoring transform result")
                        tData = nil
                    end
                    data = tData or data
                end

                onFileLoaded(data, filePath)
                loaded = loaded + 1
                log("Loaded config: " .. filePath)
            end
        end
    end

    if loaded == 0 then
        log("WARNING: no config YAMLs found under " .. prefix)
    end

    return loaded
end

---Loads and deep-merges all YAML files under the given VFS prefix into a
---single table.
---@param prefix string VFS folder prefix, e.g. "scripts/YourMod/config/"
---@param opts YamlFolderLoaderOpts|nil optional loader configuration
---@return table merged the deep-merged contents of all matched YAML files
---@return number filesLoaded the number of files successfully parsed and merged
function yamlFolderLoader.load(prefix, opts)
    opts = opts or {}
    local merged = {}

    local loaded = forEachYamlFile(prefix, opts, function(data, _)
        deepMerge(merged, data)
    end)

    return merged, loaded
end

---Loads all YAML files under the given VFS prefix, treating each file's
---top-level data as a list of values, and builds a lookup (set-style) table
---where every value across every file becomes a key mapped to `true`.
---@param prefix string VFS folder prefix, e.g. "scripts/YourMod/blacklist/"
---@param opts YamlFolderLoaderOpts|nil optional loader configuration
---@return table lookup set-style table: lookup[value] == true for every listed value
---@return number filesLoaded the number of files successfully parsed and merged
function yamlFolderLoader.loadLookup(prefix, opts)
    opts = opts or {}
    local logPrefix = opts.logPrefix or "[yamlFolderLoader]"
    local silent = opts.silent or false

    ---@param msg string
    local function log(msg)
        if not silent then
            print(logPrefix .. " " .. msg)
        end
    end

    local lookup = {}

    local loaded = forEachYamlFile(prefix, opts, function(data, filePath)
        if not isArray(data) then
            log("WARNING: " .. filePath .. " is not a list, skipping for lookup")
            return
        end
        for _, value in ipairs(data) do
            lookup[value] = true
        end
    end)

    return lookup, loaded
end

return yamlFolderLoader
