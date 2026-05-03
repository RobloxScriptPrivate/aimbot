-- ========== LOADER PRINCIPAL (v19 - Log Window) ==========
print("🔧 Iniciando carregamento v19. Pressione F9 para ver os logs.")

local BASE_URL = "https://raw.githubusercontent.com/RobloxScriptPrivate/aimbot/main/"

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

-- Carregar módulos existentes
local cleanupFuncs = {}
cleanupFuncs.aimbot   = LoadModule("aimbot.lua",   Combat)
cleanupFuncs.hitbox   = LoadModule("hitbox.lua",   Combat)
cleanupFuncs.esp      = LoadModule("esp.lua",      Visual)
cleanupFuncs.nametag  = LoadModule("nametag.lua",  Visual)
cleanupFuncs.movement = LoadModule("movement.lua", Movement)
cleanupFuncs.teleport = LoadModule("teleport.lua", Teleport)

-- Etapa 3.5: Adicionar Módulos da categoria MISC
print("\n--- Etapa 3.5: Adicionando Módulos Misc ---")

local killauraModule = Misc:AddModule("🎯 Killaura", function(enabled)
    Library.Killaura.Enabled = enabled
end)
if killauraModule then
    killauraModule:AddSlider("Distância: ", 5, 50, Library.Killaura.Distance, function(val)
        Library.Killaura.Distance = val
    end)
    print("✅ Módulo Killaura adicionado.")
end

-- Botão de Inspeção com a nova janela de Log
Misc:AddModule("🔍 Inspecionar Tycoons", function()
    local logLines = { "===== INICIANDO INSPEÇÃO DE TYCOONS =====\n" }
    local tycoonsFolder = workspace:FindFirstChild("Tycoons")
    
    if not tycoonsFolder then
        table.insert(logLines, "### ERRO: Pasta 'Tycoons' não encontrada no workspace! ###")
    else
        table.insert(logLines, "Encontrados " .. #tycoonsFolder:GetChildren() .. " tycoons.")
        for _, tycoon in ipairs(tycoonsFolder:GetChildren()) do
            table.insert(logLines, "\n--- Inspecionando Tycoon: '" .. tycoon.Name .. "' ---")
            local essentials = tycoon:FindFirstChild("Essentials")
            if not essentials then
                table.insert(logLines, "  - Pasta 'Essentials' não encontrada neste tycoon.")
            else
                for i = 1, 2 do
                    local collectorName = "CollectorP" .. i
                    local collector = essentials:FindFirstChild(collectorName)
                    if collector then
                        table.insert(logLines, "  -- Encontrado: '" .. collectorName .. "' (Classe: " .. collector.ClassName .. ") --")
                        local children = collector:GetChildren()
                        if #children > 0 then
                            table.insert(logLines, "     Filhos do Collector:")
                            for _, child in ipairs(children) do
                                local line = "       - "..child.Name .. " (Classe: " .. child.ClassName .. ")"
                                table.insert(logLines, line)
                                if child.Name == "Touch" and child:IsA("BasePart") then
                                   local touchChildren = child:GetChildren()
                                   if #touchChildren > 0 then
                                       table.insert(logLines, "         Filhos do 'Touch':")
                                       for _, touchChild in ipairs(touchChildren) do
                                           table.insert(logLines, "           * "..touchChild.Name .. " (Classe: " .. touchChild.ClassName .. ")")
                                       end
                                   else
                                       table.insert(logLines, "         'Touch' não possui filhos.")
                                   end
                                end
                            end
                        else
                            table.insert(logLines, "     '"..collectorName.."' não possui filhos.")
                        end
                    else
                        table.insert(logLines, "  -- '"..collectorName.."' não encontrado --")
                    end
                end
            end
        end
    end
    table.insert(logLines, "\n===== INSPEÇÃO CONCLUÍDA =====")
    table.insert(logLines, "\nPor favor, copie este relatório completo e envie para análise.")
    
    -- Usa a nova função da GUI para mostrar o log
    Library:CreateLogWindow("Relatório de Inspeção", table.concat(logLines, "\n"))

end, true) -- true para ser um botão de clique único

-- Etapa 4: Lógica do Killaura
print("\n--- Etapa 4: Iniciando loop do Killaura ---")
coroutine.wrap(function()
    while true do
        if Library.Killaura.Enabled and Library.Killaura.Target then
           -- (código do killaura)
        end
        wait(0.1)
    end
end)()
print("✅ Loop do Killaura iniciado.")

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
        Library.Killaura.Enabled = false
    end)
end

print("\n\n🎉🎉 CARREGAMENTO FINALIZADO. Tudo pronto. 🎉🎉")
print("👉 Pressione INSERT para abrir o menu. Pressione K para remover o script.")
