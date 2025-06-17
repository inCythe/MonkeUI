--[[
    MonkeUI Library for Roblox
    A sleek, customizable UI library inspired by modern design principles
    
    Features:
    - Dark theme with glass morphism effects
    - Smooth animations and transitions
    - Modular component system
    - Easy customization
    - Performance optimized
    
    Usage:
    local UI = require(script.MonkeUI)
    local window = UI:CreateWindow("My App", "Tab 1")
    local section = window:CreateSection("Section 1")
    section:AddButton("Button", function() print("Clicked!") end)
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- UI Library Class
local MonkeUI = {}
MonkeUI.__index = MonkeUI

-- Configuration
local Config = {
    -- Colors
    Colors = {
        Background = Color3.fromRGB(40, 42, 54),
        Secondary = Color3.fromRGB(50, 54, 67),
        Accent = Color3.fromRGB(255, 121, 63),
        AccentHover = Color3.fromRGB(255, 135, 84),
        Text = Color3.fromRGB(248, 248, 242),
        TextSecondary = Color3.fromRGB(189, 195, 199),
        Success = Color3.fromRGB(80, 200, 120),
        Destructive = Color3.fromRGB(231, 76, 60),
        Border = Color3.fromRGB(68, 71, 90),
        Hover = Color3.fromRGB(60, 64, 77)
    },
    
    -- Animation settings
    Animation = {
        Speed = 0.25,
        Style = Enum.EasingStyle.Quart,
        Direction = Enum.EasingDirection.Out
    },
    
    -- Sizes
    Sizes = {
        WindowMin = Vector2.new(600, 400),
        TabHeight = 40,
        SectionPadding = 10,
        ComponentHeight = 35,
        ComponentSpacing = 8
    }
}

-- Utility Functions
local function CreateTween(object, properties, duration)
    duration = duration or Config.Animation.Speed
    local tweenInfo = TweenInfo.new(
        duration,
        Config.Animation.Style,
        Config.Animation.Direction
    )
    return TweenService:Create(object, tweenInfo, properties)
end

local function CreateCorner(radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    return corner
end

local function CreateStroke(color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Config.Colors.Border
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return stroke
end

local function CreateGradient(colorSequence, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = colorSequence
    gradient.Rotation = rotation or 0
    return gradient
end

-- Window Class
local Window = {}
Window.__index = Window

function Window.new(title, initialTab)
    local self = setmetatable({}, Window)
    
    self.Title = title
    self.Tabs = {}
    self.CurrentTab = nil
    self.Sections = {}
    
    self:CreateWindow()
    if initialTab then
        self:CreateTab(initialTab)
    end
    
    return self
end

function Window:CreateWindow()
    local isTouch = UserInputService.TouchEnabled

    -- Main ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "MonkeUI_" .. self.Title
    self.ScreenGui.Parent = PlayerGui
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = isTouch and UDim2.new(0.95, 0, 0.9, 0) or UDim2.new(0, 800, 0, 500)
    self.MainFrame.Position = isTouch and UDim2.new(0.025, 0, 0.05, 0) or UDim2.new(0.5, -400, 0.5, -250)
    self.MainFrame.BackgroundColor3 = Config.Colors.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui

    CreateCorner(12).Parent = self.MainFrame
    CreateStroke(Config.Colors.Border, 1).Parent = self.MainFrame
    
    -- Add glass effect
    local glassGradient = CreateGradient(ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.new(0.9, 0.9, 0.9))
    })
    glassGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.95),
        NumberSequenceKeypoint.new(1, 0.98)
    }
    glassGradient.Parent = self.MainFrame
    
    -- Title Bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 40)
    self.TitleBar.Position = UDim2.new(0, 0, 0, 0)
    self.TitleBar.BackgroundColor3 = Config.Colors.Secondary
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.MainFrame
    
    CreateCorner(12).Parent = self.TitleBar
    
    -- Title corner fix
    local titleCornerFix = Instance.new("Frame")
    titleCornerFix.Size = UDim2.new(1, 0, 0, 12)
    titleCornerFix.Position = UDim2.new(0, 0, 1, -12)
    titleCornerFix.BackgroundColor3 = Config.Colors.Secondary
    titleCornerFix.BorderSizePixel = 0
    titleCornerFix.Parent = self.TitleBar
    
    -- Title Label
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "TitleLabel"
    self.TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Config.Colors.Text
    self.TitleLabel.TextScaled = true
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.Parent = self.TitleBar
    
    -- Close Button
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Name = "CloseButton"
    self.CloseButton.Size = UDim2.new(0, 30, 0, 30)
    self.CloseButton.Position = UDim2.new(1, -40, 0, 5)
    self.CloseButton.BackgroundColor3 = Config.Colors.Destructive
    self.CloseButton.BorderSizePixel = 0
    self.CloseButton.Text = "×"
    self.CloseButton.TextColor3 = Color3.new(1, 1, 1)
    self.CloseButton.TextScaled = true
    self.CloseButton.Font = Enum.Font.GothamBold
    self.CloseButton.Parent = self.TitleBar
    
    CreateCorner(6).Parent = self.CloseButton
    
    -- Tab Container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(1, 0, 0, Config.Sizes.TabHeight)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 40)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.Parent = self.MainFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 2)
    tabLayout.Parent = self.TabContainer
    
    -- Content Frame
    self.ContentFrame = Instance.new("ScrollingFrame")
    self.ContentFrame.Name = "ContentFrame"
    self.ContentFrame.Size = UDim2.new(1, -20, 1, -90)
    self.ContentFrame.Position = UDim2.new(0, 10, 0, 80)
    self.ContentFrame.BackgroundTransparency = 1
    self.ContentFrame.BorderSizePixel = 0
    self.ContentFrame.ScrollBarThickness = isTouch and 12 or 4
    self.ContentFrame.ScrollBarImageColor3 = Config.Colors.Accent
    self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.ContentFrame.Parent = self.MainFrame
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, Config.Sizes.SectionPadding)
    contentLayout.Parent = self.ContentFrame
    
    -- Auto-resize canvas
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Make window draggable
    self:MakeDraggable()
    
    -- Close button functionality
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Add hover effects
    self:AddHoverEffect(self.CloseButton, Config.Colors.Destructive, Color3.fromRGB(220, 60, 50))
end

function Window:MakeDraggable()
    local dragging = false
    local dragStart = nil
    local startPos = nil

    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

function Window:AddHoverEffect(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        CreateTween(button, {BackgroundColor3 = hoverColor}, 0.1):Play()
    end)
    
    button.MouseLeave:Connect(function()
        CreateTween(button, {BackgroundColor3 = normalColor}, 0.1):Play()
    end)
end

function Window:CreateTab(name)
    local tab = {}
    tab.Name = name
    tab.Button = Instance.new("TextButton")
    tab.Button.Name = name .. "_Tab"
    tab.Button.Size = UDim2.new(0, 100, 1, 0)
    tab.Button.BackgroundColor3 = Config.Colors.Secondary
    tab.Button.BorderSizePixel = 0
    tab.Button.Text = name
    tab.Button.TextColor3 = Config.Colors.TextSecondary
    tab.Button.TextScaled = true
    tab.Button.Font = Enum.Font.Gotham
    tab.Button.Parent = self.TabContainer
    
    CreateCorner(6).Parent = tab.Button
    
    -- Tab selection
    tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(name)
    end)
    
    self:AddHoverEffect(tab.Button, Config.Colors.Secondary, Config.Colors.Hover)
    
    self.Tabs[name] = tab
    
    if not self.CurrentTab then
        self:SelectTab(name)
    end
    
    return tab
end

function Window:SelectTab(name)
    if not self.Tabs[name] then return end
    
    -- Update tab appearances
    for tabName, tab in pairs(self.Tabs) do
        if tabName == name then
            CreateTween(tab.Button, {
                BackgroundColor3 = Config.Colors.Accent,
                TextColor3 = Color3.new(1, 1, 1)
            }):Play()
        else
            CreateTween(tab.Button, {
                BackgroundColor3 = Config.Colors.Secondary,
                TextColor3 = Config.Colors.TextSecondary
            }):Play()
        end
    end
    
    self.CurrentTab = name
    self:RefreshContent()
end

function Window:RefreshContent()
    -- Clear current content
    for _, child in pairs(self.ContentFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name:find("Section_") then
            child:Destroy()
        end
    end
    
    -- Show sections for current tab
    if self.Sections[self.CurrentTab] then
        for _, section in pairs(self.Sections[self.CurrentTab]) do
            section.Frame.Parent = self.ContentFrame
        end
    end
end

function Window:CreateSection(name)
    if not self.CurrentTab then
        warn("No tab selected. Create a tab first.")
        return
    end
    
    if not self.Sections[self.CurrentTab] then
        self.Sections[self.CurrentTab] = {}
    end
    
    local section = {}
    section.Name = name
    section.Components = {}
    
    -- Section Frame
    section.Frame = Instance.new("Frame")
    section.Frame.Name = "Section_" .. name
    section.Frame.Size = UDim2.new(1, 0, 0, 100)
    section.Frame.BackgroundColor3 = Config.Colors.Secondary
    section.Frame.BorderSizePixel = 0
    section.Frame.LayoutOrder = #self.Sections[self.CurrentTab] + 1
    
    CreateCorner(8).Parent = section.Frame
    CreateStroke(Config.Colors.Border, 1).Parent = section.Frame
    
    -- Section Title
    section.Title = Instance.new("TextLabel")
    section.Title.Name = "SectionTitle"
    section.Title.Size = UDim2.new(1, -20, 0, 30)
    section.Title.Position = UDim2.new(0, 10, 0, 5)
    section.Title.BackgroundTransparency = 1
    section.Title.Text = name
    section.Title.TextColor3 = Config.Colors.Text
    section.Title.TextScaled = true
    section.Title.TextXAlignment = Enum.TextXAlignment.Left
    section.Title.Font = Enum.Font.GothamBold
    section.Title.Parent = section.Frame
    
    -- Component Container
    section.Container = Instance.new("Frame")
    section.Container.Name = "ComponentContainer"
    section.Container.Size = UDim2.new(1, -20, 1, -40)
    section.Container.Position = UDim2.new(0, 10, 0, 35)
    section.Container.BackgroundTransparency = 1
    section.Container.Parent = section.Frame
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, Config.Sizes.ComponentSpacing)
    layout.Parent = section.Container
    
    -- Auto-resize section
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        section.Frame.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 50)
    end)
    
    section.Frame.Parent = self.ContentFrame
    self.Sections[self.CurrentTab][name] = section
    
    return section
end

-- Section Methods
function Window:AddButton(sectionName, text, callback, style)
    local section = self.Sections[self.CurrentTab] and self.Sections[self.CurrentTab][sectionName]
    if not section then return end
    
    style = style or "Primary"
    
    local button = Instance.new("TextButton")
    button.Name = "Button_" .. text
    button.Size = UDim2.new(1, 0, 0, Config.Sizes.ComponentHeight)
    button.BackgroundColor3 = style == "Destructive" and Config.Colors.Destructive or Config.Colors.Accent
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextScaled = true
    button.Font = Enum.Font.Gotham
    button.LayoutOrder = #section.Components + 1
    button.Parent = section.Container
    
    CreateCorner(6).Parent = button
    
    local hoverColor = style == "Destructive" and Color3.fromRGB(220, 60, 50) or Config.Colors.AccentHover
    self:AddHoverEffect(button, button.BackgroundColor3, hoverColor)
    
    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    table.insert(section.Components, button)
    return button
end

function Window:AddToggle(sectionName, text, default, callback)
    local section = self.Sections[self.CurrentTab] and self.Sections[self.CurrentTab][sectionName]
    if not section then return end
    
    local toggle = Instance.new("Frame")
    toggle.Name = "Toggle_" .. text
    toggle.Size = UDim2.new(1, 0, 0, Config.Sizes.ComponentHeight)
    toggle.BackgroundTransparency = 1
    toggle.LayoutOrder = #section.Components + 1
    toggle.Parent = section.Container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Config.Colors.Text
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = toggle
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 50, 0, 25)
    toggleButton.Position = UDim2.new(1, -50, 0.5, -12.5)
    toggleButton.BackgroundColor3 = default and Config.Colors.Success or Config.Colors.Border
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = ""
    toggleButton.Parent = toggle
    
    CreateCorner(12).Parent = toggleButton
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 21, 0, 21)
    indicator.Position = default and UDim2.new(1, -23, 0, 2) or UDim2.new(0, 2, 0, 2)
    indicator.BackgroundColor3 = Color3.new(1, 1, 1)
    indicator.BorderSizePixel = 0
    indicator.Parent = toggleButton
    
    CreateCorner(10).Parent = indicator
    
    local state = default or false
    
    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        
        local newColor = state and Config.Colors.Success or Config.Colors.Border
        local newPos = state and UDim2.new(1, -23, 0, 2) or UDim2.new(0, 2, 0, 2)
        
        CreateTween(toggleButton, {BackgroundColor3 = newColor}):Play()
        CreateTween(indicator, {Position = newPos}):Play()
        
        if callback then callback(state) end
    end)
    
    table.insert(section.Components, toggle)
    return toggle, function() return state end
end

function Window:AddSlider(sectionName, text, min, max, default, callback)
    local section = self.Sections[self.CurrentTab] and self.Sections[self.CurrentTab][sectionName]
    if not section then return end
    
    local slider = Instance.new("Frame")
    slider.Name = "Slider_" .. text
    slider.Size = UDim2.new(1, 0, 0, Config.Sizes.ComponentHeight + 10)
    slider.BackgroundTransparency = 1
    slider.LayoutOrder = #section.Components + 1
    slider.Parent = section.Container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Config.Colors.Text
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = slider
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 70, 0, 20)
    valueLabel.Position = UDim2.new(1, -70, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default or min) .. "%"
    valueLabel.TextColor3 = Config.Colors.Accent
    valueLabel.TextScaled = true
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Parent = slider
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, 0, 0, 6)
    sliderTrack.Position = UDim2.new(0, 0, 1, -15)
    sliderTrack.BackgroundColor3 = Config.Colors.Border
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = slider
    
    CreateCorner(3).Parent = sliderTrack
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default or min) / max, 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = Config.Colors.Accent
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack
    
    CreateCorner(3).Parent = sliderFill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 16, 0, 16)
    sliderButton.Position = UDim2.new((default or min) / max, -8, 0, -5)
    sliderButton.BackgroundColor3 = Color3.new(1, 1, 1)
    sliderButton.BorderSizePixel = 0
    sliderButton.Text = ""
    sliderButton.Parent = sliderTrack
    
    CreateCorner(8).Parent = sliderButton
    
    local value = default or min
    local dragging = false
    
    local function updateSlider(newValue)
        value = math.clamp(newValue, min, max)
        local percentage = (value - min) / (max - min)
        
        CreateTween(sliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
        CreateTween(sliderButton, {Position = UDim2.new(percentage, -8, 0, -5)}):Play()
        
        valueLabel.Text = tostring(math.floor(value)) .. "%"
        
        if callback then callback(value) end
    end
    
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position.X
            local trackPos = sliderTrack.AbsolutePosition.X
            local trackSize = sliderTrack.AbsoluteSize.X
            local percentage = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
            local newValue = min + (percentage * (max - min))
            updateSlider(newValue)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    table.insert(section.Components, slider)
    return slider, function() return value end
end

function Window:AddDropdown(sectionName, text, options, default, callback)
    local section = self.Sections[self.CurrentTab] and self.Sections[self.CurrentTab][sectionName]
    if not section then return end
    
    local dropdown = Instance.new("Frame")
    dropdown.Name = "Dropdown_" .. text
    dropdown.Size = UDim2.new(1, 0, 0, Config.Sizes.ComponentHeight)
    dropdown.BackgroundTransparency = 1
    dropdown.LayoutOrder = #section.Components + 1
    dropdown.Parent = section.Container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Config.Colors.Text
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = dropdown
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(0.6, -10, 1, 0)
    dropdownButton.Position = UDim2.new(0.4, 5, 0, 0)
    dropdownButton.BackgroundColor3 = Config.Colors.Background
    dropdownButton.BorderSizePixel = 0
    dropdownButton.Text = default or options[1] or "Select"
    dropdownButton.TextColor3 = Config.Colors.Text
    dropdownButton.TextScaled = true
    dropdownButton.Font = Enum.Font.Gotham
    dropdownButton.Parent = dropdown
    
    CreateCorner(6).Parent = dropdownButton
    CreateStroke(Config.Colors.Border, 1).Parent = dropdownButton
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -25, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Config.Colors.TextSecondary
    arrow.TextScaled = true
    arrow.Font = Enum.Font.Gotham
    arrow.Parent = dropdownButton
    
    local dropdownList = Instance.new("Frame")
    dropdownList.Size = UDim2.new(1, 0, 0, #options * 30)
    dropdownList.Position = UDim2.new(0, 0, 1, 5)
    dropdownList.BackgroundColor3 = Config.Colors.Background
    dropdownList.BorderSizePixel = 0
    dropdownList.Visible = false
    dropdownList.ZIndex = 10
    dropdownList.Parent = dropdownButton
    
    CreateCorner(6).Parent = dropdownList
    CreateStroke(Config.Colors.Border, 1).Parent = dropdownList
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = dropdownList
    
    local currentValue = default or options[1]
    local isOpen = false
    
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, 0, 0, 30)
        optionButton.BackgroundColor3 = Config.Colors.Background
        optionButton.BorderSizePixel = 0
        optionButton.Text = option
        optionButton.TextColor3 = Config.Colors.Text
        optionButton.TextScaled = true
        optionButton.Font = Enum.Font.Gotham
        optionButton.LayoutOrder = i
        optionButton.Parent = dropdownList
        
        self:AddHoverEffect(optionButton, Config.Colors.Background, Config.Colors.Hover)
        
        optionButton.MouseButton1Click:Connect(function()
            currentValue = option
            dropdownButton.Text = option
            dropdownList.Visible = false
            isOpen = false
            CreateTween(arrow, {Rotation = 0}):Play()
            
            if callback then callback(option) end
        end)
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        dropdownList.Visible = isOpen
        CreateTween(arrow, {Rotation = isOpen and 180 or 0}):Play()
    end)
    
    self:AddHoverEffect(dropdownButton, Config.Colors.Background, Config.Colors.Hover)
    
    table.insert(section.Components, dropdown)
    return dropdown, function() return currentValue end
end

function Window:AddInput(sectionName, text, placeholder, callback)
    local section = self.Sections[self.CurrentTab] and self.Sections[self.CurrentTab][sectionName]
    if not section then return end
    
    local input = Instance.new("Frame")
    input.Name = "Input_" .. text
    input.Size = UDim2.new(1, 0, 0, Config.Sizes.ComponentHeight)
    input.BackgroundTransparency = 1
    input.LayoutOrder = #section.Components + 1
    input.Parent = section.Container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.3, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Config.Colors.Text
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = input
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.7, -10, 1, 0)
    textBox.Position = UDim2.new(0.3, 5, 0, 0)
    textBox.BackgroundColor3 = Config.Colors.Background
    textBox.BorderSizePixel = 0
    textBox.Text = ""
    textBox.PlaceholderText = placeholder or "Enter text..."
    textBox.TextColor3 = Config.Colors.Text
    textBox.PlaceholderColor3 = Config.Colors.TextSecondary
    textBox.TextScaled = true
    textBox.Font = Enum.Font.Gotham
    textBox.ClearTextOnFocus = false
    textBox.Parent = input
    
    CreateCorner(6).Parent = textBox
    CreateStroke(Config.Colors.Border, 1).Parent = textBox
    
    -- Focus effects
    textBox.Focused:Connect(function()
        CreateTween(textBox:FindFirstChild("UIStroke"), {Color = Config.Colors.Accent}):Play()
    end)
    
    textBox.FocusLost:Connect(function()
        CreateTween(textBox:FindFirstChild("UIStroke"), {Color = Config.Colors.Border}):Play()
        if callback then callback(textBox.Text) end
    end)
    
    table.insert(section.Components, input)
    return input, function() return textBox.Text end
end

function Window:AddCheckbox(sectionName, text, default, callback)
    local section = self.Sections[self.CurrentTab] and self.Sections[self.CurrentTab][sectionName]
    if not section then return end
    
    local checkbox = Instance.new("Frame")
    checkbox.Name = "Checkbox_" .. text
    checkbox.Size = UDim2.new(1, 0, 0, Config.Sizes.ComponentHeight)
    checkbox.BackgroundTransparency = 1
    checkbox.LayoutOrder = #section.Components + 1
    checkbox.Parent = section.Container
    
    local checkButton = Instance.new("TextButton")
    checkButton.Size = UDim2.new(0, 25, 0, 25)
    checkButton.Position = UDim2.new(0, 0, 0.5, -12.5)
    checkButton.BackgroundColor3 = Config.Colors.Background
    checkButton.BorderSizePixel = 0
    checkButton.Text = ""
    checkButton.Parent = checkbox
    
    CreateCorner(4).Parent = checkButton
    CreateStroke(Config.Colors.Border, 1).Parent = checkButton
    
    local checkMark = Instance.new("TextLabel")
    checkMark.Size = UDim2.new(1, 0, 1, 0)
    checkMark.Position = UDim2.new(0, 0, 0, 0)
    checkMark.BackgroundTransparency = 1
    checkMark.Text = "✓"
    checkMark.TextColor3 = Config.Colors.Success
    checkMark.TextScaled = true
    checkMark.Font = Enum.Font.GothamBold
    checkMark.Visible = default or false
    checkMark.Parent = checkButton
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -35, 1, 0)
    label.Position = UDim2.new(0, 35, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Config.Colors.Text
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = checkbox
    
    local state = default or false
    
    checkButton.MouseButton1Click:Connect(function()
        state = not state
        checkMark.Visible = state
        
        local strokeColor = state and Config.Colors.Success or Config.Colors.Border
        CreateTween(checkButton:FindFirstChild("UIStroke"), {Color = strokeColor}):Play()
        
        if callback then callback(state) end
    end)
    
    self:AddHoverEffect(checkButton, Config.Colors.Background, Config.Colors.Hover)
    
    table.insert(section.Components, checkbox)
    return checkbox, function() return state end
end

function Window:AddParagraph(sectionName, title, content)
    local section = self.Sections[self.CurrentTab] and self.Sections[self.CurrentTab][sectionName]
    if not section then return end
    
    local paragraph = Instance.new("Frame")
    paragraph.Name = "Paragraph_" .. title
    paragraph.Size = UDim2.new(1, 0, 0, 60)
    paragraph.BackgroundTransparency = 1
    paragraph.LayoutOrder = #section.Components + 1
    paragraph.Parent = section.Container
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 20)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Config.Colors.Text
    titleLabel.TextScaled = true
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = paragraph
    
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, 0, 1, -25)
    contentLabel.Position = UDim2.new(0, 0, 0, 25)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = Config.Colors.TextSecondary
    contentLabel.TextWrapped = true
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextSize = 14
    contentLabel.Parent = paragraph
    
    table.insert(section.Components, paragraph)
    return paragraph
end

function Window:AddKeybind(sectionName, text, default, callback)
    local section = self.Sections[self.CurrentTab] and self.Sections[self.CurrentTab][sectionName]
    if not section then return end
    
    local keybind = Instance.new("Frame")
    keybind.Name = "Keybind_" .. text
    keybind.Size = UDim2.new(1, 0, 0, Config.Sizes.ComponentHeight)
    keybind.BackgroundTransparency = 1
    keybind.LayoutOrder = #section.Components + 1
    keybind.Parent = section.Container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Config.Colors.Text
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = keybind
    
    local keybindButton = Instance.new("TextButton")
    keybindButton.Size = UDim2.new(0, 60, 0, 25)
    keybindButton.Position = UDim2.new(1, -65, 0.5, -12.5)
    keybindButton.BackgroundColor3 = Config.Colors.Background
    keybindButton.BorderSizePixel = 0
    keybindButton.Text = default and default.Name or "None"
    keybindButton.TextColor3 = Config.Colors.Accent
    keybindButton.TextScaled = true
    keybindButton.Font = Enum.Font.GothamBold
    keybindButton.Parent = keybind
    
    CreateCorner(4).Parent = keybindButton
    CreateStroke(Config.Colors.Border, 1).Parent = keybindButton
    
    local currentKey = default
    local listening = false
    
    keybindButton.MouseButton1Click:Connect(function()
        if listening then return end
        
        listening = true
        keybindButton.Text = "Press Key"
        CreateTween(keybindButton:FindFirstChild("UIStroke"), {Color = Config.Colors.Accent}):Play()
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                keybindButton.Text = input.KeyCode.Name
                listening = false
                CreateTween(keybindButton:FindFirstChild("UIStroke"), {Color = Config.Colors.Border}):Play()
                connection:Disconnect()
                
                if callback then callback(currentKey) end
            end
        end)
    end)
    
    self:AddHoverEffect(keybindButton, Config.Colors.Background, Config.Colors.Hover)
    
    table.insert(section.Components, keybind)
    return keybind, function() return currentKey end
end

function Window:AddColorPicker(sectionName, text, default, callback)
    local section = self.Sections[self.CurrentTab] and self.Sections[self.CurrentTab][sectionName]
    if not section then return end
    
    local colorPicker = Instance.new("Frame")
    colorPicker.Name = "ColorPicker_" .. text
    colorPicker.Size = UDim2.new(1, 0, 0, Config.Sizes.ComponentHeight)
    colorPicker.BackgroundTransparency = 1
    colorPicker.LayoutOrder = #section.Components + 1
    colorPicker.Parent = section.Container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Config.Colors.Text
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = colorPicker
    
    local colorButton = Instance.new("TextButton")
    colorButton.Size = UDim2.new(0, 60, 0, 25)
    colorButton.Position = UDim2.new(1, -65, 0.5, -12.5)
    colorButton.BackgroundColor3 = default or Config.Colors.Accent
    colorButton.BorderSizePixel = 0
    colorButton.Text = ""
    colorButton.Parent = colorPicker
    
    CreateCorner(4).Parent = colorButton
    CreateStroke(Color3.new(1, 1, 1), 2).Parent = colorButton
    
    local currentColor = default or Config.Colors.Accent
    
    colorButton.MouseButton1Click:Connect(function()
        -- Simple color cycling for demo (in real implementation, you'd want a proper color picker)
        local colors = {
            Config.Colors.Accent,
            Config.Colors.Success,
            Config.Colors.Destructive,
            Color3.fromRGB(138, 43, 226),
            Color3.fromRGB(30, 144, 255),
            Color3.fromRGB(255, 20, 147)
        }
        
        local currentIndex = 1
        for i, color in ipairs(colors) do
            if color == currentColor then
                currentIndex = i
                break
            end
        end
        
        currentIndex = currentIndex % #colors + 1
        currentColor = colors[currentIndex]
        
        CreateTween(colorButton, {BackgroundColor3 = currentColor}):Play()
        
        if callback then callback(currentColor) end
    end)
    
    table.insert(section.Components, colorPicker)
    return colorPicker, function() return currentColor end
end

function Window:AddStatus(sectionName, text, status)
    local section = self.Sections[self.CurrentTab] and self.Sections[self.CurrentTab][sectionName]
    if not section then return end
    
    local statusFrame = Instance.new("Frame")
    statusFrame.Name = "Status_" .. text
    statusFrame.Size = UDim2.new(1, 0, 0, Config.Sizes.ComponentHeight)
    statusFrame.BackgroundTransparency = 1
    statusFrame.LayoutOrder = #section.Components + 1
    statusFrame.Parent = section.Container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Config.Colors.Text
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = statusFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0.4, 0, 1, 0)
    statusLabel.Position = UDim2.new(0.6, 0, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = status or "Unknown"
    statusLabel.TextColor3 = status == "Confirmed" and Config.Colors.Success or Config.Colors.TextSecondary
    statusLabel.TextScaled = true
    statusLabel.TextXAlignment = Enum.TextXAlignment.Right
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.Parent = statusFrame
    
    table.insert(section.Components, statusFrame)
    
    return statusFrame, function(newStatus)
        statusLabel.Text = newStatus
        statusLabel.TextColor3 = newStatus == "Confirmed" and Config.Colors.Success or Config.Colors.TextSecondary
    end
end

function Window:CreateNotification(title, content, duration)
    duration = duration or 3
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 300, 0, 80)
    notification.Position = UDim2.new(1, -320, 1, -100)
    notification.BackgroundColor3 = Config.Colors.Secondary
    notification.BorderSizePixel = 0
    notification.Parent = self.ScreenGui
    
    CreateCorner(8).Parent = notification
    CreateStroke(Config.Colors.Border, 1).Parent = notification
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 0, 25)
    titleLabel.Position = UDim2.new(0, 5, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Config.Colors.Text
    titleLabel.TextScaled = true
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = notification
    
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -10, 1, -30)
    contentLabel.Position = UDim2.new(0, 5, 0, 25)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = Config.Colors.TextSecondary
    contentLabel.TextWrapped = true
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextSize = 12
    contentLabel.Parent = notification
    
    -- Slide in animation
    notification.Position = UDim2.new(1, 0, 1, -100)
    CreateTween(notification, {Position = UDim2.new(1, -320, 1, -100)}, 0.3):Play()
    
    -- Auto dismiss
    task.wait(duration)
    CreateTween(notification, {Position = UDim2.new(1, 0, 1, -100)}, 0.3):Play()
    task.wait(0.3)
    notification:Destroy()
end

function Window:Destroy()
    if self.ScreenGui then
        CreateTween(self.MainFrame, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, 0.3):Play()
        
        task.wait(0.3)
        self.ScreenGui:Destroy()
    end
end

-- Main Library Interface
function MonkeUI:CreateWindow(title, initialTab)
    return Window.new(title, initialTab)
end

function MonkeUI:SetTheme(newColors)
    for colorName, color in pairs(newColors) do
        if Config.Colors[colorName] then
            Config.Colors[colorName] = color
        end
    end
end

-- Return the library
return MonkeUI

--[[
USAGE EXAMPLE:

local MonkeUI = require(script.MonkeUI)

-- Create window
local window = MonkeUI:CreateWindow("My Application", "Main")

-- Create sections
local section1 = window:CreateSection("Section 1")
local section2 = window:CreateSection("Section 2")

-- Add components
window:AddButton("Section 1", "Primary Button", function()
    print("Primary button clicked!")
end)

window:AddButton("Section 1", "Destructive Button", function()
    print("Destructive button clicked!")
end, "Destructive")

local toggle, getToggleValue = window:AddToggle("Section 1", "Toggle Feature", false, function(state)
    print("Toggle:", state)
end)

local slider, getSliderValue = window:AddSlider("Section 1", "Slider", 0, 100, 50, function(value)
    print("Slider value:", value)
end)

local dropdown, getDropdownValue = window:AddDropdown("Section 2", "Dropdown", {"Option 1", "Option 2", "Option 3"}, "Option 1", function(selected)
    print("Selected:", selected)
end)

local input, getInputValue = window:AddInput("Section 2", "Input", "Enter something...", function(text)
    print("Input:", text)
end)

local checkbox, getCheckboxValue = window:AddCheckbox("Section 2", "Checkbox", false, function(checked)
    print("Checkbox:", checked)
end)

window:AddParagraph("Section 2", "Information", "This is a paragraph with some information about the application.")

local keybind, getKeybindValue = window:AddKeybind("Section 2", "Keybind", Enum.KeyCode.F, function(key)
    print("Keybind set to:", key.Name)
end)

local colorPicker, getColorValue = window:AddColorPicker("Section 2", "Color", Color3.fromRGB(255, 121, 63), function(color)
    print("Color selected:", color)
end)

local status, setStatus = window:AddStatus("Section 2", "Status", "Confirmed")

-- Create another tab
window:CreateTab("Settings")
local settingsSection = window:CreateSection("Configuration")

window:AddButton("Configuration", "Save Settings", function()
    window:CreateNotification("Success", "Settings saved successfully!", 2)
end)

-- Custom theme example
MonkeUI:SetTheme({
    Accent = Color3.fromRGB(138, 43, 226),
    AccentHover = Color3.fromRGB(155, 60, 243)
})
]]