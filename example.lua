-- EnowLib - complete feature sample
-- Exercises every component, every manager and every window method.
-- Paste into an executor and run.

local BASE = "https://raw.githubusercontent.com/enowdev/enowlib-build/refs/heads/main/"

local EnowLib = loadstring(game:HttpGet(BASE .. "enowlib.lua"))()
local InterfaceManager = loadstring(game:HttpGet(BASE .. "managers/interfacemanager.lua"))()
local SaveManager = loadstring(game:HttpGet(BASE .. "managers/savemanager.lua"))()
local BetterLoad = loadstring(game:HttpGet(BASE .. "managers/betterload.lua"))()
local PerformanceManager = loadstring(game:HttpGet(BASE .. "managers/performancemanager.lua"))()
local FloatingButtonManager = loadstring(game:HttpGet(BASE .. "managers/floatingbuttonmanager.lua"))()

-- Set to true to see the library's internal logging
EnowLib:SetDebugMode(false)

local Window = EnowLib:CreateWindow({
    Title = "EnowLib Showcase"
})

-- Managers are initialized with the window AFTER it exists.
-- PerformanceManager:BuildUI returns early and renders nothing if its
-- Initialize was never called, so none of these are optional.
InterfaceManager:Initialize(Window)
SaveManager:Initialize(Window)
BetterLoad:Initialize(Window)
PerformanceManager:Initialize(Window)

Window.InterfaceManager = InterfaceManager
Window.SaveManager = SaveManager

local Notification = Window.EnowLib.Components.Notification

--------------------------------------------------------------------------------
-- Components
--------------------------------------------------------------------------------

local MainCategory = Window:AddCategory({
    Title = "Main",
    Icon = "rbxassetid://10723387563",
    Expanded = true
})

MainCategory:AddItem({
    Title = "Components.lua",
    Icon = "rbxassetid://10723356507",
    -- The parameter is the TAB, not the window. Naming it `window` is the
    -- convention in these examples, but every Add* below is a Tab method.
    Content = function(window)
        window:AddParagraph({
            Title = "All components",
            Content = "Every input component the library ships with, each one registered with SaveManager so its value survives a reload."
        })

        window:AddDivider()

        -- Section groups components into a titled box
        local inputs = window:AddSection({ Title = "Inputs" })

        inputs:AddButton({
            Text = "Button",
            Callback = function()
                Notification:Success("Button", "Callback fired")
            end
        })

        local toggle = inputs:AddToggle({
            Text = "Toggle",
            Default = false,
            Callback = function(value)
                print("Toggle:", value)
            end
        })
        SaveManager:RegisterComponent("demo_toggle", toggle)

        local slider = inputs:AddSlider({
            Text = "Slider",
            Min = 0,
            Max = 100,
            Default = 50,
            Callback = function(value)
                print("Slider:", value)
            end
        })
        SaveManager:RegisterComponent("demo_slider", slider)

        -- Sliders handle float ranges too, rounded to 2 decimals
        local floatSlider = inputs:AddSlider({
            Text = "Slider (float)",
            Min = 0.5,
            Max = 5,
            Default = 1.5,
            Callback = function(value)
                print("Float slider:", value)
            end
        })
        SaveManager:RegisterComponent("demo_slider_float", floatSlider)

        local textbox = inputs:AddTextBox({
            Text = "TextBox",
            Placeholder = "Type here...",
            Default = "",
            Callback = function(value)
                print("TextBox:", value)
            end
        })
        SaveManager:RegisterComponent("demo_textbox", textbox)

        local selection = window:AddSection({ Title = "Selection" })

        local dropdown = selection:AddDropdown({
            Text = "Dropdown",
            Options = { "Alpha", "Bravo", "Charlie" },
            Default = "Alpha",
            Searchable = false,
            Callback = function(value)
                print("Dropdown:", value)
            end
        })
        SaveManager:RegisterComponent("demo_dropdown", dropdown)

        local searchable = selection:AddDropdown({
            Text = "Dropdown (searchable)",
            Options = { "Apple", "Banana", "Cherry", "Dragonfruit", "Elderberry" },
            Default = "Apple",
            Searchable = true,
            Callback = function(value)
                print("Searchable dropdown:", value)
            end
        })
        SaveManager:RegisterComponent("demo_dropdown_search", searchable)

        local multiselect = selection:AddMultiSelect({
            Text = "MultiSelect",
            Options = { "Fire", "Water", "Earth", "Air" },
            Default = { "Fire" },
            Callback = function(values)
                print("MultiSelect:", table.concat(values, ", "))
            end
        })
        SaveManager:RegisterComponent("demo_multiselect", multiselect)

        -- Regression check: a Dropdown followed by a Divider in the same
        -- section used to collapse the section and clip everything after it.
        -- Both the divider and the label below must be visible, and opening
        -- the dropdown must push them down rather than hide them.
        local layoutCheck = window:AddSection({ Title = "Layout regression check" })

        layoutCheck:AddDropdown({
            Text = "Dropdown then divider",
            Options = { "One", "Two", "Three" },
            Default = "One"
        })
        layoutCheck:AddDivider()
        layoutCheck:AddLabel({ Text = "This label must be visible" })

        local misc = window:AddSection({ Title = "Color and keys" })

        local colorpicker = misc:AddColorPicker({
            Text = "ColorPicker",
            Default = Color3.fromRGB(46, 204, 113),
            Callback = function(color)
                print("Color:", color)
            end
        })
        SaveManager:RegisterComponent("demo_colorpicker", colorpicker)

        -- Keybind uses Title, not Text
        local keybind = misc:AddKeybind({
            Title = "Keybind",
            Default = "None",
            Callback = function(key)
                print("Keybind:", key)
            end
        })
        SaveManager:RegisterComponent("demo_keybind", keybind)

        misc:AddDivider()

        misc:AddLabel({ Text = "Plain label" })
        misc:AddLabel({
            Text = "Colored label",
            Color = Color3.fromRGB(241, 196, 15)
        })

        misc:AddParagraph({
            Title = "Paragraph",
            Content = "Paragraphs wrap automatically and are useful for longer explanatory text."
        })
    end
})

--------------------------------------------------------------------------------
-- Notifications
--------------------------------------------------------------------------------

MainCategory:AddItem({
    Title = "Notifications.lua",
    Icon = "rbxassetid://10723356507",
    Content = function(window)
        local section = window:AddSection({ Title = "Types" })

        section:AddButton({
            Text = "Success",
            Callback = function()
                Notification:Success("Success", "Operation completed")
            end
        })

        section:AddButton({
            Text = "Error",
            Callback = function()
                Notification:Error("Error", "Something went wrong")
            end
        })

        section:AddButton({
            Text = "Warning",
            Callback = function()
                Notification:Warning("Warning", "This cannot be undone")
            end
        })

        section:AddButton({
            Text = "Info",
            Callback = function()
                Notification:Info("Info", "Just so you know")
            end
        })

        section:AddButton({
            Text = "Custom duration (6s)",
            Callback = function()
                Notification:Success("Long", "This stays for six seconds", 6)
            end
        })

        local control = window:AddSection({ Title = "Control" })

        control:AddToggle({
            Text = "Notifications enabled",
            Default = true,
            Callback = function(value)
                InterfaceManager:SetNotificationsEnabled(value)
            end
        })

        control:AddButton({
            Text = "Clear all",
            Callback = function()
                InterfaceManager:ClearAllNotifications()
            end
        })
    end
})

--------------------------------------------------------------------------------
-- Theme and interface
--------------------------------------------------------------------------------

local SettingsCategory = Window:AddCategory({
    Title = "Settings",
    Icon = "rbxassetid://10734950309",
    Expanded = false
})

SettingsCategory:AddItem({
    Title = "Interface.lua",
    Icon = "rbxassetid://10734950309",
    Content = function(window)
        local theme = window:AddSection({ Title = "Theme" })

        local themeDropdown = theme:AddDropdown({
            Text = "Theme",
            Options = InterfaceManager:GetThemeList(),
            Default = InterfaceManager:GetCurrentTheme(),
            Callback = function(value)
                InterfaceManager:SetTheme(value)
            end
        })
        SaveManager:RegisterComponent("InterfaceManager_Theme", themeDropdown)

        local visuals = window:AddSection({ Title = "Visuals" })

        local blur = visuals:AddToggle({
            Text = "Background blur",
            Default = InterfaceManager:GetBlurEnabled(),
            Callback = function(value)
                InterfaceManager:SetBlurEnabled(value)
            end
        })
        SaveManager:RegisterComponent("InterfaceManager_BlurEnabled", blur)

        local notifs = visuals:AddToggle({
            Text = "Notifications",
            Default = InterfaceManager:GetNotificationsEnabled(),
            Callback = function(value)
                InterfaceManager:SetNotificationsEnabled(value)
            end
        })
        SaveManager:RegisterComponent("InterfaceManager_NotificationsEnabled", notifs)

        local keys = window:AddSection({ Title = "Keybinds" })

        local toggleKey = keys:AddKeybind({
            Title = "Toggle UI",
            Default = "RightShift",
            Callback = function(key)
                if key and key ~= "None" and Enum.KeyCode[key] then
                    InterfaceManager:SetMinimizeKey(Enum.KeyCode[key])
                end
            end
        })
        SaveManager:RegisterComponent("InterfaceManager_ToggleKeybind", toggleKey)

        local visibility = window:AddSection({ Title = "Visibility" })

        visibility:AddButton({
            Text = "Hide (show again with the toggle key)",
            Callback = function()
                InterfaceManager:Hide()
            end
        })

        visibility:AddButton({
            Text = "Toggle",
            Callback = function()
                InterfaceManager:Toggle()
            end
        })
    end
})

--------------------------------------------------------------------------------
-- Configuration
--------------------------------------------------------------------------------

SettingsCategory:AddItem({
    Title = "Config.lua",
    Icon = "rbxassetid://10723374759",
    Content = function(window)
        local section = window:AddSection({ Title = "Save and load" })

        local nameBox = section:AddTextBox({
            Text = "Config name",
            Placeholder = "default",
            Default = "default"
        })

        section:AddButton({
            Text = "Save",
            Callback = function()
                local name = (nameBox.Value ~= "" and nameBox.Value) or "default"
                if SaveManager:Save(name) then
                    Notification:Success("Saved", "Config '" .. name .. "' written")
                else
                    Notification:Error("Save failed", "Executor may not support file IO")
                end
            end
        })

        section:AddButton({
            Text = "Load",
            Callback = function()
                local name = (nameBox.Value ~= "" and nameBox.Value) or "default"
                if SaveManager:Load(name) then
                    Notification:Success("Loaded", "Config '" .. name .. "' applied")
                else
                    Notification:Error("Load failed", "No config named '" .. name .. "'")
                end
            end
        })

        section:AddButton({
            Text = "Delete",
            Callback = function()
                local name = (nameBox.Value ~= "" and nameBox.Value) or "default"
                SaveManager:Delete(name)
                Notification:Warning("Deleted", "Config '" .. name .. "' removed")
            end
        })

        section:AddButton({
            Text = "List configs (prints to console)",
            Callback = function()
                local configs = SaveManager:ListConfigs()
                if configs and #configs > 0 then
                    print("[Config] " .. table.concat(configs, ", "))
                    Notification:Info("Configs", #configs .. " found, see console")
                else
                    Notification:Info("Configs", "None saved yet")
                end
            end
        })

        local auto = window:AddSection({ Title = "Automatic" })

        local autosave = auto:AddToggle({
            Text = "Auto save on change",
            Default = false,
            Callback = function(value)
                SaveManager:SetAutoSave(value)
            end
        })
        SaveManager:RegisterComponent("SaveManager_AutoSave", autosave)

        auto:AddButton({
            Text = "Set current as auto-load",
            Callback = function()
                local name = (nameBox.Value ~= "" and nameBox.Value) or "default"
                SaveManager:SetAutoLoadConfig(name)
                Notification:Success("Auto-load set", "'" .. name .. "' loads on startup")
            end
        })
    end
})

--------------------------------------------------------------------------------
-- Performance, queued with BetterLoad
--------------------------------------------------------------------------------

BetterLoad:QueueTab(SettingsCategory, {
    Title = "Performance.lua",
    Icon = "rbxassetid://10734982144",
    Content = function(window)
        PerformanceManager:BuildUI(window)
    end
})

BetterLoad:ProcessQueue()

--------------------------------------------------------------------------------
-- Teardown
--------------------------------------------------------------------------------

SettingsCategory:AddItem({
    Title = "Teardown.lua",
    Icon = "rbxassetid://10747384394",
    Content = function(window)
        window:AddParagraph({
            Title = "Toggle vs Destroy",
            Content = "Toggle only hides the interface. Destroy releases input connections and the blur effect, and is what you want when your script exits or reloads."
        })

        local section = window:AddSection({ Title = "Actions" })

        section:AddButton({
            Text = "Toggle (hide, keeps everything alive)",
            Callback = function()
                Window:Toggle()
            end
        })

        section:AddButton({
            Text = "Destroy (full teardown)",
            Callback = function()
                Window:Destroy()
            end
        })

        local checks = window:AddSection({ Title = "Leak check" })

        checks:AddButton({
            Text = "Report tracked components (console)",
            Callback = function()
                local n = 0
                for _ in ipairs(Window.Components or {}) do
                    n = n + 1
                end
                print("[Teardown] components registered for cleanup:", n)
                print("[Teardown] blur effects in Lighting:", (function()
                    local c = 0
                    for _, v in ipairs(game:GetService("Lighting"):GetChildren()) do
                        if v:IsA("BlurEffect") then c = c + 1 end
                    end
                    return c
                end)())
            end
        })

        checks:AddButton({
            Text = "Destroy twice (must not error)",
            Callback = function()
                Window:Destroy()
                local ok = pcall(function() Window:Destroy() end)
                print("[Teardown] second Destroy survived:", ok)
            end
        })
    end
})

--------------------------------------------------------------------------------
-- Floating button
--------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------
-- Restore any config marked for auto-load
--------------------------------------------------------------------------------

BetterLoad:AutoLoadConfig(SaveManager)

Notification:Success("EnowLib", "Showcase loaded")

