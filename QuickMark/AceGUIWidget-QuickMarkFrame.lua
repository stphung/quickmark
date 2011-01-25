local AceGUI = LibStub("AceGUI-3.0")

-- Lua APIs
local pairs, assert, type = pairs, assert, type

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: CLOSE

----------------
-- Main Frame --
----------------
--[[
	Events :
		OnClose

]]
do
   local Type = "QuickMarkFrame"
   local Version = 1
   
   local FrameBackdrop = {
      bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", 
      tile = true, tileSize = 32, edgeSize = 32, 
      insets = { left = 8, right = 8, top = 8, bottom = 8 }
   }
   
   local PaneBackdrop  = {
      bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
      edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      tile = true, tileSize = 16, edgeSize = 16,
      insets = { left = 3, right = 3, top = 5, bottom = 3 }
   }
   
   local function frameOnClose(this)
      this.obj:Fire("OnClose")
   end
   
   local function frameOnMouseDown(this)
      AceGUI:ClearFocus()
   end
   
   local function frameOnMouseUp(this)
      local frame = this:GetParent()
      frame:StopMovingOrSizing()
      local self = frame.obj
      local status = self.status or self.localstatus
      status.width = frame:GetWidth()
      status.height = frame:GetHeight()
      status.top = frame:GetTop()
      status.left = frame:GetLeft()
   end
   
   local function Hide(self)
      self.frame:Hide()
   end
   
   local function Show(self)
      self.frame:Show()
   end

   local function Lock(self)
      self.frame:SetScript("OnMouseDown", nil)
   end

   local function Unlock(self)
      self.frame:SetScript("OnMouseDown", function() self.frame:StartMoving() end)
   end
   
   local function OnAcquire(self)
      self.frame:SetParent(UIParent)
      self.frame:SetFrameStrata("MEDIUM")
   end
   
   local function OnRelease(self)
      self.status = nil
      for k in pairs(self.localstatus) do
	 self.localstatus[k] = nil
      end
   end
   
   local function OnWidthSet(self, width)
      local content = self.content
      local contentwidth = width - 34
      if contentwidth < 0 then
	 contentwidth = 0
      end
      content:SetWidth(contentwidth)
      content.width = contentwidth
   end
   
   
   local function OnHeightSet(self, height)
      local content = self.content
      local contentheight = height - 57
      if contentheight < 0 then
	 contentheight = 0
      end
      content:SetHeight(contentheight)
      content.height = contentheight
   end
   
   local function Constructor()
      local frame = CreateFrame("Frame",nil,UIParent)
      local self = {}
      self.type = "Frame"
      
      self.Hide = Hide
      self.Show = Show
      self.Lock = Lock
      self.Unlock = Unlock
      self.OnRelease = OnRelease
      self.OnAcquire = OnAcquire
      self.OnWidthSet = OnWidthSet
      self.OnHeightSet = OnHeightSet
      
      self.localstatus = {}
      
      self.frame = frame
      frame.obj = self
      frame:SetWidth(700)
      frame:SetHeight(500)
      frame:SetPoint("CENTER",UIParent,"CENTER",0,0)
      frame:EnableMouse()
      frame:SetMovable(true)
      frame:SetResizable(false)

      frame:SetClampedToScreen(true)

      frame:SetScript("OnMouseDown", function() frame:StartMoving() end)
      frame:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() end)
      frame:SetScript("OnHide",frameOnClose)
      
      frame:SetBackdrop(FrameBackdrop)
      frame:SetBackdropColor(0,0,0,1)
      
      --Container Support
      local content = CreateFrame("Frame",nil,frame)
      self.content = content
      content.obj = self
      content:SetPoint("TOPLEFT",frame,"TOPLEFT",12,-7)
      content:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-17,40)
      
      AceGUI:RegisterAsContainer(self)
      return self	
   end
   
   AceGUI:RegisterWidgetType(Type,Constructor,Version)
end
