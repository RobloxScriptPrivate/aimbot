-- LOADER (v25 - Híbrido Estável)
-- GUI embutida para robustez (modelo v24), módulos da web para flexibilidade.

print("✔ Iniciando v25. Base estável com GUI interna.")

--[[ Etapa 1: Definição da Biblioteca GUI (Embutida e Estável) ]]
local function CreateManusGUILibrary()
    print("--- Construindo biblioteca GUI interna...")

    local Library = {}
    local RunService, UserInputService, Players, CoreGui = game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("Players"), game:GetService("CoreGui")
    local player = Players.LocalPlayer

    Library.OpenKey = Enum.KeyCode.Insert
    Library.Categories = {}

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ManusGuiLib_V25_Internal"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() ScreenGui.Parent = CoreGui end) or pcall(function() ScreenGui.Parent = player:WaitForChild("PlayerGui") end)

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(1, 0, 1, 0)
    MainFrame.BackgroundTransparency = 1
    MainFrame.Parent = ScreenGui

    local function makeDraggable(frame, handle)
        local dragging, input, startPos, frameStartPos
        handle.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; startPos = inp.Position; frameStartPos = frame.Position; local conn; conn = inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then dragging = false; conn:Disconnect() end end) end end)
        handle.InputChanged:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseMovement then input = inp end end)
        UserInputService.InputChanged:Connect(function(inp) if inp == input and dragging then local delta = inp.Position - startPos; frame.Position = UDim2.new(frameStartPos.X.Scale, frameStartPos.X.Offset + delta.X, frameStartPos.Y.Scale, frameStartPos.Y.Offset + delta.Y) end end)
    end

    function Library:CreateCategory(name, position)
        local categoryFrame = Instance.new("Frame"); categoryFrame.Name = name; categoryFrame.Size = UDim2.new(0, 150, 0, 30); categoryFrame.Position = position; categoryFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); categoryFrame.BorderSizePixel = 0; categoryFrame.Parent = MainFrame; categoryFrame.Draggable = true
        local titleButton = Instance.new("TextButton"); titleButton.Size = UDim2.new(1, 0, 1, 0); titleButton.Text = name; titleButton.TextColor3 = Color3.fromRGB(255, 255, 255); titleButton.Font = Enum.Font.SourceSansBold; titleButton.TextSize = 16; titleButton.BackgroundTransparency = 1; titleButton.Parent = categoryFrame
        local optionsFrame = Instance.new("Frame"); optionsFrame.Size = UDim2.new(1, 0, 0, 0); optionsFrame.Position = UDim2.new(0, 0, 1, 0); optionsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40); optionsFrame.BorderSizePixel = 0; optionsFrame.ClipsDescendants = true; optionsFrame.Parent = categoryFrame
        local listLayout = Instance.new("UIListLayout", optionsFrame); listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        local categoryObject = {Frame = categoryFrame, Options = optionsFrame, Expanded = true}
        table.insert(Library.Categories, categoryFrame)
        local function resizeOptionsFrame() task.wait(); local h = 0; for _, v in ipairs(optionsFrame:GetChildren()) do if v:IsA("GuiObject") then h = h + v.Size.Y.Offset end end; optionsFrame.Size = UDim2.new(1, 0, 0, h) end
        titleButton.MouseButton2Click:Connect(function() categoryObject.Expanded = not categoryObject.Expanded; optionsFrame.Visible = categoryObject.Expanded end)
        function categoryObject:AddModule(moduleName, callback, isTrigger) local moduleObject = {Enabled = false, IsTrigger = isTrigger or false}; local moduleContainer = Instance.new("Frame"); moduleContainer.Size = UDim2.new(1,0,0,25); moduleContainer.BackgroundTransparency=1; moduleContainer.Parent=optionsFrame; local moduleButton = Instance.new("TextButton"); moduleButton.Size=UDim2.new(1,0,0,25); moduleButton.BackgroundColor3=Color3.fromRGB(45,45,45); moduleButton.BorderSizePixel=0; moduleButton.Text="  "..moduleName; moduleButton.TextColor3=Color3.fromRGB(200,200,200); moduleButton.Font=Enum.Font.SourceSans; moduleButton.TextSize=14; moduleButton.TextXAlignment=Enum.TextXAlignment.Left; moduleButton.Parent=moduleContainer; moduleButton.MouseButton1Click:Connect(function() if moduleObject.IsTrigger then if callback then callback() end else moduleObject.Enabled = not moduleObject.Enabled; moduleButton.TextColor3 = moduleObject.Enabled and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(200, 200, 200); if callback then callback(moduleObject.Enabled) end end end); resizeOptionsFrame(); return moduleObject end
        return categoryObject
    end

    local keybinds = {}; function Library:AddKeybind(key, cb) if not keybinds[key] then keybinds[key] = {} end; table.insert(keybinds[key], cb) end
    UserInputService.InputBegan:Connect(function(input, processed) if processed then return end; if keybinds[input.KeyCode] then for _, cb in ipairs(keybinds[input.KeyCode]) do pcall(cb) end end end)
    Library:AddKeybind(Library.OpenKey, function() MainFrame.Visible = not MainFrame.Visible end)

    Library.ScreenGui = ScreenGui
    print("✅ Biblioteca GUI interna construída.")
    return Library
end

--[[ Etapa 2: Execução do Loader Principal ]]
local Library = CreateManusGUILibrary()
if not (Library and type(Library) == "table") then
    warn("❌ ERRO GRAVE: A construção da GUI interna falhou.")
    return
end

--[[ Etapa 3: Carregamento dos Módulos da Web ]]
local BASE_URL = "https://raw.githubusercontent.com/RobloxScriptPrivate/aimbot/main/"
local function getURL(file)
    return BASE_URL .. file .. "?v=" .. os.time() .. "&r=" .. math.random(1, 99999)
end

print("--- Criando Categorias...")
local Combat   = Library:CreateCategory("⚔️ Combat",    UDim2.new(0, 10, 0, 120))
local Visual   = Library:CreateCategory("👁️ Visual",    UDim2.new(0, 170, 0, 120))
local Movement = Library:CreateCategory("🏃 Movimento", UDim2.new(0, 330, 0, 120))
local Teleport = Library:CreateCategory("🌌 Teleporte", UDim2.new(0, 490, 0, 120))
local Misc     = Library:CreateCategory("✨ Misc",      UDim2.new(0, 650, 0, 120))
print("✅ Categorias criadas.")

print("--- Carregando Módulos da Web...")
local function LoadModule(filename, category)
    print(" ↳ Carregando Módulo: '" .. filename .. "'...")
    local success, code = pcall(game.HttpGet, game, getURL(filename), true)
    if success and code and #code > 0 then
        local s_load, err_load = pcall(loadstring(code), Library, category)
        if not s_load then warn("🔥 Erro ao executar '"..filename.."':", err_load) end
    else
        warn("⚠️ Falha no download de: "..filename)
    end
end

LoadModule("aimbot.lua", Combat)
LoadModule("hitbox.lua", Combat)
LoadModule("esp.lua",    Visual)
LoadModule("nametag.lua",Visual)
LoadModule("movement.lua", Movement)
LoadModule("teleport.lua", Teleport)
LoadModule("armas.lua", Misc)

print("\n🎉 Todos os módulos carregados. Sistema híbrido estável e funcional.")
