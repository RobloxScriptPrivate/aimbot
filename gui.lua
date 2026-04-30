-- Manus GUI Library V4 (Suporte a Trigger e Toggle)
-- Hospedagem: https://raw.githubusercontent.com/Neospeed1kk/RochaFace/refs/heads/main/gui.lua

local Library = {}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- Configurações Internas
Library.OpenKey = Enum.KeyCode.Insert
Library.RemoveKey = Enum.KeyCode.K
Library.Categories = {}
Library.SettingsOpen = false

-- Criar ScreenGui Principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ManusGuiLib"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success, err = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = player:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundTransparency = 1
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- Funções Utilitárias
local function makeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(0, 400, 0, 40)
TopBar.Position = UDim2.new(0.5, -200, 0, 20)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 6)

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0.8, -10, 0.7, 0)
SearchBox.Position = UDim2.new(0.05, 0, 0.15, 0)
SearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SearchBox.PlaceholderText = "Pesquisar módulos..."
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.Font = Enum.Font.SourceSans
SearchBox.TextSize = 16
SearchBox.Parent = TopBar

local SettingsBtn = Instance.new("TextButton")
SettingsBtn.Size = UDim2.new(0.1, 0, 0.7, 0)
SettingsBtn.Position = UDim2.new(0.87, 0, 0.15, 0)
SettingsBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SettingsBtn.Text = "⚙️"
SettingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsBtn.TextSize = 20
SettingsBtn.Parent = TopBar

-- Tela de Configurações
local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(0, 350, 0, 300)
SettingsFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SettingsFrame.BorderSizePixel = 0
SettingsFrame.Visible = false
SettingsFrame.Parent = MainFrame
Instance.new("UICorner", SettingsFrame)

local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Size = UDim2.new(1, 0, 0, 40)
SettingsTitle.Text = "Configurações & Keybinds"
SettingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SettingsTitle.Font = Enum.Font.SourceSansBold
SettingsTitle.TextSize = 20
SettingsTitle.Parent = SettingsFrame

local CloseSettings = Instance.new("TextButton")
CloseSettings.Size = UDim2.new(0, 40, 0, 40)
CloseSettings.Position = UDim2.new(1, -40, 0, 0)
CloseSettings.Text = "X"
CloseSettings.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseSettings.BackgroundTransparency = 1
CloseSettings.TextSize = 20
CloseSettings.Parent = SettingsFrame

local KeybindContainer = Instance.new("ScrollingFrame")
KeybindContainer.Size = UDim2.new(1, 0, 1, -40)
KeybindContainer.Position = UDim2.new(0, 0, 0, 40)
KeybindContainer.BackgroundTransparency = 1
KeybindContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
KeybindContainer.ScrollBarThickness = 2
KeybindContainer.Parent = SettingsFrame

local KeybindList = Instance.new("UIListLayout")
KeybindList.Padding = UDim.new(0, 5)
KeybindList.HorizontalAlignment = Enum.HorizontalAlignment.Center
KeybindList.Parent = KeybindContainer

-- Função para adicionar Keybind na Settings
function Library:AddKeybind(label, defaultKey, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0.9, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.Parent = KeybindContainer
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(0.6, 0, 1, 0)
    TextLabel.Text = label
    TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.TextSize = 16
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.BackgroundTransparency = 1
    TextLabel.Parent = Frame
    
    local BindBtn = Instance.new("TextButton")
    BindBtn.Size = UDim2.new(0.35, 0, 0.8, 0)
    BindBtn.Position = UDim2.new(0.65, 0, 0.1, 0)
    BindBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    BindBtn.Text = defaultKey and defaultKey.Name or "None"
    BindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    BindBtn.Font = Enum.Font.SourceSansBold
    BindBtn.Parent = Frame
    
    local currentKey = defaultKey
    local binding = false
    
    BindBtn.MouseButton1Click:Connect(function()
        binding = true
        BindBtn.Text = "..."
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if binding and input.UserInputType == Enum.UserInputType.Keyboard then
            binding = false
            currentKey = input.KeyCode
            BindBtn.Text = currentKey.Name
            if callback then callback(currentKey, false) end -- Apenas mudou a tecla
        elseif not gameProcessed and currentKey and input.KeyCode == currentKey then
            if callback then callback(currentKey, true) end -- Foi pressionado
        end
    end)
    
    KeybindContainer.CanvasSize = UDim2.new(0, 0, 0, KeybindList.AbsoluteContentSize.Y + 10)
end

-- Lógica de Settings
SettingsBtn.MouseButton1Click:Connect(function()
    Library.SettingsOpen = not Library.SettingsOpen
    SettingsFrame.Visible = Library.SettingsOpen
    for _, cat in pairs(Library.Categories) do cat.Visible = not Library.SettingsOpen end
end)

CloseSettings.MouseButton1Click:Connect(function()
    Library.SettingsOpen = false
    SettingsFrame.Visible = false
    for _, cat in pairs(Library.Categories) do cat.Visible = true end
end)

-- Função para criar Categoria
function Library:CreateCategory(name, position)
    local CategoryFrame = Instance.new("Frame")
    CategoryFrame.Name = name
    CategoryFrame.Size = UDim2.new(0, 150, 0, 30)
    CategoryFrame.Position = position
    CategoryFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    CategoryFrame.BorderSizePixel = 0
    CategoryFrame.Active = true
    CategoryFrame.Parent = MainFrame
    
    local Title = Instance.new("TextButton")
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.Text = name
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 18
    Title.BackgroundTransparency = 1
    Title.AutoButtonColor = false
    Title.Parent = CategoryFrame
    
    local OptionsFrame = Instance.new("Frame")
    OptionsFrame.Name = "Options"
    OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
    OptionsFrame.Position = UDim2.new(0, 0, 1, 0)
    OptionsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.ClipsDescendants = true
    OptionsFrame.Parent = CategoryFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = OptionsFrame
    
    makeDraggable(CategoryFrame, Title)
    
    local categoryObj = { Frame = CategoryFrame, Options = OptionsFrame, Expanded = true }
    table.insert(Library.Categories, CategoryFrame)
    
    Title.MouseButton2Click:Connect(function()
        categoryObj.Expanded = not categoryObj.Expanded
        OptionsFrame.Visible = categoryObj.Expanded
    end)
    
    function categoryObj:AddModule(moduleName, callback, isTrigger)
        local moduleObj = { Enabled = false, IsTrigger = isTrigger or false }
        
        local ModuleContainer = Instance.new("Frame")
        ModuleContainer.Size = UDim2.new(1, 0, 0, 25)
        ModuleContainer.BackgroundTransparency = 1
        ModuleContainer.Parent = OptionsFrame
        
        local ModuleBtn = Instance.new("TextButton")
        ModuleBtn.Size = UDim2.new(1, 0, 0, 25)
        ModuleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        ModuleBtn.BorderSizePixel = 0
        ModuleBtn.Text = "  " .. moduleName
        ModuleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        ModuleBtn.Font = Enum.Font.SourceSans
        ModuleBtn.TextSize = 16
        ModuleBtn.TextXAlignment = Enum.TextXAlignment.Left
        ModuleBtn.Parent = ModuleContainer
        
        local SubFrame = Instance.new("Frame")
        SubFrame.Size = UDim2.new(1, 0, 0, 0)
        SubFrame.Position = UDim2.new(0, 0, 0, 25)
        SubFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        SubFrame.BorderSizePixel = 0
        SubFrame.Visible = false
        SubFrame.ClipsDescendants = true
        SubFrame.Parent = ModuleContainer
        Instance.new("UIListLayout", SubFrame)
        
        local function updateCategorySize()
            local total = 0
            for _, v in pairs(OptionsFrame:GetChildren()) do
                if v:IsA("Frame") then total = total + v.Size.Y.Offset end
            end
            OptionsFrame.Size = UDim2.new(1, 0, 0, total)
        end

        -- Função de Execução (Gatilho ou Alternância)
        function moduleObj:Execute()
            if self.IsTrigger then
                -- Se for gatilho, apenas pisca a cor e executa
                local oldColor = ModuleBtn.TextColor3
                ModuleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                task.delay(0.1, function() ModuleBtn.TextColor3 = oldColor end)
                if callback then callback() end
            else
                -- Se for toggle, alterna o estado
                self.Enabled = not self.Enabled
                ModuleBtn.TextColor3 = self.Enabled and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(200, 200, 200)
                if callback then callback(self.Enabled) end
            end
        end

        ModuleBtn.MouseButton1Click:Connect(function()
            moduleObj:Execute()
        end)
        
        ModuleBtn.MouseButton2Click:Connect(function()
            SubFrame.Visible = not SubFrame.Visible
            local subHeight = 0
            if SubFrame.Visible then
                for _, v in pairs(SubFrame:GetChildren()) do
                    if v:IsA("Frame") or v:IsA("TextButton") then subHeight = subHeight + v.Size.Y.Offset end
                end
            end
            SubFrame.Size = UDim2.new(1, 0, 0, subHeight)
            ModuleContainer.Size = UDim2.new(1, 0, 0, 25 + subHeight)
            updateCategorySize()
        end)
        
        -- Componentes (Slider, Dropdown, Toggle)
        function moduleObj:AddSlider(name, min, max, default, cb)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, 0, 0, 30)
            SliderFrame.BackgroundTransparency = 1
            SliderFrame.Parent = SubFrame
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 0, 15)
            Label.Text = "    " .. name .. ": " .. default
            Label.TextColor3 = Color3.fromRGB(150, 150, 150)
            Label.Font = Enum.Font.SourceSans
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = SliderFrame
            local Bar = Instance.new("Frame")
            Bar.Size = UDim2.new(0.8, 0, 0, 4)
            Bar.Position = UDim2.new(0.1, 0, 0.7, 0)
            Bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            Bar.BorderSizePixel = 0
            Bar.Parent = SliderFrame
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
            Fill.BorderSizePixel = 0
            Fill.Parent = Bar
            local sliding = false
            local function update(input)
                local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                local val = math.floor(min + (max - min) * pos)
                Label.Text = "    " .. name .. ": " .. val
                cb(val)
            end
            Bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
            UserInputService.InputChanged:Connect(function(input) if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end)
        end
        
        function moduleObj:AddDropdown(name, options, cb)
            local DropdownBtn = Instance.new("TextButton")
            DropdownBtn.Size = UDim2.new(1, 0, 0, 20)
            DropdownBtn.BackgroundTransparency = 1
            DropdownBtn.Text = "    > " .. name .. ": " .. options[1]
            DropdownBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
            DropdownBtn.Font = Enum.Font.SourceSans
            DropdownBtn.TextSize = 12
            DropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
            DropdownBtn.Parent = SubFrame
            local currentIdx = 1
            DropdownBtn.MouseButton1Click:Connect(function()
                currentIdx = currentIdx + 1
                if currentIdx > #options then currentIdx = 1 end
                DropdownBtn.Text = "    > " .. name .. ": " .. options[currentIdx]
                cb(options[currentIdx])
            end)
        end

        function moduleObj:AddToggle(name, default, cb)
            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Size = UDim2.new(1, 0, 0, 20)
            ToggleBtn.BackgroundTransparency = 1
            ToggleBtn.Text = "    > " .. name .. ": " .. (default and "ON" or "OFF")
            ToggleBtn.TextColor3 = default and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(150, 150, 150)
            ToggleBtn.Font = Enum.Font.SourceSans
            ToggleBtn.TextSize = 12
            ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
            ToggleBtn.Parent = SubFrame
            local state = default
            ToggleBtn.MouseButton1Click:Connect(function()
                state = not state
                ToggleBtn.Text = "    > " .. name .. ": " .. (state and "ON" or "OFF")
                ToggleBtn.TextColor3 = state and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(150, 150, 150)
                cb(state)
            end)
        end

        updateCategorySize()
        return moduleObj
    end
    
    return categoryObj
end

-- Atalhos Globais Iniciais
Library:AddKeybind("Abrir/Fechar Menu", Library.OpenKey, function(key, pressed)
    if pressed then
        MainFrame.Visible = not MainFrame.Visible
        local ModalBtn = Instance.new("TextButton", MainFrame)
        ModalBtn.Size = UDim2.new(0,0,0,0)
        ModalBtn.Modal = MainFrame.Visible
        ModalBtn:Destroy()
    else
        Library.OpenKey = key
    end
end)

Library:AddKeybind("Remover Script", Library.RemoveKey, function(key, pressed)
    if pressed then
        ScreenGui:Destroy()
    else
        Library.RemoveKey = key
    end
end)

return Library
