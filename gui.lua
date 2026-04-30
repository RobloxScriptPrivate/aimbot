-- Manus GUI Library V8 - Correção final e completa.
-- AddDropdown e todas as outras funções estão 100% implementadas.

local Library = {}

--==================================================================================================
-- SERVIÇOS E CONFIGURAÇÕES
--==================================================================================================
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

Library.OpenKey = Enum.KeyCode.Insert
Library.Categories = {}
Library.Windows = {}
Library.Keybinds = {}
Library.Visible = true

-- Layout
Library.CategoryStartX = 10
Library.CategoryStartY = 70
Library.CategoryWidth = 170 -- Aumentado para melhor espaço
Library.CategorySpacing = 15
Library.NextCategoryX = Library.CategoryStartX

-- Tema
Library.Theme = {
    Background = Color3.fromRGB(30, 30, 40),
    Header = Color3.fromRGB(40, 40, 50),
    Options = Color3.fromRGB(35, 35, 45),
    Module = Color3.fromRGB(45, 45, 55),
    SubComponent = Color3.fromRGB(50, 50, 60),
    Accent = Color3.fromRGB(80, 160, 255),
    AccentDark = Color3.fromRGB(60, 60, 70),
    Text = Color3.fromRGB(255, 255, 255),
    TextInactive = Color3.fromRGB(200, 200, 200),
    TextSubtle = Color3.fromRGB(150, 150, 150),
    Font = Enum.Font.SourceSans,
    FontBold = Enum.Font.SourceSansBold
}

--==================================================================================================
-- GUI E UTILITÁRIOS
--==================================================================================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "ManusGuiLib_V8"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundTransparency = 1
MainFrame.Visible = Library.Visible
MainFrame.Active = true

local function makeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, dragStart, startPos = true, input.Position, frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + (input.Position - dragStart).X, startPos.Y.Scale, startPos.Y.Offset + (input.Position - dragStart).Y)
            frame.Position = newPos
        end
    end)
end

--==================================================================================================
-- API PRINCIPAL
--==================================================================================================
function Library:CreateCategory(name)
    local position = UDim2.new(0, Library.NextCategoryX, 0, Library.CategoryStartY)
    Library.NextCategoryX = Library.NextCategoryX + Library.CategoryWidth + Library.CategorySpacing

    local CategoryFrame = Instance.new("Frame", MainFrame)
    CategoryFrame.Name = name
    CategoryFrame.Size = UDim2.new(0, Library.CategoryWidth, 0, 30)
    CategoryFrame.Position = position
    CategoryFrame.BackgroundColor3 = Library.Theme.Header
    CategoryFrame.BorderSizePixel = 0
    CategoryFrame.Active = true
    Instance.new("UICorner", CategoryFrame).CornerRadius = UDim.new(0, 4)

    local Title = Instance.new("TextButton", CategoryFrame)
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.Text = name
    Title.TextColor3 = Library.Theme.Text
    Title.Font = Library.Theme.FontBold
    Title.TextSize = 16
    Title.BackgroundTransparency = 1
    Title.AutoButtonColor = false
    
    local OptionsFrame = Instance.new("Frame", CategoryFrame)
    OptionsFrame.Name = "Options"
    OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
    OptionsFrame.Position = UDim2.new(0, 0, 1, 5)
    OptionsFrame.BackgroundColor3 = Library.Theme.Options
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.ClipsDescendants = true
    OptionsFrame.Visible = false -- Começa fechado
    
    local UIListLayout = Instance.new("UIListLayout", OptionsFrame)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    makeDraggable(CategoryFrame, Title)
    
    local categoryObj = { Frame = CategoryFrame, Options = OptionsFrame, Expanded = false, Modules = {} }
    
    local function resizeCategory(instant)
        if not categoryObj.Expanded then return end
        local totalHeight = UIListLayout.AbsoluteContentSize.Y + 10
        local time = instant and 0 or 0.15
        OptionsFrame:TweenSize(UDim2.new(1, -10, 0, totalHeight), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, time, true)
    end

    Title.MouseButton1Click:Connect(function()
        categoryObj.Expanded = not categoryObj.Expanded
        OptionsFrame.Visible = categoryObj.Expanded
        local newHeight = categoryObj.Expanded and (UIListLayout.AbsoluteContentSize.Y + 10) or 0
        OptionsFrame:TweenSize(UDim2.new(1, -10, 0, newHeight), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
    end)
    
    function categoryObj:AddModule(moduleName, callback, isTrigger)
        local ModuleFrame = Instance.new("Frame", OptionsFrame)
        ModuleFrame.Name = moduleName
        ModuleFrame.Size = UDim2.new(1, -10, 0, 35) -- Base height
        ModuleFrame.BackgroundColor3 = Library.Theme.Module
        ModuleFrame.ClipsDescendants = true
        Instance.new("UICorner", ModuleFrame).CornerRadius = UDim.new(0, 3)

        local moduleObj = { active = false, frame = ModuleFrame, components = {} }
        
        local componentsLayout = Instance.new("UIListLayout", ModuleFrame)
        componentsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        componentsLayout.Padding = UDim.new(0, 3)
        componentsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local HeaderFrame = Instance.new("Frame", ModuleFrame)
        HeaderFrame.Name = "Header"
        HeaderFrame.Size = UDim2.new(1, 0, 0, 30)
        HeaderFrame.BackgroundTransparency = 1
        HeaderFrame.LayoutOrder = -100 -- Garante que o Header fique no topo

        local HeaderLabel = Instance.new("TextLabel", HeaderFrame)
        HeaderLabel.Size = UDim2.new(1, -50, 1, 0)
        HeaderLabel.Position = UDim2.new(0, 5, 0, 0)
        HeaderLabel.Text = moduleName
        HeaderLabel.TextColor3 = Library.Theme.Text
        HeaderLabel.Font = Library.Theme.FontBold
        HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
        HeaderLabel.BackgroundTransparency = 1

        if not isTrigger then
            local Toggle = Instance.new("TextButton", HeaderFrame)
            Toggle.Size = UDim2.new(0, 40, 0, 20)
            Toggle.Position = UDim2.new(1, -45, 0.5, -10)
            Toggle.BackgroundColor3 = Library.Theme.AccentDark
            Toggle.Text = ""
            Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 10)

            local Indicator = Instance.new("Frame", Toggle)
            Indicator.Size = UDim2.new(0, 16, 0, 16)
            Indicator.Position = UDim2.new(0, 2, 0, 2)
            Indicator.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
            Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

            Toggle.MouseButton1Click:Connect(function()
                moduleObj.active = not moduleObj.active
                local pos = moduleObj.active and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
                Indicator:TweenPosition(pos, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
                Indicator.BackgroundColor = moduleObj.active and Library.Theme.Accent or Color3.fromRGB(255, 80, 80)
                if callback then pcall(callback, moduleObj.active) end
            end)
        else
            HeaderLabel.Size = UDim2.new(1, -10, 1, 0)
            local btn = Instance.new("TextButton", HeaderFrame)
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.MouseButton1Click:Connect(function() if callback then pcall(callback) end end)
        end
        
        local function resizeModule()
            local totalHeight = componentsLayout.AbsoluteContentSize.Y
            ModuleFrame.Size = UDim2.new(1, -10, 0, totalHeight)
            resizeCategory(true)
        end
        
        function moduleObj:AddButton(text, btnCallback)
            local Button = Instance.new("TextButton", ModuleFrame)
            Button.Name = text
            Button.Size = UDim2.new(1, -10, 0, 25)
            Button.BackgroundColor3 = Library.Theme.SubComponent
            Button.TextColor3 = Library.Theme.Text
            Button.Text = text
            Button.Font = Library.Theme.Font
            Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 3)
            Button.LayoutOrder = 1
            if btnCallback then Button.MouseButton1Click:Connect(btnCallback) end
            resizeModule()
            return Button
        end

        function moduleObj:AddToggle(label, initialValue, toggleCallback)
            local state = initialValue
            local CompFrame = Instance.new("Frame", ModuleFrame)
            CompFrame.Size = UDim2.new(1, -10, 0, 25)
            CompFrame.BackgroundTransparency = 1
            CompFrame.LayoutOrder = 2
            
            local Label = Instance.new("TextLabel", CompFrame)
            Label.Size = UDim2.new(1, -35, 1, 0)
            Label.Position = UDim2.new(0, 5, 0, 0)
            Label.Text = label
            Label.Font = Library.Theme.Font
            Label.TextColor3 = Library.Theme.TextInactive
            Label.BackgroundTransparency = 1
            Label.TextXAlignment = Enum.TextXAlignment.Left
            
            local Check = Instance.new("TextButton", CompFrame)
            Check.Size = UDim2.new(0, 20, 0, 20)
            Check.Position = UDim2.new(1, -25, 0.5, -10)
            Check.BackgroundColor3 = state and Library.Theme.Accent or Library.Theme.AccentDark
            Check.Text = state and "✓" or ""
            Check.Font = Library.Theme.FontBold
            Check.TextColor3 = Library.Theme.Background
            Instance.new("UICorner", Check).CornerRadius = UDim.new(0, 3)
            
            Check.MouseButton1Click:Connect(function()
                state = not state
                Check.BackgroundColor3 = state and Library.Theme.Accent or Library.Theme.AccentDark
                Check.Text = state and "✓" or ""
                if toggleCallback then pcall(toggleCallback, state) end
            end)
            if toggleCallback then pcall(toggleCallback, state) end -- Call once on start
            resizeModule()
        end

        function moduleObj:AddSlider(label, min, max, initialValue, sliderCallback)
            local CompFrame = Instance.new("Frame", ModuleFrame)
            CompFrame.Size = UDim2.new(1, -10, 0, 40)
            CompFrame.BackgroundTransparency = 1
            CompFrame.LayoutOrder = 3

            local Label = Instance.new("TextLabel", CompFrame)
            Label.Size = UDim2.new(1, -10, 0, 20)
            Label.Position = UDim2.new(0, 5, 0, 0)
            Label.Font = Library.Theme.Font
            Label.TextColor3 = Library.Theme.TextInactive
            Label.BackgroundTransparency = 1
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local Slider = Instance.new("TextButton", CompFrame) -- TextButton for better input detection
            Slider.Size = UDim2.new(1, -10, 0, 8)
            Slider.Position = UDim2.new(0, 5, 0, 20)
            Slider.BackgroundColor3 = Library.Theme.AccentDark
            Slider.AutoButtonColor = false
            Slider.Text = ""
            Instance.new("UICorner", Slider).CornerRadius = UDim.new(1)
            
            local Fill = Instance.new("Frame", Slider)
            Fill.BackgroundColor3 = Library.Theme.Accent
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1)
            
            local Handle = Instance.new("Frame", Slider)
            Handle.Size = UDim2.new(0, 14, 0, 14)
            Handle.Position = UDim2.new(0, -7, 0.5, -7)
            Handle.BackgroundColor3 = Library.Theme.Text
            Handle.BorderSizePixel = 2
            Handle.BorderColor3 = Library.Theme.Accent
            Instance.new("UICorner", Handle).CornerRadius = UDim.new(1)

            local function UpdateSlider(value, fromInput)
                local percent = (value - min) / (max - min)
                Label.Text = string.format("%s: %.1f", label, value)
                Fill.Size = UDim2.new(percent, 0, 1, 0)
                Handle.Position = UDim2.new(percent, -7, 0.5, -7)
                if not fromInput and sliderCallback then pcall(sliderCallback, value) end
            end
            
            local function SetValueFromMouse(input)
                local percent = math.clamp((input.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
                local value = min + (max - min) * percent
                UpdateSlider(value, false)
            end

            local dragging = false
            Slider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then 
                    dragging = true
                    SetValueFromMouse(input)
                end
            end)
            Slider.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            Slider.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    SetValueFromMouse(input)
                end
            end)
            
            UpdateSlider(initialValue, true)
            if sliderCallback then pcall(sliderCallback, initialValue) end -- Call once on start
            resizeModule()
        end
        
        function moduleObj:AddDropdown(label, options, dropdownCallback)
            local state = { open = false, selected = options[1] }
            
            local CompFrame = Instance.new("Frame", ModuleFrame)
            CompFrame.Size = UDim2.new(1, -10, 0, 30)
            CompFrame.BackgroundTransparency = 1
            CompFrame.ClipsDescendants = true
            CompFrame.LayoutOrder = 4

            local DropdownButton = Instance.new("TextButton", CompFrame)
            DropdownButton.Size = UDim2.new(1, 0, 1, 0)
            DropdownButton.BackgroundColor3 = Library.Theme.SubComponent
            DropdownButton.TextColor3 = Library.Theme.TextInactive
            DropdownButton.Font = Library.Theme.Font
            Instance.new("UICorner", DropdownButton).CornerRadius = UDim.new(0, 3)
            
            local OptionsFrame = Instance.new("Frame", CompFrame)
            OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
            OptionsFrame.Position = UDim2.new(0, 0, 1, 2)
            OptionsFrame.BackgroundColor3 = Library.Theme.SubComponent
            OptionsFrame.BorderSizePixel = 0
            OptionsFrame.ClipsDescendants = true
            OptionsFrame.Visible = false
            Instance.new("UICorner", OptionsFrame).CornerRadius = UDim.new(0, 3)
            local optionsLayout = Instance.new("UIListLayout", OptionsFrame)
            optionsLayout.Padding = UDim.new(0, 2)

            local function updateText()
                DropdownButton.Text = string.format("%s: %s ▼", label, tostring(state.selected))
            end

            local function closeDropdown()
                state.open = false
                OptionsFrame.Visible = false
                CompFrame:TweenSize(UDim2.new(1, -10, 0, 30), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true, function() resizeModule() end)
            end
            
            for _, optionName in ipairs(options) do
                local OptionButton = Instance.new("TextButton", OptionsFrame)
                OptionButton.Size = UDim2.new(1, 0, 0, 25)
                OptionButton.BackgroundColor3 = Library.Theme.SubComponent
                OptionButton.TextColor3 = Library.Theme.TextInactive
                OptionButton.Font = Library.Theme.Font
                OptionButton.Text = tostring(optionName)
                OptionButton.MouseButton1Click:Connect(function()
                    state.selected = optionName
                    updateText()
                    closeDropdown()
                    if dropdownCallback then pcall(dropdownCallback, state.selected) end
                end)
            end
            
            DropdownButton.MouseButton1Click:Connect(function()
                state.open = not state.open
                OptionsFrame.Visible = state.open
                if state.open then
                    local optionsHeight = optionsLayout.AbsoluteContentSize.Y + 4
                    CompFrame:TweenSize(UDim2.new(1, -10, 0, 32 + optionsHeight), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true, function() resizeModule() end)
                else
                    closeDropdown()
                end
            end)

            updateText()
            if dropdownCallback then pcall(dropdownCallback, state.selected) end -- Call on start
            resizeModule()
        end
        
        function moduleObj:AddKeybind(label, defaultKey, keybindCallback)
             Library:AddKeybind(moduleName .. ": " .. label, defaultKey, keybindCallback)
        end

        resizeModule()
        RunService.RenderStepped:Wait()
        resizeModule()

        return moduleObj
    end
    
    -- Abre a categoria por padrão para mostrar o conteúdo
    Title.MouseButton1Click:Invoke()

    return categoryObj
end

function Library:CreateWindow(title, size)
    local winSize = size or UDim2.new(0, 300, 0, 250)
    local WindowFrame = Instance.new("Frame", MainFrame)
    WindowFrame.Size = winSize
    WindowFrame.Position = UDim2.new(0.5, -winSize.X.Offset / 2, 0.5, -winSize.Y.Offset / 2)
    WindowFrame.BackgroundColor3 = Library.Theme.Background
    WindowFrame.Active = true
    WindowFrame.ClipsDescendants = true
    Instance.new("UICorner", WindowFrame).CornerRadius = UDim.new(0, 4)

    local TitleBar = Instance.new("Frame", WindowFrame)
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Library.Theme.Header

    local TitleLabel = Instance.new("TextLabel", TitleBar)
    TitleLabel.Size = UDim2.new(1, -30, 1, 0)
    TitleLabel.Position = UDim2.new(0, 5, 0, 0)
    TitleLabel.Text = title
    TitleLabel.Font = Library.Theme.FontBold
    TitleLabel.TextColor3 = Library.Theme.Text
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local CloseBtn = Instance.new("TextButton", TitleBar)
    CloseBtn.Size = UDim2.new(0, 30, 1, 0)
    CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    CloseBtn.Text = "X"
    CloseBtn.Font = Library.Theme.FontBold
    CloseBtn.TextColor3 = Library.Theme.Text
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.MouseButton1Click:Connect(function() WindowFrame:Destroy() end)

    makeDraggable(WindowFrame, TitleBar)

    local ContentFrame = Instance.new("ScrollingFrame", WindowFrame)
    ContentFrame.Size = UDim2.new(1, 0, 1, -35)
    ContentFrame.Position = UDim2.new(0, 0, 0, 35)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.BorderSizePixel = 0
    local layout = Instance.new("UIListLayout", ContentFrame)
    layout.Padding = UDim.new(0, 5)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local windowObj = { Frame = WindowFrame, Content = ContentFrame }
    
    function windowObj:AddButton(text, callback)
        local btn = Instance.new("TextButton", ContentFrame)
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.BackgroundColor3 = Library.Theme.SubComponent
        btn.TextColor3 = Library.Theme.Text
        btn.Text = text
        btn.Font = Library.Theme.Font
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
        if callback then btn.MouseButton1Click:Connect(callback) end
        return btn
    end
    
    function windowObj:AddTextBox(placeholder, callback)
        local box = Instance.new("TextBox", ContentFrame)
        box.Size = UDim2.new(1, -10, 0, 30)
        box.BackgroundColor3 = Library.Theme.SubComponent
        box.TextColor3 = Library.Theme.Text
        box.PlaceholderText = placeholder
        box.PlaceholderColor3 = Library.Theme.TextSubtle
        box.Font = Library.Theme.Font
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 3)
        if callback then box.FocusLost:Connect(function(enterPressed) if enterPressed then callback(box.Text) end end) end
        return box
    end

    return windowObj
end

function Library:AddKeybind(label, defaultKey, callback)
    if not label or not defaultKey or not callback then return end
    local keybind = { label = label, key = defaultKey, callback = callback }
    table.insert(Library.Keybinds, keybind)
end

--==================================================================================================
-- INPUT HANDLING
--==================================================================================================
Library:AddKeybind("Abrir/Fechar Menu", Library.OpenKey, function()
    Library.Visible = not Library.Visible
    MainFrame.Visible = Library.Visible
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    for _, bind in ipairs(Library.Keybinds) do
        if input.KeyCode == bind.key then
            pcall(bind.callback)
        end
    end
end)

print("✅ Manus GUI Library V8 Carregada. Correção final.")
return Library
