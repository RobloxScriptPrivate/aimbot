-- ========== AIMBOT DUPLO V3.1 (WallCheck & Drawing Fix) ==========
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
    WallCheck  = true,
    ShowFOV    = false,
    ShowPanels = true,
    Smoothing  = 0.9,
    F_KeyMode  = "Pressionar",
}

-- Carrega config salva
local saved = Library:LoadConfig("aimbot")
if saved then
    for i,v in pairs(saved) do Config[i] = v end
end

local function Save()
    Library:SaveConfig("aimbot", Config)
end

-- VARIÁVEIS DE ESTADO
local aimingRight, aimingF, f_key_toggled = false, false, false
local lockedTargetRight, lockedTargetF = nil, nil

-- ELEMENTOS VISUAIS (COM CORREÇÃO PARA DRAWING)
local circle = {Visible=false} -- Cria uma tabela vazia para evitar erros
local success, result = pcall(function()
    local c = Drawing.new("Circle")
    c.Color=Color3.fromRGB(0,150,255); c.Thickness=1.5; c.Filled=false; c.Transparency=0.7; c.Visible=false
    circle = c -- Somente atribui se a criação for bem sucedida
end)
if not success then print("Aimbot: Objeto 'Drawing' não suportado. O círculo de FOV será desativado.") end

local overlayRight = Library:CreateOverlay("TargetRight","🎯 ALVO FOV (Direito)",Color3.fromRGB(0,150,255))
local overlayF = Library:CreateOverlay("TargetF","👑 ALVO PRÓXIMO (Tecla F)",Color3.fromRGB(0,255,120))
overlayRight:SetPosition(UDim2.new(0,20,0.5,-90)); overlayF:SetPosition(UDim2.new(0,20,0.5,10))

-- PARÂMETROS DO RAYCAST
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

-- FUNÇÕES
local function IsEnemy(player)
    if not player or player==LocalPlayer or Library:IsWhitelisted(player) then return false end
    if not Config.TeamCheck or player.Neutral then return true end
    if player.Team==LocalPlayer.Team or (player.TeamColor==LocalPlayer.TeamColor and LocalPlayer.TeamColor~=nil) then return false end
    return true
end

local function IsAlive(char) local h=char and char:FindFirstChildOfClass("Humanoid"); return h and h.Health>0 end
local function GetTargetPart(char) return char:FindFirstChild(Config.AimPart) or char:FindFirstChild("HumanoidRootPart") end

local function IsVisible(targetPlayer, targetPart)
    if not Config.WallCheck then return true end
    local localCharacter = LocalPlayer.Character
    if not localCharacter then return false end
    raycastParams.FilterDescendantsInstances = {localCharacter, targetPlayer.Character}
    local rayOrigin = Camera.CFrame.Position
    local rayDirection = targetPart.Position - rayOrigin
    local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    return not rayResult
end

local function GetClosestInFOV()
    local bestTarget, minPlayerDist = nil, math.huge
    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if IsEnemy(player) and player.Character and IsAlive(player.Character) then
            local targetPart = GetTargetPart(player.Character)
            if targetPart and IsVisible(player, targetPart) then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local mouseDistance = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if mouseDistance <= Config.FOV then
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
            if part and IsVisible(player, part) then
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

-- LOOP PRINCIPAL
local updateConnection
local function StartLoop()
    if updateConnection then updateConnection:Disconnect() end
    updateConnection = RunService.RenderStepped:Connect(function()
        if not Config.Enabled then circle.Visible=false; overlayRight:SetVisible(false); overlayF:SetVisible(false); return end
        circle.Visible = Config.ShowFOV
        if circle.Radius then circle.Radius = Config.FOV; circle.Position = UserInputService:GetMouseLocation() end

        if Config.F_KeyMode == "Alternar" then aimingF = f_key_toggled end

        local function Aim(target)
            if target and target.Character then
                local part = GetTargetPart(target.Character)
                if not part then return end
                local aimSpeed = Config.Smoothing
                if aimSpeed >= 1 then Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
                else Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, part.Position), aimSpeed) end
            end
        end

        if aimingRight then lockedTargetRight = GetClosestInFOV(); Aim(lockedTargetRight)
        else lockedTargetRight = nil end

        if aimingF then lockedTargetF, _ = GetClosestToPlayer(); Aim(lockedTargetF)
        else lockedTargetF = nil end

        if Config.ShowPanels then
            if lockedTargetRight and lockedTargetRight.Character then local p=GetTargetPart(lockedTargetRight.Character); if p then local d=(Camera.CFrame.Position-p.Position).Magnitude; overlayRight:Update(lockedTargetRight,d,"🎯 FOV Lock") end else overlayRight:SetVisible(false) end
            if lockedTargetF and lockedTargetF.Character then local p=GetTargetPart(lockedTargetF.Character); if p then local d=(Camera.CFrame.Position-p.Position).Magnitude; overlayF:Update(lockedTargetF,d,"👑 Alvo Próximo") end else overlayF:SetVisible(false) end
        else overlayRight:SetVisible(false); overlayF:SetVisible(false) end
    end)
end

-- CONEXÕES DE INPUT
local inputBeganConn = UserInputService.InputBegan:Connect(function(i,p) if p then return end; if i.UserInputType==Enum.UserInputType.MouseButton2 then aimingRight=true elseif i.KeyCode==Enum.KeyCode.F then if Config.F_KeyMode=="Pressionar" then aimingF=true else f_key_toggled=not f_key_toggled end end end)
local inputEndedConn = UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton2 then aimingRight=false elseif i.KeyCode==Enum.KeyCode.F and Config.F_KeyMode=="Pressionar" then aimingF=false end end)

-- UI
local MainToggle = AimCategory:AddModule("🔥 Aimbot Master", function(s) Config.Enabled=s; if s then StartLoop() end end, false)

MainToggle:AddToggle("👥 Checar Time", Config.TeamCheck, function(s) Config.TeamCheck=s; Save() end)
MainToggle:AddToggle("🧱 Checar Paredes", Config.WallCheck, function(s) Config.WallCheck=s; Save() end)
MainToggle:AddToggle("👁️ Mostrar FOV", Config.ShowFOV, function(s) Config.ShowFOV=s; Save() end)
MainToggle:AddToggle("📊 Mostrar Painéis", Config.ShowPanels, function(s) Config.ShowPanels=s; Save() end)
MainToggle:AddDropdown("🎯 Parte do Corpo", {"Head","HumanoidRootPart"}, function(v) Config.AimPart=v; Save() end, Config.AimPart)
MainToggle:AddDropdown(" F Atalho", {"Pressionar","Alternar"}, function(v) Config.F_KeyMode=v; Save() end, Config.F_KeyMode)
MainToggle:AddSlider("📏 Raio do FOV", 50, 500, Config.FOV, function(v) Config.FOV=v; Save() end)
MainToggle:AddSlider("🌀 Suavização", 1, 10, math.floor(Config.Smoothing*10), function(v) Config.Smoothing=math.clamp(v/10,0.1,1.0); Save() end)

print("✅ Aimbot V3.1 (Drawing Fix) carregado!")

-- CLEANUP
return function()
    Config.Enabled=false; aimingRight=false; aimingF=false; f_key_toggled=false
    if updateConnection then updateConnection:Disconnect(); updateConnection=nil end
    if inputBeganConn then inputBeganConn:Disconnect(); inputBeganConn=nil end
    if inputEndedConn then inputEndedConn:Disconnect(); inputEndedConn=nil end
    if circle.Remove then pcall(circle.Remove, circle) end
    pcall(function() overlayRight:SetVisible(false) end)
    pcall(function() overlayF:SetVisible(false) end)
end