-- ========== LOADER (v24 - Restauração Final) ==========
print("✔ Iniciando v24. Revertido para a base estável pré-caos. GUI embutida.")

--[[
    Etapa 1: Definição da Biblioteca GUI (Embutida e Estável)
    Isto cria a biblioteca de forma segura, sem loadstring em arquivos externos.
]]

local function CreateManusGUILibrary()
    print("--- Construindo biblioteca GUI...")
    
    local Library = {}
    local RunService, UserInputService, Players, CoreGui, HttpService = game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("Players"), game:GetService("CoreGui"), game:GetService("HttpService")
    local player = Players.LocalPlayer

    Library.OpenKey, Library.RemoveKey = Enum.KeyCode.Insert, Enum.KeyCode.K
    Library.Categories, Library.ActiveWindows, Library.Overlays, Library.Whitelist = {}, {}, {}, {}

    local CONFIG_FOLDER = "Universal Project"
    pcall(function() if makefolder and not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end end)

    function Library:SaveConfig(name, data) pcall(function() if writefile then writefile(CONFIG_FOLDER .. "/" .. name .. ".json", HttpService:JSONEncode(data)) end end) end
    function Library:LoadConfig(name) local p=CONFIG_FOLDER .. "/" .. name .. ".json"; if readfile and isfile and isfile(p) then local s, d = pcall(HttpService.JSONDecode, HttpService, readfile(p)); if s and type(d)=="table" then return d end end; return nil end

    local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "ManusGuiLib_V24_Final"; ScreenGui.ResetOnSpawn=false; ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    pcall(function() ScreenGui.Parent = CoreGui end) or pcall(function() ScreenGui.Parent = player:WaitForChild("PlayerGui") end)
    local MainFrame = Instance.new("Frame"); MainFrame.Size=UDim2.new(1,0,1,0); MainFrame.BackgroundTransparency=1; MainFrame.Parent=ScreenGui
    
    local categoryObjects={}
    local function savePositions() local d={}; for n,c in pairs(categoryObjects) do d[n]={x=c.Frame.Position.X.Offset,y=c.Frame.Position.Y.Offset,e=c.Expanded} end; Library:SaveConfig("positions", d) end
    local function makeDraggable(f, h) local d,i,s,p; h.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then d=true;s=inp.Position;p=f.Position;local c; c=inp.Changed:Connect(function(st) if st==Enum.UserInputState.End then d=false;savePositions();c:Disconnect() end end) end end); UserInputService.InputChanged:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseMovement and d then local a=inp.Position-s;f.Position=UDim2.new(p.X.Scale,p.X.Offset+a.X,p.Y.Scale,p.Y.Offset+a.Y) end end) end
    
    function Library:CreateCategory(n,p) local cF=Instance.new("Frame"); cF.Name=n; cF.Size=UDim2.new(0,150,0,30); cF.Position=p; cF.BackgroundColor3=Color3.fromRGB(30,30,30); cF.BorderSizePixel=0; cF.Parent=MainFrame; local T=Instance.new("TextButton"); T.Size=UDim2.new(1,0,1,0); T.Text=n; T.TextColor3=Color3.fromRGB(255,255,255); T.Font=Enum.Font.SourceSansBold; T.TextSize=16; T.BackgroundTransparency=1; T.Parent=cF; local oF=Instance.new("Frame"); oF.Size=UDim2.new(1,0,0,0); oF.Position=UDim2.new(0,0,1,0); oF.BackgroundColor3=Color3.fromRGB(40,40,40); oF.BorderSizePixel=0; oF.ClipsDescendants=true; oF.Parent=cF; local uL=Instance.new("UIListLayout",oF); uL.SortOrder=Enum.SortOrder.LayoutOrder; local cO={Frame=cF,Options=oF,Expanded=true}; makeDraggable(cF,T); table.insert(Library.Categories,cF); categoryObjects[n]=cO; local function rOF() local h=0; for _,v in ipairs(oF:GetChildren()) do if v:IsA("GuiObject") then h=h+v.AbsoluteSize.Y end end; oF.Size=UDim2.new(1,0,0,h) end; T.MouseButton2Click:Connect(function() cO.Expanded=not cO.Expanded; oF.Visible=cO.Expanded; savePositions() end); function cO:AddModule(mN,cb,iT) local mO={Enabled=false,IsTrigger=iT or false,SubExpanded=false}; local mC=Instance.new("Frame"); mC.Size=UDim2.new(1,0,0,25); mC.BackgroundTransparency=1; mC.Parent=oF; local mB=Instance.new("TextButton"); mB.Size=UDim2.new(1,0,0,25); mB.BackgroundColor3=Color3.fromRGB(45,45,45); mB.BorderSizePixel=0; mB.Text="  "..mN; mB.TextColor3=Color3.fromRGB(200,200,200); mB.Font=Enum.Font.SourceSans; mB.TextSize=14; mB.TextXAlignment=Enum.TextXAlignment.Left; mB.Parent=mC; local sF=Instance.new("ScrollingFrame"); sF.Size=UDim2.new(1,0,0,0); sF.Position=UDim2.new(0,0,1,0); sF.BackgroundColor3=Color3.fromRGB(35,35,35); sF.BorderSizePixel=0; sF.Visible=false; sF.ScrollBarThickness=2; sF.Parent=mC; local sL=Instance.new("UIListLayout",sF); sL.SortOrder=Enum.SortOrder.LayoutOrder; sL.Padding=UDim.new(0,1); local function uS() local cH=sL.AbsoluteContentSize.Y; local vH=sF.Visible and math.min(cH,120) or 0; sF.Size=UDim2.new(1,0,0,vH); sF.CanvasSize=UDim2.new(0,0,0,cH); mC.Size=UDim2.new(1,0,0,25+vH); rOF() end; uS(); sL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(uS); mB.MouseButton1Click:Connect(function() if mO.IsTrigger then if cb then cb() end else mO.Enabled=not mO.Enabled; mB.TextColor3=mO.Enabled and Color3.fromRGB(0,255,120) or Color3.fromRGB(200,200,200); if cb then cb(mO.Enabled) end end end); mB.MouseButton2Click:Connect(function() mO.SubExpanded=not mO.SubExpanded; sF.Visible=mO.SubExpanded; uS() end); function mO:AddSlider(t,min,max,d,c) local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,26); f.BackgroundTransparency=1; f.Parent=sF; local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-4,0,13); l.Position=UDim2.new(0,4,0,1); l.Text=t.." "..tostring(d); l.TextColor3=Color3.fromRGB(180,180,180); l.BackgroundTransparency=1; l.TextSize=11; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=f; local bar=Instance.new("Frame"); bar.Size=UDim2.new(1,-8,0,5); bar.Position=UDim2.new(0,4,0,16); bar.BackgroundColor3=Color3.fromRGB(55,55,55); bar.Parent=f; local fill=Instance.new("Frame"); fill.Size=UDim2.new(math.clamp((d-min)/(max-min),0,1),0,1,0); fill.BackgroundColor3=Color3.fromRGB(0,120,200); fill.Parent=bar; local function u(inp) local p=math.clamp((inp.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1); fill.Size=UDim2.new(p,0,1,0); local v=math.floor(min+(p*(max-min))); l.Text=t.." "..tostring(v); c(v) end; local dr=false; bar.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dr=true; u(inp) end end); UserInputService.InputChanged:Connect(function(inp) if dr and inp.UserInputType==Enum.UserInputType.MouseMovement then u(inp) end end); UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end) end; return mO end; rOF(); return cO end

    function Library:CreateOverlay(id,title,color) if Library.Overlays[id] then return Library.Overlays[id] end; local o=Instance.new("Frame"); o.Size=UDim2.new(0,220,0,80); o.BackgroundColor3=Color3.fromRGB(20,20,25); o.BackgroundTransparency=0.2; o.BorderSizePixel=0; o.Visible=false; o.Parent=ScreenGui; Instance.new("UICorner",o).CornerRadius=UDim.new(0,8); local b=Instance.new("Frame"); b.Size=UDim2.new(1,0,0,2); b.BackgroundColor3=color or Color3.fromRGB(0,150,255); b.BorderSizePixel=0; b.Parent=o; Instance.new("UICorner",b); local t=Instance.new("TextLabel"); t.Size=UDim2.new(1,-10,0,20); t.Position=UDim2.new(0,10,0,5); t.Text=title; t.TextColor3=color or Color3.fromRGB(0,150,255); t.Font=Enum.Font.SourceSansBold; t.TextSize=12; t.BackgroundTransparency=1; t.TextXAlignment=Enum.TextXAlignment.Left; t.Parent=o; local a=Instance.new("ImageLabel"); a.Size=UDim2.new(0,40,0,40); a.Position=UDim2.new(0,10,0,30); a.BackgroundColor3=Color3.fromRGB(40,40,45); a.Parent=o; Instance.new("UICorner",a).CornerRadius=UDim.new(1,0); local n=Instance.new("TextLabel"); n.Size=UDim2.new(1,-60,0,15); n.Position=UDim2.new(0,60,0,30); n.Text="Nenhum"; n.TextColor3=Color3.fromRGB(255,255,255); n.Font=Enum.Font.SourceSansBold; n.TextSize=14; n.TextXAlignment=Enum.TextXAlignment.Left; n.BackgroundTransparency=1; n.Parent=o; local il=Instance.new("TextLabel"); il.Size=UDim2.new(1,-60,0,15); il.Position=UDim2.new(0,60,0,45); il.TextColor3=Color3.fromRGB(180,180,180); il.Font=Enum.Font.SourceSans; il.TextSize=12; il.TextXAlignment=Enum.TextXAlignment.Left; il.BackgroundTransparency=1; il.Parent=o; local d=Instance.new("TextLabel"); d.Size=UDim2.new(1,-60,0,15); d.Position=UDim2.new(0,60,0,60); d.TextColor3=color or Color3.fromRGB(0,150,255); d.Font=Enum.Font.SourceSansBold; d.TextSize=12; d.TextXAlignment=Enum.TextXAlignment.Left; d.Parent=o; local obj={Frame=o}; function obj:Update(p,dist,info) if not p then o.Visible=false; return end; o.Visible=true; n.Text=p.DisplayName; il.Text=info or ("@"..p.Name); d.Text=dist and (string.format("%.1f",dist).."m") or ""; task.spawn(function() a.Image=Players:GetUserThumbnailAsync(p.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end) end; function obj:SetVisible(s) o.Visible=s end; function obj:SetPosition(p) o.Position=p end; Library.Overlays[id]=obj; return obj end

    local keybinds={}; function Library:AddKeybind(key, cb) if not keybinds[key] then keybinds[key]={} end table.insert(keybinds[key],cb) end
    UserInputService.InputBegan:Connect(function(i,p) if p then return end; if keybinds[i.KeyCode] then for _,cb in ipairs(keybinds[i.KeyCode]) do pcall(cb) end end end)
    
    Library:AddKeybind(Library.OpenKey, function() MainFrame.Visible = not MainFrame.Visible end)
    Library:AddKeybind(Library.RemoveKey, function() savePositions(); ScreenGui:Destroy() end)

    local d=Library:LoadConfig("positions"); if d then task.wait(); for n,c in pairs(categoryObjects) do local s=d[n]; if s then c.Frame.Position=UDim2.new(0,s.x,0,s.y); c.Expanded=s.e; c.Options.Visible=s.e end end end

    Library.ScreenGui=ScreenGui
    print("✅ Biblioteca GUI construída.")
    return Library
end

--[[
    Etapa 2: Execução do Loader Principal
]]

local Library = CreateManusGUILibrary()
if not (Library and type(Library) == "table") then warn("❌ ERRO GRAVE: A construção da GUI falhou."); return end

local BASE_URL = "https://raw.githubusercontent.com/RobloxScriptPrivate/aimbot/main/"
local function fetch(file)
    local s, c = pcall(game.HttpGet, game, BASE_URL .. file .. "?v=" .. os.time(), true)
    if s and c and #c > 0 then return c else warn("⚠️ Falha no download de: "..file); return nil end
end

print("--- Criando Categorias...")
local Combat   = Library:CreateCategory("⚔️ Combat",    UDim2.new(0, 10, 0, 120))
local Visual   = Library:CreateCategory("👁️ Visual",    UDim2.new(0, 170, 0, 120))
local Movement = Library:CreateCategory("🏃 Movimento", UDim2.new(0, 330, 0, 120))
local Teleport = Library:CreateCategory("🌌 Teleporte", UDim2.new(0, 490, 0, 120))
local Misc     = Library:CreateCategory("✨ Misc",      UDim2.new(0, 650, 0, 120))
print("✅ Categorias criadas.")

print("--- Carregando Módulos da Web...")
local function LoadModule(filename, category)
    local code = fetch(filename)
    if code then 
        local s,e = pcall(loadstring(code), Library, category)
        if not s then warn("🔥 Erro ao carregar '"..filename.."':", e) end
    end
end

LoadModule("aimbot.lua",   Combat)
LoadModule("hitbox.lua",   Combat)
LoadModule("esp.lua",      Visual)
LoadModule("nametag.lua",  Visual)
LoadModule("movement.lua", Movement)
LoadModule("teleport.lua", Teleport)

print("✅ Carregamento de módulos concluído.")

print("\n\n🎉🎉 RESTAURAÇÃO FINALIZADA (v24). O script está de volta ao estado estável. 🎉🎉")
