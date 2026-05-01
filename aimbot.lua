-- ========== AIMBOT DUPLO V2.9 (Prioridade por Distância no FOV) ==========
local Library, AimCategory = ..., select(2, ...)

-- Serviços
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera          = workspace.CurrentCamera
local LocalPlayer     = Players.LocalPlayer

-- CONFIGURAÇÕES PADRÃO
local Config = {
    Enabled    = false,
    AimPart    = "Head",
    FOV        = 150,
    TeamCheck  = true,
    ShowFOV    = false,
    ShowPanels = true,
    Smoothing  = 0.9,
    F_KeyMode  = "Pressionar",
}

-- Carrega config salva
local saved = Library:LoadConfig("aimbot")
if saved then
    if type(saved.AimPart)    == "string"  then Config.AimPart    = saved.AimPart    end
    if type(saved.FOV)        == "number"  then Config.FOV        = saved.FOV        end
    if type(saved.TeamCheck)  == "boolean" then Config.TeamCheck  = saved.TeamCheck  end
    if type(saved.ShowFOV)    == "boolean" then Config.ShowFOV    = saved.ShowFOV    end
    if type(saved.ShowPanels) == "boolean" then Config.ShowPanels = saved.ShowPanels end
    if type(saved.Smoothing)  == "number"  then Config.Smoothing  = saved.Smoothing  end
    if type(saved.F_KeyMode)  == "string"  then Config.F_KeyMode  = saved.F_KeyMode  end
end

local function Save()
    Library:SaveConfig("aimbot", {
        AimPart    = Config.AimPart,
        FOV        = Config.FOV,
        TeamCheck  = Config.TeamCheck,
        ShowFOV    = Config.ShowFOV,
        ShowPanels = Config.ShowPanels,
        Smoothing  = Config.Smoothing,
        F_KeyMode  = Config.F_KeyMode,
    })
end

-- VARIÁVEIS DE ESTADO
local aimingRight      = false
local aimingF          = false
local f_key_toggled    = false
local lockedTargetRight = nil
local lockedTargetF    = nil

-- ELEMENTOS VISUAIS
local circle = Drawing.new("Circle")
circle.Color        = Color3.fromRGB(0, 150, 255)
circle.Thickness    = 1.5
circle.Filled       = false
circle.Transparency = 0.7
circle.Visible      = false

local overlayRight = Library:CreateOverlay("TargetRight", "🎯 ALVO FOV (Direito)", Color3.fromRGB(0, 150, 255))
local overlayF     = Library:CreateOverlay("TargetF",     "👑 ALVO PRÓXIMO (Tecla F)", Color3.fromRGB(0, 255, 120))
overlayRight:SetPosition(UDim2.new(0, 20, 0.5, -90))
overlayF:SetPosition(UDim2.new(0, 20, 0.5, 10))

-- FUNÇÕES
local function IsEnemy(player)
    if not player or player == LocalPlayer then return false end
    if Library:IsWhitelisted(player) then return false end
    if not Config.TeamCheck then return true end
    if player.Neutral then return true end
    local myTeam  = LocalPlayer.Team
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

-- NOVA FUNÇÃO: Encontra o alvo mais próximo do JOGADOR que está DENTRO do círculo do FOV
local function GetClosestInFOV()
    local bestTarget, minPlayerDist = nil, math.huge
    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end -- Retorna nulo se nosso próprio personagem não existir

    for _, player in ipairs(Players:GetPlayers()) do
        if IsEnemy(player) and player.Character and IsAlive(player.Character) then
            local targetPart = GetTargetPart(player.Character)
            if targetPart then
                -- Passo 1: O alvo está visível e dentro do círculo do FOV na tela?
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local mouseDistance = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
                    
                    -- Verifica se está dentro do raio do FOV
                    if mouseDistance <= Config.FOV then
                        -- Passo 2: Se sim, este inimigo é o mais próximo do nosso personagem fisicamente?
                        local playerDistance = (localRoot.Position - targetPart.Position).Magnitude
                        if playerDistance < minPlayerDist then
                            minPlayerDist = playerDistance
                            bestTarget = player
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end


local function GetClosestToPlayer()
    local target, minDistance = nil, math.huge
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    for _, player in ipairs(Players:GetPlayers()) do
        if IsEnemy(player) and player.Character and IsAlive(player.Character) then
            local part = GetTargetPart(player.Character)
            if part then
                local dist = (root.Position - part.Position).Magnitude
                if dist < minDistance then minDistance = dist; target = player end
            end
        end
    end
    return target, minDistance
end

-- LOOP PRINCIPAL
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
        circle.Visible  = Config.ShowFOV
        circle.Radius   = Config.FOV
        circle.Position = UserInputService:GetMouseLocation()

        if Config.F_KeyMode == "Alternar" then aimingF = f_key_toggled end

        local function Aim(target)
            if target and target.Character then
                local part = GetTargetPart(target.Character)
                local aimSpeed = Config.Smoothing
                if aimSpeed >= 1 then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
                else
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, part.Position), aimSpeed)
                end
            end
        end

        if aimingRight then
            -- A cada frame, busca o melhor alvo (mais próximo do jogador, dentro do FOV)
            lockedTargetRight = GetClosestInFOV()
            Aim(lockedTargetRight)
        else lockedTargetRight = nil end

        if aimingF then
            lockedTargetF, _ = GetClosestToPlayer()
            Aim(lockedTargetF)
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

-- CONEXÕES DE INPUT
local inputBeganConn = UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimingRight = true
    elseif input.KeyCode == Enum.KeyCode.F then
        if Config.F_KeyMode == "Pressionar" then
            aimingF = true
        else
            f_key_toggled = not f_key_toggled
        end
    end
end)

local inputEndedConn = UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimingRight = false
    elseif input.KeyCode == Enum.KeyCode.F then
        if Config.F_KeyMode == "Pressionar" then aimingF = false end
    end
end)

-- UI
local MainToggle = AimCategory:AddModule("🔥 Aimbot Master", function(state)
    Config.Enabled = state
    if state then StartLoop() end
end, false)

MainToggle:AddToggle("👥 Checar Time", Config.TeamCheck, function(state)
    Config.TeamCheck = state; Save()
end)
MainToggle:AddToggle("👁️ Mostrar FOV", Config.ShowFOV, function(state)
    Config.ShowFOV = state; Save()
end)
MainToggle:AddToggle("📊 Mostrar Painéis", Config.ShowPanels, function(state)
    Config.ShowPanels = state; Save()
end)
MainToggle:AddDropdown("🎯 Parte do Corpo", {"Head", "HumanoidRootPart"}, function(val)
    Config.AimPart = val; Save()
end, Config.AimPart)
MainToggle:AddDropdown(" F Atalho", {"Pressionar", "Alternar"}, function(val)
    Config.F_KeyMode = val; Save()
end, Config.F_KeyMode)
MainToggle:AddSlider("📏 Raio do FOV", 50, 500, Config.FOV, function(val)
    Config.FOV = val; Save()
end)
MainToggle:AddSlider("🌀 Suavização", 1, 10, math.floor(Config.Smoothing * 10), function(val)
    Config.Smoothing = math.clamp(val / 10, 0.1, 1.0)
    Save()
end)

print("✅ Aimbot V2.9 (Prioridade por Distância no FOV) carregado!")

-- CLEANUP
return function()
    Config.Enabled = false
    aimingRight    = false
    aimingF        = false
    f_key_toggled  = false
    if updateConnection then updateConnection:Disconnect(); updateConnection = nil end
    if inputBeganConn then inputBeganConn:Disconnect(); inputBeganConn = nil end
    if inputEndedConn then inputEndedConn:Disconnect(); inputEndedConn = nil end
    pcall(function() circle:Remove() end)
    pcall(function() overlayRight:SetVisible(false) end)
    pcall(function() overlayF:SetVisible(false) end)
end