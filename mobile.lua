-- ZYLX ELITE MOBILE VERSION (2025) - By mvnki.
-- Prediction set to 0.1354136 as requested

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Settings
local Prediction = 0.1354136
local Smoothness = 0.15
local Locking = false
local CurrentTarget = nil
local HitboxPart = "Head"
local AutoUnlock = true
local AutoFire = false
local FOVRadius = 140
local Accuracy = 100 -- percent
local SpeedBoostEnabled = false
local SpeedValue = 32

-- Sounds
local function playClickSound()
local sound = Instance.new("Sound", Camera)
sound.SoundId = "rbxassetid://15666462" -- click sound
sound.Volume = 0.5
sound:Play()
game:GetService("Debris"):AddItem(sound, 1)
end

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZylxEliteGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 330, 0, 420)
MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Zylx Elite Mobile"
Title.TextColor3 = Color3.fromRGB(220, 220, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 26
Title.Parent = MainFrame

-- Tabs
local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(1, 0, 0, 40)
TabsFrame.Position = UDim2.new(0, 0, 0, 40)
TabsFrame.BackgroundTransparency = 1
TabsFrame.Parent = MainFrame

local Tabs = {"Main", "Combat", "Visuals", "Movement", "Settings"}
local TabButtons = {}
local ContentFrames = {}

for i, tabName in ipairs(Tabs) do
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1/#Tabs, -4, 1, 0)
btn.Position = UDim2.new((i-1)/#Tabs, 2, 0, 0)
btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 18
btn.Text = tabName
btn.AutoButtonColor = true
btn.Parent = TabsFrame
TabButtons[tabName] = btn

local frame = Instance.new("Frame")  
frame.Size = UDim2.new(1, -10, 1, -50)  
frame.Position = UDim2.new(0, 5, 0, 50)  
frame.BackgroundTransparency = 1  
frame.Visible = false  
frame.Parent = MainFrame  
ContentFrames[tabName] = frame

end

-- Show Main tab default
ContentFrames["Main"].Visible = true
TabButtons["Main"].BackgroundColor3 = Color3.fromRGB(70, 70, 100)

local function switchTab(name)
for tn, btn in pairs(TabButtons) do
btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
ContentFrames[tn].Visible = false
end
TabButtons[name].BackgroundColor3 = Color3.fromRGB(70, 70, 100)
ContentFrames[name].Visible = true
end

for tn, btn in pairs(TabButtons) do
btn.MouseButton1Click:Connect(function()
playClickSound()
switchTab(tn)
end)
end

-- Toggle GUI button
local ToggleGUIBtn = Instance.new("TextButton")
ToggleGUIBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleGUIBtn.Position = UDim2.new(0, 10, 0.85, 0)
ToggleGUIBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 110)
ToggleGUIBtn.TextColor3 = Color3.new(1,1,1)
ToggleGUIBtn.Font = Enum.Font.GothamBold
ToggleGUIBtn.TextSize = 28
ToggleGUIBtn.Text = "Z"
ToggleGUIBtn.AutoButtonColor = true
ToggleGUIBtn.Parent = ScreenGui
local guiVisible = true
ToggleGUIBtn.MouseButton1Click:Connect(function()
playClickSound()
guiVisible = not guiVisible
MainFrame.Visible = guiVisible
end)

-- Main Tab Elements
local MainTab = ContentFrames["Main"]

-- Lock Button (movable)
local LockBtn = Instance.new("TextButton")
LockBtn.Size = UDim2.new(0, 140, 0, 50)
LockBtn.Position = UDim2.new(0, 10, 0, 10)
LockBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 90)
LockBtn.TextColor3 = Color3.new(1,1,1)
LockBtn.Font = Enum.Font.GothamBold
LockBtn.TextSize = 20
LockBtn.Text = "🔒 LOCK"
LockBtn.AutoButtonColor = true
LockBtn.Active = true
LockBtn.Draggable = true
LockBtn.Parent = MainTab

-- Locking logic
local function getClosestTarget()
local closest, shortestDist = nil, math.huge
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
local part = player.Character:FindFirstChild(HitboxPart)
if part then
local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
if onScreen then
local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
if dist < shortestDist and dist <= FOVRadius then
closest = player
shortestDist = dist
end
end
end
end
end
return closest
end

LockBtn.MouseButton1Click:Connect(function()
playClickSound()
if Locking then
Locking = false
CurrentTarget = nil
LockBtn.Text = "🔒 LOCK"
else
local target = getClosestTarget()
if target then
Locking = true
CurrentTarget = target
LockBtn.Text = "🔓 UNLOCK"
else
LockBtn.Text = "❌ NO TARGET"
wait(1)
LockBtn.Text = "🔒 LOCK"
end
end
end)

-- Combat Tab
local CombatTab = ContentFrames["Combat"]

-- Prediction slider creator
local function createSlider(parent, y, labelText, min, max, default, callback)
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -20, 0, 20)
label.Position = UDim2.new(0, 10, 0, y)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1,1,1)
label.Font = Enum.Font.Gotham
label.TextSize = 14
label.Text = labelText .. ": " .. tostring(default)
label.Parent = parent

local slider = Instance.new("TextButton")  
slider.Size = UDim2.new(1, -20, 0, 20)  
slider.Position = UDim2.new(0, 10, 0, y + 22)  
slider.BackgroundColor3 = Color3.fromRGB(40,40,60)  
slider.Text = ""  
slider.AutoButtonColor = false  
slider.Parent = parent  

local fill = Instance.new("Frame")  
fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)  
fill.BackgroundColor3 = Color3.fromRGB(255, 100, 100)  
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
        local val = min + relativeX * (max - min)  
        label.Text = labelText .. ": " .. string.format("%.3f", val)  
        callback(val)  
    end  
end)  
return label, slider

end

-- Prediction slider
local PredictionLabel, PredictionSlider = createSlider(CombatTab, 10, "Prediction", 0, 0.2, Prediction, function(val)
Prediction = val
end)

-- Accuracy slider (0-100%)
local AccuracyLabel, AccuracySlider = createSlider(CombatTab, 60, "Accuracy", 0, 100, Accuracy, function(val)
Accuracy = val
end)

-- Smoothness slider (0-1)
local SmoothnessLabel, SmoothnessSlider = createSlider(CombatTab, 110, "Smoothness", 0, 1, Smoothness, function(val)
Smoothness = val
end)

-- Auto Fire toggle button
local AutoFireBtn = Instance.new("TextButton")
AutoFireBtn.Size = UDim2.new(1, -20, 0, 35)
AutoFireBtn.Position = UDim2.new(0, 10, 0, 160)
AutoFireBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 90)
AutoFireBtn.TextColor3 = Color3.new(1,1,1)
AutoFireBtn.Font = Enum.Font.GothamBold
AutoFireBtn.TextSize = 16
AutoFireBtn.Text = "Auto Fire: OFF"
AutoFireBtn.AutoButtonColor = true
AutoFireBtn.Parent = CombatTab

AutoFireBtn.MouseButton1Click:Connect(function()
playClickSound()
AutoFire = not AutoFire
AutoFireBtn.Text = AutoFire and "Auto Fire: ON" or "Auto Fire: OFF"
end)

-- Auto Unlock toggle button
local AutoUnlockBtn = Instance.new("TextButton")
AutoUnlockBtn.Size = UDim2.new(1, -20, 0, 35)
AutoUnlockBtn.Position = UDim2.new(0, 10, 0, 205)
AutoUnlockBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 90)
AutoUnlockBtn.TextColor3 = Color3.new(1,1,1)
AutoUnlockBtn.Font = Enum.Font.GothamBold
AutoUnlockBtn.TextSize = 16
AutoUnlockBtn.Text = "Auto Unlock: ON"
AutoUnlockBtn.AutoButtonColor = true
AutoUnlockBtn.Parent = CombatTab

AutoUnlockBtn.MouseButton1Click:Connect(function()
playClickSound()
AutoUnlock = not AutoUnlock
AutoUnlockBtn.Text = AutoUnlock and "Auto Unlock: ON" or "Auto Unlock: OFF"
end)

-- Hitbox selector
local Hitboxes = {"Head", "UpperTorso", "HumanoidRootPart", "LeftHand", "RightHand", "LeftFoot", "RightFoot"}
local SelectedHitboxIndex = 1

local HitboxLabel = Instance.new("TextLabel")
HitboxLabel.Size = UDim2.new(1, -20, 0, 25)
HitboxLabel.Position = UDim2.new(0, 10, 0, 250)
HitboxLabel.Text = "Hitbox: " .. Hitboxes[SelectedHitboxIndex]
HitboxLabel.TextColor3 = Color3.new(1,1,1)
HitboxLabel.BackgroundTransparency = 1
HitboxLabel.Font = Enum.Font.Gotham
HitboxLabel.TextSize = 18
HitboxLabel.Parent = CombatTab

local HitboxBtn = Instance.new("TextButton")
HitboxBtn.Size = UDim2.new(1, -20, 0, 35)
HitboxBtn.Position = UDim2.new(0, 10, 0, 280)
HitboxBtn.Text = "Change Hitbox"
HitboxBtn.Font = Enum.Font.GothamBold
HitboxBtn.TextSize = 16
HitboxBtn.BackgroundColor3 = Color3.fromRGB(40,40,60)
HitboxBtn.TextColor3 = Color3.new(1,1,1)
HitboxBtn.Parent = CombatTab
HitboxBtn.AutoButtonColor = true

HitboxBtn.MouseButton1Click:Connect(function()
playClickSound()
SelectedHitboxIndex = SelectedHitboxIndex + 1
if SelectedHitboxIndex > #Hitboxes then
SelectedHitboxIndex = 1
end
HitboxLabel.Text = "Hitbox: " .. Hitboxes[SelectedHitboxIndex]
HitboxPart = Hitboxes[SelectedHitboxIndex]
end)

-- Visuals Tab
local VisualsTab = ContentFrames["Visuals"]

-- ESP Toggle
local ESPEnabled = false
local ESPBtn = Instance.new("TextButton")
ESPBtn.Size = UDim2.new(1, -20, 0, 35)
ESPBtn.Position = UDim2.new(0, 10, 0, 10)
ESPBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 90)
ESPBtn.TextColor3 = Color3.new(1,1,1)
ESPBtn.Font = Enum.Font.GothamBold
ESPBtn.TextSize = 16
ESPBtn.Text = "ESP: OFF"
ESPBtn.AutoButtonColor = true
ESPBtn.Parent = VisualsTab

ESPBtn.MouseButton1Click:Connect(function()
playClickSound()
ESPEnabled = not ESPEnabled
ESPBtn.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"
end)

-- FOV Circle toggle
local FOVVisible = true
local FOVBtn = Instance.new("TextButton")
FOVBtn.Size = UDim2.new(1, -20, 0, 35)
FOVBtn.Position = UDim2.new(0, 10, 0, 60)
FOVBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 90)
FOVBtn.TextColor3 = Color3.new(1,1,1)
FOVBtn.Font = Enum.Font.GothamBold
FOVBtn.TextSize = 16
FOVBtn.Text = "FOV Circle: ON"
FOVBtn.AutoButtonColor = true
FOVBtn.Parent = VisualsTab

FOVBtn.MouseButton1Click:Connect(function()
playClickSound()
FOVVisible = not FOVVisible
FOVBtn.Text = FOVVisible and "FOV Circle: ON" or "FOV Circle: OFF"
end)

-- Movement Tab
local MovementTab = ContentFrames["Movement"]

local SpeedEnabled = false
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(1, -20, 0, 35)
SpeedBtn.Position = UDim2.new(0, 10, 0, 10)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 90)
SpeedBtn.TextColor3 = Color3.new(1,1,1)
SpeedBtn.Font = Enum.Font.GothamBold
SpeedBtn.TextSize = 16
SpeedBtn.Text = "Speed: OFF"
SpeedBtn.AutoButtonColor = true
SpeedBtn.Parent = MovementTab

SpeedBtn.MouseButton1Click:Connect(function()
playClickSound()
SpeedEnabled = not SpeedEnabled
SpeedBtn.Text = SpeedEnabled and "Speed: ON" or "Speed: OFF"
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
LocalPlayer.Character.Humanoid.WalkSpeed = SpeedEnabled and SpeedValue or 16
end
end)

-- Crosshair Setup (simple + subtle)
local crosshair = Drawing.new("Line")
crosshair.Color = Color3.fromRGB(255, 255, 255)
crosshair.Thickness = 2
crosshair.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2 - 10, workspace.CurrentCamera.ViewportSize.Y/2)
crosshair.To = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2 + 10, workspace.CurrentCamera.ViewportSize.Y/2)

local crosshairV = Drawing.new("Line")
crosshairV.Color = Color3.fromRGB(255, 255, 255)

local crosshairV = Drawing.new("Line")
crosshairV.Color = Color3.fromRGB(255, 255, 255)
crosshairV.Thickness = 2
crosshairV.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2 - 10)
crosshairV.To = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2 + 10)

-- Crosshair location update with screen or camera changes
RunService.RenderStepped:Connect(function()
local cx, cy = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
crosshair.From = Vector2.new(cx - 10, cy)
crosshair.To = Vector2.new(cx + 10, cy)
crosshairV.From = Vector2.new(cx, cy - 10)
crosshairV.To = Vector2.new(cx, cy + 10)
end)

