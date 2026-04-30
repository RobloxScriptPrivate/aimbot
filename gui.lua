-- Manus GUI Library V8.1 (Window System Restored)
local Library = {}

-- Services
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- GUI setup
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "ManusGuiLib_V8.1_FINAL"; ScreenGui.ResetOnSpawn = false; ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; ScreenGui.Parent = CoreGui
local MainFrame = Instance.new("Frame"); MainFrame.Name = "MainFrame"; MainFrame.Size = UDim2.new(1, 0, 1, 0); MainFrame.BackgroundTransparency = 1; MainFrame.Parent = ScreenGui
local guiOpen = true

local function makeDraggable(frame, dragHandle)
    local dragging, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, dragStart, startPos = true, input.Position, frame.Position
            local conn; conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false; conn:Disconnect() end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

UserInputService.InputBegan:Connect(function(input, processed) if not processed and input.KeyCode == Enum.KeyCode.Insert then guiOpen = not guiOpen; MainFrame.Visible = guiOpen end end)

-- ==================== WINDOW SYSTEM (RESTORED) ====================
function Library:CreateWindow(title, size)
    local windowObj = {}
    local windowFrame = Instance.new("Frame"); windowFrame.Size = size or UDim2.new(0, 300, 0, 200); windowFrame.Position = UDim2.new(0.5, -windowFrame.Size.X.Offset / 2, 0.5, -windowFrame.Size.Y.Offset / 2); windowFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35); windowFrame.BorderSizePixel = 0; windowFrame.Parent = MainFrame; windowObj.Frame = windowFrame
    local titleBar = Instance.new("Frame"); titleBar.Size = UDim2.new(1, 0, 0, 25); titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); titleBar.Parent = windowFrame
    local titleLabel = Instance.new("TextLabel", titleBar); titleLabel.Size = UDim2.new(1, -30, 1, 0); titleLabel.Text = title; titleLabel.Font = Enum.Font.SourceSansBold; titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220); titleLabel.TextSize = 14; titleLabel.Position = UDim2.new(0, 10, 0, 0)
    local closeBtn = Instance.new("TextButton", titleBar); closeBtn.Size = UDim2.new(0, 20, 0, 20); closeBtn.Position = UDim2.new(1, -25, 0.5, -10); closeBtn.Text = "X"; closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80); closeBtn.MouseButton1Click:Connect(function() windowFrame:Destroy() end)
    local contentFrame = Instance.new("Frame"); contentFrame.Size = UDim2.new(1, 0, 1, -25); contentFrame.Position = UDim2.new(0, 0, 0, 25); contentFrame.BackgroundTransparency = 1; contentFrame.Parent = windowFrame
    local listLayout = Instance.new("UIListLayout", contentFrame); listLayout.Padding = UDim.new(0, 8)

    makeDraggable(windowFrame, titleBar)

    function windowObj:AddTextBox(placeholder)
        local box = Instance.new("TextBox"); box.Size = UDim2.new(1, -20, 0, 30); box.Position = UDim2.new(0.5, -box.Size.X.Offset/2, 0, 0); box.BackgroundColor3 = Color3.fromRGB(50, 50, 50); box.PlaceholderText = placeholder or ""; box.TextColor3 = Color3.fromRGB(200, 200, 200); box.Parent = contentFrame
        return box
    end

    function windowObj:AddButton(text, cb)
        local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1, -20, 0, 30); btn.Position = UDim2.new(0.5, -btn.Size.X.Offset/2, 0, 0); btn.BackgroundColor3 = Color3.fromRGB(0, 120, 200); btn.Text = text; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Parent = contentFrame
        btn.MouseButton1Click:Connect(cb)
    end

    return windowObj
end

function Library:CreateCategory(name, position)
    local categoryObj = {}
    
    local CategoryFrame = Instance.new("Frame"); CategoryFrame.Name = name; CategoryFrame.Size = UDim2.new(0, 150, 0, 30); CategoryFrame.Position = position or UDim2.new(0,0,0,0); CategoryFrame.BackgroundColor3 = Color3.fromRGB(30,30,30); CategoryFrame.Parent = MainFrame
    local Title = Instance.new("TextButton"); Title.Size = UDim2.new(1, 0, 1, 0); Title.Text = name; Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.Font = Enum.Font.SourceSansBold; Title.TextSize = 16; Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Title.Parent = CategoryFrame
    local OptionsFrame = Instance.new("ScrollingFrame"); OptionsFrame.Size = UDim2.new(1, 0, 0, 250); OptionsFrame.Position = UDim2.new(0, 0, 1, 0); OptionsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40); OptionsFrame.BorderSizePixel = 0; OptionsFrame.Visible = false; OptionsFrame.ScrollBarThickness = 4; OptionsFrame.Parent = CategoryFrame
    local UIListLayout = Instance.new("UIListLayout", OptionsFrame); UIListLayout.Padding = UDim.new(0, 5); UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    makeDraggable(CategoryFrame, Title)

    local expanded = false
    Title.MouseButton1Click:Connect(function() expanded = not expanded; OptionsFrame.Visible = expanded end)

    function categoryObj:AddModule(moduleName, callback, p3)
        local opts = {}; if type(p3) == "table" then opts = p3 elseif type(p3) == "boolean" then opts.isTrigger = p3 end
        local moduleObj = { Enabled = false, SubExpanded = false }

        local ModuleContainer = Instance.new("Frame"); ModuleContainer.Name = moduleName.."_Container"; ModuleContainer.BackgroundTransparency = 1; ModuleContainer.Size = UDim2.new(1, 0, 0, 25); ModuleContainer.ClipsDescendants = true; ModuleContainer.Parent = OptionsFrame; ModuleContainer.LayoutOrder = opts.order or 1
        local ModuleBtn = Instance.new("TextButton"); ModuleBtn.Name = moduleName; ModuleBtn.Size = UDim2.new(1, 0, 0, 25); ModuleBtn.BackgroundColor3 = Color3.fromRGB(45,45,45); ModuleBtn.Text = "  "..moduleName; ModuleBtn.TextColor3 = Color3.fromRGB(200,200,200); ModuleBtn.Font = Enum.Font.SourceSans; ModuleBtn.TextSize = 14; ModuleBtn.TextXAlignment = Enum.TextXAlignment.Left; ModuleBtn.Parent = ModuleContainer
        local SubFrame = Instance.new("Frame"); SubFrame.Name = "SubOptions"; SubFrame.BackgroundTransparency = 1; SubFrame.Size = UDim2.new(1,0,1,0); SubFrame.Position = UDim2.new(0,0,1,0); SubFrame.Visible = false; SubFrame.Parent = ModuleContainer
        local subLayout = Instance.new("UIListLayout", SubFrame); subLayout.Padding = UDim.new(0, 3)

        subLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            local contentHeight = subLayout.AbsoluteContentSize.Y
            SubFrame.Size = UDim2.new(1, 0, 0, contentHeight)
            ModuleContainer.Size = UDim2.new(1, 0, 0, 25 + (moduleObj.SubExpanded and contentHeight or 0))
        end)
        
        ModuleBtn.MouseButton1Click:Connect(function() 
            if opts.isTrigger then pcall(callback)
            else
                moduleObj.Enabled = not moduleObj.Enabled
                ModuleBtn.TextColor3 = moduleObj.Enabled and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(200, 200, 200)
                pcall(callback, moduleObj.Enabled)
            end
        end)

        ModuleBtn.MouseButton2Click:Connect(function()
            moduleObj.SubExpanded = not moduleObj.SubExpanded
            SubFrame.Visible = moduleObj.SubExpanded
            local contentHeight = subLayout.AbsoluteContentSize.Y
            ModuleContainer.Size = UDim2.new(1, 0, 0, 25 + (moduleObj.SubExpanded and contentHeight or 0))
        end)
        
        function moduleObj:Remove() ModuleContainer:Destroy() end

        local function safeCall(cb, ...) if cb and type(cb) == "function" then pcall(cb, ...) end end

        function moduleObj:AddButton(text, cb)
            local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1, -10, 0, 22); btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); btn.Font = Enum.Font.SourceSans; btn.TextSize = 13; btn.TextColor3 = Color3.fromRGB(220, 220, 220); btn.Text = text; btn.Parent = SubFrame; local corner = Instance.new("UICorner", btn); corner.CornerRadius = UDim.new(0, 3); btn.MouseButton1Click:Connect(function() safeCall(cb) end)
        end

        function moduleObj:AddToggle(text, default, cb)
            local state = default or false; local frame = Instance.new("TextButton"); frame.Size = UDim2.new(1, -10, 0, 20); frame.BackgroundTransparency = 1; frame.Text = ""; frame.Parent = SubFrame
            local label = Instance.new("TextLabel"); label.Size = UDim2.new(1, -20, 1, 0); label.BackgroundTransparency = 1; label.Font = Enum.Font.SourceSans; label.TextSize = 13; label.TextColor3 = Color3.fromRGB(180, 180, 180); label.Text = " " .. text; label.TextXAlignment = Enum.TextXAlignment.Left; label.Parent = frame
            local check = Instance.new("Frame"); check.Size = UDim2.new(0, 10, 0, 10); check.Position = UDim2.new(1, -15, 0.5, -5); check.BackgroundColor3 = state and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(80, 80, 80); check.Parent = frame; Instance.new("UICorner", check).CornerRadius = UDim.new(0, 2)
            frame.MouseButton1Click:Connect(function() state = not state; check.BackgroundColor3 = state and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(80, 80, 80); safeCall(cb, state) end)
        end

        function moduleObj:AddDropdown(text, options, cb)
            if not (type(options) == "table" and #options > 0) then return end
            local currentIndex = 1; local dropdownBtn = Instance.new("TextButton"); dropdownBtn.Size = UDim2.new(1, -10, 0, 20); dropdownBtn.BackgroundTransparency = 1; dropdownBtn.Font = Enum.Font.SourceSans; dropdownBtn.TextSize = 13; dropdownBtn.TextColor3 = Color3.fromRGB(180, 180, 180); dropdownBtn.Text = " " .. text .. ": " .. tostring(options[currentIndex]); dropdownBtn.TextXAlignment = Enum.TextXAlignment.Left; dropdownBtn.Parent = SubFrame
            dropdownBtn.MouseButton1Click:Connect(function() currentIndex = currentIndex % #options + 1; dropdownBtn.Text = " " .. text .. ": " .. tostring(options[currentIndex]); safeCall(cb, options[currentIndex]) end)
        end

        function moduleObj:AddSlider(text, min, max, default, cb)
             if not (type(min) == "number" and type(max) == "number" and max > min) then return end
            default = (type(default) == "number" and math.clamp(default, min, max)) or min; local frame = Instance.new("Frame"); frame.Size = UDim2.new(1, -10, 0, 35); frame.BackgroundTransparency = 1; frame.Parent = SubFrame
            local label = Instance.new("TextLabel"); label.Size = UDim2.new(1, 0, 0, 15); label.BackgroundTransparency = 1; label.Font = Enum.Font.SourceSans; label.TextSize = 13; label.TextColor3 = Color3.fromRGB(180, 180, 180); label.TextXAlignment = Enum.TextXAlignment.Left; label.Parent = frame
            local bar = Instance.new("Frame"); bar.Size = UDim2.new(1, 0, 0, 4); bar.Position = UDim2.new(0, 0, 0, 20); bar.BackgroundColor3 = Color3.fromRGB(60,60,60); bar.Parent = frame; Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
            local fill = Instance.new("Frame"); fill.Parent = bar; Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0); fill.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
            local function updateSlider(value, fromDrag) local intValue = math.floor(value + 0.5); local percentage = (intValue - min) / (max - min); fill.Size = UDim2.new(percentage, 0, 1, 0); label.Text = " " .. text .. ": " .. tostring(intValue); if fromDrag then safeCall(cb, intValue) end end
            updateSlider(default, false)
            local dragging = false; local function onDrag(input) local percentage = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1); local value = min + percentage * (max - min); updateSlider(value, true) end
            bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; onDrag(i) end end); bar.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end); UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then onDrag(i) end end)
            safeCall(cb, default)
        end
        
        return moduleObj
    end
    
    return categoryObj
end

return Library
