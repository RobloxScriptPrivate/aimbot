-- ========== AIMBOT DUPLO V2.0 (FOV Estrito & Painéis Dinâmicos) ==========
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
}

-- VARIÁVEIS DE ESTADO
local aimingRight = false    -- Botão Direito
local aimingF = false        -- Tecla F
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
    return character:FindFirstChild(Config.AimPart) or character:FindFirstChild("HumanoidRootPart")
end

-- ENCONTRAR ALVO NO FOV (ESTRITO)
local function GetClosestToMouse()
    local target = nil
    local minDistance = Config.FOV -- Respeita o limite do FOV

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

-- ENCONTRAR ALVO MAIS PRÓXIMO (DISTÂNCIA REAL)
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

-- LOOP DE ATUALIZAÇÃO
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

        -- Lógica Botão Direito (FOV)
        if aimingRight then
            lockedTargetRight = GetClosestToMouse()
            if lockedTargetRight and lockedTargetRight.Character then
                local part = GetTargetPart(lockedTargetRight.Character)
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
            end
        else
            lockedTargetRight = nil
        end

        -- Lógica Tecla F (Próximo)
        if aimingF then
            lockedTargetF = GetClosestToPlayer()
            if lockedTargetF and lockedTargetF.Character then
                local part = GetTargetPart(lockedTargetF.Character)
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
            end
        else
            lockedTargetF = nil
        end

        -- Atualiza Painéis
        if Config.ShowPanels then
            if lockedTargetRight then
                local part = GetTargetPart(lockedTargetRight.Character)
                local dist = (Camera.CFrame.Position - part.Position).Magnitude
                overlayRight:Update(lockedTargetRight, dist, "🎯 Alvo Travado")
            else
                overlayRight:SetVisible(false)
            end

            if lockedTargetF then
                local target, dist = GetClosestToPlayer()
                overlayF:Update(lockedTargetF, dist, "👑 Prioridade Máxima")
            else
                overlayF:SetVisible(false)
            end
        else
            overlayRight:SetVisible(false)
            overlayF:SetVisible(false)
        end
    end)
end

-- INPUTS
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

-- UI CATEGORY
local MainToggle = AimCategory:AddModule("🔥 Aimbot Master", function(state)
    Config.Enabled = state
    if state then StartLoop() end
end, false)

MainToggle:AddToggle("👁️ Mostrar FOV", Config.ShowFOV, function(state) Config.ShowFOV = state end)
MainToggle:AddToggle("📊 Mostrar Painéis", Config.ShowPanels, function(state) Config.ShowPanels = state end)
MainToggle:AddToggle("👥 Checar Time", Config.TeamCheck, function(state) Config.TeamCheck = state end)

MainToggle:AddSlider("📏 Raio do FOV", 50, 500, Config.FOV, function(val) Config.FOV = val end)

MainToggle:AddDropdown("🎯 Parte do Corpo", {"Head", "HumanoidRootPart"}, function(val)
    Config.AimPart = val
end)

print("✅ Aimbot V2.0 (FOV Estrito) carregado!")
return function() if updateConnection then updateConnection:Disconnect() end end
