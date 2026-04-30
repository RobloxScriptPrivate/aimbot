-- ========== LOADER PRINCIPAL (VERSÃO LOCAL) ==========
print("🔧 Iniciando carregamento local...")

-- Função para carregar código de um arquivo local
-- Nota: readfile() é uma função comum em muitos executores.
-- Se o seu usar uma função diferente, você precisará ajustar aqui.
local function LoadCodeFromFile(filename)
    local success, code = pcall(readfile, filename)
    if success and code then
        return code
    else
        print("❌ Falha ao ler o arquivo local:", filename)
        -- Tenta carregar da URL como fallback
        print("🔧 Tentando carregar da URL original...")
        local fallbackUrl = "https://raw.githubusercontent.com/RobloxScriptPrivate/aimbot/refs/heads/main/" .. filename
        local success_http, code_http = pcall(function() return game:HttpGet(fallbackUrl) end)
        if success_http and code_http then
            print("✅ Fallback via HTTP bem-sucedido para:", filename)
            return code_http
        else
            print("❌ Falha ao carregar via HTTP também. Verifique o nome do arquivo e a conexão.")
            return nil
        end
    end
end

-- Carrega a biblioteca GUI
local gui_code = LoadCodeFromFile("gui.lua")
if not gui_code then
    print("❌ ERRO CRÍTICO: Não foi possível carregar a GUI. O script não pode continuar.")
    return
end
local Library = loadstring(gui_code)()

task.wait(0.5)

-- CRIA AS CATEGORIAS UMA ÚNICA VEZ
local Combat = Library:CreateCategory("⚔️ Combat", UDim2.new(0, 10, 0, 60))
local Visual = Library:CreateCategory("👁️ Visual", UDim2.new(0, 10, 0, 100))

task.wait(0.2)

-- Carrega os módulos (passando as categorias corretamente)
local function LoadModule(filename, category)
    local code = LoadCodeFromFile(filename)
    if code then
        local func = loadstring(code)
        if func then
            -- Passa a Library e a Categoria para o módulo
            return func(Library, category) 
        end
    end
    -- Retorna uma função de limpeza vazia em caso de falha
    return function() print("Cleanup vazio para módulo falho:", filename) end
end

-- Carrega os módulos locais
local cleanupAimbot = LoadModule("aimbot.lua", Combat)
local cleanupESP = LoadModule("esp.lua", Visual)
local cleanupNametag = LoadModule("nametag.lua", Visual)

-- Função de limpeza completa
local function FullCleanup()
    print("🧹 Removendo todos os módulos...")
    if cleanupAimbot then cleanupAimbot() end
    if cleanupESP then cleanupESP() end
    if cleanupNametag then cleanupNametag() end
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

print("")
print("✅ TODOS OS MÓDULOS CARREGADOS LOCALMENTE!")
print("")
print("👉 Pressione INSERT para abrir o menu")
