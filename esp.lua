-- ========== ESP V9 (Optimized Skeletons) ==========
local Library, Visual = ..., select(2, ...)

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local Camera      = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Mapeamento estático e eficiente das partes do esqueleto
-- É muito mais rápido do que procurar por "Motor6D" em cada atualização.
local SKELETON_MAP = {
    -- Conexão, [Parte1, Parte2]
    {"Head", "Torso"},
    {"Torso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"Torso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"Torso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"Torso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}

local Config = {
    Enabled     = false,
    Skeleton    = true,
    Outline     = false,
    Preenchido  = false,
    Tracers     = false,
    TeamCheck   = true,
    MaxDistance = 300,
    ShowDead    = true,
}

local saved = Library:LoadConfig("esp")
if saved then
    for key, value in pairs(saved) do
        if type(Config[key]) == type(value) then
            Config[key] = value
        end
    end
end

local function Save()
    Library:SaveConfig("esp", Config)
end

-- ──────────────────────────────────────────────
-- CORES
-- ──────────────────────────────────────────────
local function GetColor(player, isAlive)
    if not isAlive then return Color3.fromRGB(150, 150, 150) end -- Cinza para mortos
    if Config.TeamCheck then
        -- Verifica se o time do jogador é um time válido (não o time padrão "cinza")
        if player.TeamColor ~= nil and player.TeamColor.Color ~= Color3.fromRGB(204, 204, 204) then
            return player.TeamColor.Color
        end
        -- Verifica se o jogador está no mesmo objeto de Time que o LocalPlayer
        if LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team then
            return Color3.fromRGB(0, 120, 255) -- Amigo
        end
    end
    return Color3.fromRGB(255, 50, 50) -- Inimigo padrão
end

-- ──────────────────────────────────────────────
-- VALIDAÇÃO (REWORKED)
-- ──────────────────────────────────────────────
local function IsValidTarget(player)
    if not player or player == LocalPlayer then return false, false end
    if Library:IsWhitelisted(player) then return false, false end
    local char = player.Character
    if not char then return false, false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false, false end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false, false end

    local isAlive = hum.Health > 0
    
    local localChar = LocalPlayer.Character
    if localChar then
        local localRoot = localChar:FindFirstChild("HumanoidRootPart")
        if localRoot then
            if (rootPart.Position - localRoot.Position).Magnitude > Config.MaxDistance then
                return false, isAlive -- Fora de distância
            end
        end
    end
    
    return true, isAlive
end

-- ==================== TABELAS DE ELEMENTOS ESP ====================
local skeletons = {}
local highlights_outline = {}
local highlights_filled = {}
local nametags_filled = {}
local tracers = {}
local dead_markers = {}

-- ==================== FUNÇÕES DE LIMPEZA GERAIS ====================
local function CleanupPlayer(p)
    if skeletons[p] then skeletons[p]:Remove(); skeletons[p] = nil end
    if highlights_outline[p] then pcall(function() highlights_outline[p]:Destroy() end); highlights_outline[p]=nil end
    if highlights_filled[p] then pcall(function() highlights_filled[p]:Destroy() end); highlights_filled[p]=nil end
    if nametags_filled[p] then pcall(function() nametags_filled[p]:Destroy() end); nametags_filled[p]=nil end
    if tracers[p] then tracers[p]:Remove(); tracers[p]=nil end
    if dead_markers[p] then pcall(function() dead_markers[p]:Destroy() end); dead_markers[p]=nil end
end

local function CleanupAll()
    for p in pairs(skeletons) do CleanupPlayer(p) end
    for p in pairs(highlights_outline) do CleanupPlayer(p) end
    for p in pairs(highlights_filled) do CleanupPlayer(p) end
    for p in pairs(tracers) do CleanupPlayer(p) end
    for p in pairs(dead_markers) do CleanupPlayer(p) end
end

local function HideAllESP(player)
    if skeletons[player] then skeletons[player]:SetVisible(false) end
    if highlights_outline[player] then highlights_outline[player].Enabled = false end
    if highlights_filled[player] then highlights_filled[player].Enabled = false end
    if nametags_filled[player] then nametags_filled[player].Enabled = false end
    if tracers[player] then tracers[player].Visible = false end
    if dead_markers[player] then dead_markers[player].Enabled = false end
end

-- ==================== ESQUELETO (OTIMIZADO) ====================
local Skeleton = {}
Skeleton.__index = Skeleton

function Skeleton.new(color)
    local self = setmetatable({}, Skeleton)
    self.Lines = {}
    for i = 1, #SKELETON_MAP do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = 1.5
        line.Color = color
        self.Lines[i] = line
    end
    return self
end

function Skeleton:Update(character, color)
    if not character then self:SetVisible(false); return end
    self:SetColor(color)
    
    local parts = {}
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            parts[part.Name] = part
        end
    end

    for i, connection in ipairs(SKELETON_MAP) do
        local line = self.Lines[i]
        local p1 = parts[connection[1]]
        local p2 = parts[connection[2]]

        if p1 and p2 then
            local pos1, vis1 = Camera:WorldToViewportPoint(p1.Position)
            local pos2, vis2 = Camera:WorldToViewportPoint(p2.Position)

            if vis1 and vis2 then
                line.From = Vector2.new(pos1.X, pos1.Y)
                line.To = Vector2.new(pos2.X, pos2.Y)
                line.Visible = true
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
end

function Skeleton:SetVisible(state)
    for _, line in ipairs(self.Lines) do
        line.Visible = state
    end
end

function Skeleton:SetColor(color)
    for _, line in ipairs(self.Lines) do
        line.Color = color
    end
end

function Skeleton:Remove()
    for _, line in ipairs(self.Lines) do
        line:Remove()
    end
    self.Lines = nil
end

-- ==================== HIGHLIGHT / TRACER (Funções auxiliares) ====================
local function createHighlight(p, t) local h=Instance.new("Highlight"); h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.Parent=t; h.Adornee=p.Character; return h end
local function getOrCreateTracer(p) if not tracers[p] then tracers[p]=Drawing.new("Line"); tracers[p].Visible=false; tracers[p].Thickness=1.5 end; return tracers[p] end

-- ──────────────────────────────────────────────
-- LOOP PRINCIPAL (Com RenderStepped para fluidez)
-- ──────────────────────────────────────────────
local function UpdateESP()
    -- Limpa jogadores que saíram (otimizado)
    for p, _ in pairs(skeletons) do if not p or not p.Parent then CleanupPlayer(p) end end
    for p, _ in pairs(highlights_outline) do if not p or not p.Parent then CleanupPlayer(p) end end
    -- Adicione mais loops de limpeza se necessário para outras tabelas, mas o CleanupPlayer deve bastar.

    for _, player in ipairs(Players:GetPlayers()) do
        local isValid, isAlive = IsValidTarget(player)
        local char = player.Character

        if not isValid then
            HideAllESP(player) -- Esconde tudo se não for um alvo válido
            continue
        end
        
        local color = GetColor(player, isAlive)

        if isAlive then
            if dead_markers[player] then pcall(function() dead_markers[player]:Destroy() end); dead_markers[player] = nil end
            
            if Config.Skeleton then
                local sk = skeletons[player]
                if not sk then sk = Skeleton.new(color); skeletons[player] = sk; end
                sk:Update(char, color)
            else
                if skeletons[player] then skeletons[player]:SetVisible(false) end
            end

            if Config.Outline then
                local h = highlights_outline[player]; if not h or not h.Parent then h = createHighlight(player, char); highlights_outline[player] = h; end
                h.OutlineColor = color; h.FillTransparency = 1; h.OutlineTransparency = 0; h.Enabled = true
            elseif highlights_outline[player] then highlights_outline[player].Enabled = false end

            if Config.Preenchido then
                local h = highlights_filled[player]; if not h or not h.Parent then h = createHighlight(player, char); highlights_filled[player] = h; end
                h.FillColor = color; h.OutlineColor = color; h.FillTransparency = 0.5; h.OutlineTransparency = 0.2; h.Enabled = true
                
                local nT = nametags_filled[player]; if not nT or not nT.Parent then nT = Instance.new("BillboardGui", char); nT.Adornee = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"); nT.Size = UDim2.new(0,200,0,50); nT.StudsOffset = Vector3.new(0,3,0); nT.AlwaysOnTop=true; local tL=Instance.new("TextLabel",nT); tL.Size=UDim2.new(1,0,1,0); tL.BackgroundTransparency=1; tL.TextStrokeTransparency=0;tL.TextSize=14; tL.Font=Enum.Font.SourceSansBold; nametags_filled[player]=nT; end; local tL=nT:FindFirstChildOfClass("TextLabel"); if tL then tL.Text=player.Name; tL.TextColor3=color; end; nT.Enabled=true
            elseif highlights_filled[player] then highlights_filled[player].Enabled=false; if nametags_filled[player] then nametags_filled[player].Enabled=false; end end

            if Config.Tracers then
                local r=char and char:FindFirstChild("HumanoidRootPart"); local t=getOrCreateTracer(player); t.Color=color; if r then local sp,os=Camera:WorldToViewportPoint(r.Position); if os and sp.Z>0 then local vp=Camera.ViewportSize;t.From=Vector2.new(vp.X/2,vp.Y);t.To=Vector2.new(sp.X,sp.Y);t.Visible=true else t.Visible=false end else t.Visible=false end
            elseif tracers[player] then tracers[player].Visible=false end
        
        else -- Jogador está morto
            HideAllESP(player) -- Esconde ESP de vivo

            if Config.ShowDead then
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    local marker = dead_markers[player]
                    if not marker or not marker.Parent then
                        marker = Instance.new("BillboardGui", char); marker.Adornee = root; marker.Size = UDim2.new(0, 150, 0, 50); marker.StudsOffset = Vector3.new(0, 2, 0); marker.AlwaysOnTop = true; marker.Name = "DeadMarkerFor"..player.Name
                        local textLabel = Instance.new("TextLabel", marker); textLabel.Size = UDim2.new(1,0,1,0); textLabel.BackgroundTransparency=1; textLabel.Text = "💀 " .. player.Name; textLabel.TextColor3 = color; textLabel.TextStrokeTransparency=0.5; textLabel.TextSize=14; textLabel.Font=Enum.Font.SourceSansBold;
                        dead_markers[player] = marker
                    end
                    marker.Enabled = true
                end
            end
        end
    end
end

-- ──────────────────────────────────────────────
-- TOGGLE
-- ──────────────────────────────────────────────
local connection
local function ToggleLoop(state)
    if state and not connection then
        connection = RunService.RenderStepped:Connect(UpdateESP)
    elseif not state and connection then
        connection:Disconnect(); connection = nil
        CleanupAll() -- Limpa todos os elementos visuais
    end
end

-- ──────────────────────────────────────────────
-- UI
-- ──────────────────────────────────────────────
local ESP_Module = Visual:AddModule("👁️ ESP", function(state) Config.Enabled = state; ToggleLoop(state) end, false)
ESP_Module:AddToggle("💀 Skeleton (Graveto)", Config.Skeleton, function(state) Config.Skeleton = state; if not state then for p, sk in pairs(skeletons) do sk:Remove(); skeletons[p] = nil end end; Save() end)
ESP_Module:AddToggle("🔲 Outline (Contorno)", Config.Outline, function(state) Config.Outline = state; if not state then for p in pairs(highlights_outline) do CleanupPlayer(p) end end; Save() end)
ESP_Module:AddToggle("🎨 Preenchido (Cheio)", Config.Preenchido, function(state) Config.Preenchido = state; if not state then for p in pairs(highlights_filled) do CleanupPlayer(p) end end; Save() end)
ESP_Module:AddToggle("📈 Tracers (Linhas)", Config.Tracers, function(state) Config.Tracers = state; if not state then for p in pairs(tracers) do CleanupPlayer(p) end end; Save() end)
ESP_Module:AddToggle("👥 Checar Time (Cores)", Config.TeamCheck, function(state) Config.TeamCheck = state; Save() end)
ESP_Module:AddToggle("👻 Mostrar Mortos", Config.ShowDead, function(state) Config.ShowDead = state; if not state then for p in pairs(dead_markers) do CleanupPlayer(p) end end; Save() end)
ESP_Module:AddSlider("📏 Distância Máxima", 10, 1000, Config.MaxDistance, true, function(value) Config.MaxDistance = value; Save() end)

print("✅ ESP V9 (Optimized Skeletons) carregado!")

-- Função de limpeza a ser retornada para o loader
return function()
    if connection then connection:Disconnect(); connection = nil end
    CleanupAll()
end
