-- ========== LOADER PRINCIPAL (v11 - Corrigido para GUI V4) ==========
print("🔧 Iniciando carregamento remoto v11 (Corrigido). Pressione F9 para ver os logs.")

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

-- Etapa 1: Carregar a biblioteca GUI (V4 - Original)
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
print("✅ Biblioteca GUI (V4) carregada e executada.")


-- Etapa 2: Criar as categorias (Com Posições Manuais para V4)
print("\n--- Etapa 2: Criando Categorias ---")
task.wait(0.1)
-- A GUI V4 requer posições manuais (UDim2) para cada categoria.
local startX = 10
local startY = 120 -- Posição abaixo da barra superior
local catWidth = 150
local spacing = 10

local Combat = Library:CreateCategory("⚔️ Combat", UDim2.new(0, startX, 0, startY))
print("➡️ Categoria Combat criada.")

local Visual = Library:CreateCategory("👁️ Visual", UDim2.new(0, startX + catWidth + spacing, 0, startY))
print("➡️ Categoria Visual criada.")

local Movement = Library:CreateCategory("🏃 Movimento", UDim2.new(0, startX + (catWidth + spacing) * 2, 0, startY))
print("➡️ Categoria Movement criada.")

local Teleport = Library:CreateCategory("🌌 Teleporte", UDim2.new(0, startX + (catWidth + spacing) * 3, 0, startY))
print("➡️ Categoria Teleport criada.")
print("✅ Todas as categorias processadas com layout manual.")


-- Etapa 3: Carregar os Módulos
print("\n--- Etapa 3: Carregando Módulos ---")
task.wait(0.1)
local function LoadModule(filename, category)
    print("\n🔧 Carregando Módulo: '"..filename.."'...")
    if not category then
        warn("🔥🔥 ERRO: A categoria para '"..filename.."' é NULA. O módulo não será carregado.")
        return function() end
    end

    local code = fetch(filename)
    if code then
        local func, compile_err = loadstring(code)
        if func then
            local success, result = pcall(func, Library, category)
            if success then
                print("✅ Módulo '"..filename.."' executado com sucesso.")
                return result -- Retorna a função de limpeza
            else
                warn("🔥🔥 ERRO AO EXECUTAR o módulo '"..filename.."' 🔥🔥: ", result)
            end
        else
            warn("🔥🔥 ERRO DE SINTAXE no arquivo '"..filename.."' 🔥🔥: ", compile_err)
        end
    end
    return function() print("Cleanup vazio para módulo falho:", filename) end
end

-- Carrega todos os módulos
local cleanupFuncs = {}
cleanupFuncs.aimbot = LoadModule("aimbot.lua", Combat)
cleanupFuncs.esp = LoadModule("esp.lua", Visual)
cleanupFuncs.nametag = LoadModule("nametag.lua", Visual)
cleanupFuncs.movement = LoadModule("movement.lua", Movement)
cleanupFuncs.teleport = LoadModule("teleport.lua", Teleport)


-- Etapa 4: Configurar Limpeza Geral
print("\n--- Etapa 4: Configurando Limpeza Geral ---")
-- A V4 já tem a tecla K para remover o script por padrão.
print("✅ Keybind de remoção (K) já está incluso na biblioteca V4.")

print("\n\n🎉🎉 CARREGAMENTO FINALIZADO. Tudo pronto. 🎉🎉")
print("👉 Pressione INSERT para abrir o menu.")
