# Claude Development Guide for QuickMark

This document provides guidelines for AI assistants (like Claude) when working on the QuickMark World of Warcraft addon.

## Project Overview

**QuickMark** is a World of Warcraft addon that provides a draggable interface for quickly marking targets with raid icons. It uses native WoW APIs with no external dependencies.

### Key Technologies
- **Language**: Lua 5.1 (WoW's embedded Lua version)
- **UI System**: Native WoW Frame API and Blizzard Settings API
- **Target Version**: World of Warcraft Retail (The War Within / Midnight)

## API Reference Sources

When implementing or modifying features that use WoW API functions, ALWAYS reference:

1. **Primary Reference**: https://warcraft.wiki.gg/wiki/World_of_Warcraft_API
2. **Legacy Reference**: https://wowpedia.fandom.com/wiki/World_of_Warcraft_API

**IMPORTANT**: Do NOT assume API functions exist without verification. The WoW API changes between expansions. Always check the wiki before using an API function, especially for:
- Settings/Options APIs
- UI widget creation
- Color picker implementations
- Frame manipulation

## Architecture

### File Structure

```
QuickMark/
├── QuickMark.lua           # Main addon logic
│   ├── Frame creation (native WoW Frame API)
│   ├── Slash command handlers
│   ├── Settings management (Blizzard Settings API)
│   └── Saved variables management
├── QuickMark.toc           # Addon metadata
├── CLAUDE.md               # Development guidelines for AI assistants
├── CHANGES.txt             # Version history
├── LICENSE.txt             # Apache 2.0 License
└── README.md               # Project readme
```

### Key Components

1. **QuickMark.lua** - Main (and only) addon file containing:
   - Frame creation and layout management using native WoW Frame API
   - Slash command processing
   - Settings panel registration (Blizzard Settings API)
   - Saved variables for character-specific storage (`QuickMarkDB`)
   - Position, scale, border, and color management

## Development Guidelines

### Code Style

1. **Use the `QuickMark` table consistently**: Methods are defined on the `QuickMark` table using colon syntax and reference `self`
   ```lua
   function QuickMark:Lock()
       frame:SetMovable(false)
       frame:EnableMouse(false)
       db.locked = true
       Debug("Locked")
   end
   ```

2. **Use module-level locals**: The `frame`, `db`, and helper functions like `Debug()` and `Print()` are local to the file
   ```lua
   local frame -- Main UI frame
   local db    -- Saved variables reference
   ```

3. **Use constants**: Define magic values at the top of the file
   ```lua
   local DEFAULT_SCALE = 1.0
   local DEFAULT_R = 0
   local DEFAULT_G = 0
   local DEFAULT_B = 0
   local DEFAULT_A = 0.3
   ```

### Settings Implementation

When adding new settings to the Blizzard Settings panel:

1. **Register the setting**: Use `Settings.RegisterAddOnSetting()`
2. **Set up callbacks**: Use `SetValueChangedCallback()` to handle changes
3. **Create the UI element**: Use `Settings.CreateSlider()`, `Settings.CreateCheckbox()`, or `Settings.CreateDropdown()`

**Example - Adding a Checkbox**:
```lua
do
    local variable = "locked"
    local name = "Lock"
    local tooltip = "Lock the QuickMark bar in place."
    local defaultValue = false

    local setting = Settings.RegisterAddOnSetting(
        category,
        "QuickMark_Lock",
        variable,
        db,
        type(defaultValue),
        name,
        defaultValue
    )

    setting:SetValueChangedCallback(function(_, value)
        if value then
            self:Lock()
        else
            self:Unlock()
        end
    end)

    Settings.CreateCheckbox(category, setting, tooltip)
end
```

**Example - Adding a Slider**:
```lua
do
    local variable = "scale"
    local name = "Scale"
    local tooltip = "Scale controls the size of the QuickMark bar."
    local defaultValue = 1.0
    local minValue = 0.1
    local maxValue = 5.0
    local step = 0.1

    local setting = Settings.RegisterAddOnSetting(
        category,
        "QuickMark_Scale",
        variable,
        db,
        type(defaultValue),
        name,
        defaultValue
    )

    setting:SetValueChangedCallback(function(_, value)
        self:Scale(value)
    end)

    local options = Settings.CreateSliderOptions(minValue, maxValue, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
        return string.format("%.0f%%", value * 100)
    end)

    Settings.CreateSlider(category, setting, options, tooltip)
end
```

### Saved Variables

QuickMark uses WoW's native `SavedVariablesPerCharacter` (declared in the `.toc` file) for persistent storage:

```lua
-- Initialize saved variables
QuickMarkDB = QuickMarkDB or {}
db = QuickMarkDB

-- Access settings directly
db.locked
db.scale
db.horizontal
db.bg_color_r
-- etc.
```

**Character-specific settings** stored in `db`:
- `point`, `relativePoint`, `xOfs`, `yOfs` - Frame position
- `locked` - Whether the frame is locked
- `hidden` - Whether the frame is hidden
- `horizontal` - Layout orientation
- `scale` - Frame scale (0.1 to 5.0)
- `edge_file` - Border texture path
- `bg_color_r`, `bg_color_g`, `bg_color_b`, `bg_color_a` - Background RGBA

### Common Pitfalls

#### 1. Non-existent API Functions

**Problem**: Assuming an API function exists (e.g., `Settings.CreateColorPicker()`)

**Solution**: Always verify API functions on https://warcraft.wiki.gg/wiki/World_of_Warcraft_API before using them

#### 2. Adding External Dependencies

**Problem**: Introducing Ace3 or other library dependencies

**Solution**: QuickMark was intentionally rewritten to use only native WoW APIs. Do not add external library dependencies.

#### 3. Not Testing Settings Persistence

**Problem**: Settings don't persist after `/reload` or logout

**Solution**: Always test with:
1. Change a setting
2. `/reload`
3. Verify the setting persisted
4. Log out and back in
5. Verify again

## Testing Checklist

When implementing new features or fixing bugs:

- [ ] Test in-game with `/reload` to reload UI
- [ ] Enable error display: `/console scriptErrors 1`
- [ ] Test all slash commands
- [ ] Test settings panel changes persist after `/reload`
- [ ] Test settings persist after logout/login
- [ ] Verify no Lua errors in chat
- [ ] Test with frame locked and unlocked
- [ ] Test with frame hidden and shown
- [ ] Test both horizontal and vertical layouts
- [ ] Verify tooltips are helpful and accurate

## Common Tasks

### Adding a New Slash Command

1. Add to `SLASH_COMMANDS` table (if using table-driven approach)
2. Add handler method to QuickMark
3. Test with `/qm <command>`

### Adding a New Setting

1. Add default value constant at top of file
2. Add to `SetupSettings()` function
3. Add getter/setter methods if needed
4. Add to `LoadSettings()` for initialization
5. Update README with new setting

### Modifying the Frame

1. Edit `CreateQuickMarkFrame()` in `QuickMark.lua` for frame/icon changes
2. Edit layout functions (`SetHorizontalLayout`/`SetVerticalLayout`) for orientation changes
3. Test with different scales and orientations

## References

- **WoW API**: https://warcraft.wiki.gg/wiki/World_of_Warcraft_API
- **Blizzard Settings API**: https://warcraft.wiki.gg/wiki/Patch_10.0.0/API_changes#Settings
- **UI Widgets**: https://warcraft.wiki.gg/wiki/Using_UIObjects

## Version History

See [CHANGES.txt](CHANGES.txt) for version history and changelog.

## Questions?

When in doubt:
1. Check the WoW API wiki first
2. Review existing code patterns in QuickMark.lua
3. Test changes in-game before committing
4. Keep changes minimal and focused

Remember: The WoW API changes frequently between expansions. Always verify API functions exist before using them.
