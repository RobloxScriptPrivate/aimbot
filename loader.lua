-- ========== LOADER PRINCIPAL (v23 - Arsenal Reborn) ==========
print("🔧 Iniciando carregamento v23. Implementando o fluxo de trabalho do Arsenal correto.")

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
    Módulo Arsenal (v3.0 - Interface de Navegação + Sua Lógica)
]]
do
    local function openArsenalWindow()
        local arsenalWindow = Library:CreateWindow("🔫 Arsenal do Mapa", UDim2.new(0, 400, 0, 500))
        local weaponListFrame -- Declarado aqui para ser acessível por ambas as funções

        local toolGiverNames = {
            "ToolGiver1P1", "ToolGiver1P2", "ToolGiver2P1", "ToolGiver2P2", "ToolGiver3P1", "ToolGiver3P2",
            "ToolGiver4P1", "ToolGiver4P2", "ToolGiver5", "ToolGiver5P1", "ToolGiver5P2", "ToolGiver6P1",
            "ToolGiver6P2", "ToolGiver7P1", "ToolGiver7P2", "ToolGiver8P1", "ToolGiver8P2", "ToolGiver9P1",
            "ToolGiver9P2", "ToolGiver10P1", "ToolGiver10P2", "ToolGiver11P1", "ToolGiver11P2", "ToolGiver12P1",
            "ToolGiver12P2", "ToolGiver13P1", "ToolGiver13P2", "ToolGiver14P1", "ToolGiver14P2", "ToolGiver100",
            "DToolGiver1P1", "DToolGiver1P2"
        }

        -- SEÇÃO: NAVEGADOR DE TYCOONS
        arsenalWindow:AddLabel("1. Teleporte para uma base:", false)
        local navigatorFrame = Instance.new("Frame"); navigatorFrame.Size = UDim2.new(0.9, 0, 0, 70); navigatorFrame.BackgroundTransparency = 1; navigatorFrame.Parent = arsenalWindow.Content
        local navLayout = Instance.new("UIGridLayout", navigatorFrame); navLayout.CellPadding = UDim2.new(0, 5, 0, 5); navLayout.CellSize = UDim2.new(0, 110, 0, 30)
        
        local TycoonsFolder = workspace:FindFirstChild("Tycoons")
        if TycoonsFolder then
            for _, tycoon in ipairs(TycoonsFolder:GetChildren()) do
                if tycoon:IsA("Model") then
                    local btn = arsenalWindow:AddButton("TP para " .. tycoon.Name)
                    btn.Parent = navigatorFrame -- Move o botão para o frame com grid
                    btn.MouseButton1Click:Connect(function()
                        local playerChar = game.Players.LocalPlayer.Character
                        local rootPart = playerChar and playerChar:FindFirstChild("HumanoidRootPart")
                        local targetPart = tycoon.PrimaryPart or tycoon:FindFirstChildWhichIsA("BasePart")
                        if rootPart and targetPart then
                            rootPart.CFrame = targetPart.CFrame * CFrame.new(0, 5, 0)
                        end
                    end)
                end
            end
        end

        -- SEÇÃO: LISTA DE ARMAS PRÓXIMAS
        arsenalWindow:AddLabel("2. Atualize e pegue as armas:", false)
        
        local function scanForNearbyWeapons()
            if not weaponListFrame then return end
            weaponListFrame:ClearAllChildren()
            local listLayout = Instance.new("UIListLayout", weaponListFrame); listLayout.Padding = UDim.new(0, 5)
            local foundCount = 0

            local character = game.Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end

            for _, tycoon in ipairs(TycoonsFolder:GetChildren()) do
                local purchased = tycoon:FindFirstChild("PurchasedObjects")
                local tycoonPart = tycoon.PrimaryPart or tycoon:FindFirstChildWhichIsA("BasePart")
                if purchased and tycoonPart and (tycoonPart.Position - rootPart.Position).Magnitude < 300 then -- Apenas escaneia tycoons próximos
                    for _, giverName in ipairs(toolGiverNames) do
                        local toolGiver = purchased:FindFirstChild(giverName)
                        if toolGiver then
                            local touchPart = toolGiver:FindFirstChild("Touch")
                            if touchPart and touchPart:IsA("BasePart") and touchPart:FindFirstChildOfClass("TouchTransmitter") then
                                foundCount = foundCount + 1
                                local card = Instance.new("Frame"); card.Size = UDim2.new(0.95, 0, 0, 40); card.BackgroundColor3 = Color3.fromRGB(50, 50, 50); card.Parent = weaponListFrame; Instance.new("UICorner", card)
                                local title = Instance.new("TextLabel"); title.Size = UDim2.new(1, -110, 1, 0); title.Text = "  " .. toolGiver.Name; title.TextColor3 = Color3.fromRGB(240, 240, 240); title.Font = Enum.Font.SourceSansBold; title.TextSize = 14; title.TextXAlignment = Enum.TextXAlignment.Left; title.BackgroundTransparency = 1; title.Parent = card
                                local pegarBtn = Instance.new("TextButton"); pegarBtn.Size = UDim2.new(0, 100, 0.8, 0); pegarBtn.Position = UDim2.new(1, -105, 0.1, 0); pegarBtn.Text = "✔️ Pegar"; pegarBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 220); pegarBtn.TextColor3 = Color3.fromRGB(255, 255, 255); pegarBtn.Font = Enum.Font.SourceSansBold; pegarBtn.Parent = card; Instance.new("UICorner", pegarBtn)
                                pegarBtn.MouseButton1Click:Connect(function()
                                    pcall(function() 
                                        touchPart.Anchored = false
                                        touchPart.CFrame = rootPart.CFrame
                                    end)
                                end)
                            end
                        end
                    end
                end
            end
             if foundCount == 0 then
                local lbl = arsenalWindow:AddLabel("Nenhuma arma encontrada nas proximidades.", true)
                lbl.Parent = weaponListFrame
            end
        end

        arsenalWindow:AddButton("🔄 Atualizar Lista de Armas Próximas", scanForNearbyWeapons)
        weaponListFrame = arsenalWindow:AddScrollableList()
        weaponListFrame.Size = UDim2.new(0.95, 0, 0.35, 0)
    end

    Misc:AddModule("🔫 Arsenal do Mapa", openArsenalWindow, true)
end

print("✅ Carregamento Finalizado (v23).")
