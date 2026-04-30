-- ========== TELEPORTE v12 (UI Corrigida e Simplificada) ==========
local Library, TeleportCategory = ..., select(2, ...)

-- Serviços e Variáveis
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local savedPositions = {}

-- Função principal para abrir e gerenciar a janela de teleporte
local function openTeleportManager()
    -- A API CreateWindow agora lida com janelas existentes, então podemos chamar sem medo.
    
    -- 1. Criar a janela com tamanho reduzido
    local window = Library:CreateWindow("🌌 Teleporte", UDim2.new(0, 280, 0, 150))

    -- 2. Adicionar os componentes. A UIListLayout e o UIPadding da API já cuidam do alinhamento.
    local nameInput = window:AddTextBox("Nome do Ponto")
    local saveButton = window:AddButton("Salvar Posição", function()
        local posName = nameInput.Text
        if posName and #posName > 0 and LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart then
            local currentPos = LocalPlayer.Character.HumanoidRootPart.CFrame
            table.insert(savedPositions, {name = posName, pos = currentPos})
            
            nameInput.Text = "" -- Limpa o campo
            
            -- Cria um botão para o novo ponto salvo na categoria de teleporte
            TeleportCategory:AddModule(posName, function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = currentPos
                    print("Teleportado para", posName)
                end
            end, true) -- true para ser um gatilho (trigger)

            print("Posição '"..posName.."' salva.")
            window.Frame:Destroy() -- Fecha a janela após salvar
        end
    end)
end

-- Cria o módulo que abre a janela de teleporte
TeleportCategory:AddModule("Salvar Ponto", function()
    openTeleportManager()
end, true) -- true para ser um gatilho (trigger)

print("✅ Módulo de Teleporte (v12) carregado.")

-- Função de limpeza (boa prática)
return function()
    -- A limpeza das janelas agora é gerenciada pela gui.lua
    print("🧼 Módulo de Teleporte limpo.")
end
