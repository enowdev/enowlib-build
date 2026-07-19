# EnowLib

Modern, minimalist UI library for Roblox with a Radix-inspired dark design.

This repository hosts the production build. The files here are generated -- do not edit them by
hand, they are overwritten by the next release.

- [Files](#files)
- [Quick start](#quick-start)
- [Structure](#structure)
- [Components](#components)
- [Managers](#managers)
- [Themes](#themes)
- [Saving and restoring state](#saving-and-restoring-state)
- [Cleaning up](#cleaning-up)
- [Reference](#reference)
- [Requirements](#requirements)
- [License](#license)

## Files

| File | Description |
|------|-------------|
| `enowlib.lua` | The library. All components and the theme system. |
| `managers/interfacemanager.lua` | Themes, UI visibility, keybind, notifications |
| `managers/savemanager.lua` | Configuration save/load with auto-load |
| `managers/betterload.lua` | Batched tab loading to prevent startup freeze |
| `managers/performancemanager.lua` | FPS, memory and ping monitoring |
| `managers/floatingbuttonmanager.lua` | Draggable floating toggle button |
| `example.lua` | Runnable showcase of everything below |

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

To see every feature at once:

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

Two details worth knowing up front:

**The parameter passed to `Content` is the tab, not the window.** Naming it `window` is the
convention in these examples, but every `Add*` you call on it is a Tab method.

**`Content` runs immediately when the item is added,** not lazily on first open. For scripts with
many tabs, use [BetterLoad](#betterload) to spread that work across frames.

### EnowLib

```lua
EnowLib:CreateWindow(config)   -- returns a Window
EnowLib:SetDebugMode(enabled)  -- enables the library's internal logging
```

`CreateWindow` accepts:

| Key | Default | Description |
|-----|---------|-------------|
| `Title` | `"EnowLib IDE"` | Title bar text |
| `Size` | `UDim2.fromOffset(900, 600)` | Initial window size |
| `AutoResize` | `true` | Adds a resize handle |
| `MinSize` / `MaxSize` | see below | Resize bounds |
| `DestroyOnClose` | `false` | Title bar X fully tears down instead of hiding |
| `CloseCallback` | `nil` | Called when the X is clicked, before hide or destroy |

`MinSize` adapts to the device: 600x400 on desktop, 300x200 on mobile.

### Window

```lua
Window:AddCategory(config)     -- sidebar folder
Window:AddTab(config)          -- tab without a category
Window:SelectTab(tab)
Window:ShowContent(fn)
Window:Toggle()                -- hide / show
Window:Close()                 -- respects DestroyOnClose
Window:Destroy()               -- full teardown
```

Window also exposes every `Add*` component method, parenting into the content area directly.

### Category and Item

```lua
local category = Window:AddCategory({
    Title = "Main",
    Icon = "rbxassetid://10723387563",
    Expanded = true
})

category:Toggle()
category:Expand()
category:Collapse()

local item = category:AddItem({
    Title = "Features.lua",
    Icon = "rbxassetid://10723356507",
    Content = function(window) end
})

item:Select()
item:Deselect()
```

### Section

```lua
local section = window:AddSection({ Title = "Settings" })
section:AddToggle({ Text = "Option" })
```

Sections do not nest -- a Section has no `AddSection`.

## Components

Every component is created the same way and returns its instance. All callbacks are wrapped in
`pcall`, so an error in your code cannot break the UI.

Note that most components take `Text`, but **Keybind and Paragraph take `Title`**.

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

The callback fires when focus is lost, not on every keystroke.

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

The callback receives a fresh array of the selected option strings. Mutating it is safe -- it is a
copy, not the component's internal state.

```lua
local multiselect = window:AddMultiSelect({
    Text = "Select Multiple",
    Options = {"Fire", "Water", "Earth"},
    Default = {"Fire"},
    Callback = function(values)
        print(table.concat(values, ", "))
    end
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

Takes `Title`, not `Text`. The callback receives a key name string such as `"LeftControl"`.

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
    Color = Color3.fromRGB(255, 255, 255),  -- optional
    Size = 14,                              -- optional
    Font = Enum.Font.Gotham                 -- optional
})

window:AddParagraph({
    Title = "Title",                        -- Paragraph takes Title
    Content = "Longer text that wraps automatically."
})

window:AddDivider()                         -- or AddDivider({ Text = "Section" })
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

Attaching a manager as `Window.<Name>Manager` means `Window:Destroy()` tears it down for you.

### InterfaceManager

```lua
InterfaceManager:SetTheme("Ocean")
InterfaceManager:GetThemeList()             -- array of theme names
InterfaceManager:GetCurrentTheme()

InterfaceManager:SetBlurEnabled(false)
InterfaceManager:GetBlurEnabled()
InterfaceManager:SetNotificationsEnabled(false)
InterfaceManager:GetNotificationsEnabled()
InterfaceManager:SetMinimizeKey(Enum.KeyCode.LeftControl)

InterfaceManager:Show()
InterfaceManager:Hide()
InterfaceManager:Toggle()
InterfaceManager:Destroy()
```

Notifications come in four types. The shorthands take positional arguments; `Notify` takes a config
table.

```lua
InterfaceManager:Success("Title", "Message")
InterfaceManager:Error("Title", "Message")
InterfaceManager:Warning("Title", "Message")
InterfaceManager:Info("Title", "Message", 5)   -- optional duration, default 3
InterfaceManager:ClearAllNotifications()
```

You can also reach the notification component directly:

```lua
local Notification = Window.EnowLib.Components.Notification
Notification:Success("Title", "Message")
Notification:SetEnabled(false)
```

### SaveManager

```lua
SaveManager:RegisterComponent(id, component)
SaveManager:UnregisterComponent(id)

SaveManager:Save("my_config")
SaveManager:Load("my_config")
SaveManager:Delete("my_config")
SaveManager:ListConfigs()

SaveManager:SetAutoSave(true)                  -- save on every change
SaveManager:EnableAutoSave(60)                 -- or save on a timer, in seconds
SaveManager:DisableAutoSave()

SaveManager:SetAutoLoadConfig("my_config")     -- restore on next startup
SaveManager:GetAutoLoadConfig()
SaveManager:AutoLoad()
```

See [Saving and restoring state](#saving-and-restoring-state) for the details that matter.

### BetterLoad

`Content` functions run eagerly, so building many tabs at once blocks the frame. BetterLoad spreads
that work across frames.

```lua
BetterLoad:Initialize(Window)
BetterLoad:WaitForGameLoad()

BetterLoad:QueueTab(category, {
    Title = "Heavy.lua",
    Icon = "rbxassetid://10723356507",
    Content = function(window) end
})

BetterLoad:ProcessQueue()
BetterLoad:AutoLoadConfig(SaveManager)

BetterLoad:SetBatchSize(1)
BetterLoad:SetBatchDelay(0.05)
BetterLoad:LoadWithProgress(fn, "Description")
```

`OptimizeReplicatedStorage()` caches ReplicatedStorage's top-level children so later lookups skip
the traversal, reachable via `GetCachedItems()` and `GetCachedItem(name)`. It does **not** make
Roblox replicate or load anything sooner -- the name promises more than it delivers.

Note that `BetterLoad:AutoLoadConfig` and `SaveManager:AutoLoad` do the same job. Calling both
loads the config twice.

### PerformanceManager

`BuildUI` renders nothing unless `Initialize` ran first.

```lua
PerformanceManager:Initialize(Window)

category:AddItem({
    Title = "Performance.lua",
    Content = function(window)
        PerformanceManager:BuildUI(window)
    end
})

PerformanceManager:StartMonitoring()
PerformanceManager:StopMonitoring()
PerformanceManager:GetFPS()
PerformanceManager:GetAvgFPS()
PerformanceManager:GetMemory()
PerformanceManager:GetPing()
PerformanceManager:ResetStats()
```

Metrics read `--` until monitoring is enabled.

### FloatingButtonManager

Created with `.new(config)`, not `Initialize(window)`.

```lua
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

floatingButton:SetImage("rbxassetid://...")
floatingButton:SetPosition(UDim2.new(0, 20, 0, 20))
floatingButton:Show()
floatingButton:Hide()
floatingButton:Toggle()
floatingButton:Destroy()
```

## Themes

Eight built-in themes: **Hacker** (default, green), **Ocean** (blue), **Purple**, **Sunset**
(orange), **Midnight** (deep blue), **Forest** (green), **Amber** (yellow), **Crimson** (red).

```lua
InterfaceManager:SetTheme("Ocean")
```

Switching a theme restyles components already on screen -- they re-read their colours rather than
being rebuilt.

## Saving and restoring state

Register a component and its value is written to the config file:

```lua
local toggle = window:AddToggle({ Text = "Enable Feature", Default = false })
SaveManager:RegisterComponent("enable_feature", toggle)
```

Three rules that will save you debugging time:

**Register after constructing.** Registration wraps the component's callback, so registering the
same component twice fires its callback twice.

**Restoring does not fire callbacks.** Loading a config sets values silently, so side effects are
not replayed. If a toggle's effect must be reapplied on load, do it yourself after `Load` returns.

**Only components with a value are saved.** Buttons, labels, paragraphs and dividers hold no state
and are skipped.

Configs are JSON, written to the `EnowLib/` folder in your executor's workspace directory. Colours
are stored as `{R, G, B}` and keybinds as key-name strings; both are reconstructed on load.

## Cleaning up

`Window:Toggle()` hides and shows. `Window:Destroy()` is a full teardown -- it disconnects input
handlers, removes the blur effect, destroys the interface and tears down any manager attached as
`Window.<Name>Manager`.

```lua
Window:Destroy()
```

Call it when your script exits or reloads. Executors commonly run a script several times in one
session, and without teardown each run leaves its input handlers behind.

`Destroy` is safe to call twice.

## Reference

### Component values

| Component | Value type | Setter |
|-----------|-----------|--------|
| Toggle | boolean | `SetValue(v)` |
| Slider | number | `SetValue(v)` |
| TextBox | string | `SetValue(v)` |
| Dropdown | string | `SetValue(v)` silent, `Select(v)` fires callback |
| MultiSelect | array of strings | `SetValue(v)`, `GetValue()` returns a copy |
| ColorPicker | Color3 | `SetValue(v)` |
| Keybind | key name string | `SetValue(v)` or `SetKey(v)` |

Every `SetValue` is silent by design. `Dropdown:Select` is the interactive path and does fire the
callback.

### Debug output

The library is silent by default and does not touch the global `print`.

```lua
EnowLib:SetDebugMode(true)
```

### Pinning a version

The URLs above track `main` and change with each release. To pin a script to a build you have
tested, use a commit SHA in place of the branch:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/enowdev/enowlib-build/<commit-sha>/enowlib.lua"))()
```

Raw GitHub responses are cached briefly, so a fresh release may take a moment to appear.

## Requirements

An executor with `loadstring` and `game:HttpGet`.

Config persistence additionally needs the file IO globals (`isfolder`, `makefolder`, `readfile`,
`writefile`, `listfiles`, `isfile`, `delfile`). SaveManager degrades gracefully without them --
nothing errors, but configs will not persist between sessions.

## License

MIT -- see [LICENSE](LICENSE).

Copyright (c) 2024 EnowHub Development
