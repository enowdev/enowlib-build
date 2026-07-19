# EnowLib

Modern, minimalist UI library for Roblox with a Radix-inspired dark design.

This repository hosts the production build. The files here are generated, so do not edit them by
hand -- they are overwritten by the next release.

## Files

| File | Description |
|------|-------------|
| `enowlib.lua` | The library itself. All components and the theme system. |
| `managers/interfacemanager.lua` | Theme switching, UI visibility, keybind, notification control |
| `managers/savemanager.lua` | Configuration save/load with auto-load support |
| `managers/betterload.lua` | Batched tab loading to prevent startup freeze |
| `managers/performancemanager.lua` | FPS, memory and ping monitoring |
| `managers/floatingbuttonmanager.lua` | Draggable floating toggle button |

Managers are separate files. Load only the ones your script uses.

## Quick start

```lua
local EnowLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/enowdev/enowlib-build/refs/heads/main/enowlib.lua"))()

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

The parameter passed to `Content` is the **tab**, not the window. Naming it `window` is the
convention used throughout these examples, but it is a tab instance.

## Complete example

`example.lua` in this repository exercises every component and manager. Run it to see everything
at once:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/enowdev/enowlib-build/refs/heads/main/example.lua"))()
```

## Structure

```
Window
  Category            sidebar folder
    Item              a tab, created with Content
      Section         titled box grouping components
        components
```

`Window:AddCategory` returns a Category, `Category:AddItem` returns an Item backed by a tab, and
`Tab:AddSection` returns a Section. Components can be added to a Tab directly or to a Section.

Note that `Content` runs immediately when the item is added, not lazily on first open. For scripts
with many tabs, use BetterLoad to spread that work across frames.

## Components

Every component is created the same way, and returns the component instance.

### Button

```lua
window:AddButton({
    Text = "Click Me",
    Callback = function() end
})
```

### Toggle

```lua
local toggle = window:AddToggle({
    Text = "Enable Feature",
    Default = false,
    Callback = function(value) end
})
```

### Slider

Handles integer and float ranges; float values are rounded to two decimals.

```lua
local slider = window:AddSlider({
    Text = "Adjust Value",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(value) end
})
```

### TextBox

```lua
local textbox = window:AddTextBox({
    Text = "Enter Text",
    Placeholder = "Type here...",
    Default = "",
    Callback = function(value) end
})
```

### Dropdown

Set `Searchable = true` to add a filter box.

```lua
local dropdown = window:AddDropdown({
    Text = "Select Option",
    Options = {"Option A", "Option B", "Option C"},
    Default = "Option A",
    Searchable = false,
    Callback = function(value) end
})
```

### MultiSelect

The callback receives an array of the selected option strings.

```lua
local multiselect = window:AddMultiSelect({
    Text = "Select Multiple",
    Options = {"Feature 1", "Feature 2", "Feature 3"},
    Default = {"Feature 1"},
    Callback = function(values) end
})
```

### ColorPicker

```lua
local colorpicker = window:AddColorPicker({
    Text = "Choose Color",
    Default = Color3.fromRGB(46, 204, 113),
    Callback = function(color) end
})
```

### Keybind

Takes `Title`, not `Text`.

```lua
local keybind = window:AddKeybind({
    Title = "Set Keybind",
    Default = "None",
    Callback = function(key) end
})
```

### Label, Paragraph, Divider

```lua
window:AddLabel({
    Text = "This is a label",
    Color = Color3.fromRGB(255, 255, 255) -- optional
})

window:AddParagraph({
    Title = "Title",              -- Paragraph takes Title, not Text
    Content = "Longer text that wraps automatically."
})

window:AddDivider()
```

### Section

```lua
local section = window:AddSection({ Title = "Settings" })
section:AddToggle({ Text = "Option" })
section:AddSlider({ Text = "Amount", Min = 0, Max = 10, Default = 5 })
```

## Managers

Initialize a manager with the window **after** the window is created. The library does not do this
for you, so scripts that skip a manager never pay for it.

```lua
local BASE = "https://raw.githubusercontent.com/enowdev/enowlib-build/refs/heads/main/"

local EnowLib = loadstring(game:HttpGet(BASE .. "enowlib.lua"))()
local InterfaceManager = loadstring(game:HttpGet(BASE .. "managers/interfacemanager.lua"))()
local SaveManager = loadstring(game:HttpGet(BASE .. "managers/savemanager.lua"))()

local Window = EnowLib:CreateWindow({ Title = "My Script" })

InterfaceManager:Initialize(Window)
SaveManager:Initialize(Window)

Window.InterfaceManager = InterfaceManager
Window.SaveManager = SaveManager
```

### InterfaceManager

```lua
InterfaceManager:SetTheme("Ocean")
local themes = InterfaceManager:GetThemeList()
local current = InterfaceManager:GetCurrentTheme()

InterfaceManager:SetBlurEnabled(false)
InterfaceManager:SetNotificationsEnabled(false)
InterfaceManager:SetMinimizeKey(Enum.KeyCode.LeftControl)

InterfaceManager:Show()
InterfaceManager:Hide()
InterfaceManager:Toggle()
```

Notifications come in four types. `Notify` takes a config table, while the four shorthands take
positional arguments:

```lua
InterfaceManager:Success("Title", "Message")
InterfaceManager:Error("Title", "Message")
InterfaceManager:Warning("Title", "Message")
InterfaceManager:Info("Title", "Message", 5)   -- optional duration in seconds
InterfaceManager:ClearAllNotifications()
```

### SaveManager

Register a component to have its value written to the config file. Register **after** constructing
it; registration wraps the component's callback, so registering twice fires the callback twice.

```lua
local toggle = window:AddToggle({ Text = "Enable Feature", Default = false })
SaveManager:RegisterComponent("enable_feature", toggle)

SaveManager:Save("my_config")
SaveManager:Load("my_config")
SaveManager:Delete("my_config")

local configs = SaveManager:ListConfigs()

SaveManager:SetAutoSave(true)                  -- save on every change
SaveManager:SetAutoLoadConfig("my_config")     -- restore on next startup
```

Configs are written to the `EnowLib/` folder in your executor's workspace directory.

### BetterLoad

`Content` functions run eagerly, so building many tabs at once blocks the frame. BetterLoad spreads
that work out:

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

`BetterLoad:OptimizeReplicatedStorage()` caches ReplicatedStorage's top-level children so later
lookups avoid re-walking the tree, reachable through `GetCachedItems()` and `GetCachedItem(name)`.
It does not make Roblox replicate or load anything sooner.

### PerformanceManager

`BuildUI` renders nothing unless `Initialize` was called first.

```lua
local PerformanceManager = loadstring(game:HttpGet(BASE .. "managers/performancemanager.lua"))()

PerformanceManager:Initialize(Window)

Category:AddItem({
    Title = "Performance.lua",
    Icon = "rbxassetid://10734982144",
    Content = function(window)
        PerformanceManager:BuildUI(window)
    end
})
```

### FloatingButtonManager

```lua
local FloatingButtonManager = loadstring(game:HttpGet(BASE .. "managers/floatingbuttonmanager.lua"))()

local floatingButton = FloatingButtonManager.new({
    Size = UDim2.fromOffset(56, 56),
    Position = UDim2.new(1, -76, 0.5, -28),
    ImageId = "rbxassetid://103844172237114",
    BackgroundColor = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.3,
    CornerRadius = 28,
    OnClick = function()
        Window:Toggle()
    end
})
```

## Themes

Eight built-in themes: **Hacker** (default, green), **Ocean** (blue), **Purple**, **Sunset**
(orange), **Midnight** (deep blue), **Forest** (green), **Amber** (yellow), **Crimson** (red).

```lua
InterfaceManager:SetTheme("Ocean")
```

## Cleaning up

`Window:Toggle()` hides and shows the UI. `Window:Destroy()` is a full teardown -- it disconnects
input handlers, removes the blur effect and destroys the interface. Call it when your script exits
or reloads so that re-running does not stack leftover connections.

```lua
Window:Destroy()
```

## Debug output

The library is silent by default and does not touch the global `print`.

```lua
EnowLib:SetDebugMode(true)
```

## Pinning a version

The URLs above track `main` and change with each release. To pin a script to a build you have
tested, use a commit SHA in place of the branch:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/enowdev/enowlib-build/<commit-sha>/enowlib.lua"))()
```

Raw GitHub responses are cached briefly, so a fresh release may take a moment to appear.

## Requirements

An executor with `loadstring` and `game:HttpGet`. Config persistence additionally needs the file IO
globals (`isfolder`, `makefolder`, `readfile`, `writefile`, `listfiles`). SaveManager degrades
gracefully without them, but configs will not persist between sessions.

## Version

v2.0.0

## License

MIT
