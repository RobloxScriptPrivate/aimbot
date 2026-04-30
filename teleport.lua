-- ========== TELEPORTE V6 (Dropdown) ==========
local Library, TeleportCategory = ..., select(2, ...)

-- Serviços
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Variáveis
local savedCheckpoints = {} -- Tabela para mapear Nome -> CFrame
local checkpointNames = {}  -- Tabela para as opções do Dropdown

-- Função de teleporte chamada pelo dropdown
local function doTeleport(name)
    if savedCheckpoints[name] then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = savedCheckpoints[name]
        end
    end
end

-- Função para abrir o menu de salvar checkpoint
local function openSaveMenu()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    if playerGui:FindFirstChild("CheckpointSaveMenu") then return end

    -- O código da GUI para o menu de salvar (caixa de texto, etc.) permanece o mesmo
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

                -- Se a lista estava com o placeholder, limpa antes de adicionar o primeiro item real
                if #checkpointNames == 1 and checkpointNames[1] == "<Nenhum>" then
                    table.remove(checkpointNames, 1)
                end
                table.insert(checkpointNames, name)

                print("Checkpoint '" .. name .. "' salvo! O dropdown foi atualizado.")
                screenGui:Destroy()
            end
        end
    end)
end

-- CRIAÇÃO DO MÓDULO E CONTROLES
local teleportModule = TeleportCategory:AddModule("🚀 Teleporte Custom", function(state)
    -- O toggle principal não precisa fazer nada
end)

-- Adiciona o botão para ABRIR o menu de salvar
teleportModule:AddButton("📌 Salvar Ponto Atual", openSaveMenu)

-- Inicializa a lista com um placeholder se estiver vazia
if #checkpointNames == 0 then
    table.insert(checkpointNames, "<Nenhum>")
end

-- Adiciona o dropdown que usa a tabela checkpointNames. A GUI deve atualizar
-- automaticamente quando a tabela for modificada.
teleportModule:AddDropdown("🚀 Teleportar para", checkpointNames, doTeleport)

print("✅ Módulo de Teleporte carregado (v6)!")

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
