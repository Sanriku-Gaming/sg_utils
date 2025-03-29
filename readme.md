# sg_utils

A framework agnostic utilities resource for FiveM servers. Provides a consistent API across different frameworks (QBCore, QBX) and makes development of resources easier and more consistent.

## Features

- Framework abstraction layer (QB, QBX support)
- Easy to use utility functions
- Comprehensive utility categories:
  - Player utilities
  - Vehicle utilities
  - Inventory utilities
  - Economy utilities
  - UI utilities (notifications, dispatch, target)
  - World utilities
- Automatic version checking system

## Installation

1. Download the latest release from [GitHub](https://github.com/Sanriku-Gaming/sg_utils/releases)
2. Extract the `sg_utils` folder to your server's resources directory
3. Add `ensure sg_utils` to your server.cfg (make sure it loads before any resources that depend on it)
4. Configure the `config.lua` file to match your server's framework setup

## Configuration

```lua
Config.Framework = {
    core        = 'qb',                                 -- 'qb' or 'qbx'
    inventory   = 'qb',                                 -- 'qb', 'ps', or 'ox'
    target      = 'qb',                                 -- 'qb' or 'ox'
    notify      = 'qb',                                 -- 'qb', 'okok', or 'ox'
    banking     = 'qb',                                 -- 'qb', 'qs', or 'renewed'
    dispatch    = 'qb',                                 -- 'qb' (or qbx), 'cd', 'ps'
    fuel        = 'LegacyFuel',                         -- 'LegacyFuel', 'ps-fuel', 'ox_fuel', etc.
}
```

## Basic Usage

```lua
-- At the top of your file
local Utils = exports['sg_utils']:GetUtils()

-- Then use any utility directly
RegisterCommand('testutil', function()
    -- Player utilities
    local playerName = Utils.Player.getName()

    -- Vehicle utilities
    local coords = GetEntityCoords(PlayerPedId())
    local vehicle = Utils.Vehicle.spawn('adder', vector4(coords.x, coords.y, coords.z, 0.0))

    -- UI utilities
    Utils.UI.sendNotify('Hello ' .. playerName, 'success')
end, false)
```

## Available Utilities

### Client-Side

- `Utils.Player` - Player-related utilities (get data, get job, get name)
- `Utils.Inventory` - Inventory-related utilities (check items)
- `Utils.Vehicle` - Vehicle-related utilities (spawn, modify, get info)
- `Utils.Ped` - Ped-related utilities (spawn, scenario)
- `Utils.UI` - UI and interaction utilities (notifications, target, dispatch)
- `Utils.World` - World and environment utilities (street names, NPC detection, area clearing)

### Server-Side

- `Utils.Player` - Player-related utilities (get player data, get player by citizen ID, etc.)
- `Utils.Inventory` - Inventory-related utilities (add/remove items, check item data, etc.)
- `Utils.Economy` - Money and banking utilities (add/remove money, get balance, etc.)
- `Utils.UI` - UI and notification utilities

## Versioning

This project uses [Semantic Versioning](https://semver.org/). The current version is 1.0.0.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Credits

- [Nicky of SG Scripts](https://forum.cfx.re/u/Sanriku)
- [SG Scripts Discord](https://discord.gg/uEDNgAwhey)
- [SG Scripts Github](https://github.com/Sanriku-Gaming)
- [SG Scripts Tebex](https://sanriku-gaming.tebex.io/)