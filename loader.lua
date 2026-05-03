-- ========== LOADER PRINCIPAL (v22 - GUI Embutida) ==========
print("🔧 Iniciando carregamento v22. GUI agora está embutida.")

--[[
    Etapa 1: Código da Biblioteca GUI (embutido para evitar erros de cache)
]]
print("\n--- Etapa 1: Carregando GUI Embutida ---")
local gui_code = [[
    -- Manus GUI Library V7.2 (Complete Restoration)
    local Library = {}

    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local CoreGui = game:GetService("CoreGui")
    local HttpService = game:GetService("HttpService")
    local player = Players.LocalPlayer

    Library.OpenKey = Enum.KeyCode.Insert
    Library.RemoveKey = Enum.KeyCode.K
    Library.Categories, Library.ActiveWindows, Library.Overlays, Library.Whitelist = {}, {}, {}, {}
    Library.Killaura = { Target = nil, Enabled = false, Distance = 10 }
    Library.TeleportCooldownUntil = 0
    Library.TeleportCooldownDuration = 5

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

    local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "ManusGuiLib_V7_2"; ScreenGui.ResetOnSpawn = false; ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if not pcall(function() ScreenGui.Parent = CoreGui end) then ScreenGui.Parent = player:WaitForChild("PlayerGui") end
    local MainFrame = Instance.new("Frame"); MainFrame.Name = "MainFrame"; MainFrame.Size = UDim2.new(1, 0, 1, 0); MainFrame.BackgroundTransparency = 1; MainFrame.Visible = true; MainFrame.Parent = ScreenGui
    
    local categoryObjects = {}
    local function saveCategoryPositions() local d={}; for _,c in ipairs(Library.Categories) do if c and c.Parent then local o=categoryObjects[c.Name]; d[c.Name]={x=c.Position.X.Offset,y=c.Position.Y.Offset,expanded=o and o.Expanded or true} end end; Library:SaveConfig("category_positions", d) end
    local function loadCategoryPositions() return Library:LoadConfig("category_positions") end
    local function makeDraggable(f, h, onDragEnd) local d,i,s,p; h.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then d=true;s=inp.Position;p=f.Position;inp.Changed:Connect(function() if inp.UserInputState==Enum.UserInputState.End then d=false;if onDragEnd then onDragEnd() end end end) end end); h.InputChanged:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseMovement then i=inp end end); UserInputService.InputChanged:Connect(function(inp) if inp==i and d then local a=inp.Position-s;f.Position=UDim2.new(p.X.Scale,p.X.Offset+a.X,p.Y.Scale,p.Y.Offset+a.Y) end end) end

    function Library:CreateWindow(title, size, position)
        if Library.ActiveWindows[title] and Library.ActiveWindows[title].Frame.Parent then Library.ActiveWindows[title].Frame:Destroy() end
        local windowObj={}; local WindowFrame=Instance.new("Frame"); WindowFrame.Name=title; WindowFrame.Size=size or UDim2.new(0,350,0,250); WindowFrame.Position=position or UDim2.new(0.5,-175,0.5,-125); WindowFrame.BackgroundColor3=Color3.fromRGB(30,30,30); WindowFrame.BorderSizePixel=0; WindowFrame.Visible=true; Instance.new("UICorner",WindowFrame).CornerRadius=UDim.new(0,5)
        local TitleBar=Instance.new("TextLabel"); TitleBar.Size=UDim2.new(1,0,0,35); TitleBar.Text="  "..title; TitleBar.TextColor3=Color3.fromRGB(255,255,255); TitleBar.BackgroundColor3=Color3.fromRGB(40,40,40); TitleBar.Font=Enum.Font.SourceSansBold; TitleBar.TextSize=16; TitleBar.TextXAlignment=Enum.TextXAlignment.Left; TitleBar.Parent=WindowFrame
        local CloseButton=Instance.new("TextButton"); CloseButton.Size=UDim2.new(0,35,1,0); CloseButton.Position=UDim2.new(1,-35,0,0); CloseButton.Text="X"; CloseButton.TextColor3=Color3.fromRGB(255,80,80); CloseButton.BackgroundTransparency=1; CloseButton.TextSize=18; CloseButton.Parent=TitleBar; CloseButton.MouseButton1Click:Connect(function() WindowFrame:Destroy() end)
        local ContentFrame=Instance.new("Frame"); ContentFrame.Size=UDim2.new(1,0,1,-35); ContentFrame.Position=UDim2.new(0,0,0,35); ContentFrame.BackgroundTransparency=1; ContentFrame.Parent=WindowFrame; local l=Instance.new("UIListLayout",ContentFrame); l.Padding=UDim.new(0,8); l.HorizontalAlignment=Enum.HorizontalAlignment.Center; Instance.new("UIPadding",ContentFrame).PaddingTop=UDim.new(0,8)
        windowObj.Frame=WindowFrame; windowObj.Content=ContentFrame; makeDraggable(WindowFrame,TitleBar); WindowFrame.Parent=MainFrame
        function windowObj:AddButton(t,c) local b=Instance.new("TextButton"); b.Size=UDim2.new(0.9,0,0,32); b.BackgroundColor3=Color3.fromRGB(50,50,50); b.TextColor3=Color3.fromRGB(220,220,220); b.Text=t; b.TextSize=14; b.Font=Enum.Font.SourceSansBold; b.Parent=ContentFrame; Instance.new("UICorner",b); b.MouseButton1Click:Connect(c); return b end
        Library.ActiveWindows[title] = windowObj; return windowObj
    end

    function Library:CreateCategory(n,p)
        local cF=Instance.new("Frame"); cF.Name=n; cF.Size=UDim2.new(0,150,0,30); cF.Position=p; cF.BackgroundColor3=Color3.fromRGB(30,30,30); cF.BorderSizePixel=0; cF.Parent=MainFrame; local T=Instance.new("TextButton"); T.Size=UDim2.new(1,0,1,0); T.Text=n; T.TextColor3=Color3.fromRGB(255,255,255); T.Font=Enum.Font.SourceSansBold; T.TextSize=16; T.BackgroundTransparency=1; T.Parent=cF; local oF=Instance.new("Frame"); oF.Size=UDim2.new(1,0,0,0); oF.Position=UDim2.new(0,0,1,0); oF.BackgroundColor3=Color3.fromRGB(40,40,40); oF.BorderSizePixel=0; oF.ClipsDescendants=true; oF.Parent=cF; local uL=Instance.new("UIListLayout",oF); uL.SortOrder=Enum.SortOrder.LayoutOrder; local cO={Frame=cF,Options=oF,Expanded=true}; makeDraggable(cF,T,saveCategoryPositions); table.insert(Library.Categories,cF); categoryObjects[n]=cO; local function rOF() local h=0; for _,v in pairs(oF:GetChildren()) do if v:IsA("Frame") then h=h+v.Size.Y.Offset end end; oF.Size=UDim2.new(1,0,0,h) end; T.MouseButton2Click:Connect(function() cO.Expanded=not cO.Expanded; oF.Visible=cO.Expanded; saveCategoryPositions() end);
        function cO:AddModule(mN,cb,iT) local mO={Enabled=false,IsTrigger=iT or false,SubExpanded=false}; local mC=Instance.new("Frame"); mC.Size=UDim2.new(1,0,0,25); mC.BackgroundTransparency=1; mC.Parent=oF; local mB=Instance.new("TextButton"); mB.Size=UDim2.new(1,0,0,25); mB.BackgroundColor3=Color3.fromRGB(45,45,45); mB.BorderSizePixel=0; mB.Text="  "..mN; mB.TextColor3=Color3.fromRGB(200,200,200); mB.Font=Enum.Font.SourceSans; mB.TextSize=14; mB.TextXAlignment=Enum.TextXAlignment.Left; mB.Parent=mC; local sF=Instance.new("ScrollingFrame"); sF.Size=UDim2.new(1,0,0,0); sF.Position=UDim2.new(0,0,0,25); sF.BackgroundColor3=Color3.fromRGB(35,35,35); sF.BorderSizePixel=0; sF.Visible=false; sF.ScrollBarThickness=2; sF.Parent=mC; local sL=Instance.new("UIListLayout",sF); sL.SortOrder=Enum.SortOrder.LayoutOrder; sL.Padding=UDim.new(0,1); local function uS() local cH=sL.AbsoluteContentSize.Y; local vH=sF.Visible and math.min(cH,120) or 0; sF.Size=UDim2.new(1,0,0,vH); sF.CanvasSize=UDim2.new(0,0,0,cH); mC.Size=UDim2.new(1,0,0,25+vH); rOF() end; uS(); sL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(uS); mB.MouseButton1Click:Connect(function() if mO.IsTrigger then cb() else mO.Enabled=not mO.Enabled; mB.TextColor3=mO.Enabled and Color3.fromRGB(0,255,120) or Color3.fromRGB(200,200,200); cb(mO.Enabled) end end); mB.MouseButton2Click:Connect(function() mO.SubExpanded=not mO.SubExpanded; sF.Visible=mO.SubExpanded; uS() end); function mO:AddToggle(t,d,c) local s=d or false; local b=Instance.new("TextButton"); b.Size=UDim2.new(1,0,0,18); b.BackgroundTransparency=1; b.Text="  "..t; b.TextColor3=s and Color3.fromRGB(0,200,100) or Color3.fromRGB(160,160,160); b.Font=Enum.Font.SourceSans; b.TextSize=12; b.TextXAlignment=Enum.TextXAlignment.Left; b.Parent=sF; b.MouseButton1Click:Connect(function() s=not s; b.TextColor3=s and Color3.fromRGB(0,200,100) or Color3.fromRGB(160,160,160); c(s) end) end; function mO:AddSlider(t,min,max,d,c) local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,26); f.BackgroundTransparency=1; f.Parent=sF; local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-4,0,13); l.Position=UDim2.new(0,4,0,1); l.Text=t.." "..tostring(d); l.TextColor3=Color3.fromRGB(180,180,180); l.BackgroundTransparency=1; l.TextSize=11; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=f; local bar=Instance.new("Frame"); bar.Size=UDim2.new(1,-8,0,5); bar.Position=UDim2.new(0,4,0,16); bar.BackgroundColor3=Color3.fromRGB(55,55,55); bar.Parent=f; local fill=Instance.new("Frame"); fill.Size=UDim2.new(math.clamp((d-min)/(max-min),0,1),0,1,0); fill.BackgroundColor3=Color3.fromRGB(0,120,200); fill.Parent=bar; local function u(inp) local p=math.clamp((inp.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1); fill.Size=UDim2.new(p,0,1,0); local v=math.floor(min+(p*(max-min))); l.Text=t.." "..tostring(v); c(v) end; local dr=false; bar.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dr=true; u(inp) end end); UserInputService.InputChanged:Connect(function(inp) if dr and inp.UserInputType==Enum.UserInputType.MouseMovement then u(inp) end end); UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end) end; return mO end;
        return cO
    end

    function Library:CreateOverlay(id,title,color)
        if Library.Overlays[id] then return Library.Overlays[id] end
        local o=Instance.new("Frame"); o.Size=UDim2.new(0,220,0,80); o.BackgroundColor3=Color3.fromRGB(20,20,25); o.BackgroundTransparency=0.2; o.BorderSizePixel=0; o.Visible=false; o.Parent=ScreenGui; Instance.new("UICorner",o).CornerRadius=UDim.new(0,8)
        local b=Instance.new("Frame"); b.Size=UDim2.new(1,0,0,2); b.BackgroundColor3=color or Color3.fromRGB(0,150,255); b.BorderSizePixel=0; b.Parent=o; Instance.new("UICorner",b)
        local t=Instance.new("TextLabel"); t.Size=UDim2.new(1,-10,0,20); t.Position=UDim2.new(0,10,0,5); t.Text=title; t.TextColor3=color or Color3.fromRGB(0,150,255); t.Font=Enum.Font.SourceSansBold; t.TextSize=12; t.BackgroundTransparency=1; t.TextXAlignment=Enum.TextXAlignment.Left; t.Parent=o
        local a=Instance.new("ImageLabel"); a.Size=UDim2.new(0,40,0,40); a.Position=UDim2.new(0,10,0,30); a.BackgroundColor3=Color3.fromRGB(40,40,45); a.Parent=o; Instance.new("UICorner",a).CornerRadius=UDim.new(1,0)
        local n=Instance.new("TextLabel"); n.Size=UDim2.new(1,-60,0,15); n.Position=UDim2.new(0,60,0,30); n.Text="Nenhum"; n.TextColor3=Color3.fromRGB(255,255,255); n.Font=Enum.Font.SourceSansBold; n.TextSize=14; n.TextXAlignment=Enum.TextXAlignment.Left; n.BackgroundTransparency=1; n.Parent=o
        local il=Instance.new("TextLabel"); il.Size=UDim2.new(1,-60,0,15); il.Position=UDim2.new(0,60,0,45); il.TextColor3=Color3.fromRGB(180,180,180); il.Font=Enum.Font.SourceSans; il.TextSize=12; il.TextXAlignment=Enum.TextXAlignment.Left; il.BackgroundTransparency=1; il.Parent=o
        local d=Instance.new("TextLabel"); d.Size=UDim2.new(1,-60,0,15); d.Position=UDim2.new(0,60,0,60); d.TextColor3=color or Color3.fromRGB(0,150,255); d.Font=Enum.Font.SourceSansBold; d.TextSize=12; d.TextXAlignment=Enum.TextXAlignment.Left; d.BackgroundTransparency=1; d.Parent=o
        local obj={Frame=o}
        function obj:Update(p,dist,info) if not p then o.Visible=false; return end; o.Visible=true; n.Text=p.DisplayName; il.Text=info or ("@"..p.Name); d.Text=dist and (string.format("%.1f",dist).."m") or ""; task.spawn(function() a.Image=Players:GetUserThumbnailAsync(p.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end) end
        function obj:SetVisible(s) o.Visible=s end
        function obj:SetPosition(p) o.Position=p end
        Library.Overlays[id]=obj; return obj
    end

    Library:AddKeybind("Abrir/Fechar Menu", Library.OpenKey, function(k,p) if p then MainFrame.Visible=not MainFrame.Visible end end)
    Library.ScreenGui=ScreenGui
    return Library
]];

local success, Library = pcall(loadstring(gui_code))
if not success or not Library then
    warn("❌ ERRO FATAL: A GUI embutida falhou ao carregar. Erro: " .. tostring(Library))
    return
end
Library = Library()
print("✅ Biblioteca GUI embutida carregada e executada.")

--[[
    Etapa 2: Carregar Módulos da Internet
]]

local BASE_URL = "https://raw.githubusercontent.com/RobloxScriptPrivate/aimbot/main/"
local function fetch(file)
    local cache_buster = "?v=" .. os.time() .. "&r=" .. math.random(1, 1000000)
    local url = BASE_URL .. file .. cache_buster
    local success, content = pcall(game.HttpGet, game, url, true)
    if success and content and #content > 0 then return content else return nil end
end

-- CRIAÇÃO DAS CATEGORIAS
print("\n--- Etapa 2: Criando Categorias ---")
local Combat   = Library:CreateCategory("⚔️ Combat",    UDim2.new(0, 10, 0, 120))
local Visual   = Library:CreateCategory("👁️ Visual",    UDim2.new(0, 170, 0, 120))
local Movement = Library:CreateCategory("🏃 Movimento", UDim2.new(0, 330, 0, 120))
local Teleport = Library:CreateCategory("🌌 Teleporte", UDim2.new(0, 490, 0, 120))
local Misc     = Library:CreateCategory("✨ Misc",      UDim2.new(0, 650, 0, 120))
print("✅ Todas as categorias criadas.")


-- CARREGAMENTO DOS MÓDULOS
print("\n--- Etapa 3: Carregando Módulos ---")
local function LoadModule(filename, category)
    local code = fetch(filename)
    if code then
        local func = loadstring(code)
        if func then pcall(func, Library, category) end
    end
end

LoadModule("aimbot.lua",   Combat)
LoadModule("hitbox.lua",   Combat)
LoadModule("esp.lua",      Visual)
LoadModule("nametag.lua",  Visual)
LoadModule("movement.lua", Movement)
LoadModule("teleport.lua", Teleport)

-- MÓDULOS MISC
getgenv().AutoCollectMoney = false
Misc:AddModule("🎯 Killaura", function(enabled) Library.Killaura.Enabled = enabled end):AddSlider("Distância: ", 5, 50, Library.Killaura.Distance, function(val) Library.Killaura.Distance = val end)
Misc:AddModule("💵 Auto Coletar Dinheiro", function(enabled) getgenv().AutoCollectMoney = enabled end)

-- (Lógica de Killaura e Auto-Collect em background)
coroutine.wrap(function() while true do task.wait(1); if getgenv().AutoCollectMoney then local p=game:GetService("Players").LocalPlayer; local c=p and p.Character; local r=c and c:FindFirstChild("HumanoidRootPart"); if not r then continue end; for _,t in ipairs(workspace.Tycoons:GetChildren()) do local es=t:FindFirstChild("Essentials"); if es then for i=1,2 do local co=es:FindFirstChild("CollectorP"..i); local tp=co and co:FindFirstChild("Touch"); if tp and tp:IsA("BasePart") then pcall(function() local o=tp.CFrame; tp.CFrame=r.CFrame; game:GetService("RunService").Heartbeat:Wait(); tp.CFrame=o end) end end end end end end end)()

print("\n\n🎉🎉 CARREGAMENTO FINALIZADO. Tudo deve funcionar agora. 🎉🎉")
