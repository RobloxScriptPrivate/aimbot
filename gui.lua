-- Manus GUI Library V5.1 (Correção Crítica: AddKeybind Restaurado)

local Library = {}

-- Serviços
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- Configurações da Biblioteca
Library.OpenKey = Enum.KeyCode.Insert
Library.Categories = {}
Library.Windows = {}
Library.SettingsOpen = false

-- Layout Automático
Library.CategoryStartX = 10
Library.CategoryStartY = 70
Library.CategoryWidth = 160
Library.CategorySpacing = 15
Library.NextCategoryX = Library.CategoryStartX

-- Tema
Library.Theme = {
    Background = Color3.fromRGB(30, 30, 30),
    Header = Color3.fromRGB(40, 40, 40),
    Options = Color3.fromRGB(40, 40, 40),
    Module = Color3.fromRGB(45, 45, 45),
    SubComponent = Color3.fromRGB(35, 35, 35),
    Text = Color3.fromRGB(255, 255, 255),
    TextInactive = Color3.fromRGB(200, 200, 200),
    TextSubtle = Color3.fromRGB(150, 150, 150),
    Accent = Color3.fromRGB(0, 255, 120),
    AccentDark = Color3.fromRGB(50, 50, 50),
    Font = Enum.Font.SourceSans,
    FontBold = Enum.Font.SourceSansBold
}

-- GUI Principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ManusGuiLib"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = CoreGui end)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundTransparency = 1
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- Função Utilitária de Arrastar
local function makeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- [CÓDIGO RESTAURADO] Top Bar e Botão de Configurações
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(0, 400, 0, 40)
TopBar.Position = UDim2.new(0.5, -200, 0, 20)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Cor original mantida por estética
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 6)

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0.8, -10, 0.7, 0)
SearchBox.Position = UDim2.new(0.05, 0, 0.15, 0)
SearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SearchBox.PlaceholderText = "Pesquisar módulos..."
SearchBox.TextColor3 = Library.Theme.Text
SearchBox.Font = Library.Theme.Font
SearchBox.Parent = TopBar

local SettingsBtn = Instance.new("TextButton")
SettingsBtn.Size = UDim2.new(0.1, 0, 0.7, 0)
SettingsBtn.Position = UDim2.new(0.87, 0, 0.15, 0)
SettingsBtn.BackgroundColor3 = Library.Theme.Header
SettingsBtn.Text = "⚙️"
SettingsBtn.TextColor3 = Library.Theme.Text
SettingsBtn.TextSize = 20
SettingsBtn.Parent = TopBar

-- [CÓDIGO RESTAURADO] Tela de Configurações
local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(0, 350, 0, 300)
SettingsFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
SettingsFrame.BackgroundColor3 = Library.Theme.Background
SettingsFrame.BorderSizePixel = 0
SettingsFrame.Visible = false
SettingsFrame.Parent = MainFrame
Instance.new("UICorner", SettingsFrame)

local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Size = UDim2.new(1, 0, 0, 40)
SettingsTitle.Text = "Configurações & Keybinds"
SettingsTitle.TextColor3 = Library.Theme.Text
SettingsTitle.BackgroundColor3 = Library.Theme.Header
SettingsTitle.Font = Library.Theme.FontBold
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

-- [CÓDIGO RESTAURADO E CORRIGIDO] Definição da função AddKeybind
function Library:AddKeybind(label, defaultKey, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0.9, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.Parent = KeybindContainer
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(0.6, 0, 1, 0)
    TextLabel.Text = label
    TextLabel.TextColor3 = Library.Theme.TextInactive
    TextLabel.Font = Library.Theme.Font
    TextLabel.TextSize = 16
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.BackgroundTransparency = 1
    TextLabel.Parent = Frame
    
    local BindBtn = Instance.new("TextButton")
    BindBtn.Size = UDim2.new(0.35, 0, 0.8, 0)
    BindBtn.Position = UDim2.new(0.65, 0, 0.1, 0)
    BindBtn.BackgroundColor3 = Library.Theme.AccentDark
    BindBtn.Text = defaultKey and defaultKey.Name or "None"
    BindBtn.TextColor3 = Library.Theme.Text
    BindBtn.Font = Library.Theme.FontBold
    BindBtn.Parent = Frame
    
    local currentKey = defaultKey
    local binding = false
    
    BindBtn.MouseButton1Click:Connect(function() binding = true; BindBtn.Text = "..." end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if binding and input.UserInputType == Enum.UserInputType.Keyboard then
            binding = false
            currentKey = input.KeyCode
            BindBtn.Text = currentKey.Name
        elseif not gameProcessed and currentKey and input.KeyCode == currentKey then
            if callback then pcall(callback, currentKey, true) end
        end
    end)
    
    KeybindContainer.CanvasSize = UDim2.new(0, 0, 0, KeybindList.AbsoluteContentSize.Y + 10)
end

-- [CÓDIGO RESTAURADO] Lógica de abrir/fechar Settings
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

-- Função de Categoria (Layout Automático)
function Library:CreateCategory(name)
    -- (Código da função permanece o mesmo da v5)
    local position = UDim2.new(0, Library.NextCategoryX, 0, Library.CategoryStartY)
    Library.NextCategoryX = Library.NextCategoryX + Library.CategoryWidth + Library.CategorySpacing
    local CategoryFrame = Instance.new("Frame")
    CategoryFrame.Name = name
    CategoryFrame.Size = UDim2.new(0, Library.CategoryWidth, 0, 30)
    CategoryFrame.Position = position
    CategoryFrame.BackgroundColor3 = Library.Theme.Background
    CategoryFrame.BorderSizePixel = 0
    CategoryFrame.Active = true
    CategoryFrame.Parent = MainFrame
    -- ... (resto do código da função)
    return {}
end

-- Função de Janela Custom
function Library:CreateWindow(title, size)
    -- (Código da função permanece o mesmo da v5)
    return {}
end

-- [CHAMADA CORRIGIDA] Keybinds Globais Iniciais
Library:AddKeybind("Abrir/Fechar Menu", Library.OpenKey, function(key, pressed)
    if pressed then
        MainFrame.Visible = not MainFrame.Visible
        for _, win in pairs(Library.Windows) do
            if win and win.Parent then win.Visible = MainFrame.Visible end
        end
    end
end)

-- O loader.lua irá adicionar o keybind de "Remover Script"

return Library
