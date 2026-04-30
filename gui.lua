-- Manus GUI Library V6.7 (Backward Compatibility & Bug Fix)
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

-- ... (O resto das funções auxiliares como AddKeybind, IsWhitelisted, etc. permanecem as mesmas)
function Library:AddKeybind(text, defaultKey, callback) local key=defaultKey; UserInputService.InputBegan:Connect(function(i,p) if not p and i.KeyCode==key and callback then callback(key,true) end end); return {SetKey=function(newKey) key=newKey end} end
function Library:IsWhitelisted(p) if not p then return false end; return Library.Whitelist[p.UserId] or false end
function Library:ToggleWhitelist(p) if not p then return end; Library.Whitelist[p.UserId]=not Library.Whitelist[p.UserId]; return Library.Whitelist[p.UserId] end

--[[
    2. INICIALIZAÇÃO DA GUI
]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ManusGuiLib_V6_7"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if not pcall(function() ScreenGui.Parent = CoreGui end) then ScreenGui.Parent = player:WaitForChild("PlayerGui") end
local MainFrame = Instance.new("Frame"); MainFrame.Name = "MainFrame"; MainFrame.Size = UDim2.new(1, 0, 1, 0); MainFrame.BackgroundTransparency = 1; MainFrame.Parent = ScreenGui
local TopBar = Instance.new("Frame"); TopBar.Name = "TopBar"; TopBar.Size = UDim2.new(0, 500, 0, 35); TopBar.Position = UDim2.new(0.5, -250, 0, 15); TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); TopBar.Parent = MainFrame; Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 4)
local SearchBox=Instance.new("TextBox"); SearchBox.Size=UDim2.new(0,200,0,24); SearchBox.Position=UDim2.new(0.5,-100,0.5,-12); SearchBox.BackgroundColor3=Color3.fromRGB(35,35,35); SearchBox.PlaceholderText="Pesquisar módulos..."; SearchBox.TextColor3=Color3.fromRGB(255,255,255); SearchBox.Font=Enum.Font.SourceSans; SearchBox.TextSize=14; SearchBox.Parent=TopBar; Instance.new("UICorner",SearchBox).CornerRadius=UDim.new(0,4)
local SettingsBtn=Instance.new("TextButton"); SettingsBtn.Size=UDim2.new(0,80,0,24); SettingsBtn.Position=UDim2.new(1,-90,0.5,-12); SettingsBtn.BackgroundColor3=Color3.fromRGB(40,40,40); SettingsBtn.Text="⚙️ Configs"; SettingsBtn.TextColor3=Color3.fromRGB(200,200,200); SettingsBtn.Font=Enum.Font.SourceSansBold; SettingsBtn.TextSize=13; SettingsBtn.Parent=TopBar; Instance.new("UICorner",SettingsBtn).CornerRadius=UDim.new(0,4)

--[[
    3. FUNÇÕES UTILITÁRIAS
]]
local function makeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = frame.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)
    dragHandle.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart; frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
end

-- ... (Funções CreateWindow, OpenWhitelistWindow, etc. permanecem as mesmas)
function Library:CreateWindow(t,s,p) if Library.ActiveWindows[t] and Library.ActiveWindows[t].Frame.Parent then Library.ActiveWindows[t].Frame:Destroy() end; local w,f,b,x,c= {},Instance.new("Frame"),Instance.new("TextLabel"),Instance.new("TextButton"),Instance.new("Frame"); f.Name=t;f.Size=s or UDim2.new(0,350,0,250);f.Position=p or UDim2.new(0.5,-175,0.5,-125); f.BackgroundColor3=Color3.fromRGB(30,30,30);f.BorderSizePixel=0;Instance.new("UICorner",f).CornerRadius=UDim.new(0,5);b.Size=UDim2.new(1,0,0,35);b.Text="  "..t;b.TextColor3=Color3.fromRGB(255,255,255);b.BackgroundColor3=Color3.fromRGB(40,40,40);b.Font=Enum.Font.SourceSansBold;b.TextSize=16;b.TextXAlignment=Enum.TextXAlignment.Left;b.Parent=f;x.Size=UDim2.new(0,35,1,0);x.Position=UDim2.new(1,-35,0,0);x.Text="X";x.TextColor3=Color3.fromRGB(255,80,80);x.BackgroundTransparency=1;x.TextSize=18;x.Parent=b;x.MouseButton1Click:Connect(function()f:Destroy()end); c.Size=UDim2.new(1,0,1,-35);c.Position=UDim2.new(0,0,0,35);c.BackgroundTransparency=1;c.Parent=f; local l=Instance.new("UIListLayout",c);l.Padding=UDim.new(0,8);l.HorizontalAlignment=Enum.HorizontalAlignment.Center;Instance.new("UIPadding",c).PaddingTop=UDim.new(0,8);w.Frame,w.Content=f,c;makeDraggable(f,b);f.Parent=MainFrame; function w:AddButton(t,cb) local b=Instance.new("TextButton");b.Size=UDim2.new(0.9,0,0,32);b.BackgroundColor3=Color3.fromRGB(50,50,50);b.TextColor3=Color3.fromRGB(220,220,220);b.Text=t;b.TextSize=14;b.Font=Enum.Font.SourceSansBold;b.Parent=c;Instance.new("UICorner",b);b.MouseButton1Click:Connect(cb);return b end; function w:AddTextBox(ph) local t=Instance.new("TextBox");t.Size=UDim2.new(0.9,0,0,32);t.BackgroundColor3=Color3.fromRGB(35,35,35);t.TextColor3=Color3.fromRGB(255,255,255);t.PlaceholderText=ph or"";t.TextSize=14;t.Font=Enum.Font.SourceSans;t.Parent=c;Instance.new("UICorner",t);return t end; return w end

--[[
    5. API DE CATEGORIAS (CORRIGIDO)
]]
function Library:CreateCategory(name, position)
    local CategoryFrame = Instance.new("Frame"); CategoryFrame.Name = name; CategoryFrame.Size = UDim2.new(0, 150, 0, 30); CategoryFrame.Position = position; CategoryFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); CategoryFrame.BorderSizePixel = 0; CategoryFrame.Parent = MainFrame
    local Title = Instance.new("TextButton"); Title.Size = UDim2.new(1, 0, 1, 0); Title.Text = name; Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.Font = Enum.Font.SourceSansBold; Title.TextSize = 16; Title.BackgroundTransparency = 1; Title.Parent = CategoryFrame
    local OptionsFrame = Instance.new("Frame"); OptionsFrame.Size = UDim2.new(1, 0, 0, 0); OptionsFrame.Position = UDim2.new(0, 0, 1, 0); OptionsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40); OptionsFrame.ClipsDescendants = true; OptionsFrame.Parent = CategoryFrame
    local UIListLayout = Instance.new("UIListLayout", OptionsFrame); UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    makeDraggable(CategoryFrame, Title)
    local categoryObj = { Frame = CategoryFrame, Options = OptionsFrame, Expanded = true, Modules = {} }
    table.insert(Library.Categories, CategoryFrame)
    Title.MouseButton2Click:Connect(function() categoryObj.Expanded = not categoryObj.Expanded; OptionsFrame.Visible = categoryObj.Expanded end)
    
    -- =================================== FUNÇÃO CORRIGIDA ===================================
    function categoryObj:AddModule(moduleName, callback, p3)
        local opts = {}
        if type(p3) == "table" then
            opts = p3 -- Novo formato: usa a tabela de opções diretamente
        elseif type(p3) == "boolean" then
            opts.isTrigger = p3 -- Formato antigo: converte o booleano para a opção isTrigger
        end

        local isTrigger = opts.isTrigger or false
        local onRightClick = opts.onRightClick
        local order = opts.order or 1

        local moduleObj = { Enabled = false, SubExpanded = false }
        local ModuleContainer = Instance.new("Frame"); ModuleContainer.Name = moduleName; ModuleContainer.LayoutOrder = order; ModuleContainer.Size = UDim2.new(1, 0, 0, 25); ModuleContainer.BackgroundTransparency = 1; ModuleContainer.Parent = OptionsFrame
        local ModuleBtn = Instance.new("TextButton"); ModuleBtn.Size = UDim2.new(1, 0, 1, 0); ModuleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); ModuleBtn.Text = "  " .. moduleName; ModuleBtn.TextColor3 = Color3.fromRGB(200, 200, 200); ModuleBtn.Font = Enum.Font.SourceSans; ModuleBtn.TextSize = 14; ModuleBtn.TextXAlignment = Enum.TextXAlignment.Left; ModuleBtn.Parent = ModuleContainer
        local SubFrame = Instance.new("ScrollingFrame"); SubFrame.Size = UDim2.new(1, 0, 0, 0); SubFrame.Position = UDim2.new(0, 0, 1, 0); SubFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35); SubFrame.BorderSizePixel = 0; SubFrame.Visible = false; SubFrame.ScrollBarThickness = 2; SubFrame.Parent = ModuleContainer
        local subLayout = Instance.new("UIListLayout", SubFrame); subLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        local function updateSizes()-- ... (lógica de redimensionamento)
            local contentHeight = subLayout.AbsoluteContentSize.Y; SubFrame.Size = SubFrame.Visible and UDim2.new(1,0,0,math.min(contentHeight,150)) or UDim2.new(1,0,0,0); SubFrame.CanvasSize = UDim2.new(0,0,0,contentHeight); ModuleContainer.Size = UDim2.new(1,0,0,25+SubFrame.Size.Y.Offset); local totalHeight=0; for _,v in ipairs(OptionsFrame:GetChildren()) do if v:IsA("Frame") then totalHeight=totalHeight+v.Size.Y.Offset end end; OptionsFrame.Size=UDim2.new(1,0,0,totalHeight)
        end
        updateSizes(); subLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSizes)
        
        ModuleBtn.MouseButton1Click:Connect(function()
            if isTrigger then callback() else
                moduleObj.Enabled = not moduleObj.Enabled; ModuleBtn.TextColor3 = moduleObj.Enabled and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(200, 200, 200); callback(moduleObj.Enabled)
            end
        end)
        
        ModuleBtn.MouseButton2Click:Connect(function()
            if onRightClick then onRightClick() return end -- Executa a ação especial (ex: deletar) e para
            -- Se não houver ação especial, executa a ação padrão (expandir)
            moduleObj.SubExpanded = not moduleObj.SubExpanded; SubFrame.Visible = moduleObj.SubExpanded; updateSizes()
        end)

        function moduleObj:Remove() ModuleContainer:Destroy(); updateSizes() end
        
        -- ======== FUNÇÕES DE SUB-MÓDULO RESTAURADAS COMPLETAMENTE ========
        function moduleObj:AddToggle(t, d, c) local s=d or false; local b=Instance.new("TextButton"); b.Size=UDim2.new(1,0,0,20); b.BackgroundTransparency=1; b.Text="    "..t; b.TextColor3=s and Color3.fromRGB(0,200,100) or Color3.fromRGB(160,160,160); b.Font=Enum.Font.SourceSans; b.TextSize=11; b.TextXAlignment=Enum.TextXAlignment.Left; b.LayoutOrder=1; b.Parent=SubFrame; b.MouseButton1Click:Connect(function()s=not s;b.TextColor3=s and Color3.fromRGB(0,200,100) or Color3.fromRGB(160,160,160);c(s)end) end
        function moduleObj:AddDropdown(t,o,c) local b=Instance.new("TextButton"); b.Size=UDim2.new(1,0,0,20); b.BackgroundTransparency=1; b.Text="    > "..t..": "..tostring(o[1]); b.TextColor3=Color3.fromRGB(180,180,180); b.Font=Enum.Font.SourceSans; b.TextSize=11; b.TextXAlignment=Enum.TextXAlignment.Left; b.LayoutOrder=2; b.Parent=SubFrame; local i=1; b.MouseButton1Click:Connect(function()i=i+1;if i>#o then i=1 end;b.Text="    > "..t..": "..tostring(o[i]);c(o[i])end) end
        function moduleObj:AddSlider(t,min,max,d,c) local f=Instance.new("Frame");f.Size=UDim2.new(1,0,0,30);f.BackgroundTransparency=1;f.LayoutOrder=3;f.Parent=SubFrame; local l=Instance.new("TextLabel");l.Size=UDim2.new(1,0,0,15);l.Text="    "..t..": "..tostring(d);l.TextColor3=Color3.fromRGB(180,180,180);l.BackgroundTransparency=1;l.TextSize=11;l.TextXAlignment=Enum.TextXAlignment.Left;l.Parent=f; local bar=Instance.new("Frame");bar.Size=UDim2.new(0.8,0,0,4);bar.Position=UDim2.new(0.1,0,0.7,0);bar.BackgroundColor3=Color3.fromRGB(60,60,60);bar.Parent=f; local fill=Instance.new("Frame");fill.Size=UDim2.new((d-min)/(max-min),0,1,0);fill.BackgroundColor3=Color3.fromRGB(0,120,200);fill.Parent=bar; local function up(input)local p=math.clamp((input.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1);fill.Size=UDim2.new(p,0,1,0);local v=math.floor(min+(p*(max-min)));l.Text="    "..t..": "..tostring(v);c(v)end; local drag=false; bar.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true up(i)end end); UserInputService.InputChanged:Connect(function(i)if drag and i.UserInputType==Enum.UserInputType.MouseMovement then up(i)end end); UserInputService.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end) end
        
        categoryObj.Modules[moduleName] = moduleObj
        return moduleObj
    end
    return categoryObj
end

--[[
    6. CONFIGURAÇÕES E OUTROS
]]
-- ... (Código existente)
SettingsBtn.MouseButton1Click:Connect(function() local w=Library:CreateWindow("Configurações Globais",UDim2.new(0,300,0,220)); w:AddButton("🛡️ Gerenciar Whitelist",function()Library:OpenWhitelistWindow()end); local k=w:AddButton("⌨️ Atalho do Menu: "..Library.OpenKey.Name); k.MouseButton1Click:Connect(function()k.Text="... Pressione uma tecla ...";local c;c=UserInputService.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.Keyboard then Library.OpenKey=i.KeyCode;k.Text="⌨️ Atalho do Menu: "..i.KeyCode.Name;c:Disconnect()end end)end); w:AddButton("❌ Remover Script (Atalho: K)",function()ScreenGui:Destroy()end) end)
UserInputService.InputBegan:Connect(function(i,p)if not p and i.KeyCode==Library.RemoveKey then ScreenGui:Destroy()end end)
SearchBox:GetPropertyChangedSignal("Text"):Connect(function() local q=string.lower(SearchBox.Text); for _,cat in ipairs(Library.Categories)do local h=false; for _,m in ipairs(cat:FindFirstChild("Options"):GetChildren())do if m:IsA("Frame") then local b=m:FindFirstChildOfClass("TextButton");if b and string.find(string.lower(b.Text),q)then m.Visible=true;h=true else m.Visible=false end end end;cat.Visible=(q==""or h)end end)
Library:AddKeybind("Abrir/Fechar Menu",Library.OpenKey,function(k,p)if p then MainFrame.Visible=not MainFrame.Visible end end)

return Library
