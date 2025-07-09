--!strict
-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- VARIABLES
local Prediction = 0.12
local CurrentTarget = nil
local Locking = false
local AutoUnlock = false
local AutoFire = false
local SmoothAimSpeed = 0.3
local Hitbox = "Head"
local ESPEnabled = false
local FOVEnabled = true
local SpeedEnabled = false
local SpeedValue = 24 -- Default WalkSpeed
local JumpAssistEnabled = false
local NoRecoilEnabled = false
local NoSpreadEnabled = false
local SilentAimEnabled = false

local Config = {} -- For saving settings in session

-- SOUNDS
local SoundClick = Instance.new("Sound")
SoundClick.SoundId = "rbxassetid://1420701276" -- click sound
SoundClick.Volume = 0.3
SoundClick.Parent = workspace

local SoundToggle = Instance.new("Sound")
SoundToggle.SoundId = "rbxassetid://15666462" -- toggle sound
SoundToggle.Volume = 0.3
SoundToggle.Parent = workspace

-- UTILITIES
local function PlayClick()
    SoundClick:Play()
end
local function PlayToggle()
    SoundToggle:Play()
end

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZylxEliteGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- DRAGGABLE BUTTON TO OPEN/CLOSE GUI
local ToggleButton = Instance.new("TextButton")
ToggleButton.Text = "Zylx Elite"
ToggleButton.Size = UDim2.new(0, 120, 0, 40)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -20)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 20
ToggleButton.Active = true
ToggleButton.Draggable = true
ToggleButton.Parent = ScreenGui

-- MAIN FRAME (HIDDEN BY DEFAULT)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 450)
MainFrame.Position = UDim2.new(0, 150, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

-- ROUND CORNERS
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 15)
Corner.Parent = MainFrame

-- TITLE BAR
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "Zylx Elite"
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 28
TitleLabel.Parent = TitleBar

-- CLOSE BUTTON
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "✕"
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 24
CloseBtn.Parent = TitleBar

CloseBtn.MouseButton1Click:Connect(function()
    PlayClick()
    MainFrame.Visible = false
end)

ToggleButton.MouseButton1Click:Connect(function()
    PlayClick()
    MainFrame.Visible = not MainFrame.Visible
end)

-- TABS CONTAINER
local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(1, 0, 0, 40)
TabsFrame.Position = UDim2.new(0, 0, 0, 40)
TabsFrame.BackgroundTransparency = 1
TabsFrame.Parent = MainFrame

local Tabs = {"Main", "Combat", "Visuals", "Movement", "Settings"}
local tabButtons = {}
local contentFrames = {}

for i, tabName in ipairs(Tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 1, 0)
    btn.Position = UDim2.new(0, (i-1)*90, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 18
    btn.Text = tabName
    btn.Name = tabName .. "Tab"
    btn.AutoButtonColor = false
    btn.Parent = TabsFrame
    tabButtons[tabName] = btn

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -40)
    content.Position = UDim2.new(0, 0, 0, 40)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = MainFrame
    contentFrames[tabName] = content
end
-- Default to Main tab
contentFrames["Main"].Visible = true
tabButtons["Main"].BackgroundColor3 = Color3.fromRGB(70, 70, 70)

-- Switch tab function
local function switchTab(name)
    for tn, btn in pairs(tabButtons) do
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        contentFrames[tn].Visible = false
    end
    tabButtons[name].BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    contentFrames[name].Visible = true
end
for tn, btn in pairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        PlayClick()
        switchTab(tn)
    end)
end

-- ======= Main Tab Content =======
local MainContent = contentFrames["Main"]

local LockButton = Instance.new("TextButton")
LockButton.Size = UDim2.new(0, 120, 0, 40)
LockButton.Position = UDim2.new(0, 15, 0, 10)
LockButton.Text = "🔒 LOCK"
LockButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
LockButton.TextColor3 = Color3.new(1,1,1)
LockButton.Font = Enum.Font.GothamBold
LockButton.TextSize = 20
LockButton.AutoButtonColor = true
LockButton.Parent = MainContent

local LockStatus = Instance.new("TextLabel")
LockStatus.Text = "Status: Unlocked"
LockStatus.Size = UDim2.new(1, -160, 0, 30)
LockStatus.Position = UDim2.new(0, 150, 0, 15)
LockStatus.BackgroundTransparency = 1
LockStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
LockStatus.Font = Enum.Font.Gotham
LockStatus.TextSize = 16
LockStatus.TextXAlignment = Enum.TextXAlignment.Left
LockStatus.Parent = MainContent

-- Helper function: get closest target inside FOV
local FOVRadius = 150
local function getClosestTarget()
    local closest = nil
    local shortestDist = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
                if onScreen then
                    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < FOVRadius and dist < shortestDist then
                        closest = player
                        shortestDist = dist
                    end
                end
            end
        end
    end
    return closest
end

-- Function: Aim at target hitbox with prediction and smoothness
local function aimAtTarget(target)
    if not target or not target.Character then return end
    local rootPart = target.Character:FindFirstChild("HumanoidRootPart")
    local hitPart = target.Character:FindFirstChild(Hitbox)
    if not rootPart or not hitPart then return end

    -- Calculate predicted position
    local velocity = rootPart.Velocity
    local predictedPos = hitPart.Position + velocity * Prediction

    -- Calculate screen position
    local screenPos, onScreen = Camera:WorldToScreenPoint(predictedPos)
    if not onScreen then return end

    if not SilentAimEnabled then
        -- Smooth aim movement
        local mousePos = Vector2.new(Mouse.X, Mouse.Y)
        local targetPos = Vector2.new(screenPos.X, screenPos.Y)
        local newPos = mousePos:Lerp(targetPos, SmoothAimSpeed)
        mousemoverel(newPos.X - mousePos.X, newPos.Y - mousePos.Y)
    else
        -- Silent aim: No cursor movement, just shoot to predicted position (needs integration with firing)
    end
end

-- Lock Button Logic
LockButton.MouseButton1Click:Connect(function()
    PlayClick()
    if Locking then
        Locking = false
        CurrentTarget = nil
        LockButton.Text = "🔒 LOCK"
        LockStatus.Text = "Status: Unlocked"
        return
    end

    local target = getClosestTarget()
    if target then
        CurrentTarget = target
        Locking = true
        LockButton.Text = "🔓 UNLOCK"
        LockStatus.Text = "Status: Locked on " .. target.Name
    else
        LockStatus.Text = "Status: No target found"
    end
end)

-- Auto Unlock logic (target dead or out of sight)
RunService.RenderStepped:Connect(function()
    if Locking and CurrentTarget then
        if not CurrentTarget.Character or not CurrentTarget.Character:FindFirstChild("Humanoid") or CurrentTarget.Character.Humanoid.Health <= 0 then
            Locking = false
            CurrentTarget = nil
            LockButton.Text = "🔒 LOCK"
            LockStatus.Text = "Status: Unlocked"
            return
        end
    end
end)

-- Aim update loop
RunService.RenderStepped:Connect(function()
    if Locking and CurrentTarget then
        aimAtTarget(CurrentTarget)
        -- Auto Fire if enabled
        if AutoFire then
            -- Simulate mouse click (fires)
            mouse1press()
            wait(0.05)
            mouse1release()
        end
    end
end)

-- ======= Combat Tab Content =======
local CombatContent = contentFrames["Combat"]

-- Prediction slider
local PredictionLabel = Instance.new("TextLabel")
PredictionLabel.Text = "Prediction: " .. string.format("%.3f", Prediction)
PredictionLabel.Size = UDim2.new(1, -30, 0, 30)
PredictionLabel.Position = UDim2.new(0, 15, 0, 10)
PredictionLabel.BackgroundTransparency = 1
PredictionLabel.TextColor3 = Color3.new(1,1,1)
PredictionLabel.Font = Enum.Font.Gotham
PredictionLabel.TextSize = 18
PredictionLabel.Parent = CombatContent

local PredictionSlider = Instance.new("Frame")
PredictionSlider.Size = UDim2.new(1, -30, 0, 30)
PredictionSlider.Position = UDim2.new(0, 15, 0, 45)
PredictionSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
PredictionSlider.Parent = CombatContent

local SliderBar = Instance.new("Frame")
SliderBar.Size = UDim2.new(0, 0, 1, 0)
SliderBar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
SliderBar.Parent = PredictionSlider

local draggingPrediction = false

PredictionSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingPrediction = true
    end
end)
PredictionSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingPrediction = false
    end
end)
PredictionSlider.InputChanged:Connect(function(input)
    if draggingPrediction and input.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = math.clamp((input.Position.X - PredictionSlider.AbsolutePosition.X) / PredictionSlider.AbsoluteSize.X, 0, 1)
        Prediction = pos * 0.5
        SliderBar.Size = UDim2.new(pos, 0, 1, 0)
        PredictionLabel.Text = ("Prediction: %.3f"):format(Prediction)
    end
end)

-- Auto Fire Toggle
local AutoFireToggle = Instance.new("TextButton")
AutoFireToggle.Text = "Auto Fire: OFF"
AutoFireToggle.Size = UDim2.new(1, -30, 0, 40)
AutoFireToggle.Position
