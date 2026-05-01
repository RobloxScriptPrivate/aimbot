-- ========== TELEPORTE v27 (Clique Direto + Remover Imediato) ==========
local Library, TeleportCategory = ..., select(2, ...)

-- Serviços
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local CurrentPlaceId = tostring(game.PlaceId)

-- Configuração
local CONFIG_FILE = "Manus_Teleports_V4"
local allSavedPositions = Library:LoadConfig(CONFIG_FILE) or {}
if not allSavedPositions[CurrentPlaceId] or type(allSavedPositions[CurrentPlaceId]) ~= "table" then
    allSavedPositions[CurrentPlaceId] = {}
end
local currentMapPositions = allSavedPositions[CurrentPlaceId]

-- Lista dos módulos de ponto criados dinamicamente (para poder destruí-los no refresh)
local teleportModules = {}

-- ──────────────────────────────────────────────
-- Função de teleporte
-- ──────────────────────────────────────────────
local function teleportTo(cf)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.Velocity = Vector3.new(0, 0, 0)
        root.CFrame = cf
        task.wait()
        if root and root.Parent then
            root.Velocity = Vector3.new(0, 0, 0)
        end
    end
end

-- ──────────────────────────────────────────────
-- Rebuild completo da lista de pontos na UI
-- ──────────────────────────────────────────────
local function refreshTeleportUI()
    -- Destrói todos os módulos de ponto anteriores (método Destroy agora existe na GUI V6.6)
    for _, mod in ipairs(teleportModules) do
        if mod and mod.Destroy then
            mod:Destroy()
        end
    end
    teleportModules = {}

    -- Recria um botão para cada ponto salvo
    for _, data in ipairs(currentMapPositions) do
        local pointData = data  -- captura local para o closure

        -- isTrigger = true → clique simples, sem estado verde permanente
        local teleModule = TeleportCategory:AddModule(pointData.name, function()
            -- Clique esquerdo: teleporta imediatamente
            local cf = CFrame.new(table.unpack(pointData.position))
            teleportTo(cf)
        end, true)

        -- Clique direito no botão abre sub-painel com opção de remover
        -- (o usuário pode clicar com botão direito para expandir as sub-opções)
        teleModule:AddToggle("❌ Remover este ponto", false, function(state)
            if state then
                -- Remove da tabela e persiste
                for i, p in ipairs(currentMapPositions) do
                    if p == pointData then
                        table.remove(currentMapPositions, i)
                        break
                    end
                end
                Library:SaveConfig(CONFIG_FILE, allSavedPositions)
                print("❌ Ponto '" .. pointData.name .. "' removido.")
                -- Rebuild imediato da lista (o módulo atual será destruído junto)
                refreshTeleportUI()
            end
        end)

        table.insert(teleportModules, teleModule)
    end
end

-- ──────────────────────────────────────────────
-- Janela para criar novo ponto
-- ──────────────────────────────────────────────
local function openTeleportManager()
    -- Tamanho: 280×150  |  Posição: centralizada
    local window = Library:CreateWindow(
        "🌌 Novo Ponto",
        UDim2.new(0, 280, 0, 150),
        UDim2.new(0.5, -140, 0.5, -75)
    )
    local nameInput = window:AddTextBox("Nome do Local...")

    window:AddButton("💾 Salvar Posição Atual", function()
        local posName = nameInput.Text
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        if posName and #posName > 0 and root then
            -- Armazena os 12 componentes do CFrame para reconstrução fiel
            local newPoint = {
                name = posName,
                position = { root.CFrame:GetComponents() }
            }
            table.insert(currentMapPositions, 1, newPoint)
            Library:SaveConfig(CONFIG_FILE, allSavedPositions)
            print("✅ Ponto '" .. posName .. "' salvo.")
            window.Frame:Destroy()
            refreshTeleportUI()
        else
            print("⚠️ Preencha o nome e certifique-se de estar num personagem.")
        end
    end)
end

-- ──────────────────────────────────────────────
-- Botão fixo: Criar Novo Ponto
-- ──────────────────────────────────────────────
TeleportCategory:AddModule("➕ Criar Novo Ponto", function()
    openTeleportManager()
end, true)

-- Carregamento inicial dos pontos salvos
refreshTeleportUI()

print("✅ Módulo de Teleporte (v27) carregado. " .. #currentMapPositions .. " ponto(s) encontrado(s).")
