-- Manus GUI Library V5 (Layout Automático e Janelas Custom)
-- Hospedagem: https://raw.githubusercontent.com/Neospeed1kk/RochaFace/refs/heads/main/gui.lua

local Library = {}

-- Serviços
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- Configurações da Biblioteca
Library.OpenKey = Enum.KeyCode.Insert
Library.Categories = {}
Library.Windows = {}
Library.SettingsOpen = false

-- Configurações de Layout Automático de Categoria
Library.CategoryStartX = 10
Library.CategoryStartY = 70 -- Abaixo da TopBar
Library.CategoryWidth = 160
Library.CategorySpacing = 15
Library.NextCategoryX = Library.CategoryStartX

-- Configurações de Tema (para consistência)
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
    AccentDark = Color3.fromRGB(60, 60, 60),
    Font = Enum.Font.SourceSans,
    FontBold = Enum.Font.SourceSansBold
}

-- Criar ScreenGui Principal
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

-- Função utilitária de arrastar
local function makeDraggable(frame, dragHandle)
    -- (O código da função makeDraggable permanece o mesmo de antes)
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

-- (O código da TopBar e do menu de Settings permanece o mesmo)

-- ==================================================
-- NOVA FUNÇÃO: Criar Categoria com Layout Automático
-- ==================================================
function Library:CreateCategory(name)
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
    
    local Title = Instance.new("TextButton")
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.Text = name
    Title.TextColor3 = Library.Theme.Text
    Title.Font = Library.Theme.FontBold
    Title.TextSize = 18
    Title.BackgroundTransparency = 1
    Title.AutoButtonColor = false
    Title.Parent = CategoryFrame
    
    local OptionsFrame = Instance.new("Frame")
    OptionsFrame.Name = "Options"
    OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
    OptionsFrame.Position = UDim2.new(0, 0, 1, 0)
    OptionsFrame.BackgroundColor3 = Library.Theme.Options
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
    
    -- O resto da função AddModule e os componentes internos (Slider, Dropdown, etc.)
    -- permanecem os mesmos, mas podem ser atualizados para usar o Library.Theme
    function categoryObj:AddModule(moduleName, callback, isTrigger)
        -- ... (código do AddModule, usando Library.Theme para cores e fontes) ...
        return moduleObj
    end
    
    return categoryObj
end

-- ===================================
-- NOVA FUNÇÃO: Criar Janela Custom
-- ===================================
function Library:CreateWindow(title, size)
    local winSize = size or UDim2.new(0, 250, 0, 300)

    local WindowFrame = Instance.new("Frame")
    WindowFrame.Name = title
    WindowFrame.Size = winSize
    WindowFrame.Position = UDim2.new(0.5, -winSize.X.Offset / 2, 0.5, -winSize.Y.Offset / 2)
    WindowFrame.BackgroundColor3 = Library.Theme.Background
    WindowFrame.BorderSizePixel = 1
    WindowFrame.BorderColor3 = Library.Theme.Header
    WindowFrame.Active = true
    WindowFrame.Visible = MainFrame.Visible -- Sincroniza com o menu principal
    WindowFrame.Parent = MainFrame

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 25)
    TitleBar.BackgroundColor3 = Library.Theme.Header
    TitleBar.Parent = WindowFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -25, 1, 0)
    TitleLabel.Text = "  " .. title
    TitleLabel.TextColor3 = Library.Theme.Text
    TitleLabel.Font = Library.Theme.FontBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = TitleBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 25, 1, 0)
    CloseBtn.Position = UDim2.new(1, -25, 0, 0)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Library.Theme.TextInactive
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Font = Library.Theme.FontBold
    CloseBtn.Parent = TitleBar
    CloseBtn.MouseButton1Click:Connect(function() WindowFrame:Destroy() end)

    makeDraggable(WindowFrame, TitleBar)

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, 0, 1, -25)
    ContentFrame.Position = UDim2.new(0, 0, 0, 25)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = WindowFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = ContentFrame

    local windowObj = { Frame = WindowFrame, Content = ContentFrame }
    table.insert(Library.Windows, WindowFrame)

    -- Métodos para adicionar componentes à janela
    function windowObj:AddButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.Position = UDim2.new(0, 5, 0, 0)
        btn.Text = text
        btn.BackgroundColor3 = Library.Theme.Module
        btn.TextColor3 = Library.Theme.TextInactive
        btn.Font = Library.Theme.Font
        btn.Parent = windowObj.Content
        if callback then btn.MouseButton1Click:Connect(callback) end
        return btn
    end

    function windowObj:AddTextBox(placeholder, callback)
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -10, 0, 30)
        box.Position = UDim2.new(0, 5, 0, 0)
        box.PlaceholderText = placeholder
        box.BackgroundColor3 = Library.Theme.SubComponent
        box.TextColor3 = Library.Theme.Text
        box.Font = Library.Theme.Font
        box.Parent = windowObj.Content
        if callback then
            box.FocusLost:Connect(function(enterPressed) if enterPressed then callback(box.Text) end end)
        end
        return box
    end
    
    return windowObj
end


-- Keybind para abrir/fechar o menu principal (e janelas filhas)
Library:AddKeybind("Abrir/Fechar Menu", Library.OpenKey, function(key, pressed)
    if pressed then
        MainFrame.Visible = not MainFrame.Visible
        -- Sincroniza a visibilidade de todas as janelas criadas
        for _, win in pairs(Library.Windows) do
            if win and win.Parent then
                win.Visible = MainFrame.Visible
            end
        end
    end
end)

-- (O resto do código, como AddKeybind e a remoção, permanece o mesmo)

return Library
