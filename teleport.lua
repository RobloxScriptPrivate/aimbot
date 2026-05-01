-- ========== TELEPORTE v15.2 (Com Ferramenta de Debug) ==========
local Library, TeleportCategory = ..., select(2, ...)

-- Serviços
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CurrentPlaceId = tostring(game.PlaceId)

-- Configuração
local CONFIG_FILE = "Manus_Teleports_V4" -- Mantemos V4 por enquanto
local allSavedPositions = Library:LoadConfig(CONFIG_FILE) or {}

-- Garante que o container para o mapa atual exista e seja uma tabela (array)
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
        local module = TeleportCategory:AddModule(name, function() teleportTo(cf) end)

        module:AddButton("Remover", function()
            table.remove(currentMapPositions, i)
            Library:SaveConfig(CONFIG_FILE, allSavedPositions)
            print("❌ Ponto '"..name.."' removido.")
            refreshTeleportUI()
        end)
        table.insert(teleportModules, module)
    end
end

-- Função para abrir a janela de criação
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

-- Botão principal para criar novos pontos
TeleportCategory:AddModule("➕ Criar Novo Ponto", function()
    openTeleportManager()
end, true)

-- ### FERRAMENTA DE DEBUG ###
TeleportCategory:AddModule("🔍 Inspecionar Cache", function()
    if type(inspect) == 'function' then
        print("--- Cache de Teleporte Ativo ---")
        print(inspect(allSavedPositions))
        print("--- Fim do Cache ---")
        warn("Copiado para a área de transferência! Cole no arquivo Manus_Teleports_V4.json")
        setclipboard(inspect(allSavedPositions)) -- Tenta copiar para o clipboard
    else
        warn("Função 'inspect' não encontrada. Não é possível depurar.")
    end
end, true)


-- Carregamento inicial dos pontos do mapa atual
refreshTeleportUI()

print("✅ Módulo de Teleporte Avançado (v15.2) carregado.")
