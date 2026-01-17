# EnowLib Build

This repository contains the obfuscated build of EnowLib.

## Files

- `enowlib.lua` - Obfuscated production build

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
