RNGHateCounterUI = {
    mainFragment
}

local tableInit = false
local differentCount = 0
local totalCount = 0
local sortByName = true

function RNGHateCounterUI.OnStart(h, hl, x, y)
    --RNGHCTLC1:SetHidden(h)
    RNGHCTLC1ButtonLabel:SetHidden(hl)
    RNGHCTLC1:ClearAnchors()
    RNGHCTLC1:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)

    for _, v in pairs(RNGHateCounter.db.IteratableSavedVars) do
        totalCount = totalCount + v
    end

    RNGHCTLC1ButtonLabel:SetText(totalCount)

    RNGHateCounterUI.mainFragment = ZO_SimpleSceneFragment:New(RNGHCTLC1)

    if not h then
        HUD_SCENE:AddFragment(RNGHateCounterUI.mainFragment)
        HUD_UI_SCENE:AddFragment(RNGHateCounterUI.mainFragment)
    end
end

function RNGHateCounterUI.saveButtonLocation()
    RNGHateCounter.Settings.buttonX = RNGHCTLC1:GetLeft()
    RNGHateCounter.Settings.buttonY = RNGHCTLC1:GetTop()
end

function RNGHateCounterUI.InitScrollList()

    if not tableInit then
        RNGHateCounterUI.CreateMainWindowControl()
        RNGHateCounterUI.CreateScrollListControl()
        RNGHateCounterUI.CreateScrollListDataType()
        tableInit = true
    else
        RNGHateCounterUI.controlMainWindow:SetHidden(false)
    end

    differentCount = 0
    totalCount = 0

    local table = RNGHateCounterUI.PopulateScrollList(function(a) return true end)
    RNGHateCounterUI.UpdateScrollList(RNGHateCounterUI.controlScrollList, table, 1)

    RNGHateCounterUI.controlInfoLabel:SetText("Different Species killed: " ..
        differentCount .. " | Total kills: " .. totalCount)


end

function RNGHateCounterUI.CreateMainWindowControl()
    --Main Window
    RNGHateCounterUI.controlMainWindow = WINDOW_MANAGER:CreateTopLevelWindow("TLW")
    RNGHateCounterUI.controlMainWindow:SetAnchor(CENTER, GuiRoot, CENTER)
    RNGHateCounterUI.controlMainWindow:SetDimensions(600, 800)
    RNGHateCounterUI.controlMainWindow:SetHidden(false)
    RNGHateCounterUI.controlMainWindow:SetMovable(true)
    RNGHateCounterUI.controlMainWindow:SetClampedToScreen(true)
    RNGHateCounterUI.controlMainWindow:SetMouseEnabled(true)

    --Background
    RNGHateCounterUI.controlMainWindowBackground = WINDOW_MANAGER:CreateControlFromVirtual("TLWBG",
        RNGHateCounterUI.controlMainWindow, "ZO_DarkThinFrame")
    RNGHateCounterUI.controlMainWindowBackground:SetAnchorFill(RNGHateCounterUI.controlMainWindow)

    --Title
    RNGHateCounterUI.controlLabel = WINDOW_MANAGER:CreateControlFromVirtual("TLWLabel",
        RNGHateCounterUI.controlMainWindow
        ,
        "ZO_WindowTitle")
    RNGHateCounterUI.controlLabel:SetAnchor(TOPLEFT, RNGHateCounterUI.controlMainWindow, TOPLEFT, 10, 5)
    RNGHateCounterUI.controlLabel:SetText("RNG Hate Counter")

    --SwapOrderButton
    RNGHateCounterUI.controlSwapButton = WINDOW_MANAGER:CreateControlFromVirtual("TLWSwapButton",
        RNGHateCounterUI.controlMainWindow, "ZO_DropdownButton")
    RNGHateCounterUI.controlSwapButton:SetAnchor(LEFT, RNGHateCounterUI.controlLabel, RIGHT, 5, 5)
    RNGHateCounterUI.controlSwapButton:SetHandler("OnMouseEnter", function(control)
        ZO_Tooltips_ShowTextTooltip(control, RIGHT, "Swap between sort by name/amount")
    end)
    RNGHateCounterUI.controlSwapButton:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)
    RNGHateCounterUI.controlSwapButton:SetHandler("OnClicked",
        function()
            sortByName = not sortByName
            if RNGHateCounterUI.controlSearchBar:GetText() ~= "Search" then
                local table = RNGHateCounterUI.PopulateScrollList(function(a)
                    if string.find(string.lower(a), string.lower(RNGHateCounterUI.controlSearchBar:GetText())) ~= nil then return true else return false end
                end)
                RNGHateCounterUI.UpdateScrollList(RNGHateCounterUI.controlScrollList, table, 1)
            else
                RNGHateCounterUI.InitScrollList()
            end
        end)


    --SearchBar
    RNGHateCounterUI.controlSearchBar = WINDOW_MANAGER:CreateControlFromVirtual("TLWSearchBar",
        RNGHateCounterUI.controlMainWindow, "ZO_DefaultEditForBackdrop")
    RNGHateCounterUI.controlSearchBar:ClearAnchors()
    RNGHateCounterUI.controlSearchBar:SetAnchor(TOPRIGHT, RNGHateCounterUI.controlMainWindow, TOPRIGHT, -40, 10)
    RNGHateCounterUI.controlSearchBar:SetDimensions(200, 28)
    RNGHateCounterUI.controlSearchBar:SetText("Search")
    RNGHateCounterUI.controlSearchBar:SetHandler("OnTextChanged", function()
        differentCount = 0
        totalCount = 0
        local table = RNGHateCounterUI.PopulateScrollList(function(a)
            if string.find(string.lower(a), string.lower(RNGHateCounterUI.controlSearchBar:GetText())) ~= nil then return true else return false end
        end)
        RNGHateCounterUI.UpdateScrollList(RNGHateCounterUI.controlScrollList, table, 1)

        RNGHateCounterUI.controlInfoLabel:SetText("Different Species killed: " ..
            differentCount .. " | Total kills: " .. totalCount)

    end)
    RNGHateCounterUI.controlSearchBar:SetHandler("OnFocusGained",
        function() RNGHateCounterUI.controlSearchBar:Clear() end)
    --SearchBarBackground
    RNGHateCounterUI.controlSearchBarBackground = WINDOW_MANAGER:CreateControlFromVirtual("TLWSearchBarBG",
        RNGHateCounterUI.controlSearchBar, "ZO_DarkThinFrame")
    RNGHateCounterUI.controlSearchBarBackground:SetAnchorFill(RNGHateCounterUI.controlSearchBar)

    --Close Button
    RNGHateCounterUI.controlCloseButton = WINDOW_MANAGER:CreateControlFromVirtual("TLWCloseButton",
        RNGHateCounterUI.controlMainWindow, "ZO_CloseButton")
    RNGHateCounterUI.controlCloseButton:SetAnchor(TOPRIGHT, RNGHateCounterUI.controlMainWindow, TOPRIGHT)
    RNGHateCounterUI.controlCloseButton:SetHandler("OnClicked",
        function()
            RNGHateCounterUI.controlMainWindow:SetHidden(true)
            RNGHateCounterUI.controlSearchBar:SetText("Search")
        end)

    --Info Label
    RNGHateCounterUI.controlInfoLabel = WINDOW_MANAGER:CreateControl("TLWInfoLabel",
        RNGHateCounterUI.controlMainWindow, CT_LABEL)
    RNGHateCounterUI.controlInfoLabel:SetFont("ZoFontWinH3")
    RNGHateCounterUI.controlInfoLabel:SetColor(RNGHateCounterUI.controlLabel:GetColor())
    RNGHateCounterUI.controlInfoLabel:SetAnchor(BOTTOM, RNGHateCounterUI.controlMainWindow, BOTTOM)
    RNGHateCounterUI.controlInfoLabel:SetText("Different Species killed: 0 | Total kills: 0")
end

function RNGHateCounterUI.CreateScrollListControl()
    RNGHateCounterUI.controlScrollList = WINDOW_MANAGER:CreateControlFromVirtual("ScrollList",
        RNGHateCounterUI.controlMainWindow, "ZO_ScrollList")
    local width, height = RNGHateCounterUI.controlMainWindow:GetDimensions()
    RNGHateCounterUI.controlScrollList:SetDimensions(width - 20, height - 80)
    RNGHateCounterUI.controlScrollList:SetAnchor(BOTTOM, RNGHateCounterUI.controlMainWindow, BOTTOM, 0, -30)
end

function RNGHateCounterUI.CreateScrollListDataType()
    local control = RNGHateCounterUI.controlScrollList
    local typeId = 1
    local templateName = "ZO_SelectableLabel"
    local height = 25 -- height of the row, not the window
    local setupFunction = RNGHateCounterUI.LayoutRow
    local hideCallback = nil
    local dataTypeSelectSound = nil
    local resetControlCallback = nil

    ZO_ScrollList_AddDataType(control, typeId, templateName, height, setupFunction, hideCallback, dataTypeSelectSound,
        resetControlCallback)
end

function RNGHateCounterUI.PopulateScrollList(func)
    local tab = {}
    for k, v in pairs(RNGHateCounter.db.IteratableSavedVars) do
        if (func(k)) then
            table.insert(tab, {
                name = k,
                amount = v
            })
            differentCount = differentCount + 1
            totalCount = totalCount + v
        end
    end

    if (sortByName) then
        table.sort(tab, function(a, b) return a.name < b.name end)
    else
        table.sort(tab, function(a, b) return a.amount > b.amount end)
    end

    return tab
end

function RNGHateCounterUI.UpdateScrollList(control, data, rowType)
    local dataCopy = ZO_DeepTableCopy(data)
    local dataList = ZO_ScrollList_GetDataList(control)

    ZO_ScrollList_Clear(control)

    for key, value in ipairs(dataCopy) do
        local entry = ZO_ScrollList_CreateDataEntry(rowType, value)
        table.insert(dataList, entry)
    end

    ZO_ScrollList_Commit(control)

end

function RNGHateCounterUI.LayoutRow(rowControl, data, scrollList)

    rowControl:SetFont("ZoFontWinH4")
    rowControl:SetMaxLineCount(1)
    rowControl:SetText(data.name .. ": " .. data.amount)



end
