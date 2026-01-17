# EnowLib Build

This repository contains the built and obfuscated versions of EnowLib.

## Files

- `enowlib.lua` - Non-obfuscated build
- `enowlib.obfuscated.lua` - Obfuscated build (recommended for production)

## Usage

```lua
local EnowLib = loadstring(game:HttpGet("YOUR_RAW_URL_HERE"))()

local window = EnowLib:CreateWindow({
    Title = "My Script",
    Size = UDim2.new(0, 500, 0, 400)
})
```

## Version

v2.0.0

## License

MIT
