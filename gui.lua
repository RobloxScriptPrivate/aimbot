-- Manus GUI Library V7.1 (Overlay Fix)
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

-- (Funções de Whitelist e Teleporte permanecem as mesmas)

--[[
    2. INICIALIZAÇÃO DA GUI
]]
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "ManusGuiLib_V7_1"; ScreenGui.ResetOnSpawn = false; ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if not pcall(function() ScreenGui.Parent = CoreGui end) then ScreenGui.Parent = player:WaitForChild("PlayerGui") end
local MainFrame = Instance.new("Frame"); MainFrame.Name = "MainFrame"; MainFrame.Size = UDim2.new(1, 0, 1, 0); MainFrame.BackgroundTransparency = 1; MainFrame.Visible = true; MainFrame.Parent = ScreenGui

-- (Código da TopBar, SearchBox, etc., permanece o mesmo)

--[[
    3. FUNÇÕES UTILITÁRIAS DE ARRASTAR
]]
local function makeDraggable(f, h, onDragEnd) local d,i,s,p; h.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then d=true;s=inp.Position;p=f.Position;inp.Changed:Connect(function() if inp.UserInputState==Enum.UserInputState.End then d=false;if onDragEnd then onDragEnd() end end end) end end); h.InputChanged:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseMovement then i=inp end end); UserInputService.InputChanged:Connect(function(inp) if inp==i and d then local a=inp.Position-s;f.Position=UDim2.new(p.X.Scale,p.X.Offset+a.X,p.Y.Scale,p.Y.Offset+a.Y) end end) end

--[[
    4. JANELAS CUSTOMIZADAS (Log Window, etc.)
]]
function Library:CreateLogWindow(title, logContent)
    -- (O código da janela de log permanece o mesmo)
end

--[[
    5. API DE JANELAS E CATEGORIAS
]]
-- (Funções de criação de Janelas, Categorias e Módulos permanecem as mesmas)

--[[
    6. CONFIGURAÇÕES
]]
-- (O código do botão de Configurações permanece o mesmo)

--[[
    7. OVERLAY (CORRIGIDO)
]]
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
    function obj:Update(p,dist,info)
        if not p then o.Visible=false; return end
        o.Visible=true
        n.Text=p.DisplayName
        il.Text=info or ("@"..p.Name)
        d.Text=dist and (string.format("%.1f",dist).."m") or ""
        task.spawn(function() a.Image=Players:GetUserThumbnailAsync(p.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end)
    end
    function obj:SetVisible(s) o.Visible=s end
    function obj:SetPosition(p) o.Position=p end
    Library.Overlays[id]=obj
    return obj
end


Library:AddKeybind("Abrir/Fechar Menu", Library.OpenKey, function(k,p) if p then MainFrame.Visible=not MainFrame.Visible end end)
Library.ScreenGui=ScreenGui
return Library
