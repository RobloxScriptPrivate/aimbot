-- ========== AIMBOT DUPLO MELHORADO ==========
local Library = ...

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- CONFIGURAÇÕES
local Config = {
    Enabled = false,
    AimPart = "Head",
    FOV = 250,
    TeamCheck = true,
    ShowFOV = true,        -- Mostrar círculo do FOV
    ShowPanels = true,     -- Mostrar painéis de informação
}

-- VARIÁVEIS
local aimingRight = false    -- Botão Direito (FOV)
local aimingF = false        -- Tecla F (Mais próximo)
local lockedTargetFOV = nil  -- Alvo do FOV
local lockedTargetClose = nil -- Alvo do mais próximo
local screenCenter = Vector2.new(0, 0)
local canMoveCamera = true    -- Permite mover a câmera com o mouse

-- ========== ELEMENTOS VISUAIS ==========
-- Círculo FOV
local circle = Drawing.new("Circle")
circle.Color = Color3.fromRGB(0, 150, 255)
circle.Thickness = 2
circle.Filled = false
circle.Radius = Config.FOV
circle.Visible = false

-- Painéis de informação
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Aimbot_Overlay"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Painel FOV
local panelFOV = Instance.new("Frame")
panelFOV.Size = UDim2.new(0, 280, 0, 85)
panelFOV.Position = UDim2.new(0, 10, 0, 130)
panelFOV.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
panelFOV.BackgroundTransparency = 0.15
panelFOV.BorderSizePixel = 2
panelFOV.BorderColor3 = Color3.fromRGB(0, 150, 255)
panelFOV.Visible = false
panelFOV.Parent = screenGui
Instance.new("UICorner", panelFOV).CornerRadius = UDim.new(0, 10)

local titleFOV = Instance.new("TextLabel")
titleFOV.Size = UDim2.new(1, 0, 0, 22)
titleFOV.Position = UDim2.new(0, 0, 0, 0)
titleFOV.Text = "🎯 ALVO DO FOV (Botão Direito)"
titleFOV.TextColor3 = Color3.fromRGB(0, 150, 255)
titleFOV.TextSize = 11
titleFOV.Font = Enum.Font.GothamBold
titleFOV.BackgroundTransparency = 1
titleFOV.Parent = panelFOV

local avatarFOV = Instance.new("ImageLabel")
avatarFOV.Size = UDim2.new(0, 50, 0, 50)
avatarFOV.Position = UDim2.new(0, 10, 0, 26)
avatarFOV.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
avatarFOV.BackgroundTransparency = 0.5
avatarFOV.Parent = panelFOV
Instance.new("UICorner", avatarFOV).CornerRadius = UDim.new(1, 0)

local nameFOV = Instance.new("TextLabel")
nameFOV.Size = UDim2.new(0, 200, 0, 18)
nameFOV.Position = UDim2.new(0, 70, 0, 28)
nameFOV.Text = "Nenhum"
nameFOV.TextColor3 = Color3.fromRGB(255, 255, 255)
nameFOV.TextSize = 13
nameFOV.Font = Enum.Font.GothamBold
nameFOV.TextXAlignment = Enum.TextXAlignment.Left
nameFOV.BackgroundTransparency = 1
nameFOV.Parent = panelFOV

local displayFOV = Instance.new("TextLabel")
displayFOV.Size = UDim2.new(0, 200, 0, 14)
displayFOV.Position = UDim2.new(0, 70, 0, 46)
displayFOV.Text = ""
displayFOV.TextColor3 = Color3.fromRGB(180, 180, 180)
displayFOV.TextSize = 10
displayFOV.Font = Enum.Font.GothamMedium
displayFOV.TextXAlignment = Enum.TextXAlignment.Left
displayFOV.BackgroundTransparency = 1
displayFOV.Parent = panelFOV

local distFOV = Instance.new("TextLabel")
distFOV.Size = UDim2.new(0, 200, 0, 14)
distFOV.Position = UDim2.new(0, 70, 0, 62)
distFOV.Text = ""
distFOV.TextColor3 = Color3.fromRGB(0, 200, 255)
distFOV.TextSize = 10
distFOV.Font = Enum.Font.GothamMedium
distFOV.TextXAlignment = Enum.TextXAlignment.Left
distFOV.BackgroundTransparency = 1
distFOV.Parent = panelFOV

-- Painel Mais Próximo
local panelClose = Instance.new("Frame")
panelClose.Size = UDim2.new(0, 280, 0, 85)
panelClose.Position = UDim2.new(0, 10, 0, 225)
panelClose.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
panelClose.BackgroundTransparency = 0.15
panelClose.BorderSizePixel = 2
panelClose.BorderColor3 = Color3.fromRGB(0, 255, 100)
panelClose.Visible = false
panelClose.Parent = screenGui
Instance.new("UICorner", panelClose).CornerRadius = UDim.new(0, 10)

local titleClose = Instance.new("TextLabel")
titleClose.Size = UDim2.new(1, 0, 0, 22)
titleClose.Position = UDim2.new(0, 0, 0, 0)
titleClose.Text = "👑 ALVO MAIS PRÓXIMO (Tecla F)"
titleClose.TextColor3 = Color3.fromRGB(0, 255, 100)
titleClose.TextSize = 11
titleClose.Font = Enum.Font.GothamBold
titleClose.BackgroundTransparency = 1
titleClose.Parent = panelClose

local avatarClose = Instance.new("ImageLabel")
avatarClose.Size = UDim2.new(0, 50, 0, 50)
avatarClose.Position = UDim2.new(0, 10, 0, 26)
avatarClose.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
avatarClose.BackgroundTransparency = 0.5
avatarClose.Parent = panelClose
Instance.new("UICorner", avatarClose).CornerRadius = UDim.new(1, 0)

local nameClose = Instance.new("TextLabel")
nameClose.Size = UDim2.new(0, 200, 0, 18)
nameClose.Position = UDim2.new(0, 70, 0, 28)
nameClose.Text = "Nenhum"
nameClose.TextColor3 = Color3.fromRGB(255, 255, 255)
nameClose.TextSize = 13
nameClose.Font = Enum.Font.GothamBold
nameClose.TextXAlignment = Enum.TextXAlignment.Left
nameClose.BackgroundTransparency = 1
nameClose.Parent = panelClose

local displayClose = Instance.new("TextLabel")
displayClose.Size = UDim2.new(0, 200, 0, 14)
displayClose.Position = UDim2.new(0, 70, 0, 46)
displayClose.Text = ""
displayClose.TextColor3 = Color3.fromRGB(180, 180, 180)
displayClose.TextSize = 10
displayClose.Font = Enum.Font.GothamMedium
displayClose.TextXAlignment = Enum.TextXAlignment.Left
displayClose.BackgroundTransparency = 1
displayClose.Parent = panelClose

local distClose = Instance.new("TextLabel")
distClose.Size = UDim2.new(0, 200, 0, 14)
distClose.Position = UDim2.new(0, 70, 0, 62)
distClose.Text = ""
distClose.TextColor3 = Color3.fromRGB(0, 255, 100)
distClose.TextSize = 10
distClose.Font = Enum.Font.GothamMedium
distClose.TextXAlignment = Enum.TextXAlignment.Left
distClose.BackgroundTransparency = 1
distClose.Parent = panelClose

-- ========== FUNÇÕES ==========
local function IsEnemy(player)
    if player == LocalPlayer then return false end
    if not Config.TeamCheck then return true end
    if not player.Team or not LocalPlayer.Team then return true end
    return player.Team ~= LocalPlayer.Team
end

local function IsAlive(character)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function GetTargetPart(character)
    if Config.AimPart == "Head" then
        local head = character:FindFirstChild("Head")
        if head then return head end
    end
    return character:FindFirstChild("HumanoidRootPart")
end

-- ENCONTRA ALVO DENTRO DO FOV (RESPEITANDO O RAIO)
local function FindTargetInFOV()
    local bestTarget = nil
    local bestDistance = Config.FOV + 1
    
    for _, player in ipairs(Players:GetPlayers()) do
        if not IsEnemy(player) then continue end
        
        local character = player.Character
        if not character or not IsAlive(character) then continue end
        
        local targetPart = GetTargetPart(character)
        if not targetPart then continue end
        
        local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen or screenPoint.Z <= 0 then continue end
        
        local fovDistance = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
        
        -- RESPEITA O FOV: só considera se estiver dentro do círculo
        if fovDistance <= Config.FOV and fovDistance < bestDistance then
            bestDistance = fovDistance
            bestTarget = player
        end
    end
    
    return bestTarget
end

-- ENCONTRA O ALVO MAIS PRÓXIMO (distância real, IGNORA FOV)
local function FindClosestTarget()
    local closestTarget = nil
    local closestDistance = math.huge
    
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if not IsEnemy(player) then continue end
        
        local character = player.Character
        if not character or not IsAlive(character) then continue end
        
        local targetPart = GetTargetPart(character)
        if not targetPart then continue end
        
        local realDistance = (root.Position - targetPart.Position).Magnitude
        
        if realDistance < closestDistance then
            closestDistance = realDistance
            closestTarget = player
        end
    end
    
    return closestTarget, closestDistance
end

-- ATUALIZA PAINEL DO FOV
local function UpdatePanelFOV(target, distance)
    if not Config.ShowPanels then
        panelFOV.Visible = false
        return
    end
    
    if not target then
        panelFOV.Visible = false
        return
    end
    
    panelFOV.Visible = true
    nameFOV.Text = target.Name
    displayFOV.Text = "@" .. target.Name
    if distance then
        distFOV.Text = "📏 " .. string.format("%.1f", distance) .. " metros"
    end
    
    local userId = target.UserId
    local thumbnail = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    avatarFOV.Image = thumbnail
end

-- ATUALIZA PAINEL DO MAIS PRÓXIMO
local function UpdatePanelClose(target, distance)
    if not Config.ShowPanels then
        panelClose.Visible = false
        return
    end
    
    if not target then
        panelClose.Visible = false
        return
    end
    
    panelClose.Visible = true
    nameClose.Text = target.Name
    displayClose.Text = "@" .. target.Name
    if distance then
        distClose.Text = "📏 " .. string.format("%.1f", distance) .. " metros"
    end
    
    local userId = target.UserId
    local thumbnail = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    avatarClose.Image = thumbnail
end

-- MIRA NO ALVO (sem perder controle do mouse)
local function AimAt(target)
    if not target or not target.Character then return end
    
    local targetPart = GetTargetPart(target.Character)
    if not targetPart then return end
    
    -- Salva a posição atual da câmera
    local currentPos = Camera.CFrame.Position
    
    -- Aplica a mira suavemente (mas ainda permite mover o mouse)
    local newCFrame = CFrame.new(currentPos, targetPart.Position)
    Camera.CFrame = newCFrame
end

-- VERIFICA SE ALVO AINDA É VÁLIDO
local function IsTargetValid(target)
    if not target or not target.Character then return false end
    if not IsAlive(target.Character) then return false end
    return true
end

-- ========== BOTÃO DIREITO (MÉTODO QUE NÃO TRAVA O MOUSE) ==========
local function onRightClick(actionName, inputState, inputObject)
    if not Config.Enabled then return end
    
    if inputState == Enum.UserInputState.Begin then
        aimingRight = true
        canMoveCamera = false  -- Desativa movimento da câmera com mouse (opcional)
        
        local target = FindTargetInFOV()
        if target then
            lockedTargetFOV = target
            AimAt(lockedTargetFOV)
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local dist = root and (root.Position - lockedTargetFOV.Character.Head.Position).Magnitude or nil
            UpdatePanelFOV(lockedTargetFOV, dist)
            if Config.ShowFOV then
                circle.Color = Color3.fromRGB(0, 255, 0)
            end
        else
            lockedTargetFOV = nil
            panelFOV.Visible = false
        end
        
    elseif inputState == Enum.UserInputState.End then
        aimingRight = false
        canMoveCamera = true  -- Reativa movimento da câmera
        lockedTargetFOV = nil
        panelFOV.Visible = false
        if not aimingF and Config.ShowFOV then
            circle.Color = Color3.fromRGB(0, 150, 255)
        end
    end
end

-- ========== TECLA F = MIRA MAIS PRÓXIMO (TOGGLE) ==========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not Config.Enabled then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        if aimingF then
            aimingF = false
            lockedTargetClose = nil
            panelClose.Visible = false
            if not aimingRight and Config.ShowFOV then
                circle.Color = Color3.fromRGB(0, 150, 255)
            end
        else
            aimingF = true
            aimingRight = false  -- Desativa o FOV se ativar o Mais Próximo
            local target, dist = FindClosestTarget()
            if target then
                lockedTargetClose = target
                AimAt(lockedTargetClose)
                UpdatePanelClose(lockedTargetClose, dist)
                if Config.ShowFOV then
                    circle.Color = Color3.fromRGB(0, 255, 100)
                end
            else
                lockedTargetClose = nil
                panelClose.Visible = false
            end
        end
    end
end)

-- ========== LOOP PRINCIPAL ==========
RunService.RenderStepped:Connect(function()
    screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    -- Atualiza círculo do FOV
    if Config.ShowFOV then
        circle.Position = screenCenter
        circle.Radius = Config.FOV
        circle.Visible = Config.Enabled
    else
        circle.Visible = false
    end
    
    if not Config.Enabled then return end
    
    -- MIRA DO FOV (Botão Direito)
    if aimingRight then
        if lockedTargetFOV and IsTargetValid(lockedTargetFOV) then
            AimAt(lockedTargetFOV)
            
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root and lockedTargetFOV.Character then
                local targetPart = GetTargetPart(lockedTargetFOV.Character)
                if targetPart then
                    local dist = (root.Position - targetPart.Position).Magnitude
                    if Config.ShowPanels then
                        distFOV.Text = "📏 " .. string.format("%.1f", dist) .. " metros"
                    end
                end
            end
        elseif lockedTargetFOV and not IsTargetValid(lockedTargetFOV) then
            local newTarget = FindTargetInFOV()
            if newTarget then
                lockedTargetFOV = newTarget
                AimAt(lockedTargetFOV)
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local dist = root and (root.Position - lockedTargetFOV.Character.Head.Position).Magnitude or nil
                UpdatePanelFOV(lockedTargetFOV, dist)
            else
                lockedTargetFOV = nil
                panelFOV.Visible = false
            end
        end
    end
    
    -- MIRA DO MAIS PRÓXIMO (Tecla F)
    if aimingF and not aimingRight then
        if lockedTargetClose and IsTargetValid(lockedTargetClose) then
            AimAt(lockedTargetClose)
            
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root and lockedTargetClose.Character then
                local targetPart = GetTargetPart(lockedTargetClose.Character)
                if targetPart then
                    local dist = (root.Position - targetPart.Position).Magnitude
                    if Config.ShowPanels then
                        distClose.Text = "📏 " .. string.format("%.1f", dist) .. " metros"
                    end
                end
            end
        elseif lockedTargetClose and not IsTargetValid(lockedTargetClose) then
            local newTarget, newDist = FindClosestTarget()
            if newTarget then
                lockedTargetClose = newTarget
                AimAt(lockedTargetClose)
                UpdatePanelClose(lockedTargetClose, newDist)
            else
                lockedTargetClose = nil
                panelClose.Visible = false
            end
        end
    end
end)

-- ========== LIMPEZA ==========
local function Cleanup()
    print("🧹 Removendo aimbot...")
    
    Config.Enabled = false
    aimingRight = false
    aimingF = false
    lockedTargetFOV = nil
    lockedTargetClose = nil
    
    ContextActionService:UnbindAction("AimbotRight")
    
    if circle then circle:Remove() end
    if screenGui then screenGui:Destroy() end
    
    print("✅ Aimbot completamente removido!")
end

-- ========== INTEGRAÇÃO COM A BIBLIOTECA GUI ==========
local Combat = Library:CreateCategory("⚔️ Combat", UDim2.new(0, 10, 0, 60))

-- Módulo principal
local Aimbot = Combat:AddModule("🎯 Aimbot", function(state)
    Config.Enabled = state
    
    if Config.Enabled then
        if Config.ShowFOV then circle.Visible = true end
        ContextActionService:BindActionAtPriority("AimbotRight", onRightClick, false, 1000, Enum.UserInputType.MouseButton2)
    else
        circle.Visible = false
        aimingRight = false
        aimingF = false
        lockedTargetFOV = nil
        lockedTargetClose = nil
        panelFOV.Visible = false
        panelClose.Visible = false
        ContextActionService:UnbindAction("AimbotRight")
    end
end, false)

-- Configurações
Aimbot:AddSlider("🔵 Raio do FOV", 50, 400, Config.FOV, function(value)
    Config.FOV = value
    if circle then circle.Radius = value end
end)

Aimbot:AddDropdown("🎯 Parte do corpo", {"Head", "HumanoidRootPart"}, function(selected)
    Config.AimPart = selected
end)

Aimbot:AddToggle("👥 Verificar Time", Config.TeamCheck, function(state)
    Config.TeamCheck = state
end)

-- NOVAS SUB-OPÇÕES
Aimbot:AddToggle("👁️ Mostrar Círculo FOV", Config.ShowFOV, function(state)
    Config.ShowFOV = state
    if not Config.Enabled then return end
    circle.Visible = state
    if state then
        circle.Color = aimingRight and Color3.fromRGB(0, 255, 0) or (aimingF and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(0, 150, 255))
    end
end)

Aimbot:AddToggle("📊 Mostrar Painéis", Config.ShowPanels, function(state)
    Config.ShowPanels = state
    if not state then
        panelFOV.Visible = false
        panelClose.Visible = false
    elseif Config.Enabled then
        if lockedTargetFOV then UpdatePanelFOV(lockedTargetFOV) end
        if lockedTargetClose then UpdatePanelClose(lockedTargetClose) end
    end
end)

-- Botão de remover completo
Aimbot:AddModule("🗑️ Remover Script", function()
    Cleanup()
    local guiLib = LocalPlayer.PlayerGui:FindFirstChild("ManusGuiLib")
    if guiLib then guiLib:Destroy() end
end, true)

print("✅ Aimbot carregado! Pressione INSERT para abrir o menu")

-- Retorna a função de limpeza
return Cleanup
