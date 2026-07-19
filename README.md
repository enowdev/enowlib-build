# EnowLib Build

Obfuscated production artifacts for [EnowLib](https://github.com/enowdev/enowlib), a modern
minimalist UI library for Roblox.

This repository contains **generated files only**. Do not edit anything here by hand -- every
file is overwritten by the next build. Source code, issues and pull requests belong in the
[main repository](https://github.com/enowdev/enowlib).

## Files

| File | Description |
|------|-------------|
| `enowlib.lua` | The library itself. Contains all components and the theme system. |
| `managers/interfacemanager.lua` | Theme switching, UI visibility, keybind, notification control |
| `managers/savemanager.lua` | Configuration save/load with auto-load support |
| `managers/betterload.lua` | Batched tab loading to prevent startup freeze |
| `managers/performancemanager.lua` | FPS, memory and ping monitoring |
| `managers/floatingbuttonmanager.lua` | Draggable floating toggle button |

Managers are separate files. Load only the ones your script actually uses -- each one you skip
is bandwidth and parse time you do not pay for.

## Usage

### Minimal

```lua
local EnowLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/enowdev/enowlib-build/main/enowlib.lua"))()

local Window = EnowLib:CreateWindow({
    Title = "My Script"
})

local MainCategory = Window:AddCategory({
    Title = "Main",
    Icon = "rbxassetid://10723387563",
    Expanded = true
})

MainCategory:AddItem({
    Title = "Features.lua",
    Icon = "rbxassetid://10723356507",
    Content = function(window)
        window:AddToggle({
            Text = "Enable Feature",
            Default = false,
            Callback = function(value)
                print("Feature:", value)
            end
        })
    end
})
```

Note that the parameter passed to `Content` is the **tab**, not the window. Naming it `window`
is the established convention in the examples, but it is a tab instance.

### With managers

```lua
local BASE = "https://raw.githubusercontent.com/enowdev/enowlib-build/main/"

local EnowLib = loadstring(game:HttpGet(BASE .. "enowlib.lua"))()
local InterfaceManager = loadstring(game:HttpGet(BASE .. "managers/interfacemanager.lua"))()
local SaveManager = loadstring(game:HttpGet(BASE .. "managers/savemanager.lua"))()

local Window = EnowLib:CreateWindow({ Title = "My Script" })

InterfaceManager:Initialize(Window)
SaveManager:Initialize(Window)

Window.InterfaceManager = InterfaceManager
Window.SaveManager = SaveManager
```

Managers must be initialized with the window **after** it is created. The main library does not
initialize them for you -- that is deliberate, so scripts that do not need a manager never load it.

### Persisting component state

Register a component with SaveManager to have its value written to the config file:

```lua
local toggle = window:AddToggle({ Text = "Enable Feature", Default = false })
SaveManager:RegisterComponent("enable_feature", toggle)

SaveManager:Save("my_config")
SaveManager:Load("my_config")
SaveManager:SetAutoLoadConfig("my_config")  -- restore on next startup
```

Register **after** constructing the component. Registration wraps the component's callback, so a
component registered twice will fire its callback once per registration.

### Large scripts

Building many tabs at once blocks the frame. `Content` functions run eagerly when the item is
added, so BetterLoad exists to spread that work out:

```lua
local BetterLoad = loadstring(game:HttpGet(BASE .. "managers/betterload.lua"))()

BetterLoad:Initialize(Window)
BetterLoad:WaitForGameLoad()

BetterLoad:QueueTab(MainCategory, {
    Title = "Heavy.lua",
    Icon = "rbxassetid://10723356507",
    Content = function(window) end
})

BetterLoad:ProcessQueue()
BetterLoad:AutoLoadConfig(SaveManager)
```

### Cleaning up

`Window:Destroy()` tears the UI down completely -- it disconnects input handlers, removes the
blur effect and destroys the interface. Use it when your script exits or reloads, so that
re-running it does not stack leftover connections:

```lua
Window:Destroy()
```

`Window:Toggle()` only hides and shows the UI; it is not a teardown.

### Debug output

The library is silent by default. Enable its internal logging when diagnosing a problem:

```lua
EnowLib:SetDebugMode(true)
```

## Pinning a version

The URLs above track `main` and change whenever a new build is published. To pin a script to a
build that you have tested, reference a commit SHA instead of a branch:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/enowdev/enowlib-build/<commit-sha>/enowlib.lua"))()
```

Raw GitHub responses are cached for a few minutes, so a freshly pushed build may take a moment to
become visible.

## Requirements

An executor with `loadstring` and `game:HttpGet`. Config persistence additionally requires the
file IO globals (`isfolder`, `makefolder`, `readfile`, `writefile`, `listfiles`); SaveManager
degrades gracefully when they are unavailable, but configs will not persist between sessions.

Configs are written to the `EnowLib/` folder in your executor's workspace directory.

## Documentation

Full API reference, component list and guides are in the main repository:

- [README](https://github.com/enowdev/enowlib#readme)
- [API reference](https://github.com/enowdev/enowlib/blob/main/API.md)
- [Quick start](https://github.com/enowdev/enowlib/blob/main/QUICKSTART.md)

## Version

v2.0.0

## License

MIT -- see the [main repository](https://github.com/enowdev/enowlib/blob/main/LICENSE).
