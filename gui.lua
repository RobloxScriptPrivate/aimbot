-- Manus GUI Library V4.8 (Overlay Dinâmico & Persistência)
local Library = {}

-- Serviços
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- Variáveis Locais
local player = Players.LocalPlayer

-- Configurações da Biblioteca
Library.OpenKey = Enum.KeyCode.Insert
Library.RemoveKey = Enum.KeyCode.K
Library.Categories = {}
Library.ActiveWindows = {}
Library.Overlays = {}
Library.SettingsOpen = false

--[[
    Sistema de Persistência (JSON)
]]
function Library:SaveConfig(name, data)
    if writefile then
        pcall(function()
            writefile(name .. ".json", HttpService:JSONEncode(data))
        end)
    end
end

function Library:LoadConfig(name)
    if readfile and isfile and isfile(name .. ".json") then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(name .. ".json"))
        end)
        if success then return result end
    end
    return nil
end

--[[
    Inicialização da GUI Principal
]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ManusGuiLib_V4_8"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if not pcall(function() ScreenGui.Parent = CoreGui end) then
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundTransparency = 1
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

--[[
    Funções Utilitárias
]]
local function makeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--[[
    API de Overlay (Painéis de Alvo/Status)
]]
function Library:CreateOverlay(id, title, color)
    if Library.Overlays[id] then return Library.Overlays[id] end
    
    local OverlayFrame = Instance.new("Frame")
    OverlayFrame.Size = UDim2.new(0, 220, 0, 80)
    OverlayFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    OverlayFrame.BackgroundTransparency = 0.2
    OverlayFrame.BorderSizePixel = 0
    OverlayFrame.Visible = false
    OverlayFrame.Parent = ScreenGui
    Instance.new("UICorner", OverlayFrame).CornerRadius = UDim.new(0, 8)
    
    local Border = Instance.new("Frame")
    Border.Size = UDim2.new(1, 0, 0, 2)
    Border.Position = UDim2.new(0, 0, 0, 0)
    Border.BackgroundColor3 = color or Color3.fromRGB(0, 150, 255)
    Border.BorderSizePixel = 0
    Border.Parent = OverlayFrame
    Instance.new("UICorner", Border)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -10, 0, 20)
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.Text = title
    Title.TextColor3 = color or Color3.fromRGB(0, 150, 255)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 12
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = OverlayFrame

    local Avatar = Instance.new("ImageLabel")
    Avatar.Size = UDim2.new(0, 40, 0, 40)
    Avatar.Position = UDim2.new(0, 10, 0, 30)
    Avatar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Avatar.Parent = OverlayFrame
    Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -60, 0, 15)
    NameLabel.Position = UDim2.new(0, 60, 0, 30)
    NameLabel.Text = "Nenhum"
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.Font = Enum.Font.SourceSansBold
    NameLabel.TextSize = 14
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.BackgroundTransparency = 1
    NameLabel.Parent = OverlayFrame

    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, -60, 0, 15)
    InfoLabel.Position = UDim2.new(0, 60, 0, 45)
    InfoLabel.Text = ""
    InfoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    InfoLabel.Font = Enum.Font.SourceSans
    InfoLabel.TextSize = 12
    InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Parent = OverlayFrame

    local DistLabel = Instance.new("TextLabel")
    DistLabel.Size = UDim2.new(1, -60, 0, 15)
    DistLabel.Position = UDim2.new(0, 60, 0, 60)
    DistLabel.Text = ""
    DistLabel.TextColor3 = color or Color3.fromRGB(0, 150, 255)
    DistLabel.Font = Enum.Font.SourceSansBold
    DistLabel.TextSize = 12
    DistLabel.TextXAlignment = Enum.TextXAlignment.Left
    DistLabel.BackgroundTransparency = 1
    DistLabel.Parent = OverlayFrame

    local overlayObj = { Frame = OverlayFrame }
    
    function overlayObj:Update(playerObj, distance, info)
        if not playerObj then
            OverlayFrame.Visible = false
            return
        end
        OverlayFrame.Visible = true
        NameLabel.Text = playerObj.DisplayName or playerObj.Name
        InfoLabel.Text = info or ("@" .. playerObj.Name)
        DistLabel.Text = distance and (string.format("%.1f", distance) .. "m") or ""
        
        task.spawn(function()
            local thumb = Players:GetUserThumbnailAsync(playerObj.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            Avatar.Image = thumb
        end)
    end

    function overlayObj:SetVisible(state)
        OverlayFrame.Visible = state
    end

    function overlayObj:SetPosition(pos)
        OverlayFrame.Position = pos
    end

    Library.Overlays[id] = overlayObj
    return overlayObj
end

--[[
    Barra Superior e Configurações
]]
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(0, 450, 0, 40)
TopBar.Position = UDim2.new(0.5, -225, 0, 20)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 6)

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0.8, -10, 0.7, 0)
SearchBox.Position = UDim2.new(0.05, 0, 0.15, 0)
SearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SearchBox.PlaceholderText = "Pesquisar módulos..."
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.Font = Enum.Font.SourceSans
SearchBox.TextSize = 16
SearchBox.Parent = TopBar

local SettingsBtn = Instance.new("TextButton")
SettingsBtn.Size = UDim2.new(0.1, 0, 0.7, 0)
SettingsBtn.Position = UDim2.new(0.87, 0, 0.15, 0)
SettingsBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SettingsBtn.Text = "⚙️"
SettingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsBtn.TextSize = 20
SettingsBtn.Parent = TopBar

local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(0, 350, 0, 300)
SettingsFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SettingsFrame.Visible = false
SettingsFrame.Parent = MainFrame
Instance.new("UICorner", SettingsFrame)

local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Size = UDim2.new(1, 0, 0, 40)
SettingsTitle.Text = "Configurações & Keybinds"
SettingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SettingsTitle.Font = Enum.Font.SourceSansBold
SettingsTitle.TextSize = 20
SettingsTitle.Parent = SettingsFrame

local CloseSettings = Instance.new("TextButton")
CloseSettings.Size = UDim2.new(0, 40, 0, 40)
CloseSettings.Position = UDim2.new(1, -40, 0, 0)
CloseSettings.Text = "X"
CloseSettings.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseSettings.BackgroundTransparency = 1
CloseSettings.TextSize = 20
CloseSettings.Parent = SettingsFrame

local KeybindContainer = Instance.new("ScrollingFrame")
KeybindContainer.Size = UDim2.new(1, 0, 1, -40)
KeybindContainer.Position = UDim2.new(0, 0, 0, 40)
KeybindContainer.BackgroundTransparency = 1
KeybindContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
KeybindContainer.ScrollBarThickness = 2
KeybindContainer.Parent = SettingsFrame

local KeybindList = Instance.new("UIListLayout")
KeybindList.Padding = UDim.new(0, 5)
KeybindList.HorizontalAlignment = Enum.HorizontalAlignment.Center
KeybindList.Parent = KeybindContainer

function Library:AddKeybind(label, defaultKey, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0.9, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.Parent = KeybindContainer
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(0.6, 0, 1, 0)
    TextLabel.Text = label
    TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.TextSize = 16
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.BackgroundTransparency = 1
    TextLabel.Parent = Frame
    
    local BindBtn = Instance.new("TextButton")
    BindBtn.Size = UDim2.new(0.35, 0, 0.8, 0)
    BindBtn.Position = UDim2.new(0.65, 0, 0.1, 0)
    BindBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    BindBtn.Text = defaultKey and defaultKey.Name or "None"
    BindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    BindBtn.Font = Enum.Font.SourceSansBold
    BindBtn.Parent = Frame
    
    local currentKey = defaultKey
    local binding = false
    
    BindBtn.MouseButton1Click:Connect(function()
        binding = true
        BindBtn.Text = "..."
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if binding and input.UserInputType == Enum.UserInputType.Keyboard then
            binding = false
            currentKey = input.KeyCode
            BindBtn.Text = currentKey.Name
            if callback then callback(currentKey, false) end
        elseif not gameProcessed and currentKey and input.KeyCode == currentKey then
            if callback then callback(currentKey, true) end
        end
    end)
    
    KeybindContainer.CanvasSize = UDim2.new(0, 0, 0, KeybindList.AbsoluteContentSize.Y + 10)
end

SettingsBtn.MouseButton1Click:Connect(function()
    Library.SettingsOpen = not Library.SettingsOpen
    SettingsFrame.Visible = Library.SettingsOpen
    for _, cat in pairs(Library.Categories) do cat.Visible = not Library.SettingsOpen end
end)

CloseSettings.MouseButton1Click:Connect(function()
    Library.SettingsOpen = false
    SettingsFrame.Visible = false
    for _, cat in pairs(Library.Categories) do cat.Visible = true end
end)

--[[
    API de Janelas (CreateWindow)
]]
function Library:CreateWindow(title, size, position)
    if Library.ActiveWindows[title] and Library.ActiveWindows[title].Frame.Parent then
        Library.ActiveWindows[title].Frame:Destroy()
    end

    local windowObj = {}
    local WindowFrame = Instance.new("Frame")
    local ContentFrame = Instance.new("Frame")

    WindowFrame.Name = title
    WindowFrame.Size = size or UDim2.new(0, 350, 0, 250)
    WindowFrame.Position = position or UDim2.new(0.5, -175, 0.5, -125)
    WindowFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    WindowFrame.BorderSizePixel = 0
    WindowFrame.Visible = true
    Instance.new("UICorner", WindowFrame).CornerRadius = UDim.new(0, 5)

    local TitleBar = Instance.new("TextLabel")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.Text = title
    TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TitleBar.Font = Enum.Font.SourceSansBold
    TitleBar.TextSize = 18
    TitleBar.Parent = WindowFrame

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 40, 1, 0)
    CloseButton.Position = UDim2.new(1, -40, 0, 0)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 80, 80)
    CloseButton.BackgroundTransparency = 1
    CloseButton.TextSize = 22
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.Parent = TitleBar
    CloseButton.MouseButton1Click:Connect(function()
        windowObj.Frame:Destroy()
        Library.ActiveWindows[title] = nil
    end)

    ContentFrame.Name = "Content"
    ContentFrame.Size = UDim2.new(1, 0, 1, -40)
    ContentFrame.Position = UDim2.new(0, 0, 0, 40)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = WindowFrame
    
    local layout = Instance.new("UIListLayout", ContentFrame)
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Instance.new("UIPadding", ContentFrame).PaddingTop = UDim.new(0, 10)

    windowObj.Frame = WindowFrame
    windowObj.Content = ContentFrame
    Library.ActiveWindows[title] = windowObj
    
    makeDraggable(WindowFrame, TitleBar)
    WindowFrame.Parent = MainFrame

    function windowObj:AddButton(text, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0.9, 0, 0, 35)
        Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Button.TextColor3 = Color3.fromRGB(220, 220, 220)
        Button.Text = text
        Button.TextSize = 16
        Button.Font = Enum.Font.SourceSansBold
        Button.Parent = ContentFrame
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 4)
        if callback then Button.MouseButton1Click:Connect(callback) end
        return Button
    end

    function windowObj:AddTextBox(placeholder)
        local TextBox = Instance.new("TextBox")
        TextBox.Size = UDim2.new(0.9, 0, 0, 40)
        TextBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        TextBox.PlaceholderText = placeholder or ""
        TextBox.Text = ""
        TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextBox.TextSize = 16
        TextBox.Font = Enum.Font.SourceSans
        TextBox.Parent = ContentFrame
        Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 4)
        return TextBox
    end
    
    return windowObj
end

--[[
    Sistema de Categorias e Módulos
]]
function Library:CreateCategory(name, position)
    local CategoryFrame = Instance.new("Frame")
    CategoryFrame.Name = name
    CategoryFrame.Size = UDim2.new(0, 150, 0, 30)
    CategoryFrame.Position = position
    CategoryFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    CategoryFrame.BorderSizePixel = 0
    CategoryFrame.Active = true
    CategoryFrame.Parent = MainFrame
    
    local Title = Instance.new("TextButton")
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.Text = name
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 18
    Title.BackgroundTransparency = 1
    Title.AutoButtonColor = false
    Title.Parent = CategoryFrame
    
    local OptionsFrame = Instance.new("Frame")
    OptionsFrame.Name = "Options"
    OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
    OptionsFrame.Position = UDim2.new(0, 0, 1, 0)
    OptionsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.ClipsDescendants = true
    OptionsFrame.Parent = CategoryFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = OptionsFrame
    
    makeDraggable(CategoryFrame, Title)
    
    local categoryObj = { Frame = CategoryFrame, Options = OptionsFrame, Expanded = true }
    table.insert(Library.Categories, CategoryFrame)
    
    Title.MouseButton2Click:Connect(function()
        categoryObj.Expanded = not categoryObj.Expanded
        OptionsFrame.Visible = categoryObj.Expanded
    end)
    
    function categoryObj:AddModule(moduleName, callback, isTrigger)
        local moduleObj = { Enabled = false, IsTrigger = isTrigger or false, SubExpanded = false }
        
        local ModuleContainer = Instance.new("Frame")
        ModuleContainer.Size = UDim2.new(1, 0, 0, 25)
        ModuleContainer.BackgroundTransparency = 1
        ModuleContainer.Parent = OptionsFrame
        
        local ModuleBtn = Instance.new("TextButton")
        ModuleBtn.Size = UDim2.new(1, 0, 0, 25)
        ModuleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        ModuleBtn.BorderSizePixel = 0
        ModuleBtn.Text = "  " .. moduleName
        ModuleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        ModuleBtn.Font = Enum.Font.SourceSans
        ModuleBtn.TextSize = 16
        ModuleBtn.TextXAlignment = Enum.TextXAlignment.Left
        ModuleBtn.Parent = ModuleContainer

        local SubFrame = Instance.new("Frame")
        SubFrame.Size = UDim2.new(1, 0, 0, 0)
        SubFrame.Position = UDim2.new(0, 0, 0, 25)
        SubFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        SubFrame.BorderSizePixel = 0
        SubFrame.Visible = false
        SubFrame.ClipsDescendants = true
        SubFrame.Parent = ModuleContainer
        local subLayout = Instance.new("UIListLayout", SubFrame)
        
        local function updateSizes()
            local subHeight = 0
            if SubFrame.Visible then
                for _, v in pairs(SubFrame:GetChildren()) do
                    if v:IsA("Frame") then subHeight = subHeight + v.Size.Y.Offset end
                end
            end
            SubFrame.Size = UDim2.new(1, 0, 0, subHeight)
            ModuleContainer.Size = UDim2.new(1, 0, 0, 25 + subHeight)
            
            local totalHeight = 0
            for _, v in pairs(OptionsFrame:GetChildren()) do
                if v:IsA("Frame") then totalHeight = totalHeight + v.Size.Y.Offset end
            end
            OptionsFrame.Size = UDim2.new(1, 0, 0, totalHeight)
        end
        
        function moduleObj:ToggleSub()
            self.SubExpanded = not self.SubExpanded
            SubFrame.Visible = self.SubExpanded
            updateSizes()
        end

        function moduleObj:Execute()
            if self.IsTrigger then
                local oldColor = ModuleBtn.TextColor3
                ModuleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                task.delay(0.1, function() ModuleBtn.TextColor3 = oldColor end)
                if callback then callback() end
            else
                self.Enabled = not self.Enabled
                ModuleBtn.TextColor3 = self.Enabled and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(200, 200, 200)
                if callback then callback(self.Enabled) end
            end
        end

        ModuleBtn.MouseButton1Click:Connect(function() moduleObj:Execute() end)
        ModuleBtn.MouseButton2Click:Connect(function() moduleObj:ToggleSub() end)

        function moduleObj:AddToggle(text, default, subCallback)
            local state = default or false
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 22)
            ToggleFrame.BackgroundTransparency = 1
            ToggleFrame.Parent = SubFrame
            
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = "    " .. text
            Btn.TextColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(160, 160, 160)
            Btn.Font = Enum.Font.SourceSans
            Btn.TextSize = 13
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.Parent = ToggleFrame
            
            Btn.MouseButton1Click:Connect(function()
                state = not state
                Btn.TextColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(160, 160, 160)
                if subCallback then subCallback(state) end
            end)
            updateSizes()
        end

        function moduleObj:AddSlider(text, min, max, default, subCallback)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, 0, 0, 35)
            SliderFrame.BackgroundTransparency = 1
            SliderFrame.Parent = SubFrame
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 0, 18)
            Label.Text = "    " .. text .. ": " .. tostring(default)
            Label.TextColor3 = Color3.fromRGB(180, 180, 180)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.SourceSans
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame
            
            local Bar = Instance.new("Frame")
            Bar.Size = UDim2.new(0.8, 0, 0, 4)
            Bar.Position = UDim2.new(0.1, 0, 0.7, 0)
            Bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            Bar.Parent = SliderFrame
            
            local Fill = Instance.new("Frame")
            local percent = (default - min) / (max - min)
            Fill.Size = UDim2.new(percent, 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
            Fill.Parent = Bar
            
            local function update(input)
                local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                local val = math.floor(min + (pos * (max - min)))
                Label.Text = "    " .. text .. ": " .. tostring(val)
                if subCallback then subCallback(val) end
            end
            
            local dragging = false
            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true update(input) end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            updateSizes()
        end

        function moduleObj:AddDropdown(text, options, subCallback)
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Size = UDim2.new(1, 0, 0, 22)
            DropdownFrame.BackgroundTransparency = 1
            DropdownFrame.Parent = SubFrame
            
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = "    > " .. text .. ": " .. tostring(options[1])
            Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            Btn.Font = Enum.Font.SourceSans
            Btn.TextSize = 13
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.Parent = DropdownFrame
            
            local currentIdx = 1
            Btn.MouseButton1Click:Connect(function()
                currentIdx = currentIdx + 1
                if currentIdx > #options then currentIdx = 1 end
                Btn.Text = "    > " .. text .. ": " .. tostring(options[currentIdx])
                if subCallback then subCallback(options[currentIdx]) end
            end)
            updateSizes()
        end

        updateSizes()
        return moduleObj
    end
    
    return categoryObj
end

--[[
    Keybinds Iniciais Globais
]]
Library:AddKeybind("Abrir/Fechar Menu", Library.OpenKey, function(key, pressed)
    if pressed then
        MainFrame.Visible = not MainFrame.Visible
    else 
        Library.OpenKey = key
    end
end)

Library:AddKeybind("Remover Script", Library.RemoveKey, function(key, pressed)
    if pressed then
        ScreenGui:Destroy()
    else
        Library.RemoveKey = key
    end
end)

return Library
