-- Manus GUI Library V4.1 (Com Janelas Reutilizáveis)
-- Hospedagem: https://raw.githubusercontent.com/Neospeed1kk/RochaFace/refs/heads/main/gui.lua

local Library = {}

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- Configurações Internas
Library.OpenKey = Enum.KeyCode.Insert
Library.RemoveKey = Enum.KeyCode.K
Library.Categories = {}
Library.ActiveWindows = {} -- Rastreia janelas abertas

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

-- [[ NOVO ]] Função para criar Janelas Genéricas
function Library:CreateWindow(title, size, position)
    -- Impede a criação de múltiplas janelas com o mesmo título
    if Library.ActiveWindows[title] and Library.ActiveWindows[title].Parent then
        return Library.ActiveWindows[title]
    end

    local WindowFrame = Instance.new("Frame")
    WindowFrame.Name = title .. "Window"
    WindowFrame.Size = size or UDim2.new(0, 350, 0, 300)
    WindowFrame.Position = position or UDim2.new(0.5, -175, 0.5, -150)
    WindowFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    WindowFrame.BorderSizePixel = 0
    WindowFrame.Visible = true
    WindowFrame.Parent = MainFrame
    Instance.new("UICorner", WindowFrame)

    local TitleBar = Instance.new("TextLabel")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.Text = title
    TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TitleBar.Font = Enum.Font.SourceSansBold
    TitleBar.TextSize = 20
    TitleBar.Parent = WindowFrame

    makeDraggable(WindowFrame, TitleBar)

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 40, 0, 40)
    CloseButton.Position = UDim2.new(1, -40, 0, 0)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.BackgroundTransparency = 1
    CloseButton.TextSize = 20
    CloseButton.Parent = TitleBar
    CloseButton.ZIndex = 2
    CloseButton.MouseButton1Click:Connect(function()
        WindowFrame:Destroy()
        Library.ActiveWindows[title] = nil
    end)

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "Content"
    ContentFrame.Size = UDim2.new(1, 0, 1, -40)
    ContentFrame.Position = UDim2.new(0, 0, 0, 40)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = WindowFrame
    Instance.new("UIListLayout", ContentFrame).Padding = UDim.new(0, 5)

    -- Armazena a referência da janela para evitar duplicatas
    Library.ActiveWindows[title] = WindowFrame
    
    local windowObj = {
        Frame = WindowFrame,
        Content = ContentFrame
    }

    function windowObj:AddButton(text, callback)
        local Button = Instance.new("TextButton")
        Button.Name = text .. "_Button"
        Button.Size = UDim2.new(0.9, 0, 0, 30)
        Button.Position = UDim2.new(0.05, 0, 0, 0)
        Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Button.TextColor3 = Color3.fromRGB(220, 220, 220)
        Button.Text = text
        Button.Font = Enum.Font.SourceSansBold
        Button.Parent = ContentFrame
        if callback then Button.MouseButton1Click:Connect(callback) end
        return Button
    end
    
    function windowObj:AddTextBox(placeholder)
        local TextBox = Instance.new("TextBox")
        TextBox.Name = placeholder .. "_TextBox"
        TextBox.Size = UDim2.new(0.9, 0, 0, 35)
        TextBox.Position = UDim2.new(0.05, 0, 0, 0)
        TextBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        TextBox.PlaceholderText = placeholder
        TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextBox.Font = Enum.Font.SourceSans
        TextBox.Parent = ContentFrame
        return TextBox
    end
    
    return windowObj
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

-- [[ ATUALIZADO ]] Tela de Configurações agora usa CreateWindow
local KeybindContainer -- Definido fora para ser acessado por AddKeybind

local function openSettingsWindow()
    if Library.ActiveWindows["Configurações & Keybinds"] then return end

    local settingsWindow = Library:CreateWindow("Configurações & Keybinds", UDim2.new(0, 350, 0, 300), UDim2.new(0.5, -175, 0.5, -150))
    
    KeybindContainer = Instance.new("ScrollingFrame")
    KeybindContainer.Size = UDim2.new(1, 0, 1, 0)
    KeybindContainer.BackgroundTransparency = 1
    KeybindContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    KeybindContainer.ScrollBarThickness = 2
    KeybindContainer.Parent = settingsWindow.Content
    
    local KeybindList = Instance.new("UIListLayout")
    KeybindList.Padding = UDim.new(0, 5)
    KeybindList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    KeybindList.Parent = KeybindContainer

    -- Readiciona os keybinds à nova janela
    Library:RebindKeys()
end

SettingsBtn.MouseButton1Click:Connect(openSettingsWindow)

-- Função para adicionar Keybind. Adaptada para funcionar com a janela.
function Library:AddKeybind(label, defaultKey, callback)
    if not KeybindContainer or not KeybindContainer.Parent then
        -- Se a janela não estiver aberta, armazena para depois
        Library.PendingBinds = Library.PendingBinds or {}
        table.insert(Library.PendingBinds, {label=label, key=defaultKey, cb=callback})
        return
    end

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0.9, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.Parent = KeybindContainer
    
    local TextLabel = Instance.new("TextLabel", Frame)
    TextLabel.Size = UDim2.new(0.6, 0, 1, 0)
    TextLabel.Text = label
    TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.TextSize = 16
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.BackgroundTransparency = 1
    
    local BindBtn = Instance.new("TextButton", Frame)
    BindBtn.Size = UDim2.new(0.35, 0, 0.8, 0)
    BindBtn.Position = UDim2.new(0.65, 0, 0.1, 0)
    BindBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    BindBtn.Text = defaultKey and defaultKey.Name or "None"
    BindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    BindBtn.Font = Enum.Font.SourceSansBold
    
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
    
    KeybindContainer.CanvasSize = UDim2.new(0, 0, 0, KeybindContainer.UIListLayout.AbsoluteContentSize.Y + 10)
end

-- Adiciona os keybinds pendentes quando a janela for criada
function Library:RebindKeys()
    if not Library.PendingBinds then return end
    for _, bindInfo in ipairs(Library.PendingBinds) do
        Library:AddKeybind(bindInfo.label, bindInfo.key, bindInfo.cb)
    end
    -- Limpa para não adicionar duas vezes
    Library.PendingBinds = {}
end

-- Função para criar Categoria (sem alterações)
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

        function moduleObj:Execute()
            if self.IsTrigger then
                local oldColor = ModuleBtn.TextColor3
                ModuleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                task.delay(0.1, function() ModuleBtn.TextColor3 = oldColor end)
                if callback then callback() end
            else
                self.Enabled = not self.Enabled
                ModuleBtn.TextColor3 = self.Enabled and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(200, 200, 200)
                if callback then callback(self.Enabled) end
            end
        end

        ModuleBtn.MouseButton1Click:Connect(function() moduleObj:Execute() end)
        
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
        
        -- Componentes (não precisam de alteração)
        function moduleObj:AddSlider(name, min, max, default, cb) end
        function moduleObj:AddDropdown(name, options, cb) end
        function moduleObj:AddToggle(name, default, cb) end

        updateCategorySize()
        return moduleObj
    end
    
    return categoryObj
end

-- Atalhos Globais Iniciais (Armazenados para re-binding)
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
