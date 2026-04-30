-- ========== FREECAM V1 ==========
local Library, MovementCategory = ..., select(2, ...)

-- Serviços
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Variáveis
local freecamActive = false
local freecamConnection = nil
local originalCamSubject = nil
local originalCamType = nil
local characterAnchor = nil

-- Função para ativar/desativar a Freecam
local function toggleFreecam(state)
    freecamActive = state
    local char = LocalPlayer.Character
    local cam = workspace.CurrentCamera

    if state then
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            warn("Freecam requer um personagem.")
            return
        end

        -- Salva o estado original da câmera
        originalCamSubject = cam.CameraSubject
        originalCamType = cam.CameraType
        cam.CameraType = Enum.CameraType.Scriptable

        -- "Ancora" o personagem no local
        characterAnchor = char.HumanoidRootPart.CFrame

        -- Conexão para mover a câmera
        freecamConnection = RunService.RenderStepped:Connect(function()
            if not freecamActive then return end

            -- Mantém o personagem no lugar
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = characterAnchor
            end

            -- Move a câmera
            local moveSpeed = 5 -- Ajuste se necessário
            local moveVector = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector - Vector3.new(0, 0, 1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector + Vector3.new(0, 0, 1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - Vector3.new(1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Vector3.new(1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVector = moveVector - Vector3.new(0, 1, 0) end

            cam.CFrame = cam.CFrame * CFrame.new(moveVector * moveSpeed)
        end)

    else
        -- Desativa a Freecam
        if freecamConnection then
            freecamConnection:Disconnect()
            freecamConnection = nil
        end

        -- Restaura a câmera
        if originalCamSubject and originalCamType then
            cam.CameraType = originalCamType
            cam.CameraSubject = originalCamSubject
        end
        characterAnchor = nil
    end
end

-- Adiciona o botão ao menu
MovementCategory:AddToggle("📷 Freecam", false, toggleFreecam)

print("✅ Módulo Freecam carregado!")

-- Função de limpeza
return function()
    toggleFreecam(false)
end
