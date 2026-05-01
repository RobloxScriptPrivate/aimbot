-- ========== HITBOX EXPANDER V1.0 ==========
local Library, CombatCategory = ..., select(2, ...)

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- CONFIGURAÇÕES
local Config = {
    Enabled    = false,
    Size       = 10,       -- tamanho do HumanoidRootPart expandido
    TeamCheck  = false,    -- só expande inimigos quando ativo
}

-- Guarda os tamanhos originais para restaurar ao desativar
local originalSizes = {}

-- ──────────────────────────────────────────────
-- FUNÇÕES AUXILIARES
-- ──────────────────────────────────────────────
local function IsEnemy(player)
    if not player or player == LocalPlayer then return false end
    if Library:IsWhitelisted(player) then return false end
    if not Config.TeamCheck then return true end
    if player.Neutral then return true end
    local myTeam = LocalPlayer.Team
    if myTeam and player.Team == myTeam then return false end
    return true
end

local function ExpandHitbox(player)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    -- Salva tamanho original só uma vez por personagem
    if not originalSizes[player] then
        originalSizes[player] = hrp.Size
    end
    pcall(function()
        hrp.Size         = Vector3.new(Config.Size, Config.Size, Config.Size)
        hrp.Transparency = 0.9
        hrp.CanCollide   = false
    end)
end

local function RestoreHitbox(player)
    local char = player.Character
    if not char then
        originalSizes[player] = nil
        return
    end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local orig = originalSizes[player]
        pcall(function()
            hrp.Size         = orig or Vector3.new(2, 2, 1)
            hrp.Transparency = 1
            hrp.CanCollide   = false
        end)
    end
    originalSizes[player] = nil
end

local function RestoreAll()
    for _, player in ipairs(Players:GetPlayers()) do
        RestoreHitbox(player)
    end
    originalSizes = {}
end

-- ──────────────────────────────────────────────
-- LOOP PRINCIPAL
-- ──────────────────────────────────────────────
local connection

local function ToggleLoop(state)
    if state and not connection then
        connection = RunService.Heartbeat:Connect(function()
            for _, player in ipairs(Players:GetPlayers()) do
                if IsEnemy(player) then
                    ExpandHitbox(player)
                else
                    -- Restaura aliados se TeamCheck ativo
                    if Config.TeamCheck and originalSizes[player] then
                        RestoreHitbox(player)
                    end
                end
            end
        end)
    elseif not state and connection then
        connection:Disconnect()
        connection = nil
        RestoreAll()
    end
end

-- Restaura hitbox quando um jogador sai ou respawna
Players.PlayerRemoving:Connect(function(player)
    originalSizes[player] = nil
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        -- Limpa o cache do tamanho original ao respawnar
        originalSizes[player] = nil
    end)
end)

-- ──────────────────────────────────────────────
-- UI
-- ──────────────────────────────────────────────
local HitboxModule = CombatCategory:AddModule("💥 Hitbox Expander", function(state)
    Config.Enabled = state
    ToggleLoop(state)
end, false)

HitboxModule:AddSlider("📐 Tamanho", 3, 50, Config.Size, function(val)
    Config.Size = val
end)

HitboxModule:AddToggle("👥 Só Inimigos (Time)", Config.TeamCheck, function(state)
    Config.TeamCheck = state
end)

print("✅ Hitbox Expander V1.0 carregado!")

-- Cleanup ao pressionar K
return function()
    if connection then connection:Disconnect(); connection = nil end
    RestoreAll()
end
