-- ========== ESP V8 (Dead Markers + Reliability) ==========
local Library, Visual = ..., select(2, ...)

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local Camera      = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Config = {
    Enabled     = false,
    Skeleton    = true,
    Outline     = false,
    Preenchido  = false,
    Tracers     = false,
    TeamCheck   = true,
    MaxDistance = 300,
    ShowDead    = true, -- NEW: Show markers for dead players
}

local saved = Library:LoadConfig("esp")
if saved then
    if type(saved.Skeleton)    == "boolean" then Config.Skeleton    = saved.Skeleton    end
    if type(saved.Outline)     == "boolean" then Config.Outline     = saved.Outline     end
    if type(saved.Preenchido)   == "boolean" then Config.Preenchido   = saved.Preenchido   end
    if type(saved.Tracers)     == "boolean" then Config.Tracers     = saved.Tracers     end
    if type(saved.TeamCheck)   == "boolean" then Config.TeamCheck   = saved.TeamCheck   end
    if type(saved.MaxDistance) == "number"  then Config.MaxDistance = saved.MaxDistance end
    if type(saved.ShowDead)    == "boolean" then Config.ShowDead    = saved.ShowDead    end
end

local function Save()
    Library:SaveConfig("esp", {
        Skeleton    = Config.Skeleton,
        Outline     = Config.Outline,
        Preenchido  = Config.Preenchido,
        Tracers     = Config.Tracers,
        TeamCheck   = Config.TeamCheck,
        MaxDistance = Config.MaxDistance,
        ShowDead    = Config.ShowDead,
    })
end

-- ──────────────────────────────────────────────
-- CORES
-- ──────────────────────────────────────────────
local function GetColor(player, isAlive)
    if not isAlive then return Color3.fromRGB(150, 150, 150) end -- Dead players are grey
    if Config.TeamCheck then
        if player.TeamColor ~= nil and player.TeamColor.Color ~= Color3.fromRGB(204, 204, 204) then
            return player.TeamColor.Color
        end
        if LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team then
            return Color3.fromRGB(0, 120, 255) -- Friendly
        end
    end
    return Color3.fromRGB(255, 50, 50) -- Default enemy color
end

-- ──────────────────────────────────────────────
-- VALIDAÇÃO (REWORKED)
-- ──────────────────────────────────────────────
local function IsValidTarget(player)
    if not player or player == LocalPlayer then return false, false end
    if Library:IsWhitelisted(player) then return false, false end
    local char = player.Character
    if not char then return false, false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false, false end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false, false end

    local isAlive = hum.Health > 0
    
    -- Distance Check (always active)
    local localChar = LocalPlayer.Character
    if localChar then
        local localRoot = localChar:FindFirstChild("HumanoidRootPart")
        if localRoot then
            if (rootPart.Position - localRoot.Position).Magnitude > Config.MaxDistance then
                return false, isAlive -- Return false if out of distance
            end
        end
    end
    
    return true, isAlive -- Return validity and alive status
end

-- ==================== ESP ELEMENT TABLES ====================
local skeletons = {}
local highlights_outline = {}
local highlights_filled = {}
local nametags_filled = {}
local tracers = {}
local dead_markers = {} -- NEW: For dead players

-- ... (Funções de criação e remoção de ESP de esqueleto, highlight, tracer permanecem as mesmas)

-- ==================== SKELETON ====================
local function newLine(color) local l = Drawing.new("Line"); l.Visible = false; l.Thickness = 1.5; l.Color = color; return l end
local function buildLines(p, c) local ch = p.Character; if not ch then return {} end; local ls = {}; for _,pt in next, ch:GetChildren() do if pt:IsA("BasePart") then for _,m in next, pt:GetChildren() do if m:IsA("Motor6D") then table.insert(ls,{newLine(c),newLine(c),pt.Name,m.Name}) end end end end; return ls end
local function removeLines(ls) for _,l in ipairs(ls) do l[1]:Remove(); l[2]:Remove() end end
local function updateSkeleton(p, ls, c) local ch=p.Character; if not ch then return false end; local rB=false; for _,l in ipairs(ls) do local pt=ch:FindFirstChild(l[3]); if not pt then l[1].Visible=false;l[2].Visible=false;rB=true; continue end; local m=pt:FindFirstChild(l[4]); if not(m and m.Part0 and m.Part1) then l[1].Visible=false;l[2].Visible=false;rB=true; continue end; local p0,p1=m.Part0,m.Part1; local c0,c1=m.C0,m.C1; local a0,v0=Camera:WorldToViewportPoint(p0.CFrame.p); local a1,v1=Camera:WorldToViewportPoint((p0.CFrame*c0).p); if v0 and v1 then l[1].From=Vector2.new(a0.X,a0.Y);l[1].To=Vector2.new(a1.X,a1.Y);l[1].Color=c;l[1].Visible=true else l[1].Visible=false end; local b0,w0=Camera:WorldToViewportPoint(p1.CFrame.p); local b1,w1=Camera:WorldToViewportPoint((p1.CFrame*c1).p); if w0 and w1 then l[2].From=Vector2.new(b0.X,b0.Y);l[2].To=Vector2.new(b1.X,b1.Y);l[2].Color=c;l[2].Visible=true else l[2].Visible=false end end; return rB end
local function hideSkeleton(p) if skeletons[p] then for _,l in ipairs(skeletons[p].Lines) do l[1].Visible=false; l[2].Visible=false end end end
local function removeSkeleton(p) if skeletons[p] then removeLines(skeletons[p].Lines); skeletons[p]=nil end end
local function removeAllSkeletons() for p in pairs(skeletons) do removeSkeleton(p) end end

-- ==================== HIGHLIGHT ====================
local function createHighlight(p, t) local h=Instance.new("Highlight"); h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.Parent=t; h.Adornee=p.Character; return h end
local function removeHighlight_Outline(p) if highlights_outline[p] then pcall(function() highlights_outline[p]:Destroy() end); highlights_outline[p]=nil end end
local function removeAllHighlights_Outline() for p in pairs(highlights_outline) do removeHighlight_Outline(p) end end
local function removeHighlight_Filled(p) if highlights_filled[p] then pcall(function() highlights_filled[p]:Destroy() end); highlights_filled[p]=nil end; if nametags_filled[p] then pcall(function() nametags_filled[p]:Destroy() end); nametags_filled[p]=nil end end
local function removeAllHighlights_Filled() for p in pairs(highlights_filled) do removeHighlight_Filled(p) end end

-- ==================== TRACER ====================
local function getOrCreateTracer(p) if not tracers[p] then tracers[p]=Drawing.new("Line"); tracers[p].Visible=false; tracers[p].Thickness=1.5 end; return tracers[p] end
local function removeTracer(p) if tracers[p] then tracers[p]:Remove(); tracers[p]=nil end end
local function removeAllTracers() for p in pairs(tracers) do removeTracer(p) end end

-- ==================== DEAD MARKERS (NEW) ====================
local function removeDeadMarker(p) if dead_markers[p] then pcall(function() dead_markers[p]:Destroy() end); dead_markers[p]=nil end end
local function removeAllDeadMarkers() for p in pairs(dead_markers) do removeDeadMarker(p) end end
local function hideAllESP(player) hideSkeleton(player); if highlights_outline[player] then highlights_outline[player].Enabled = false end; if highlights_filled[player] then highlights_filled[player].Enabled = false end; if nametags_filled[player] then nametags_filled[player].Enabled = false end; if tracers[player] then tracers[player].Visible = false end; if dead_markers[player] then dead_markers[player].Enabled = false end; end

-- ──────────────────────────────────────────────
-- LOOP PRINCIPAL (REWORKED)
-- ──────────────────────────────────────────────
local function UpdateESP()
    -- Cleanup players who left
    for p in pairs(skeletons) do if not p or not p.Parent then removeSkeleton(p) end end
    for p in pairs(highlights_outline) do if not p or not p.Parent then removeHighlight_Outline(p) end end
    for p in pairs(highlights_filled) do if not p or not p.Parent then removeHighlight_Filled(p) end end
    for p in pairs(tracers) do if not p or not p.Parent then removeTracer(p) end end
    for p in pairs(dead_markers) do if not p or not p.Parent then removeDeadMarker(p) end end

    for _, player in ipairs(Players:GetPlayers()) do
        local isValid, isAlive = IsValidTarget(player)
        local char = player.Character

        if not isValid then
            hideAllESP(player) -- Hide everything if not a valid target (e.g., out of range)
            continue
        end
        
        local color = GetColor(player, isAlive)

        -- Player is ALIVE and in range
        if isAlive then
            if dead_markers[player] then removeDeadMarker(player) end -- Clean up dead marker if they respawned

            if Config.Skeleton then
                local s = skeletons[player]; if not s then s = { Lines = buildLines(player, color) }; skeletons[player] = s; end
                if updateSkeleton(player, s.Lines, color) or #s.Lines == 0 then removeLines(s.Lines); s.Lines = buildLines(player, color) end
            else hideSkeleton(player) end

            if Config.Outline then
                local h = highlights_outline[player]; if not h or not h.Parent then h = createHighlight(player, char); highlights_outline[player] = h; end
                h.OutlineColor = color; h.FillTransparency = 1; h.OutlineTransparency = 0; h.Enabled = true
            elseif highlights_outline[player] then highlights_outline[player].Enabled = false end

            if Config.Preenchido then
                local h = highlights_filled[player]; if not h or not h.Parent then h = createHighlight(player, char); highlights_filled[player] = h; end
                h.FillColor = color; h.OutlineColor = color; h.FillTransparency = 0.5; h.OutlineTransparency = 0.2; h.Enabled = true
                local nT = nametags_filled[player]; if not nT or not nT.Parent then nT = Instance.new("BillboardGui", char); nT.Adornee = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"); nT.Size = UDim2.new(0,200,0,50); nT.StudsOffset = Vector3.new(0,3,0); nT.AlwaysOnTop=true; local tL=Instance.new("TextLabel",nT); tL.Size=UDim2.new(1,0,1,0); tL.BackgroundTransparency=1; tL.TextStrokeTransparency=0;tL.TextSize=14;tL.Font=Enum.Font.SourceSansBold; nametags_filled[player]=nT; end; local tL=nT:FindFirstChildOfClass("TextLabel"); if tL then tL.Text=player.Name; tL.TextColor3=color; end; nT.Enabled=true
            elseif highlights_filled[player] then highlights_filled[player].Enabled=false; if nametags_filled[player] then nametags_filled[player].Enabled=false; end end

            if Config.Tracers then
                local r=char and char:FindFirstChild("HumanoidRootPart"); local t=getOrCreateTracer(player); t.Color=color; if r then local sp,os=Camera:WorldToViewportPoint(r.Position); if os and sp.Z>0 then local vp=Camera.ViewportSize;t.From=Vector2.new(vp.X/2,vp.Y);t.To=Vector2.new(sp.X,sp.Y);t.Visible=true else t.Visible=false end else t.Visible=false end
            elseif tracers[player] then tracers[player].Visible=false end

        -- Player is DEAD and in range
        elseif Config.ShowDead then
            hideSkeleton(player)
            if highlights_outline[player] then highlights_outline[player].Enabled = false end
            if highlights_filled[player] then highlights_filled[player].Enabled=false; if nametags_filled[player] then nametags_filled[player].Enabled=false; end end
            if tracers[player] then tracers[player].Visible=false end

            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local marker = dead_markers[player]
                if not marker or not marker.Parent then
                    marker = Instance.new("BillboardGui", char); marker.Adornee = root; marker.Size = UDim2.new(0, 150, 0, 50); marker.StudsOffset = Vector3.new(0, 2, 0); marker.AlwaysOnTop = true; marker.Name = "DeadMarkerFor"..player.Name
                    local textLabel = Instance.new("TextLabel", marker); textLabel.Size = UDim2.new(1,0,1,0); textLabel.BackgroundTransparency=1; textLabel.Text = "💀 " .. player.Name; textLabel.TextColor3 = color; textLabel.TextStrokeTransparency=0.5; textLabel.TextSize=14; textLabel.Font=Enum.Font.SourceSansBold;
                    dead_markers[player] = marker
                end
                marker.Enabled = true
            end
        else
            hideAllESP(player) -- Hide if ShowDead is off
        end
    end
end

-- ──────────────────────────────────────────────
-- TOGGLE
-- ──────────────────────────────────────────────
local connection
local function ToggleLoop(state)
    if state and not connection then
        connection = RunService.RenderStepped:Connect(UpdateESP)
    elseif not state and connection then
        connection:Disconnect(); connection = nil
        removeAllSkeletons(); removeAllHighlights_Outline(); removeAllHighlights_Filled(); removeAllTracers(); removeAllDeadMarkers()
    end
end

-- ──────────────────────────────────────────────
-- UI
-- ──────────────────────────────────────────────
local ESP_Module = Visual:AddModule("👁️ ESP", function(state) Config.Enabled = state; ToggleLoop(state) end, false)
ESP_Module:AddToggle("💀 Skeleton (Graveto)", Config.Skeleton, function(state) Config.Skeleton = state; if not state then removeAllSkeletons() end; Save() end)
ESP_Module:AddToggle("🔲 Outline (Contorno)", Config.Outline, function(state) Config.Outline = state; if not state then removeAllHighlights_Outline() end; Save() end)
ESP_Module:AddToggle("🎨 Preenchido (Cheio)", Config.Preenchido, function(state) Config.Preenchido = state; if not state then removeAllHighlights_Filled() end; Save() end)
ESP_Module:AddToggle("📈 Tracers (Linhas)", Config.Tracers, function(state) Config.Tracers = state; if not state then removeAllTracers() end; Save() end)
ESP_Module:AddToggle("👥 Checar Time (Cores)", Config.TeamCheck, function(state) Config.TeamCheck = state; Save() end)

-- NEW UI TOGGLE
ESP_Module:AddToggle("👻 Mostrar Mortos", Config.ShowDead, function(state)
    Config.ShowDead = state
    if not state then removeAllDeadMarkers() end
    Save()
end)

ESP_Module:AddSlider("📏 Distância Máxima", 10, 1000, Config.MaxDistance, true, function(value) Config.MaxDistance = value; Save() end)

print("✅ ESP V8 (Dead Markers) carregado!")

return function()
    if connection then connection:Disconnect(); connection = nil end
    removeAllSkeletons(); removeAllHighlights_Outline(); removeAllHighlights_Filled(); removeAllTracers(); removeAllDeadMarkers()
end