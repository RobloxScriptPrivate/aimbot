-- Manus GUI Library V6.7 (Compact SubOptions + Destroy Fix)
local Library = {}

-- Serviços
local UserInputService = game:GetService("UserInputService")
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
-- Pasta base dos configs no workspace do executor
local CONFIG_FOLDER = "Universal Project"

-- Garante que a pasta existe (makefolder é API padrão dos executores)
pcall(function()
    if makefolder and not isfolder(CONFIG_FOLDER) then
        makefolder(CONFIG_FOLDER)
    end
end)

function Library:SaveConfig(name, data)
    pcall(function()
        if writefile then
            writefile(CONFIG_FOLDER .. "/" .. name .. ".json", HttpService:JSONEncode(data))
        end
    end)
end

function Library:LoadConfig(name)
    local path = CONFIG_FOLDER .. "/" .. name .. ".json"
    if readfile and isfile and isfile(path) then
        local ok, result = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        if ok and type(result) == "table" then return result end
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
ScreenGui.Name = "ManusGuiLib_V6_7"
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
-- Salva posicoes das categorias na pasta Universal Project
-- Mapa nome->categoryObj para salvar estado expanded
local categoryObjects = {}

local function saveCategoryPositions()
    local data = {}
    for _, cat in ipairs(Library.Categories) do
        if cat and cat.Parent then
            local obj = categoryObjects[cat.Name]
            data[cat.Name] = {
                x        = cat.Position.X.Offset,
                y        = cat.Position.Y.Offset,
                expanded = obj and obj.Expanded or true,
            }
        end
    end
    Library:SaveConfig("category_positions", data)
end

local function loadCategoryPositions()
    return Library:LoadConfig("category_positions")
end

local function makeDraggable(frame, dragHandle, onDragEnd)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if onDragEnd then onDragEnd() end
                end
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
    4. JANELA DE WHITELIST
]]
function Library:OpenWhitelistWindow()
    local window = Library:CreateWindow("🛡️ Whitelist de Jogadores", UDim2.new(0, 400, 0, 350))
    local content = window.Content
    local currentTab = "Marcador"
    local searchQuery = ""

    local WinSearch = Instance.new("TextBox")
    WinSearch.Size = UDim2.new(0.9, 0, 0, 28)
    WinSearch.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    WinSearch.PlaceholderText = "Pesquisar jogador..."
    WinSearch.Text = ""; WinSearch.TextColor3 = Color3.fromRGB(255, 255, 255)
    WinSearch.Font = Enum.Font.SourceSans; WinSearch.TextSize = 14
    WinSearch.Parent = content; Instance.new("UICorner", WinSearch)

    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(0.9, 0, 0, 35); TabFrame.BackgroundTransparency = 1; TabFrame.Parent = content
    local Btn1 = Instance.new("TextButton")
    Btn1.Size = UDim2.new(0.5, -5, 1, 0); Btn1.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    Btn1.Text = "Marcador"; Btn1.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn1.Font = Enum.Font.SourceSansBold; Btn1.TextSize = 16; Btn1.Parent = TabFrame; Instance.new("UICorner", Btn1)
    local Btn2 = Instance.new("TextButton")
    Btn2.Size = UDim2.new(0.5, -5, 1, 0); Btn2.Position = UDim2.new(0.5, 5, 0, 0)
    Btn2.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Btn2.Text = "Marcados"
    Btn2.TextColor3 = Color3.fromRGB(200, 200, 200); Btn2.Font = Enum.Font.SourceSansBold
    Btn2.TextSize = 16; Btn2.Parent = TabFrame; Instance.new("UICorner", Btn2)

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(0.95, 0, 1, -110); Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0; Scroll.ScrollBarThickness = 3; Scroll.Parent = content
    local listLayout = Instance.new("UIListLayout", Scroll)
    listLayout.Padding = UDim.new(0, 5); listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local function refresh()
        for _, v in pairs(Scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        for _, p in ipairs(Players:GetPlayers()) do
            if p == player then continue end
            local isW = Library:IsWhitelisted(p)
            local match = string.find(string.lower(p.DisplayName), string.lower(searchQuery)) or string.find(string.lower(p.Name), string.lower(searchQuery))
            local show = (currentTab == "Marcador" and match) or (currentTab == "Marcados" and isW and match)
            if show then
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(0.95, 0, 0, 32)
                b.BackgroundColor3 = isW and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(50, 50, 50)
                b.Text = (isW and "[WL] " or "") .. p.DisplayName
                b.TextColor3 = Color3.fromRGB(255, 255, 255); b.Font = Enum.Font.SourceSans
                b.TextSize = 14; b.Parent = Scroll; Instance.new("UICorner", b)
                b.MouseButton1Click:Connect(function() Library:ToggleWhitelist(p); refresh() end)
            end
        end
        Scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 5)
    end
    Btn1.MouseButton1Click:Connect(function()
        currentTab = "Marcador"; Btn1.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        Btn2.BackgroundColor3 = Color3.fromRGB(45, 45, 45); refresh()
    end)
    Btn2.MouseButton1Click:Connect(function()
        currentTab = "Marcados"; Btn2.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        Btn1.BackgroundColor3 = Color3.fromRGB(45, 45, 45); refresh()
    end)
    WinSearch:GetPropertyChangedSignal("Text"):Connect(function() searchQuery = WinSearch.Text; refresh() end)
    refresh()
end

--[[
    5. API DE JANELAS E CATEGORIAS
]]
function Library:CreateWindow(title, size, position)
    if Library.ActiveWindows[title] and Library.ActiveWindows[title].Frame.Parent then
        Library.ActiveWindows[title].Frame:Destroy()
    end
    local windowObj = {}
    local WindowFrame = Instance.new("Frame")
    WindowFrame.Name = title
    WindowFrame.Size = size or UDim2.new(0, 350, 0, 250)
    WindowFrame.Position = position or UDim2.new(0.5, -175, 0.5, -125)
    WindowFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    WindowFrame.BorderSizePixel = 0; WindowFrame.Visible = true
    Instance.new("UICorner", WindowFrame).CornerRadius = UDim.new(0, 5)

    local TitleBar = Instance.new("TextLabel")
    TitleBar.Size = UDim2.new(1, 0, 0, 35); TitleBar.Text = "  " .. title
    TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TitleBar.Font = Enum.Font.SourceSansBold; TitleBar.TextSize = 16
    TitleBar.TextXAlignment = Enum.TextXAlignment.Left; TitleBar.Parent = WindowFrame

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 35, 1, 0); CloseButton.Position = UDim2.new(1, -35, 0, 0)
    CloseButton.Text = "X"; CloseButton.TextColor3 = Color3.fromRGB(255, 80, 80)
    CloseButton.BackgroundTransparency = 1; CloseButton.TextSize = 18; CloseButton.Parent = TitleBar
    CloseButton.MouseButton1Click:Connect(function() WindowFrame:Destroy() end)

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, 0, 1, -35); ContentFrame.Position = UDim2.new(0, 0, 0, 35)
    ContentFrame.BackgroundTransparency = 1; ContentFrame.Parent = WindowFrame
    local layout = Instance.new("UIListLayout", ContentFrame)
    layout.Padding = UDim.new(0, 8); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Instance.new("UIPadding", ContentFrame).PaddingTop = UDim.new(0, 8)

    windowObj.Frame = WindowFrame; windowObj.Content = ContentFrame
    makeDraggable(WindowFrame, TitleBar); WindowFrame.Parent = MainFrame

    function windowObj:AddButton(text, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.9, 0, 0, 32); b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        b.TextColor3 = Color3.fromRGB(220, 220, 220); b.Text = text
        b.TextSize = 14; b.Font = Enum.Font.SourceSansBold; b.Parent = ContentFrame
        Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(callback); return b
    end
    function windowObj:AddTextBox(placeholder)
        local tb = Instance.new("TextBox")
        tb.Size = UDim2.new(0.9, 0, 0, 32); tb.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        tb.TextColor3 = Color3.fromRGB(255, 255, 255); tb.PlaceholderText = placeholder or ""
        tb.Text = ""; tb.TextSize = 14; tb.Font = Enum.Font.SourceSans; tb.Parent = ContentFrame
        Instance.new("UICorner", tb); return tb
    end
    return windowObj
end

-- Exposto para o loader chamar APOS todos os modulos carregados
function Library:RestoreCategoryPositions()
    local savedData = loadCategoryPositions()
    if not savedData then return end
    for _, cat in ipairs(Library.Categories) do
        if cat and cat.Parent and savedData[cat.Name] then
            local sp  = savedData[cat.Name]
            local obj = categoryObjects[cat.Name]
            -- Restaura posicao
            cat.Position = UDim2.new(0, sp.x, 0, sp.y)
            -- Restaura estado expandido/colapsado
            if obj and type(sp.expanded) == "boolean" then
                obj.Expanded = sp.expanded
                local optFrame = obj.Options
                if optFrame then
                    optFrame.Visible = sp.expanded
                end
            end
        end
    end
end

function Library:CreateCategory(name, position)
    local CategoryFrame = Instance.new("Frame")
    CategoryFrame.Name = name
    CategoryFrame.Size = UDim2.new(0, 150, 0, 30)
    CategoryFrame.Position = position
    CategoryFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    CategoryFrame.BorderSizePixel = 0; CategoryFrame.Parent = MainFrame

    local Title = Instance.new("TextButton")
    Title.Size = UDim2.new(1, 0, 1, 0); Title.Text = name
    Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 16; Title.BackgroundTransparency = 1; Title.Parent = CategoryFrame

    local OptionsFrame = Instance.new("Frame")
    OptionsFrame.Size = UDim2.new(1, 0, 0, 0); OptionsFrame.Position = UDim2.new(0, 0, 1, 0)
    OptionsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    OptionsFrame.BorderSizePixel = 0; OptionsFrame.ClipsDescendants = true
    OptionsFrame.Parent = CategoryFrame

    local UIListLayout = Instance.new("UIListLayout", OptionsFrame)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    makeDraggable(CategoryFrame, Title, saveCategoryPositions)
    local categoryObj = { Frame = CategoryFrame, Options = OptionsFrame, Expanded = true }
    table.insert(Library.Categories, CategoryFrame)
    categoryObjects[name] = categoryObj  -- registra para save/restore de estado

    -- Recalcula altura total do OptionsFrame somando todos os ModuleContainers
    local function recalcOptionsFrame()
        local totalHeight = 0
        for _, v in pairs(OptionsFrame:GetChildren()) do
            if v:IsA("Frame") then
                totalHeight = totalHeight + v.Size.Y.Offset
            end
        end
        OptionsFrame.Size = UDim2.new(1, 0, 0, totalHeight)
    end

    Title.MouseButton2Click:Connect(function()
        categoryObj.Expanded = not categoryObj.Expanded
        OptionsFrame.Visible = categoryObj.Expanded
        saveCategoryPositions()  -- salva estado ao colapsar/expandir
    end)

    function categoryObj:AddModule(moduleName, callback, isTrigger)
        local moduleObj = { Enabled = false, IsTrigger = isTrigger or false, SubExpanded = false }

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
        ModuleBtn.TextSize = 14
        ModuleBtn.TextXAlignment = Enum.TextXAlignment.Left
        ModuleBtn.Parent = ModuleContainer

        -- SubFrame compacto: cada item tem altura fixa de 18px (toggle) ou 26px (slider)
        local SubFrame = Instance.new("ScrollingFrame")
        SubFrame.Size = UDim2.new(1, 0, 0, 0)
        SubFrame.Position = UDim2.new(0, 0, 0, 25)
        SubFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        SubFrame.BorderSizePixel = 0
        SubFrame.Visible = false
        SubFrame.ScrollBarThickness = 2
        SubFrame.Parent = ModuleContainer

        local subLayout = Instance.new("UIListLayout", SubFrame)
        subLayout.SortOrder = Enum.SortOrder.LayoutOrder
        subLayout.Padding = UDim.new(0, 1)

        local function updateSizes()
            local contentHeight = subLayout.AbsoluteContentSize.Y
            local visibleHeight = SubFrame.Visible and math.min(contentHeight, 120) or 0
            SubFrame.Size = UDim2.new(1, 0, 0, visibleHeight)
            SubFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
            ModuleContainer.Size = UDim2.new(1, 0, 0, 25 + visibleHeight)
            recalcOptionsFrame()
        end
        updateSizes()
        subLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSizes)

        ModuleBtn.MouseButton1Click:Connect(function()
            if moduleObj.IsTrigger then
                callback()
            else
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

        -- CORREÇÃO: Destroy remove o container e recalcula o layout
        function moduleObj:Destroy()
            if ModuleContainer and ModuleContainer.Parent then
                ModuleContainer:Destroy()
            end
            recalcOptionsFrame()
        end

        -- Toggle compacto: 18px de altura, texto pequeno
        function moduleObj:AddToggle(t, d, c)
            local s = d or false
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 18)
            b.BackgroundTransparency = 1
            b.Text = "  " .. t
            b.TextColor3 = s and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(160, 160, 160)
            b.Font = Enum.Font.SourceSans
            b.TextSize = 12
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.LayoutOrder = 1
            b.Parent = SubFrame
            b.MouseButton1Click:Connect(function()
                s = not s
                b.TextColor3 = s and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(160, 160, 160)
                c(s)
            end)
        end

        -- Dropdown compacto: aceita defaultValue opcional para restaurar config salva
        -- Assinatura: AddDropdown(texto, opcoes, callback, valorInicial)
        function moduleObj:AddDropdown(t, o, c, defaultValue)
            -- Encontra o indice do valor inicial (salvo ou primeiro da lista)
            local i = 1
            if defaultValue ~= nil then
                for idx, v in ipairs(o) do
                    if tostring(v) == tostring(defaultValue) then i = idx; break end
                end
            end
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 18)
            b.BackgroundTransparency = 1
            b.Text = "  " .. t .. ": " .. tostring(o[i])
            b.TextColor3 = Color3.fromRGB(180, 180, 180)
            b.Font = Enum.Font.SourceSans
            b.TextSize = 12
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.LayoutOrder = 2
            b.Parent = SubFrame
            b.MouseButton1Click:Connect(function()
                i = i + 1; if i > #o then i = 1 end
                b.Text = "  " .. t .. ": " .. tostring(o[i]); c(o[i])
            end)
        end

        -- Slider compacto: 26px total (label 13px + barra 8px + padding 5px)
        function moduleObj:AddSlider(t, min, max, d, c)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 0, 26)
            f.BackgroundTransparency = 1
            f.LayoutOrder = 3
            f.Parent = SubFrame

            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, -4, 0, 13)
            l.Position = UDim2.new(0, 4, 0, 1)
            l.Text = t .. ": " .. tostring(d)
            l.TextColor3 = Color3.fromRGB(180, 180, 180)
            l.BackgroundTransparency = 1
            l.TextSize = 11
            l.Font = Enum.Font.SourceSans
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Parent = f

            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(1, -8, 0, 5)
            bar.Position = UDim2.new(0, 4, 0, 16)
            bar.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            bar.BorderSizePixel = 0
            bar.Parent = f
            Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(math.clamp((d - min) / (max - min), 0, 1), 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
            fill.BorderSizePixel = 0
            fill.Parent = bar
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

            local function up(input)
                local p = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(p, 0, 1, 0)
                local v = math.floor(min + (p * (max - min)))
                l.Text = t .. ": " .. tostring(v)
                c(v)
            end
            local drag = false
            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; up(input) end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if drag and input.UserInputType == Enum.UserInputType.MouseMovement then up(input) end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
            end)
        end

        return moduleObj
    end
    return categoryObj
end

--[[
    6. CONFIGURAÇÕES
]]
SettingsBtn.MouseButton1Click:Connect(function()
    local win = Library:CreateWindow("Configurações Globais", UDim2.new(0, 300, 0, 220))
    win:AddButton("🛡️ Gerenciar Whitelist", function() Library:OpenWhitelistWindow() end)
    local kb = win:AddButton("⌨️ Atalho do Menu: " .. Library.OpenKey.Name, function() end)
    kb.MouseButton1Click:Connect(function()
        kb.Text = "... Pressione uma tecla ..."
        local c; c = UserInputService.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Keyboard then
                Library.OpenKey = i.KeyCode
                kb.Text = "⌨️ Atalho do Menu: " .. i.KeyCode.Name
                c:Disconnect()
            end
        end)
    end)
    win:AddButton("❌ Remover Script (Atalho: K)", function() ScreenGui:Destroy() end)
end)

-- ATALHO GLOBAL PARA REMOVER (K)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Library.RemoveKey then ScreenGui:Destroy() end
end)

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = string.lower(SearchBox.Text)
    for _, cat in ipairs(Library.Categories) do
        local has = false
        for _, mod in ipairs(cat:FindFirstChild("Options"):GetChildren()) do
            if mod:IsA("Frame") then
                local b = mod:FindFirstChildOfClass("TextButton")
                if b and string.find(string.lower(b.Text), q) then
                    mod.Visible = true; has = true
                else
                    mod.Visible = false
                end
            end
        end
        cat.Visible = (q == "" or has)
    end
end)

--[[
    7. OVERLAY
]]
function Library:CreateOverlay(id, title, color)
    if Library.Overlays[id] then return Library.Overlays[id] end
    local o = Instance.new("Frame")
    o.Size = UDim2.new(0, 220, 0, 80); o.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    o.BackgroundTransparency = 0.2; o.BorderSizePixel = 0; o.Visible = false; o.Parent = ScreenGui
    Instance.new("UICorner", o).CornerRadius = UDim.new(0, 8)
    local b = Instance.new("Frame"); b.Size = UDim2.new(1, 0, 0, 2)
    b.BackgroundColor3 = color or Color3.fromRGB(0, 150, 255); b.BorderSizePixel = 0; b.Parent = o
    Instance.new("UICorner", b)
    local t = Instance.new("TextLabel"); t.Size = UDim2.new(1, -10, 0, 20); t.Position = UDim2.new(0, 10, 0, 5)
    t.Text = title; t.TextColor3 = color or Color3.fromRGB(0, 150, 255); t.Font = Enum.Font.SourceSansBold
    t.TextSize = 12; t.BackgroundTransparency = 1; t.TextXAlignment = Enum.TextXAlignment.Left; t.Parent = o
    local a = Instance.new("ImageLabel"); a.Size = UDim2.new(0, 40, 0, 40); a.Position = UDim2.new(0, 10, 0, 30)
    a.BackgroundColor3 = Color3.fromRGB(40, 40, 45); a.Parent = o
    Instance.new("UICorner", a).CornerRadius = UDim.new(1, 0)
    local n = Instance.new("TextLabel"); n.Size = UDim2.new(1, -60, 0, 15); n.Position = UDim2.new(0, 60, 0, 30)
    n.Text = "Nenhum"; n.TextColor3 = Color3.fromRGB(255, 255, 255); n.Font = Enum.Font.SourceSansBold
    n.TextSize = 14; n.TextXAlignment = Enum.TextXAlignment.Left; n.BackgroundTransparency = 1; n.Parent = o
    local i_l = Instance.new("TextLabel"); i_l.Size = UDim2.new(1, -60, 0, 15); i_l.Position = UDim2.new(0, 60, 0, 45)
    i_l.Text = ""; i_l.TextColor3 = Color3.fromRGB(180, 180, 180); i_l.Font = Enum.Font.SourceSans
    i_l.TextSize = 12; i_l.TextXAlignment = Enum.TextXAlignment.Left; i_l.BackgroundTransparency = 1; i_l.Parent = o
    local d = Instance.new("TextLabel"); d.Size = UDim2.new(1, -60, 0, 15); d.Position = UDim2.new(0, 60, 0, 60)
    d.Text = ""; d.TextColor3 = color or Color3.fromRGB(0, 150, 255); d.Font = Enum.Font.SourceSansBold
    d.TextSize = 12; d.TextXAlignment = Enum.TextXAlignment.Left; d.BackgroundTransparency = 1; d.Parent = o
    local obj = { Frame = o }
    function obj:Update(p, dist, info)
        if not p then o.Visible = false; return end
        o.Visible = true; n.Text = p.DisplayName
        i_l.Text = info or ("@" .. p.Name)
        d.Text = dist and (string.format("%.1f", dist) .. "m") or ""
        task.spawn(function()
            a.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
    end
    function obj:SetVisible(s) o.Visible = s end
    function obj:SetPosition(pos) o.Position = pos end
    Library.Overlays[id] = obj; return obj
end

Library:AddKeybind("Abrir/Fechar Menu", Library.OpenKey, function(key, pressed)
    if pressed then MainFrame.Visible = not MainFrame.Visible end
end)

-- Expõe o ScreenGui para que o loader conecte o cleanup global
Library.ScreenGui = ScreenGui

return Library
