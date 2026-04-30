-- ========== FREECAM V4 ==========
local Library, MovementCategory = ..., select(2, ...)

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Variáveis
local freecamConnection = nil
local originalCharacter = nil
local fakeCharacter = nil
local freecamSpeed = 50

-- Função para clonar o personagem e prepará-lo para a freecam
local function createFakeCharacter()
    -- VERIFICAÇÃO ADICIONADA: Garante que o personagem existe
    if not LocalPlayer.Character or not LocalPlayer.Character.Parent then return end

    originalCharacter = LocalPlayer.Character
    fakeCharacter = originalCharacter:Clone()
    fakeCharacter.Name = "FreecamCharacter"
    fakeCharacter.Parent = workspace
    -- Deixa o char falso invisível e sem colisão
    for _, part in ipairs(fakeCharacter:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanCollide = false
        end
    end

    -- Prende o char original no lugar
    if originalCharacter:FindFirstChild("HumanoidRootPart") then
      originalCharacter.HumanoidRootPart.Anchored = true
    end

    -- Muda a câmera para o char falso
    workspace.CurrentCamera.CameraSubject = fakeCharacter:FindFirstChildOfClass("Humanoid")
end

-- Função de movimento da freecam
local function freecamLoop()
    local camera = workspace.CurrentCamera
    local moveVector = Vector3.new()

    -- Teclas de movimento
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Vector3.new(0, 0, -1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector + Vector3.new(0, 0, 1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector + Vector3.new(-1, 0, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Vector3.new(1, 0, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVector = moveVector + Vector3.new(0, -1, 0) end

    if fakeCharacter and fakeCharacter:FindFirstChild("HumanoidRootPart") then
        -- Movimento relativo à câmera
        local relativeMove = camera.CFrame:VectorToWorldSpace(moveVector)
        fakeCharacter.HumanoidRootPart.CFrame = fakeCharacter.HumanoidRootPart.CFrame + relativeMove * (freecamSpeed / 10)
    end
end

-- Ativa/Desativa o modo Freecam
local function toggleFreecam(state)
    if state then
        createFakeCharacter()
        if fakeCharacter then
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

-- Adiciona o Módulo à categoria de Movimento, usando a função de toggle como segundo argumento
local FreecamModule = MovementCategory:AddModule("📷 Freecam", toggleFreecam)
FreecamModule:AddSlider("Velocidade da Freecam", 10, 200, freecamSpeed, function(val) freecamSpeed = val end)

print("✅ Módulo Freecam carregado (v4)!")

-- Função de limpeza
return function()
    toggleFreecam(false) -- Garante que tudo é revertido
end
