-- Manus GUI Library V4.3 (Correção Crítica de CreateCategory)

local Library = {}

-- Serviços
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

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

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ManusGuiLib_V4_3"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if not pcall(function() ScreenGui.Parent = CoreGui end) then
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundTransparency = 1
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

--[[
    Funções Utilitárias
]]

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
    
    WindowFrame.Name = title
    WindowFrame.Size = size or UDim2.new(0, 350, 0, 250)
    WindowFrame.Position = position or UDim2.new(0.5, -175, 0.5, -125)
    WindowFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    WindowFrame.BorderSizePixel = 0
    WindowFrame.Visible = true
    Instance.new("UICorner", WindowFrame).CornerRadius = UDim.new(0, 5)

    local TitleBar = Instance.new("TextLabel")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.Text = title
    TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TitleBar.Font = FONT_BOLD
    TitleBar.TextSize = TEXT_SIZE_TITLE
    TitleBar.Parent = WindowFrame

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

    ContentFrame.Name = "Content"
    ContentFrame.Size = UDim2.new(1, 0, 1, -TitleBar.Size.Y.Offset)
    ContentFrame.Position = UDim2.new(0, 0, 0, TitleBar.Size.Y.Offset)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = WindowFrame
    
    Instance.new("UIListLayout", ContentFrame).Padding = UDim.new(0, 8)
    Instance.new("UIPadding", ContentFrame).PaddingTop = UDim.new(0, PADDING)
    Instance.new("UIPadding", ContentFrame).PaddingBottom = UDim.new(0, PADDING)

    windowObj.Frame = WindowFrame
    windowObj.Content = ContentFrame
    Library.ActiveWindows[title] = windowObj
    
    makeDraggable(WindowFrame, TitleBar)
    WindowFrame.Parent = MainFrame

    function windowObj:AddButton(text, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -2*PADDING, 0, 35)
        Button.Position = UDim2.new(0, PADDING, 0, 0)
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
        TextBox.Size = UDim2.new(1, -2*PADDING, 0, 40)
        TextBox.Position = UDim2.new(0, PADDING, 0, 0)
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

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(0, 450, 0, 40)
TopBar.Position = UDim2.new(0.5, -225, 0, 20)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TopBar.Parent = MainFrame
-- ... (resto da barra superior igual)

--[[
    Sistema de Keybinds e Janela de Configurações
]]

-- ... (código dos keybinds e janela de configurações igual)

--[[
    Sistema de Categorias e Módulos (CORRIGIDO)
]]
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
        ModuleBtn.Size = UDim2.new(1, 0, 1, 0)
        ModuleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        ModuleBtn.BorderSizePixel = 0
        ModuleBtn.Text = "  " .. moduleName
        ModuleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        ModuleBtn.Font = Enum.Font.SourceSans
        ModuleBtn.TextSize = 16
        ModuleBtn.TextXAlignment = Enum.TextXAlignment.Left
        ModuleBtn.Parent = ModuleContainer

        local function updateCategorySize()
            local totalHeight = 0
            for _, v in ipairs(OptionsFrame:GetChildren()) do
                if v:IsA("Frame") then totalHeight = totalHeight + v.Size.Y.Offset end
            end
            OptionsFrame.Size = UDim2.new(1, 0, 0, totalHeight)
        end
        
        function moduleObj:Execute()
            if self.IsTrigger then
                if callback then callback() end
            else
                self.Enabled = not self.Enabled
                ModuleBtn.TextColor3 = self.Enabled and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(200, 200, 200)
                if callback then callback(self.Enabled) end
            end
        end

        ModuleBtn.MouseButton1Click:Connect(function() moduleObj:Execute() end)
        updateCategorySize()
        return moduleObj
    end
    
    return categoryObj
end

--[[
    Keybinds Iniciais Globais
]]
Library:AddKeybind("Abrir/Fechar Menu", Library.OpenKey, function(key, pressed)
    if pressed then
        MainFrame.Visible = not MainFrame.Visible
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
