-- ========== LOADER PRINCIPAL (v14 - Restore Categorias) ==========
print("🔧 Iniciando carregamento remoto v14. Pressione F9 para ver os logs.")

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
local Misc = Library:CreateCategory("✨ Misc", UDim2.new(0, startX + (catWidth + spacing) * 4, 0, startY))
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

local function LoadLocalModule(filename, category)
    print("\n🔧 Carregando Módulo Local: '"..filename.."'...")
    if not category then
        warn("🔥🔥 ERRO: A categoria para '"..filename.."' é NULA.")
        return function() end
    end
    local code = readfile(filename)
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


local cleanupFuncs = {}
cleanupFuncs.aimbot   = LoadModule("aimbot.lua",   Combat)
cleanupFuncs.hitbox   = LoadModule("hitbox.lua",   Combat)
cleanupFuncs.esp      = LoadModule("esp.lua",      Visual)
cleanupFuncs.nametag  = LoadModule("nametag.lua",  Visual)
cleanupFuncs.movement = LoadModule("movement.lua", Movement)
cleanupFuncs.teleport = LoadModule("teleport.lua", Teleport)
cleanupFuncs.killaura = LoadLocalModule("killaura.lua", Misc)


-- Etapa 4: Restaura posicoes e estado das categorias APOS todos os modulos
print("\n--- Etapa 4: Restaurando posicoes das categorias ---")
task.wait(0.05)  -- aguarda um frame para garantir que todos os frames existem
if Library.RestoreCategoryPositions then
    Library:RestoreCategoryPositions()
    print("✅ Posicoes e estados das categorias restaurados.")
end

-- Etapa 5: Cleanup global — roda quando K é pressionado ou ScreenGui destruído
print("\n--- Etapa 5: Configurando Limpeza Global ---")

-- Library.ScreenGui é exposto pela gui.lua para que o loader possa conectar
local sg = Library.ScreenGui
if sg then
    sg.Destroying:Connect(function()
        print("🧹 ScreenGui destruído — executando cleanup de todos os módulos...")
        for name, fn in pairs(cleanupFuncs) do
            if type(fn) == "function" then
                local ok, err = pcall(fn)
                if not ok then
                    warn("⚠️ Erro no cleanup de '" .. tostring(name) .. "': " .. tostring(err))
                end
            end
        end
        print("✅ Cleanup global concluído. Todos os Drawing objects e Highlights removidos.")
    end)
    print("✅ Cleanup global conectado ao ScreenGui.Destroying.")
else
    warn("⚠️ Library.ScreenGui não encontrado — cleanup automático não será executado.")
end

print("\n\n🎉🎉 CARREGAMENTO FINALIZADO. Tudo pronto. 🎉🎉")
print("👉 Pressione INSERT para abrir o menu. Pressione K para remover o script.")
