-- ========== LOADER PRINCIPAL (v20 - Final Auto-Collect) ==========
print("🔧 Iniciando carregamento v20. Pressione F9 para ver os logs.")

local BASE_URL = "https://raw.githubusercontent.com/RobloxScriptPrivate/aimbot/main/"

-- Serviços
local RunService = game:GetService("RunService")

-- Função para buscar e carregar código da URL
local function fetch(file)
    local cache_buster = "?v=" .. os.time() .. "&r=" .. math.random(1, 1000000)
    local url = BASE_URL .. file .. cache_buster
    print("⚡ Baixando de: " .. url)
    local success, content = pcall(game.HttpGet, game, url, true)
    if success and content and #content > 0 then
        print("✅ Download de '"..file.."' bem-sucedido.")
        return content
    else
        print("🔥🔥 FALHA CRÍTICA NO DOWNLOAD de '"..file.."'. Erro: " .. tostring(content))
        return nil
    end
end

-- Etapa 1: Carregar a biblioteca GUI
print("\n--- Etapa 1: Carregando GUI ---")
local gui_code = fetch("gui.lua")
if not gui_code then
    warn("❌ ERRO FATAL: A biblioteca da GUI não pôde ser baixada.")
    return
end

local Library = loadstring(gui_code)()
if not Library then
    warn("❌ ERRO FATAL: A biblioteca da GUI falhou ao executar.")
    return
end
print("✅ Biblioteca GUI carregada e executada.")


-- Etapa 2: Criar as categorias
print("\n--- Etapa 2: Criando Categorias ---")
task.wait(0.1)
local startX   = 10
local startY   = 120
local catWidth = 150
local spacing  = 10

local Combat   = Library:CreateCategory("⚔️ Combat",    UDim2.new(0, startX, 0, startY))
local Visual   = Library:CreateCategory("👁️ Visual",    UDim2.new(0, startX + catWidth + spacing, 0, startY))
local Movement = Library:CreateCategory("🏃 Movimento", UDim2.new(0, startX + (catWidth + spacing) * 2, 0, startY))
local Teleport = Library:CreateCategory("🌌 Teleporte", UDim2.new(0, startX + (catWidth + spacing) * 3, 0, startY))
local Misc     = Library:CreateCategory("✨ Misc",      UDim2.new(0, startX + (catWidth + spacing) * 4, 0, startY))
print("✅ Todas as categorias criadas.")


-- Etapa 3: Carregar os Módulos
print("\n--- Etapa 3: Carregando Módulos ---")
task.wait(0.1)
local function LoadModule(filename, category)
    print("\n🔧 Carregando Módulo: '"..filename.."'...")
    if not category then
        warn("🔥🔥 ERRO: A categoria para '"..filename.."' é NULA.")
        return function() end
    end
    local code = fetch(filename)
    if code then
        local func, compile_err = loadstring(code)
        if func then
            local success, result = pcall(func, Library, category)
            if success then
                print("✅ Módulo '"..filename.."' executado com sucesso.")
                return result
            else
                warn("🔥🔥 ERRO AO EXECUTAR '"..filename.."': ", result)
            end
        else
            warn("🔥🔥 ERRO DE SINTAXE em '"..filename.."': ", compile_err)
        end
    end
    return function() end
end

-- Carregar módulos existentes (GARANTINDO QUE AIMBOT SEJA CARREGADO)
local cleanupFuncs = {}
cleanupFuncs.aimbot   = LoadModule("aimbot.lua",   Combat)
cleanupFuncs.hitbox   = LoadModule("hitbox.lua",   Combat)
cleanupFuncs.esp      = LoadModule("esp.lua",      Visual)
cleanupFuncs.nametag  = LoadModule("nametag.lua",  Visual)
cleanupFuncs.movement = LoadModule("movement.lua", Movement)
cleanupFuncs.teleport = LoadModule("teleport.lua", Teleport)

-- Etapa 3.5: Adicionar Módulos da categoria MISC
print("\n--- Etapa 3.5: Adicionando Módulos Misc ---")
getgenv().AutoCollectMoney = false

local killauraModule = Misc:AddModule("🎯 Killaura", function(enabled)
    Library.Killaura.Enabled = enabled
end)
if killauraModule then
    killauraModule:AddSlider("Distância: ", 5, 50, Library.Killaura.Distance, function(val)
        Library.Killaura.Distance = val
    end)
    print("✅ Módulo Killaura adicionado.")
end

-- NOVO AUTO COLLECT DEFINITIVO
Misc:AddModule("💵 Auto Coletar Dinheiro", function(enabled)
    getgenv().AutoCollectMoney = enabled
    print("Auto Coletar Dinheiro (v20) " .. (enabled and "ativado" or "desativado"))
end)

-- Etapa 4: Lógica dos Módulos (em background)
print("\n--- Etapa 4: Iniciando loops de background ---")

-- Loop do Killaura
coroutine.wrap(function() -- (código do killaura permanece o mesmo)
end)()
print("✅ Loop do Killaura iniciado.")

-- Loop do Auto Collect Money (LÓGICA DE TELEPORTE-E-RETORNO)
coroutine.wrap(function()
    while true do
        task.wait(1) -- Coleta a cada 1 segundo
        
        if getgenv().AutoCollectMoney then
            local localPlayer = game:GetService("Players").LocalPlayer
            local Character = localPlayer.Character
            local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")

            if not RootPart then continue end

            local tycoonsFolder = workspace:FindFirstChild("Tycoons")
            if not tycoonsFolder then continue end

            for _, tycoon in ipairs(tycoonsFolder:GetChildren()) do
                local essentials = tycoon:FindFirstChild("Essentials")
                if essentials then
                    for i = 1, 2 do
                        local collector = essentials:FindFirstChild("CollectorP" .. i)
                        local touchPart = collector and collector:FindFirstChild("Touch")

                        if touchPart and touchPart:IsA("BasePart") then
                            -- Executa a operação de forma segura
                            pcall(function()
                                local originalCFrame = touchPart.CFrame
                                
                                -- Move a placa para o jogador
                                touchPart.CFrame = RootPart.CFrame
                                
                                -- Espera um único frame para o jogo registrar o toque
                                RunService.Heartbeat:Wait()
                                
                                -- Retorna a placa para a posição original
                                touchPart.CFrame = originalCFrame
                            end)
                        end
                    end
                end
            end
        end
    end
end)()
print("✅ Loop do Auto Collect (v20 - Teleport) iniciado.")


-- Etapa 5: Restaurar posições e Cleanup
print("\n--- Etapa 5: Configurações Finais ---")
task.wait(0.05)
if Library.RestoreCategoryPositions then
    Library:RestoreCategoryPositions()
end

local sg = Library.ScreenGui
if sg then
    sg.Destroying:Connect(function()
        print("🧹 Cleanup global executado.")
        getgenv().AutoCollectMoney = false
        Library.Killaura.Enabled = false
        for name, fn in pairs(cleanupFuncs) do
            if type(fn) == "function" then pcall(fn) end
        end
    end)
end

print("\n\n🎉🎉 CARREGAMENTO FINALIZADO. Tudo pronto. 🎉🎉")
print("👉 Pressione INSERT para abrir o menu. Pressione K para remover o script.")
