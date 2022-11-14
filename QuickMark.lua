local QuickMark = LibStub("AceAddon-3.0"):NewAddon("QuickMark", "AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConfigDialogue = LibStub("AceConfigDialog-3.0")
local AceConfig = LibStub("AceConfig-3.0")

local DEBUG = false

--------------------------------------------------------------------------------
-- Options
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

local OPTIONS = {
    name = "QuickMark",
    handler = QuickMark,
    type = 'group',
    args = {
        -- Locking
        lock_gui = { type = 'toggle', name = 'Lock', desc = 'Lock the QuickMark bar.', set = 'ToggleLocked', get = 'IsLocked', cmdHidden = true, order = 1 },
        lock = { type = 'toggle', name = 'Lock', desc = 'Lock the QuickMark bar.', set = 'SetLocked', get = 'IsLocked', guiHidden = true },
        l = { type = 'toggle', name = 'Lock', desc = 'Lock the QuickMark bar.', set = 'SetLocked', get = 'IsLocked', guiHidden = true },
        unlock = { type = 'toggle', name = 'Lock', desc = 'Unlock the QuickMark bar.', set = 'SetUnlocked', get = 'IsLocked', guiHidden = true },
        u = { type = 'toggle', name = 'Lock', desc = 'Unlock the QuickMark bar.', set = 'SetUnlocked', get = 'IsLocked', guiHidden = true },

        -- Hide
        hide_gui = { type = 'toggle', name = 'Hide', desc = 'Hide the QuickMark bar.', set = 'ToggleHidden', get = 'IsHidden', cmdHidden = true, order = 2 },
        hide = { type = 'toggle', name = 'Hide', desc = 'Hide the QuickMark bar.', set = 'SetHidden', get = 'IsHidden', guiHidden = true },
        h = { type = 'toggle', name = 'Hide', desc = 'Hide the QuickMark bar.', set = 'SetHidden', get = 'IsHidden', guiHidden = true },

        -- Show
        show = { type = 'toggle', name = 'Show', desc = 'Show the QuickMark bar.', set = 'SetShown', get = 'IsShown', guiHidden = true },
        s = { type = 'toggle', name = 'Show', desc = 'Show the QuickMark bar.', set = 'SetShown', get = 'IsShown', guiHidden = true },

        -------------------------------------------------------------------------
        -- APPEARANCE
        -------------------------------------------------------------------------
        appearance_header = { type = 'header', name = 'Appearance', order = 10 },

        -- Border
        border = { type = 'select', name = 'Border', desc = 'Set the border of the QuickMark bar.', style = 'dropdown', set = 'SetBorder', get = 'GetBorder', values = EDGE_FILES, cmdHidden = true, order = 12 },

        -- Background color
        background_color = { type = 'color', name = 'Background Color', desc = 'Set the color of the background of the QuickMark bar.', get = 'GetBackgroundColor', set = 'SetBackgroundColor', hasAlpha = true, cmdHidden = true, order = 11 },

        -------------------------------------------------------------------------
        -- APPEARANCE
        -------------------------------------------------------------------------
        size_and_orientation_header = { type = 'header', name = 'Size and Orientation', order = 20 },

        -- Flip
        flip = { type = 'toggle', name = 'Flip', desc = 'Invert the QuickMark bar orientation.', set = 'Flip', get = 'GetHorizontal', guiHidden = true },
        f = { type = 'toggle', name = 'Flip', desc = 'Invert the QuickMark bar orientation.', set = 'Flip', get = 'GetHorizontal', guiHidden = true },

        -- Horizontal
        horizontal_gui = { type = 'toggle', name = 'Horizontal', desc = 'Display the QuickMark bar horizontally.', set = 'Flip', get = 'GetHorizontal', cmdHidden = true },
        horizontal = { type = 'toggle', name = 'Horizontal', desc = 'Display the QuickMark bar horizontally.', set = 'SetHorizontal', get = 'GetHorizontal', guiHidden = true },
        hor = { type = 'toggle', name = 'Horizontal', desc = 'Display the QuickMark bar horizontally.', set = 'SetHorizontal', get = 'GetHorizontal', guiHidden = true },

        -- Vertical
        vertical = { type = 'toggle', name = 'Vertical', desc = 'Display the QuickMark bar vertically.', set = 'SetVertical', get = 'GetVertical', guiHidden = true },
        vert = { type = 'toggle', name = 'Vertical', desc = 'Display the QuickMark bar vertically.', set = 'SetVertical', get = 'GetVertical', guiHidden = true },

        -- Toggle
        toggle = { type = 'toggle', name = 'Toggle', desc = 'Toggle the display of the QuickMark bar.', set = 'ToggleHidden', get = 'IsHidden', guiHidden = true },
        t = { type = 'toggle', name = 'Toggle', desc = 'Toggle the display of the QuickMark bar.', set = 'ToggleHidden', get = 'IsHidden', guiHidden = true },

        -- Scale
        scale = { type = 'range', name = 'Scale', desc = 'Scale controls the size of the QuickMark bar.', set = 'SetScale', get = 'GetScale', min = 0.1, max = 5.0, cmdHidden = true },
    },
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
AceConfigDialogue:AddToBlizOptions("QuickMark", "QuickMark")
AceConfig:RegisterOptionsTable("QuickMark", OPTIONS, { "quickmark", "qm" })

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