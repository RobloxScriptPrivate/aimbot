-- ========== TELEPORTE v18 (Comportamento de Botão Corrigido) ==========
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

        local teleModule -- Declarado antes para auto-referência

        -- CORREÇÃO FINAL: Cria um toggle, teleporta, e se desliga em seguida.
        teleModule = TeleportCategory:AddModule(name, function(state) 
            if state then -- Só executa quando ativado
                teleportTo(cf)
                teleModule:Set(false) -- ESSENCIAL: Desliga o toggle para agir como um botão
            end
        end, false) -- `false` para permitir sub-opções

        -- Adiciona a sub-opção "Remover" que agora deve funcionar
        teleModule:AddButton("Remover", function()
            table.remove(currentMapPositions, i)
            Library:SaveConfig(CONFIG_FILE, allSavedPositions)
            print("❌ Ponto '"..name.."' removido.")
            refreshTeleportUI()
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

-- Botão principal para criar novos pontos (sem sub-opções)
TeleportCategory:AddModule("➕ Criar Novo Ponto", function()
    openTeleportManager()
end, true)

-- Carregamento inicial
refreshTeleportUI()

print("✅ Módulo de Teleporte Avançado (v18) carregado.")
