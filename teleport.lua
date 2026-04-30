-- ========== TELEPORTE v13 (Instantâneo & Persistente) ==========
local Library, TeleportCategory = ..., select(2, ...)

-- Serviços
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Nome do arquivo de configuração
local CONFIG_FILE = "Manus_Teleports"

-- Carregar posições salvas
local savedPositions = Library:LoadConfig(CONFIG_FILE) or {}

-- Função para teleporte instantâneo (sem rubber-banding)
local function teleportTo(pos)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        -- Zera a velocidade para evitar que o anticheat puxe de volta por momentum
        root.Velocity = Vector3.new(0, 0, 0)
        root.CFrame = pos
        -- Garante que a velocidade continue zero por um frame
        task.wait()
        if root then root.Velocity = Vector3.new(0, 0, 0) end
    end
end

-- Função para adicionar botão de teleporte na UI
local function addTeleportButton(name, pos)
    TeleportCategory:AddModule(name, function()
        teleportTo(pos)
    end, true)
end

-- Carrega os botões salvos na inicialização
for name, data in pairs(savedPositions) do
    -- Converte a tabela de posição de volta para CFrame
    local cf = CFrame.new(unpack(data))
    addTeleportButton(name, cf)
end

-- Função para abrir o gerenciador de criação
local function openTeleportManager()
    local window = Library:CreateWindow("🌌 Novo Ponto", UDim2.new(0, 280, 0, 150))
    local nameInput = window:AddTextBox("Nome do Local...")
    
    window:AddButton("Salvar Posição Atual", function()
        local posName = nameInput.Text
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if posName and #posName > 0 and root then
            local currentCF = root.CFrame
            -- Salva no cache local
            local cfTable = {currentCF:GetComponents()}
            savedPositions[posName] = cfTable
            
            -- Persiste no arquivo JSON
            Library:SaveConfig(CONFIG_FILE, savedPositions)
            
            -- Adiciona o botão na lista
            addTeleportButton(posName, currentCF)
            
            print("✅ Ponto '"..posName.."' salvo permanentemente.")
            window.Frame:Destroy()
        end
    end)
end

-- Botão principal para criar novos pontos
TeleportCategory:AddModule("➕ Criar Novo Ponto", function()
    openTeleportManager()
end, true)

print("✅ Módulo de Teleporte Persistente (v13) carregado.")
