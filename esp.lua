-- ========== ESP (Wallhack) MELHORADO V2 ==========
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

-- VARIÁVEIS
local drawings = {}

-- Limpa todos os desenhos de um jogador
local function ClearPlayerDrawings(player)
    if drawings[player] then
        for _, d in ipairs(drawings[player]) do
            d:Remove()
        end
        drawings[player] = nil
    end
end

-- Limpa tudo
local function ClearAllDrawings()
    for player in pairs(drawings) do
        ClearPlayerDrawings(player)
    end
end

-- Mesma função de validação dos outros scripts
local function IsValidTarget(player)
    if not player or player == LocalPlayer then return false end
    
    -- Se estiver na Whitelist, não desenha como inimigo
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
    return humanoid and humanoid.Health > 0 and character:FindFirstChild("HumanoidRootPart")
end

-- Retorna a cor do time
local function GetTeamColor(player)
    if not Config.TeamCheck or not player.Team or not LocalPlayer.Team then
        return Color3.fromRGB(255, 255, 0) -- Amarelo se a checagem estiver desativada
    end
    return player.Team == LocalPlayer.Team and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 80, 80)
end

-- Função principal de desenho
local function UpdateESP()
    -- Limpa desenhos de jogadores que saíram
    for player, _ in pairs(drawings) do
        if not player or not player.Parent then
            ClearPlayerDrawings(player)
        end
    end

    -- Desenha para jogadores válidos
    for _, player in ipairs(Players:GetPlayers()) do
        if IsValidTarget(player) then
            local character = player.Character
            local rootPart = character.HumanoidRootPart
            local head = character:FindFirstChild("Head")
            if not head then continue end
            
            -- Limpa desenhos antigos para recriar
            ClearPlayerDrawings(player)
            drawings[player] = {}

            local color = GetTeamColor(player)

            -- BOX ESP (Caixa)
            if Config.Boxes then
                local size = Vector3.new(4, 6, 2) -- Tamanho aproximado de um personagem
                local cframe = rootPart.CFrame * CFrame.new(0, -1, 0) -- Ajusta a posição da caixa

                local points = {
                    cframe * CFrame.new(size.X/2, size.Y/2, 0).Position,
                    cframe * CFrame.new(size.X/2, -size.Y/2, 0).Position,
                    cframe * CFrame.new(-size.X/2, -size.Y/2, 0).Position,
                    cframe * CFrame.new(-size.X/2, size.Y/2, 0).Position,
                }

                local screenPoints = {}
                local onScreen = true
                for i, point in ipairs(points) do
                    local screenPos, isOnScreen = Camera:WorldToViewportPoint(point)
                    if not isOnScreen then onScreen = false; break end
                    table.insert(screenPoints, Vector2.new(screenPos.X, screenPos.Y))
                end

                if onScreen then
                    local topLeft = screenPoints[4]
                    local bottomRight = screenPoints[2]
                    local boxWidth = math.abs(topLeft.X - bottomRight.X)
                    local boxHeight = math.abs(topLeft.Y - bottomRight.Y)

                    local box = Drawing.new("Square")
                    box.Visible = true
                    box.Color = color
                    box.Thickness = 1
                    box.Size = Vector2.new(boxWidth, boxHeight)
                    box.Position = Vector2.new(topLeft.X, topLeft.Y)
                    box.Filled = false
                    table.insert(drawings[player], box)
                end
            end

            -- TRACERS (Linhas)
            if Config.Tracers then
                local startPos
                if Config.TracerStartPoint == "Top" then
                    startPos = Vector2.new(Camera.ViewportSize.X / 2, 0)
                elseif Config.TracerStartPoint == "Mouse" then
                    startPos = UserInputService:GetMouseLocation()
                else -- Bottom
                    startPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                end
                
                local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local tracer = Drawing.new("Line")
                    tracer.Visible = true
                    tracer.Color = color
                    tracer.Thickness = 1
                    tracer.From = startPos
                    tracer.To = Vector2.new(headPos.X, headPos.Y)
                    table.insert(drawings[player], tracer)
                end
            end
        else
            -- Limpa se o alvo se tornou inválido
            ClearPlayerDrawings(player)
        end
    end
end


-- Loop principal
local connection
local function ToggleLoop(state)
    if state and not connection then
        connection = RunService.RenderStepped:Connect(UpdateESP)
    elseif not state and connection then
        connection:Disconnect()
        connection = nil
        ClearAllDrawings()
    end
end


-- ========== ADICIONA O MÓDULO À CATEGORIA VISUAL ==========
local ESP_Module = Visual:AddModule("👁️ ESP", function(state)
    Config.Enabled = state
    ToggleLoop(state)
end, false)

ESP_Module:AddToggle("📦 Boxes (Caixas)", Config.Boxes, function(state) Config.Boxes = state end)
ESP_Module:AddToggle("📈 Tracers (Linhas)", Config.Tracers, function(state) Config.Tracers = state end)
ESP_Module:AddToggle("👥 Checagem de Time", Config.TeamCheck, function(state) Config.TeamCheck = state end)
ESP_Module:AddDropdown("📍 Ponto do Tracer", {"Bottom", "Top", "Mouse"}, function(val) Config.TracerStartPoint = val end)

print("✅ ESP V2 carregado!")

-- Função de limpeza para quando o script for removido
return function()
    ToggleLoop(false)
end
