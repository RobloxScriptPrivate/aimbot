-- Sword Aura com alvo único e GUI arrastável (com remoção)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local selectedTarget = nil
local auraActive = false
local maxDistance = 10
local running = true -- controle de execução do script

-- Criar GUI principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AuraRemovableGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 320)
mainFrame.Position = UDim2.new(0, 50, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

-- Barra de título (arrastável)
local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.Text = "  Sword Aura (arraste aqui)"
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
titleBar.BackgroundTransparency = 0
titleBar.Parent = mainFrame

-- Botão de fechar (X) dentro da barra
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
closeBtn.BackgroundTransparency = 0
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

-- Função para remover completamente o script
local function destroyScript()
    running = false
    if screenGui then screenGui:Destroy() end
    -- Limpar referências
    selectedTarget = nil
    auraActive = false
    print("Script removido e GUI destruída.")
end

closeBtn.MouseButton1Click:Connect(destroyScript)

-- Arrastar a GUI
local dragging = false
local dragStart = nil
local frameStart = nil

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        frameStart = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(0, frameStart.X.Offset + delta.X, 0, frameStart.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Dropdown de jogadores inimigos
local dropdownBtn = Instance.new("TextButton")
dropdownBtn.Size = UDim2.new(0.9, 0, 0, 32)
dropdownBtn.Position = UDim2.new(0.05, 0, 0, 40)
dropdownBtn.Text = "▼ Selecionar Alvo"
dropdownBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 85)
dropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dropdownBtn.Parent = mainFrame

local dropdownList = Instance.new("ScrollingFrame")
dropdownList.Size = UDim2.new(0.9, 0, 0, 100)
dropdownList.Position = UDim2.new(0.05, 0, 0, 75)
dropdownList.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
dropdownList.Visible = false
dropdownList.Parent = mainFrame
dropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = dropdownList

-- Atualizar lista de inimigos
local function refreshEnemyList()
    for _, child in ipairs(dropdownList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local y = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 25)
            btn.Text = plr.Name
            btn.BackgroundColor3 = Color3.fromRGB(70, 70, 95)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Parent = dropdownList
            btn.MouseButton1Click:Connect(function()
                selectedTarget = plr.Name
                dropdownBtn.Text = "✅ " .. plr.Name
                dropdownList.Visible = false
            end)
            y = y + 25
        end
    end
    dropdownList.CanvasSize = UDim2.new(0, 0, 0, y)
end

dropdownBtn.MouseButton1Click:Connect(function()
    if not running then return end
    dropdownList.Visible = not dropdownList.Visible
    if dropdownList.Visible then refreshEnemyList() end
end)

-- Limpar alvo
local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0.9, 0, 0, 30)
clearBtn.Position = UDim2.new(0.05, 0, 0, 180)
clearBtn.Text = "Limpar Alvo"
clearBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.Parent = mainFrame
clearBtn.MouseButton1Click:Connect(function()
    selectedTarget = nil
    dropdownBtn.Text = "▼ Selecionar Alvo"
end)

-- Distância
local distLabel = Instance.new("TextLabel")
distLabel.Size = UDim2.new(0.4, 0, 0, 25)
distLabel.Position = UDim2.new(0.05, 0, 0, 220)
distLabel.Text = "Distância:"
distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
distLabel.BackgroundTransparency = 1
distLabel.Parent = mainFrame

local distBox = Instance.new("TextBox")
distBox.Size = UDim2.new(0.4, 0, 0, 25)
distBox.Position = UDim2.new(0.55, 0, 0, 220)
distBox.Text = "10"
distBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
distBox.TextColor3 = Color3.fromRGB(255, 255, 255)
distBox.Parent = mainFrame
distBox.FocusLost:Connect(function()
    local n = tonumber(distBox.Text)
    if n and n > 0 then maxDistance = n else distBox.Text = tostring(maxDistance) end
end)

-- Toggle da aura
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 35)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 255)
toggleBtn.Text = "🔴 Aura DESLIGADA"
toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Parent = mainFrame
toggleBtn.MouseButton1Click:Connect(function()
    auraActive = not auraActive
    if auraActive then
        toggleBtn.Text = "🟢 Aura LIGADA"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 130, 60)
    else
        toggleBtn.Text = "🔴 Aura DESLIGADA"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    end
end)

-- Botão remover script (adicional)
local removeScriptBtn = Instance.new("TextButton")
removeScriptBtn.Size = UDim2.new(0.9, 0, 0, 28)
removeScriptBtn.Position = UDim2.new(0.05, 0, 0, 295)
removeScriptBtn.Text = "✖ Remover Script"
removeScriptBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
removeScriptBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
removeScriptBtn.Parent = mainFrame
removeScriptBtn.MouseButton1Click:Connect(destroyScript)

-- Função de ataque (mesma lógica do script original)
local function attackTarget(targetChar)
    local char = LocalPlayer.Character
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

-- Loop otimizado da aura (evita processamento desnecessário)
coroutine.wrap(function()
    while running do
        if auraActive and selectedTarget then
            local targetPlayer = nil
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Name == selectedTarget and plr ~= LocalPlayer then
                    targetPlayer = plr
                    break
                end
            end
            if targetPlayer and targetPlayer.Character then
                local hum = targetPlayer.Character:FindFirstChild("Humanoid")
                local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local localChar = LocalPlayer.Character
                if hum and hum.Health > 0 and hrp and localChar and localChar:FindFirstChild("HumanoidRootPart") then
                    local dist = (hrp.Position - localChar.HumanoidRootPart.Position).Magnitude
                    if dist <= maxDistance then
                        attackTarget(targetPlayer.Character)
                    end
                end
            end
        end
        wait(0.1) -- 100ms entre ataques (evita spam excessivo)
    end
end)()

-- Atualização periódica da lista de inimigos (quando o dropdown está aberto)
coroutine.wrap(function()
    while running do
        if dropdownList.Visible then
            refreshEnemyList()
        end
        wait(2)
    end
end)()

print("✅ Script carregado com sucesso! Use o X para remover.")
