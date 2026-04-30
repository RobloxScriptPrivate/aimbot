-- ========== NAMETAG SIMPLES (Nome + Vida + Distância) ==========
local Library = ...

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
}

-- VARIÁVEIS
local nametags = {}  -- Armazena os textos
local screenCenter = Vector2.new(0, 0)

-- Cores conforme time
local function GetTeamColor(player)
    if not Config.TeamCheck then
        return Color3.fromRGB(255, 255, 255)
    end
    
    if not player.Team or not LocalPlayer.Team then
        return Color3.fromRGB(200, 200, 200)
    end
    
    if player.Team == LocalPlayer.Team then
        return Color3.fromRGB(0, 255, 0) -- Verde
    else
        return Color3.fromRGB(255, 0, 0) -- Vermelho
    end
end

-- Verifica se o jogador é válido
local function IsValidTarget(player)
    if player == LocalPlayer then return false end
    
    local character = player.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    return true
end

-- Atualiza o nametag de um jogador
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
    
    -- Cria o nametag se não existir
    if not nametags[player] then
        nametags[player] = Drawing.new("Text")
        nametags[player].Size = 14
        nametags[player].Center = true
        nametags[player].Outline = true
        nametags[player].Font = 2
        nametags[player].Visible = true
    end
    
    local color = GetTeamColor(player)
    local text = {}
    
    -- Nome do jogador
    if Config.ShowName then
        table.insert(text, player.Name)
    end
    
    -- Vida do jogador
    if Config.ShowHealth then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local health = humanoid and math.floor(humanoid.Health) or 0
        local maxHealth = humanoid and humanoid.MaxHealth or 100
        local percent = (health / maxHealth) * 100
        
        -- Cor da vida (verde > amarelo > vermelho)
        local healthColor
        if percent > 60 then
            healthColor = Color3.fromRGB(0, 255, 0)
        elseif percent > 30 then
            healthColor = Color3.fromRGB(255, 255, 0)
        else
            healthColor = Color3.fromRGB(255, 0, 0)
        end
        
        table.insert(text, string.format("❤️ %d", health))
        nametags[player].Color = healthColor
    else
        nametags[player].Color = color
    end
    
    -- Distância
    if Config.ShowDistance then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root and character:FindFirstChild("HumanoidRootPart") then
            local distance = (root.Position - character.HumanoidRootPart.Position).Magnitude
            table.insert(text, string.format("📏 %.1fm", distance))
        end
    end
    
    -- Atualiza o texto
    nametags[player].Text = table.concat(text, "  |  ")
    nametags[player].Position = Vector2.new(screenPos.X, screenPos.Y - 20)
end

-- Remove todos os nametags
local function ClearNametags()
    for player, text in pairs(nametags) do
        text:Remove()
    end
    nametags = {}
end

-- Loop principal
RunService.RenderStepped:Connect(function()
    if not Config.Enabled then
        ClearNametags()
        return
    end
    
    screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    -- Remove nametags de jogadores inválidos
    for player in pairs(nametags) do
        if not IsValidTarget(player) then
            nametags[player]:Remove()
            nametags[player] = nil
        end
    end
    
    -- Atualiza nametags dos jogadores válidos
    for _, player in ipairs(Players:GetPlayers()) do
        if IsValidTarget(player) then
            UpdateNametag(player)
        end
    end
end)

-- ========== LIMPEZA ==========
local function Cleanup()
    print("🧹 Removendo Nametags...")
    ClearNametags()
    print("✅ Nametags removidas!")
end

-- ========== INTEGRAÇÃO COM A BIBLIOTECA GUI ==========
local Visual = Library:CreateCategory("👁️ Visual", UDim2.new(0, 10, 0, 100))

-- Módulo principal do Nametag
local Nametag = Visual:AddModule("🏷️ Nametags", function(state)
    Config.Enabled = state
    if not state then
        ClearNametags()
    end
    print(state and "✅ Nametags Ligadas" or "❌ Nametags Desligadas")
end, false)

-- Configurações do Nametag
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

print("✅ Módulo Nametag carregado!")

-- Retorna a função de limpeza
return Cleanup
