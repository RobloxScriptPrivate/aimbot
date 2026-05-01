-- ========== TELEPORTE v26 (Abordagem de Painel de Ação) ==========
local Library, TeleportCategory = ..., select(2, ...)

-- Serviços
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CurrentPlaceId = tostring(game.PlaceId)

-- Configuração
local CONFIG_FILE = "Manus_Teleports_V4"
local allSavedPositions = Library:LoadConfig(CONFIG_FILE) or {}
if not allSavedPositions[CurrentPlaceId] or type(allSavedPositions[CurrentPlaceId]) ~= 'table' then
    allSavedPositions[CurrentPlaceId] = {}
end
local currentMapPositions = allSavedPositions[CurrentPlaceId]
local teleportModules = {} 

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
    for _, module in ipairs(teleportModules) do
        if module and module.Destroy then module:Destroy() end
    end
    teleportModules = {}

    -- Função que cria o painel de ação para um ponto específico
    local function createActionWindow(pointData)
        local pointName = pointData.name
        local cf = CFrame.new(unpack(pointData.position))

        local window = Library:CreateWindow("Ação: " .. pointName, UDim2.new(0.5, -140, 0.5, -90), UDim2.new(0, 280, 0, 180))

        window:AddButton("➡️ Ir Agora", function()
            teleportTo(cf)
            window.Frame:Destroy()
        end)

        window:AddButton("❌ Remover", function()
            -- Procura e remove o ponto da tabela principal de forma segura
            for i, p in ipairs(currentMapPositions) do
                if p == pointData then
                    table.remove(currentMapPositions, i)
                    break
                end
            end
            Library:SaveConfig(CONFIG_FILE, allSavedPositions)
            print("❌ Ponto '"..pointName.."' removido.")
            window.Frame:Destroy()
            refreshTeleportUI() -- Agora é seguro recarregar
        end)

        window:AddButton("Cancelar", function()
            window.Frame:Destroy()
        end)
    end

    -- Loop principal que cria os botões na categoria
    for _, data in ipairs(currentMapPositions) do
        -- Captura a referência da `data` para esta iteração
        local pointDataForButton = data

        -- PASSO 1: Cria um BOTÃO SIMPLES (`true` no final). Ele não tem estado "verde".
        local teleModule = TeleportCategory:AddModule(pointDataForButton.name, function() 
            -- PASSO 2: O clique abre o painel de ação, em vez de tentar fazer a ação diretamente.
            createActionWindow(pointDataForButton)
        end, true)

        table.insert(teleportModules, teleModule)
    end
end

-- Função para abrir a janela de criação de ponto
local function openTeleportManager()
    local window = Library:CreateWindow("🌌 Novo Ponto", UDim2.new(0.5, -140, 0.5, -75), UDim2.new(0, 280, 0, 150))
    local nameInput = window:AddTextBox("Nome do Local...")
    
    window:AddButton("Salvar Posição Atual", function()
        local posName = nameInput.Text
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if posName and #posName > 0 and root then
            local newPoint = { name = posName, position = {root.CFrame:GetComponents()} }
            table.insert(currentMapPositions, 1, newPoint)
            Library:SaveConfig(CONFIG_FILE, allSavedPositions)
            print("✅ Ponto '"..posName.."' salvo.")
            window.Frame:Destroy()
            refreshTeleportUI()
        end
    end)
end

-- Botão principal para criar novos pontos
TeleportCategory:AddModule("➕ Criar Novo Ponto", function()
    openTeleportManager()
end, true)

-- Carregamento inicial
refreshTeleportUI()

print("✅ Módulo de Teleporte Avançado (v26) carregado.")
