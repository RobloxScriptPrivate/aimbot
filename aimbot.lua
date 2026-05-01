-- ========== AIMBOT DUPLO V2.6 (Modo de Atalho Configurável) ==========
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
    Smoothing = 0.2,
    F_KeyMode = "Pressionar", -- Novo: "Pressionar" ou "Alternar"
}

-- VARIÁVEIS DE ESTADO
local aimingRight = false
local aimingF = false
local f_key_toggled = false -- Novo: Estado de toggle para a tecla F
local lockedTargetRight = nil
local lockedTargetF = nil

-- ELEMENTOS VISUAIS
local circle = Drawing.new("Circle")
circle.Color = Color3.fromRGB(0, 150, 255)
circle.Thickness = 1.5
circle.Filled = false
circle.Transparency = 0.7
circle.Visible = false

local overlayRight = Library:CreateOverlay("TargetRight", "🎯 ALVO FOV (Direito)", Color3.fromRGB(0, 150, 255))
local overlayF = Library:CreateOverlay("TargetF", "👑 ALVO PRÓXIMO (Tecla F)", Color3.fromRGB(0, 255, 120))
overlayRight:SetPosition(UDim2.new(0, 20, 0.5, -90))
overlayF:SetPosition(UDim2.new(0, 20, 0.5, 10))

-- FUNÇÕES
local function IsEnemy(player)
    if not player or player == LocalPlayer then return false end
    if Library:IsWhitelisted(player) then return false end
    if not Config.TeamCheck then return true end
    if player.Neutral then return true end
    
    local myTeam = LocalPlayer.Team
    local myColor = LocalPlayer.TeamColor
    if player.Team == myTeam or (player.TeamColor == myColor and myColor ~= nil) then
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
        circle.Visible = Config.ShowFOV
        circle.Radius = Config.FOV
        circle.Position = UserInputService:GetMouseLocation()

        -- Atualiza o estado de mira da tecla F baseado no modo
        if Config.F_KeyMode == "Alternar" then
            aimingF = f_key_toggled
        end

        if aimingRight then
            if not (lockedTargetRight and IsEnemy(lockedTargetRight) and lockedTargetRight.Character and IsAlive(lockedTargetRight.Character)) then
                lockedTargetRight = GetClosestToMouse()
            end
            if lockedTargetRight and lockedTargetRight.Character then
                local part = GetTargetPart(lockedTargetRight.Character)
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, part.Position), Config.Smoothing)
            end
        else lockedTargetRight = nil end

        if aimingF then
            local currentClosest = GetClosestToPlayer()
            lockedTargetF = currentClosest
            if lockedTargetF and lockedTargetF.Character then
                local part = GetTargetPart(lockedTargetF.Character)
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, part.Position), Config.Smoothing)
            end
        else lockedTargetF = nil end

        if Config.ShowPanels then
            if lockedTargetRight then
                local part = GetTargetPart(lockedTargetRight.Character)
                local dist = (Camera.CFrame.Position - part.Position).Magnitude
                overlayRight:Update(lockedTargetRight, dist, "🎯 FOV Lock")
            else overlayRight:SetVisible(false) end
            if lockedTargetF then
                local dist = (Camera.CFrame.Position - GetTargetPart(lockedTargetF.Character).Position).Magnitude
                overlayF:Update(lockedTargetF, dist, "👑 Alvo Próximo")
            else overlayF:SetVisible(false) end
        else
            overlayRight:SetVisible(false)
            overlayF:SetVisible(false)
        end
    end)
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then aimingRight = true
    elseif input.KeyCode == Enum.KeyCode.F then
        if Config.F_KeyMode == "Pressionar" then
            aimingF = true
        else -- Modo Alternar
            f_key_toggled = not f_key_toggled
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then aimingRight = false
    elseif input.KeyCode == Enum.KeyCode.F then
        if Config.F_KeyMode == "Pressionar" then
            aimingF = false
        end
    end
end)

-- UI CATEGORY (ORDEM ORGANIZADA)
local MainToggle = AimCategory:AddModule("🔥 Aimbot Master", function(state)
    Config.Enabled = state
    if state then StartLoop() end
end, false)

-- 1. TOGGLES
MainToggle:AddToggle("👥 Checar Time", Config.TeamCheck, function(state) Config.TeamCheck = state end)
MainToggle:AddToggle("👁️ Mostrar FOV", Config.ShowFOV, function(state) Config.ShowFOV = state end)
MainToggle:AddToggle("📊 Mostrar Painéis", Config.ShowPanels, function(state) Config.ShowPanels = state end)

-- 2. DROPDOWNS
MainToggle:AddDropdown("🎯 Parte do Corpo", {"Head", "HumanoidRootPart"}, function(val) Config.AimPart = val end)
MainToggle:AddDropdown(" F Atalho", {"Pressionar", "Alternar"}, function(val) Config.F_KeyMode = val end)

-- 3. SLIDERS
MainToggle:AddSlider("📏 Raio do FOV", 50, 500, Config.FOV, function(val) Config.FOV = val end)
MainToggle:AddSlider("🌀 Suavização", 1, 10, 2, function(val) Config.Smoothing = val/10 end)

print("✅ Aimbot V2.6 (GUI V6.0) carregado!")
return function()
    if updateConnection then updateConnection:Disconnect(); updateConnection = nil end
    -- Remove o círculo de FOV (Drawing object) da tela
    circle:Remove()
end
