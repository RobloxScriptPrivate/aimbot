-- ========== AIMBOT DUPLO V2.2 (Rastreamento Contínuo & TeamCheck Avançado) ==========
local Library, AimCategory = ..., select(2, ...)

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
    FOV = 150,
    TeamCheck = true,
    ShowFOV = true,
    ShowPanels = true,
    Smoothing = 0.2, -- Suavização da mira
}

-- VARIÁVEIS DE ESTADO
local aimingRight = false    -- Botão Direito (FOV)
local aimingF = false        -- Tecla F (Mais Próximo)
local lockedTargetRight = nil
local lockedTargetF = nil

-- ELEMENTOS VISUAIS (FOV)
local circle = Drawing.new("Circle")
circle.Color = Color3.fromRGB(0, 150, 255)
circle.Thickness = 1.5
circle.Filled = false
circle.Transparency = 0.7
circle.Visible = false

-- PAINÉIS DE ALVO (Via Library Overlay)
local overlayRight = Library:CreateOverlay("TargetRight", "🎯 ALVO FOV (Direito)", Color3.fromRGB(0, 150, 255))
local overlayF = Library:CreateOverlay("TargetF", "👑 ALVO PRÓXIMO (Tecla F)", Color3.fromRGB(0, 255, 120))

-- Posicionamento inicial dos painéis
overlayRight:SetPosition(UDim2.new(0, 20, 0.5, -90))
overlayF:SetPosition(UDim2.new(0, 20, 0.5, 10))

-- FUNÇÕES DE VALIDAÇÃO
local function IsEnemy(player)
    if not player or player == LocalPlayer then return false end
    if not Config.TeamCheck then return true end
    
    if player.Neutral then return true end
    
    local myTeam = LocalPlayer.Team
    local myColor = LocalPlayer.TeamColor
    local targetTeam = player.Team
    local targetColor = player.TeamColor
    
    if targetTeam == myTeam or (targetColor == myColor and myColor ~= nil) then
        return false
    end
    
    return true
end

local function IsAlive(character)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function GetTargetPart(character)
    return character:FindFirstChild(Config.AimPart) or character:FindFirstChild("HumanoidRootPart")
end

-- ENCONTRAR ALVO NO FOV (ESTRITO)
local function GetClosestToMouse()
    local target = nil
    local minDistance = Config.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if IsEnemy(player) and player.Character and IsAlive(player.Character) then
            local part = GetTargetPart(player.Character)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local mouseDistance = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if mouseDistance < minDistance then
                        minDistance = mouseDistance
                        target = player
                    end
                end
            end
        end
    end
    return target
end

-- ENCONTRAR ALVO MAIS PRÓXIMO (DISTÂNCIA REAL - MUNDO)
local function GetClosestToPlayer()
    local target = nil
    local minDistance = math.huge
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not root then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if IsEnemy(player) and player.Character and IsAlive(player.Character) then
            local part = GetTargetPart(player.Character)
            if part then
                local dist = (root.Position - part.Position).Magnitude
                if dist < minDistance then
                    minDistance = dist
                    target = player
                end
            end
        end
    end
    return target, minDistance
end

-- LOOP DE ATUALIZAÇÃO (RenderStepped para mira suave e contínua)
local updateConnection
local function StartLoop()
    if updateConnection then updateConnection:Disconnect() end
    
    updateConnection = RunService.RenderStepped:Connect(function()
        if not Config.Enabled then
            circle.Visible = false
            overlayRight:SetVisible(false)
            overlayF:SetVisible(false)
            return
        end

        -- Atualiza Círculo FOV
        circle.Visible = Config.ShowFOV
        circle.Radius = Config.FOV
        circle.Position = UserInputService:GetMouseLocation()

        -- LÓGICA DO BOTÃO DIREITO (FOV)
        if aimingRight then
            -- Se já temos um alvo e ele ainda é válido, mantemos. Senão, procuramos o melhor.
            if not (lockedTargetRight and IsEnemy(lockedTargetRight) and lockedTargetRight.Character and IsAlive(lockedTargetRight.Character)) then
                lockedTargetRight = GetClosestToMouse()
            end
            
            if lockedTargetRight and lockedTargetRight.Character then
                local part = GetTargetPart(lockedTargetRight.Character)
                local targetCF = CFrame.new(Camera.CFrame.Position, part.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, Config.Smoothing)
            end
        else
            lockedTargetRight = nil
        end

        -- LÓGICA DA TECLA F (MAIS PRÓXIMO - RASTREAMENTO CONTÍNUO)
        if aimingF then
            -- Para o F, sempre buscamos o mais próximo a cada frame para garantir que ele mude de alvo se outro chegar mais perto
            local currentClosest, dist = GetClosestToPlayer()
            lockedTargetF = currentClosest
            
            if lockedTargetF and lockedTargetF.Character then
                local part = GetTargetPart(lockedTargetF.Character)
                local targetCF = CFrame.new(Camera.CFrame.Position, part.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, Config.Smoothing)
            end
        else
            lockedTargetF = nil
        end

        -- ATUALIZAÇÃO DOS PAINÉIS
        if Config.ShowPanels then
            if lockedTargetRight then
                local part = GetTargetPart(lockedTargetRight.Character)
                local dist = (Camera.CFrame.Position - part.Position).Magnitude
                overlayRight:Update(lockedTargetRight, dist, "🎯 FOV Lock")
            else
                overlayRight:SetVisible(false)
            end

            if lockedTargetF then
                local part = GetTargetPart(lockedTargetF.Character)
                local dist = (Camera.CFrame.Position - part.Position).Magnitude
                overlayF:Update(lockedTargetF, dist, "👑 Alvo Próximo")
            else
                overlayF:SetVisible(false)
            end
        else
            overlayRight:SetVisible(false)
            overlayF:SetVisible(false)
        end
    end)
end

-- INPUTS (Uso de InputBegan/Ended para detectar quando as teclas são seguradas)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimingRight = true
    elseif input.KeyCode == Enum.KeyCode.F then
        aimingF = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimingRight = false
    elseif input.KeyCode == Enum.KeyCode.F then
        aimingF = false
    end
end)

-- CATEGORIA NA UI
local MainToggle = AimCategory:AddModule("🔥 Aimbot Master", function(state)
    Config.Enabled = state
    if state then StartLoop() end
end, false)

MainToggle:AddToggle("👁️ Mostrar FOV", Config.ShowFOV, function(state) Config.ShowFOV = state end)
MainToggle:AddToggle("📊 Mostrar Painéis", Config.ShowPanels, function(state) Config.ShowPanels = state end)
MainToggle:AddToggle("👥 Checar Time", Config.TeamCheck, function(state) Config.TeamCheck = state end)

MainToggle:AddSlider("📏 Raio do FOV", 50, 500, Config.FOV, function(val) Config.FOV = val end)
MainToggle:AddSlider("🌀 Suavização", 1, 10, 2, function(val) Config.Smoothing = val/10 end)

MainToggle:AddDropdown("🎯 Parte do Corpo", {"Head", "HumanoidRootPart"}, function(val)
    Config.AimPart = val
end)

print("✅ Aimbot V2.2 (F Rastreamento Contínuo) carregado!")
return function() if updateConnection then updateConnection:Disconnect() end end
