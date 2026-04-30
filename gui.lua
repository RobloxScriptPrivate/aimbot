-- Manus GUI Library V4.2 (Correções de Estilo e Keybinds)

local Library = {}

-- Serviços
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Variáveis Locais
local player = Players.LocalPlayer

-- Configurações da Biblioteca
Library.OpenKey = Enum.KeyCode.Insert
Library.RemoveKey = Enum.KeyCode.K
Library.Categories = {}
Library.ActiveWindows = {}
Library.PendingBinds = {}

--[[
    Inicialização da GUI Principal
]]

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ManusGuiLib_V4_2"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if not pcall(function() ScreenGui.Parent = CoreGui end) then
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
end

-- MainFrame (Container Principal)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundTransparency = 1
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

--[[
    Funções Utilitárias
]]

-- Torna um elemento arrastável
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


--[[
    API de Janelas (CreateWindow e componentes)
]]

function Library:CreateWindow(title, size, position)
    if Library.ActiveWindows[title] and Library.ActiveWindows[title].Frame.Parent then
        Library.ActiveWindows[title].Frame:Destroy()
    end

    local windowObj = {}
    local WindowFrame = Instance.new("Frame")
    local ContentFrame = Instance.new("Frame")

    -- Estilos
    local FONT = Enum.Font.SourceSans
    local FONT_BOLD = Enum.Font.SourceSansBold
    local TEXT_SIZE_BODY = 16
    local TEXT_SIZE_TITLE = 18
    local PADDING = 10
    
    -- Frame da Janela
    WindowFrame.Name = title
    WindowFrame.Size = size or UDim2.new(0, 350, 0, 250)
    WindowFrame.Position = position or UDim2.new(0.5, -175, 0.5, -125)
    WindowFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    WindowFrame.BorderSizePixel = 0
    WindowFrame.Visible = true
    Instance.new("UICorner", WindowFrame).CornerRadius = UDim.new(0, 5)

    -- Barra de Título
    local TitleBar = Instance.new("TextLabel")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.Text = title
    TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TitleBar.Font = FONT_BOLD
    TitleBar.TextSize = TEXT_SIZE_TITLE
    TitleBar.Parent = WindowFrame

    -- Botão de Fechar
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 40, 1, 0)
    CloseButton.Position = UDim2.new(1, -40, 0, 0)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 80, 80)
    CloseButton.BackgroundTransparency = 1
    CloseButton.TextSize = 22
    CloseButton.Font = FONT_BOLD
    CloseButton.ZIndex = 2
    CloseButton.Parent = TitleBar
    CloseButton.MouseButton1Click:Connect(function()
        windowObj.Frame:Destroy()
        Library.ActiveWindows[title] = nil
    end)

    -- Área de Conteúdo
    ContentFrame.Name = "Content"
    ContentFrame.Size = UDim2.new(1, 0, 1, -TitleBar.Size.Y.Offset)
    ContentFrame.Position = UDim2.new(0, 0, 0, TitleBar.Size.Y.Offset)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = WindowFrame
    
    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 8)
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIList.Parent = ContentFrame
    
    local UIPad = Instance.new("UIPadding")
    UIPad.PaddingTop = UDim.new(0, PADDING)
    UIPad.PaddingBottom = UDim.new(0, PADDING)
    UIPad.PaddingLeft = UDim.new(0, PADDING)
    UIPad.PaddingRight = UDim.new(0, PADDING)
    UIPad.Parent = ContentFrame

    -- Adiciona o objeto à lista de janelas ativas
    windowObj.Frame = WindowFrame
    windowObj.Content = ContentFrame
    Library.ActiveWindows[title] = windowObj
    
    -- Torna a janela arrastável e a coloca na frente
    makeDraggable(WindowFrame, TitleBar)
    WindowFrame.Parent = MainFrame

    -- Métodos da Janela
    function windowObj:AddButton(text, callback)
        local Button = Instance.new("TextButton")
        Button.Name = text
        Button.Size = UDim2.new(1, 0, 0, 35)
        Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Button.TextColor3 = Color3.fromRGB(220, 220, 220)
        Button.Text = text
        Button.TextSize = TEXT_SIZE_BODY
        Button.Font = FONT_BOLD
        Button.Parent = ContentFrame
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 4)
        if callback then Button.MouseButton1Click:Connect(callback) end
        return Button
    end

    function windowObj:AddTextBox(placeholder)
        local TextBox = Instance.new("TextBox")
        TextBox.Name = placeholder
        TextBox.Size = UDim2.new(1, 0, 0, 40)
        TextBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        TextBox.PlaceholderText = placeholder or ""
        TextBox.Text = ""
        TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextBox.TextSize = TEXT_SIZE_BODY
        TextBox.Font = FONT
        TextBox.Parent = ContentFrame
        Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 4)
        return TextBox
    end
    
    return windowObj
end


--[[
    Barra Superior (Busca e Configurações)
]]

-- Frame da Barra
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(0, 450, 0, 40)
TopBar.Position = UDim2.new(0.5, -225, 0, 20)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 6)
Instance.new("UIListLayout", TopBar).FillDirection = Enum.FillDirection.Horizontal
Instance.new("UIPadding", TopBar).PaddingLeft = UDim.new(0, 10)

-- Caixa de Busca
local SearchBox = Instance.new("TextBox")
SearchBox.Name = "SearchBox"
SearchBox.Size = UDim2.new(1, -55, 0.7, 0)
SearchBox.Position = UDim2.new(0, 0, 0.15, 0)
SearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SearchBox.PlaceholderText = "Pesquisar módulos..."
SearchBox.Text = ""
SearchBox.ClearTextOnFocus = false
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.Font = Enum.Font.SourceSans
SearchBox.TextSize = 16
SearchBox.Parent = TopBar
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 4)

-- Botão de Configurações
local SettingsBtn = Instance.new("TextButton")
SettingsBtn.Name = "SettingsButton"
SettingsBtn.Size = UDim2.new(0, 35, 0.7, 0)
SettingsBtn.Position = UDim2.new(1, -45, 0.15, 0)
SettingsBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SettingsBtn.BackgroundTransparency = 0.5
SettingsBtn.Text = "⚙️"
SettingsBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
SettingsBtn.TextSize = 22
SettingsBtn.Font = Enum.Font.SourceSansBold
SettingsBtn.Parent = TopBar
Instance.new("UICorner", SettingsBtn).CornerRadius = UDim.new(0, 4)


--[[
    Sistema de Keybinds e Janela de Configurações
]]

local KeybindContainer -- Escopo global para a função AddKeybind

-- Função que abre (ou recria) a janela de Configurações
local function openSettingsWindow()
    local settingsWindow = Library:CreateWindow("Configurações & Keybinds", UDim2.new(0, 380, 0, 400))
    
    KeybindContainer = Instance.new("ScrollingFrame")
    KeybindContainer.Name = "KeybindContainer"
    KeybindContainer.Size = UDim2.new(1, 0, 1, 0)
    KeybindContainer.BackgroundTransparency = 1
    KeybindContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    KeybindContainer.ScrollBarThickness = 4
    KeybindContainer.Parent = settingsWindow.Content
    
    local KeybindList = Instance.new("UIListLayout")
    KeybindList.Padding = UDim.new(0, 5)
    KeybindList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    KeybindList.SortOrder = Enum.SortOrder.LayoutOrder
    KeybindList.Parent = KeybindContainer

    -- Dispara a recriação dos keybinds na nova janela
    Library:RebindKeys()
end

SettingsBtn.MouseButton1Click:Connect(openSettingsWindow)

-- Função para registrar um Keybind.
function Library:AddKeybind(label, defaultKey, callback)
    local bindInfo = {label=label, key=defaultKey, cb=callback, connections={}}
    
    -- Armazena o keybind para ser recriado se a janela for reaberta
    Library.PendingBinds[label] = bindInfo

    local function createVisual(container)
        local Frame = Instance.new("Frame", container)
        Frame.Size = UDim2.new(1, -20, 0, 40)
        Frame.BackgroundTransparency = 1
        Frame.LayoutOrder = #container:GetChildren()

        local TextLabel = Instance.new("TextLabel", Frame)
        TextLabel.Size = UDim2.new(0.6, 0, 1, 0)
        TextLabel.Text = label
        TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        TextLabel.Font = Enum.Font.SourceSans
        TextLabel.TextSize = 16
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.BackgroundTransparency = 1

        local BindBtn = Instance.new("TextButton", Frame)
        BindBtn.Size = UDim2.new(0.4, 0, 0.9, 0)
        BindBtn.Position = UDim2.new(0.6, 0, 0.05, 0)
        BindBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        BindBtn.Text = bindInfo.key and bindInfo.key.Name or "Nenhum"
        BindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        BindBtn.Font = Enum.Font.SourceSansBold
        
        local binding = false
        BindBtn.MouseButton1Click:Connect(function()
            binding = true
            BindBtn.Text = "..."
        end)
        
        table.insert(bindInfo.connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                binding = false
                bindInfo.key = input.KeyCode
                BindBtn.Text = bindInfo.key.Name
                if bindInfo.cb then bindInfo.cb(bindInfo.key, false) end
            end
        end))
        
        container.CanvasSize = UDim2.new(0, 0, 0, KeybindList.AbsoluteContentSize.Y)
    end
    
    -- Se a janela já estiver aberta, cria o visual. Senão, fica pendente.
    if KeybindContainer and KeybindContainer.Parent then
        createVisual(KeybindContainer)
    end

    -- Conexão global que sempre escuta a tecla, independentemente da janela
    table.insert(bindInfo.connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and bindInfo.key and input.KeyCode == bindInfo.key then
            if bindInfo.cb then bindInfo.cb(bindInfo.key, true) end -- Pressionado
        end
    end))
end

-- Recria os visuais dos keybinds na janela
function Library:RebindKeys()
    if not KeybindContainer or not KeybindContainer.Parent then return end
    
    for _, child in ipairs(KeybindContainer:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    for label, bindInfo in pairs(Library.PendingBinds) do
        local Frame = Instance.new("Frame", KeybindContainer)
        Frame.Size = UDim2.new(0.9, 0, 0, 40)
        Frame.BackgroundTransparency = 1
        Frame.LayoutOrder = #KeybindContainer:GetChildren()

        local TextLabel = Instance.new("TextLabel", Frame)
        TextLabel.Size = UDim2.new(0.6, 0, 1, 0)
        TextLabel.Text = bindInfo.label
        TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        TextLabel.Font = Enum.Font.SourceSans
        TextLabel.TextSize = 16
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.BackgroundTransparency = 1

        local BindBtn = Instance.new("TextButton", Frame)
        BindBtn.Size = UDim2.new(0.4, 0, 0.9, 0)
        BindBtn.Position = UDim2.new(0.6, 0, 0.05, 0)
        BindBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        BindBtn.Text = bindInfo.key and bindInfo.key.Name or "Nenhum"
        BindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        BindBtn.Font = Enum.Font.SourceSansBold
        
        local binding = false
        BindBtn.MouseButton1Click:Connect(function()
            binding = true
            BindBtn.Text = "..."
        end)
        
        -- Apenas a lógica de MUDAR a tecla precisa de uma nova conexão
        local rebindConnection = UserInputService.InputBegan:Connect(function(input, _)
            if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                binding = false
                bindInfo.key = input.KeyCode
                BindBtn.Text = bindInfo.key.Name
                if bindInfo.cb then bindInfo.cb(bindInfo.key, false) end
            end
        end)
        -- Limpa essa conexão quando a janela fechar
        settingsWindow.Frame.Destroying:Connect(function() rebindConnection:Disconnect() end)
    end
    
    KeybindContainer.CanvasSize = UDim2.new(0, 0, 0, #KeybindContainer:GetChildren() * 45)
end


--[[
    Sistema de Categorias e Módulos (Sem grandes alterações)
]]
function Library:CreateCategory(name, position)
    -- ... (código existente, sem alterações visuais críticas)
    local CategoryFrame = Instance.new("Frame", MainFrame)
    -- ... etc
    return categoryObj
end


--[[
    Keybinds Iniciais Globais
]]
Library:AddKeybind("Abrir/Fechar Menu", Library.OpenKey, function(key, pressed)
    if pressed then
        MainFrame.Visible = not MainFrame.Visible
    else -- A tecla foi alterada na janela de configs
        Library.OpenKey = key
    end
end)

Library:AddKeybind("Remover Script", Library.RemoveKey, function(key, pressed)
    if pressed then
        ScreenGui:Destroy()
    else -- A tecla foi alterada
        Library.RemoveKey = key
    end
end)


return Library
