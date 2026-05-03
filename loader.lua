-- ========== LOADER PRINCIPAL (v25 - User-Designed Scan UI) ==========
print("🔧 Iniciando carregamento v25. Design do Scan atualizado para o seu.")

local BASE_URL = "https://raw.githubusercontent.com/RobloxScriptPrivate/aimbot/main/"

local function fetch(file)
    local cache_buster = "?v=" .. os.time() .. "&r=" .. math.random(1, 1000000)
    local url = BASE_URL .. file .. cache_buster
    local success, content = pcall(function() return game:HttpGet(url, true) end)
    if success and content and #content > 0 then return content end
    warn("❌ Erro ao baixar: "..file)
    return nil
end

local gui_code = fetch("gui.lua")
if not gui_code then return end
local Library = loadstring(gui_code)()
if not Library then return end

local startX, startY, catWidth, spacing = 10, 120, 150, 10
local Combat   = Library:CreateCategory("⚔️ Combat",    UDim2.new(0, startX, 0, startY))
local Visual   = Library:CreateCategory("👁️ Visual",    UDim2.new(0, startX + catWidth + spacing, 0, startY))
local Movement = Library:CreateCategory("🏃 Movimento", UDim2.new(0, startX + (catWidth + spacing) * 2, 0, startY))
local Teleport = Library:CreateCategory("🌌 Teleporte", UDim2.new(0, startX + (catWidth + spacing) * 3, 0, startY))
local Misc     = Library:CreateCategory("✨ Misc",      UDim2.new(0, startX + (catWidth + spacing) * 4, 0, startY))

local function LoadModule(filename, category)
    local code = fetch(filename)
    if code then
        local func, err = loadstring(code)
        if func then pcall(func, Library, category) end
    end
end

-- Carregar módulos externos
LoadModule("aimbot.lua",   Combat)
LoadModule("hitbox.lua",   Combat)
LoadModule("esp.lua",      Visual)
LoadModule("nametag.lua",  Visual)
LoadModule("movement.lua", Movement)
LoadModule("teleport.lua", Teleport)

--[[
    KILLAURA INTEGRADO
]]
do
    local KillauraModule = Combat:AddModule("🎯 Killaura", function(state) Library.Killaura.Enabled = state end, false)
    KillauraModule:AddSlider("Distância", 5, 50, Library.Killaura.Distance, function(val) Library.Killaura.Distance = val end)
    game:GetService("RunService").Heartbeat:Connect(function()
        if not Library.Killaura.Enabled or not Library.Killaura.Target then return end
        local target, localChar = Library.Killaura.Target, game.Players.LocalPlayer.Character
        if target and target.Character and localChar and localChar:FindFirstChild("HumanoidRootPart") then
            local root = target.Character:FindFirstChild("HumanoidRootPart")
            if root and (root.Position - localChar.HumanoidRootPart.Position).Magnitude <= Library.Killaura.Distance then
                local tool = localChar:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Handle") then pcall(function() firetouchinterest(tool.Handle, root, 0); firetouchinterest(tool.Handle, root, 1) end) end
            end
        end
    end)
end

--[[
    Módulo de Scan Estrutural (v2 - Seu Design)
]]
do
    local function runStructuralScan()
        -- 1. Cria uma janela de status pequena e temporária
        local scanWindow = Library:CreateWindow("🔬 Scan em Progresso...", UDim2.new(0.5, -150, 0.5, -50), 300, 100)
        scanWindow:AddLabel("Scan rodando... Verifique o console (F9).", true)

        -- 2. Inicia o scan em uma nova thread para não travar a UI
        task.spawn(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local output = {}

            local function scan(instance, depth)
                pcall(function()
                    local indent = string.rep("  ", depth)
                    table.insert(output, indent .. "[" .. instance.ClassName .. "] " .. instance.Name)
                    for _, child in ipairs(instance:GetChildren()) do
                        scan(child, depth + 1)
                    end
                end)
            end

            print("--- INICIANDO SCAN DO REPLICATEDSTORAGE (v25) ---")
            table.insert(output, "--- INICIANDO SCAN DO REPLICATEDSTORAGE (v25) ---")
            
            scan(ReplicatedStorage, 1)

            print("--- SCAN FINALIZADO ---")
            table.insert(output, "--- SCAN FINALIZADO ---")
            
            local fullLog = table.concat(output, "\n")

            -- 3. Limpa a janela temporária e adiciona o botão de copiar
            scanWindow.Frame.Content:ClearAllChildren()
            scanWindow.Frame.Title.Text = "🔬 Scan Concluído"
            
            local copyButton = scanWindow:AddButton("Copiar Logs", function() 
                if setclipboard then 
                    setclipboard(fullLog)
                    print("✅ Logs copiados para a área de transferência!")
                    scanWindow.Frame.Title.Text = "✅ Copiado!"
                end
            end)
            copyButton.Size = UDim2.new(0.8, 0, 0.5, 0)
            copyButton.Position = UDim2.new(0.1, 0, 0.25, 0)
        end)
    end

    Misc:AddModule("🔬 Scan Estrutural", runStructuralScan, true)
end

print("✅ Carregamento Finalizado (v25).")
