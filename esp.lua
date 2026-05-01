-- ========== ESP V7 (Skeleton, Outline, Filled) ==========
-- Skeleton:  Motor6D based (Blissful4992)
-- Outline:   Highlight (Outline only)
-- Filled:    Highlight (Filled + Nametag)
local Library, Visual = ..., select(2, ...)

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local Camera      = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Config = {
    Enabled   = false,
    Skeleton  = true,
    Outline   = false,
    Preenchido = false, -- Filled mode (Highlight + Nametag)
    Tracers   = false,
    TeamCheck = true,
    MaxDistance = 300,
}

local saved = Library:LoadConfig("esp")
if saved then
    if type(saved.Skeleton)  == "boolean" then Config.Skeleton  = saved.Skeleton  end
    if type(saved.Outline)   == "boolean" then Config.Outline   = saved.Outline   end
    if type(saved.Preenchido) == "boolean" then Config.Preenchido = saved.Preenchido end
    if type(saved.Tracers)   == "boolean" then Config.Tracers   = saved.Tracers   end
    if type(saved.TeamCheck) == "boolean" then Config.TeamCheck = saved.TeamCheck end
    if type(saved.MaxDistance) == "number" then Config.MaxDistance = saved.MaxDistance end
end

local function Save()
    Library:SaveConfig("esp", {
        Skeleton  = Config.Skeleton,
        Outline   = Config.Outline,
        Preenchido = Config.Preenchido,
        Tracers   = Config.Tracers,
        TeamCheck = Config.TeamCheck,
        MaxDistance = Config.MaxDistance,
    })
end

-- ──────────────────────────────────────────────
-- CORES
-- ──────────────────────────────────────────────
local function GetColor(player)
    if Config.TeamCheck then
        -- Prioritize the game's built-in team color system
        if player.TeamColor ~= nil and player.TeamColor.Color ~= Color3.fromRGB(204, 204, 204) then -- Ignore neutral grey
            return player.TeamColor.Color
        end
        -- Fallback to team instances if TeamColor isn't used
        if LocalPlayer.Team and player.Team then
            if player.Team == LocalPlayer.Team then
                return Color3.fromRGB(0, 120, 255) -- Friendly
            end
        end
    end
    -- Default enemy color
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
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end

    -- Distance Check
    local localChar = LocalPlayer.Character
    if localChar then
        local localRoot = localChar:FindFirstChild("HumanoidRootPart")
        if localRoot then
            if (rootPart.Position - localRoot.Position).Magnitude > Config.MaxDistance then
                return false
            end
        end
    end

    -- TeamCheck is now handled by GetColor, so we don't filter out teammates here
    if Config.TeamCheck and LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team then
        return true -- Always show teammates if TeamCheck is on
    end

    return true
end

-- ==================== SKELETON ====================
local skeletons = {}

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
    if skeletons[player] then
        for _, l in ipairs(skeletons[player].Lines) do
            l[1].Visible = false
            l[2].Visible = false
        end
    end
end

local function removeSkeleton(player)
    if skeletons[player] then
        if skeletons[player].conn then skeletons[player].conn:Disconnect() end
        removeLines(skeletons[player].Lines)
        skeletons[player] = nil
    end
end

local function removeAllSkeletons()
    for p in pairs(skeletons) do removeSkeleton(p) end
end

-- ==================== HIGHLIGHT (OUTLINE & FILLED) ====================
local highlights_outline = {}
local highlights_filled = {}
local nametags_filled = {} -- BillboardGuis for the "Filled" mode

local function createHighlight(player, parent)
    local h = Instance.new("Highlight")
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = parent
    h.Adornee = player.Character
    return h
end

-- Outline Specific
local function removeHighlight_Outline(player)
    if highlights_outline[player] then
        pcall(function() highlights_outline[player]:Destroy() end)
        highlights_outline[player] = nil
    end
end
local function removeAllHighlights_Outline()
    for p in pairs(highlights_outline) do removeHighlight_Outline(p) end
end

-- Filled Specific
local function removeHighlight_Filled(player)
    if highlights_filled[player] then
        pcall(function() highlights_filled[player]:Destroy() end)
        highlights_filled[player] = nil
    end
    if nametags_filled[player] then
        pcall(function() nametags_filled[player]:Destroy() end)
        nametags_filled[player] = nil
    end
end
local function removeAllHighlights_Filled()
    for p in pairs(highlights_filled) do removeHighlight_Filled(p) end
end

-- ==================== TRACER ====================
local tracers = {}

local function getOrCreateTracer(player)
    if not tracers[player] then
        tracers[player] = Drawing.new("Line")
        tracers[player].Visible = false
        tracers[player].Thickness = 1.5
    end
    return tracers[player]
end

local function removeTracer(player)
    if tracers[player] then
        tracers[player]:Remove()
        tracers[player] = nil
    end
end

local function removeAllTracers()
    for p in pairs(tracers) do removeTracer(p) end
end

-- ──────────────────────────────────────────────
-- LOOP PRINCIPAL
-- ──────────────────────────────────────────────
local function UpdateESP()
    -- Cleanup players who left
    for p in pairs(skeletons) do if not p or not p.Parent then removeSkeleton(p) end end
    for p in pairs(highlights_outline) do if not p or not p.Parent then removeHighlight_Outline(p) end end
    for p in pairs(highlights_filled) do if not p or not p.Parent then removeHighlight_Filled(p) end end
    for p in pairs(tracers) do if not p or not p.Parent then removeTracer(p) end end

    for _, player in ipairs(Players:GetPlayers()) do
        local valid = IsValidTarget(player)
        local color = GetColor(player)
        local char = player.Character

        -- SKELETON
        if Config.Skeleton and valid then
            local s = skeletons[player]
            if not s then
                skeletons[player] = { Lines = buildLines(player, color) }
                s = skeletons[player]
            end
            if updateSkeleton(player, s.Lines, color) or #s.Lines == 0 then
                removeLines(s.Lines)
                s.Lines = buildLines(player, color)
            end
        else
            hideSkeleton(player)
        end

        -- OUTLINE (Highlight)
        if Config.Outline and valid then
            local h = highlights_outline[player]
            if not h or not h.Parent then h = createHighlight(player, char); highlights_outline[player] = h; end
            h.OutlineColor = color
            h.FillTransparency = 1
            h.OutlineTransparency = 0
            h.Enabled = true
        elseif highlights_outline[player] then
            highlights_outline[player].Enabled = false
        end

        -- FILLED / PREENCHIDO (Highlight + Nametag)
        if Config.Preenchido and valid then
            -- Highlight part
            local h = highlights_filled[player]
            if not h or not h.Parent then h = createHighlight(player, char); highlights_filled[player] = h; end
            h.FillColor = color
            h.OutlineColor = color
            h.FillTransparency = 0.5
            h.OutlineTransparency = 0.2
            h.Enabled = true
            
            -- Nametag part
            local nameTag = nametags_filled[player]
            if not nameTag or not nameTag.Parent then
                nameTag = Instance.new("BillboardGui", char)
                nameTag.Adornee = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                nameTag.Size = UDim2.new(0, 200, 0, 50)
                nameTag.StudsOffset = Vector3.new(0, 3, 0)
                nameTag.AlwaysOnTop = true
                
                local textLabel = Instance.new("TextLabel", nameTag)
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextStrokeTransparency = 0
                textLabel.TextSize = 14
                textLabel.Font = Enum.Font.SourceSansBold
                nametags_filled[player] = nameTag
            end
            local textLabel = nameTag:FindFirstChildOfClass("TextLabel")
            if textLabel then
                textLabel.Text = player.Name
                textLabel.TextColor3 = color
            end
            nameTag.Enabled = true

        elseif highlights_filled[player] then
            highlights_filled[player].Enabled = false
            if nametags_filled[player] then
                nametags_filled[player].Enabled = false
            end
        end

        -- TRACER
        if Config.Tracers and valid then
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
        elseif tracers[player] then
            tracers[player].Visible = false
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
        removeAllHighlights_Outline()
        removeAllHighlights_Filled()
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
    if not state then removeAllHighlights_Outline() end
    Save()
end)
ESP_Module:AddToggle("🎨 Preenchido (Cheio)", Config.Preenchido, function(state)
    Config.Preenchido = state
    if not state then removeAllHighlights_Filled() end
    Save()
end)
ESP_Module:AddToggle("📈 Tracers (Linhas)", Config.Tracers, function(state)
    Config.Tracers = state
    if not state then removeAllTracers() end
    Save()
end)
ESP_Module:AddToggle("👥 Checar Time (Cores)", Config.TeamCheck, function(state)
    Config.TeamCheck = state
    Save()
end)

ESP_Module:AddSlider("📏 Distância Máxima", 10, 1000, Config.MaxDistance, true, function(value)
    Config.MaxDistance = value
    Save()
end)

print("✅ ESP V7 (Skeleton, Outline, Filled) carregado!")

return function()
    if connection then connection:Disconnect(); connection = nil end
    removeAllSkeletons()
    removeAllHighlights_Outline()
    removeAllHighlights_Filled()
    removeAllTracers()
end