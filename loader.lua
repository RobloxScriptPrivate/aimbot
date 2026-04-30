-- ========== LOADER PRINCIPAL (100% REMOTO) ==========
print("🔧 Iniciando carregamento remoto v3...")

local BASE_URL = "https://raw.githubusercontent.com/RobloxScriptPrivate/aimbot/main/"

-- Função para buscar e carregar código da URL
local function fetch(file)
    local url = BASE_URL .. file
    local success, content = pcall(function() return game:HttpGet(url) end)
    if success and content then
        print("✅ Conteúdo de '"..file.."' baixado.")
        return content
    else
        print("❌ Falha ao baixar '"..file.."' da URL: " .. url)
        return nil
    end
end

-- Carrega a biblioteca GUI
local gui_code = fetch("gui.lua")
if not gui_code then
    print("❌ ERRO CRÍTICO: Não foi possível carregar a GUI. O script não pode continuar.")
    return
end
local Library = loadstring(gui_code)()
print("✅ Biblioteca GUI carregada.")

task.wait(0.5)

-- CRIA AS CATEGORIAS UMA ÚNICA VEZ
local Combat = Library:CreateCategory("⚔️ Combat", UDim2.new(0, 10, 0, 60))
local Visual = Library:CreateCategory("👁️ Visual", UDim2.new(0, 10, 0, 100))
print("✅ Categorias criadas.")

task.wait(0.2)

-- Carrega os módulos (passando as categorias corretamente)
local function LoadModule(filename, category)
    local code = fetch(filename)
    if code then
        local func = loadstring(code)
        if func then
            -- Passa a Library e a Categoria para o módulo
            print("🔧 Carregando módulo: "..filename)
            local success, cleanupFunc = pcall(func, Library, category)
            if success then
                print("✅ Módulo '"..filename.."' carregado com sucesso.")
                return cleanupFunc
            else
                print("❌ Erro ao executar o módulo '"..filename.."':", cleanupFunc) -- 'cleanupFunc' will be the error message here
            end
        end
    end
    -- Retorna uma função de limpeza vazia em caso de falha
    return function() print("Cleanup vazio para módulo falho:", filename) end
end

-- Carrega os módulos
local cleanupAimbot = LoadModule("aimbot.lua", Combat)
local cleanupESP = LoadModule("esp.lua", Visual)
local cleanupNametag = LoadModule("nametag.lua", Visual)

-- Função de limpeza completa
local function FullCleanup()
    print("🧹 Removendo todos os módulos...")
    if cleanupAimbot and type(cleanupAimbot) == 'function' then cleanupAimbot() end
    if cleanupESP and type(cleanupESP) == 'function' then cleanupESP() end
    if cleanupNametag and type(cleanupNametag) == 'function' then cleanupNametag() end
    print("✅ Todos os módulos removidos!")
end

-- Tecla K para remover tudo
Library:AddKeybind("Remover Script", Enum.KeyCode.K, function(key, pressed)
    if pressed then
        FullCleanup()
        local guiLib = game.Players.LocalPlayer.PlayerGui:FindFirstChild("ManusGuiLib")
        if guiLib then guiLib:Destroy() end
        print("✅ Script completamente removido!")
    end
end)

print("\n✅ TODOS OS MÓDULOS CARREGADOS!\n👉 Pressione INSERT para abrir o menu")