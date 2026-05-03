-- ========== LOADER PRINCIPAL (v21 - Module Inspector) ==========
print("🔧 Iniciando carregamento v21. Pressione F9 para ver os logs de inicialização.")

local BASE_URL = "https://raw.githubusercontent.com/RobloxScriptPrivate/aimbot/main/"

-- Serviços
local RunService = game:GetService("RunService")

-- Função para buscar e carregar código da URL
local function fetch(file)
    local cache_buster = "?v=" .. os.time() .. "&r=" .. math.random(1, 1000000)
    local url = BASE_URL .. file .. cache_buster
    local success, content = pcall(game.HttpGet, game, url, true)
    if success and content and #content > 0 then
        return content
    else
        warn("FALHA NO DOWNLOAD de '"..file.."'. Erro: " .. tostring(content))
        return nil
    end
end

-- Etapa 1: Carregar a biblioteca GUI
print("\n--- Etapa 1: Carregando GUI ---")
local gui_code = fetch("gui.lua")
if not gui_code then
    warn("❌ ERRO FATAL: A biblioteca da GUI não pôde ser baixada. O script não pode continuar.")
    return
end
local Library = loadstring(gui_code)()
if not Library then
    warn("❌ ERRO FATAL: A biblioteca da GUI falhou ao executar. O script não pode continuar.")
    return
end
print("✅ Biblioteca GUI carregada e executada.")


-- Etapa 2: Criar as categorias
print("\n--- Etapa 2: Criando Categorias ---")
local Combat   = Library:CreateCategory("⚔️ Combat",    UDim2.new(0, 10, 0, 120))
local Visual   = Library:CreateCategory("👁️ Visual",    UDim2.new(0, 170, 0, 120))
local Movement = Library:CreateCategory("🏃 Movimento", UDim2.new(0, 330, 0, 120))
local Teleport = Library:CreateCategory("🌌 Teleporte", UDim2.new(0, 490, 0, 120))
local Misc     = Library:CreateCategory("✨ Misc",      UDim2.new(0, 650, 0, 120))
print("✅ Todas as categorias criadas.")


-- Etapa 3: NOVA FUNÇÃO DE CARREGAMENTO DE MÓDULO (COM LOGS DETALHADOS)
print("\n--- Etapa 3: Carregando Módulos ---")
local function LoadModule(filename, category)
    print("\n========================================")
    print("🔧 Iniciando carregamento do Módulo: '"..filename.."'")
    
    if not category or not category.Frame then
        warn("🔥🔥 ERRO CRÍTICO: A categoria para '"..filename.."' é NULA ou INVÁLIDA. O módulo não pode ser desenhado.")
        print("========================================")
        return function() end
    end
    print("  [1/4] Categoria encontrada: '" .. category.Frame.Name .. "'.")

    local code = fetch(filename)
    if not code then
        warn("🔥🔥 ERRO CRÍTICO: Falha no download de '"..filename.."'. O módulo não será carregado.")
        print("========================================")
        return function() end
    end
    print("  [2/4] Download de '"..filename.."' concluído.")

    local func, compile_err = loadstring(code)
    if not func then
        warn("🔥🔥 ERRO CRÍTICO DE COMPILAÇÃO em '"..filename.."':")
        warn(tostring(compile_err))
        print("========================================")
        return function() end
    end
    print("  [3/4] Compilação (loadstring) de '"..filename.."' bem-sucedida.")

    local success, result = pcall(func, Library, category)
    if not success then
        warn("🔥🔥 ERRO CRÍTICO DE EXECUÇÃO em '"..filename.."':")
        warn(tostring(result))
        print("========================================")
        return function() end
    end
    
    print("  [4/4] Execução inicial de '"..filename.."' bem-sucedida.")
    print("✅ Módulo '"..filename.."' carregado e integrado com sucesso!")
    print("========================================")
    return result or function() end
end


-- Carregar todos os módulos
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

Misc:AddModule("🎯 Killaura", function(enabled)
    Library.Killaura.Enabled = enabled
end):AddSlider("Distância: ", 5, 50, Library.Killaura.Distance, function(val)
    Library.Killaura.Distance = val
end)

Misc:AddModule("💵 Auto Coletar Dinheiro", function(enabled)
    getgenv().AutoCollectMoney = enabled
end)


-- Etapa 4: Lógicas de Background
-- (Código do Killaura e Auto Collect permanecem os mesmos)


-- Etapa 5: Configurações Finais
-- (Código de restauração e cleanup permanecem os mesmos)

print("\n\n🎉🎉 CARREGAMENTO FINALIZADO. Verifique o console F9 para quaisquer erros críticos. 🎉🎉")
