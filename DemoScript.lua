-- MonkeUI Demo Script
local MonkeUI = require(script.Parent.MonkeUI)

-- Create window
local window = MonkeUI:CreateWindow("MonkeUI Demo", "Main")

-- Theme switcher
local themeSection = window:CreateSection("Theme")
window:AddDropdown("Theme", "Theme", {"Dark", "Light", "Minimal"}, "Dark", function(selected)
    MonkeUI:SwitchTheme(selected)
    window:CreateNotification("Theme Switched", "Now using " .. selected .. " theme!", 2, "rbxassetid://6031094678")
end, "rbxassetid://6031094678")

-- Main section
local section1 = window:CreateSection("Section 1")
window:AddButton("Section 1", "Primary Button", function()
    window:CreateNotification("Clicked!", "You clicked the primary button.", 2, "rbxassetid://6031091002")
end, nil, "rbxassetid://6031091002")
window:AddButton("Section 1", "Destructive Button", function()
    window:CreateNotification("Warning", "Destructive action!", 2, "rbxassetid://6031090990")
end, "Destructive", "rbxassetid://6031090990")
local toggle, getToggleValue = window:AddToggle("Section 1", "Toggle Feature", false, function(state)
    window:CreateNotification("Toggle", "State: " .. tostring(state), 2, "rbxassetid://6031280882")
end, "rbxassetid://6031280882")
local slider, getSliderValue = window:AddSlider("Section 1", "Slider", 0, 100, 50, function(value)
    window:CreateNotification("Slider", "Value: " .. math.floor(value), 1, "rbxassetid://6031265976")
end)

-- Section 2
local section2 = window:CreateSection("Section 2")
window:AddDropdown("Section 2", "Dropdown", {"Option 1", "Option 2", "Option 3", "Another Option", "Last Option"}, "Option 1", function(selected)
    window:CreateNotification("Dropdown", "Selected: " .. selected, 2, "rbxassetid://6031068426")
end, "rbxassetid://6031068426")
local input, getInputValue = window:AddInput("Section 2", "Input", "Enter something...", function(text)
    window:CreateNotification("Input", "You typed: " .. text, 2, "rbxassetid://6031071050")
end)
local checkbox, getCheckboxValue = window:AddCheckbox("Section 2", "Checkbox", false, function(checked)
    window:CreateNotification("Checkbox", "Checked: " .. tostring(checked), 2, "rbxassetid://6031094678")
end)
window:AddParagraph("Section 2", "Information", "This is a paragraph with some information about the application.")
local keybind, getKeybindValue = window:AddKeybind("Section 2", "Keybind", Enum.KeyCode.F, function(key)
    window:CreateNotification("Keybind", "Set to: " .. key.Name, 2, "rbxassetid://6031280882")
end)
local colorPicker, getColorValue = window:AddColorPicker("Section 2", "Color", Color3.fromRGB(255, 121, 63), function(color)
    window:CreateNotification("Color", "Selected!", 1, "rbxassetid://6031071050")
end)
local status, setStatus = window:AddStatus("Section 2", "Status", "Confirmed")

-- Settings tab
window:CreateTab("Settings")
local settingsSection = window:CreateSection("Configuration")
window:AddButton("Configuration", "Save Settings", function()
    window:CreateNotification("Success", "Settings saved successfully!", 2, "rbxassetid://6031091002")
end, nil, "rbxassetid://6031091002")

-- Show tooltips, icons, notifications, and all features in use
window:CreateNotification("Welcome!", "This is the MonkeUI demo.", 3, "rbxassetid://6031094678") 