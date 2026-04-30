-- Manus GUI Library V6.0 (Ultimate Edition - Barra Superior, Busca & Whitelist Avançada)
local Library = {}

-- Serviços
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- Variáveis Locais
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Configurações da Biblioteca
Library.OpenKey = Enum.KeyCode.Insert
Library.RemoveKey = Enum.KeyCode.K
Library.Categories = {}
Library.ActiveWindows = {}
Library.Overlays = {}
Library.SettingsOpen = false
Library.Whitelist = {}
Library.SearchQuery = ""

--[[
    1. REGISTRO DE MÉTODOS BASE
]]
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
    2. INICIALIZAÇÃO DA GUI (BARRA SUPERIOR)
]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ManusGuiLib_V6_0"
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
TopBar.Size = UDim2.new(0, 600, 0, 40)
TopBar.Position = UDim2.new(0.5, -300, 0, 20)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 6)

local TopTitle = Instance.new("TextLabel")
TopTitle.Size = UDim2.new(0, 150, 1, 0)
TopTitle.Position = UDim2.new(0, 15, 0, 0)
TopTitle.Text = "MANUS V6.0"
TopTitle.TextColor3 = Color3.fromRGB(0, 150, 255)
TopTitle.Font = Enum.Font.SourceSansBold
TopTitle.TextSize = 20
TopTitle.BackgroundTransparency = 1
TopTitle.TextXAlignment = Enum.TextXAlignment.Left
TopTitle.Parent = TopBar

-- BARRA DE PESQUISA
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0, 250, 0, 26)
SearchBox.Position = UDim2.new(0.5, -125, 0.5, -13)
SearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
SearchBox.PlaceholderText = "Pesquisar módulos..."
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.Font = Enum.Font.SourceSans
SearchBox.TextSize = 14
SearchBox.Parent = TopBar
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 4)

-- BOTÃO CONFIGURAÇÕES
local SettingsBtn = Instance.new("TextButton")
SettingsBtn.Size = UDim2.new(0, 100, 0, 26)
SettingsBtn.Position = UDim2.new(1, -115, 0.5, -13)
SettingsBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
SettingsBtn.Text = "⚙️ Configs"
SettingsBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
SettingsBtn.Font = Enum.Font.SourceSansBold
SettingsBtn.TextSize = 14
SettingsBtn.Parent = TopBar
Instance.new("UICorner", SettingsBtn).CornerRadius = UDim.new(0, 4)

--[[
    3. FUNÇÕES UTILITÁRIAS
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
makeDraggable(TopBar, TopBar)

--[[
    4. JANELA DE WHITELIST AVANÇADA
]]
function Library:OpenWhitelistWindow()
    local window = Library:CreateWindow("🛡️ Gerenciador de Whitelist", UDim2.new(0, 450, 0, 400))
    local content = window.Content
    
    local currentTab = "Marcador" -- "Marcador" ou "Marcados"
    local searchQuery = ""

    -- ABA DE PESQUISA NA JANELA
    local WinSearch = Instance.new("TextBox")
    WinSearch.Size = UDim2.new(0.9, 0, 0, 30)
    WinSearch.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    WinSearch.PlaceholderText = "Filtrar jogadores..."
    WinSearch.Text = ""
    WinSearch.TextColor3 = Color3.fromRGB(255, 255, 255)
    WinSearch.Font = Enum.Font.SourceSans
    WinSearch.TextSize = 14
    WinSearch.Parent = content
    Instance.new("UICorner", WinSearch)

    -- BOTÕES DE ABA
    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(0.9, 0, 0, 35)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Parent = content
    
    local BtnMarcador = Instance.new("TextButton")
    BtnMarcador.Size = UDim2.new(0.5, -5, 1, 0)
    BtnMarcador.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    BtnMarcador.Text = "Marcador (Todos)"
    BtnMarcador.TextColor3 = Color3.fromRGB(255, 255, 255)
    BtnMarcador.Font = Enum.Font.SourceSansBold
    BtnMarcador.Parent = TabFrame
    Instance.new("UICorner", BtnMarcador)

    local BtnMarcados = Instance.new("TextButton")
    BtnMarcados.Size = UDim2.new(0.5, -5, 1, 0)
    BtnMarcados.Position = UDim2.new(0.5, 5, 0, 0)
    BtnMarcados.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    BtnMarcados.Text = "Marcados (Aliados)"
    BtnMarcados.TextColor3 = Color3.fromRGB(200, 200, 200)
    BtnMarcados.Font = Enum.Font.SourceSansBold
    BtnMarcados.Parent = TabFrame
    Instance.new("UICorner", BtnMarcados)

    -- LISTA COM SCROLL
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(0.95, 0, 1, -110)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 4
    Scroll.Parent = content
    
    local listLayout = Instance.new("UIListLayout", Scroll)
    listLayout.Padding = UDim.new(0, 5)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local function refreshList()
        for _, v in pairs(Scroll:GetChildren()) do
            if v:IsA("TextButton") then v:Destroy() end
        end

        for _, p in ipairs(Players:GetPlayers()) do
            if p == player then continue end
            
            local isW = Library:IsWhitelisted(p)
            local nameMatch = string.find(string.lower(p.DisplayName), string.lower(searchQuery)) or string.find(string.lower(p.Name), string.lower(searchQuery))
            
            local shouldShow = false
            if currentTab == "Marcador" then
                shouldShow = nameMatch
            else
                shouldShow = isW and nameMatch
            end

            if shouldShow then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(0.95, 0, 0, 35)
                btn.BackgroundColor3 = isW and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(50, 50, 55)
                btn.Text = (isW and "[ALIADO] " or "") .. p.DisplayName .. " (@" .. p.Name .. ")"
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.Font = Enum.Font.SourceSans
                btn.TextSize = 14
                btn.Parent = Scroll
                Instance.new("UICorner", btn)
                
                btn.MouseButton1Click:Connect(function()
                    Library:ToggleWhitelist(p)
                    refreshList()
                end)
            end
        end
        Scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end

    BtnMarcador.MouseButton1Click:Connect(function()
        currentTab = "Marcador"
        BtnMarcador.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        BtnMarcados.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        refreshList()
    end)

    BtnMarcados.MouseButton1Click:Connect(function()
        currentTab = "Marcados"
        BtnMarcados.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        BtnMarcador.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        refreshList()
    end)

    WinSearch:GetPropertyChangedSignal("Text"):Connect(function()
        searchQuery = WinSearch.Text
        refreshList()
    end)

    refreshList()
end

--[[
    5. API DE JANELAS E CATEGORIAS (MANTIDAS & MELHORADAS)
]]
function Library:CreateWindow(title, size, position)
    if Library.ActiveWindows[title] and Library.ActiveWindows[title].Frame.Parent then
        Library.ActiveWindows[title].Frame:Destroy()
    end
    local windowObj = {}
    local WindowFrame = Instance.new("Frame")
    local ContentFrame = Instance.new("Frame")
    WindowFrame.Name = title
    WindowFrame.Size = size or UDim2.new(0, 350, 0, 250)
    WindowFrame.Position = position or UDim2.new(0.5, -175, 0.5, -125)
    WindowFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    WindowFrame.BorderSizePixel = 0
    WindowFrame.Visible = true
    Instance.new("UICorner", WindowFrame).CornerRadius = UDim.new(0, 8)
    local TitleBar = Instance.new("TextLabel")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.Text = "  " .. title
    TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    TitleBar.Font = Enum.Font.SourceSansBold
    TitleBar.TextSize = 16
    TitleBar.TextXAlignment = Enum.TextXAlignment.Left
    TitleBar.Parent = WindowFrame
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 40, 1, 0)
    CloseButton.Position = UDim2.new(1, -40, 0, 0)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 80, 80)
    CloseButton.BackgroundTransparency = 1
    CloseButton.TextSize = 20
    CloseButton.Parent = TitleBar
    CloseButton.MouseButton1Click:Connect(function() WindowFrame:Destroy() end)
    ContentFrame.Size = UDim2.new(1, 0, 1, -40)
    ContentFrame.Position = UDim2.new(0, 0, 0, 40)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = WindowFrame
    local layout = Instance.new("UIListLayout", ContentFrame)
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Instance.new("UIPadding", ContentFrame).PaddingTop = UDim.new(0, 10)
    windowObj.Frame = WindowFrame
    windowObj.Content = ContentFrame
    makeDraggable(WindowFrame, TitleBar)
    WindowFrame.Parent = MainFrame
    return windowObj
end

function Library:CreateCategory(name, position)
    local CategoryFrame = Instance.new("Frame")
    CategoryFrame.Name = name
    CategoryFrame.Size = UDim2.new(0, 160, 0, 32)
    CategoryFrame.Position = position
    CategoryFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    CategoryFrame.BorderSizePixel = 0
    CategoryFrame.Parent = MainFrame
    Instance.new("UICorner", CategoryFrame).CornerRadius = UDim.new(0, 4)
    local Title = Instance.new("TextButton")
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.Text = name
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 16
    Title.BackgroundTransparency = 1
    Title.Parent = CategoryFrame
    local OptionsFrame = Instance.new("Frame")
    OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
    OptionsFrame.Position = UDim2.new(0, 0, 1, 2)
    OptionsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.ClipsDescendants = true
    OptionsFrame.Parent = CategoryFrame
    Instance.new("UICorner", OptionsFrame)
    local UIListLayout = Instance.new("UIListLayout", OptionsFrame)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    makeDraggable(CategoryFrame, Title)
    local categoryObj = { Frame = CategoryFrame, Options = OptionsFrame, Expanded = true }
    
    function categoryObj:AddModule(moduleName, callback, isTrigger)
        local moduleObj = { Enabled = false, IsTrigger = isTrigger or false, SubExpanded = false }
        local ModuleContainer = Instance.new("Frame")
        ModuleContainer.Size = UDim2.new(1, 0, 0, 28)
        ModuleContainer.BackgroundTransparency = 1
        ModuleContainer.Parent = OptionsFrame
        local ModuleBtn = Instance.new("TextButton")
        ModuleBtn.Size = UDim2.new(1, 0, 0, 28)
        ModuleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        ModuleBtn.Text = "  " .. moduleName
        ModuleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        ModuleBtn.Font = Enum.Font.SourceSans
        ModuleBtn.TextSize = 15
        ModuleBtn.TextXAlignment = Enum.TextXAlignment.Left
        ModuleBtn.Parent = ModuleContainer
        local SubFrame = Instance.new("ScrollingFrame")
        SubFrame.Size = UDim2.new(1, 0, 0, 0)
        SubFrame.Position = UDim2.new(0, 0, 0, 28)
        SubFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        SubFrame.BorderSizePixel = 0
        SubFrame.Visible = false
        SubFrame.ScrollBarThickness = 2
        SubFrame.Parent = ModuleContainer
        local subLayout = Instance.new("UIListLayout", SubFrame)
        subLayout.SortOrder = Enum.SortOrder.LayoutOrder
        local function updateSizes()
            local contentHeight = subLayout.AbsoluteContentSize.Y
            if SubFrame.Visible then
                SubFrame.Size = UDim2.new(1, 0, 0, math.min(contentHeight, 180))
                SubFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
            else SubFrame.Size = UDim2.new(1, 0, 0, 0) end
            ModuleContainer.Size = UDim2.new(1, 0, 0, 28 + SubFrame.Size.Y.Offset)
            local totalHeight = 0
            for _, v in pairs(OptionsFrame:GetChildren()) do if v:IsA("Frame") then totalHeight = totalHeight + v.Size.Y.Offset end end
            OptionsFrame.Size = UDim2.new(1, 0, 0, totalHeight)
        end
        subLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSizes)
        ModuleBtn.MouseButton1Click:Connect(function()
            if moduleObj.IsTrigger then callback() else
                moduleObj.Enabled = not moduleObj.Enabled
                ModuleBtn.TextColor3 = moduleObj.Enabled and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(200, 200, 200)
                callback(moduleObj.Enabled)
            end
        end)
        ModuleBtn.MouseButton2Click:Connect(function()
            moduleObj.SubExpanded = not moduleObj.SubExpanded
            SubFrame.Visible = moduleObj.SubExpanded
            updateSizes()
        end)
        function moduleObj:AddToggle(t, d, c)
            local s = d or false
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 24)
            b.BackgroundTransparency = 1
            b.Text = "    " .. t
            b.TextColor3 = s and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(160, 160, 160)
            b.Font = Enum.Font.SourceSans; b.TextSize = 13; b.TextXAlignment = Enum.TextXAlignment.Left
            b.LayoutOrder = 1; b.Parent = SubFrame
            b.MouseButton1Click:Connect(function() s = not s; b.TextColor3 = s and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(160, 160, 160); c(s) end)
        end
        function moduleObj:AddDropdown(t, o, c)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 24)
            b.BackgroundTransparency = 1
            b.Text = "    > " .. t .. ": " .. tostring(o[1])
            b.TextColor3 = Color3.fromRGB(180, 180, 180)
            b.Font = Enum.Font.SourceSans; b.TextSize = 13; b.TextXAlignment = Enum.TextXAlignment.Left
            b.LayoutOrder = 2; b.Parent = SubFrame
            local i = 1
            b.MouseButton1Click:Connect(function() i = i + 1; if i > #o then i = 1 end; b.Text = "    > " .. t .. ": " .. tostring(o[i]); c(o[i]) end)
        end
        function moduleObj:AddSlider(t, min, max, d, c)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 0, 35); f.BackgroundTransparency = 1; f.LayoutOrder = 3; f.Parent = SubFrame
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, 0, 0, 18); l.Text = "    " .. t .. ": " .. tostring(d); l.TextColor3 = Color3.fromRGB(180, 180, 180); l.BackgroundTransparency = 1; l.TextSize = 12; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = f
            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(0.8, 0, 0, 4); bar.Position = UDim2.new(0.1, 0, 0.7, 0); bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60); bar.Parent = f
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((d-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255); fill.Parent = bar
            local function up(input)
                local p = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(p, 0, 1, 0)
                local v = math.floor(min + (p * (max - min)))
                l.Text = "    " .. t .. ": " .. tostring(v); c(v)
            end
            local drag = false
            bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = true up(input) end end)
            UserInputService.InputChanged:Connect(function(input) if drag and input.UserInputType == Enum.UserInputType.MouseMovement then up(input) end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
        end
        return moduleObj
    end
    return categoryObj
end

--[[
    6. CONFIGURAÇÕES GERAIS E BUSCA
]]
SettingsBtn.MouseButton1Click:Connect(function()
    local win = Library:CreateWindow("⚙️ Configurações Globais", UDim2.new(0, 300, 0, 200))
    win:AddButton("🛡️ Gerenciar Whitelist (Aliados)", function()
        Library:OpenWhitelistWindow()
    end)
    win:AddButton("❌ Remover Script", function()
        ScreenGui:Destroy()
    end)
end)

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = string.lower(SearchBox.Text)
    for _, cat in ipairs(Library.Categories) do
        local hasVisible = false
        for _, mod in ipairs(cat:FindFirstChild("Options"):GetChildren()) do
            if mod:IsA("Frame") then
                local modName = string.lower(mod:FindFirstChildOfClass("TextButton").Text)
                if string.find(modName, q) then
                    mod.Visible = true; hasVisible = true
                else mod.Visible = false end
            end
        end
        cat.Visible = (q == "" or hasVisible)
    end
end)

--[[
    7. API DE OVERLAY (RE-DEFINIÇÃO PARA COMPATIBILIDADE)
]]
function Library:CreateOverlay(id, title, color)
    -- Já definido acima, mantido para compatibilidade de chamada
    return Library.Overlays[id] or Library:CreateOverlay(id, title, color)
end

-- KEYBINDS
Library:AddKeybind("Abrir/Fechar Menu", Library.OpenKey, function(key, pressed)
    if pressed then MainFrame.Visible = not MainFrame.Visible end
end)

return Library
