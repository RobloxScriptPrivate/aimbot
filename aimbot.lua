-- ========== AIMBOT DUPLO MELHORADO V2 ==========
local Library, Combat = ..., select(2, ...)

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- CONFIGURAÇÕES
local Config = {
    Enabled = false,
    AimPart = "Head",
    FOV = 250,
    TeamCheck = true,
    ShowFOV = true,
}

-- VARIÁVEIS
local aimingRight = false
local aimingF = false
local lockedTarget = nil
local inputBeganConn = nil
local inputEndedConn = nil
local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
local mouseOverridden = false -- Flag para saber se estamos controlando a câmera

-- Círculo de FOV
local circle = Drawing.new("Circle")
circle.Visible = false
circle.Radius = Config.FOV
circle.Color = Color3.fromRGB(0, 150, 255)
circle.Thickness = 1
circle.Filled = false
circle.Position = screenCenter

-- Função de limpeza para desconectar eventos
local function cleanup()
    circle.Visible = false
    if mouseOverridden then
        RunService:UnbindFromRenderStep("AimbotAim")
        mouseOverridden = false
    end
end

-- Checa se é um inimigo válido
local function IsEnemy(player)
    if not player or player == LocalPlayer or not player:IsA("Player") then return false end
    if Config.TeamCheck and player.Team and player.Team == LocalPlayer.Team then return false end
    local character = player.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

-- Pega a parte do corpo para mirar
local function GetTargetPart(character)
    return character:FindFirstChild(Config.AimPart) or character:FindFirstChild("HumanoidRootPart")
end

-- ENCONTRA O MELHOR ALVO
local function FindBestTarget(isForFKey)
    local bestTarget = nil
    local bestMetric = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if not IsEnemy(player) then continue end
        
        local targetPart = GetTargetPart(player.Character)
        if not targetPart then continue end
        
        local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen or screenPoint.Z <= 0 then continue end
        
        local metric
        if isForFKey then -- Tecla F: Prioriza o mais perto do jogador no mundo 3D
            metric = (LocalPlayer.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude
        else -- Botão Direito: Prioriza o mais perto do centro da tela (cursor)
            metric = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
            if metric > Config.FOV then continue end -- Só considera alvos dentro do círculo
        end

        if metric < bestMetric then
            bestMetric = metric
            bestTarget = player
        end
    end
    return bestTarget
end

-- Função que roda a cada frame para mirar
local function Aim()    
    -- Só continua se tivermos um alvo travado
    if not lockedTarget or not lockedTarget.Parent then
        RunService:UnbindFromRenderStep("AimbotAim")
        mouseOverridden = false
        return
    end

    local targetPart = GetTargetPart(lockedTarget.Character)
    if not targetPart or not IsEnemy(lockedTarget) then
        RunService:UnbindFromRenderStep("AimbotAim")
        mouseOverridden = false
        return
    end

    -- Impede o Roblox de controlar a câmera enquanto miramos
    -- Isso é o que para a câmera de se mover com o mouse
    if not mouseOverridden then
        RunService:BindToRenderStep("AimbotAim", Enum.RenderPriority.Camera.Value + 1, function()
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 0.2) -- Suavização
        end)
        mouseOverridden = true
    end
end

-- Gerencia os inputs do mouse e teclado
local function HandleInput(input, gameProcessed)
    if gameProcessed then return end

    -- ATIVAÇÃO: Botão direito (mira no FOV)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if input.UserInputState == Enum.UserInputState.Begin then
            aimingRight = true
            -- Tenta achar um alvo inicial
            lockedTarget = FindBestTarget(false)
            if lockedTarget then
                Aim() -- Inicia a mira
                circle.Color = Color3.fromRGB(255, 0, 0)
            end
        elseif input.UserInputState == Enum.UserInputState.End then
            aimingRight = false
            lockedTarget = nil
            RunService:UnbindFromRenderStep("AimbotAim") -- Para de mirar
            mouseOverridden = false
            circle.Color = Color3.fromRGB(0, 150, 255)
        end
    end

    -- ATIVAÇÃO: Tecla F (mira no mais próximo)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.F then
        if input.UserInputState == Enum.UserInputState.Begin then
            aimingF = true
            lockedTarget = FindBestTarget(true)
            if lockedTarget then
                Aim() -- Inicia a mira
                if Config.ShowFOV then circle.Color = Color3.fromRGB(255, 100, 0) end
            end
        elseif input.UserInputState == Enum.UserInputState.End then
            aimingF = false
            lockedTarget = nil
            RunService:UnbindFromRenderStep("AimbotAim") -- Para de mirar
            mouseOverridden = false
            if Config.ShowFOV and not aimingRight then circle.Color = Color3.fromRGB(0, 150, 255) end
        end
    end
end


-- Loop para atualizar o alvo do FOV em tempo real (se nenhum alvo já estiver travado)
RunService.RenderStepped:Connect(function()
    if not Config.Enabled then return end

    -- Atualiza centro da tela se a janela mudar de tamanho
    screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    circle.Position = screenCenter

    -- Se o usuário está segurando o botão direito mas AINDA NÃO travou em ninguém,
    -- continua procurando um alvo.
    if aimingRight and not lockedTarget then
        local newTarget = FindBestTarget(false)
        if newTarget then
            lockedTarget = newTarget
            Aim() -- Trava e começa a mirar
            circle.Color = Color3.fromRGB(255, 0, 0)
        end
    end
end)


-- Adiciona o módulo à GUI
local AimbotModule = Combat:AddModule("🎯 Aimbot", function(state)
    Config.Enabled = state
    if state then
        if not inputBeganConn then inputBeganConn = UserInputService.InputBegan:Connect(HandleInput) end
        if not inputEndedConn then inputEndedConn = UserInputService.InputEnded:Connect(HandleInput) end
        if Config.ShowFOV then circle.Visible = true end
    else
        if inputBeganConn then inputBeganConn:Disconnect(); inputBeganConn = nil end
        if inputEndedConn then inputEndedConn:Disconnect(); inputEndedConn = nil end
        cleanup()
    end
end)

AimbotModule:AddToggle("🟢 Mostrar FOV", Config.ShowFOV, function(state)
    Config.ShowFOV = state
    if Config.Enabled then
        circle.Visible = state
    end
end)

AimbotModule:AddToggle("👥 Checagem de Time", Config.TeamCheck, function(state) Config.TeamCheck = state end)

AimbotModule:AddSlider("⭕ Raio do FOV", 50, 500, Config.FOV, function(val) 
    Config.FOV = val 
    circle.Radius = val
end)

AimbotModule:AddDropdown("🎯 Parte do Corpo", {"Head", "Torso", "HumanoidRootPart"}, function(val) Config.AimPart = val end)

print("✅ Aimbot V2 carregado!")

return cleanup