--------------------------------------------------------------------------------
-- QuickMark
-- Author:  stphung
-- Email:   stphung@gmail.com
--------------------------------------------------------------------------------

-- Constants -------------------------------------------------------------------
local name = "QuickMark";
local version = "2.2";
local SET_RAID_TARGET_NO_MARK = 0;
local DEFAULT_IS_VERTICAL = false;

--------------------------------------------------------------------------------
-- Utility print function.
-- Returns void.
--
function QuickMark_Print(arg)
    DEFAULT_CHAT_FRAME:AddMessage(arg);
end

--------------------------------------------------------------------------------
-- ENTRY POINT
-- Called in QuickMarkForm.xml to bootstrap this addon.
-- Returns void.
--
function QuickMark_OnLoad()
    this:RegisterEvent('VARIABLES_LOADED');
    QuickMark_AddSlashCommandHandler();
    QuickMark_Print(name .. " " .. version 
                        .. " loaded.  Use /qm to display available commands.");
end

--------------------------------------------------------------------------------
-- Listener for the VARIABLES_LOADED event.
-- Returns void.
--
function QuickMark_OnEvent(event)
    if ( event == 'VARIABLES_LOADED' ) then
        if ( not QuickMark_isVertical ) then 
            QuickMark_isVertical = DEFAULT_IS_VERTICAL;
        end
    end
end

--------------------------------------------------------------------------------
-- Adds the slash commands for invoking QuickMark.
-- Returns void.
--
function QuickMark_AddSlashCommandHandler()
    SlashCmdList["QUICKMARK"] = function ( msg )
    if ( msg == "" ) then
        QuickMark_Print("Use /qm <command>");
        QuickMark_Print("   <command>: show, hide, flip, version");
    elseif ( msg == "show" ) then
        QuickMark_ShowForm();
    elseif ( msg == "hide" ) then
        QuickMark_HideForm();
    elseif ( msg == "toggle" ) then
        QuickMark_ToggleForm();
    elseif ( msg == "flip" ) then
        QuickMark_FlipForm();
    elseif ( msg == "version" ) then
        QuickMark_Print("You are currently using " .. version .. " " .. version .. ".");
    end
end
    SLASH_QUICKMARK1 = "/quickmark";
    SLASH_QUICKMARK2 = "/qm";
end

function QuickMark_MarkCurrentTarget ( icon )
    if ( GetRaidTargetIndex("target") == icon ) then
        SetRaidTarget("target", SET_RAID_TARGET_NO_MARK);
    else
        SetRaidTarget("target", icon);
    end
end

--------------------------------------------------------------------------------
-- Gets the current form.
-- Returns the form
--
local function GetForm()
    if ( QuickMark_isVertical ) then
        return QuickMarkVerticalForm
    else return QuickMarkHorizontalForm
    end
end

--------------------------------------------------------------------------------
-- Flips the form from horizontal to vertical or vice versa.
-- Returns void.
--
function QuickMark_FlipForm()
    if ( GetForm():IsShown() ) then
        QuickMark_HideForm(QuickMark_isVertical);
        QuickMark_isVertical = not QuickMark_isVertical;
        QuickMark_ShowForm(QuickMark_isVertical);
    end
end

--------------------------------------------------------------------------------
-- Toggles the display of the form on and off.
-- Returns void.
--
function QuickMark_ToggleForm()
    if ( GetForm():IsShown() ) then 
        QuickMark_HideForm(isVertical);
    else 
        QuickMark_ShowForm(isVertical);
    end
end

--------------------------------------------------------------------------------
-- Displays the form.
-- Returns void.
--
function QuickMark_ShowForm()
    GetForm():Show();
end

--------------------------------------------------------------------------------
-- Hides the frame.
-- Returns void.
--
function QuickMark_HideForm()
    GetForm():Hide();
end