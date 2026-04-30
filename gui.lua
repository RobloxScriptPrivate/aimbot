-- Manus GUI Library V6.6 (Extended Module API)
local Library = {}

-- Serviços
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- Variáveis Locais
local player = Players.LocalPlayer

-- Configurações da Biblioteca
Library.OpenKey = Enum.KeyCode.Insert
Library.RemoveKey = Enum.KeyCode.K
Library.Categories = {}
Library.ActiveWindows = {}
Library.Overlays = {}
Library.Whitelist = {}

--[[
    1. MÉTODOS DE CONFIGURAÇÃO
]]
function Library:SaveConfig(name, data)
    if writefile then
        pcall(function()
            writefile(name .. ".json", HttpService:JSONEncode(data))
        end)
    end
end

function Library:LoadConfig(name)
    if readfile and isfile and isfile(name .. ".json") then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(name .. ".json"))
        end)
        if success then return result end
    end
    return nil
end

function Library:AddKeybind(text, defaultKey, callback)
    local key = defaultKey
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == key then
            if callback then callback(key, true) end
        end
    end)
    return { SetKey = function(newKey) key = newKey end }
end

function Library:IsWhitelisted(playerObj)
    if not playerObj then return false end
    return Library.Whitelist[playerObj.UserId] or false
end

function Library:ToggleWhitelist(playerObj)
    if not playerObj then return end
    Library.Whitelist[playerObj.UserId] = not Library.Whitelist[playerObj.UserId]
    return Library.Whitelist[playerObj.UserId]
end

--[[
    2. INICIALIZAÇÃO DA GUI
]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ManusGuiLib_V6_6"
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

-- BARRA SUPERIOR FIXA
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(0, 500, 0, 35)
TopBar.Position = UDim2.new(0.5, -250, 0, 15)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 4)

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0, 200, 0, 24)
SearchBox.Position = UDim2.new(0.5, -100, 0.5, -12)
SearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SearchBox.PlaceholderText = "Pesquisar módulos..."
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.Font = Enum.Font.SourceSans
SearchBox.TextSize = 14
SearchBox.Parent = TopBar
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 4)

local SettingsBtn = Instance.new("TextButton")
SettingsBtn.Size = UDim2.new(0, 80, 0, 24)
SettingsBtn.Position = UDim2.new(1, -90, 0.5, -12)
SettingsBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SettingsBtn.Text = "⚙️ Configs"
SettingsBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
SettingsBtn.Font = Enum.Font.SourceSansBold
SettingsBtn.TextSize = 13
SettingsBtn.Parent = TopBar
Instance.new("UICorner", SettingsBtn).CornerRadius = UDim.new(0, 4)

--[[
    3. FUNÇÕES UTILITÁRIAS
]]
local function makeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = frame.Position
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

--[[
    4. JANELA DE WHITELIST
]]
function Library:OpenWhitelistWindow()
    local window = Library:CreateWindow("🛡️ Whitelist de Jogadores", UDim2.new(0, 400, 0, 350))
    -- ... (código da janela de whitelist)
end

--[[
    5. API DE JANELAS E CATEGORIAS
]]
function Library:CreateWindow(title, size, position)
    if Library.ActiveWindows[title] and Library.ActiveWindows[title].Frame.Parent then Library.ActiveWindows[title].Frame:Destroy() end
    local windowObj = {}
    local WindowFrame = Instance.new("Frame")
    WindowFrame.Name = title; WindowFrame.Size = size or UDim2.new(0, 350, 0, 250); WindowFrame.Position = position or UDim2.new(0.5, -175, 0.5, -125); WindowFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); WindowFrame.BorderSizePixel = 0; WindowFrame.Visible = true; Instance.new("UICorner", WindowFrame).CornerRadius = UDim.new(0, 5)
    local TitleBar = Instance.new("TextLabel")
    TitleBar.Size = UDim2.new(1, 0, 0, 35); TitleBar.Text = "  " .. title; TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255); TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40); TitleBar.Font = Enum.Font.SourceSansBold; TitleBar.TextSize = 16; TitleBar.TextXAlignment = Enum.TextXAlignment.Left; TitleBar.Parent = WindowFrame
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 35, 1, 0); CloseButton.Position = UDim2.new(1, -35, 0, 0); CloseButton.Text = "X"; CloseButton.TextColor3 = Color3.fromRGB(255, 80, 80); CloseButton.BackgroundTransparency = 1; CloseButton.TextSize = 18; CloseButton.Parent = TitleBar
    CloseButton.MouseButton1Click:Connect(function() WindowFrame:Destroy() end)
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, 0, 1, -35); ContentFrame.Position = UDim2.new(0, 0, 0, 35); ContentFrame.BackgroundTransparency = 1; ContentFrame.Parent = WindowFrame
    local layout = Instance.new("UIListLayout", ContentFrame); layout.Padding = UDim.new(0, 8); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center; Instance.new("UIPadding", ContentFrame).PaddingTop = UDim.new(0, 8)
    windowObj.Frame = WindowFrame; windowObj.Content = ContentFrame; makeDraggable(WindowFrame, TitleBar); WindowFrame.Parent = MainFrame
    function windowObj:AddButton(text, callback)
        local b = Instance.new("TextButton"); b.Size = UDim2.new(0.9, 0, 0, 32); b.BackgroundColor3 = Color3.fromRGB(50, 50, 50); b.TextColor3 = Color3.fromRGB(220, 220, 220); b.Text = text; b.TextSize = 14; b.Font = Enum.Font.SourceSansBold; b.Parent = ContentFrame; Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(callback); return b
    end
    function windowObj:AddTextBox(placeholder)
        local tb = Instance.new("TextBox"); tb.Size = UDim2.new(0.9, 0, 0, 32); tb.BackgroundColor3 = Color3.fromRGB(35, 35, 35); tb.TextColor3 = Color3.fromRGB(255, 255, 255); tb.PlaceholderText = placeholder or ""; tb.Text = ""; tb.TextSize = 14; tb.Font = Enum.Font.SourceSans; tb.Parent = ContentFrame; Instance.new("UICorner", tb)
        return tb
    end
    return windowObj
end

function Library:CreateCategory(name, position)
    local CategoryFrame = Instance.new("Frame")
    CategoryFrame.Name = name; CategoryFrame.Size = UDim2.new(0, 150, 0, 30); CategoryFrame.Position = position; CategoryFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); CategoryFrame.BorderSizePixel = 0; CategoryFrame.Parent = MainFrame
    local Title = Instance.new("TextButton")
    Title.Size = UDim2.new(1, 0, 1, 0); Title.Text = name; Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.Font = Enum.Font.SourceSansBold; Title.TextSize = 16; Title.BackgroundTransparency = 1; Title.Parent = CategoryFrame
    local OptionsFrame = Instance.new("Frame")
    OptionsFrame.Size = UDim2.new(1, 0, 0, 0); OptionsFrame.Position = UDim2.new(0, 0, 1, 0); OptionsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40); OptionsFrame.BorderSizePixel = 0; OptionsFrame.ClipsDescendants = true; OptionsFrame.Parent = CategoryFrame
    local UIListLayout = Instance.new("UIListLayout", OptionsFrame); UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    makeDraggable(CategoryFrame, Title)
    local categoryObj = { Frame = CategoryFrame, Options = OptionsFrame, Expanded = true, Modules = {} }
    table.insert(Library.Categories, CategoryFrame)
    
    Title.MouseButton2Click:Connect(function()
        categoryObj.Expanded = not categoryObj.Expanded
        OptionsFrame.Visible = categoryObj.Expanded
    end)
    
    function categoryObj:AddModule(moduleName, callback, opts)
        opts = opts or {}
        local isTrigger = opts.isTrigger or false
        local onRightClick = opts.onRightClick
        local order = opts.order or 1

        local moduleObj = { Enabled = false, SubExpanded = false }
        local ModuleContainer = Instance.new("Frame")
        ModuleContainer.Name = moduleName
        ModuleContainer.LayoutOrder = order
        ModuleContainer.Size = UDim2.new(1, 0, 0, 25); ModuleContainer.BackgroundTransparency = 1; ModuleContainer.Parent = OptionsFrame
        local ModuleBtn = Instance.new("TextButton")
        ModuleBtn.Size = UDim2.new(1, 0, 1, 0); ModuleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); ModuleBtn.BorderSizePixel = 0; ModuleBtn.Text = "  " .. moduleName; ModuleBtn.TextColor3 = Color3.fromRGB(200, 200, 200); ModuleBtn.Font = Enum.Font.SourceSans; ModuleBtn.TextSize = 14; ModuleBtn.TextXAlignment = Enum.TextXAlignment.Left; ModuleBtn.Parent = ModuleContainer
        local SubFrame = Instance.new("ScrollingFrame")
        SubFrame.Size = UDim2.new(1, 0, 0, 0); SubFrame.Position = UDim2.new(0, 0, 1, 0); SubFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35); SubFrame.BorderSizePixel = 0; SubFrame.Visible = false; SubFrame.ScrollBarThickness = 2; SubFrame.Parent = ModuleContainer
        local subLayout = Instance.new("UIListLayout", SubFrame); subLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        local function updateSizes()
            local contentHeight = subLayout.AbsoluteContentSize.Y
            SubFrame.Size = SubFrame.Visible and UDim2.new(1, 0, 0, math.min(contentHeight, 150)) or UDim2.new(1, 0, 0, 0)
            SubFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
            ModuleContainer.Size = UDim2.new(1, 0, 0, 25 + SubFrame.Size.Y.Offset)
            local totalHeight = 0
            for _, v in ipairs(OptionsFrame:GetChildren()) do if v:IsA("Frame") then totalHeight = totalHeight + v.Size.Y.Offset end end
            OptionsFrame.Size = UDim2.new(1, 0, 0, totalHeight)
        end
        updateSizes()
        subLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSizes)
        
        ModuleBtn.MouseButton1Click:Connect(function()
            if isTrigger then callback() else
                moduleObj.Enabled = not moduleObj.Enabled
                ModuleBtn.TextColor3 = moduleObj.Enabled and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(200, 200, 200)
                callback(moduleObj.Enabled)
            end
        end)
        
        ModuleBtn.MouseButton2Click:Connect(function()
            if onRightClick then onRightClick() return end
            moduleObj.SubExpanded = not moduleObj.SubExpanded
            SubFrame.Visible = moduleObj.SubExpanded
            updateSizes()
        end)

        function moduleObj:Remove()
            ModuleContainer:Destroy()
            updateSizes()
        end
        
        -- Funções de sub-módulo (AddToggle, etc.)
        function moduleObj:AddToggle(t, d, c) b.TextSize = 11 -- ... (código existente)
        end
        function moduleObj:AddDropdown(t, o, c) b.TextSize = 11 -- ... (código existente)
        end
        function moduleObj:AddSlider(t, min, max, d, c) l.TextSize = 11 -- ... (código existente)
        end
        
        categoryObj.Modules[moduleName] = moduleObj
        return moduleObj
    end
    return categoryObj
end

--[[
    6. CONFIGURAÇÕES E OUTROS
]]
-- ... (código existente)

return Library
