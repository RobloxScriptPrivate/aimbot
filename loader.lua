-- ========== LOADER PRINCIPAL (v22 - Logic Overhaul by User) ==========
print("🔧 Iniciando carregamento v22. Sua lógica foi implementada. Obrigado!")

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
        if func then 
            pcall(func, Library, category)
        end
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
    local KillauraModule = Combat:AddModule("🎯 Killaura", function(state)
        Library.Killaura.Enabled = state
    end, false)
    KillauraModule:AddSlider("Distância", 5, 50, Library.Killaura.Distance, function(val) Library.Killaura.Distance = val end)
    game:GetService("RunService").Heartbeat:Connect(function()
        if not Library.Killaura.Enabled or not Library.Killaura.Target then return end
        local target = Library.Killaura.Target
        local localChar = game.Players.LocalPlayer.Character
        if target and target.Character and localChar and localChar:FindFirstChild("HumanoidRootPart") then
            local hum = target.Character:FindFirstChildOfClass("Humanoid")
            local root = target.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and root then
                if (root.Position - localChar.HumanoidRootPart.Position).Magnitude <= Library.Killaura.Distance then
                    local tool = localChar:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Handle") then
                        pcall(function() 
                            firetouchinterest(tool.Handle, root, 0); firetouchinterest(tool.Handle, root, 1) 
                        end)
                    end
                end
            end
        end
    end)
end

--[[
    Módulo Pegar Todas as Armas (Sua Lógica)
]]
do
    local autoGetRunning = false
    local autoGetThread = nil

    local toolGiverNames = {
        "ToolGiver1P1", "ToolGiver1P2", "ToolGiver2P1", "ToolGiver2P2", "ToolGiver3P1", "ToolGiver3P2",
        "ToolGiver4P1", "ToolGiver4P2", "ToolGiver5", "ToolGiver5P1", "ToolGiver5P2", "ToolGiver6P1",
        "ToolGiver6P2", "ToolGiver7P1", "ToolGiver7P2", "ToolGiver8P1", "ToolGiver8P2", "ToolGiver9P1",
        "ToolGiver9P2", "ToolGiver10P1", "ToolGiver10P2", "ToolGiver11P1", "ToolGiver11P2", "ToolGiver12P1",
        "ToolGiver12P2", "ToolGiver13P1", "ToolGiver13P2", "ToolGiver14P1", "ToolGiver14P2", "ToolGiver100",
        "DToolGiver1P1", "DToolGiver1P2"
    }

    Misc:AddModule("📦 Pegar Todas as Armas", function(state)
        autoGetRunning = state
        if state then
            autoGetThread = task.spawn(function()
                local TycoonsFolder = workspace:WaitForChild("Tycoons", 30)
                if not TycoonsFolder then 
                    warn("[AutoGet] Pasta Tycoons não encontrada.")
                    return 
                end

                while autoGetRunning do
                    local character = game.Players.LocalPlayer.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

                    if rootPart then
                        for _, tycoon in ipairs(TycoonsFolder:GetChildren()) do
                            local purchased = tycoon:FindFirstChild("PurchasedObjects")
                            if purchased then
                                for _, toolGiverName in ipairs(toolGiverNames) do
                                    local toolGiver = purchased:FindFirstChild(toolGiverName)
                                    if toolGiver then
                                        local touchPart = toolGiver:FindFirstChild("Touch")
                                        if touchPart and touchPart:IsA("BasePart") and touchPart:FindFirstChildOfClass("TouchTransmitter") then
                                            pcall(function() -- Usar pcall para evitar erros
                                                touchPart.Anchored = false
                                                touchPart.CFrame = rootPart.CFrame
                                            end)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait(1) -- Espera para não sobrecarregar
                end
            end)
        else
            if autoGetThread then
                task.cancel(autoGetThread)
                autoGetThread = nil
            end
        end
    end, false)
end

print("✅ Carregamento Finalizado (v22).")
