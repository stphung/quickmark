local QuickMark = LibStub("AceAddon-3.0"):NewAddon("QuickMark", "AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")

--------------------------------------------------------------------------------
-- QUICKMARK FRAME CREATION FUNCTION
--------------------------------------------------------------------------------
function QuickMark:CreateQuickMarkFrame()
   local qmFrame = AceGUI:Create("QuickMarkFrame")

   for i=1, 8 do
      local targetIcon = AceGUI:Create("Icon")
      targetIcon:SetImage("INTERFACE/TARGETINGFRAME/UI-RaidTargetingIcon_" .. i)
      targetIcon:SetWidth(20)
      targetIcon:SetHeight(20)
      targetIcon:SetImageSize(20,20)
      targetIcon:SetCallback("OnClick", function()
				       if GetRaidTargetIndex("target") ~= i then
					  SetRaidTarget("target", i)
				       else
					  SetRaidTarget("target", 0)
				       end
				    end)
      qmFrame:AddChild(targetIcon)
   end

   local closeIcon = AceGUI:Create("Icon")
   closeIcon:SetImage("INTERFACE/BUTTONS/CancelButton-Up")
   closeIcon:SetWidth(20)
   closeIcon:SetHeight(20)
   closeIcon:SetImageSize(20,20)
   closeIcon:SetCallback("OnClick", function() QuickMark:Hide() end)
   qmFrame:AddChild(closeIcon)

   return qmFrame
end

local QM_FRAME = QuickMark:CreateQuickMarkFrame()
local DEBUG = false

--------------------------------------------------------------------------------
-- COMMAND FUNCTIONS
--------------------------------------------------------------------------------
function QuickMark:SetHorizontalLayout()
   QM_FRAME:SetWidth(215)
   QM_FRAME:SetHeight(48)
   QM_FRAME:SetLayout("Flow")
   self.db.char.horizontal = true
   QuickMark:Print("Horizontal Layout")
end

function QuickMark:SetVerticalLayout()
   QM_FRAME:SetWidth(45)
   QM_FRAME:SetHeight(280)
   QM_FRAME:SetLayout("List")
   self.db.char.horizontal = false
   QuickMark:Print("Vertical Layout")
end

function QuickMark:Lock()
   QM_FRAME:Lock()
   self.db.char.locked = true
   QuickMark:Print("Locked")
end

function QuickMark:Unlock()
   QM_FRAME:Unlock()
   self.db.char.locked = false
   QuickMark:Print("Unlocked")
end

function QuickMark:SetPosition(point, relativePoint, x, y)
   QM_FRAME:ClearAllPoints()
   QM_FRAME:SetPoint(point, UIParent, relativePoint, x, y)
   if DEBUG then
      QuickMark:Print("Positioning at " .. x .. ", " .. y .. " relative to " .. relativePoint)
   end
end

function QuickMark:SetScale(scale)
   QM_FRAME.frame:SetScale(scale)
   self.db.char.scale = scale
   QuickMark:Print("Scale set to " .. scale*100 .. "%")
end

function QuickMark:Show()
   QM_FRAME:Show()
   self.db.char.hidden = false
   QuickMark:Print("Shown")
end

function QuickMark:Hide()
   QM_FRAME:Hide()
   self.db.char.hidden = true
   QuickMark:Print("Hidden")
end

function QuickMark:Toggle()
   if self.db.char.hidden then
      QuickMark:Show()
   else
      QuickMark:Hide()
   end
end

function QuickMark:AutoToggle()
	if AutoToggle == true then
	AutoToggle=false
	QuickMark:Print("AutoToggle off")
	else
	AutoToggle=true
	QuickMark:Print("AutoToggle on")
	end
end

-- DEPRECATED: Only here for those using the 2.0 API, use QuickMark:Toggle() instead.
function QuickMark_ToggleForm()
   QuickMark:Toggle()
end

--------------------------------------------------------------------------------
-- SLASH COMMAND PROCESSOR
--------------------------------------------------------------------------------
function QuickMark:SlashProcessor(input)
   if string.find(input, "scale") == 1 then
      local scale = string.match(input, "%d+")
      if scale ~= nil then
	 QuickMark:SetScale(scale/100.0)
      else
	 QuickMark:Print("Bad input to scale")
      end
   elseif input == "at" or input == "autotoggle" then
      QuickMark:AutoToggle()
   elseif input == "s" or input == "show" then
      QuickMark:Show()
   elseif input == "h" or input == "hide" then
      QuickMark:Hide()
   elseif input == "t" or input == "toggle" then
      QuickMark:Toggle()
   elseif input == "vert" or input == "vertical" then
      QuickMark:SetVerticalLayout()
   elseif input == "hor" or input == "horizontal" then
      QuickMark:SetHorizontalLayout()
   elseif input == "f" or input == "flip" then
      if self.db.char.horizontal then
	 QuickMark:SetVerticalLayout()
      else
	 QuickMark:SetHorizontalLayout()
      end
   elseif input == "l" or input == "lock" then
      QuickMark:Lock()
   elseif input == "u" or input == "unlock" then
      QuickMark:Unlock()
   else
      QuickMark:Print("usage: /qm [s, show | h, hide | t toggle | hor horizontal | vert vertical | f flip | l lock | u unlock | at autotoggle | scale n.m]")
      QuickMark:Print("    at, autotoggle     auto toggle the user interface depending on if you are in a party/raid")
      QuickMark:Print("    s, show            shows the user interface")
      QuickMark:Print("    h, hide            hides the user interface")
      QuickMark:Print("    t, toggle          shows or hides the user interface depending on if it was hidden or shown respectively")
      QuickMark:Print("    hor, horizontal    sets the layout to be horizontal")
      QuickMark:Print("    vert, vertical     sets the layout to be vertical")
      QuickMark:Print("    f, flip            inverts the layout")
      QuickMark:Print("    l, lock            locks the user interface")
      QuickMark:Print("    u, unlock          unlocks the user interface")
      QuickMark:Print("    scale <percentage> scales the user interface to the input percentage.  The default scale is set to 100")
   end
end

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
      QuickMark:SetScale(self.db.char.scale)
   else
      QuickMark:SetScale(1.0)
   end
end

--------------------------------------------------------------------------------
-- INITIALIZATION FUNCTION
--------------------------------------------------------------------------------
function QuickMark:OnInitialize()
   QuickMark:Print("Initializing settings")

   self.db = LibStub("AceDB-3.0"):New("QuickMarkDB")
   QuickMark:RegisterChatCommand("qm", "SlashProcessor")
   QuickMark:RegisterChatCommand("quickmark", "SlashProcessor")

   -- XXX: This might have performance problems but it is safe in terms of data consistency.
   QM_FRAME.frame:SetScript("OnLeave", function()
					point, relativeTo, relativePoint, xOfs, yOfs = QM_FRAME.frame:GetPoint()
					if relativeTo == nil then
					   self.db.char.point = point
					   self.db.char.relativePoint = relativePoint
					   self.db.char.xOfs = xOfs
					   self.db.char.yOfs = yOfs
					   if DEBUG then
					      QuickMark:Print("Positioning at " .. point .. " at "  .. xOfs .. ", " .. yOfs .. " relative to " .. relativePoint)
					   end
					end
				     end)

   QuickMark:LoadSettings()
end

function QuickMark:OnEnable()
   QuickMark:Print("Enabled")
end

function QuickMark:OnDisable()
   QuickMark:Print("Disabled")
end


local frame = CreateFrame("Frame")

function frame:OnUpdate()
if AutoToggle == true then
	numMembers = GetRealNumPartyMembers()
	if numMembers > 0 then
			QM_FRAME:Show()
			else
			QM_FRAME:Hide()
		end
	end
end
frame:SetScript("OnUpdate", frame.OnUpdate)

