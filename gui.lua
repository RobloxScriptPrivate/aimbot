-- Manus GUI Library V7.0 (The Final, Stable Version)
local Library = {}

-- Services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- Local Variables
local player = Players.LocalPlayer
local guiOpen = true

-- GUI setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ManusGuiLib_V7_FINAL"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundTransparency = 1
MainFrame.Parent = ScreenGui

-- Draggable function
local function makeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Keybind to open/close
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.Insert then
        guiOpen = not guiOpen
        MainFrame.Visible = guiOpen
    end
end)


function Library:CreateCategory(name, position)
    local categoryObj = {}
    
    local CategoryFrame = Instance.new("Frame")
    CategoryFrame.Name = name
    CategoryFrame.Size = UDim2.new(0, 150, 0, 30)
    CategoryFrame.Position = position or UDim2.new(0, 0, 0, 0)
    CategoryFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    CategoryFrame.BorderSizePixel = 0
    CategoryFrame.Parent = MainFrame

    local Title = Instance.new("TextButton")
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.Text = name
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 16
    Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Title.Parent = CategoryFrame

    local OptionsFrame = Instance.new("ScrollingFrame")
    OptionsFrame.Size = UDim2.new(1, 0, 0, 200) -- Fixed height, scrollable
    OptionsFrame.Position = UDim2.new(0, 0, 1, 0)
    OptionsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.Visible = false -- Start closed
    OptionsFrame.ScrollBarThickness = 3
    OptionsFrame.Parent = CategoryFrame

    local UIListLayout = Instance.new("UIListLayout", OptionsFrame)
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    makeDraggable(CategoryFrame, Title)

    local expanded = false
    Title.MouseButton1Click:Connect(function()
        expanded = not expanded
        OptionsFrame.Visible = expanded
    end)

    function categoryObj:AddModule(moduleName, callback, p3)
        local opts = {}
        if type(p3) == "table" then opts = p3 
        elseif type(p3) == "boolean" then opts.isTrigger = p3 end
        
        local moduleObj = { Enabled = false, IsTrigger = opts.isTrigger or false, SubExpanded = false }

        local ModuleContainer = Instance.new("Frame")
        ModuleContainer.Name = moduleName .. "_Container"
        ModuleContainer.BackgroundTransparency = 1
        ModuleContainer.Size = UDim2.new(1, 0, 0, 25) -- Start with base height
        ModuleContainer.ClipsDescendants = true
        ModuleContainer.Parent = OptionsFrame
        ModuleContainer.LayoutOrder = opts.order or 1
        
        local ModuleBtn = Instance.new("TextButton")
        ModuleBtn.Name = moduleName
        ModuleBtn.Size = UDim2.new(1, 0, 0, 25)
        ModuleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        ModuleBtn.Text = "  " .. moduleName
        ModuleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        ModuleBtn.Font = Enum.Font.SourceSans
        ModuleBtn.TextSize = 14
        ModuleBtn.TextXAlignment = Enum.TextXAlignment.Left
        ModuleBtn.Parent = ModuleContainer

        local SubFrame = Instance.new("Frame")
        SubFrame.Name = "SubOptions"
        SubFrame.BackgroundTransparency = 1
        SubFrame.Size = UDim2.new(1, 0, 1, 0) -- Will be auto-sized
        SubFrame.Position = UDim2.new(0, 0, 1, 0)
        SubFrame.Visible = false -- Start closed
        SubFrame.Parent = ModuleContainer
        
        local subLayout = Instance.new("UIListLayout", SubFrame)
        subLayout.Padding = UDim.new(0, 2)

        -- Auto-size the subframe and container
        subLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            local contentHeight = subLayout.AbsoluteContentSize.Y
            SubFrame.Size = UDim2.new(1, 0, 0, contentHeight)
            if moduleObj.SubExpanded then
                ModuleContainer.Size = UDim2.new(1, 0, 0, 25 + contentHeight)
            else
                ModuleContainer.Size = UDim2.new(1, 0, 0, 25)
            end
        end)
        
        ModuleBtn.MouseButton1Click:Connect(function() -- Left Click
            if moduleObj.IsTrigger then
                if callback then callback() end
            else
                moduleObj.Enabled = not moduleObj.Enabled
                ModuleBtn.TextColor3 = moduleObj.Enabled and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(200, 200, 200)
                if callback then callback(moduleObj.Enabled) end
            end
        end)

        ModuleBtn.MouseButton2Click:Connect(function() -- Right Click
            if opts.onRightClick then
                opts.onRightClick()
                return
            end
            
            moduleObj.SubExpanded = not moduleObj.SubExpanded
            SubFrame.Visible = moduleObj.SubExpanded
            
            local contentHeight = subLayout.AbsoluteContentSize.Y
            if moduleObj.SubExpanded then
                ModuleContainer.Size = UDim2.new(1, 0, 0, 25 + contentHeight)
            else
                ModuleContainer.Size = UDim2.new(1, 0, 0, 25)
            end
        end)
        
        function moduleObj:Remove()
            ModuleContainer:Destroy()
        end

        -- ================== THE ACTUAL, FULLY IMPLEMENTED SUB-FUNCTIONS ==================
        
        function moduleObj:AddToggle(text, default, cb)
            local state = default or false
            local frame = Instance.new("TextButton")
            frame.Size = UDim2.new(1, -10, 0, 20)
            frame.BackgroundTransparency = 1
            frame.Text = ""
            frame.Parent = SubFrame
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -20, 1, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.SourceSans
            label.TextSize = 13
            label.TextColor3 = Color3.fromRGB(180, 180, 180)
            label.Text = " " .. text
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            
            local check = Instance.new("Frame")
            check.Size = UDim2.new(0, 10, 0, 10)
            check.Position = UDim2.new(1, -15, 0.5, -5)
            check.BackgroundColor3 = state and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(80, 80, 80)
            check.Parent = frame
            Instance.new("UICorner", check).CornerRadius = UDim.new(0, 2)
            
            frame.MouseButton1Click:Connect(function()
                state = not state
                check.BackgroundColor3 = state and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(80, 80, 80)
                if cb then cb(state) end
            end)
        end

        function moduleObj:AddDropdown(text, options, cb)
            local currentIndex = 1
            
            local dropdownBtn = Instance.new("TextButton")
            dropdownBtn.Size = UDim2.new(1, -10, 0, 20)
            dropdownBtn.BackgroundTransparency = 1
            dropdownBtn.Font = Enum.Font.SourceSans
            dropdownBtn.TextSize = 13
            dropdownBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
            dropdownBtn.Text = " " .. text .. ": " .. tostring(options[currentIndex])
            dropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
            dropdownBtn.Parent = SubFrame

            dropdownBtn.MouseButton1Click:Connect(function()
                currentIndex = currentIndex % #options + 1
                dropdownBtn.Text = " " .. text .. ": " .. tostring(options[currentIndex])
                if cb then cb(options[currentIndex]) end
            end)
        end

        function moduleObj:AddSlider(text, min, max, default, cb)
            default = default or min
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -10, 0, 35)
            frame.BackgroundTransparency = 1
            frame.Parent = SubFrame
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 15)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.SourceSans
            label.TextSize = 13
            label.TextColor3 = Color3.fromRGB(180, 180, 180)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            
            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(1, 0, 0, 4)
            bar.Position = UDim2.new(0, 0, 0, 20)
            bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
            bar.Parent = frame
            Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
            
            local fill = Instance.new("Frame")
            fill.Parent = bar
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
            
            local function updateSlider(value)
                local intValue = math.floor(value + 0.5)
                local percentage = (intValue - min) / (max - min)
                fill.Size = UDim2.new(percentage, 0, 1, 0)
                label.Text = " " .. text .. ": " .. tostring(intValue)
                if cb then cb(intValue) end
            end
            
            updateSlider(default)

            local dragging = false
            local function onDrag(input)
                local percentage = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local value = min + percentage * (max - min)
                updateSlider(value)
            end
            
            bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; onDrag(i) end end)
            bar.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
            UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then onDrag(i) end end)
        end
        
        return moduleObj
    end
    
    return categoryObj
end

function Library:CreateOverlay(id, props)
    props = props or {}
    local ov = Instance.new("Frame")
    ov.Name = id
    ov.Size = props.Size or UDim2.new(0, 150, 0, 20)
    ov.Position = props.Position or UDim2.new(0.5, 0, 0.5, 0)
    ov.BackgroundColor3 = props.Color or Color3.fromRGB(30,30,30)
    ov.BorderSizePixel = 0
    ov.Parent = MainFrame
    Instance.new("UICorner", ov).CornerRadius=UDim.new(0,4)
    
    local title = Instance.new("TextLabel", ov)
    title.Size = UDim2.new(1,0,1,0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Text = props.Title or id
    
    return ov
end

function Library:SaveConfig(name, data)
    if writefile then pcall(function() writefile(name .. ".json", HttpService:JSONEncode(data)) end) end
end

function Library:LoadConfig(name)
    if readfile and isfile and isfile(name .. ".json") then
        local s, d = pcall(function() return HttpService:JSONDecode(readfile(name .. ".json")) end)
        if s then return d end
    end
    return nil
end

return Library
