-- ========== TELEPORTE v10 (Usando a nova API de Janelas) ==========
local Library, TeleportCategory = ..., select(2, ...)

-- Serviços e Variáveis Locais
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Tabela para armazenar os checkpoints
local savedCheckpoints = {}

-- Referência para a nossa janela de teleporte, para não criar múltiplas
local teleportWindow = nil

-- Função para abrir (ou focar) a janela de gerenciamento de checkpoints
local function openCheckpointWindow()
    -- Se a janela já existe, apenas a traga para a frente (ou não faça nada)
    if teleportWindow and teleportWindow.Frame and teleportWindow.Frame.Parent then
        return
    end

    -- Cria a janela usando a nova API do gui.lua
    teleportWindow = Library:CreateWindow("📌 Checkpoints", UDim2.new(0, 220, 0, 300))

    -- Frame com scroll para a lista de checkpoints
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, -80) -- Deixa espaço para os controles abaixo
    scrollFrame.Position = UDim2.new(0, 0, 0, 80)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35) -- Cor um pouco mais escura para contraste
    scrollFrame.BorderSizePixel = 0
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = teleportWindow.Content

    local listLayout = Instance.new("UIListLayout", scrollFrame)
    listLayout.Padding = UDim.new(0, 3)

    -- Função para redesenhar os botões na lista de scroll
    local function redrawCheckpointButtons()
        -- Limpa a lista antiga
        for _, child in ipairs(scrollFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        -- Adiciona um botão para cada checkpoint salvo
        for _, data in ipairs(savedCheckpoints) do
            local btn = Instance.new("TextButton")
            btn.Name = "Checkpoint_" .. data.name
            btn.Text = "-> " .. data.name
            btn.Size = UDim2.new(1, -10, 0, 25)
            btn.Position = UDim2.new(0, 5, 0, 0) -- Posição é gerenciada pelo UIListLayout
            btn.BackgroundColor3 = Library.Theme.Module
            btn.TextColor3 = Library.Theme.TextInactive
            btn.Font = Library.Theme.Font
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = scrollFrame

            btn.MouseButton1Click:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = data.pos
                    print("Teleportado para", data.name)
                end
            end)
        end
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #savedCheckpoints * (25 + listLayout.Padding.Offset))
    end

    -- Adiciona os controles à janela usando a API
    local nameBox = teleportWindow:AddTextBox("Nome do Ponto", function(text)
        -- A lógica de salvar foi movida para o botão para mais controle
    end)

    local saveBtn = teleportWindow:AddButton("💾 Salvar Posição", function()
        local name = nameBox.Text
        if name and name:gsub(" ", "") ~= "" and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local exists = false
            for _, data in ipairs(savedCheckpoints) do
                if data.name == name then exists = true; break; end
            end
            if not exists then
                table.insert(savedCheckpoints, {name = name, pos = LocalPlayer.Character.HumanoidRootPart.CFrame})
                redrawCheckpointButtons() 
                nameBox.Text = ""
            end
        end
    end)
    saveBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 80) -- Cor verde para salvar

    -- Coloca a lista de scroll no final
    scrollFrame.LayoutOrder = 3
    nameBox.LayoutOrder = 1
    saveBtn.LayoutOrder = 2

    -- Desenha os botões iniciais
    redrawCheckpointButtons()
end

-- Adiciona o botão ÚNICO que abre a janela de checkpoints
TeleportCategory:AddModule("🌌 Teleporte", function() end, true) -- Definido como Trigger
    :AddButton("Abrir Menu de Checkpoints", openCheckpointWindow)


print("✅ Módulo de Teleporte (v10) com API de Janela carregado.")

-- Função de limpeza
return function()
    if teleportWindow and teleportWindow.Frame and teleportWindow.Frame.Parent then
        teleportWindow.Frame:Destroy()
    end
    print("🧼 Módulo de Teleporte limpo.")
end
