-- Manus GUI Library V7.4 (Framework & Original UI Restored)
local Library = {}

-- Serviços
local RunService = game:GetService("RunService")
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
Library.Killaura = {
    Target = nil,
    Enabled = false,
    Distance = 10
}

-- COOLDOWN DE TELEPORTE
Library.TeleportCooldownUntil = 0
Library.TeleportCooldownDuration = 5

--[[
    1. MÉTODOS DE CONFIGURAÇÃO E UTILIDADES
]]
local CONFIG_FOLDER = "Universal Project"
pcall(function() if makefolder and not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end end)

function Library:SaveConfig(name, data)
    pcall(function() if writefile then writefile(CONFIG_FOLDER .. "/" .. name .. ".json", HttpService:JSONEncode(data)) end end)
end

function Library:LoadConfig(name)
    local path = CONFIG_FOLDER .. "/" .. name .. ".json"
    if readfile and isfile and isfile(path) then
        local ok, result = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
        if ok and type(result) == "table" then return result end
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

function Library:IsWhitelisted(playerObj) return playerObj and (Library.Whitelist[playerObj.UserId] or false) end

function Library:ToggleWhitelist(playerObj)
    if not playerObj then return end
    Library.Whitelist[playerObj.UserId] = not Library.Whitelist[playerObj.UserId]
    return Library.Whitelist[playerObj.UserId]
end

function Library:TeleportToPlayer(targetPlayer)
    if tick() < Library.TeleportCooldownUntil then
        print("⚠️ Teleporte em cooldown!")
        return
    end
    local localChar = player.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    local targetChar = targetPlayer and targetPlayer.Character
    local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
    if localRoot and targetRoot then
        localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 3, 0)
        Library.TeleportCooldownUntil = tick() + Library.TeleportCooldownDuration
    end
end

--[[
    2. INICIALIZAÇÃO DA GUI
]]
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "ManusGuiLib_V7_4"; ScreenGui.ResetOnSpawn = false; ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if not pcall(function() ScreenGui.Parent = CoreGui end) then ScreenGui.Parent = player:WaitForChild("PlayerGui") end
Library.ScreenGui = ScreenGui

local MainFrame = Instance.new("Frame"); MainFrame.Name = "MainFrame"; MainFrame.Size = UDim2.new(1, 0, 1, 0); MainFrame.BackgroundTransparency = 1; MainFrame.Visible = true; MainFrame.Parent = ScreenGui
local TopBar = Instance.new("Frame"); TopBar.Name = "TopBar"; TopBar.Size = UDim2.new(0, 500, 0, 35); TopBar.Position = UDim2.new(0.5, -250, 0, 15); TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); TopBar.BorderSizePixel = 0; TopBar.Parent = MainFrame; Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 4)
local SearchBox = Instance.new("TextBox"); SearchBox.Size = UDim2.new(0, 200, 0, 24); SearchBox.Position = UDim2.new(0.5, -100, 0.5, -12); SearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35); SearchBox.PlaceholderText = "Pesquisar módulos..."; SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255); SearchBox.Font = Enum.Font.SourceSans; SearchBox.TextSize = 14; SearchBox.Parent = TopBar; Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 4)
local SettingsBtn = Instance.new("TextButton"); SettingsBtn.Size = UDim2.new(0, 80, 0, 24); SettingsBtn.Position = UDim2.new(1, -90, 0.5, -12); SettingsBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); SettingsBtn.Text = "⚙️ Configs"; SettingsBtn.TextColor3 = Color3.fromRGB(200, 200, 200); SettingsBtn.Font = Enum.Font.SourceSansBold; SettingsBtn.TextSize = 13; SettingsBtn.Parent = TopBar; Instance.new("UICorner", SettingsBtn).CornerRadius = UDim.new(0, 4)

--[[
    3. FUNÇÕES UTILITÁRIAS
]]
local categoryObjects = {}
local function saveCategoryPositions() local d={}; for _,c in ipairs(Library.Categories) do if c and c.Parent then local o=categoryObjects[c.Name]; d[c.Name]={x=c.Position.X.Offset,y=c.Position.Y.Offset,expanded=o and o.Expanded or true} end end; Library:SaveConfig("category_positions", d) end
local function loadCategoryPositions() return Library:LoadConfig("category_positions") end
local function makeDraggable(f, h, onDragEnd) local d,i,s,p; h.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then d=true;s=inp.Position;p=f.Position;inp.Changed:Connect(function() if inp.UserInputState==Enum.UserInputState.End then d=false;if onDragEnd then onDragEnd() end end end) end end); h.InputChanged:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseMovement then i=inp end end); UserInputService.InputChanged:Connect(function(inp) if inp==i and d then local a=inp.Position-s;f.Position=UDim2.new(p.X.Scale,p.X.Offset+a.X,p.Y.Scale,p.Y.Offset+a.Y) end end) end

--[[
    4. API DE JANELAS E CATEGORIAS
]]
function Library:CreateWindow(title, size, position)
    if Library.ActiveWindows[title] and Library.ActiveWindows[title].Frame.Parent then Library.ActiveWindows[title].Frame:Destroy() end
    local windowObj={}; local WindowFrame=Instance.new("Frame"); WindowFrame.Name=title; WindowFrame.Size=size or UDim2.new(0,350,0,250); WindowFrame.Position=position or UDim2.new(0.5,-175,0.5,-125); WindowFrame.BackgroundColor3=Color3.fromRGB(30,30,30); WindowFrame.BorderSizePixel=0; WindowFrame.Visible=true; Instance.new("UICorner",WindowFrame).CornerRadius=UDim.new(0,5)
    local TitleBar=Instance.new("TextLabel"); TitleBar.Size=UDim2.new(1,0,0,35); TitleBar.Text="  "..title; TitleBar.TextColor3=Color3.fromRGB(255,255,255); TitleBar.BackgroundColor3=Color3.fromRGB(40,40,40); TitleBar.Font=Enum.Font.SourceSansBold; TitleBar.TextSize=16; TitleBar.TextXAlignment=Enum.TextXAlignment.Left; TitleBar.Parent=WindowFrame
    local CloseButton=Instance.new("TextButton"); CloseButton.Size=UDim2.new(0,35,1,0); CloseButton.Position=UDim2.new(1,-35,0,0); CloseButton.Text="X"; CloseButton.TextColor3=Color3.fromRGB(255,80,80); CloseButton.BackgroundTransparency=1; CloseButton.TextSize=18; CloseButton.Parent=TitleBar; CloseButton.MouseButton1Click:Connect(function() WindowFrame:Destroy() end)
    local ContentFrame=Instance.new("Frame"); ContentFrame.Size=UDim2.new(1,0,1,-35); ContentFrame.Position=UDim2.new(0,0,0,35); ContentFrame.BackgroundTransparency=1; ContentFrame.Parent=WindowFrame
    local mainLayout = Instance.new("UIListLayout", ContentFrame); mainLayout.Padding = UDim.new(0,8); mainLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
    Instance.new("UIPadding", ContentFrame).PaddingTop = UDim.new(0,8)
    windowObj.Frame=WindowFrame; windowObj.Content=ContentFrame; windowObj.Title=TitleBar; makeDraggable(WindowFrame,TitleBar); WindowFrame.Parent=MainFrame
    function windowObj:AddButton(t,c)
        local b=Instance.new("TextButton"); b.Size=UDim2.new(0.9,0,0,32); b.BackgroundColor3=Color3.fromRGB(50,50,50); b.TextColor3=Color3.fromRGB(220,220,220); b.Text=t; b.TextSize=14; b.Font=Enum.Font.SourceSansBold; b.Parent=ContentFrame; Instance.new("UICorner",b); b.MouseButton1Click:Connect(c); return b
    end
    function windowObj:AddLabel(text, centered)
        local label = Instance.new("TextLabel"); label.Size = UDim2.new(0.9, 0, 0, 30); label.Text = text; label.Font = Enum.Font.SourceSans; label.TextSize = 14; label.TextColor3 = Color3.fromRGB(220, 220, 220); label.BackgroundTransparency = 1; label.TextXAlignment = centered and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left; label.Parent = ContentFrame
        return label
    end
    function windowObj:AddScrollableList()
        local frame = Instance.new("ScrollingFrame"); frame.Size = UDim2.new(0.95, 0, 0.7, 0); frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35); frame.BorderSizePixel = 0; frame.ScrollBarThickness = 6; frame.Parent = ContentFrame;
        local listLayout = Instance.new("UIListLayout", frame); listLayout.Padding = UDim.new(0, 5); listLayout.SortOrder = Enum.SortOrder.LayoutOrder; listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() frame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y) end)
        Instance.new("UICorner", frame)
        return frame
    end
    Library.ActiveWindows[title] = windowObj
    return windowObj
end

function Library:CreateCategory(n,p) 
    local cF=Instance.new("Frame"); cF.Name=n; cF.Size=UDim2.new(0,150,0,30); cF.Position=p; cF.BackgroundColor3=Color3.fromRGB(30,30,30); cF.BorderSizePixel=0; cF.Parent=MainFrame; 
    local T=Instance.new("TextButton"); T.Size=UDim2.new(1,0,1,0); T.Text=n; T.TextColor3=Color3.fromRGB(255,255,255); T.Font=Enum.Font.SourceSansBold; T.TextSize=16; T.BackgroundTransparency=1; T.Parent=cF; 
    local oF=Instance.new("Frame"); oF.Size=UDim2.new(1,0,0,0); oF.Position=UDim2.new(0,0,1,0); oF.BackgroundColor3=Color3.fromRGB(40,40,40); oF.BorderSizePixel=0; oF.ClipsDescendants=true; oF.Parent=cF; 
    local uL=Instance.new("UIListLayout",oF); uL.SortOrder=Enum.SortOrder.LayoutOrder; 
    local cO={Frame=cF,Options=oF,Expanded=true}; makeDraggable(cF,T,saveCategoryPositions); table.insert(Library.Categories,cF); categoryObjects[n]=cO; 
    local function rOF() local h=0; for _,v in pairs(oF:GetChildren()) do if v:IsA("Frame") then h=h+v.Size.Y.Offset end end; oF.Size=UDim2.new(1,0,0,h) end; 
    T.MouseButton2Click:Connect(function() cO.Expanded=not cO.Expanded; oF.Visible=cO.Expanded; saveCategoryPositions() end); 
    function cO:AddModule(mN,cb,iT) 
        local mO={Enabled=false,IsTrigger=iT or false,SubExpanded=false}; 
        local mC=Instance.new("Frame"); mC.Size=UDim2.new(1,0,0,25); mC.BackgroundTransparency=1; mC.Parent=oF; 
        local mB=Instance.new("TextButton"); mB.Size=UDim2.new(1,0,0,25); mB.BackgroundColor3=Color3.fromRGB(45,45,45); mB.BorderSizePixel=0; mB.Text="  "..mN; mB.TextColor3=Color3.fromRGB(200,200,200); mB.Font=Enum.Font.SourceSans; mB.TextSize=14; mB.TextXAlignment=Enum.TextXAlignment.Left; mB.Parent=mC; 
        local sF=Instance.new("ScrollingFrame"); sF.Size=UDim2.new(1,0,0,0); sF.Position=UDim2.new(0,0,0,25); sF.BackgroundColor3=Color3.fromRGB(35,35,35); sF.BorderSizePixel=0; sF.Visible=false; sF.ScrollBarThickness=2; sF.Parent=mC; 
        local sL=Instance.new("UIListLayout",sF); sL.SortOrder=Enum.SortOrder.LayoutOrder; sL.Padding=UDim.new(0,1); 
        local function uS() local cH=sL.AbsoluteContentSize.Y; local vH=sF.Visible and math.min(cH,120) or 0; sF.Size=UDim2.new(1,0,0,vH); sF.CanvasSize=UDim2.new(0,0,0,cH); mC.Size=UDim2.new(1,0,0,25+vH); rOF() end; 
        uS(); sL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(uS); 
        mB.MouseButton1Click:Connect(function() if mO.IsTrigger then cb() else mO.Enabled=not mO.Enabled; mB.TextColor3=mO.Enabled and Color3.fromRGB(0,255,120) or Color3.fromRGB(200,200,200); cb(mO.Enabled) end end); 
        mB.MouseButton2Click:Connect(function() mO.SubExpanded=not mO.SubExpanded; sF.Visible=mO.SubExpanded; uS() end); 
        function mO:AddToggle(t,d,c) 
            local s=d or false; local b=Instance.new("TextButton"); b.Size=UDim2.new(1,0,0,18); b.BackgroundTransparency=1; b.Text="  "..t; b.TextColor3=s and Color3.fromRGB(0,200,100) or Color3.fromRGB(160,160,160); b.Font=Enum.Font.SourceSans; b.TextSize=12; b.TextXAlignment=Enum.TextXAlignment.Left; b.LayoutOrder=1; b.Parent=sF; 
            b.MouseButton1Click:Connect(function() s=not s; b.TextColor3=s and Color3.fromRGB(0,200,100) or Color3.fromRGB(160,160,160); c(s) end) 
        end; 
        function mO:AddSlider(t,min,max,d,c) 
            local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,26); f.BackgroundTransparency=1; f.LayoutOrder=3; f.Parent=sF; 
            local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-4,0,13); l.Position=UDim2.new(0,4,0,1); l.Text=t.." "..tostring(d); l.TextColor3=Color3.fromRGB(180,180,180); l.BackgroundTransparency=1; l.TextSize=11; l.Font=Enum.Font.SourceSans; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=f; 
            local bar=Instance.new("Frame"); bar.Size=UDim2.new(1,-8,0,5); bar.Position=UDim2.new(0,4,0,16); bar.BackgroundColor3=Color3.fromRGB(55,55,55); bar.BorderSizePixel=0; bar.Parent=f; Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0); 
            local fill=Instance.new("Frame"); fill.Size=UDim2.new(math.clamp((d-min)/(max-min),0,1),0,1,0); fill.BackgroundColor3=Color3.fromRGB(0,120,200); fill.BorderSizePixel=0; fill.Parent=bar; Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0); 
            local function u(inp) local p=math.clamp((inp.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1); fill.Size=UDim2.new(p,0,1,0); local v=math.floor(min+(p*(max-min))); l.Text=t.." "..tostring(v); c(v) end; 
            local dr=false; bar.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dr=true; u(inp) end end); 
            UserInputService.InputChanged:Connect(function(inp) if dr and inp.UserInputType==Enum.UserInputType.MouseMovement then u(inp) end end); 
            UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end) 
        end; 
        return mO 
    end; 
    return cO 
end

--[[
    5. OVERLAY & FEATURES
]]
function Library:CreateOverlay(id, title, color)
    if Library.Overlays[id] then return Library.Overlays[id] end
    local o=Instance.new("Frame"); o.Size=UDim2.new(0,220,0,80); o.BackgroundColor3=Color3.fromRGB(20,20,25); o.BackgroundTransparency=0.2; o.BorderSizePixel=0; o.Visible=false; o.Parent=ScreenGui; Instance.new("UICorner",o).CornerRadius=UDim.new(0,8)
    local b=Instance.new("Frame"); b.Size=UDim2.new(1,0,0,2); b.BackgroundColor3=color or Color3.fromRGB(0,150,255); b.BorderSizePixel=0; b.Parent=o; Instance.new("UICorner",b)
    local t=Instance.new("TextLabel"); t.Size=UDim2.new(1,-10,0,20); t.Position=UDim2.new(0,10,0,5); t.Text=title; t.TextColor3=color or Color3.fromRGB(0,150,255); t.Font=Enum.Font.SourceSansBold; t.TextSize=12; t.BackgroundTransparency=1; t.TextXAlignment=Enum.TextXAlignment.Left; t.Parent=o
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-20,0,40); l.Position=UDim2.new(0,10,0,30); l.Text="Aguardando..."; l.TextColor3=Color3.fromRGB(255,255,255); l.Font=Enum.Font.SourceSans; l.TextSize=14; l.BackgroundTransparency=1; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=o
    local overlayObj = {Frame = o, Label = l}
    function overlayObj:SetText(txt) l.Text = txt end
    function overlayObj:SetVisible(v) o.Visible = v end
    Library.Overlays[id] = overlayObj
    return overlayObj
end

--[[
    6. JANELAS DE CONFIGURAÇÃO (RESTAURADAS COM ABAS)
]]
function Library:OpenWhitelistWindow()
    local window = Library:CreateWindow("🛡️ Whitelist & Teleporte", UDim2.new(0, 400, 0, 350))
    local content = window.Content
    local currentTab = "Marcador"
    
    local TabFrame = Instance.new("Frame"); TabFrame.Size=UDim2.new(0.9,0,0,30); TabFrame.BackgroundTransparency=1; TabFrame.Parent=content
    local Btn1 = Instance.new("TextButton"); Btn1.Size=UDim2.new(0.5,-2,1,0); Btn1.BackgroundColor3=Color3.fromRGB(0,150,255); Btn1.Text="Marcador"; Btn1.TextColor3=Color3.fromRGB(255,255,255); Btn1.Font=Enum.Font.SourceSansBold; Btn1.Parent=TabFrame; Instance.new("UICorner",Btn1)
    local Btn2 = Instance.new("TextButton"); Btn2.Size=UDim2.new(0.5,-2,1,0); Btn2.Position=UDim2.new(0.5,2,0,0); Btn2.BackgroundColor3=Color3.fromRGB(45,45,45); Btn2.Text="Marcados"; Btn2.TextColor3=Color3.fromRGB(200,200,200); Btn2.Font=Enum.Font.SourceSansBold; Btn2.Parent=TabFrame; Instance.new("UICorner",Btn2)
    
    local scroll = window:AddScrollableList()
    scroll.Size = UDim2.new(0.95, 0, 0.7, 0)
    
    local function refresh()
        scroll:ClearAllChildren()
        Instance.new("UIListLayout", scroll).Padding = UDim.new(0,5)
        for _, p in ipairs(Players:GetPlayers()) do
            if p == player then continue end
            local isW = Library:IsWhitelisted(p)
            if (currentTab == "Marcador") or (currentTab == "Marcados" and isW) then
                local pF=Instance.new("Frame"); pF.Size=UDim2.new(0.95,0,0,35); pF.BackgroundTransparency=1; pF.Parent=scroll
                local nL=Instance.new("TextLabel"); nL.Size=UDim2.new(1,-110,1,0); nL.Text="  "..p.DisplayName; nL.TextColor3=Color3.fromRGB(220,220,220); nL.Font=Enum.Font.SourceSans; nL.TextSize=14; nL.TextXAlignment=Enum.TextXAlignment.Left; nL.BackgroundTransparency=1; nL.Parent=pF
                local wB=Instance.new("TextButton"); wB.Size=UDim2.new(0,50,0.8,0); wB.Position=UDim2.new(1,-105,0.1,0); wB.BackgroundColor3=isW and Color3.fromRGB(0,180,80) or Color3.fromRGB(50,50,50); wB.Text=isW and "WL" or "Add"; wB.TextColor3=Color3.fromRGB(255,255,255); wB.Font=Enum.Font.SourceSansBold; wB.TextSize=12; wB.Parent=pF; Instance.new("UICorner",wB)
                wB.MouseButton1Click:Connect(function() Library:ToggleWhitelist(p); refresh() end)
                local tB=Instance.new("TextButton"); tB.Size=UDim2.new(0,50,0.8,0); tB.Position=UDim2.new(1,-50,0.1,0); tB.BackgroundColor3=Color3.fromRGB(0,150,255); tB.Text="TP"; tB.TextColor3=Color3.fromRGB(255,255,255); tB.Font=Enum.Font.SourceSansBold; tB.TextSize=12; tB.Parent=pF; Instance.new("UICorner",tB)
                tB.MouseButton1Click:Connect(function() Library:TeleportToPlayer(p) end)
            end
        end
    end
    Btn1.MouseButton1Click:Connect(function() currentTab="Marcador"; Btn1.BackgroundColor3=Color3.fromRGB(0,150,255); Btn2.BackgroundColor3=Color3.fromRGB(45,45,45); refresh() end)
    Btn2.MouseButton1Click:Connect(function() currentTab="Marcados"; Btn2.BackgroundColor3=Color3.fromRGB(0,150,255); Btn1.BackgroundColor3=Color3.fromRGB(45,45,45); refresh() end)
    refresh()
end

function Library:OpenKillauraTargetWindow()
    local window = Library:CreateWindow("🎯 Alvo Killaura", UDim2.new(0, 300, 0, 350))
    local scroll = window:AddScrollableList()
    scroll.Size = UDim2.new(0.95, 0, 0.8, 0)
    local function refresh()
        scroll:ClearAllChildren()
        Instance.new("UIListLayout", scroll).Padding = UDim.new(0,5)
        for _, p in ipairs(Players:GetPlayers()) do
            if p == player then continue end
            local pF=Instance.new("Frame"); pF.Size=UDim2.new(0.95,0,0,35); pF.BackgroundTransparency=1; pF.Parent=scroll
            local nL=Instance.new("TextLabel"); nL.Size=UDim2.new(1,-60,1,0); nL.Text="  "..p.DisplayName; nL.TextColor3=Color3.fromRGB(220,220,220); nL.Font=Enum.Font.SourceSans; nL.TextSize=14; nL.TextXAlignment=Enum.TextXAlignment.Left; nL.BackgroundTransparency=1; nL.Parent=pF
            local sB=Instance.new("TextButton"); sB.Size=UDim2.new(0,50,0.8,0); sB.Position=UDim2.new(1,-55,0.1,0); sB.BackgroundColor3=(Library.Killaura.Target==p) and Color3.fromRGB(0,180,80) or Color3.fromRGB(50,50,50); sB.Text=(Library.Killaura.Target==p) and "ALVO" or "Sel."; sB.TextColor3=Color3.fromRGB(255,255,255); sB.Font=Enum.Font.SourceSansBold; sB.TextSize=12; sB.Parent=pF; Instance.new("UICorner",sB)
            sB.MouseButton1Click:Connect(function() Library.Killaura.Target=p; refresh() end)
        end
    end
    refresh()
end

-- Configurações Globais
SettingsBtn.MouseButton1Click:Connect(function() 
    local w=Library:CreateWindow("Configurações Globais",UDim2.new(0,300,0,300)); 
    w:AddButton("🛡️ Gerenciar Jogadores", function() Library:OpenWhitelistWindow() end)
    w:AddButton("🎯 Alvo Killaura", function() Library:OpenKillauraTargetWindow() end)
    local kb=w:AddButton("⌨️ Atalho Menu: "..Library.OpenKey.Name, function() end)
    kb.MouseButton1Click:Connect(function() kb.Text="..."; local c; c=UserInputService.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Keyboard then Library.OpenKey=i.KeyCode; kb.Text="⌨️ Atalho Menu: "..i.KeyCode.Name; c:Disconnect() end end) end)
    w:AddButton("❌ Remover Script (K)", function() ScreenGui:Destroy() end) 
end)

-- Atalhos Globais
UserInputService.InputBegan:Connect(function(i,p) 
    if not p and i.KeyCode==Library.OpenKey then MainFrame.Visible = not MainFrame.Visible end
    if not p and i.KeyCode==Library.RemoveKey then ScreenGui:Destroy() end
end)

return Library
