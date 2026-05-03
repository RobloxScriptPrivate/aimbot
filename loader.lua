-- ========== LOADER PRINCIPAL (v20 - Arsenal Scope Fix) ==========
print("🔧 Iniciando carregamento v20. Pressione F9 para ver os logs.")

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
            local success, result = pcall(func, Library, category)
            if not success then warn("Erro ao executar "..filename..": "..tostring(result)) end
        else
            warn("Erro de sintaxe em "..filename..": "..tostring(err))
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

    KillauraModule:AddSlider("Distância", 5, 50, Library.Killaura.Distance, function(val)
        Library.Killaura.Distance = val
    end)

    local function attackTarget(targetChar)
        local char = game.Players.LocalPlayer.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool or not tool:FindFirstChild("Handle") then return end
        local targetPart = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChildWhichIsA("BasePart")
        if not targetPart then return end
        pcall(function() 
            firetouchinterest(tool.Handle, targetPart, 0)
            firetouchinterest(tool.Handle, targetPart, 1)
        end)
    end

    game:GetService("RunService").Heartbeat:Connect(function()
        if not Library.Killaura.Enabled or not Library.Killaura.Target then return end
        
        local target = Library.Killaura.Target
        local localChar = game.Players.LocalPlayer.Character

        if target and target.Character and localChar and localChar:FindFirstChild("HumanoidRootPart") then
            local hum = target.Character:FindFirstChildOfClass("Humanoid")
            local root = target.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and root then
                local dist = (root.Position - localChar.HumanoidRootPart.Position).Magnitude
                if dist <= Library.Killaura.Distance then
                    attackTarget(target.Character)
                end
            end
        end
    end)
    print("✅ Killaura (Integrado) carregado!")
end

-- Módulo de Scanner de Mapa
do
    local scanWindow
    local function runMapScan()
        if scanWindow and scanWindow.Frame.Parent then scanWindow.Frame:Destroy() end
        scanWindow = Library:CreateWindow("Scan do Mapa", UDim2.new(0, 300, 0, 150))
        scanWindow:AddLabel("Logs detalhados enviados para o F9", true)

        local logLines = {}
        local function scan(instance, depth)
            if depth > 10 then return end
            pcall(function()
                local name = string.lower(instance.Name)
                if name:find("tool") or name:find("giver") or instance:IsA("Tool") or instance:IsA("ClickDetector") then
                    local entry = "[" .. instance.ClassName .. "] " .. instance:GetFullName()
                    table.insert(logLines, entry)
                    print("🔬 Scan: " .. entry)
                end
                for _, child in ipairs(instance:GetChildren()) do scan(child, depth + 1) end
            end)
        end
        
        task.spawn(function()
            print("--- INICIANDO SCAN DO MAPA ---")
            scan(workspace, 0)
            print("--- SCAN FINALIZADO ("..#logLines.." itens) ---")
            
            local fullLog = table.concat(logLines, "\n")
            scanWindow:AddButton("Copiar Logs para Clipboard", function() 
                if setclipboard then setclipboard(fullLog); print("✅ Logs copiados!") end
            end)
        end)
    end
    Misc:AddModule("🔬 Scan do Mapa", runMapScan, true)
end

--[[
    Módulo Arsenal (v2.1 - Busca Corrigida e Focada)
]]
do
    local arsenalWindow, weaponListFrame
    local toolGiverNames = { "ToolGiver", "WeaponGiver", "SwordGiver", "GunGiver" }

    local function scanAndPopulateWeapons()
        if not weaponListFrame then return end
        weaponListFrame:ClearAllChildren()
        local foundCount = 0

        local function lookForGivers(parent)
            for _, obj in ipairs(parent:GetChildren()) do
                local isGiver = false
                for _, name in ipairs(toolGiverNames) do if obj.Name:find(name) then isGiver = true break end end
                
                if isGiver or obj:IsA("Tool") or obj:FindFirstChildOfClass("Tool") then
                    local tool = obj:IsA("Tool") and obj or obj:FindFirstChildOfClass("Tool")
                    
                    if tool and tool:IsA("Tool") then
                        foundCount = foundCount + 1
                        
                        local card = Instance.new("Frame"); card.Size = UDim2.new(0.95, 0, 0, 65); card.BackgroundColor3 = Color3.fromRGB(40, 40, 40); card.BorderSizePixel = 0; card.Parent = weaponListFrame; Instance.new("UICorner", card)
                        local title = Instance.new("TextLabel"); title.Size = UDim2.new(1, -10, 0, 25); title.Position = UDim2.new(0, 5, 0, 5); title.Text = tool.Name; title.Font = Enum.Font.SourceSansBold; title.TextSize = 15; title.TextColor3 = Color3.fromRGB(255, 255, 255); title.TextXAlignment = Enum.TextXAlignment.Left; title.BackgroundTransparency = 1; title.Parent = card
                        local pegarBtn = Instance.new("TextButton"); pegarBtn.Size = UDim2.new(0.4, 0, 0, 28); pegarBtn.Position = UDim2.new(0.05, 0, 0, 32); pegarBtn.Text = "✔️ Pegar"; pegarBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 80); pegarBtn.TextColor3 = Color3.fromRGB(255, 255, 255); pegarBtn.Font = Enum.Font.SourceSansBold; pegarBtn.Parent = card; Instance.new("UICorner", pegarBtn)
                        local tpBtn = Instance.new("TextButton"); tpBtn.Size = UDim2.new(0.4, 0, 0, 28); tpBtn.Position = UDim2.new(0.55, 0, 0, 32); tpBtn.Text = "🌌 TP"; tpBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 160); tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255); tpBtn.Font = Enum.Font.SourceSansBold; tpBtn.Parent = card; Instance.new("UICorner", tpBtn)
                        
                        pegarBtn.MouseButton1Click:Connect(function()
                            local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if not root then return end
                            local touchPart = obj:IsA("BasePart") and obj or obj:FindFirstChild("Handle") or tool:FindFirstChild("Handle")
                            if touchPart then
                                firetouchinterest(root, touchPart, 0); firetouchinterest(root, touchPart, 1)
                                print("[Arsenal] Tentativa de 'Pegar' para: " .. tool.Name)
                            end
                        end)

                        tpBtn.MouseButton1Click:Connect(function()
                            local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if not root then return end
                            local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChild("Handle") or tool:FindFirstChild("Handle")
                            if targetPart and targetPart.Position then
                                root.CFrame = CFrame.new(targetPart.Position) * CFrame.new(0, 3, 0)
                                print("[Arsenal] Teleportado para: " .. tool.Name)
                            end
                        end)
                    end
                end
                if #obj:GetChildren() > 0 then lookForGivers(obj) end
            end
        end
        
        -- CORREÇÃO: Procurar apenas dentro da pasta 'Tycoons'
        local tycoonsFolder = workspace:FindFirstChild("Tycoons")
        if tycoonsFolder then
            print("[Arsenal] Pasta 'Tycoons' encontrada. Escaneando...")
            lookForGivers(tycoonsFolder)
        else
            warn("[Arsenal] Pasta 'Tycoons' não encontrada. A busca pode falhar.")
            -- Como fallback, podemos procurar em todo o workspace, mas isso pode causar o bug antigo
            -- lookForGivers(workspace) 
        end

        if foundCount == 0 then
            local lbl = Instance.new("TextLabel"); lbl.Text = "Nenhum 'Tool Giver' encontrado nos Tycoons."; lbl.Size = UDim2.new(1, 0, 0, 30); lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.fromRGB(200, 200, 200); lbl.Parent = weaponListFrame
        end
    end

    local function openArsenalWindow()
        arsenalWindow = Library:CreateWindow("Arsenal do Mapa", UDim2.new(0, 350, 0, 450))
        weaponListFrame = arsenalWindow:AddScrollableList()
        weaponListFrame.Size = UDim2.new(0.95, 0, 0, 350)
        arsenalWindow:AddButton("Atualizar Lista", scanAndPopulateWeapons)
        scanAndPopulateWeapons()
    end
    Misc:AddModule("🔫 Arsenal", openArsenalWindow, true)
end

print("✅ Carregamento Finalizado (v20).")
