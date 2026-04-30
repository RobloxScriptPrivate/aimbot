-- ========== TELEPORTE v14 (Gerenciamento por Mapa & Deleção) ==========
local Library, TeleportCategory = ..., select(2, ...)

-- Serviços
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Nome do arquivo de configuração baseado no ID do mapa
local CONFIG_NAME = "Manus_Teleports_" .. tostring(game.PlaceId)

-- Cache local para os módulos de UI, para que possam ser removidos
local pointModules = {}

-- Carregar posições salvas para o mapa atual
local savedPositions = Library:LoadConfig(CONFIG_NAME) or {}

-- Função para teleporte instantâneo
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

-- Função para remover um ponto de teleporte
local function removeTeleportPoint(name)
    -- Remove do cache local
    savedPositions[name] = nil
    
    -- Salva as alterações no arquivo
    Library:SaveConfig(CONFIG_NAME, savedPositions)
    
    -- Remove o botão da UI
    if pointModules[name] then
        pointModules[name]:Remove()
        pointModules[name] = nil
    end
    print("🗑️ Ponto '"..name.."' deletado.")
end

-- Função para adicionar botão de teleporte na UI
local function addTeleportButton(name, posData)
    -- Converte a tabela de posição de volta para CFrame
    local cf = CFrame.new(unpack(posData))

    -- Cria o módulo com opções para deleção e ordenação
    local module = TeleportCategory:AddModule(name, function()
        teleportTo(cf)
    end, {
        isTrigger = true,
        order = 2, -- Ordem maior para ficar abaixo do botão 'Criar'
        onRightClick = function()
            removeTeleportPoint(name)
        end
    })
    
    -- Armazena a referência do módulo para poder deletá-lo depois
    pointModules[name] = module
end

-- Carrega os botões salvos na inicialização
for name, data in pairs(savedPositions) do
    addTeleportButton(name, data)
end

-- Função para abrir o gerenciador de criação
local function openTeleportManager()
    local window = Library:CreateWindow("🌌 Novo Ponto", UDim2.new(0, 280, 0, 150))
    local nameInput = window:AddTextBox("Nome do Local...")
    
    window:AddButton("Salvar Posição Atual", function()
        local posName = nameInput.Text
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if posName and #posName > 0 and root then
            -- Verifica se o ponto já existe
            if savedPositions[posName] then
                print("⚠️ Um ponto com o nome '"..posName.."' já existe.")
                return
            end

            local currentCF = root.CFrame
            local cfTable = {currentCF:GetComponents()}
            
            -- Salva no cache local
            savedPositions[posName] = cfTable
            
            -- Persiste no arquivo JSON específico do mapa
            Library:SaveConfig(CONFIG_NAME, savedPositions)
            
            -- Adiciona o botão na lista
            addTeleportButton(posName, cfTable)
            
            print("✅ Ponto '"..posName.."' salvo para este mapa.")
            window.Frame:Destroy()
        end
    end)
end

-- Botão principal para criar novos pontos (sempre no topo)
TeleportCategory:AddModule("➕ Criar Novo Ponto", function()
    openTeleportManager()
end, { isTrigger = true, order = 1 }) -- Ordem 1 para ficar no topo

print("✅ Módulo de Teleporte v14 (Por Mapa) carregado.")
