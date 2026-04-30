-- ========== TELEPORTE v16 (Classic Dropdown) ==========
local Library, TeleportCategory = ..., select(2, ...)

-- Serviços
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Nome do arquivo de configuração baseado no ID do mapa
local CONFIG_NAME = "Manus_Teleports_" .. tostring(game.PlaceId)

-- Carregar posições salvas
local savedPositions = Library:LoadConfig(CONFIG_NAME) or {}
local positionNames = {}
for name, _ in pairs(savedPositions) do
    table.insert(positionNames, name)
end

local currentTarget = nil

-- MÓDULO PRINCIPAL
local TP_Module = TeleportCategory:AddModule("🌌 Teleporte", nil, false)

-- AÇÕES
TP_Module:AddButton("Teleportar", function()
    if currentTarget and savedPositions[currentTarget] then
        local cf = CFrame.new(unpack(savedPositions[currentTarget]))
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = cf end
    end
end)

TP_Module:AddButton("Salvar Posição", function()
    Library:ShowInput("Nome da Posição", function(name)
        if name and #name > 0 and not savedPositions[name] then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                savedPositions[name] = {root.CFrame:GetComponents()}
                Library:SaveConfig(CONFIG_NAME, savedPositions)
                -- Atualiza o dropdown
                table.insert(positionNames, name)
                TP_Module:UpdateDropdown("Pontos Salvos", positionNames)
            end
        end
    end)
end)

TP_Module:AddButton("Deletar Posição", function()
    if currentTarget then
        savedPositions[currentTarget] = nil
        Library:SaveConfig(CONFIG_NAME, savedPositions)
        -- Atualiza o dropdown
        for i, v in ipairs(positionNames) do
            if v == currentTarget then table.remove(positionNames, i); break end
        end
        TP_Module:UpdateDropdown("Pontos Salvos", positionNames)
        currentTarget = nil
    end
end)

-- DROPDOWN PARA SELEÇÃO
TP_Module:AddDropdown("Pontos Salvos", positionNames, function(selection)
    currentTarget = selection
end)

print("✅ Módulo de Teleporte v16 (Classic Dropdown) carregado.")
