--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
-- Lua Library inline imports
local function __TS__ObjectAssign(target, ...)
    local sources = {...}
    for i = 1, #sources do
        local source = sources[i]
        for key in pairs(source) do
            target[key] = source[key]
        end
    end
    return target
end
-- End of Lua Library inline imports
local ____exports = {}
local getConfig
local util = require("neotest-playwright.util")
local ____build_2Dcommand = require('neotest-playwright.build-command')
local buildCommand = ____build_2Dcommand.buildCommand
local ____report = require('neotest-playwright.report')
local parseOutput = ____report.parseOutput
local async = require("neotest.async")
local lib = require("neotest.lib")
local logger = require("neotest.logging")
local ____adapter_2Doptions = require('neotest-playwright.adapter-options')
local options = ____adapter_2Doptions.options
local ____preset_2Doptions = require('neotest-playwright.preset-options')
local COMMAND_PRESETS = ____preset_2Doptions.COMMAND_PRESETS
____exports.buildSpec = function(args)
    if not args then
        logger.error("No args")
        return
    end
    if not args.tree then
        logger.error("No args.tree")
        return
    end
    local pos = args.tree:data()
    local testFilter = (pos.type == "test" or pos.type == "namespace") and (pos.path .. ":") .. tostring(pos.range[1] + 1) or pos.path
    local commandOptions = __TS__ObjectAssign(
        {},
        COMMAND_PRESETS[options.preset],
        {
            bin = options.get_playwright_command(pos.path),
            config = getConfig(pos.path),
            projects = options.projects,
            testFilter = testFilter
        }
    )
    local resultsPath = async.fn.tempname() .. ".json"
    lib.files.write(resultsPath, "")
    local streamData, stopStream = lib.files.stream(resultsPath)
    return {
        command = buildCommand(commandOptions),
        cwd = nil,
        context = {results_path = resultsPath, file = pos.path, stop_stream = stopStream},
        stream = function() return function()
            local newResults = streamData()
            local ok, report = pcall(vim.json.decode, newResults, {luanil = {object = true}})
            if not ok then
                logger.error("Error parsing results")
                return {}
            end
            return parseOutput(report, resultsPath)
        end end,
        env = {PLAYWRIGHT_JSON_OUTPUT_NAME = resultsPath}
    }
end
getConfig = function(filePath)
    local configDir = util.find_ancestor(filePath, "playwright.config.ts", false)
    local config = tostring(configDir) .. "/playwright.config.ts"
    if lib.files.exists(config) then
        logger.debug("playwright config", config)
        return config
    end
    logger.warn("Unable to locate config file.", config)
    return nil
end
return ____exports
