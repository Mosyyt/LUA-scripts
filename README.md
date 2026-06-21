<div align="center">

# LUA Scripts

**A collection of Roblox Lua executor scripts, organized for use with common exploit executors.**

![Language](https://img.shields.io/badge/Language-Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Roblox-red?style=for-the-badge)
![Type](https://img.shields.io/badge/Type-Executor%20Scripts-orange?style=for-the-badge)

</div>

---

## What is this?

A personal library of Lua scripts for Roblox, organized into two areas: standalone scripts at the root for quick use, and a modular collection with scripts grouped by category under `scripts-collection/`.

---

## Structure

```
LUA-scripts/
├── *.lua                        # 15 standalone scripts, ready to inject
└── scripts-collection/
    ├── Games/                   # Game-specific scripts
    ├── Libraries/               # Shared utility modules
    ├── Misc/                    # Miscellaneous scripts
    └── Other Stuff/             # Additional scripts
```

---

## Standalone Scripts (Root)

| File | Description |
|---|---|
| `aimbot.lua` | Aim assistance |
| `aimbot2.lua` | Alternate aim configuration |
| `admin.lua` | Admin-style command interface |
| `anti-afk.lua` | Prevents AFK kick |
| `esp.lua` | ESP / wallhack overlay |
| `fly.lua` | Flight script |
| `grab-knife-v3.lua` | Grab knife tool |
| `inf-jump.lua` | Infinite jump |
| `kill-aura.lua` | Kill aura combat script |
| `noclip.lua` | Noclip / walk through walls |
| `op-gui.lua` | OP GUI loader |
| `script-hub.lua` | Script hub menu |
| `self-damage.lua` | Self damage utility |
| `speed.lua` | Speed modifier |
| `tp-all-items.lua` | Teleport all items |

---

## Scripts Collection

Organized modular scripts inside `scripts-collection/`. Grouped into `Games/`, `Libraries/`, `Misc/`, and `Other Stuff/`.

---

## Usage

Inject any `.lua` file using your preferred Roblox executor (e.g. Synapse X, Krnl, Fluxus). No dependencies required for standalone scripts.
