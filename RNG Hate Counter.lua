RNGHateCounter = {
    name = "RNG Hate Counter",
    version = "1.2.6",
    author = "@Complicative",
}

RNGHateCounter.Settings = {}

RNGHateCounter.Default = {
    throttle = 5,
    throttle1 = 0,
    throttle2 = 0,
    throttle3 = 0,
    timeStamp = true,
    squirrel1 = nil,
    squirrel2 = nil,
    squirrel3 = nil,
}

RNGHateCounter.db = {}

local LAM2 = LibAddonMenu2
local debug = false
local function cStart(hex)
    return "|c" .. hex
end

local function cEnd()
    return "|r"
end

local function getTimeStamp()
    if RNGHateCounter.Settings.timeStamp then
        return cStart(888888) .. "[" .. os.date('%H:%M:%S') .. "] " .. cEnd()
    else
        return ""
    end
end

-------------------------------------------------------------------------------------------------
-- OnPlayerCombatState  --
-------------------------------------------------------------------------------------------------
function RNGHateCounter.CombatCallbacks(_, result, isError, aName, aGraphic, aActionSlotType, sName, sType, tName, tType
                                        , hitValue, pType, dType, log, sUnitId, tUnitId, abilityId, overflow)

    local player = zo_strformat("<<1>>", sName)
    local squirrel = zo_strformat("<<1>>", tName)
    --posts all results, targetNames, sourceNames if debug is on
    if debug then
        d(getTimeStamp() .. sName .. " did " .. result .. " to " .. tName)
    end

    -- 2262 -> kill with exp
    -- 2260 -> kill without exp (critters/dummy)
    -- If player kills something
    if (result == 2262 or result == 2260) and player ~= "" and tType ~= 1 then
        -- Check if mob has is in the table already
        if (RNGHateCounter.db[squirrel] ~= nil) then
            -- Increment value by 1
            RNGHateCounter.db[squirrel] = RNGHateCounter.db[squirrel] + 1
        else
            -- Set value to 1
            RNGHateCounter.db[squirrel] = 1
        end
        -- If it's a tracked mob or everything is posted
        if (
            (string.lower(squirrel) == string.lower(RNGHateCounter.Settings.squirrel1) and
                RNGHateCounter.db[squirrel] % RNGHateCounter.Settings.throttle1 == 0 and
                RNGHateCounter.Settings.throttle1 >= 0)
                or
                (string.lower(squirrel) == string.lower(RNGHateCounter.Settings.squirrel2) and
                    RNGHateCounter.db[squirrel] % RNGHateCounter.Settings.throttle2 == 0 and
                    RNGHateCounter.Settings.throttle2 >= 0)
                or
                (string.lower(squirrel) == string.lower(RNGHateCounter.Settings.squirrel3) and
                    RNGHateCounter.Settings.throttle3 >= 0)
                or
                (
                RNGHateCounter.Settings.throttle >= 0 and
                    RNGHateCounter.db[squirrel] % RNGHateCounter.Settings.throttle == 0)
            )
        -- and throttle rule allows to post
        then
            -- post mob + killed amount
            CHAT_SYSTEM:AddMessage(getTimeStamp() ..
                squirrel .. " (" .. RNGHateCounter.db[squirrel] .. ")")
        end
    end
end

-------------------------------------------------------------------------------------------------
-- OnAddOnLoaded  --
-------------------------------------------------------------------------------------------------

function RNGHateCounter.OnAddOnLoaded(event, addonName)
    if addonName ~= RNGHateCounter.name then return end

    -- SavedSettings
    RNGHateCounter.Settings = ZO_SavedVars:NewAccountWide("RNGHateCounterSettings", 2, nil, RNGHateCounter.Default)
    RNGHateCounter.db = ZO_SavedVars:NewAccountWide("RNGHateCounterDB", 1, nil, RNGHateCounter.db)



    -------------------------------------------------------------------------------------------------
    -- Creating Settings  --
    -------------------------------------------------------------------------------------------------

    local panelData = {
        type = "panel",
        name = "RNG Hate Counter",
        author = 'Complicative',
        version = RNGHateCounter.version,
        website = "https://www.esoui.com/downloads/info3425-RNGHateCounterSpecificMobKillTracker.html",
        slashCommand = "/rnghatecounter"
    }

    LAM2:RegisterAddonPanel("RNGHateCounterOptions", panelData)

    local optionsData = {}
    optionsData[#optionsData + 1] = {
        type = "description",
        text = "This add-on tracks all your killing blows on any npc. You can select up to 3 npc, where you can set up how often to post updates on these."
            .. "\n" ..
            "One additional slider is available for all other npc." .. "\n\n" ..
            "Example: Setting the first npc to <Mammoth> and setting it's slider to <5>, while having the last slider on <10>, "
            ..
            "will result with updates on Mammoth kills at 5,10,15,.. and all other npc at 10,20,30,..." .. "\n\n" ..
            "Commands:" .. "\n" ..
            "/killcount <npc> will post in chat the recorded kills on <npc>. Typing and capitalisation needs to be exact."
    }
    optionsData[#optionsData + 1] = {
        type = "editbox",
        name = "NPC #1 to live post in chat:",
        tooltip = "Type in the name of the npc you want to get updates about in chat and select with the slider below, how often to get such updates",
        getFunc =
        function()
            if RNGHateCounter.Settings.squirrel1 ~= nil then
                return RNGHateCounter.Settings.squirrel1
            else
                return ""
            end
        end,
        setFunc =
        function(text)
            if text == "" then
                RNGHateCounter.Settings.squirrel1 = nil
            else
                RNGHateCounter.Settings.squirrel1 = text
            end
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "slider",
        name = "Throttle",
        tooltip = "After how many kills to post updates in chat",
        min = 0,
        max = 100,
        getFunc = function() return RNGHateCounter.Settings.throttle1 end,
        setFunc = function(value) RNGHateCounter.Settings.throttle1 = value end,
    }
    optionsData[#optionsData + 1] = {
        type = "divider",
    }
    optionsData[#optionsData + 1] = {
        type = "editbox",
        name = "NPC #2 to live post in chat:",
        tooltip = "Type in the name of the npc you want to get updates about in chat and select with the slider below, how often to get such updates",
        getFunc =
        function()
            if RNGHateCounter.Settings.squirrel2 ~= nil then
                return RNGHateCounter.Settings.squirrel2
            else
                return ""
            end
        end,
        setFunc =
        function(text)
            if text == "" then
                RNGHateCounter.Settings.squirrel2 = nil
            else
                RNGHateCounter.Settings.squirrel2 = text
            end
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "slider",
        name = "Throttle",
        tooltip = "After how many kills to post updates in chat",
        min = 0,
        max = 100,
        getFunc = function() return RNGHateCounter.Settings.throttle2 end,
        setFunc = function(value) RNGHateCounter.Settings.throttle2 = value end,
    }
    optionsData[#optionsData + 1] = {
        type = "divider",
    }
    optionsData[#optionsData + 1] = {
        type = "editbox",
        name = "NPC #3 to live post in chat:",
        tooltip = "Type in the name of the npc you want to get updates about in chat and select with the slider below, how often to get such updates",
        getFunc =
        function()
            if RNGHateCounter.Settings.squirrel3 ~= nil then
                return RNGHateCounter.Settings.squirrel3
            else
                return ""
            end
        end,
        setFunc =
        function(text)
            if text == "" then
                RNGHateCounter.Settings.squirrel3 = nil
            else
                RNGHateCounter.Settings.squirrel3 = text
            end
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "slider",
        name = "Throttle",
        tooltip = "After how many kills to post updates in chat",
        min = 0,
        max = 100,
        getFunc = function() return RNGHateCounter.Settings.throttle3 end,
        setFunc = function(value) RNGHateCounter.Settings.throttle3 = value end,
    }
    optionsData[#optionsData + 1] = {
        type = "divider",
    }
    optionsData[#optionsData + 1] = {
        type = "slider",
        name = "Throttle All",
        tooltip = "If selected 0, this option is off. This is for all npc and will work alongside the specified ones.",
        min = 0,
        max = 100,
        getFunc = function() return RNGHateCounter.Settings.throttle end,
        setFunc = function(value) RNGHateCounter.Settings.throttle = value end,
    }
    optionsData[#optionsData + 1] = {
        type = "divider",
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Timestamp",
        tooltip = "Do you want a timestamp at the start of the messages?",
        getFunc = function() return RNGHateCounter.Settings.timeStamp end,
        setFunc = function(value) RNGHateCounter.Settings.timeStamp = value end,
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Debug",
        tooltip = "I wouldn't touch that",
        getFunc = function() return debug end,
        setFunc = function(value) debug = value end,
    }

    LAM2:RegisterOptionControls("RNGHateCounterOptions", optionsData)


    -------------------------------------------------------------------------------------------------
    -- Creating Settings End --
    -------------------------------------------------------------------------------------------------
end

-------------------------------------------------------------------------------------------------
-- OnAddOnLoaded End --
-------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------------------------
-- General events and commands --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(RNGHateCounter.name, EVENT_COMBAT_EVENT, RNGHateCounter.CombatCallbacks)
EVENT_MANAGER:RegisterForEvent(RNGHateCounter.name, EVENT_ADD_ON_LOADED, RNGHateCounter.OnAddOnLoaded)



SLASH_COMMANDS["/killcount"] = function(squirrel)
    local count
    if RNGHateCounter.db[squirrel] ~= nil then
        count = RNGHateCounter.db[squirrel]
    else
        count = 0
    end
    -- Posts kills of <squirrel> var if existing (Only works with proper capitalisation currently)
    CHAT_SYSTEM:AddMessage(getTimeStamp() ..
        "You have killed " ..
        cStart("00BB00") .. zo_strformat("<<2>>" .. cEnd() .. " <<m:1>>", squirrel, count))
end