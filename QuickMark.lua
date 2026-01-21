--------------------------------------------------------------------------------
-- QuickMark - Native WoW Addon (No Ace3)
-- A lightweight addon for quickly marking targets with raid icons
--------------------------------------------------------------------------------

local ADDON_NAME = "QuickMark"
local QuickMark = {}
local frame -- Main UI frame
local db -- Saved variables reference

local DEBUG = false
local settingsCategory = nil

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------
local DEFAULT_EDGE_FILE = "Interface\\Tooltips\\UI-Tooltip-Border"
local DEFAULT_SCALE = 1.0
local DEFAULT_R = 0
local DEFAULT_G = 0
local DEFAULT_B = 0
local DEFAULT_A = 0.3

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
-- Helper Functions
--------------------------------------------------------------------------------
local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99QuickMark:|r " .. tostring(msg))
end

local function Debug(msg)
    if DEBUG then
        Print("[DEBUG] " .. tostring(msg))
    end
end

--------------------------------------------------------------------------------
-- Frame Creation
--------------------------------------------------------------------------------
local function CreateQuickMarkFrame()
    local f = CreateFrame("Frame", "QuickMarkFrame", UIParent, "BackdropTemplate")
    f:SetSize(230, 48)
    f:SetPoint("CENTER")
    f:EnableMouse(true)
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:SetFrameStrata("MEDIUM")

    -- Set up backdrop
    local backdrop = {
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = DEFAULT_EDGE_FILE,
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 3, right = 3, top = 5, bottom = 3 }
    }
    f:SetBackdrop(backdrop)
    f:SetBackdropColor(DEFAULT_R, DEFAULT_G, DEFAULT_B, DEFAULT_A)

    -- Drag functionality
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self)
        if self:IsMovable() then
            self:StartMoving()
        end
    end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        QuickMark:SavePosition()
    end)

    -- Container for icons
    f.icons = {}

    -- Create 8 raid target icon buttons
    local iconSize = 20
    local spacing = 5
    for i = 1, 8 do
        local btn = CreateFrame("Button", nil, f)
        btn:SetSize(iconSize, iconSize)
        btn:SetPoint("LEFT", 12 + (i-1) * (iconSize + spacing), 0)

        local texture = btn:CreateTexture(nil, "ARTWORK")
        texture:SetAllPoints()
        texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. i)

        btn:SetScript("OnClick", function()
            if GetRaidTargetIndex("target") == i then
                SetRaidTarget("target", 0)
            else
                SetRaidTarget("target", i)
            end
        end)

        f.icons[i] = btn
    end

    return f
end

--------------------------------------------------------------------------------
-- Layout Functions
--------------------------------------------------------------------------------
function QuickMark:SetHorizontalLayout()
    local iconSize = 20
    local spacing = 5

    frame:SetSize(230, 48)

    for i = 1, 8 do
        frame.icons[i]:ClearAllPoints()
        frame.icons[i]:SetPoint("LEFT", 12 + (i-1) * (iconSize + spacing), 0)
    end

    db.horizontal = true
    Debug("Horizontal Layout")
end

function QuickMark:SetVerticalLayout()
    local iconSize = 20
    local spacing = 5

    frame:SetSize(48, 230)

    for i = 1, 8 do
        frame.icons[i]:ClearAllPoints()
        frame.icons[i]:SetPoint("TOP", 0, -12 - (i-1) * (iconSize + spacing))
    end

    db.horizontal = false
    Debug("Vertical Layout")
end

function QuickMark:GetHorizontal()
    return db.horizontal
end

function QuickMark:SetHorizontal()
    return self:SetHorizontalLayout()
end

function QuickMark:GetVertical()
    return not db.horizontal
end

function QuickMark:SetVertical()
    return self:SetVerticalLayout()
end

function QuickMark:Flip()
    if db.horizontal then
        self:SetVerticalLayout()
    else
        self:SetHorizontalLayout()
    end
end

--------------------------------------------------------------------------------
-- Lock/Unlock Functions
--------------------------------------------------------------------------------
function QuickMark:Lock()
    frame:SetMovable(false)
    frame:EnableMouse(false)
    db.locked = true
    Debug("Locked")
end

function QuickMark:Unlock()
    frame:SetMovable(true)
    frame:EnableMouse(true)
    db.locked = false
    Debug("Unlocked")
end

function QuickMark:IsLocked()
    return db.locked
end

function QuickMark:ToggleLocked()
    if db.locked then
        self:Unlock()
    else
        self:Lock()
    end
end

function QuickMark:SetLocked()
    self:Lock()
end

function QuickMark:SetUnlocked()
    self:Unlock()
end

--------------------------------------------------------------------------------
-- Position Functions
--------------------------------------------------------------------------------
function QuickMark:SetPosition(point, relativePoint, xOfs, yOfs)
    frame:ClearAllPoints()
    frame:SetPoint(point, UIParent, relativePoint, xOfs, yOfs)
    db.point = point
    db.relativePoint = relativePoint
    db.xOfs = xOfs
    db.yOfs = yOfs
    Debug("Positioning at " .. xOfs .. ", " .. yOfs .. " relative to " .. relativePoint)
end

function QuickMark:SavePosition()
    local point, _, relativePoint, xOfs, yOfs = frame:GetPoint()
    if point and relativePoint then
        db.point = point
        db.relativePoint = relativePoint
        db.xOfs = xOfs
        db.yOfs = yOfs
        Debug("Position saved: " .. point .. " at " .. xOfs .. ", " .. yOfs)
    end
end

--------------------------------------------------------------------------------
-- Scale Functions
--------------------------------------------------------------------------------
function QuickMark:Scale(scale)
    frame:SetScale(scale)
    db.scale = scale
    Debug("Scale set to " .. (scale * 100) .. "%")
end

function QuickMark:GetScale()
    return db.scale or DEFAULT_SCALE
end

function QuickMark:SetScale(scale)
    self:Scale(scale)
end

--------------------------------------------------------------------------------
-- Visibility Functions
--------------------------------------------------------------------------------
function QuickMark:Toggle()
    if db.hidden then
        self:Show()
    else
        self:Hide()
    end
end

function QuickMark:Show()
    frame:Show()
    db.hidden = false
    Debug("Shown")
end

function QuickMark:Hide()
    frame:Hide()
    db.hidden = true
    Debug("Hidden")
end

function QuickMark:IsShown()
    return not db.hidden
end

function QuickMark:IsHidden()
    return db.hidden
end

function QuickMark:SetShown()
    self:Show()
end

function QuickMark:SetHidden()
    self:Hide()
end

--------------------------------------------------------------------------------
-- Border Functions
--------------------------------------------------------------------------------
function QuickMark:Border(edge_file)
    db.edge_file = edge_file

    local backdrop = {
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = edge_file,
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 3, right = 3, top = 5, bottom = 3 }
    }

    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(db.bg_color_r, db.bg_color_g, db.bg_color_b, db.bg_color_a)
    Debug("Border changed")
end

function QuickMark:GetBorder()
    return db.edge_file
end

function QuickMark:SetBorder(input)
    self:Border(input)
end

--------------------------------------------------------------------------------
-- Background Color Functions
--------------------------------------------------------------------------------
function QuickMark:BackgroundColor(r, g, b, a)
    db.bg_color_r = r
    db.bg_color_g = g
    db.bg_color_b = b
    db.bg_color_a = a

    frame:SetBackdropColor(r, g, b, a)
    Debug("Color changed")
end

function QuickMark:GetBackgroundColor()
    return db.bg_color_r, db.bg_color_g, db.bg_color_b, db.bg_color_a
end

function QuickMark:SetBackgroundColor(r, g, b, a)
    self:BackgroundColor(r, g, b, a)
end

--------------------------------------------------------------------------------
-- Blizzard Settings API
--------------------------------------------------------------------------------
function QuickMark:SetupSettings()
    local category = Settings.RegisterVerticalLayoutCategory("QuickMark")
    settingsCategory = category

    -- Lock checkbox
    do
        local variable = "locked"
        local name = "Lock"
        local tooltip = "Lock the QuickMark bar in place."
        local defaultValue = false

        local setting = Settings.RegisterAddOnSetting(category, "QuickMark_Lock", variable, db, type(defaultValue), name, defaultValue)
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
        local variable = "hidden"
        local name = "Hide"
        local tooltip = "Hide the QuickMark bar."
        local defaultValue = false

        local setting = Settings.RegisterAddOnSetting(category, "QuickMark_Hide", variable, db, type(defaultValue), name, defaultValue)
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
        local variable = "horizontal"
        local name = "Horizontal"
        local tooltip = "Display the QuickMark bar horizontally instead of vertically."
        local defaultValue = false

        local setting = Settings.RegisterAddOnSetting(category, "QuickMark_Horizontal", variable, db, type(defaultValue), name, defaultValue)
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
        local variable = "scale"
        local name = "Scale"
        local tooltip = "Scale controls the size of the QuickMark bar."
        local defaultValue = DEFAULT_SCALE
        local minValue = 0.1
        local maxValue = 5.0
        local step = 0.1

        local setting = Settings.RegisterAddOnSetting(category, "QuickMark_Scale", variable, db, type(defaultValue), name, defaultValue)
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
        local variable = "edge_file"
        local name = "Border"
        local tooltip = "Set the border of the QuickMark bar."
        local defaultValue = DEFAULT_EDGE_FILE

        local function GetOptions()
            local container = Settings.CreateControlTextContainer()
            for _, opt in ipairs(BORDER_OPTIONS) do
                container:Add(opt.value, opt.label)
            end
            return container:GetData()
        end

        local setting = Settings.RegisterAddOnSetting(category, "QuickMark_Border", variable, db, type(defaultValue), name, defaultValue)
        setting:SetValueChangedCallback(function(_, value)
            QuickMark:Border(value)
        end)
        Settings.CreateDropdown(category, setting, GetOptions, tooltip)
    end

    Settings.RegisterAddOnCategory(category)
end

--------------------------------------------------------------------------------
-- Load Settings
--------------------------------------------------------------------------------
function QuickMark:LoadSettings()
    -- Set Position
    if db.point then
        self:SetPosition(db.point, db.relativePoint, db.xOfs, db.yOfs)
    end

    -- Set Orientation
    if db.horizontal then
        self:SetHorizontalLayout()
    else
        self:SetVerticalLayout()
    end

    -- Set Locked Status
    if db.locked then
        self:Lock()
    else
        self:Unlock()
    end

    -- Set Hidden Status
    if db.hidden then
        self:Hide()
    else
        self:Show()
    end

    -- Set Scale
    self:Scale(db.scale or DEFAULT_SCALE)

    -- Set Background Color
    if db.bg_color_r and db.bg_color_g and db.bg_color_b and db.bg_color_a then
        self:BackgroundColor(db.bg_color_r, db.bg_color_g, db.bg_color_b, db.bg_color_a)
    else
        self:BackgroundColor(DEFAULT_R, DEFAULT_G, DEFAULT_B, DEFAULT_A)
    end

    -- Set Border
    self:Border(db.edge_file or DEFAULT_EDGE_FILE)
end

--------------------------------------------------------------------------------
-- Initialize Saved Variables
--------------------------------------------------------------------------------
local function InitializeDatabase()
    QuickMarkDB = QuickMarkDB or {}
    db = QuickMarkDB

    -- Set defaults if not already set
    if db.scale == nil then db.scale = DEFAULT_SCALE end
    if db.horizontal == nil then db.horizontal = false end
    if db.locked == nil then db.locked = false end
    if db.hidden == nil then db.hidden = false end
    if db.edge_file == nil then db.edge_file = DEFAULT_EDGE_FILE end
    if db.bg_color_r == nil then db.bg_color_r = DEFAULT_R end
    if db.bg_color_g == nil then db.bg_color_g = DEFAULT_G end
    if db.bg_color_b == nil then db.bg_color_b = DEFAULT_B end
    if db.bg_color_a == nil then db.bg_color_a = DEFAULT_A end

    Debug("Database initialized")
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------
function QuickMark:OnInitialize()
    Debug("Initializing settings")

    InitializeDatabase()
    frame = CreateQuickMarkFrame()

    self:LoadSettings()
    self:SetupSettings()
end

function QuickMark:OnEnable()
    Debug("Enabled")
end

function QuickMark:OnDisable()
    Debug("Disabled")
end

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
-- Event Handler
--------------------------------------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_LOGOUT")
eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        QuickMark:OnInitialize()
    elseif event == "PLAYER_LOGIN" then
        QuickMark:OnEnable()
    elseif event == "PLAYER_LOGOUT" then
        QuickMark:OnDisable()
    end
end)

--------------------------------------------------------------------------------
-- Export to global namespace
--------------------------------------------------------------------------------
_G["QuickMark"] = QuickMark
