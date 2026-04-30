-- ========== NAMETAG (Nome + Vida + Distância em Português) V2 ==========
local Library = ...
local Visual = select(2, ...)

-- Verificação de debug
if not Visual then
    print("❌ ERRO: Visual é nil!")
    return function() end
end

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
local localCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Atualiza a referência do personagem local ao renascer
LocalPlayer.CharacterAdded:Connect(function(character)
    localCharacter = character
end)

local function GetTeamColor(player)
    if not Config.TeamCheck or not player.Team or not LocalPlayer.Team then
        return Color3.fromRGB(255, 255, 255) -- Branco se a checagem estiver desativada ou times inválidos
    end
    
    if player.Team == LocalPlayer.Team then
        return Color3.fromRGB(0, 255, 120) -- Verde para time aliado
    else
        return Color3.fromRGB(255, 80, 80) -- Vermelho para time inimigo
    end
end

local function GetHealthColor(percent)
    return Color3.fromHSV(0.33 * (percent / 100), 1, 1) -- Gradiente de verde para vermelho
end

local function IsValidTarget(player)
    if not player or not player:IsA("Player") or player == LocalPlayer then return false end
    local character = player.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function UpdateNametag(player, character, humanoid)
    local head = character:FindFirstChild("Head")
    if not head then return end
    
    -- Posição do Nametag
    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.5, 0))
    if not onScreen or screenPos.Z <= 0 then
        if nametags[player] then
            nametags[player].Visible = false
        end
        return
    end
    
    -- Cria se não existir
    if not nametags[player] then
        local newTag = Drawing.new("Text")
        newTag.Center = true
        newTag.Outline = true
        newTag.Font = 2
        nametags[player] = newTag
    end
    
    local tag = nametags[player]
    tag.Size = Config.TextSize
    tag.Visible = true
    
    -- Monta o texto
    local texts = {}
    if Config.ShowName then
        table.insert(texts, player.Name)
    end
    
    if Config.ShowHealth then
        local health = math.floor(humanoid.Health)
        table.insert(texts, string.format("❤️ %d", health))
        tag.Color = GetHealthColor( (health / humanoid.MaxHealth) * 100 )
    else
        tag.Color = GetTeamColor(player)
    end
    
    if Config.ShowDistance then
        local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
        local targetRoot = character:FindFirstChild("HumanoidRootPart")
        if localRoot and targetRoot then
            local distance = (localRoot.Position - targetRoot.Position).Magnitude
            table.insert(texts, string.format("📏 %.0fm", distance))
        end
    end
    
    tag.Text = table.concat(texts, " | ")
    tag.Position = Vector2.new(screenPos.X, screenPos.Y)
end

local function ClearNametags()
    for player, tag in pairs(nametags) do
        if tag then tag:Remove() end
    end
    nametags = {}
end

-- Loop Principal
local connection
local function ToggleLoop(state)
    if state and not connection then
        connection = RunService.RenderStepped:Connect(function()
            -- Limpa tags de jogadores que saíram
            for player, tag in pairs(nametags) do
                if not player or not player.Parent then
                    tag:Remove()
                    nametags[player] = nil
                end
            end

            -- Atualiza tags de jogadores válidos
            for _, player in ipairs(Players:GetPlayers()) do
                if IsValidTarget(player) then
                    UpdateNametag(player, player.Character, player.Character:FindFirstChildOfClass("Humanoid"))
                else
                    -- Esconde tag se o alvo se tornou inválido (ex: morreu)
                    if nametags[player] then
                        nametags[player].Visible = false
                    end
                end
            end
        end)
    elseif not state and connection then
        connection:Disconnect()
        connection = nil
        ClearNametags()
    end
end

-- ========== ADICIONA O MÓDULO À CATEGORIA VISUAL ==========
local Nametag = Visual:AddModule("🏷️ Nametags", function(state)
    Config.Enabled = state
    ToggleLoop(state)
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
end)

print("✅ Nametag V2 carregado!")

-- Função de limpeza ao remover o script
return function()
    ToggleLoop(false)
end
