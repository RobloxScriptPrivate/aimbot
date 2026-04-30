-- ========== FREECAM V2 ==========
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
    if not LocalPlayer.Character then return end
    
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
    originalCharacter.HumanoidRootPart.Anchored = true
    
    -- Muda a câmera para o char falso
    workspace.CurrentCamera.CameraSubject = fakeCharacter.Humanoid
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
        local newPos = fakeCharacter.HumanoidRootPart.CFrame * CFrame.new(moveVector * (freecamSpeed / 10))
        fakeCharacter.HumanoidRootPart.CFrame = newPos
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
        if originalCharacter and originalCharacter:FindFirstChild("HumanoidRootPart") then
            originalCharacter.HumanoidRootPart.Anchored = false
        end
        if fakeCharacter then
            fakeCharacter:Destroy()
            fakeCharacter = nil
        end
        workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
        originalCharacter = nil
    end
end

-- Adiciona o Módulo à categoria de Movimento
local FreecamModule = Library:CreateSection(MovementCategory, "📷 Freecam")
Library:AddToggle(FreecamModule, "Ativar Freecam", false, toggleFreecam)
Library:AddSlider(FreecamModule, "Velocidade da Freecam", 10, 200, freecamSpeed, function(val) freecamSpeed = val end)

print("✅ Módulo Freecam carregado (v2)!")

-- Função de limpeza
return function()
    toggleFreecam(false) -- Garante que tudo é revertido
end
