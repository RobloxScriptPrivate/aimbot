-- ========== LOADER PRINCIPAL (v16.1 - Framework Fixed) ==========
print("🔧 Iniciando carregamento v16.1. Pressione F9 para ver os logs.")

-- Em um ambiente real, você usaria game.HttpGet. Aqui simulamos o carregamento local.
local Library = loadstring(readfile("gui.lua"))()

-- Etapa 2: Criar as categorias
local startX   = 10
local startY   = 120
local catWidth = 150
local spacing  = 10

local Combat   = Library:CreateCategory("⚔️ Combat",    UDim2.new(0, startX, 0, startY))
local Visual   = Library:CreateCategory("👁️ Visual",    UDim2.new(0, startX + catWidth + spacing, 0, startY))
local Movement = Library:CreateCategory("🏃 Movimento", UDim2.new(0, startX + (catWidth + spacing) * 2, 0, startY))
local Teleport = Library:CreateCategory("🌌 Teleporte", UDim2.new(0, startX + (catWidth + spacing) * 3, 0, startY))
local Misc     = Library:CreateCategory("✨ Misc",      UDim2.new(0, startX + (catWidth + spacing) * 4, 0, startY))

-- Etapa 3.5: Módulo de Scanner de Mapa (Corrigido)
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
                    -- Lógica de busca melhorada
                    local name = string.lower(instance.Name)
                    if name:find("tool") or name:find("giver") or instance:IsA("Tool") or instance:IsA("ClickDetector") then
                        table.insert(logLines, "[" .. instance.ClassName .. "] " .. instance:GetFullName())
                    end
                    for _, child in ipairs(instance:GetChildren()) do scan(child, depth + 1) end
                end)
            end
            scan(workspace, 0)
            statusLabel:Destroy()

            local fullLog = table.concat(logLines, "\n")
            if #logLines == 0 then fullLog = "Nenhum item relevante encontrado no Workspace." end

            -- Adiciona a lista rolável
            local scrollList = scanWindow:AddScrollableList()
            scrollList.Size = UDim2.new(0.95, 0, 0, 280) -- Ajuste de tamanho para caber o botão abaixo
            
            local logBox = Instance.new("TextBox")
            logBox.Size = UDim2.new(1, -10, 0, math.max(280, #logLines * 16))
            logBox.Text = fullLog
            logBox.MultiLine = true
            logBox.ReadOnly = true
            logBox.Font = Enum.Font.Code
            logBox.TextSize = 12
            logBox.TextColor3 = Color3.fromRGB(240, 240, 240)
            logBox.BackgroundTransparency = 1
            logBox.TextXAlignment = Enum.TextXAlignment.Left
            logBox.TextYAlignment = Enum.TextYAlignment.Top
            logBox.Parent = scrollList

            -- Botão de copiar agora fora do scroll para ser sempre visível
            scanWindow:AddButton("Copiar Logs para o Clipboard", function() 
                if setclipboard then 
                    setclipboard(fullLog)
                    print("✅ Logs copiados!")
                else
                    print("❌ setclipboard não suportado neste executor.")
                end
            end)
        end)
    end
    Misc:AddModule("🔬 Scan do Mapa", runMapScan, true)
end

-- Etapa 3.6: Módulo Arsenal (Corrigido)
do
    local arsenalWindow, weaponListFrame
    -- Lista expandida de possíveis nomes de givers
    local toolGiverNames = { "ToolGiver", "WeaponGiver", "SwordGiver", "GunGiver" }

    local function scanAndPopulateWeapons()
        if not weaponListFrame then return end
        weaponListFrame:ClearAllChildren()
        
        local foundCount = 0
        local function lookForGivers(parent)
            for _, obj in ipairs(parent:GetChildren()) do
                local isGiver = false
                for _, name in ipairs(toolGiverNames) do
                    if obj.Name:find(name) then isGiver = true break end
                end
                
                -- Se encontrar algo que pareça um giver ou tenha ferramentas dentro
                if isGiver or obj:FindFirstChildOfClass("Tool") then
                    local tool = obj:FindFirstChildOfClass("Tool") or obj
                    if tool:IsA("Tool") then
                        foundCount = foundCount + 1
                        local btn = Instance.new("TextButton")
                        btn.Text = "Pegar: " .. tool.Name
                        btn.Size = UDim2.new(0.9, 0, 0, 30)
                        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        btn.Font = Enum.Font.SourceSansBold
                        btn.Parent = weaponListFrame
                        Instance.new("UICorner", btn)
                        
                        btn.MouseButton1Click:Connect(function()
                            local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if root then
                                -- Tenta mover o giver para o player ou o player para o giver
                                if obj:IsA("BasePart") then
                                    firetouchinterest(root, obj, 0)
                                    firetouchinterest(root, obj, 1)
                                elseif obj:FindFirstChild("Handle") then
                                    firetouchinterest(root, obj.Handle, 0)
                                    firetouchinterest(root, obj.Handle, 1)
                                end
                                print("Attempted to grab: " .. tool.Name)
                            end
                        end)
                    end
                end
                if #obj:GetChildren() > 0 then lookForGivers(obj) end
            end
        end

        -- Procura em Tycoons e no Workspace geral
        local tycoons = workspace:FindFirstChild("Tycoons")
        if tycoons then lookForGivers(tycoons) end
        lookForGivers(workspace)

        if foundCount == 0 then
            local lbl = Instance.new("TextLabel")
            lbl.Text = "Nenhuma arma detectada automaticamente."
            lbl.Size = UDim2.new(1, 0, 0, 30)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
            lbl.Parent = weaponListFrame
        end
    end

    local function openArsenalWindow()
        arsenalWindow = Library:CreateWindow("Arsenal do Mapa", UDim2.new(0, 300, 0, 400))
        weaponListFrame = arsenalWindow:AddScrollableList()
        weaponListFrame.Size = UDim2.new(0.95, 0, 0, 300)
        
        arsenalWindow:AddButton("Atualizar Lista", scanAndPopulateWeapons)
        scanAndPopulateWeapons()
    end
    Misc:AddModule("🔫 Arsenal", openArsenalWindow, true)
end

print("✅ Carregamento Finalizado com Correções.")
