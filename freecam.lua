-- ========== FREECAM V5 (Padrão Aimbot) ==========
local Library, MovementCategory = ..., select(2, ...)

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Variáveis
local freecamEnabled = false
local freecamConnection = nil
local originalCharacter = nil
local fakeCharacter = nil
local freecamSpeed = 50

-- Função para clonar o personagem
local function createFakeCharacter()
    if not LocalPlayer.Character or not LocalPlayer.Character.Parent then return end

    originalCharacter = LocalPlayer.Character
    fakeCharacter = originalCharacter:Clone()
    fakeCharacter.Name = "FreecamCharacter"
    fakeCharacter.Parent = workspace
    for _, part in ipairs(fakeCharacter:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanCollide = false
        end
    end

    if originalCharacter:FindFirstChild("HumanoidRootPart") then
      originalCharacter.HumanoidRootPart.Anchored = true
    end
    workspace.CurrentCamera.CameraSubject = fakeCharacter:FindFirstChildOfClass("Humanoid")
end

-- Loop de movimento
local function freecamLoop()
    local camera = workspace.CurrentCamera
    local moveVector = Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Vector3.new(0, 0, -1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector + Vector3.new(0, 0, 1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector + Vector3.new(-1, 0, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Vector3.new(1, 0, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVector = moveVector + Vector3.new(0, -1, 0) end

    if fakeCharacter and fakeCharacter:FindFirstChild("HumanoidRootPart") then
        local relativeMove = camera.CFrame:VectorToWorldSpace(moveVector)
        fakeCharacter.HumanoidRootPart.CFrame = fakeCharacter.HumanoidRootP art.CFrame + relativeMove * (freecamSpeed / 10)
    end
end

-- Ativa/Desativa o modo Freecam
local function toggleFreecam(state)
    freecamEnabled = state
    if freecamEnabled then
        createFakeCharacter()
        if fakeCharacter then -- Apenas conecta o loop se o personagem falso foi criado
            freecamConnection = RunService.RenderStepped:Connect(freecamLoop)
        end
    else
        if freecamConnection then
            freecamConnection:Disconnect()
            freecamConnection = nil
        end
        if originalCharacter and originalCharacter.Parent and originalCharacter:FindFirstChild("HumanoidRootPart") then
            workspace.CurrentCamera.CameraSubject = originalCharacter:FindFirstChildOfClass("Humanoid")
            originalCharacter.HumanoidRootPart.Anchored = false
        end
        if fakeCharacter then
            fakeCharacter:Destroy()
            fakeCharacter = nil
        end
        originalCharacter = nil
    end
end

-- CRIAÇÃO DO MÓDULO E CONTROLES (Padrão Aimbot)
local FreecamModule = MovementCategory:AddModule("📷 Freecam", toggleFreecam)

FreecamModule:AddSlider("Velocidade da Freecam", 10, 200, freecamSpeed, function(val) freecamSpeed = val end)

print("✅ Módulo Freecam carregado (v5)!")

-- Função de limpeza
return function()
    toggleFreecam(false)
end
