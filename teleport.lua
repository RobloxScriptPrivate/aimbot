-- ========== TELEPORTE v11 (API de Janelas Reutilizável) ==========
local Library, TeleportCategory = ..., select(2, ...)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local savedPositions = {}
local teleportWindow = nil

-- Função principal para abrir e gerenciar a janela de teleporte
local function openTeleportManager()
    -- Se a janela já existe, não faça nada. A função CreateWindow já lida com isso.
    if Library.ActiveWindows["🌌 Teleporte"] then return end

    -- 1. Criar a janela usando a nova API
    teleportWindow = Library:CreateWindow("🌌 Teleporte", UDim2.new(0, 300, 0, 400), UDim2.new(0.5, -150, 0.5, -200))

    -- Container para a lista de posições salvas
    local listContainer = Instance.new("ScrollingFrame")
    listContainer.Name = "ListContainer"
    listContainer.Size = UDim2.new(0.9, 0, 1, -120) -- Espaço para os controles abaixo
    listContainer.Position = UDim2.new(0.05, 0, 0, 110)
    listContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    listContainer.BorderSizePixel = 1
    listContainer.BorderColor3 = Color3.fromRGB(50,50,50)
    listContainer.Parent = teleportWindow.Content
    Instance.new("UIListLayout", listContainer).Padding = UDim.new(0, 3)
    
    -- Função para redesenhar a lista de botões
    local function redrawList()
        for _, child in ipairs(listContainer:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("Frame") then child:Destroy() end
        end
        
        for i, data in ipairs(savedPositions) do
            local positionFrame = Instance.new("Frame")
            positionFrame.Size = UDim2.new(1, 0, 0, 30)
            positionFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            positionFrame.Parent = listContainer

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0.7, 0, 1, 0)
            nameLabel.Text = "  "..data.name
            nameLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
            nameLabel.Font = Enum.Font.SourceSans
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.BackgroundTransparency = 1
            nameLabel.Parent = positionFrame
            
            local deleteBtn = Instance.new("TextButton")
            deleteBtn.Size = UDim2.new(0.15, 0, 0.8, 0)
            deleteBtn.Position = UDim2.new(0.82, 0, 0.1, 0)
            deleteBtn.Text = "X"
            deleteBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
            deleteBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            deleteBtn.Parent = positionFrame
            deleteBtn.MouseButton1Click:Connect(function()
                table.remove(savedPositions, i)
                redrawList()
            end)

            nameLabel.InputBegan:connect(function(input) 
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                     if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = data.pos
                        print("Teleportado para", data.name)
                    end
                end
            end)
        end
        listContainer.CanvasSize = UDim2.new(0, 0, 0, #listContainer:GetChildren() * 33)
    end

    -- 2. Adicionar os componentes na janela
    local nameInput = teleportWindow:AddTextBox("Nome do Ponto")
    local saveButton = teleportWindow:AddButton("Salvar Posição Atual", function()
        local posName = nameInput.Text
        if posName and #posName > 0 and LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart then
            -- Verifica se o nome já existe
            local exists = false
            for _, data in ipairs(savedPositions) do
                if data.name == posName then exists = true; break; end
            end
            
            if not exists then
                table.insert(savedPositions, {name = posName, pos = LocalPlayer.Character.HumanoidRootPart.CFrame})
                nameInput.Text = "" -- Limpa o campo
                redrawList() -- Atualiza a lista visual
            else
                warn("Um ponto com o nome '"..posName.."' já existe.")
            end
        end
    end)

    -- 3. Adiciona um botão de gatilho na categoria de Teleporte para abrir esta janela
    redrawList() -- Desenha a lista inicial
end

-- Cria o módulo que abre a janela de teleporte
local teleportModule = TeleportCategory:AddModule("Gerenciar Pontos", function()
    openTeleportManager()
end, true) -- true para ser um gatilho (trigger)

print("✅ Módulo de Teleporte (v11) carregado.")

-- Função de limpeza é chamada quando o script é removido
return function()
    if teleportWindow and teleportWindow.Frame and teleportWindow.Frame.Parent then
        teleportWindow.Frame:Destroy()
    end
    print("🧼 Módulo de Teleporte limpo.")
end
