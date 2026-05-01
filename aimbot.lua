-- ========== AIMBOT DUPLO V3.0 (WallCheck Otimizado) ==========
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
    WallCheck  = true, -- NOVO: Checagem de paredes
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
    if type(saved.WallCheck)  == "boolean" then Config.WallCheck  = saved.WallCheck  end
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
        WallCheck  = Config.WallCheck,
        ShowFOV    = Config.ShowFOV,
        ShowPanels = Config.ShowPanels,
        Smoothing  = Config.Smoothing,
        F_KeyMode  = Config.F_KeyMode,
    })
end

-- VARIÁVEIS DE ESTADO
local aimingRight, aimingF, f_key_toggled = false, false, false
local lockedTargetRight, lockedTargetF = nil, nil

-- ELEMENTOS VISUAIS
local circle = Drawing.new("Circle"); circle.Color=Color3.fromRGB(0,150,255); circle.Thickness=1.5; circle.Filled=false; circle.Transparency=0.7; circle.Visible=false
local overlayRight = Library:CreateOverlay("TargetRight","🎯 ALVO FOV (Direito)",Color3.fromRGB(0,150,255))
local overlayF = Library:CreateOverlay("TargetF","👑 ALVO PRÓXIMO (Tecla F)",Color3.fromRGB(0,255,120))
overlayRight:SetPosition(UDim2.new(0,20,0.5,-90)); overlayF:SetPosition(UDim2.new(0,20,0.5,10))

-- PARÂMETROS DO RAYCAST (para não recriar a cada frame)
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

-- Função de Checagem de Parede Otimizada
local function IsVisible(targetPlayer, targetPart)
    if not Config.WallCheck then return true end -- Se a checagem estiver desligada, considera sempre visível

    local localCharacter = LocalPlayer.Character
    if not localCharacter then return false end

    raycastParams.FilterDescendantsInstances = {localCharacter, targetPlayer.Character} -- Ignora o nosso personagem e o do alvo
    
    local rayOrigin = Camera.CFrame.Position
    local rayDirection = targetPart.Position - rayOrigin
    local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    -- Se rayResult for nil, o caminho está livre. Se não for nil, algo está no caminho.
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
        circle.Visible, circle.Radius, circle.Position = Config.ShowFOV, Config.FOV, UserInputService:GetMouseLocation()

        if Config.F_KeyMode == "Alternar" then aimingF = f_key_toggled end

        local function Aim(target)
            if target and target.Character then
                local part = GetTargetPart(target.Character)
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
            if lockedTargetRight then local p=GetTargetPart(lockedTargetRight.Character); local d=(Camera.CFrame.Position-p.Position).Magnitude; overlayRight:Update(lockedTargetRight,d,"🎯 FOV Lock") else overlayRight:SetVisible(false) end
            if lockedTargetF then local p=GetTargetPart(lockedTargetF.Character); local d=(Camera.CFrame.Position-p.Position).Magnitude; overlayF:Update(lockedTargetF,d,"👑 Alvo Próximo") else overlayF:SetVisible(false) end
        else overlayRight:SetVisible(false); overlayF:SetVisible(false) end
    end)
end

-- CONEXÕES DE INPUT
local inputBeganConn = UserInputService.InputBegan:Connect(function(i,p) if p then return end; if i.UserInputType==Enum.UserInputType.MouseButton2 then aimingRight=true elseif i.KeyCode==Enum.KeyCode.F then if Config.F_KeyMode=="Pressionar" then aimingF=true else f_key_toggled=not f_key_toggled end end end)
local inputEndedConn = UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton2 then aimingRight=false elseif i.KeyCode==Enum.KeyCode.F and Config.F_KeyMode=="Pressionar" then aimingF=false end end)

-- UI
local MainToggle = AimCategory:AddModule("🔥 Aimbot Master", function(s) Config.Enabled=s; if s then StartLoop() end end, false)

MainToggle:AddToggle("👥 Checar Time", Config.TeamCheck, function(s) Config.TeamCheck=s; Save() end)
MainToggle:AddToggle("🧱 Checar Paredes", Config.WallCheck, function(s) Config.WallCheck=s; Save() end) -- NOVO
MainToggle:AddToggle("👁️ Mostrar FOV", Config.ShowFOV, function(s) Config.ShowFOV=s; Save() end)
MainToggle:AddToggle("📊 Mostrar Painéis", Config.ShowPanels, function(s) Config.ShowPanels=s; Save() end)
MainToggle:AddDropdown("🎯 Parte do Corpo", {"Head","HumanoidRootPart"}, function(v) Config.AimPart=v; Save() end, Config.AimPart)
MainToggle:AddDropdown(" F Atalho", {"Pressionar","Alternar"}, function(v) Config.F_KeyMode=v; Save() end, Config.F_KeyMode)
MainToggle:AddSlider("📏 Raio do FOV", 50, 500, Config.FOV, function(v) Config.FOV=v; Save() end)
MainToggle:AddSlider("🌀 Suavização", 1, 10, math.floor(Config.Smoothing*10), function(v) Config.Smoothing=math.clamp(v/10,0.1,1.0); Save() end)

print("✅ Aimbot V3.0 (WallCheck) carregado!")

-- CLEANUP
return function()
    Config.Enabled=false; aimingRight=false; aimingF=false; f_key_toggled=false
    if updateConnection then updateConnection:Disconnect(); updateConnection=nil end
    if inputBeganConn then inputBeganConn:Disconnect(); inputBeganConn=nil end
    if inputEndedConn then inputEndedConn:Disconnect(); inputEndedConn=nil end
    pcall(function() circle:Remove() end)
    pcall(function() overlayRight:SetVisible(false) end)
    pcall(function() overlayF:SetVisible(false) end)
end