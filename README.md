# QuickMark

A lightweight World of Warcraft addon that provides a convenient, draggable interface for quickly marking enemy targets with raid icons.

## Features

- **Quick Access Bar**: Floating bar with all 8 raid target icons (Star, Circle, Diamond, Triangle, Moon, Square, Cross, Skull)
- **One-Click Marking**: Click an icon to mark your current target; click again to remove the mark
- **Flexible Layout**: Toggle between horizontal and vertical orientations
- **Fully Customizable**:
  - Adjustable scale (10% - 500%)
  - Multiple border styles (Classic, Slick, Wood, Hefty, Graphite, or None)
  - Configurable background color and opacity
  - Lock/unlock to prevent accidental movement
  - Show/hide as needed
- **Position Memory**: Remembers your bar position per character
- **Blizzard Settings Integration**: Full settings panel accessible via ESC menu

## Installation

### Manual Installation

1. Download or clone this repository
2. Copy the `qm` folder to your World of Warcraft AddOns directory:
   - Windows: `C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\`
   - Mac: `/Applications/World of Warcraft/_retail_/Interface/AddOns/`
3. Rename the folder from `qm` to `QuickMark`
4. Restart World of Warcraft or type `/reload` in-game

## Usage

### Slash Commands

QuickMark supports the following slash commands (use `/qm` or `/quickmark`):

```
/qm                  - Open settings panel
/qm lock (or l)      - Lock the bar in place
/qm unlock (or u)    - Unlock the bar for repositioning
/qm show (or s)      - Show the bar
/qm hide (or h)      - Hide the bar
/qm toggle (or t)    - Toggle visibility
/qm flip (or f)      - Flip between horizontal and vertical layouts
/qm horizontal (hor) - Set horizontal layout
/qm vertical (vert)  - Set vertical layout
```

### Settings Panel

Access the full settings panel via:
- Type `/qm` or `/quickmark`
- Press **ESC → Options → AddOns → QuickMark**

Available settings:
- **Lock**: Prevent the bar from being moved
- **Hide**: Toggle visibility
- **Horizontal**: Switch between horizontal and vertical orientation
- **Scale**: Adjust size from 10% to 500%
- **Border**: Choose from multiple border styles

### Marking Targets

1. Target an enemy or player
2. Click any raid icon on the QuickMark bar
3. Click the same icon again to remove the mark

## Development

### Project Structure

```
QuickMark/
├── QuickMark.lua       # Main addon code
├── QuickMark.toc       # Addon metadata
├── embeds.xml          # Library includes
├── LICENSE.txt         # Apache 2.0 License
├── README.md           # This file
├── CLAUDE.md           # Development guidelines for AI assistants
├── CHANGES.txt         # Version history
├── libs/               # Bundled library dependencies
│   ├── Ace3/           # Ace3 addon framework
│   ├── LibStub/        # Library stub loader
│   └── CallbackHandler/
└── widgets/            # Custom UI widgets
    └── QuickMarkFrame.lua
```

### Dependencies

QuickMark uses the following libraries (bundled in `libs/`):
- **Ace3**: Addon framework providing AceAddon, AceConsole, AceGUI, AceConfig, and AceDB
- **LibStub**: Library management
- **CallbackHandler**: Event callback system

All dependencies are included in the repository. No external build process or package manager is required.

### Building

No build process is needed. The addon is ready to use as-is. Simply copy the folder to your AddOns directory.

### Contributing

When contributing to QuickMark:

1. Test changes in-game with `/reload` to reload the UI
2. Check for Lua errors using `/console scriptErrors 1`
3. Follow the existing code style and patterns
4. Ensure settings persist across `/reload` and game restarts
5. See `CLAUDE.md` for additional development guidelines

### WoW API Reference

When working with World of Warcraft API functions, refer to:
- **Primary**: https://warcraft.wiki.gg/wiki/World_of_Warcraft_API
- **Legacy**: https://wowpedia.fandom.com/wiki/World_of_Warcraft_API

## License

Licensed under the Apache License 2.0. See [LICENSE.txt](LICENSE.txt) for details.

## Credits

QuickMark uses the Ace3 framework, developed by the Ace3 team.
