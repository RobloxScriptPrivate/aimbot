-- ========== ESP V6 (Skeleton Motor6D + Highlight Outline) ==========
-- Skeleton: baseado em UniversalSkeleton (Blissful4992) - usa Motor6D
-- Outline:  usa Instance.new("Highlight") nativo do Roblox
local Library, Visual = ..., select(2, ...)

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local Camera      = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Config = {
    Enabled   = false,
    Skeleton  = true,
    Outline   = false,
    Tracers   = false,
    TeamCheck = false,
}

local saved = Library:LoadConfig("esp")
if saved then
    if type(saved.Skeleton)  == "boolean" then Config.Skeleton  = saved.Skeleton  end
    if type(saved.Outline)   == "boolean" then Config.Outline   = saved.Outline   end
    if type(saved.Tracers)   == "boolean" then Config.Tracers   = saved.Tracers   end
    if type(saved.TeamCheck) == "boolean" then Config.TeamCheck = saved.TeamCheck end
end

local function Save()
    Library:SaveConfig("esp", {
        Skeleton  = Config.Skeleton,
        Outline   = Config.Outline,
        Tracers   = Config.Tracers,
        TeamCheck = Config.TeamCheck,
    })
end

-- ──────────────────────────────────────────────
-- CORES
-- ──────────────────────────────────────────────
local function GetColor(player)
    if not Config.TeamCheck then
        return Color3.fromRGB(255, 50, 50)
    end
    local myTeam = LocalPlayer.Team
    if myTeam and player.Team == myTeam then
        return Color3.fromRGB(0, 120, 255)
    end
    return Color3.fromRGB(255, 50, 50)
end

-- ──────────────────────────────────────────────
-- VALIDAÇÃO
-- ──────────────────────────────────────────────
local function IsValidTarget(player)
    if not player or player == LocalPlayer then return false end
    if Library:IsWhitelisted(player) then return false end
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if not char:FindFirstChild("HumanoidRootPart") then return false end
    if Config.TeamCheck then
        local myTeam = LocalPlayer.Team
        if myTeam and player.Team == myTeam then return false end
    end
    return true
end

-- ──────────────────────────────────────────────
-- SKELETON via Motor6D (igual UniversalSkeleton)
-- Cada entrada em Lines = { line1, line2, partName, motorName }
-- line1: Part0.center → joint offset C0
-- line2: Part1.center → joint offset C1
-- ──────────────────────────────────────────────
local skeletons = {}  -- skeletons[player] = { Lines={}, conn=nil }

local function newLine(color)
    local l = Drawing.new("Line")
    l.Visible = false
    l.Thickness = 1.5
    l.Color = color or Color3.fromRGB(255, 50, 50)
    return l
end

local function buildLines(player, color)
    local char = player.Character
    if not char then return {} end
    local lines = {}
    for _, part in next, char:GetChildren() do
        if not part:IsA("BasePart") then continue end
        for _, motor in next, part:GetChildren() do
            if not motor:IsA("Motor6D") then continue end
            table.insert(lines, {
                newLine(color),
                newLine(color),
                part.Name,
                motor.Name,
            })
        end
    end
    return lines
end

local function removeLines(lines)
    for _, l in ipairs(lines) do
        l[1]:Remove()
        l[2]:Remove()
    end
end

local function updateSkeleton(player, lines, color)
    local char = player.Character
    if not char then return false end
    local needRebuild = false

    for _, l in ipairs(lines) do
        local part = char:FindFirstChild(l[3])
        if not part then
            l[1].Visible = false; l[2].Visible = false
            needRebuild = true
            continue
        end
        local motor = part:FindFirstChild(l[4])
        if not (motor and motor.Part0 and motor.Part1) then
            l[1].Visible = false; l[2].Visible = false
            needRebuild = true
            continue
        end

        local p0, p1 = motor.Part0, motor.Part1
        local c0, c1 = motor.C0, motor.C1

        -- linha 1: centro de Part0 → offset C0
        local a0, v0 = Camera:WorldToViewportPoint(p0.CFrame.p)
        local a1, v1 = Camera:WorldToViewportPoint((p0.CFrame * c0).p)
        if v0 and v1 then
            l[1].From = Vector2.new(a0.X, a0.Y)
            l[1].To   = Vector2.new(a1.X, a1.Y)
            l[1].Color = color
            l[1].Visible = true
        else
            l[1].Visible = false
        end

        -- linha 2: centro de Part1 → offset C1
        local b0, w0 = Camera:WorldToViewportPoint(p1.CFrame.p)
        local b1, w1 = Camera:WorldToViewportPoint((p1.CFrame * c1).p)
        if w0 and w1 then
            l[2].From = Vector2.new(b0.X, b0.Y)
            l[2].To   = Vector2.new(b1.X, b1.Y)
            l[2].Color = color
            l[2].Visible = true
        else
            l[2].Visible = false
        end
    end

    return needRebuild
end

local function hideSkeleton(player)
    local s = skeletons[player]
    if not s then return end
    for _, l in ipairs(s.Lines) do
        l[1].Visible = false
        l[2].Visible = false
    end
end

local function removeSkeleton(player)
    local s = skeletons[player]
    if not s then return end
    if s.conn then s.conn:Disconnect() end
    removeLines(s.Lines)
    skeletons[player] = nil
end

local function removeAllSkeletons()
    for p in pairs(skeletons) do removeSkeleton(p) end
end

-- ──────────────────────────────────────────────
-- OUTLINE via Highlight instance
-- Highlight.FillTransparency = 1 → sem preenchimento
-- Highlight.OutlineTransparency = 0 → contorno sólido
-- Highlight.DepthMode = AlwaysOnTop → vê através de paredes
-- ──────────────────────────────────────────────
local highlights = {}  -- highlights[player] = Highlight instance

local function getOrCreateHighlight(player)
    if highlights[player] and highlights[player].Parent then
        return highlights[player]
    end
    local char = player.Character
    if not char then return nil end
    -- Remove highlight antigo se existir
    local old = char:FindFirstChildOfClass("Highlight")
    if old then old:Destroy() end
    local h = Instance.new("Highlight")
    h.FillTransparency    = 1      -- sem preenchimento de cor
    h.OutlineTransparency = 0      -- contorno totalmente visível
    h.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = char
    highlights[player] = h
    return h
end

local function removeHighlight(player)
    local h = highlights[player]
    if h then
        pcall(function() h:Destroy() end)
        highlights[player] = nil
    end
end

local function removeAllHighlights()
    for p in pairs(highlights) do removeHighlight(p) end
end

-- ──────────────────────────────────────────────
-- TRACER
-- ──────────────────────────────────────────────
local tracers = {}  -- tracers[player] = Line

local function getOrCreateTracer(player)
    if tracers[player] then return tracers[player] end
    local l = Drawing.new("Line")
    l.Visible = false; l.Thickness = 1.5
    tracers[player] = l
    return l
end

local function removeTracer(player)
    if tracers[player] then tracers[player]:Remove(); tracers[player] = nil end
end

local function removeAllTracers()
    for p in pairs(tracers) do removeTracer(p) end
end

-- ──────────────────────────────────────────────
-- LOOP PRINCIPAL
-- ──────────────────────────────────────────────
local function UpdateESP()
    -- Limpa jogadores que saíram
    for p in pairs(skeletons) do
        if not p or not p.Parent then removeSkeleton(p) end
    end
    for p in pairs(highlights) do
        if not p or not p.Parent then removeHighlight(p) end
    end
    for p in pairs(tracers) do
        if not p or not p.Parent then removeTracer(p) end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        local color = GetColor(player)
        local valid = IsValidTarget(player)

        -- SKELETON
        if Config.Skeleton and valid then
            local s = skeletons[player]
            if not s then
                local lines = buildLines(player, color)
                skeletons[player] = { Lines = lines }
                s = skeletons[player]
            end
            local needRebuild = updateSkeleton(player, s.Lines, color)
            if needRebuild or #s.Lines == 0 then
                removeLines(s.Lines)
                s.Lines = buildLines(player, color)
            end
        else
            hideSkeleton(player)
        end

        -- OUTLINE (Highlight)
        if Config.Outline and valid then
            local h = getOrCreateHighlight(player)
            if h then
                h.OutlineColor = color
                h.Enabled = true
            end
        else
            local h = highlights[player]
            if h then h.Enabled = false end
        end

        -- TRACER
        if Config.Tracers and valid then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local t = getOrCreateTracer(player)
            t.Color = color
            if root then
                local sp, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen and sp.Z > 0 then
                    local vp = Camera.ViewportSize
                    t.From = Vector2.new(vp.X/2, vp.Y)
                    t.To   = Vector2.new(sp.X, sp.Y)
                    t.Visible = true
                else
                    t.Visible = false
                end
            else
                t.Visible = false
            end
        else
            local t = tracers[player]
            if t then t.Visible = false end
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
        removeAllSkeletons()
        removeAllHighlights()
        removeAllTracers()
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
    if not state then removeAllSkeletons() end
    Save()
end)
ESP_Module:AddToggle("🔲 Outline (Contorno)", Config.Outline, function(state)
    Config.Outline = state
    if not state then removeAllHighlights() end
    Save()
end)
ESP_Module:AddToggle("📈 Tracers (Linhas)", Config.Tracers, function(state)
    Config.Tracers = state
    if not state then removeAllTracers() end
    Save()
end)
ESP_Module:AddToggle("👥 Checar Time (azul/vermelho)", Config.TeamCheck, function(state)
    Config.TeamCheck = state
    Save()
end)

print("✅ ESP V6 (Skeleton Motor6D + Highlight Outline) carregado!")

-- Limpa tudo independente do estado atual
return function()
    if connection then connection:Disconnect(); connection = nil end
    removeAllSkeletons()
    removeAllHighlights()
    removeAllTracers()
end
