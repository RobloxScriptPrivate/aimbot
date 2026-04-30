-- ========== MOVIMENTO V5 (Padrão Aimbot) ==========
local Library, MovementCategory = ..., select(2, ...)

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Variáveis
local originalWalkSpeed = 16
local noclipEnabled = false
local flyEnabled = false
local flySpeed = 50

local noclipConnection, flyConnection, flyVelocity = nil, nil, nil

-- Garante que temos a velocidade original
local function getOriginalSpeed()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        originalWalkSpeed = LocalPlayer.Character.Humanoid.WalkSpeed
    end
end
getOriginalSpeed()
LocalPlayer.CharacterAdded:Connect(function(char)
    getOriginalSpeed()
    if noclipEnabled then -- Re-aplica o noclip no novo personagem
        toggleNoclip(true, true)
    end
    if flyEnabled then -- Re-aplica o fly no novo personagem
        toggleFly(true, true)
    end
end)


-- LÓGICA DAS FUNÇÕES

local function toggleNoclip(state, force)
    if not force then noclipEnabled = state end

    if noclipEnabled then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end

local flyKeys = { F = Enum.KeyCode.W, B = Enum.KeyCode.S, L = Enum.KeyCode.A, R = Enum.KeyCode.D, U = Enum.KeyCode.Space, D = Enum.KeyCode.LeftControl }

local function toggleFly(state, force)
    if not force then flyEnabled = state end

    local char = LocalPlayer.Character
    if flyEnabled and char and char:FindFirstChild("HumanoidRootPart") then
        if flyConnection then flyConnection:Disconnect() end
        if flyVelocity then flyVelocity:Destroy() end

        flyVelocity = Instance.new("BodyVelocity", char.HumanoidRootPart)
        flyVelocity.MaxForce = Vector3.new(1, 1, 1) * 1e7
        flyVelocity.Velocity = Vector3.new(0, 0, 0)

        flyConnection = RunService.RenderStepped:Connect(function()
            local camCF = workspace.CurrentCamera.CFrame
            local move = Vector3.new()
            if UserInputService:IsKeyDown(flyKeys.F) then move = move + camCF.LookVector end
            if UserInputService:IsKeyDown(flyKeys.B) then move = move - camCF.LookVector end
            if UserInputService:IsKeyDown(flyKeys.R) then move = move + camCF.RightVector end
            if UserInputService:IsKeyDown(flyKeys.L) then move = move - camCF.RightVector end
            if UserInputService:IsKeyDown(flyKeys.U) then move = move + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(flyKeys.D) then move = move - Vector3.new(0, 1, 0) end

            if flyVelocity and flyVelocity.Parent then
                flyVelocity.Velocity = (move.Magnitude > 0 and move.Unit * flySpeed or Vector3.new(0,0,0))
            end
        end)
    else
        if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
        if flyVelocity then flyVelocity:Destroy(); flyVelocity = nil end
    end
end


-- CRIAÇÃO DO MÓDULO E CONTROLES (Padrão Aimbot)

-- O Toggle principal do módulo não faz nada, é só um container.
local MovementModule = MovementCategory:AddModule("🏃 Movimento Geral", function(state) end)

MovementModule:AddToggle("👻 Noclip", false, toggleNoclip)
MovementModule:AddToggle("✈️ Fly", false, toggleFly)

MovementModule:AddSlider("Velocidade do Personagem", 16, 200, originalWalkSpeed, function(val)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end)

MovementModule:AddSlider("Velocidade do Voo", 50, 500, flySpeed, function(val) flySpeed = val end)


print("✅ Módulo de Movimento carregado (v5)!")

-- Função de limpeza geral
return function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = originalWalkSpeed
    end
    toggleNoclip(false)
    toggleFly(false)
end
