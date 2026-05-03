-- ========== LOADER PRINCIPAL (v15 - Killaura Integrado) ==========
print("🔧 Iniciando carregamento v15. Pressione F9 para ver os logs.")

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


-- Etapa 3.5: Adicionar o Módulo Arsenal (Com a lógica do script FelixXLS)
print("\n--- Etapa 3.5: Adicionando Arsenal (Lógica Corrigida) ---")
do
    local arsenalWindow

    -- Lista de nomes exatos (do script que você forneceu)
    local toolGiverNames = {
        "ToolGiver1P1", "ToolGiver1P2", "ToolGiver2P1", "ToolGiver3P1", "ToolGiver3P2",
        "ToolGiver4P1", "ToolGiver4P2", "ToolGiver5", "ToolGiver5P1", "ToolGiver5P2",
        "ToolGiver6P1", "ToolGiver6P2", "ToolGiver7P1", "ToolGiver7P2", "ToolGiver8P1",
        "ToolGiver8P2", "ToolGiver9P1", "ToolGiver9P2", "ToolGiver10P1", "ToolGiver10P2",
        "ToolGiver11P1", "ToolGiver11P2", "ToolGiver12P1", "ToolGiver12P2", "ToolGiver13P1",
        "ToolGiver13P2", "ToolGiver14P1", "ToolGiver14P2", "ToolGiver100"
    }

    local function scanAndPopulateWeapons()
        if not arsenalWindow or not arsenalWindow.Frame then return end
        
        for _, child in ipairs(arsenalWindow.Container:GetChildren()) do
            if child:IsA("TextButton") and child.Name ~= "Atualizar Lista" then
                child:Destroy()
            end
        end

        print("[Arsenal] Escaneando Tycoons com lista de nomes exatos...")
        local tycoonsFolder = workspace:FindFirstChild("Tycoons")
        if not tycoonsFolder then
            warn("[Arsenal] Pasta 'Tycoons' não encontrada.")
            return
        end

        local weaponsFound = 0
        for _, tycoon in ipairs(tycoonsFolder:GetChildren()) do
            local purchased = tycoon:FindFirstChild("PurchasedObjects")
            if purchased then
                -- Itera sobre a lista de nomes exatos
                for _, toolGiverName in ipairs(toolGiverNames) do
                    local toolGiver = purchased:FindFirstChild(toolGiverName)
                    if toolGiver then
                        local tool = toolGiver:FindFirstChildOfClass("Tool")
                        local touchPart = toolGiver:FindFirstChild("Touch")
                        
                        if tool and touchPart and touchPart:IsA("BasePart") then
                            weaponsFound = weaponsFound + 1
                            
                            local weaponButton = arsenalWindow:AddButton(tool.Name, function()
                                print("[Arsenal] Coletando arma: " .. tool.Name .. " com método de teleporte.")
                                local RootPart = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if RootPart then
                                    -- Método de coleta do script FelixXLS
                                    local originalCFrame = touchPart.CFrame
                                    touchPart.Anchored = false
                                    touchPart.CFrame = RootPart.CFrame
                                    task.wait(0.1)
                                    -- Opcional: mover de volta para não deixar o mapa bagunçado
                                    -- touchPart.CFrame = originalCFrame
                                end
                            end)
                            weaponButton.Name = tool.Name
                        end
                    end
                end
            end
        end
        print("[Arsenal] Escaneamento concluído. " .. weaponsFound .. " armas encontradas.")
    end

    local function openArsenalWindow()
        if not arsenalWindow or not arsenalWindow.Frame.Parent then 
            arsenalWindow = Library:CreateWindow("Arsenal do Mapa", UDim2.new(0, 300, 0, 400), UDim2.new(0.5, -150, 0.5, -200))
            if arsenalWindow.Title then
                arsenalWindow.Title.Font = Enum.Font.SourceSansBold
                arsenalWindow.Title.TextSize = 16
            end

            local refreshBtn = arsenalWindow:AddButton("Atualizar Lista", scanAndPopulateWeapons)
            refreshBtn.Name = "Atualizar Lista"

            task.wait(0.1)
            scanAndPopulateWeapons()
        end
        arsenalWindow.Frame.Visible = not arsenalWindow.Frame.Visible
    end

    Misc:AddModule("🔫 Arsenal", openArsenalWindow, true)
    print("✅ Módulo de Arsenal integrado com a lógica correta.")
end


-- Etapa 3.6: Adicionar o Módulo Killaura diretamente
print("\n--- Etapa 3.6: Adicionando Killaura ---")
local killauraModule = Misc:AddModule("🎯 Killaura", function(enabled)
    Library.Killaura.Enabled = enabled
end)

if killauraModule then
    killauraModule:AddSlider("Distância: ", 5, 50, Library.Killaura.Distance, function(val)
        Library.Killaura.Distance = val
    end)
    print("✅ Módulo Killaura adicionado à categoria Misc.")
end


-- Etapa 4: Lógica do Killaura (integrada)
print("\n--- Etapa 4: Iniciando loop do Killaura ---")
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

local killauraLoop
killauraLoop = coroutine.wrap(function()
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
end)
killauraLoop()


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
        for name, fn in pairs(cleanupFuncs) do
            if type(fn) == "function" then
                pcall(fn)
            end
        end
        if killauraLoop and coroutine.status(killauraLoop) ~= "dead" then
        end
        print("✅ Cleanup global concluído.")
    end)
    print("✅ Cleanup global conectado ao ScreenGui.Destroying.")
else
    warn("⚠️ Library.ScreenGui não encontrado — cleanup automático não será executado.")
end

print("\n\n🎉🎉 CARREGAMENTO FINALIZADO. Tudo pronto. 🎉🎉")
print("👉 Pressione INSERT para abrir o menu. Pressione K para remover o script.")
