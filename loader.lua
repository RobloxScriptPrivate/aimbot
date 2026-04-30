-- ========== LOADER PRINCIPAL (v8 - MODO DE DIAGNÓSTICO) ==========
print("🔧 Iniciando carregamento remoto v8 (MODO DE DIAGNÓSTICO). Pressione F9 para ver os logs.")

local BASE_URL = "https://raw.githubusercontent.com/RobloxScriptPrivate/aimbot/main/"

-- Função para buscar e carregar código da URL, com sistema anti-cache agressivo e logs detalhados
local function fetch(file)
    -- Anti-cache extremamente agressivo para garantir um novo download sempre
    local cache_buster = "?v=" .. os.time() .. "&r=" .. math.random(1, 1000000)
    local url = BASE_URL .. file .. cache_buster
    
    print("⚡ Baixando de: " .. url) 

    local success, content = pcall(function() 
        -- O segundo argumento 'true' tenta forçar a invalidação do cache
        return game:HttpGet(url, true) 
    end)
    
    if success and content and #content > 0 then
        print("✅ Download de '"..file.."' bem-sucedido.")
        return content
    else
        print("🔥🔥 FALHA CRÍTICA NO DOWNLOAD de '"..file.."' 🔥🔥. O script pode não funcionar. Erro: " .. tostring(content))
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
task.wait(0.2)
local Combat = Library:CreateCategory("⚔️ Combat", UDim2.new(0, 10, 0, 60))
print("➡️ Categoria Combat criada.")
local Visual = Library:CreateCategory("👁️ Visual", UDim2.new(0, 10, 0, 100))
print("➡️ Categoria Visual criada.")
local Movement = Library:CreateCategory("🏃 Movimento", UDim2.new(0, 10, 0, 140))
print("➡️ Categoria Movement criada.")
local Teleport = Library:CreateCategory("🌌 Teleporte", UDim2.new(0, 10, 0, 180))
print("➡️ Categoria Teleport criada.")
print("✅ Todas as categorias processadas.")


-- Etapa 3: Carregar os Módulos
print("\n--- Etapa 3: Carregando Módulos ---")
task.wait(0.2)
local function LoadModule(filename, category)
    print("\n🔧 Carregando Módulo: '"..filename.."'...")
    if not category then
        warn("🔥🔥 ERRO: A categoria para '"..filename.."' é NULA. O módulo não será carregado. 🔥🔥")
        return function() end
    end

    local code = fetch(filename)
    if code then
        local func, compile_err = loadstring(code)
        if func then
            -- Usando pcall para capturar erros DENTRO do módulo
            local success, result = pcall(func, Library, category)
            if success then
                print("✅ Módulo '"..filename.."' executado com sucesso.")
                return result -- Retorna a função de limpeza
            else
                warn("🔥🔥 ERRO AO EXECUTAR o módulo '"..filename.."' 🔥🔥")
                warn("🔴 O erro é: ", result)
                warn("🔴 O script pode estar instável.")
            end
        else
            warn("🔥🔥 ERRO DE SINTAXE no arquivo '"..filename.."' 🔥🔥")
            warn("🔴 O erro de compilação é: ", compile_err)
        end
    end
    return function() print("Cleanup vazio para módulo falho:", filename) end
end

-- Carrega todos os módulos com log detalhado
local cleanupFuncs = {}
cleanupFuncs.aimbot = LoadModule("aimbot.lua", Combat)
cleanupFuncs.esp = LoadModule("esp.lua", Visual)
cleanupFuncs.nametag = LoadModule("nametag.lua", Visual)
cleanupFuncs.movement = LoadModule("movement.lua", Movement)
cleanupFuncs.teleport = LoadModule("teleport.lua", Teleport)
cleanupFuncs.freecam = LoadModule("freecam.lua", Movement)


-- Etapa 4: Configurar Limpeza Geral
print("\n--- Etapa 4: Configurando Limpeza Geral ---")
local function FullCleanup()
    print("🧹 Removendo todos os módulos...")
    for name, cleanup in pairs(cleanupFuncs) do
        if type(cleanup) == 'function' then
            pcall(cleanup)
            print("🧼 Módulo '"..name.."' limpo.")
        end
    end
    print("✅ Todos os módulos removidos!")
end

Library:AddKeybind("Remover Script", Enum.KeyCode.K, function(key, pressed)
    if pressed then
        FullCleanup()
        local guiLib = game.Players.LocalPlayer.PlayerGui:FindFirstChild("ManusGuiLib")
        if guiLib then guiLib:Destroy() end
        print("✅ Script completamente removido!")
    end
end)
print("✅ Keybind de remoção configurado.")


print("\n\n🎉🎉 DIAGNÓSTICO FINALIZADO. Se as categorias não apareceram, por favor, envie uma imagem do console (F9) para análise. 🎉🎉")
print("👉 Pressione INSERT para abrir o menu.")
