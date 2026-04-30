-- ========== ESP SIMPLES (BORDA CONFORME TIME) ==========
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
    OutlineThickness = 2,
    ShowDistance = true,
}

-- VARIÁVEIS
local espObjects = {}  -- Armazena os objetos de ESP
local screenCenter = Vector2.new(0, 0)

-- Cores dos times
local function GetTeamColor(player)
    if not Config.TeamCheck then
        return Color3.fromRGB(255, 255, 255) -- Branco
    end
    
    if not player.Team or not LocalPlayer.Team then
        return Color3.fromRGB(200, 200, 200) -- Cinza claro
    end
    
    if player.Team == LocalPlayer.Team then
        return Color3.fromRGB(0, 255, 0) -- Verde (mesmo time)
    else
        return Color3.fromRGB(255, 0, 0) -- Vermelho (inimigo)
    end
end

-- Verifica se é inimigo (para o ESP)
local function IsValidTarget(player)
    if player == LocalPlayer then return false end
    
    local character = player.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    return true
end

-- Desenha a borda ao redor do personagem
local function DrawOutline(player, color)
    local character = player.Character
    if not character then return end
    
    -- Encontra os limites do personagem
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    local anyVisible = false
    
    -- Percorre todas as partes do personagem
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
    
    -- Adiciona um padding
    local padding = 5
    minX = minX - padding
    minY = minY - padding
    maxX = maxX + padding
    maxY = maxY + padding
    
    -- Cria ou atualiza a borda
    if not espObjects[player] then
        -- Cria uma linha para cada lado do retângulo
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
                line.Color = color
                line.Visible = true
            end
        end
        
        espObjects[player].distance.Color = color
        espObjects[player].distance.Size = 12
        espObjects[player].distance.Outline = true
        espObjects[player].distance.Center = true
        espObjects[player].distance.Font = 2
        espObjects[player].distance.Visible = Config.ShowDistance
    end
    
    -- Atualiza a posição das linhas
    local lines = espObjects[player]
    lines.top.From = Vector2.new(minX, minY)
    lines.top.To = Vector2.new(maxX, minY)
    lines.bottom.From = Vector2.new(minX, maxY)
    lines.bottom.To = Vector2.new(maxX, maxY)
    lines.left.From = Vector2.new(minX, minY)
    lines.left.To = Vector2.new(minX, maxY)
    lines.right.From = Vector2.new(maxX, minY)
    lines.right.To = Vector2.new(maxX, maxY)
    
    -- Atualiza a cor (caso o time mude)
    lines.top.Color = color
    lines.bottom.Color = color
    lines.left.Color = color
    lines.right.Color = color
    
    -- Calcula e mostra distância
    if Config.ShowDistance and character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local distance = (root.Position - character.HumanoidRootPart.Position).Magnitude
            local centerX = (minX + maxX) / 2
            local centerY = (minY + maxY) / 2
            lines.distance.Position = Vector2.new(centerX, maxY + 15)
            lines.distance.Text = string.format("%.1f m", distance)
            lines.distance.Color = color
        end
    end
end

-- Remove todos os ESPs
local function ClearESP()
    for player, objects in pairs(espObjects) do
        for _, obj in pairs(objects) do
            obj:Remove()
        end
    end
    espObjects = {}
end

-- Loop principal do ESP
RunService.RenderStepped:Connect(function()
    if not Config.Enabled then
        ClearESP()
        return
    end
    
    screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    -- Remove ESP de jogadores que saíram ou morreram
    for player in pairs(espObjects) do
        if not IsValidTarget(player) then
            for _, obj in pairs(espObjects[player]) do
                obj:Remove()
            end
            espObjects[player] = nil
        end
    end
    
    -- Desenha ESP para cada jogador válido
    for _, player in ipairs(Players:GetPlayers()) do
        if IsValidTarget(player) then
            local color = GetTeamColor(player)
            DrawOutline(player, color)
        end
    end
end)

-- ========== LIMPEZA ==========
local function Cleanup()
    print("🧹 Removendo ESP...")
    ClearESP()
    print("✅ ESP removido!")
end

-- ========== INTEGRAÇÃO COM A BIBLIOTECA GUI ==========
local Visual = Library:CreateCategory("👁️ Visual", UDim2.new(0, 10, 0, 100))

-- Módulo principal do ESP
local ESP = Visual:AddModule("🎨 ESP (Borda)", function(state)
    Config.Enabled = state
    if not state then
        ClearESP()
    end
    print(state and "✅ ESP Ligado" or "❌ ESP Desligado")
end, false)

-- Configurações do ESP
ESP:AddToggle("👥 Mostrar por Time", Config.TeamCheck, function(state)
    Config.TeamCheck = state
end)

ESP:AddToggle("📏 Mostrar Distância", Config.ShowDistance, function(state)
    Config.ShowDistance = state
    if not state then
        for player, objects in pairs(espObjects) do
            if objects.distance then
                objects.distance.Visible = false
            end
        end
    end
end)

ESP:AddSlider("📏 Espessura da Borda", 1, 5, Config.OutlineThickness, function(value)
    Config.OutlineThickness = value
    for player, objects in pairs(espObjects) do
        for _, line in pairs(objects) do
            if line ~= objects.distance then
                line.Thickness = value
            end
        end
    end
end)

print("✅ Módulo ESP carregado!")

-- Retorna a função de limpeza
return Cleanup
