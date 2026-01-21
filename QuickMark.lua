local QuickMark = LibStub("AceAddon-3.0"):NewAddon("QuickMark", "AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local AceDB = LibStub("AceDB-3.0")

local DEBUG = false
local settingsCategory = nil

--------------------------------------------------------------------------------
-- Options (for slash commands)
--------------------------------------------------------------------------------
local EDGE_FILES = {
    ["Interface\\DialogFrame\\UI-DialogBox-Border"] = "Classic",
    ["Interface\\DialogFrame\\UI-DialogBox-Gold-Border"] = "Classic Gold",
    ["Interface\\Tooltips\\UI-Tooltip-Border"] = "Slick",
    ["Interface\\ACHIEVEMENTFRAME\\UI-Achievement-WoodBorder"] = "Wood",
    ["Interface\\FriendsFrame\\UI-Toast-Border"] = "Hefty",
    [""] = "None",
    ["Interface\\LFGFRAME\\LFGBorder"] = "Graphite"
}

-- Border options for dropdown (value -> display name)
local BORDER_OPTIONS = {
    { value = "Interface\\DialogFrame\\UI-DialogBox-Border", label = "Classic" },
    { value = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border", label = "Classic Gold" },
    { value = "Interface\\Tooltips\\UI-Tooltip-Border", label = "Slick" },
    { value = "Interface\\ACHIEVEMENTFRAME\\UI-Achievement-WoodBorder", label = "Wood" },
    { value = "Interface\\FriendsFrame\\UI-Toast-Border", label = "Hefty" },
    { value = "", label = "None" },
    { value = "Interface\\LFGFRAME\\LFGBorder", label = "Graphite" },
}

--------------------------------------------------------------------------------
-- Frame
--------------------------------------------------------------------------------
function QuickMark:CreateQuickMarkFrame()
    local frame = AceGUI:Create("QuickMarkFrame")
    local iconSize = 20

    for i = 1, 8 do
        local targetIcon = AceGUI:Create("Icon")
        targetIcon:SetImage("INTERFACE/TARGETINGFRAME/UI-RaidTargetingIcon_" .. i)
        targetIcon:SetWidth(iconSize)
        targetIcon:SetHeight(iconSize)
        targetIcon:SetImageSize(iconSize, iconSize)
        targetIcon:SetCallback("OnClick", function(self, button)
            if GetRaidTargetIndex("target") ~= i then
                SetRaidTarget("target", i)
            else
                SetRaidTarget("target", 0)
            end
        end)
        frame:AddChild(targetIcon)
    end

    return frame
end

local frame = QuickMark:CreateQuickMarkFrame()

--------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------
SLASH_QUICKMARK1 = "/quickmark"
SLASH_QUICKMARK2 = "/qm"
SlashCmdList["QUICKMARK"] = function(msg)
    local cmd = string.lower(msg or "")
    if cmd == "lock" or cmd == "l" then
        QuickMark:Lock()
    elseif cmd == "unlock" or cmd == "u" then
        QuickMark:Unlock()
    elseif cmd == "hide" or cmd == "h" then
        QuickMark:Hide()
    elseif cmd == "show" or cmd == "s" then
        QuickMark:Show()
    elseif cmd == "toggle" or cmd == "t" then
        QuickMark:Toggle()
    elseif cmd == "flip" or cmd == "f" then
        QuickMark:Flip()
    elseif cmd == "horizontal" or cmd == "hor" then
        QuickMark:SetHorizontalLayout()
    elseif cmd == "vertical" or cmd == "vert" then
        QuickMark:SetVerticalLayout()
    else
        if settingsCategory then
            Settings.OpenToCategory(settingsCategory:GetID())
        end
    end
end

--------------------------------------------------------------------------------
-- Layout Handlers
--------------------------------------------------------------------------------
function QuickMark:SetHorizontalLayout()
    frame:SetWidth(195)
    frame:SetHeight(48)
    frame:SetLayout("Flow")
    self.db.char.horizontal = true
    QuickMark:Debug("Horizontal Layout")
    return self.db.char.horizontal
end

function QuickMark:SetVerticalLayout()
    frame:SetWidth(45)
    frame:SetHeight(260)
    frame:SetLayout("List")
    QuickMark.db.char.horizontal = false
    QuickMark:Debug("Vertical Layout")
    return self.db.char.horizontal
end

function QuickMark:GetHorizontal(info)
    return self.db.char.horizontal
end

function QuickMark:SetHorizontal(info, input)
    return QuickMark:SetHorizontalLayout()
end

function QuickMark:GetVertical(info)
    return not self.db.char.horizontal
end

function QuickMark:SetVertical(info, input)
    return QuickMark:SetVerticalLayout()
end

function QuickMark:Flip(info, input)
    if self.db.char.horizontal then
        QuickMark:SetVerticalLayout()
    else
        QuickMark:SetHorizontalLayout()
    end
end

--------------------------------------------------------------------------------
-- Locking Handlers
--------------------------------------------------------------------------------
function QuickMark:Lock()
    frame:Lock()
    self.db.char.locked = true
    QuickMark:Debug("Locked")
end

function QuickMark:Unlock()
    frame:Unlock()
    self.db.char.locked = false
    QuickMark:Debug("Unlocked")
end

function QuickMark:IsLocked(info)
    return self.db.char.locked
end

function QuickMark:ToggleLocked(info, input)
    if self.db.char.locked then
        QuickMark:Unlock()
    else
        QuickMark:Lock()
    end
end

function QuickMark:SetLocked(info, input)
    QuickMark:Lock()
end

function QuickMark:SetUnlocked(info, input)
    QuickMark:Unlock()
end

--------------------------------------------------------------------------------
-- Positioning Handlers
--------------------------------------------------------------------------------
function QuickMark:SetPosition(point, relativePoint, x, y)
    frame:ClearAllPoints()
    frame:SetPoint(point, UIParent, relativePoint, x, y)
    QuickMark:Debug("Positioning at " .. x .. ", " .. y .. " relative to " .. relativePoint)
end

--------------------------------------------------------------------------------
-- Scaling Handlers
--------------------------------------------------------------------------------
function QuickMark:Scale(scale)
    frame.frame:SetScale(scale)
    self.db.char.scale = scale
    local displayScale = scale * 100
    QuickMark:Debug("Scale set to " .. displayScale .. "%")
end

function QuickMark:GetScale(info)
    return self.db.char.scale
end

function QuickMark:SetScale(info, scale)
    QuickMark:Scale(scale)
end

--------------------------------------------------------------------------------
-- Displaying Handlers
--------------------------------------------------------------------------------
function QuickMark:Toggle()
    if self.db.char.hidden then
        return QuickMark:Show()
    else
        return QuickMark:Hide()
    end
end

function QuickMark:Show()
    frame:Show()
    self.db.char.hidden = false
    QuickMark:Debug("Shown")
end

function QuickMark:Hide()
    frame:Hide()
    self.db.char.hidden = true
    QuickMark:Debug("Hidden")
end

function QuickMark:IsShown(info)
    return not self.db.char.hidden
end

function QuickMark:IsHidden(info)
    return self.db.char.hidden
end

function QuickMark:SetShown(info, input)
    QuickMark:Show()
end

function QuickMark:SetHidden(info, input)
    QuickMark:Hide()
end

function QuickMark:ToggleHidden(info, input)
    if self.db.char.hidden then
        QuickMark:Show()
    else
        QuickMark:Hide()
    end
end

--------------------------------------------------------------------------------
-- Appearance Handlers
--------------------------------------------------------------------------------
function QuickMark:Border(edge_file)
    self.db.char.edge_file = edge_file
    frame:SetBackdrop(self.db.char.edge_file, self.db.char.bg_color_r, self.db.char.bg_color_g, self.db.char.bg_color_b, self.db.char.bg_color_a)
    QuickMark:Debug("Border changed")
end

function QuickMark:GetBorder(info, input)
    return self.db.char.edge_file
end

function QuickMark:SetBorder(info, input)
    QuickMark:Border(input)
end

function QuickMark:BackgroundColor(r, g, b, a)
    self.db.char.bg_color_r = r
    self.db.char.bg_color_g = g
    self.db.char.bg_color_b = b
    self.db.char.bg_color_a = a
    frame:SetBackdrop(self.db.char.edge_file, self.db.char.bg_color_r, self.db.char.bg_color_g, self.db.char.bg_color_b, self.db.char.bg_color_a)
    QuickMark:Debug("Color changed")
end

function QuickMark:GetBackgroundColor(info, r, g, b, a)
    return self.db.char.bg_color_r, self.db.char.bg_color_g, self.db.char.bg_color_b, self.db.char.bg_color_a
end

function QuickMark:SetBackgroundColor(info, r, g, b, a)
    QuickMark:BackgroundColor(r, g, b, a)
end

-- DEPRECATED: Only here for those using the 2.0 API, use QuickMark:Toggle() instead.
function QuickMark_ToggleForm()
    QuickMark:Toggle()
end

--------------------------------------------------------------------------------
-- Blizzard Settings API
--------------------------------------------------------------------------------
function QuickMark:SetupSettings()
    local category = Settings.RegisterVerticalLayoutCategory("QuickMark")
    settingsCategory = category

    -- Lock checkbox
    do
        local variable = "QuickMark_Lock"
        local name = "Lock"
        local tooltip = "Lock the QuickMark bar in place."
        local defaultValue = false

        local setting = Settings.RegisterAddOnSetting(category, variable, variable, QuickMark.db.char, type(defaultValue), name, defaultValue)
        setting:SetValueChangedCallback(function(_, value)
            if value then
                QuickMark:Lock()
            else
                QuickMark:Unlock()
            end
        end)
        Settings.CreateCheckbox(category, setting, tooltip)
    end

    -- Hide checkbox
    do
        local variable = "QuickMark_Hide"
        local name = "Hide"
        local tooltip = "Hide the QuickMark bar."
        local defaultValue = false

        local setting = Settings.RegisterAddOnSetting(category, variable, variable, QuickMark.db.char, type(defaultValue), name, defaultValue)
        setting:SetValueChangedCallback(function(_, value)
            if value then
                QuickMark:Hide()
            else
                QuickMark:Show()
            end
        end)
        Settings.CreateCheckbox(category, setting, tooltip)
    end

    -- Horizontal checkbox
    do
        local variable = "QuickMark_Horizontal"
        local name = "Horizontal"
        local tooltip = "Display the QuickMark bar horizontally instead of vertically."
        local defaultValue = false

        local setting = Settings.RegisterAddOnSetting(category, variable, variable, QuickMark.db.char, type(defaultValue), name, defaultValue)
        setting:SetValueChangedCallback(function(_, value)
            if value then
                QuickMark:SetHorizontalLayout()
            else
                QuickMark:SetVerticalLayout()
            end
        end)
        Settings.CreateCheckbox(category, setting, tooltip)
    end

    -- Scale slider
    do
        local variable = "QuickMark_Scale"
        local name = "Scale"
        local tooltip = "Scale controls the size of the QuickMark bar."
        local defaultValue = 1.0
        local minValue = 0.1
        local maxValue = 5.0
        local step = 0.1

        local setting = Settings.RegisterAddOnSetting(category, variable, variable, QuickMark.db.char, type(defaultValue), name, defaultValue)
        setting:SetValueChangedCallback(function(_, value)
            QuickMark:Scale(value)
        end)

        local options = Settings.CreateSliderOptions(minValue, maxValue, step)
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
            return string.format("%.0f%%", value * 100)
        end)
        Settings.CreateSlider(category, setting, options, tooltip)
    end

    -- Border dropdown
    do
        local variable = "QuickMark_Border"
        local name = "Border"
        local tooltip = "Set the border of the QuickMark bar."
        local defaultValue = "Interface\\Tooltips\\UI-Tooltip-Border"

        local function GetOptions()
            local container = Settings.CreateControlTextContainer()
            for _, opt in ipairs(BORDER_OPTIONS) do
                container:Add(opt.value, opt.label)
            end
            return container:GetData()
        end

        local setting = Settings.RegisterAddOnSetting(category, variable, variable, QuickMark.db.char, type(defaultValue), name, defaultValue)
        setting:SetValueChangedCallback(function(_, value)
            QuickMark:Border(value)
        end)
        Settings.CreateDropdown(category, setting, GetOptions, tooltip)
    end

    Settings.RegisterAddOnCategory(category)
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------
local DEFAULT_EDGE_FILE = "Interface\\Tooltips\\UI-Tooltip-Border"
local DEFAULT_SCALE = 1.0
local DEFAULT_R = 0
local DEFAULT_G = 0
local DEFAULT_B = 0
local DEFAULT_A = 0.3

function QuickMark:LoadSettings()
    -- Set Position
    if self.db.char.point ~= nil then
        QuickMark:SetPosition(self.db.char.point, self.db.char.relativePoint, self.db.char.xOfs, self.db.char.yOfs)
    end

    -- Set Orientation
    if self.db.char.horizontal then
        QuickMark:SetHorizontalLayout()
    else
        QuickMark:SetVerticalLayout()
    end

    -- Set Locked Status
    if self.db.char.locked then
        QuickMark:Lock()
    else
        QuickMark:Unlock()
    end

    -- Set Hidden Status
    if self.db.char.hidden then
        QuickMark:Hide()
    else
        QuickMark:Show()
    end

    -- Set Scale
    if self.db.char.scale then
        QuickMark:Scale(self.db.char.scale)
    else
        QuickMark:Scale(DEFAULT_SCALE)
    end

    if self.db.char.bg_color_r and self.db.char.bg_color_g and self.db.char.bg_color_b and self.db.char.bg_color_a then
        QuickMark:BackgroundColor(self.db.char.bg_color_r, self.db.char.bg_color_g, self.db.char.bg_color_b, self.db.char.bg_color_a)
    else
        QuickMark:BackgroundColor(DEFAULT_R, DEFAULT_G, DEFAULT_B, DEFAULT_A)
    end

    -- Set Border
    if self.db.char.edge_file then
        QuickMark:Border(self.db.char.edge_file)
    else
        QuickMark:Border(DEFAULT_EDGE_FILE)
    end
end

function QuickMark:OnInitialize()
    QuickMark:Debug("Initializing settings")

    self.db = AceDB:New("QuickMarkDB")

    -- XXX: This might have performance problems but it is safe in terms of data consistency.
    frame.frame:SetScript("OnLeave", function()
        point, relativeTo, relativePoint, xOfs, yOfs = frame.frame:GetPoint()
        if relativeTo == nil then
            self.db.char.point = point
            self.db.char.relativePoint = relativePoint
            self.db.char.xOfs = xOfs
            self.db.char.yOfs = yOfs
            QuickMark:Debug("Positioning at " .. point .. " at " .. xOfs .. ", " .. yOfs .. " relative to " .. relativePoint)
        end
    end)

    QuickMark:LoadSettings()
    QuickMark:SetupSettings()
end

function QuickMark:OnEnable()
    QuickMark:Debug("Enabled")
end

function QuickMark:OnDisable()
    QuickMark:Debug("Disabled")
end

function QuickMark:Debug(message)
    if DEBUG then
        QuickMark:Print(message)
    end
end
