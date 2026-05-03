-- LOADER (Revertido para o commit estável ed2a767, com módulo de Arsenal)

print("🔧 Iniciando Loader (Commit ed2a767)")

-- URL Base para os scripts
local BASE_URL = "https://raw.githubusercontent.com/RobloxScriptPrivate/aimbot/main/"

-- Adiciona um parâmetro aleatório para evitar cache
local function getURL(file)
    return BASE_URL .. file .. "?v=" .. os.time() .. "&r=" .. math.random(1, 99999)
end

-- Etapa 1: Carregar a Biblioteca GUI
print("--- Etapa 1: Carregando GUI...")
local gui_code, err = pcall(game.HttpGet, game, getURL("gui.lua"), true)
if not (gui_code and not err) then
    warn("❌ Falha no download da biblioteca GUI. Verifique a conexão ou a URL.")
    return
end

local success, Library = pcall(loadstring(gui_code))
if not success or type(Library) ~= "function" then
    warn("❌ Falha ao carregar o código da GUI. Erro: " .. tostring(Library))
    return
end

Library = Library()
if type(Library) ~= "table" then
    warn("❌ A biblioteca GUI não inicializou corretamente.")
    return
end

print("✅ Biblioteca GUI carregada e executada.")


-- Etapa 2: Criar as Categorias da UI
print("--- Etapa 2: Criando Categorias...")
local Combat   = Library:CreateCategory("⚔️ Combat",    UDim2.new(0, 10, 0, 120))
local Visual   = Library:CreateCategory("👁️ Visual",    UDim2.new(0, 170, 0, 120))
local Movement = Library:CreateCategory("🏃 Movimento", UDim2.new(0, 330, 0, 120))
local Teleport = Library:CreateCategory("🌌 Teleporte", UDim2.new(0, 490, 0, 120))
local Misc     = Library:CreateCategory("✨ Misc",      UDim2.new(0, 650, 0, 120))
print("✅ Categorias criadas.")


-- Etapa 3: Carregar os Módulos Individuais
print("--- Etapa 3: Carregando Módulos...")
local function LoadModule(filename, category)
    print(" ↳ Carregando Módulo: '" .. filename .. "'...")
    local code, fetch_err = pcall(game.HttpGet, game, getURL(filename), true)
    if code and not fetch_err then
        local s, exec_err = pcall(loadstring(code), Library, category)
        if not s then warn("🔥 Erro ao executar '"..filename.."':", exec_err) end
    else
        warn("⚠️ Falha no download de: "..filename)
    end
end

LoadModule("aimbot.lua", Combat)
LoadModule("hitbox.lua", Combat)
LoadModule("esp.lua",    Visual)
LoadModule("nametag.lua",Visual)
LoadModule("movement.lua", Movement)
LoadModule("teleport.lua", Teleport)

-- Carregando o novo módulo de Arsenal
LoadModule("armas.lua", Misc)

print("\n🎉 Todos os módulos, incluindo o novo Arsenal, foram carregados.")
