-- ========== NAMETAG (Nome + Vida + Distância em Português) ==========
local Library, Visual = ..., select(2, ...)

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- CONFIGURAÇÕES
local Config = {
    Enabled = false,
    TeamCheck = true,
    ShowHealth = true,
    ShowDistance = true,
    ShowName = true,
    TextSize = 14,
}

-- VARIÁVEIS
local nametags = {}

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
        return Color3.fromRGB(255, 80, 80)
    end
end

local function GetHealthColor(percent)
    if percent > 60 then
        return Color3.fromRGB(0, 255, 0)
    elseif percent > 30 then
        return Color3.fromRGB(255, 255, 0)
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

local function UpdateNametag(player)
    local character = player.Character
    if not character then return end
    
    local head = character:FindFirstChild("Head")
    if not head then return end
    
    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.5, 0))
    if not onScreen or screenPos.Z <= 0 then
        if nametags[player] then
            nametags[player].Visible = false
        end
        return
    end
    
    if not nametags[player] then
        nametags[player] = Drawing.new("Text")
        nametags[player].Size = Config.TextSize
        nametags[player].Center = true
        nametags[player].Outline = true
        nametags[player].Font = 2
        nametags[player].Visible = true
    end
    
    local texts = {}
    
    if Config.ShowName then
        table.insert(texts, player.Name)
    end
    
    if Config.ShowHealth then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local health = humanoid and math.floor(humanoid.Health) or 0
        table.insert(texts, string.format("❤️ %d", health))
        
        local maxHealth = humanoid and humanoid.MaxHealth or 100
        local percent = (health / maxHealth) * 100
        nametags[player].Color = GetHealthColor(percent)
    else
        nametags[player].Color = GetTeamColor(player)
    end
    
    if Config.ShowDistance then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root and character:FindFirstChild("HumanoidRootPart") then
            local distance = (root.Position - character.HumanoidRootPart.Position).Magnitude
            table.insert(texts, string.format("📏 %.1fm", distance))
        end
    end
    
    nametags[player].Text = table.concat(texts, "  |  ")
    nametags[player].Position = Vector2.new(screenPos.X, screenPos.Y - 20)
end

local function ClearNametags()
    for player, text in pairs(nametags) do
        text:Remove()
    end
    nametags = {}
end

RunService.RenderStepped:Connect(function()
    if not Config.Enabled then
        ClearNametags()
        return
    end
    
    for player in pairs(nametags) do
        if not IsValidTarget(player) then
            nametags[player]:Remove()
            nametags[player] = nil
        end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if IsValidTarget(player) then
            UpdateNametag(player)
        end
    end
end)

local function Cleanup()
    ClearNametags()
end

-- ========== ADICIONA O MÓDULO À CATEGORIA VISUAL ==========
local Nametag = Visual:AddModule("🏷️ Nametags", function(state)
    Config.Enabled = state
    if not state then ClearNametags() end
end, false)

Nametag:AddToggle("👥 Mostrar por Time", Config.TeamCheck, function(state)
    Config.TeamCheck = state
end)

Nametag:AddToggle("📝 Mostrar Nome", Config.ShowName, function(state)
    Config.ShowName = state
end)

Nametag:AddToggle("❤️ Mostrar Vida", Config.ShowHealth, function(state)
    Config.ShowHealth = state
end)

Nametag:AddToggle("📏 Mostrar Distância", Config.ShowDistance, function(state)
    Config.ShowDistance = state
end)

Nametag:AddSlider("📏 Tamanho do Texto", 10, 20, Config.TextSize, function(value)
    Config.TextSize = value
    for _, text in pairs(nametags) do
        text.Size = value
    end
end)

print("✅ Nametag carregado!")

return Cleanup
