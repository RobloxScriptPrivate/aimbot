-- ========== LOADER PRINCIPAL (v16 - Auto Collect) ==========
print("🔧 Iniciando carregamento v16. Pressione F9 para ver os logs.")

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

local autoCollectModule = Misc:AddModule("💵 Auto Collect", function(enabled)
    getgenv().AutoCollectMoney = enabled
    print("Auto Collect " .. (enabled and "ativado" or "desativado"))
end)
print("✅ Módulo Auto Collect adicionado.")


-- Etapa 4: Lógica dos Módulos (em background)
print("\n--- Etapa 4: Iniciando loops de background ---")

-- Loop do Killaura
local function attackTarget(targetChar)
    local char = game:GetService("Players").LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool or not tool:FindFirstChild("Handle") then return end
    local targetPart = targetChar:FindFirstChildWhichIsA("BasePart")
    if not targetPart then return end
    if tool:FindFirstChild("Use") then
        tool.Use:FireServer()
    end
    firetouchinterest(tool.Handle, targetPart, 0)
    firetouchinterest(tool.Handle, targetPart, 1)
end

coroutine.wrap(function()
    while true do
        if Library.Killaura.Enabled and Library.Killaura.Target then
            local targetPlayer = Library.Killaura.Target
            if targetPlayer and targetPlayer.Character then
                local hum = targetPlayer.Character:FindFirstChild("Humanoid")
                local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local localChar = game:GetService("Players").LocalPlayer.Character
                if hum and hum.Health > 0 and hrp and localChar and localChar:FindFirstChild("HumanoidRootPart") then
                    local dist = (hrp.Position - localChar.HumanoidRootPart.Position).Magnitude
                    if dist <= Library.Killaura.Distance then
                        attackTarget(targetPlayer.Character)
                    end
                else
                    Library.Killaura.Target = nil
                end
            end
        end
        wait(0.1)
    end
end)()
print("✅ Loop do Killaura iniciado.")

-- Loop do Auto Collect Money
coroutine.wrap(function()
    while true do
        if getgenv().AutoCollectMoney then
            local Character = game:GetService("Players").LocalPlayer.Character
            if Character and Character:FindFirstChild("HumanoidRootPart") then
                local RootPart = Character.HumanoidRootPart
                 for _, tycoon in ipairs(workspace.Tycoons:GetChildren()) do
                    local essentials = tycoon:FindFirstChild("Essentials")
                    if essentials then
                        local collectorP1 = essentials:FindFirstChild("CollectorP1")
                        local collectorP2 = essentials:FindFirstChild("CollectorP2")

                        if collectorP1 and collectorP1:FindFirstChild("Touch") then
                            firetouchinterest(collectorP1.Touch, RootPart, 0)
                            firetouchinterest(collectorP1.Touch, RootPart, 1)
                        end

                        if collectorP2 and collectorP2:FindFirstChild("Touch") then
                            firetouchinterest(collectorP2.Touch, RootPart, 0)
                            firetouchinterest(collectorP2.Touch, RootPart, 1)
                        end
                    end
                end
            end
        end
        wait(1) -- Espera 1 segundo para não sobrecarregar
    end
end)()
print("✅ Loop do Auto Collect iniciado.")


-- Etapa 5: Restaurar posições das categorias
print("\n--- Etapa 5: Restaurando posicoes das categorias ---")
task.wait(0.05)
if Library.RestoreCategoryPositions then
    Library:RestoreCategoryPositions()
    print("✅ Posicoes e estados das categorias restaurados.")
end

-- Etapa 6: Cleanup global
print("\n--- Etapa 6: Configurando Limpeza Global ---")
local sg = Library.ScreenGui
if sg then
    sg.Destroying:Connect(function()
        print("🧹 ScreenGui destruído — executando cleanup de todos os módulos...")
        getgenv().AutoCollectMoney = false
        Library.Killaura.Enabled = false
        for name, fn in pairs(cleanupFuncs) do
            if type(fn) == "function" then
                pcall(fn)
            end
        end
        print("✅ Cleanup global concluído.")
    end)
    print("✅ Cleanup global conectado ao ScreenGui.Destroying.")
else
    warn("⚠️ Library.ScreenGui não encontrado — cleanup automático não será executado.")
end

print("\n\n🎉🎉 CARREGAMENTO FINALIZADO. Tudo pronto. 🎉🎉")
print("👉 Pressione INSERT para abrir o menu. Pressione K para remover o script.")
