-- ========== TELEPORTE V5 (Padrão Aimbot) ==========
local Library, TeleportCategory = ..., select(2, ...)

-- Serviços
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Tabela para guardar os checkpoints
local savedCheckpoints = {}
local teleportModule = nil -- Placeholder para o módulo da GUI

-- Função para abrir o menu de salvar checkpoint
local function openSaveMenu()
    -- Se o módulo não foi criado ainda, não faz nada.
    if not teleportModule then return end

    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    if playerGui:FindFirstChild("CheckpointSaveMenu") then return end

    -- (O código da GUI para o menu de salvar permanece o mesmo)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CheckpointSaveMenu"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.Parent = playerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 250, 0, 140)
    mainFrame.Position = UDim2.new(0.5, -125, 0.5, -70)
    mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = Color3.fromRGB(80, 80, 90)
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 25)
    titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    titleBar.Parent = mainFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.Text = "Salvar Checkpoint"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.SourceSansBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextOffset = Vector2.new(10, 0)
    title.BackgroundTransparency = 1
    title.Parent = titleBar

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -23, 0, 2.5)
    closeButton.Text = "X"
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = titleBar
    closeButton.MouseButton1Click:Connect(function() screenGui:Destroy() end)

    local nameBox = Instance.new("TextBox")
    nameBox.Size = UDim2.new(1, -20, 0, 30)
    nameBox.Position = UDim2.new(0, 10, 0, 40)
    nameBox.PlaceholderText = "Nome do local"
    nameBox.Font = Enum.Font.SourceSans
    nameBox.Parent = mainFrame

    local saveButton = Instance.new("TextButton")
    saveButton.Size = UDim2.new(1, -20, 0, 40)
    saveButton.Position = UDim2.new(0, 10, 0, 85)
    saveButton.Text = "💾 Salvar Posição Atual"
    saveButton.BackgroundColor3 = Color3.fromRGB(80, 150, 80)
    saveButton.Font = Enum.Font.SourceSansBold
    saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveButton.Parent = mainFrame

    saveButton.MouseButton1Click:Connect(function()
        local name = nameBox.Text
        if name and name:gsub(" ", "") ~= "" and not savedCheckpoints[name] then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local pos = LocalPlayer.Character.HumanoidRootPart.CFrame
                savedCheckpoints[name] = pos
                -- Adiciona o botão ao módulo principal
                teleportModule:AddButton("🚀 TP > " .. name, function()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = pos
                    end
                end)
                screenGui:Destroy()
            end
        end
    end)
end

-- CRIAÇÃO DO MÓDULO PRINCIPAL (seguindo o padrão do aimbot.lua)
-- A função de toggle principal apenas ativa/desativa o módulo, não precisa fazer nada a mais.
teleportModule = TeleportCategory:AddModule("🚀 Teleporte Custom", function(state)
    -- A lógica é controlada pelos botões, então o toggle principal pode não fazer nada.
end)

-- Adiciona o botão de salvar ao módulo principal
teleportModule:AddButton("📌 Salvar Ponto Atual", openSaveMenu)

print("✅ Módulo de Teleporte carregado (v5)!")

-- Função de limpeza
return function()
    local playerGui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local menu = playerGui:FindFirstChild("CheckpointSaveMenu")
        if menu then
            menu:Destroy()
        end
    end
end
