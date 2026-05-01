-- ========== ESP V3 (Box + Tracer corrigidos) ==========
local Library, Visual = ..., select(2, ...)

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- CONFIGURAÇÕES
local Config = {
    Enabled = false,
    Boxes = true,
    Tracers = false,
    TeamCheck = true,
    TracerStartPoint = "Bottom",
}

-- VARIÁVEIS — cada jogador tem { box, tracer }
local drawings = {}

-- ──────────────────────────────────────────────
-- Helpers de desenho
-- ──────────────────────────────────────────────
local function newBox()
    local d = Drawing.new("Square")
    d.Visible = false
    d.Filled = false
    d.Thickness = 1.5
    d.Color = Color3.fromRGB(255, 255, 0)
    return d
end

local function newLine()
    local d = Drawing.new("Line")
    d.Visible = false
    d.Thickness = 1.5
    d.Color = Color3.fromRGB(255, 255, 0)
    return d
end

local function getOrCreate(player)
    if not drawings[player] then
        drawings[player] = { box = newBox(), tracer = newLine() }
    end
    return drawings[player]
end

local function hidePlayer(player)
    local d = drawings[player]
    if d then
        d.box.Visible = false
        d.tracer.Visible = false
    end
end

local function removePlayer(player)
    local d = drawings[player]
    if d then
        d.box:Remove()
        d.tracer:Remove()
        drawings[player] = nil
    end
end

local function removeAll()
    for player in pairs(drawings) do
        removePlayer(player)
    end
end

-- ──────────────────────────────────────────────
-- Validação de alvo
-- ──────────────────────────────────────────────
local function IsValidTarget(player)
    if not player or player == LocalPlayer then return false end
    if Library:IsWhitelisted(player) then return false end
    if Config.TeamCheck then
        if not player.Neutral then
            local myTeam = LocalPlayer.Team
            local myColor = LocalPlayer.TeamColor
            if player.Team == myTeam or (player.TeamColor == myColor and myColor ~= nil) then
                return false
            end
        end
    end
    local character = player.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0 and character:FindFirstChild("HumanoidRootPart") ~= nil
end

local function GetESPColor(player)
    if not Config.TeamCheck or not player.Team or not LocalPlayer.Team then
        return Color3.fromRGB(255, 255, 0)
    end
    return player.Team == LocalPlayer.Team
        and Color3.fromRGB(0, 255, 120)
        or  Color3.fromRGB(255, 80, 80)
end

-- ──────────────────────────────────────────────
-- Bounding box 2D via 8 cantos do volume do char
-- ──────────────────────────────────────────────
local function getScreenBoundingBox(rootPart)
    local halfW, halfH, halfD = 2, 3, 1
    local offsets = {
        Vector3.new( halfW,  halfH,  halfD),
        Vector3.new( halfW,  halfH, -halfD),
        Vector3.new( halfW, -halfH,  halfD),
        Vector3.new( halfW, -halfH, -halfD),
        Vector3.new(-halfW,  halfH,  halfD),
        Vector3.new(-halfW,  halfH, -halfD),
        Vector3.new(-halfW, -halfH,  halfD),
        Vector3.new(-halfW, -halfH, -halfD),
    }
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    for _, offset in ipairs(offsets) do
        local worldPos = (rootPart.CFrame * CFrame.new(offset)).Position
        local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)
        if not onScreen or screenPos.Z <= 0 then return nil end
        if screenPos.X < minX then minX = screenPos.X end
        if screenPos.Y < minY then minY = screenPos.Y end
        if screenPos.X > maxX then maxX = screenPos.X end
        if screenPos.Y > maxY then maxY = screenPos.Y end
    end
    return minX, minY, maxX - minX, maxY - minY
end

-- ──────────────────────────────────────────────
-- Loop principal
-- ──────────────────────────────────────────────
local function UpdateESP()
    for player in pairs(drawings) do
        if not player or not player.Parent then
            removePlayer(player)
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        local d = getOrCreate(player)
        local color = GetESPColor(player)
        d.box.Color = color
        d.tracer.Color = color

        if not IsValidTarget(player) then
            hidePlayer(player)
            continue
        end

        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local head = character and character:FindFirstChild("Head")
        if not rootPart or not head then
            hidePlayer(player)
            continue
        end

        -- BOX
        if Config.Boxes then
            local x, y, w, h = getScreenBoundingBox(rootPart)
            if x then
                d.box.Position = Vector2.new(x, y)
                d.box.Size = Vector2.new(w, h)
                d.box.Visible = true
            else
                d.box.Visible = false
            end
        else
            d.box.Visible = false
        end

        -- TRACER
        if Config.Tracers then
            local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen and headPos.Z > 0 then
                local vp = Camera.ViewportSize
                local from
                if Config.TracerStartPoint == "Top" then
                    from = Vector2.new(vp.X / 2, 0)
                elseif Config.TracerStartPoint == "Mouse" then
                    from = UserInputService:GetMouseLocation()
                else
                    from = Vector2.new(vp.X / 2, vp.Y)
                end
                d.tracer.From = from
                d.tracer.To = Vector2.new(headPos.X, headPos.Y)
                d.tracer.Visible = true
            else
                d.tracer.Visible = false
            end
        else
            d.tracer.Visible = false
        end
    end
end

-- ──────────────────────────────────────────────
-- Toggle
-- ──────────────────────────────────────────────
local connection
local function ToggleLoop(state)
    if state and not connection then
        connection = RunService.RenderStepped:Connect(UpdateESP)
    elseif not state and connection then
        connection:Disconnect()
        connection = nil
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

ESP_Module:AddToggle("📦 Boxes (Caixas)", Config.Boxes, function(state) Config.Boxes = state end)
ESP_Module:AddToggle("📈 Tracers (Linhas)", Config.Tracers, function(state) Config.Tracers = state end)
ESP_Module:AddToggle("👥 Checagem de Time", Config.TeamCheck, function(state) Config.TeamCheck = state end)
ESP_Module:AddDropdown("📍 Ponto do Tracer", {"Bottom", "Top", "Mouse"}, function(val) Config.TracerStartPoint = val end)

print("✅ ESP V3 carregado!")

return function()
    ToggleLoop(false)
end
