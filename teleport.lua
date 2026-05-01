-- ========== TELEPORTE v22 (Ação no Clique Principal + Sub-Opção Corrigida) ==========
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

    for i, data in ipairs(currentMapPositions) do
        local name = data.name
        local posData = data.position
        local cf = CFrame.new(unpack(posData))
        local teleModule

        -- PASSO 1: Ação no clique principal. O módulo é um toggle que executa uma ação e se desliga.
        teleModule = TeleportCategory:AddModule(name, function(state) 
            if state then
                teleportTo(cf)
                teleModule:Set(false) -- ESSENCIAL: Desliga o toggle para não ficar verde.
            end
        end, false) -- `false` para permitir o menu de clique-direito.

        -- PASSO 2: A sub-opção é criada com AddToggle, o método correto que existe na biblioteca.
        teleModule:AddToggle("❌ Remover", false, function(state)
            if state then
                table.remove(currentMapPositions, i)
                Library:SaveConfig(CONFIG_FILE, allSavedPositions)
                print("❌ Ponto '"..name.."' removido.")
                refreshTeleportUI()
            end
        end)

        table.insert(teleportModules, teleModule)
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
            local newPoint = { name = posName, position = {root.CFrame:GetComponents()} }
            table.insert(currentMapPositions, 1, newPoint)
            Library:SaveConfig(CONFIG_FILE, allSavedPositions)
            print("✅ Ponto '"..posName.."' salvo.")
            window.Frame:Destroy()
            refreshTeleportUI()
        end
    end)
end

-- Botão principal para criar novos pontos (este é um botão simples)
TeleportCategory:AddModule("➕ Criar Novo Ponto", function()
    openTeleportManager()
end, true)

-- Carregamento inicial
refreshTeleportUI()

print("✅ Módulo de Teleporte Avançado (v22) carregado.")
