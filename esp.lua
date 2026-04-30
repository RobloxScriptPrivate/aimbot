-- ========== ESP SIMPLES (BORDA CONFORME TIME) ==========
local Library = ...
local Visual = ... -- Recebe a categoria Visual do loader

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- CONFIGURAÇÕES
local Config = {
    Enabled = false,
    TeamCheck = true,
    OutlineThickness = 2,
    ShowDistance = true,
}

-- VARIÁVEIS
local espObjects = {}

-- Cores dos times
local function GetTeamColor(player)
    if not Config.TeamCheck then
        return Color3.fromRGB(255, 255, 255)
    end
    
    if not player.Team or not LocalPlayer.Team then
        return Color3.fromRGB(200, 200, 200)
    end
    
    if player.Team == LocalPlayer.Team then
        return Color3.fromRGB(0, 255, 0)
    else
        return Color3.fromRGB(255, 0, 0)
    end
end

local function IsValidTarget(player)
    if player == LocalPlayer then return false end
    local character = player.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function DrawOutline(player, color)
    local character = player.Character
    if not character then return end
    
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    local anyVisible = false
    
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Visible then
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen and screenPos.Z > 0 then
                anyVisible = true
                minX = math.min(minX, screenPos.X)
                minY = math.min(minY, screenPos.Y)
                maxX = math.max(maxX, screenPos.X)
                maxY = math.max(maxY, screenPos.Y)
            end
        end
    end
    
    if not anyVisible then return end
    
    local padding = 5
    minX = minX - padding
    minY = minY - padding
    maxX = maxX + padding
    maxY = maxY + padding
    
    if not espObjects[player] then
        espObjects[player] = {
            top = Drawing.new("Line"),
            bottom = Drawing.new("Line"),
            left = Drawing.new("Line"),
            right = Drawing.new("Line"),
            distance = Drawing.new("Text")
        }
        
        for _, line in pairs(espObjects[player]) do
            if line ~= espObjects[player].distance then
                line.Thickness = Config.OutlineThickness
                line.Transparency = 0.8
                line.Visible = true
            end
        end
        
        espObjects[player].distance.Size = 12
        espObjects[player].distance.Outline = true
        espObjects[player].distance.Center = true
        espObjects[player].distance.Font = 2
    end
    
    local lines = espObjects[player]
    lines.top.From = Vector2.new(minX, minY)
    lines.top.To = Vector2.new(maxX, minY)
    lines.bottom.From = Vector2.new(minX, maxY)
    lines.bottom.To = Vector2.new(maxX, maxY)
    lines.left.From = Vector2.new(minX, minY)
    lines.left.To = Vector2.new(minX, maxY)
    lines.right.From = Vector2.new(maxX, minY)
    lines.right.To = Vector2.new(maxX, maxY)
    
    lines.top.Color = color
    lines.bottom.Color = color
    lines.left.Color = color
    lines.right.Color = color
    
    if Config.ShowDistance and character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local distance = (root.Position - character.HumanoidRootPart.Position).Magnitude
            local centerX = (minX + maxX) / 2
            local centerY = (minY + maxY) / 2
            lines.distance.Position = Vector2.new(centerX, maxY + 15)
            lines.distance.Text = string.format("%.1f m", distance)
            lines.distance.Color = color
            lines.distance.Visible = true
        end
    else
        lines.distance.Visible = false
    end
end

local function ClearESP()
    for player, objects in pairs(espObjects) do
        for _, obj in pairs(objects) do
            obj:Remove()
        end
    end
    espObjects = {}
end

RunService.RenderStepped:Connect(function()
    if not Config.Enabled then
        ClearESP()
        return
    end
    
    for player in pairs(espObjects) do
        if not IsValidTarget(player) then
            for _, obj in pairs(espObjects[player]) do
                obj:Remove()
            end
            espObjects[player] = nil
        end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if IsValidTarget(player) then
            DrawOutline(player, GetTeamColor(player))
        end
    end
end)

-- ========== LIMPEZA ==========
local function Cleanup()
    ClearESP()
end

-- ========== ADICIONA O MÓDULO À CATEGORIA VISUAL ==========
local ESP = Visual:AddModule("🎨 ESP (Borda)", function(state)
    Config.Enabled = state
    if not state then ClearESP() end
end, false)

ESP:AddToggle("👥 Mostrar por Time", Config.TeamCheck, function(state)
    Config.TeamCheck = state
end)

ESP:AddToggle("📏 Mostrar Distância", Config.ShowDistance, function(state)
    Config.ShowDistance = state
end)

ESP:AddSlider("📏 Espessura", 1, 5, Config.OutlineThickness, function(value)
    Config.OutlineThickness = value
    for player, objects in pairs(espObjects) do
        for _, line in pairs(objects) do
            if line ~= objects.distance then
                line.Thickness = value
            end
        end
    end
end)

print("✅ ESP carregado!")

return Cleanup
