-- Módulo de Arsenal do Mapa (v1.0)

return function(Library, MiscCategory)
    print("  -> 🔫 Carregando Módulo de Arsenal...")

    -- Variáveis locais para a janela e estado
    local arsenalWindow = nil
    local weaponListFrame = nil

    -- Função para escanear e popular a lista de armas
    local function scanAndPopulateWeapons()
        if not (arsenalWindow and weaponListFrame) then return end
        
        -- Limpa a lista antiga
        weaponListFrame:ClearAllChildren()

        print("[Arsenal] Escaneando Tycoons em busca de armas...")
        local tycoonsFolder = workspace:FindFirstChild("Tycoons")
        if not tycoonsFolder then
            warn("[Arsenal] Pasta 'Tycoons' não encontrada no workspace.")
            return
        end

        local weaponsFound = 0
        for _, tycoon in ipairs(tycoonsFolder:GetChildren()) do
            local purchased = tycoon:FindFirstChild("PurchasedObjects")
            if purchased then
                for _, child in ipairs(purchased:GetChildren()) do
                    -- A heurística principal: procurar por "ToolGiver" no nome
                    if string.find(string.lower(child.Name), "toolgiver") then
                        local tool = child:FindFirstChildOfClass("Tool")
                        local touchPart = child:FindFirstChild("Touch")

                        if tool and touchPart and touchPart:FindFirstChildOfClass("TouchTransmitter") then
                            weaponsFound = weaponsFound + 1
                            
                            -- Cria um botão na lista para esta arma
                            local weaponButton = Instance.new("TextButton")
                            weaponButton.Name = tool.Name
                            weaponButton.Text = tool.Name
                            weaponButton.TextSize = 14
                            weaponButton.TextColor3 = Color3.fromRGB(220, 220, 220)
                            weaponButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
                            weaponButton.BorderSizePixel = 0
                            weaponButton.Size = UDim2.new(1, -10, 0, 25)
                            weaponButton.Parent = weaponListFrame

                            -- Ação de clique: coletar a arma
                            weaponButton.MouseButton1Click:Connect(function()
                                print("[Arsenal] Coletando arma: " .. tool.Name)
                                local rootPart = game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if rootPart then
                                    pcall(firetouchinterest, touchPart, rootPart, 0)
                                    pcall(firetouchinterest, touchPart, rootPart, 1)
                                    weaponButton.Text = tool.Name .. " (COLETADO!)"
                                    weaponButton.TextColor3 = Color3.fromRGB(0, 255, 120)
                                end
                            end)
                        end
                    end
                end
            end
        end
        print("[Arsenal] Escaneamento concluído. " .. weaponsFound .. " armas encontradas.")
    end

    -- Função para criar (ou mostrar) a janela do arsenal
    local function openArsenalWindow()
        if arsenalWindow and arsenalWindow.Parent then
            arsenalWindow:Destroy()
            arsenalWindow = nil
            return
        end

        -- Cria a janela principal (Frame)
        arsenalWindow = Instance.new("Frame")
        arsenalWindow.Name = "ArsenalWindow"
        arsenalWindow.Size = UDim2.new(0, 250, 0, 300)
        arsenalWindow.Position = UDim2.new(0.5, -125, 0.5, -150)
        arsenalWindow.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        arsenalWindow.BorderSizePixel = 1
        arsenalWindow.BorderColor3 = Color3.fromRGB(80, 80, 80)
        arsenalWindow.Draggable = true
        arsenalWindow.Parent = Library.ScreenGui

        -- Cria a barra de título
        local titleBar = Instance.new("Frame")
        titleBar.Name = "TitleBar"
        titleBar.Size = UDim2.new(1, 0, 0, 25)
        titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        titleBar.Parent = arsenalWindow

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "TitleLabel"
        titleLabel.Text = "Arsenal do Mapa"
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.Font = Enum.Font.SourceSansBold
        titleLabel.Size = UDim2.new(1, -50, 1, 0)
        titleLabel.Position = UDim2.new(0, 10, 0, 0)
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.BackgroundTransparency = 1
        titleLabel.Parent = titleBar

        -- Cria o botão de fechar
        local closeButton = Instance.new("TextButton")
        closeButton.Name = "CloseButton"
        closeButton.Size = UDim2.new(0, 25, 1, 0)
        closeButton.Position = UDim2.new(1, -25, 0, 0)
        closeButton.Text = "X"
        closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeButton.Parent = titleBar
        closeButton.MouseButton1Click:Connect(function()
            arsenalWindow:Destroy()
            arsenalWindow = nil
        end)

        -- Cria o botão de atualizar
        local refreshButton = Instance.new("TextButton")
        refreshButton.Name = "RefreshButton"
        refreshButton.Size = UDim2.new(0, 60, 0, 20)
        refreshButton.Position = UDim2.new(1, -70, 0, 30)
        refreshButton.Text = "Atualizar"
        refreshButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
        refreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        refreshButton.Parent = arsenalWindow
        refreshButton.MouseButton1Click:Connect(scanAndPopulateWeapons)

        -- Cria o painel de rolagem para a lista de armas
        local scrollingFrame = Instance.new("ScrollingFrame")
        scrollingFrame.Name = "WeaponList"
        scrollingFrame.Size = UDim2.new(1, 0, 1, -60)
        scrollingFrame.Position = UDim2.new(0, 0, 0, 60)
        scrollingFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollingFrame.ScrollBarThickness = 5
        scrollingFrame.Parent = arsenalWindow

        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 5)
        listLayout.SortOrder = Enum.SortOrder.Name
        listLayout.Parent = scrollingFrame

        -- Define a variável global para a função de escaneamento usar
        weaponListFrame = scrollingFrame

        -- Escaneia e popula a lista
        scanAndPopulateWeapons()
    end

    -- Adiciona o módulo à categoria Misc
    -- Usamos isTrigger = true porque o botão apenas abre a janela, ele não tem um estado "ligado/desligado"
    local ArsenalModule = MiscCategory:AddModule("🔫 Arsenal", openArsenalWindow, true)

    print("✅ Módulo de Arsenal carregado com sucesso.")
end
