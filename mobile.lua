-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Variables
local Prediction = 0.13
local AutoFire = false
local Locking = false
local CurrentTarget = nil
local HitboxPartName = "Head" -- Default hitbox
local Accuracy = 100 -- % chance to hit
local Smoothness = 0.25 -- 0-1 (0 = instant, 1 = slowest)
local AutoUnlock = true
local ESPEnabled = false
local TeamCheck = true
local ChamsEnabled = false
local SpeedBoostEnabled = false
local SpeedValue = 30 -- default speed boost
local JumpAssistEnabled = false
local NoRecoilEnabled = false
local NoSpreadEnabled = false
local SafeModeEnabled = false

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZylxEliteGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- Main draggable frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 400)
MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Zylx Elite"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 28
Title.Parent = MainFrame

-- Tabs buttons container
local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(1, 0, 0, 40)
TabsFrame.Position = UDim2.new(0, 0, 0, 40)
TabsFrame.BackgroundTransparency = 1
TabsFrame.Parent = MainFrame

local tabs = {"Main", "Combat", "Visuals", "Movement", "Settings"}
local tabButtons = {}
local contentFrames = {}

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1/#tabs, -4, 1, 0)
    btn.Position = UDim2.new((i-1)/#tabs, 2, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Text = tabName
    btn.AutoButtonColor = true
    btn.Parent = TabsFrame
    tabButtons[tabName] = btn

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 1, -50)
    frame.Position = UDim2.new(0, 5, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.Parent = MainFrame
    contentFrames[tabName] = frame
end

-- Show Main tab by default
contentFrames["Main"].Visible = true
tabButtons["Main"].BackgroundColor3 = Color3.fromRGB(70, 70, 100)

-- Tab switch function
local function switchTab(name)
    for tn, btn in pairs(tabButtons) do
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        contentFrames[tn].Visible = false
    end
    tabButtons[name].BackgroundColor3 = Color3.fromRGB(70, 70, 100)
    contentFrames[name].Visible = true
end

for tn, btn in pairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        switchTab(tn)
    end)
end

-- Toggle GUI button (small button on screen)
local toggleGuiBtn = Instance.new("TextButton")
toggleGuiBtn.Size = UDim2.new(0, 50, 0, 50)
toggleGuiBtn.Position = UDim2.new(0, 10, 0.8, 0)
toggleGuiBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
toggleGuiBtn.TextColor3 = Color3.new(1,1,1)
toggleGuiBtn.Font = Enum.Font.GothamBold
toggleGuiBtn.TextSize = 28
toggleGuiBtn.Text = "Z"
toggleGuiBtn.AutoButtonColor = true
toggleGuiBtn.Parent = ScreenGui
local guiVisible = true
toggleGuiBtn.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    MainFrame.Visible = guiVisible
end)

-- Utility function: Create labeled toggle button
local function createToggleButton(parent, posY, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Text = text
    btn.AutoButtonColor = true
    btn.Parent = parent
    return btn
end

-- Utility function: Create labeled slider (with label updating)
local function createSlider(parent, posY, labelText, minVal, maxVal, defaultVal, callback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, posY)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Text = labelText .. ": " .. tostring(defaultVal)
    label.Parent = parent

    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(1, -20, 0, 20)
    slider.Position = UDim2.new(0, 10, 0, posY + 22)
    slider.BackgroundColor3 = Color3.fromRGB(40,40,60)
    slider.Text = ""
    slider.AutoButtonColor = false
    slider.Parent = parent

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    fill.Parent = slider

    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    slider.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relativeX = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(relativeX, 0, 1, 0)
            local val = math.floor(minVal + relativeX * (maxVal - minVal) * 1000) / 1000
            label.Text = labelText .. ": " .. tostring(val)
            callback(val)
        end
    end)
    return label, slider
end

-- ===== Main Tab Content =====
local mainTab = contentFrames["Main"]

-- Lock Button (movable)
local LockButton = Instance.new("TextButton")
LockButton.Size = UDim2.new(0, 130, 0, 45)
LockButton.Position = UDim2.new(0, 10, 0, 10)
LockButton.BackgroundColor3 = Color3.fromRGB(50,50,80)
LockButton.TextColor3 = Color3.new(1,1,1)
LockButton.Font = Enum.Font.GothamBold
LockButton.TextSize = 20
LockButton.Text = "🔒 LOCK"
LockButton.AutoButtonColor = true
LockButton.Active = true
LockButton.Draggable = true
LockButton.Parent = mainTab

-- Lock Tool toggle
local LockToolToggle = createToggleButton(mainTab, 65, "Lock Tool: OFF")
local Tool = Instance.new("Tool")
Tool.RequiresHandle = false
Tool.Name = "Lock Tool"
Tool.Enabled = false
Tool.Parent = LocalPlayer.Backpack

LockToolToggle.MouseButton1Click:Connect(function()
    if Tool.Enabled then
        Tool.Enabled = false
        LockToolToggle.Text = "Lock Tool: OFF"
        LockButton.Visible = true
        Locking = false
        CurrentTarget = nil
        LockButton.Text = "🔒 LOCK"
    else
        Tool.Enabled = true
        LockToolToggle.Text = "Lock Tool: ON"
        LockButton.Visible = false
        Locking = false
        CurrentTarget = nil
        LockButton.Text = "🔒 LOCK"
    end
end)

Tool.Activated:Connect(function()
    local target = Mouse.Target and Players:GetPlayerFromCharacter(Mouse.Target.Parent)
    if target and target ~= LocalPlayer then
        CurrentTarget = target
        Locking = true
        LockButton.Text = "🔓 UNLOCK"
    end
end)

LockButton.MouseButton1Click:Connect(function()
    if Locking then
        Locking = false
        CurrentTarget = nil
        LockButton.Text = "🔒 LOCK"
        return
    end
    -- Lock nearest target in FOV circle
    local closest, shortestDist = nil, math.huge
    local FOVRadius = 150 -- same as visual FOV circle radius
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local part = player.Character:FindFirstChild(HitboxPartName)
            if part then
                local screenPos, onScreen = Camera:WorldToScreenPoint(part.Position)
                if onScreen then
                    local distToMouse = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if distToMouse < shortestDist and distToMouse <= FOVRadius then
                        if TeamCheck and player.Team == LocalPlayer.Team then
                            -- Skip teammates
                        else
                            closest = player
                            shortestDist = distToMouse
                        end
                    end
                end
            end
        end
    end
    if closest then
        CurrentTarget = closest
        Locking = true
        LockButton.Text = "🔓 UNLOCK"
    end
end)

-- ===== Combat Tab Content =====
local combatTab = contentFrames["Combat"]

-- Prediction slider
local function onPredictionChange(val)
    Prediction = val
end
local predLabel, predSlider = createSlider(combatTab, 10, "Prediction", 0, 0.2, Prediction, onPredictionChange)

-- Accuracy slider
local function onAccuracyChange(val)
    Accuracy = val * 100
end
local accLabel, accSlider = createSlider(combatTab, 60, "Accuracy", 0, 100, Accuracy/100, onAccuracyChange)

-- Smoothness slider
local SmoothnessVal = 0.25
local function onSmoothnessChange(val)
    SmoothnessVal = val
end
local smoothLabel, smoothSlider = createSlider(combatTab, 110, "Smoothness", 0, 1, SmoothnessVal, onSmoothnessChange)

-- Auto Fire toggle
local AutoFireToggle = createToggleButton(combatTab, 160, "Auto Fire: OFF")
AutoFireToggle.MouseButton1Click:Connect(function()
    AutoFire = not AutoFire
    AutoFireToggle.Text = AutoFire and "Auto Fire: ON" or "Auto Fire: OFF"
end)

-- Auto Unlock toggle
local AutoUnlockToggle = createToggleButton(combatTab, 210, "Auto Unlock: ON")
AutoUnlock = true
AutoUnlockToggle.MouseButton1Click:Connect(function()
    AutoUnlock = not AutoUnlock
    AutoUnlockToggle.Text = AutoUnlock and "Auto Unlock: ON" or "Auto Unlock: OFF"
end)

-- Hitbox selector dropdown
local hitboxes = {"Head", "UpperTorso", "LeftHand", "RightHand", "LeftFoot", "RightFoot", "LowerTorso"}
local selectedHitboxIndex = 1
local HitboxLabel = Instance.new("TextLabel")
HitboxLabel.Size = UDim2.new(1, -20, 0, 25)
HitboxLabel.Position = UDim2.new(0, 10, 0, 270)
HitboxLabel.Text = "Hitbox: " .. hitboxes[selectedHitboxIndex]
HitboxLabel.TextColor3 = Color3.new(1,1,1)
HitboxLabel.BackgroundTransparency = 1
HitboxLabel.Font = Enum.Font.Gotham
HitboxLabel.TextSize = 18
HitboxLabel.Parent = combatTab

local HitboxBtn = Instance.new("TextButton")
HitboxBtn.Size = UDim2.new(1, -20, 0, 35)
HitboxBtn.Position = UDim2.new(0, 10, 0, 300)
HitboxBtn.Text = "Change Hitbox"
HitboxBtn.Font = Enum.Font.GothamBold
HitboxBtn.TextSize = 16
HitboxBtn.BackgroundColor3 = Color3.fromRGB(40,40,60)
HitboxBtn.TextColor3 = Color3.new(1,1,1)
HitboxBtn.Parent = combatTab
HitboxBtn.AutoButtonColor = true

HitboxBtn.MouseButton1Click:Connect(function()
    selectedHitboxIndex = selectedHitboxIndex + 1
    if selectedHitboxIndex > #hitboxes then selectedHitboxIndex = 1 end
    HitboxLabel.Text = "Hitbox: " .. hitboxes[selectedHitboxIndex]
    HitboxPartName = hitboxes[selectedHitboxIndex]
end)

-- ===== Visuals Tab Content =====
local visualsTab = contentFrames["Visuals"]

-- ESP Toggle
local ESPToggle = createToggleButton(visualsTab, 10, "ESP: OFF")
ESPToggle.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ESPToggle.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"
end)

-- Team Check Toggle
local TeamCheckToggle = createToggleButton(visualsTab, 60, "Team Check: ON")
TeamCheckToggle.MouseButton1Click:Connect(function()
    TeamCheck = not TeamCheck
    TeamCheckToggle.Text = TeamCheck and "Team Check: ON" or "Team Check: OFF"
end)

-- Chams Toggle
local ChamsToggle = createToggleButton(visualsTab, 110, "Chams: OFF")
ChamsToggle.MouseButton1Click:Connect(function()
    ChamsEnabled = not ChamsEnabled
    ChamsToggle.Text = ChamsEnabled and "Chams: ON" or "Chams: OFF"
end)

-- FOV Circle Toggle
local FOVEnabled = true
local FOVToggle = createToggleButton(visualsTab, 160, "Disable FOV Circle")
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = 150
FOVCircle.Color = Color3.new(1, 0, 0)
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Visible = true

RunService.RenderStepped:Connect(function()
    if FOVEnabled then
        local mousePos = Vector2.new(Mouse.X, Mouse.Y)
        FOVCircle.Position = mousePos
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end)

FOVToggle.MouseButton1Click:Connect(function()
    FOVEnabled = not FOVEnabled
    if FOVEnabled then
        FOVToggle.Text = "Disable FOV Circle"
    else
        FOVToggle.Text = "Enable FOV Circle"
    end
end)

-- ESP Drawing containers
local ESPBoxes = {}
local ESPNames = {}
local ESPHealthBars = {}
local ESPDistanceLabels = {}

-- Function to create ESP elements for a player
local function createESPForPlayer(player)
    if ESPBoxes[player] then return end
    local box = Drawing.new("Square")
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Thickness = 2
    box.Filled = false

    local nameTag = Drawing.new("Text")
    nameTag.Text = player.Name
    nameTag.Color = Color3.fromRGB(255, 255, 255)
    nameTag.Size = 16
    nameTag.Center = true

    local healthBar = Drawing.new("Square")
    healthBar.Color = Color3.fromRGB(0, 255, 0)
    healthBar.Thickness = 3
    healthBar.Filled = true

    local distLabel = Drawing.new("Text")
    distLabel.Text = ""
    distLabel.Color = Color3.fromRGB(255, 255, 255)
    distLabel.Size = 14
