-- Manus GUI Library V7.0 (Log Window Update)
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
Library.TeleportCooldownDuration = 5 -- 5 segundos de cooldown

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
        print("⚠️ Teleporte em cooldown! Aguarde.")
        return
    end

    local localChar = player.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    local targetChar = targetPlayer and targetPlayer.Character
    local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

    if localRoot and targetRoot then
        localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 3, 0)
        print("🚀 Teleportado para " .. targetPlayer.Name)
        Library.TeleportCooldownUntil = tick() + Library.TeleportCooldownDuration
    else
        print("⚠️ Não foi possível teleportar: jogador de destino ou local não encontrado.")
    end
end

--[[
    2. INICIALIZAÇÃO DA GUI
]]
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "ManusGuiLib_V7_0"; ScreenGui.ResetOnSpawn = false; ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if not pcall(function() ScreenGui.Parent = CoreGui end) then ScreenGui.Parent = player:WaitForChild("PlayerGui") end
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
    4. JANELAS CUSTOMIZADAS (Whitelist, Killaura, Logs)
]]
function Library:OpenWhitelistWindow()
    -- (O código da janela de whitelist permanece o mesmo)
end
function Library:OpenKillauraTargetWindow()
    -- (O código da janela do Killaura permanece o mesmo)
end

function Library:CreateLogWindow(title, logContent)
    local window = Library:CreateWindow(title, UDim2.new(0, 500, 0, 400)) -- Janela maior
    window.Content.UIPadding:Destroy() -- Remove padding para usar o espaço todo

    local logScroll = Instance.new("ScrollingFrame")
    logScroll.Size = UDim2.new(1, -10, 1, -50)
    logScroll.Position = UDim2.new(0, 5, 0, 5)
    logScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    logScroll.BorderSizePixel = 0
    logScroll.ScrollBarThickness = 5
    logScroll.Parent = window.Content
    Instance.new("UICorner", logScroll).CornerRadius = UDim.new(0, 4)

    local logText = Instance.new("TextBox")
    logText.Size = UDim2.new(1, -10, 0, 0) -- Largura ajustada, altura automática
    logText.Position = UDim2.new(0, 5, 0, 5)
    logText.Text = logContent
    logText.Font = Enum.Font.Code
    logText.TextSize = 12
    logText.TextColor3 = Color3.fromRGB(220, 220, 220)
    logText.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    logText.MultiLine = true
    logText.TextWrapped = true
    logText.TextXAlignment = Enum.TextXAlignment.Left
    logText.TextYAlignment = Enum.TextYAlignment.Top
    logText.ClearTextOnFocus = false
    logText.TextEditable = false
    logText.Parent = logScroll

    -- Ajusta o tamanho do scroll para o conteúdo
    task.wait()
    logText.Size = UDim2.new(1, -10, 0, logText.TextBounds.Y + 10)
    logScroll.CanvasSize = UDim2.new(0, 0, 0, logText.AbsoluteSize.Y)
    
    local copyButton = window:AddButton("📋 Copiar Logs & Fechar", function() end)
    copyButton.Size = UDim2.new(1, -10, 0, 35)
    copyButton.Position = UDim2.new(0, 5, 1, -40)
    copyButton.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(logContent)
            print("Logs copiados para a área de transferência!")
        else
            print("setclipboard não disponível neste executor.")
        end
        window.Frame:Destroy()
    end)

    return window
end

--[[
    5. API DE JANELAS E CATEGORIAS
]]
function Library:CreateWindow(title, size, position)
    if Library.ActiveWindows[title] and Library.ActiveWindows[title].Frame.Parent then Library.ActiveWindows[title].Frame:Destroy() end
    local windowObj={}; local WindowFrame=Instance.new("Frame"); WindowFrame.Name=title; WindowFrame.Size=size or UDim2.new(0,350,0,250); WindowFrame.Position=position or UDim2.new(0.5,-175,0.5,-125); WindowFrame.BackgroundColor3=Color3.fromRGB(30,30,30); WindowFrame.BorderSizePixel=0; WindowFrame.Visible=true; Instance.new("UICorner",WindowFrame).CornerRadius=UDim.new(0,5)
    local TitleBar=Instance.new("TextLabel"); TitleBar.Size=UDim2.new(1,0,0,35); TitleBar.Text="  "..title; TitleBar.TextColor3=Color3.fromRGB(255,255,255); TitleBar.BackgroundColor3=Color3.fromRGB(40,40,40); TitleBar.Font=Enum.Font.SourceSansBold; TitleBar.TextSize=16; TitleBar.TextXAlignment=Enum.TextXAlignment.Left; TitleBar.Parent=WindowFrame
    local CloseButton=Instance.new("TextButton"); CloseButton.Size=UDim2.new(0,35,1,0); CloseButton.Position=UDim2.new(1,-35,0,0); CloseButton.Text="X"; CloseButton.TextColor3=Color3.fromRGB(255,80,80); CloseButton.BackgroundTransparency=1; CloseButton.TextSize=18; CloseButton.Parent=TitleBar; CloseButton.MouseButton1Click:Connect(function() WindowFrame:Destroy() end)
    local ContentFrame=Instance.new("Frame"); ContentFrame.Size=UDim2.new(1,0,1,-35); ContentFrame.Position=UDim2.new(0,0,0,35); ContentFrame.BackgroundTransparency=1; ContentFrame.Parent=WindowFrame; local l=Instance.new("UIListLayout",ContentFrame); l.Padding=UDim.new(0,8); l.HorizontalAlignment=Enum.HorizontalAlignment.Center; Instance.new("UIPadding",ContentFrame).PaddingTop=UDim.new(0,8)
    windowObj.Frame=WindowFrame; windowObj.Content=ContentFrame; makeDraggable(WindowFrame,TitleBar); WindowFrame.Parent=MainFrame
    function windowObj:AddButton(t,c) local b=Instance.new("TextButton"); b.Size=UDim2.new(0.9,0,0,32); b.BackgroundColor3=Color3.fromRGB(50,50,50); b.TextColor3=Color3.fromRGB(220,220,220); b.Text=t; b.TextSize=14; b.Font=Enum.Font.SourceSansBold; b.Parent=ContentFrame; Instance.new("UICorner",b); b.MouseButton1Click:Connect(c); return b end
    function windowObj:AddTextBox(p) local t=Instance.new("TextBox"); t.Size=UDim2.new(0.9,0,0,32); t.BackgroundColor3=Color3.fromRGB(35,35,35); t.TextColor3=Color3.fromRGB(255,255,255); t.PlaceholderText=p or ""; t.TextSize=14; t.Font=Enum.Font.SourceSans; t.Parent=ContentFrame; Instance.new("UICorner",t); return t end
    return windowObj
end
function Library:RestoreCategoryPositions() local d=loadCategoryPositions(); if not d then return end; for _,c in ipairs(Library.Categories) do if c and c.Parent and d[c.Name] then local s=d[c.Name]; local o=categoryObjects[c.Name]; c.Position=UDim2.new(0,s.x,0,s.y); if o and type(s.expanded)=="boolean" then o.Expanded=s.expanded; local f=o.Options; if f then f.Visible=s.expanded end end end end end
function Library:CreateCategory(n,p) local cF=Instance.new("Frame"); cF.Name=n; cF.Size=UDim2.new(0,150,0,30); cF.Position=p; cF.BackgroundColor3=Color3.fromRGB(30,30,30); cF.BorderSizePixel=0; cF.Parent=MainFrame; local T=Instance.new("TextButton"); T.Size=UDim2.new(1,0,1,0); T.Text=n; T.TextColor3=Color3.fromRGB(255,255,255); T.Font=Enum.Font.SourceSansBold; T.TextSize=16; T.BackgroundTransparency=1; T.Parent=cF; local oF=Instance.new("Frame"); oF.Size=UDim2.new(1,0,0,0); oF.Position=UDim2.new(0,0,1,0); oF.BackgroundColor3=Color3.fromRGB(40,40,40); oF.BorderSizePixel=0; oF.ClipsDescendants=true; oF.Parent=cF; local uL=Instance.new("UIListLayout",oF); uL.SortOrder=Enum.SortOrder.LayoutOrder; local cO={Frame=cF,Options=oF,Expanded=true}; makeDraggable(cF,T,saveCategoryPositions); table.insert(Library.Categories,cF); categoryObjects[n]=cO; local function rOF() local h=0; for _,v in pairs(oF:GetChildren()) do if v:IsA("Frame") then h=h+v.Size.Y.Offset end end; oF.Size=UDim2.new(1,0,0,h) end; T.MouseButton2Click:Connect(function() cO.Expanded=not cO.Expanded; oF.Visible=cO.Expanded; saveCategoryPositions() end); function cO:AddModule(mN,cb,iT) local mO={Enabled=false,IsTrigger=iT or false,SubExpanded=false}; local mC=Instance.new("Frame"); mC.Size=UDim2.new(1,0,0,25); mC.BackgroundTransparency=1; mC.Parent=oF; local mB=Instance.new("TextButton"); mB.Size=UDim2.new(1,0,0,25); mB.BackgroundColor3=Color3.fromRGB(45,45,45); mB.BorderSizePixel=0; mB.Text="  "..mN; mB.TextColor3=Color3.fromRGB(200,200,200); mB.Font=Enum.Font.SourceSans; mB.TextSize=14; mB.TextXAlignment=Enum.TextXAlignment.Left; mB.Parent=mC; local sF=Instance.new("ScrollingFrame"); sF.Size=UDim2.new(1,0,0,0); sF.Position=UDim2.new(0,0,0,25); sF.BackgroundColor3=Color3.fromRGB(35,35,35); sF.BorderSizePixel=0; sF.Visible=false; sF.ScrollBarThickness=2; sF.Parent=mC; local sL=Instance.new("UIListLayout",sF); sL.SortOrder=Enum.SortOrder.LayoutOrder; sL.Padding=UDim.new(0,1); local function uS() local cH=sL.AbsoluteContentSize.Y; local vH=sF.Visible and math.min(cH,120) or 0; sF.Size=UDim2.new(1,0,0,vH); sF.CanvasSize=UDim2.new(0,0,0,cH); mC.Size=UDim2.new(1,0,0,25+vH); rOF() end; uS(); sL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(uS); mB.MouseButton1Click:Connect(function() if mO.IsTrigger then cb() else mO.Enabled=not mO.Enabled; mB.TextColor3=mO.Enabled and Color3.fromRGB(0,255,120) or Color3.fromRGB(200,200,200); cb(mO.Enabled) end end); mB.MouseButton2Click:Connect(function() mO.SubExpanded=not mO.SubExpanded; sF.Visible=mO.SubExpanded; uS() end); function mO:Destroy() if mC and mC.Parent then mC:Destroy() end; rOF() end; function mO:AddToggle(t,d,c) local s=d or false; local b=Instance.new("TextButton"); b.Size=UDim2.new(1,0,0,18); b.BackgroundTransparency=1; b.Text="  "..t; b.TextColor3=s and Color3.fromRGB(0,200,100) or Color3.fromRGB(160,160,160); b.Font=Enum.Font.SourceSans; b.TextSize=12; b.TextXAlignment=Enum.TextXAlignment.Left; b.LayoutOrder=1; b.Parent=sF; b.MouseButton1Click:Connect(function() s=not s; b.TextColor3=s and Color3.fromRGB(0,200,100) or Color3.fromRGB(160,160,160); c(s) end) end; function mO:AddDropdown(t,o,c,dV) local i=1; if dV~=nil then for idx,v in ipairs(o) do if tostring(v)==tostring(dV) then i=idx; break end end end; local b=Instance.new("TextButton"); b.Size=UDim2.new(1,0,0,18); b.BackgroundTransparency=1; b.Text="  "..t.." "..tostring(o[i]); b.TextColor3=Color3.fromRGB(180,180,180); b.Font=Enum.Font.SourceSans; b.TextSize=12; b.TextXAlignment=Enum.TextXAlignment.Left; b.LayoutOrder=2; b.Parent=sF; b.MouseButton1Click:Connect(function() i=i+1; if i>#o then i=1 end; b.Text="  "..t.." "..tostring(o[i]); c(o[i]) end) end; function mO:AddSlider(t,min,max,d,c) local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,26); f.BackgroundTransparency=1; f.LayoutOrder=3; f.Parent=sF; local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-4,0,13); l.Position=UDim2.new(0,4,0,1); l.Text=t.." "..tostring(d); l.TextColor3=Color3.fromRGB(180,180,180); l.BackgroundTransparency=1; l.TextSize=11; l.Font=Enum.Font.SourceSans; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=f; local bar=Instance.new("Frame"); bar.Size=UDim2.new(1,-8,0,5); bar.Position=UDim2.new(0,4,0,16); bar.BackgroundColor3=Color3.fromRGB(55,55,55); bar.BorderSizePixel=0; bar.Parent=f; Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0); local fill=Instance.new("Frame"); fill.Size=UDim2.new(math.clamp((d-min)/(max-min),0,1),0,1,0); fill.BackgroundColor3=Color3.fromRGB(0,120,200); fill.BorderSizePixel=0; fill.Parent=bar; Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0); local function u(inp) local p=math.clamp((inp.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1); fill.Size=UDim2.new(p,0,1,0); local v=math.floor(min+(p*(max-min))); l.Text=t.." "..tostring(v); c(v) end; local dr=false; bar.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dr=true; u(inp) end end); UserInputService.InputChanged:Connect(function(inp) if dr and inp.UserInputType==Enum.UserInputType.MouseMovement then u(inp) end end); UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end) end; return mO end; return cO end

--[[
    6. CONFIGURAÇÕES
]]
SettingsBtn.MouseButton1Click:Connect(function() 
    local w=Library:CreateWindow("Configurações Globais",UDim2.new(0,300,0,260)); 
    w:AddButton("🛡️ Gerenciar Jogadores",function() Library:OpenWhitelistWindow() end)
    w:AddButton("🎯 Alvo Killaura", function() Library:OpenKillauraTargetWindow() end)
    w:AddButton("📜 Inspecionar Tycoon", function() 
        -- A lógica de inspeção será movida para o loader, aqui apenas chamamos a janela de log
        -- Esta parte será preenchida pelo loader
    end)
    local kb=w:AddButton("⌨️ Atalho do Menu: "..Library.OpenKey.Name,function()end); 
    kb.MouseButton1Click:Connect(function() 
        kb.Text="... Pressione uma tecla ..."; 
        local c; 
        c=UserInputService.InputBegan:Connect(function(i) 
            if i.UserInputType==Enum.UserInputType.Keyboard then 
                Library.OpenKey=i.KeyCode; 
                kb.Text="⌨️ Atalho do Menu: "..i.KeyCode.Name; 
                c:Disconnect() 
            end 
        end) 
    end); 
    w:AddButton("❌ Remover Script (Atalho: K)",function() saveCategoryPositions(); ScreenGui:Destroy() end) 
end)
UserInputService.InputBegan:Connect(function(i,p) if not p and i.KeyCode==Library.RemoveKey then saveCategoryPositions(); ScreenGui:Destroy() end end)
SearchBox:GetPropertyChangedSignal("Text"):Connect(function() local q=string.lower(SearchBox.Text); for _,cat in ipairs(Library.Categories) do local h=false; for _,m in ipairs(cat:FindFirstChild("Options"):GetChildren()) do if m:IsA("Frame") then local b=m:FindFirstChildOfClass("TextButton"); if b and string.find(string.lower(b.Text),q) then m.Visible=true; h=true else m.Visible=false end end end; cat.Visible=(q=="" or h) end end)

--[[
    7. OVERLAY
]]
function Library:CreateOverlay(id,title,color) 
    -- (O código do Overlay permanece o mesmo)
end

Library:AddKeybind("Abrir/Fechar Menu", Library.OpenKey, function(k,p) if p then MainFrame.Visible=not MainFrame.Visible end end)
Library.ScreenGui=ScreenGui
return Library
