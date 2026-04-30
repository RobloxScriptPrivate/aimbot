-- ========== TELEPORTE v15 (Correção com Sub-Opção) ==========
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

    -- Cria o módulo. Clique esquerdo teleporta. Clique direito expande.
    local module = TeleportCategory:AddModule(name, function()
        teleportTo(cf)
    end, {
        isTrigger = true, -- Mantém o teleporte no clique esquerdo
        order = 2 -- Ordem maior para ficar abaixo do botão 'Criar'
        -- A lógica onRightClick foi REMOVIDA
    })

    -- ADICIONA A SUB-OPÇÃO DE DELETAR, como você sugeriu
    module:AddButton("Deletar Ponto", function()
        removeTeleportPoint(name)
    end)
    
    -- Armazena a referência do módulo para poder deletá-lo depois
    pointModules[name] = module
end

-- Carrega os botões salvos na inicialização
for name, data in pairs(savedPositions) do
    addTeleportButton(name, data)
end

-- Função para abrir o gerenciador de criação
-- NOTA: A função CreateWindow foi restaurada na V8.1 da GUI
local function openTeleportManager()
    local window = Library:CreateWindow("🌌 Novo Ponto", UDim2.new(0, 280, 0, 150))
    if not window then
        print("ERRO: Library:CreateWindow não existe na versão atual da GUI.")
        return
    end
    local nameInput = window:AddTextBox("Nome do Local...")
    
    window:AddButton("Salvar Posição Atual", function()
        local posName = nameInput.Text
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if posName and #posName > 0 and root then
            if savedPositions[posName] then
                print("⚠️ Um ponto com o nome '"..posName.."' já existe.")
                return
            end

            local currentCF = root.CFrame
            local cfTable = {currentCF:GetComponents()}
            
            savedPositions[posName] = cfTable
            Library:SaveConfig(CONFIG_NAME, savedPositions)
            addTeleportButton(posName, cfTable)
            
            print("✅ Ponto '"..posName.."' salvo para este mapa.")
            window.Frame:Destroy()
        end
    end)
end

-- Botão principal para criar novos pontos
TeleportCategory:AddModule("➕ Criar Novo Ponto", function()
    openTeleportManager()
end, { isTrigger = true, order = 1 })

print("✅ Módulo de Teleporte v15 (Com Sub-Opção) carregado.")
