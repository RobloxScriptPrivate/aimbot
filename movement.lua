-- ========== MOVIMENTO (Speed, Noclip, Fly) V3 ==========
local Library, MovementCategory = ..., select(2, ...)

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Variáveis Locais
local originalWalkSpeed = 16
local noclipConnection = nil
local flyConnection = nil
local flyVelocity = nil

-- Garante que temos o personagem e a velocidade original
if LocalPlayer.Character then
    originalWalkSpeed = LocalPlayer.Character.Humanoid.WalkSpeed
end
LocalPlayer.CharacterAdded:Connect(function(char)
    originalWalkSpeed = char.Humanoid.WalkSpeed
end)

-- ========== MÓDULO: SPEED HACK ==========
local SpeedModule = MovementCategory:AddModule("🏃 Velocidade")
SpeedModule:AddSlider("Velocidade do Personagem", 16, 200, originalWalkSpeed, function(value)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
end)

-- ========== MÓDULO: NOCLIP ==========
local function toggleNoclip(state)
    if state then
        if noclipConnection then noclipConnection:Disconnect() end -- Evita múltiplas conexões
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
local NoclipModule = MovementCategory:AddModule("👻 Noclip (Atravessar)")
NoclipModule:AddToggle("Ativar Noclip", false, toggleNoclip)

-- ========== MÓDULO: FLY ==========
local flyKeys = {
    Forward = Enum.KeyCode.W,
    Backward = Enum.KeyCode.S,
    Left = Enum.KeyCode.A,
    Right = Enum.KeyCode.D,
    Up = Enum.KeyCode.Space,
    Down = Enum.KeyCode.LeftControl
}
local flySpeed = 50

local function toggleFly(state)
    if state then
        if flyConnection then flyConnection:Disconnect() end -- Limpeza

        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end

        flyVelocity = Instance.new("BodyVelocity", char.HumanoidRootPart)
        flyVelocity.MaxForce = Vector3.new(1, 1, 1) * 1e6
        flyVelocity.Velocity = Vector3.new(0, 0, 0)

        flyConnection = RunService.RenderStepped:Connect(function()
            local cameraCF = workspace.CurrentCamera.CFrame
            local moveVector = Vector3.new(0, 0, 0)

            if UserInputService:IsKeyDown(flyKeys.Forward) then moveVector = moveVector + cameraCF.LookVector end
            if UserInputService:IsKeyDown(flyKeys.Backward) then moveVector = moveVector - cameraCF.LookVector end
            if UserInputService:IsKeyDown(flyKeys.Right) then moveVector = moveVector + cameraCF.RightVector end
            if UserInputService:IsKeyDown(flyKeys.Left) then moveVector = moveVector - cameraCF.RightVector end
            if UserInputService:IsKeyDown(flyKeys.Up) then moveVector = moveVector + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(flyKeys.Down) then moveVector = moveVector - Vector3.new(0, 1, 0) end

            if flyVelocity and flyVelocity.Parent then
                if moveVector.Magnitude > 0 then
                    flyVelocity.Velocity = moveVector.Unit * flySpeed
                else
                    flyVelocity.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end)
    else
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        if flyVelocity then
            flyVelocity:Destroy()
            flyVelocity = nil
        end
    end
end

local FlyModule = MovementCategory:AddModule("✈️ Fly (Voar)")
FlyModule:AddToggle("Ativar Voo", false, toggleFly)
FlyModule:AddSlider("Velocidade do Voo", 50, 500, flySpeed, function(val) flySpeed = val end)

print("✅ Módulos de Movimento carregados (v3)!")

-- Função de limpeza geral para o módulo de movimento
return function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = originalWalkSpeed
    end
    toggleNoclip(false)
    toggleFly(false)
end
