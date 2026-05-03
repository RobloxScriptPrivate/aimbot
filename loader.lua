-- ========== LOADER PRINCIPAL (v16 - Final) ==========
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

-- Etapa 1: Carregar a biblioteca GUI v7.0 (Restaurada e Consertada)
print("\n--- Etapa 1: Carregando GUI v7.0 ---")
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
print("✅ Biblioteca GUI v7.0 carregada e executada.")


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

local cleanupFuncs = {}
cleanupFuncs.aimbot   = LoadModule("aimbot.lua",   Combat)
cleanupFuncs.hitbox   = LoadModule("hitbox.lua",   Combat)
cleanupFuncs.esp      = LoadModule("esp.lua",      Visual)
cleanupFuncs.nametag  = LoadModule("nametag.lua",  Visual)
cleanupFuncs.movement = LoadModule("movement.lua", Movement)
cleanupFuncs.teleport = LoadModule("teleport.lua", Teleport)


-- Etapa 3.5: Módulo de Scanner de Mapa (Usando GUI v7.0)
print("\n--- Etapa 3.5: Adicionando Scanner de Mapa ---")
do
    local scanWindow
    local function runMapScan()
        if scanWindow and scanWindow.Frame.Parent then scanWindow.Frame:Destroy() end
        scanWindow = Library:CreateWindow("Resultado do Scan", UDim2.new(0, 500, 0, 400))
        local statusLabel = scanWindow:AddLabel("Varredura em andamento...", true)

        task.spawn(function()
            local logLines = {}
            local function scan(instance, depth)
                if depth > 10 then return end
                pcall(function()
                    if string.find(string.lower(instance.Name), "tool") or string.find(string.lower(instance.Name), "giver") or instance:IsA("Tool") then
                        table.insert(logLines, instance:GetFullName())
                    end
                    for _, child in ipairs(instance:GetChildren()) do scan(child, depth + 1) end
                end)
            end
            scan(workspace, 0)
            statusLabel:Destroy()

            local fullLog = table.concat(logLines, "\n")
            if #fullLog == 0 then fullLog = "Nenhum item (tool, giver) encontrado." end

            local scrollList = scanWindow:AddScrollableList()
            local logBox = Instance.new("TextBox")
            logBox.Size = UDim2.new(1, 0, 0, #logLines * 16 + 20)
            logBox.Text = fullLog; logBox.MultiLine = true; logBox.ReadOnly = true; logBox.Font = Enum.Font.Code; logBox.TextSize = 12; logBox.TextColor3 = Color3.fromRGB(240, 240, 240); logBox.BackgroundTransparency = 1; logBox.TextXAlignment = Enum.TextXAlignment.Left; logBox.TextYAlignment = Enum.TextYAlignment.Top; logBox.Parent = scrollList

            local copyButton = scanWindow:AddButton("Copiar Logs", function() setclipboard(fullLog) end)
            copyButton.Size = UDim2.new(1, -10, 0, 30)
            copyButton.Position = UDim2.new(0, 5, 1, -35)
        end)
    end
    Misc:AddModule("🔬 Scan do Mapa", runMapScan, true)
    print("✅ Módulo de Scanner (v7.0) adicionado.")
end

-- Etapa 3.6: Módulo Arsenal (Usando GUI v7.0)
print("\n--- Etapa 3.6: Adicionando Arsenal ---")
do
    local arsenalWindow, weaponListFrame
    local toolGiverNames = { "ToolGiver1P1", "ToolGiver1P2", "ToolGiver2P1", "ToolGiver3P1", "ToolGiver3P2", "ToolGiver4P1", "ToolGiver4P2", "ToolGiver5", "ToolGiver5P1", "ToolGiver5P2", "ToolGiver6P1", "ToolGiver6P2", "ToolGiver7P1", "ToolGiver7P2", "ToolGiver8P1", "ToolGiver8P2", "ToolGiver9P1", "ToolGiver9P2", "ToolGiver10P1", "ToolGiver10P2", "ToolGiver11P1", "ToolGiver11P2", "ToolGiver12P1", "ToolGiver12P2", "ToolGiver13P1", "ToolGiver13P2", "ToolGiver14P1", "ToolGiver14P2", "ToolGiver100" }

    local function scanAndPopulateWeapons()
        if not weaponListFrame then return end
        weaponListFrame:ClearAllChildren()
        local tycoons = workspace:FindFirstChild("Tycoons")
        if not tycoons then weaponListFrame:AddLabel("Pasta 'Tycoons' não encontrada.", true); return end

        local weaponsFound = 0
        for _, tycoon in ipairs(tycoons:GetChildren()) do
            local purchased = tycoon:FindFirstChild("PurchasedObjects")
            if purchased then
                for _, toolGiverName in ipairs(toolGiverNames) do
                    local toolGiver = purchased:FindFirstChild(toolGiverName)
                    if toolGiver and toolGiver:FindFirstChild("Touch") and toolGiver:FindFirstChildOfClass("Tool") then
                        weaponsFound = weaponsFound + 1
                        local tool = toolGiver:FindFirstChildOfClass("Tool")
                        local btn = Instance.new("TextButton"); btn.Name = tool.Name; btn.Text = tool.Name; btn.Size = UDim2.new(1, -10, 0, 25); btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); btn.TextColor3 = Color3.fromRGB(220, 220, 220); btn.Font = Enum.Font.SourceSansBold; btn.Parent = weaponListFrame; Instance.new("UICorner", btn)
                        btn.MouseButton1Click:Connect(function()
                            if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.HumanoidRootPart then
                                toolGiver.Touch.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                            end
                        end)
                    end
                end
            end
        end
        if weaponsFound == 0 then weaponListFrame.Parent:AddLabel("Nenhuma arma encontrada nos tycoons.", true) end
    end

    local function openArsenalWindow()
        if not arsenalWindow or not arsenalWindow.Frame.Parent then
            arsenalWindow = Library:CreateWindow("Arsenal do Mapa", UDim2.new(0, 300, 0, 400))
            weaponListFrame = arsenalWindow:AddScrollableList()
            local refreshBtn = arsenalWindow:AddButton("Atualizar", scanAndPopulateWeapons)
            refreshBtn.Size = UDim2.new(1, -10, 0, 30); refreshBtn.Position = UDim2.new(0, 5, 1, -35)
            scanAndPopulateWeapons()
        end
        arsenalWindow.Frame.Visible = not arsenalWindow.Frame.Visible
    end
    Misc:AddModule("🔫 Arsenal", openArsenalWindow, true)
    print("✅ Módulo de Arsenal (v7.0) adicionado.")
end


-- Etapa 3.7: Módulo Killaura
print("\n--- Etapa 3.7: Adicionando Killaura ---")
Misc:AddModule("🎯 Killaura", function(enabled) Library.Killaura.Enabled = enabled end):AddSlider("Distância: ", 5, 50, Library.Killaura.Distance, function(val) Library.Killaura.Distance = val end)
print("✅ Módulo Killaura adicionado.")


-- Etapa 4: Lógica do Killaura
coroutine.wrap(function()
    while true do
        if Library.Killaura.Enabled and Library.Killaura.Target and Library.Killaura.Target.Character then
            local char = game.Players.LocalPlayer.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Handle") then
                local targetPart = Library.Killaura.Target.Character:FindFirstChild("HumanoidRootPart")
                if targetPart and (targetPart.Position - char.HumanoidRootPart.Position).Magnitude <= Library.Killaura.Distance then
                    firetouchinterest(tool.Handle, targetPart, 0); firetouchinterest(tool.Handle, targetPart, 1)
                end
            end
        end
        task.wait(0.1)
    end
end)()


-- Etapa 5: Restaurar posições e finalizar
print("\n--- Etapa 5: Finalizando ---")
task.wait(0.05)
if Library.RestoreCategoryPositions then Library:RestoreCategoryPositions(); print("✅ Posições restauradas.") end
local sg = Library.ScreenGui
if sg then sg.Destroying:Connect(function() for _, f in pairs(cleanupFuncs) do if type(f) == "function" then pcall(f) end end end) end

print("\n\n🎉🎉 CARREGAMENTO FINALIZADO. Tudo pronto. 🎉🎉")
print("👉 Pressione INSERT para abrir o menu. Pressione K para remover o script.")
