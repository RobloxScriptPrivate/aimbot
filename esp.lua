-- ========== ESP V5 (Skeleton + Outline, deteccao corrigida) ==========
local Library, Visual = ..., select(2, ...)

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local Camera      = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ──────────────────────────────────────────────
-- CONFIGURAÇÕES
-- ──────────────────────────────────────────────
local Config = {
    Enabled   = false,
    Skeleton  = true,
    Outline   = false,
    Tracers   = false,
    TeamCheck = false,  -- desativado por padrão: mostra TODOS os inimigos
}

-- ──────────────────────────────────────────────
-- PARES DE OSSOS (Skeleton)
-- ──────────────────────────────────────────────
local BONE_PAIRS = {
    {"Head",          "UpperTorso"},
    {"UpperTorso",    "LowerTorso"},
    {"UpperTorso",    "LeftUpperArm"},
    {"LeftUpperArm",  "LeftLowerArm"},
    {"LeftLowerArm",  "LeftHand"},
    {"UpperTorso",    "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso",    "LeftUpperLeg"},
    {"LeftUpperLeg",  "LeftLowerLeg"},
    {"LeftLowerLeg",  "LeftFoot"},
    {"LowerTorso",    "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
}

-- PARTES para Outline
local OUTLINE_PARTS = {
    "Head","UpperTorso","LowerTorso",
    "LeftUpperArm","LeftLowerArm","LeftHand",
    "RightUpperArm","RightLowerArm","RightHand",
    "LeftUpperLeg","LeftLowerLeg","LeftFoot",
    "RightUpperLeg","RightLowerLeg","RightFoot",
}

-- ──────────────────────────────────────────────
-- POOL DE DRAWINGS
-- drawings[player] = { bones={Line...}, outlines={Square...}, tracer=Line }
-- ──────────────────────────────────────────────
local drawings = {}

local function newLine()
    local d = Drawing.new("Line")
    d.Visible = false; d.Thickness = 1.5
    d.Color = Color3.fromRGB(255,255,255)
    return d
end
local function newSquare()
    local d = Drawing.new("Square")
    d.Visible = false; d.Filled = false; d.Thickness = 1.5
    d.Color = Color3.fromRGB(255,255,255)
    return d
end

local function allocPlayer(player)
    if drawings[player] then return drawings[player] end
    local d = { bones={}, outlines={}, tracer=newLine() }
    for i=1,#BONE_PAIRS    do d.bones[i]    = newLine()   end
    for i=1,#OUTLINE_PARTS do d.outlines[i] = newSquare() end
    drawings[player] = d
    return d
end

local function hidePlayer(player)
    local d = drawings[player]; if not d then return end
    for _,l in ipairs(d.bones)    do l.Visible = false end
    for _,s in ipairs(d.outlines) do s.Visible = false end
    d.tracer.Visible = false
end

local function removePlayer(player)
    local d = drawings[player]; if not d then return end
    for _,l in ipairs(d.bones)    do l:Remove() end
    for _,s in ipairs(d.outlines) do s:Remove() end
    d.tracer:Remove()
    drawings[player] = nil
end

local function removeAll()
    for p in pairs(drawings) do removePlayer(p) end
end

-- ──────────────────────────────────────────────
-- HELPERS
-- ──────────────────────────────────────────────

-- Cor: azul aliado / vermelho inimigo / amarelo sem time
local function GetColor(player)
    if not Config.TeamCheck then
        return Color3.fromRGB(255, 50, 50)  -- sem checagem = todos vermelhos
    end
    local myTeam = LocalPlayer.Team
    if myTeam and player.Team == myTeam then
        return Color3.fromRGB(0, 120, 255)  -- azul = aliado
    end
    return Color3.fromRGB(255, 50, 50)      -- vermelho = inimigo
end

-- Verifica se o jogador deve ser desenhado
-- CORREÇÃO: lógica simplificada — só exclui o próprio jogador e whitelisted
-- TeamCheck apenas filtra aliados (não bloqueia jogadores sem time)
local function IsValidTarget(player)
    if not player or player == LocalPlayer then return false end
    if Library:IsWhitelisted(player) then return false end

    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if not char:FindFirstChild("HumanoidRootPart") then return false end

    -- Se TeamCheck ativo, esconde aliados do mesmo time
    if Config.TeamCheck then
        local myTeam = LocalPlayer.Team
        if myTeam and player.Team == myTeam then return false end
    end

    return true
end

-- Projeção 3D → 2D (não retorna nil se Z<=0 para skeleton funcionar parcialmente)
local function toScreen(pos)
    local sp, onScreen = Camera:WorldToViewportPoint(pos)
    if not onScreen or sp.Z <= 0 then return nil end
    return Vector2.new(sp.X, sp.Y)
end

-- Bounding box 2D de uma BasePart
-- CORREÇÃO: usa apenas os pontos que estão na tela (min/max parcial)
-- em vez de retornar nil se qualquer canto sair da tela
local function partBounds(part)
    local s = part.Size
    local hx, hy, hz = s.X/2, s.Y/2, s.Z/2
    local offsets = {
        Vector3.new( hx, hy, hz), Vector3.new( hx, hy,-hz),
        Vector3.new( hx,-hy, hz), Vector3.new( hx,-hy,-hz),
        Vector3.new(-hx, hy, hz), Vector3.new(-hx, hy,-hz),
        Vector3.new(-hx,-hy, hz), Vector3.new(-hx,-hy,-hz),
    }
    local minX, minY =  math.huge,  math.huge
    local maxX, maxY = -math.huge, -math.huge
    local found = false
    for _, off in ipairs(offsets) do
        local sp = toScreen((part.CFrame * CFrame.new(off)).Position)
        if sp then
            found = true
            if sp.X < minX then minX = sp.X end
            if sp.Y < minY then minY = sp.Y end
            if sp.X > maxX then maxX = sp.X end
            if sp.Y > maxY then maxY = sp.Y end
        end
    end
    if not found then return nil end
    return minX, minY, maxX - minX, maxY - minY
end

-- ──────────────────────────────────────────────
-- LOOP PRINCIPAL
-- ──────────────────────────────────────────────
local function UpdateESP()
    -- Limpa jogadores que saíram
    for p in pairs(drawings) do
        if not p or not p.Parent then removePlayer(p) end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        local d     = allocPlayer(player)
        local color = GetColor(player)
        for _,l in ipairs(d.bones)    do l.Color = color end
        for _,s in ipairs(d.outlines) do s.Color = color end
        d.tracer.Color = color

        if not IsValidTarget(player) then
            hidePlayer(player)
            continue
        end

        local char = player.Character

        -- ── SKELETON ──────────────────────────────
        if Config.Skeleton then
            for i, pair in ipairs(BONE_PAIRS) do
                local pA = char:FindFirstChild(pair[1])
                local pB = char:FindFirstChild(pair[2])
                local ln = d.bones[i]
                if pA and pB then
                    local a = toScreen(pA.Position)
                    local b = toScreen(pB.Position)
                    if a and b then
                        ln.From = a; ln.To = b; ln.Visible = true
                    else
                        ln.Visible = false
                    end
                else
                    ln.Visible = false
                end
            end
        else
            for _,l in ipairs(d.bones) do l.Visible = false end
        end

        -- ── OUTLINE ───────────────────────────────
        if Config.Outline then
            for i, partName in ipairs(OUTLINE_PARTS) do
                local part = char:FindFirstChild(partName)
                local sq   = d.outlines[i]
                if part then
                    local x, y, w, h = partBounds(part)
                    if x and w > 0 and h > 0 then
                        sq.Position = Vector2.new(x, y)
                        sq.Size     = Vector2.new(w, h)
                        sq.Visible  = true
                    else
                        sq.Visible = false
                    end
                else
                    sq.Visible = false
                end
            end
        else
            for _,s in ipairs(d.outlines) do s.Visible = false end
        end

        -- ── TRACER ────────────────────────────────
        if Config.Tracers then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local sp = toScreen(root.Position)
                if sp then
                    local vp = Camera.ViewportSize
                    d.tracer.From    = Vector2.new(vp.X/2, vp.Y)
                    d.tracer.To      = sp
                    d.tracer.Visible = true
                else
                    d.tracer.Visible = false
                end
            else
                d.tracer.Visible = false
            end
        else
            d.tracer.Visible = false
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
        removeAll()
    end
end

-- ──────────────────────────────────────────────
-- UI
-- ──────────────────────────────────────────────
local ESP_Module = Visual:AddModule("👁️ ESP", function(state)
    Config.Enabled = state
    ToggleLoop(state)
end, false)

ESP_Module:AddToggle("💀 Skeleton (Graveto)", Config.Skeleton, function(state)
    Config.Skeleton = state
end)
ESP_Module:AddToggle("🔲 Outline (Contorno)", Config.Outline, function(state)
    Config.Outline = state
end)
ESP_Module:AddToggle("📈 Tracers (Linhas)", Config.Tracers, function(state)
    Config.Tracers = state
end)
ESP_Module:AddToggle("👥 Checar Time (azul/vermelho)", Config.TeamCheck, function(state)
    Config.TeamCheck = state
end)

print("✅ ESP V5 (Skeleton + Outline) carregado!")

return function() ToggleLoop(false) end
