-- ========== LOADER PRINCIPAL ==========
print("🔧 Iniciando carregamento...")

-- Carrega a biblioteca GUI do seu próprio repositório
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/RobloxScriptPrivate/aimbot/refs/heads/main/gui.lua"))()

task.wait(0.5)

-- CRIA AS CATEGORIAS UMA ÚNICA VEZ
local Combat = Library:CreateCategory("⚔️ Combat", UDim2.new(0, 10, 0, 60))
local Visual = Library:CreateCategory("👁️ Visual", UDim2.new(0, 10, 0, 100))

task.wait(0.2)

-- Carrega os módulos (passando as categorias corretamente)
local function LoadModule(url, category)
    local func = loadstring(game:HttpGet(url))
    if func then
        return func(Library, category)
    end
end

local cleanupAimbot = LoadModule("https://raw.githubusercontent.com/RobloxScriptPrivate/aimbot/refs/heads/main/aimbot.lua", Combat)
local cleanupESP = LoadModule("https://raw.githubusercontent.com/RobloxScriptPrivate/aimbot/refs/heads/main/esp.lua", Visual)
local cleanupNametag = LoadModule("https://raw.githubusercontent.com/RobloxScriptPrivate/aimbot/refs/heads/main/nametag.lua", Visual)

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
print("✅ TODOS OS MÓDULOS CARREGADOS!")
print("")
print("👉 Pressione INSERT para abrir o menu")
