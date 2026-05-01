-- ========== TELEPORTE v15.1 (Cache Busting) ==========
local Library, TeleportCategory = ..., select(2, ...)

-- Serviços
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CurrentPlaceId = tostring(game.PlaceId)

-- Configuração
local CONFIG_FILE = "Manus_Teleports_V4" -- ARQUIVO ATUALIZADO PARA FORÇAR RE-LEITURA
local allSavedPositions = Library:LoadConfig(CONFIG_FILE) or {}

-- Garante que o container para o mapa atual exista e seja uma tabela (array)
if not allSavedPositions[CurrentPlaceId] or type(allSavedPositions[CurrentPlaceId]) ~= 'table' then
    allSavedPositions[CurrentPlaceId] = {}
end
local currentMapPositions = allSavedPositions[CurrentPlaceId] -- é uma array
local teleportModules = {} -- Rastreia os módulos da UI para poder limpar

-- Função para teleporte
local function teleportTo(pos)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.Velocity = Vector3.new(0, 0, 0)
        root.CFrame = pos
        task.wait()
        if root then root.Velocity = Vector3.new(0, 0, 0) end
    end
end

-- Função para redesenhar todos os botões de teleporte
local function refreshTeleportUI()
    -- Limpa os módulos antigos da UI
    for _, module in ipairs(teleportModules) do
        if module and module.Destroy then
            module:Destroy()
        end
    end
    teleportModules = {}

    -- Cria novos módulos na ordem correta (a tabela já está ordenada)
    for i, data in ipairs(currentMapPositions) do
        local name = data.name
        local posData = data.position
        local cf = CFrame.new(unpack(posData))

        -- Adiciona o botão principal de teleporte
        local module = TeleportCategory:AddModule(name, function()
            teleportTo(cf)
        end)

        -- Adiciona a sub-opção "Remover"
        module:AddButton("Remover", function()
            table.remove(currentMapPositions, i) -- Remove da lista local
            Library:SaveConfig(CONFIG_FILE, allSavedPositions) -- Salva a estrutura principal que foi modificada
            print("❌ Ponto '"..name.."' removido.")
            refreshTeleportUI() -- Redesenha a UI para refletir a remoção
        end)
        
        -- Adiciona o novo módulo à lista de rastreamento
        table.insert(teleportModules, module)
    end
end

-- Função para abrir a janela de criação de ponto
local function openTeleportManager()
    local window = Library:CreateWindow("🌌 Novo Ponto", UDim2.new(0, 280, 0, 150))
    local nameInput = window:AddTextBox("Nome do Local...")
    
    window:AddButton("Salvar Posição Atual", function()
        local posName = nameInput.Text
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if posName and #posName > 0 and root then
            local newPoint = {
                name = posName,
                position = {root.CFrame:GetComponents()}
            }
            -- Adiciona no topo da lista
            table.insert(currentMapPositions, 1, newPoint)
            
            -- Salva a configuração global no arquivo
            Library:SaveConfig(CONFIG_FILE, allSavedPositions)
            
            print("✅ Ponto '"..posName.."' salvo permanentemente.")
            window.Frame:Destroy()
            
            -- Redesenha a UI com o novo ponto no topo
            refreshTeleportUI()
        end
    end)
end

-- Botão principal para criar novos pontos
TeleportCategory:AddModule("➕ Criar Novo Ponto", function()
    openTeleportManager()
end, true)

-- Carregamento inicial dos pontos do mapa atual
refreshTeleportUI()

print("✅ Módulo de Teleporte Avançado (v15.1) carregado.")