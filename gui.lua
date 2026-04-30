-- Manus GUI Library V6.9 (Definitive Fix)
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
        pcall(function() writefile(name .. ".json", HttpService:JSONEncode(data)) end)
    end
end

function Library:LoadConfig(name)
    if readfile and isfile and isfile(name .. ".json") then
        local success, result = pcall(function() return HttpService:JSONDecode(readfile(name .. ".json")) end)
        if success then return result end
    end
    return nil
end

function Library:AddKeybind(text, defaultKey, callback)
    local key = defaultKey
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == key and callback then callback(key, true) end
    end)
    return { SetKey = function(newKey) key = newKey end }
end

-- ... Funções de Whitelist ...

--[[
    2. INICIALIZAÇÃO DA GUI
]]
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "ManusGuiLib_V6_9"; ScreenGui.ResetOnSpawn = false; ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = CoreGui end)

local MainFrame = Instance.new("Frame"); MainFrame.Name = "MainFrame"; MainFrame.Size = UDim2.new(1, 0, 1, 0); MainFrame.BackgroundTransparency = 1; MainFrame.Parent = ScreenGui

-- ... Barra Superior e outros elementos visuais ...
local TopBar = Instance.new("Frame"); TopBar.Name = "TopBar"; TopBar.Size = UDim2.new(0, 500, 0, 35); TopBar.Position = UDim2.new(0.5, -250, 0, 15); TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); TopBar.Parent = MainFrame; Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 4)
local SearchBox = Instance.new("TextBox"); SearchBox.Size = UDim2.new(0, 200, 0, 24); SearchBox.Position = UDim2.new(0.5, -100, 0.5, -12); SearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35); SearchBox.PlaceholderText = "Pesquisar módulos..."; SearchBox.Text = ""; SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255); SearchBox.Font = Enum.Font.SourceSans; SearchBox.TextSize = 14; SearchBox.Parent = TopBar; Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 4)

--[[
    3. FUNÇÕES UTILITÁRIAS
]]
local function makeDraggable(frame, dragHandle) -- ... código para arrastar ...
    local d,di,ds,sp; dragHandle.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then d,ds,sp=true,i.Position,frame.Position;i.Changed:Connect(function()if i.UserInputState==Enum.UserInputState.End then d=false end end)end end);dragHandle.InputChanged:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseMovement then di=i end end);UserInputService.InputChanged:Connect(function(i)if i==di and d then local D=i.Position-ds;frame.Position=UDim2.new(sp.X.Scale,sp.X.Offset+D.X,sp.Y.Scale,sp.Y.Offset+D.Y)end end)
end

--[[
    4. API DE JANELAS E CATEGORIAS (VERSÃO ESTÁVEL E CORRIGIDA)
]]
function Library:CreateCategory(name, position)
    local categoryObj = {}
    local CategoryFrame = Instance.new("Frame"); CategoryFrame.Name = name; CategoryFrame.Size = UDim2.new(0, 150, 0, 30); CategoryFrame.Position = position; CategoryFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); CategoryFrame.BorderSizePixel = 0; CategoryFrame.Parent = MainFrame
    local Title = Instance.new("TextButton"); Title.Size = UDim2.new(1, 0, 1, 0); Title.Text = name; Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.Font = Enum.Font.SourceSansBold; Title.TextSize = 16; Title.BackgroundTransparency = 1; Title.Parent = CategoryFrame
    local OptionsFrame = Instance.new("Frame"); OptionsFrame.Size = UDim2.new(1, 0, 0, 0); OptionsFrame.Position = UDim2.new(0, 0, 1, 0); OptionsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40); OptionsFrame.BorderSizePixel = 0; OptionsFrame.ClipsDescendants = true; OptionsFrame.Parent = CategoryFrame; OptionsFrame.Visible = false
    local UIListLayout = Instance.new("UIListLayout", OptionsFrame); UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    makeDraggable(CategoryFrame, Title)

    local expanded = false
    Title.MouseButton1Click:Connect(function()
        expanded = not expanded
        OptionsFrame.Visible = expanded
        local tween = TweenService:Create(OptionsFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, expanded and UIListLayout.AbsoluteContentSize.Y or 0)})
        tween:Play()
    end)

    function categoryObj:AddModule(moduleName, callback, p3)
        local opts = {}; if type(p3) == "table" then opts = p3 elseif type(p3) == "boolean" then opts.isTrigger = p3 end
        local moduleObj = { Enabled = false, SubExpanded = false }

        local ModuleContainer = Instance.new("Frame"); ModuleContainer.Size = UDim2.new(1, 0, 0, 25); ModuleContainer.BackgroundTransparency = 1; ModuleContainer.Parent = OptionsFrame; ModuleContainer.LayoutOrder = opts.order or 1
        local ModuleBtn = Instance.new("TextButton"); ModuleBtn.Size = UDim2.new(1, 0, 1, 0); ModuleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); ModuleBtn.Text = "  " .. moduleName; ModuleBtn.TextColor3 = Color3.fromRGB(200, 200, 200); ModuleBtn.Font = Enum.Font.SourceSans; ModuleBtn.TextSize = 14; ModuleBtn.TextXAlignment = Enum.TextXAlignment.Left; ModuleBtn.Parent = ModuleContainer
        local SubFrame = Instance.new("ScrollingFrame"); SubFrame.Size = UDim2.new(1, 0, 0, 0); SubFrame.Position = UDim2.new(0, 0, 1, 0); SubFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35); SubFrame.BorderSizePixel = 0; SubFrame.Visible = false; SubFrame.ScrollBarThickness = 2; SubFrame.Parent = ModuleContainer
        local subLayout = Instance.new("UIListLayout", SubFrame); subLayout.Padding = UDim.new(0, 2)

        local function updateParentSize()
            local subHeight = SubFrame.Visible and subLayout.AbsoluteContentSize.Y or 0
            ModuleContainer.Size = UDim2.new(1, 0, 0, 25 + subHeight)
            OptionsFrame.Size = UDim2.new(1, 0, 0, UIListLayout.AbsoluteContentSize.Y)
        end
        subLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateParentSize)

        ModuleBtn.MouseButton1Click:Connect(function() -- LEFT CLICK
            if opts.isTrigger then callback() return end
            moduleObj.Enabled = not moduleObj.Enabled
            ModuleBtn.TextColor3 = moduleObj.Enabled and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(200, 200, 200)
            callback(moduleObj.Enabled)
        end)

        ModuleBtn.MouseButton2Click:Connect(function() -- RIGHT CLICK
            if opts.onRightClick then opts.onRightClick() return end
            moduleObj.SubExpanded = not moduleObj.SubExpanded
            SubFrame.Visible = moduleObj.SubExpanded
            updateParentSize()
        end)

        function moduleObj:Remove() ModuleContainer:Destroy(); task.wait(); updateParentSize() end
        
        -- ================== SUB-OPTION FUNCTIONS (CORRECTED SCOPE) ==================
        function moduleObj:AddToggle(text, default, cb)
            local state = default or false
            local toggleBtn = Instance.new("TextButton"); toggleBtn.Size = UDim2.new(1, -10, 0, 20); toggleBtn.Position = UDim2.new(0.5, -toggleBtn.Size.X.Offset/2, 0, 0); toggleBtn.BackgroundTransparency = 1; toggleBtn.Font = Enum.Font.SourceSans; toggleBtn.TextSize = 13; toggleBtn.TextColor3 = Color3.fromRGB(180, 180, 180); toggleBtn.Text = text; toggleBtn.Parent = SubFrame
            local check = Instance.new("Frame"); check.Size = UDim2.new(0, 10, 0, 10); check.Position = UDim2.new(1, -15, 0.5, -5); check.BackgroundColor3 = state and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(80, 80, 80); check.Parent = toggleBtn; Instance.new("UICorner", check).CornerRadius = UDim.new(0, 2)
            toggleBtn.MouseButton1Click:Connect(function() state = not state; check.BackgroundColor3 = state and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(80, 80, 80); cb(state) end)
        end

        function moduleObj:AddSlider(text, min, max, default, cb)
            local sliderFrame = Instance.new("Frame"); sliderFrame.Size = UDim2.new(1, -10, 0, 30); sliderFrame.Position = UDim2.new(0.5, -sliderFrame.Size.X.Offset/2, 0, 0); sliderFrame.BackgroundTransparency = 1; sliderFrame.Parent = SubFrame
            local label = Instance.new("TextLabel"); label.Size = UDim2.new(1, 0, 0, 15); label.BackgroundTransparency = 1; label.Font = Enum.Font.SourceSans; label.TextSize = 13; label.TextColor3 = Color3.fromRGB(180, 180, 180); label.Text = text .. ": " .. default; label.Parent = sliderFrame
            local bar = Instance.new("Frame"); bar.Size = UDim2.new(1, 0, 0, 4); bar.Position = UDim2.new(0, 0, 0, 20); bar.BackgroundColor3 = Color3.fromRGB(60,60,60); bar.Parent = sliderFrame; Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
            local fill = Instance.new("Frame"); fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(0, 120, 200); fill.Parent = bar; Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
            local function onDrag(input) local p=math.clamp((input.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1); local val=math.floor(min+p*(max-min)+0.5); fill.Size=UDim2.new(p,0,1,0); label.Text=text..": "..val; cb(val) end
            local dragging=false; bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true onDrag(i) end end); bar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end); UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then onDrag(i) end end)
        end
        
        -- ... outras sub-funções como AddDropdown ...

        return moduleObj
    end
    table.insert(Library.Categories, categoryObj) -- Adiciona a categoria à lista principal
    return categoryObj
end

--[[
    5. OVERLAYS E OUTROS
]]
function Library:CreateOverlay(id, props)
    props = props or {}
    local ov = Instance.new("Frame"); ov.Name = id; ov.Size = props.Size or UDim2.new(0, 200, 0, 100); ov.Position = props.Position or UDim2.new(0, 10, 0, 10); ov.BackgroundColor3 = props.Color or Color3.fromRGB(30,30,30); ov.BorderSizePixel=0; ov.Parent = MainFrame; Instance.new("UICorner", ov).CornerRadius=UDim.new(0,4)
    Library.Overlays[id] = ov
    return ov
end

-- ... Lógica de pesquisa, atalhos, etc. ...

return Library
