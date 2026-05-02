-- ========== NAMETAG (Nome + Vida + Distância em Português) V3 (À Prova de Falhas) ==========
local Library, Visual = ..., select(2, ...)

if not Visual then warn("❌ ERRO: Categoria Visual não encontrada para o Nametag."); return function() end end

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

local saved = Library:LoadConfig("nametag")
if saved then
    for key, value in pairs(saved) do
        if type(Config[key]) == type(value) then
            Config[key] = value
        end
    end
end

local function Save()
    Library:SaveConfig("nametag", Config)
end

-- VARIÁVEIS
local nametags = {}

local function GetTeamColor(player)
    if not Config.TeamCheck or not player.Team or not LocalPlayer.Team then
        return Color3.fromRGB(255, 255, 255) -- Branco padrão
    end
    
    return player.Team == LocalPlayer.Team and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 80, 80)
end

local function GetHealthColor(percent)
    return Color3.fromHSV(0.33 * (percent / 100), 1, 1) -- Gradiente de Verde para Vermelho
end

local function UpdateNametag(player, character, humanoid)
    local head = character and character:FindFirstChild("Head")
    -- Adicionada verificação para garantir que a cabeça é uma parte válida do jogo
    if not (head and head:IsA("BasePart")) then
        if nametags[player] then nametags[player].Visible = false end
        return
    end
    
    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.5, 0))
    if not onScreen or screenPos.Z <= 0 then
        if nametags[player] then nametags[player].Visible = false end
        return
    end
    
    local tag = nametags[player]
    if not tag then
        tag = Drawing.new("Text")
        tag.Center = true
        tag.Outline = true
        tag.Font = 2 -- SourceSansBold
        nametags[player] = tag
    end
    
    tag.Size = Config.TextSize
    tag.Visible = true
    
    local texts = {}
    if Config.ShowName then
        table.insert(texts, player.Name)
    end
    
    if Config.ShowHealth then
        local health = math.floor(humanoid.Health)
        table.insert(texts, string.format("❤️ %d", health))
        tag.Color = GetHealthColor((health / humanoid.MaxHealth) * 100)
    else
        tag.Color = GetTeamColor(player)
    end
    
    if Config.ShowDistance then
        local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if localRoot and head then -- Re-usa a 'head' que já sabemos que existe
            local distance = (localRoot.Position - head.Position).Magnitude
            table.insert(texts, string.format("📏 %.0fm", distance))
        end
    end
    
    tag.Text = table.concat(texts, " | ")
    tag.Position = Vector2.new(screenPos.X, screenPos.Y)
end

local function ClearNametags()
    for _, tag in pairs(nametags) do
        if tag and tag.Remove then pcall(tag.Remove, tag) end
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
                if not (player and player.Parent) then
                    pcall(tag.Remove, tag)
                    nametags[player] = nil
                end
            end

            -- Atualiza tags de jogadores válidos, agora dentro de um pcall para evitar congelamentos
            for _, player in ipairs(Players:GetPlayers()) do
                local success, err = pcall(function()
                    if player == LocalPlayer then return end

                    local character = player.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

                    if humanoid and humanoid.Health > 0 then
                        UpdateNametag(player, character, humanoid)
                    else
                        if nametags[player] then
                            nametags[player].Visible = false
                        end
                    end
                end)

                if not success then
                    warn("Nametag Error (Player: " .. tostring(player) .. "):", err)
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
local NametagModule = Visual:AddModule("🏷️ Nametags", function(state)
    Config.Enabled = state; ToggleLoop(state)
end, false)

NametagModule:AddToggle("👥 Mostrar por Time", Config.TeamCheck, function(state) Config.TeamCheck = state; Save() end)
NametagModule:AddToggle("📝 Mostrar Nome", Config.ShowName, function(state) Config.ShowName = state; Save() end)
NametagModule:AddToggle("❤️ Mostrar Vida", Config.ShowHealth, function(state) Config.ShowHealth = state; Save() end)
NametagModule:AddToggle("📏 Mostrar Distância", Config.ShowDistance, function(state) Config.ShowDistance = state; Save() end)
NametagModule:AddSlider("📏 Tamanho do Texto", 10, 20, Config.TextSize, function(value) Config.TextSize = value; Save() end)

print("✅ Nametag V3 (À Prova de Falhas) carregado!")

-- Função de limpeza ao remover o script
return function()
    if connection then connection:Disconnect(); connection = nil end
    ClearNametags()
end
