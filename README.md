# Snake.lua

A lightweight Roblox Luau cursor effect that creates a configurable trailing snake following your mouse.

## Preview

<img width="535" height="539" alt="Snake.lua preview" src="https://github.com/user-attachments/assets/75e9de1e-6948-408c-9c8f-e7902ef721d9" />

## Usage

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/zvzt/snake.lua/refs/heads/main/snake.lua"))()
```

## Features

- 40-segment cursor trail
- Smooth movement interpolation
- Onyx-style draggable interface
- Active/Disabled header switch
- HSV color picker with hue slider
- Live RGB inputs
- RGB rainbow mode
- Manual color edits automatically stop rainbow mode
- Header-only minimize/restore behavior
- Rerun cleanup so old connections and trails do not stack
- Screen-edge drag clamping with `-57 / 57` vertical offsets

## Controls

- Use the header switch to enable or disable the trail
- Use the color square, hue bar, or RGB fields to choose a trail color
- Click **RGB** to toggle rainbow mode
- Click **—** to collapse the window to its header
- Click **X** to fully clean up the UI and active connections

## Compatibility

Requires an environment that supports `loadstring` and `game:HttpGet` when using the one-line loader.

## Files

- `snake.lua` — main script
- `README.md` — documentation

## License

MIT — see [LICENSE](LICENSE).
