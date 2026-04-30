-- ========== MOVIMENTO v9 (Módulos Separados Re-implementado) ==========
local Library, MovementCategory = ..., select(2, ...)

-- Serviços e Variáveis Locais
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local flyConnection = nil
local noclipConnection = nil
local freecamConnection = nil -- Conexão para o Freecam

-- ==================
-- MÓDULO DE FLY
-- ==================
local flyModule = MovementCategory:AddModule("✈️ Fly", function(enabled)
    if enabled then
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end

        local rootPart = char.HumanoidRootPart
        local bodyGyro = Instance.new("BodyGyro", rootPart)
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.D = 100
        bodyGyro.P = 10000
        
        local bodyVelocity = Instance.new("BodyVelocity", rootPart)
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        
        local speed = 50 -- Velocidade padrão do fly

        flyConnection = RunService.RenderStepped:Connect(function()
            local cameraCF = workspace.CurrentCamera.CFrame
            bodyGyro.CFrame = cameraCF

            local moveVector = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Vector3.new(0, 0, -1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector + Vector3.new(0, 0, 1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - cameraCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + cameraCF.RightVector end

            if moveVector.Magnitude > 0 then
                bodyVelocity.Velocity = cameraCF:VectorToWorldSpace(moveVector.Unit) * speed
            else
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        end)
    else
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local rootPart = char.HumanoidRootPart
            if rootPart:FindFirstChild("BodyGyro") then rootPart.BodyGyro:Destroy() end
            if rootPart:FindFirstChild("BodyVelocity") then rootPart.BodyVelocity:Destroy() end
        end
    end
end)

-- ===================
-- MÓDULO DE NOCLIP
-- ===================
local noclipModule = MovementCategory:AddModule("👻 Noclip", function(enabled)
    if enabled then
        noclipConnection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
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
end)

-- ===================
-- MÓDULO DE FREECAM
-- ===================
local freecamModule = MovementCategory:AddModule("📷 Freecam", function(enabled)
    local camera = workspace.CurrentCamera
    local originalCamSubject = camera.CameraSubject

    if enabled then
        camera.CameraType = Enum.CameraType.Scriptable
        local moveSpeed = 5

        freecamConnection = RunService.RenderStepped:Connect(function()
            local moveVector = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Vector3.new(0,0,-1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector + Vector3.new(0,0,1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector + Vector3.new(-1,0,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Vector3.new(1,0,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveVector = moveVector + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveVector = moveVector + Vector3.new(0,-1,0) end

            camera.CFrame = camera.CFrame * CFrame.new(moveVector * moveSpeed)
        end)
    else
        if freecamConnection then
            freecamConnection:Disconnect()
            freecamConnection = nil
        end
        camera.CameraType = Enum.CameraType.Custom
        camera.CameraSubject = originalCamSubject
    end
end)

print("✅ Módulos de Movimento (Fly, Noclip, Freecam) carregados separadamente.")

-- Função de limpeza para parar todos os modos
return function()
    if flyConnection then flyConnection:Disconnect() end
    if noclipConnection then noclipConnection:Disconnect() end
    if freecamConnection then freecamConnection:Disconnect() end
    
    -- Limpeza do Fly
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local rootPart = char.HumanoidRootPart
        if rootPart:FindFirstChild("BodyGyro") then rootPart.BodyGyro:Destroy() end
        if rootPart:FindFirstChild("BodyVelocity") then rootPart.BodyVelocity:Destroy() end
    end

    -- Limpeza do Freecam
    local camera = workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")

    print("🧼 Módulos de Movimento limpos.")
end
