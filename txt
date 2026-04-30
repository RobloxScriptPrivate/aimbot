local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

local AIM_SPEED = 45 

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Aimbot_Elite_V2"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 150)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
titleBar.BorderSizePixel = 0
titleBar.Active = true
titleBar.Parent = mainFrame
local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 8)

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, 0, 1, 0)
titleText.Text = "AIMBOT"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 20
titleText.Font = Enum.Font.GothamBold
titleText.BackgroundTransparency = 1
titleText.Parent = titleBar

local lockBtn = Instance.new("TextButton")
lockBtn.Size = UDim2.new(0, 200, 0, 45)
lockBtn.Position = UDim2.new(0.5, -100, 0, 45)
lockBtn.Text = "OFF"
lockBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
lockBtn.TextColor3 = Color3.new(1, 1, 1)
lockBtn.TextSize = 18
lockBtn.Font = Enum.Font.GothamBold
lockBtn.Parent = mainFrame
Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(0, 6)

local targetInfo = Instance.new("Frame")
targetInfo.Size = UDim2.new(1, -20, 0, 50)
targetInfo.Position = UDim2.new(0, 10, 0, 95)
targetInfo.BackgroundTransparency = 1
targetInfo.Parent = mainFrame

local pfpImage = Instance.new("ImageLabel")
pfpImage.Size = UDim2.new(0, 40, 0, 40)
pfpImage.Position = UDim2.new(0, 0, 0.5, -20)
pfpImage.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
pfpImage.Image = "rbxassetid://0"
pfpImage.Visible = false
pfpImage.Parent = targetInfo
Instance.new("UICorner", pfpImage).CornerRadius = UDim.new(1, 0)

local targetDisplay = Instance.new("TextLabel")
targetDisplay.Size = UDim2.new(1, -50, 1, 0)
targetDisplay.Position = UDim2.new(0, 50, 0, 0)
targetDisplay.BackgroundTransparency = 1
targetDisplay.Text = "Searching..."
targetDisplay.TextColor3 = Color3.fromRGB(180, 180, 180)
targetDisplay.TextSize = 12
targetDisplay.Font = Enum.Font.GothamMedium
targetDisplay.TextXAlignment = Enum.TextXAlignment.Left
targetDisplay.TextWrapped = true
targetDisplay.Parent = targetInfo

local function makeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then 
                    dragging = false 
                end
            end)
        end
    end)
    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    userInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

makeDraggable(titleBar)

local aimbotEnabled = false
local currentTarget = nil
local lastPfpId = 0

local function isEnemy(targetPlayer)
	if not targetPlayer.Team or not player.Team then return true end
	return targetPlayer.Team ~= player.Team
end

local function isVisible(targetPart)
	if not targetPart then return false end
	local origin = camera.CFrame.Position
	local direction = (targetPart.Position - origin)
	local raycastParams = RaycastParams.new()
	local ignoreList = {}
	for _, p in pairs(game.Players:GetPlayers()) do
		if p.Character then table.insert(ignoreList, p.Character) end
	end
	raycastParams.FilterDescendantsInstances = ignoreList
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local result = workspace:Raycast(origin, direction, raycastParams)
	return result == nil
end

local function isAlive(character)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return humanoid and humanoid.Health > 0
end

local function getNearestEnemy()
	local nearest = nil
	local shortestDist = math.huge
	for _, p in pairs(game.Players:GetPlayers()) do
		if p == player or not isEnemy(p) or not isAlive(p.Character) then continue end
		local head = p.Character:FindFirstChild("Head")
		if not head then continue end
		local dist = (player.Character.HumanoidRootPart.Position - head.Position).Magnitude
		if dist < shortestDist and isVisible(head) then
			shortestDist = dist
			nearest = p
		end
	end
	return nearest
end

lockBtn.MouseButton1Click:Connect(function()
	aimbotEnabled = not aimbotEnabled
	local targetColor = aimbotEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(40, 40, 45)
	local targetText = aimbotEnabled and "ON" or "OFF"
	
	tweenService:Create(lockBtn, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {BackgroundColor3 = targetColor}):Play()
	task.spawn(function()
		local fadeOut = tweenService:Create(lockBtn, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {TextTransparency = 1})
		fadeOut:Play()
		fadeOut.Completed:Wait()
		lockBtn.Text = targetText
		tweenService:Create(lockBtn, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {TextTransparency = 0}):Play()
	end)
	
	if not aimbotEnabled then 
		currentTarget = nil 
		pfpImage.Visible = false
		targetDisplay.Text = "Searching..."
	end
end)

runService:BindToRenderStep("AimbotUpdate", Enum.RenderPriority.Camera.Value + 1, function(dt)
	if not aimbotEnabled then return end
	local head = currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Head")
	
	if not currentTarget or not currentTarget.Parent or not isAlive(currentTarget.Character) or not isVisible(head) then
		currentTarget = getNearestEnemy()
		lastPfpId = 0
	end
	
	if currentTarget and currentTarget.Character then
		if currentTarget.UserId ~= lastPfpId then
			lastPfpId = currentTarget.UserId
			pfpImage.Image = game.Players:GetUserThumbnailAsync(currentTarget.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
			pfpImage.Visible = true
		end
		targetDisplay.Text = currentTarget.DisplayName .. "\n(@" .. currentTarget.Name .. ")"
		
		local targetHead = currentTarget.Character:FindFirstChild("Head")
		if targetHead then
			local targetCFrame = CFrame.new(camera.CFrame.Position, targetHead.Position)
			local lerpSpeed = math.clamp(AIM_SPEED * dt, 0, 1)
			camera.CFrame = camera.CFrame:Lerp(targetCFrame, lerpSpeed)
		end
	else
		pfpImage.Visible = false
		targetDisplay.Text = "Searching..."
	end
end)
