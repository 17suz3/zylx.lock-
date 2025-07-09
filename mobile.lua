-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Variables
local Prediction = 0.127047434437305158
local CurrentTarget = nil
local Locking = false
local AutoUnlock = false
local ESPEnabled = false
local FOVEnabled = true
local HitEffectEnabled = true

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "ZylxLockGUI"
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 280, 0, 360)
MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

-- Title
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Zylx Lock GUI"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22

-- Tabs container
local TabsFrame = Instance.new("Frame", MainFrame)
TabsFrame.Size = UDim2.new(1, 0, 0, 30)
TabsFrame.Position = UDim2.new(0, 0, 0, 30)
TabsFrame.BackgroundTransparency = 1

-- Content frame (below tabs)
local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -10, 1, -70)
ContentFrame.Position = UDim2.new(0, 5, 0, 65)
ContentFrame.BackgroundTransparency = 1

-- Tab buttons
local tabs = {"Main", "Combat", "Visuals"}
local tabButtons = {}
local contentPages = {}

for i, tabName in ipairs(tabs) do
local btn = Instance.new("TextButton", TabsFrame)
btn.Size = UDim2.new(0, 90, 1, 0)
btn.Position = UDim2.new(0, (i-1)*90, 0, 0)
btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.Gotham
btn.TextSize = 16
btn.Text = tabName
btn.AutoButtonColor = false
btn.Name = tabName .. "Tab"
tabButtons[tabName] = btn

local page = Instance.new("Frame", ContentFrame)  
page.Size = UDim2.new(1, 0, 1, 0)  
page.Visible = false  
contentPages[tabName] = page

end
contentPages["Main"].Visible = true
tabButtons["Main"].BackgroundColor3 = Color3.fromRGB(60, 60, 60)

-- Function to switch tabs
local function switchTab(name)
for tn, btn in pairs(tabButtons) do
btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
contentPages[tn].Visible = false
end
tabButtons[name].BackgroundColor3 = Color3.fromRGB(60, 60, 60)
contentPages[name].Visible = true
end
for tn, btn in pairs(tabButtons) do
btn.MouseButton1Click:Connect(function()
switchTab(tn)
end)
end

-- ======= Main Tab =======
-- Lock Button
local LockButton = Instance.new("TextButton", contentPages["Main"])
LockButton.Size = UDim2.new(0, 120, 0, 40)
LockButton.Position = UDim2.new(0, 10, 0, 10)
LockButton.Text = "🔒 LOCK"
LockButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
LockButton.TextColor3 = Color3.new(1,1,1)
LockButton.Font = Enum.Font.GothamBold
LockButton.TextSize = 18
LockButton.AutoButtonColor = true
LockButton.Active = true
LockButton.Draggable = true

-- Lock Tool toggle
local LockToolToggle = Instance.new("TextButton", contentPages["Main"])
LockToolToggle.Size = UDim2.new(0, 120, 0, 40)
LockToolToggle.Position = UDim2.new(0, 150, 0, 10)
LockToolToggle.Text = "Lock Tool OFF"
LockToolToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
LockToolToggle.TextColor3 = Color3.new(1,1,1)
LockToolToggle.Font = Enum.Font.GothamBold
LockToolToggle.TextSize = 18
LockToolToggle.AutoButtonColor = true

local Tool = Instance.new("Tool")
Tool.RequiresHandle = false
Tool.Name = "Lock Tool"
Tool.Enabled = false
Tool.Parent = LocalPlayer.Backpack

LockToolToggle.MouseButton1Click:Connect(function()
if Tool.Enabled then
Tool.Enabled = false
LockToolToggle.Text = "Lock Tool OFF"
LockButton.Visible = true
else
Tool.Enabled = true
LockToolToggle.Text = "Lock Tool ON"
LockButton.Visible = false
Locking = false
CurrentTarget = nil
LockButton.Text = "🔒 LOCK"
end
end)

-- Logic for Tool Activation
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

local closest, shortest = nil, math.huge  
for _, player in ipairs(Players:GetPlayers()) do  
    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then  
        local head = player.Character:FindFirstChild("Head")  
        if head then  
            local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)  
            if onScreen then  
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude  
                if dist < shortest then  
                    closest = player  
                    shortest = dist  
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

-- ======= Combat Tab =======
local CombatFrame = contentPages["Combat"]

-- Prediction slider label
local PredictionLabel = Instance.new("TextLabel", CombatFrame)
PredictionLabel.Position = UDim2.new(0, 10, 0, 10)
PredictionLabel.Size = UDim2.new(1, -20, 0, 25)
PredictionLabel.Text = "Prediction: " .. string.format("%.3f", Prediction)
PredictionLabel.TextColor3 = Color3.new(1,1,1)
PredictionLabel.BackgroundTransparency = 1
PredictionLabel.Font = Enum.Font.Gotham
PredictionLabel.TextSize = 18

-- Prediction slider
local PredictionSlider = Instance.new("TextButton", CombatFrame)
PredictionSlider.Position = UDim2.new(0, 10, 0, 45)
PredictionSlider.Size = UDim2.new(1, -20, 0, 20)
PredictionSlider.BackgroundColor3 = Color3.fromRGB(40,40,40)
PredictionSlider.Text = ""
PredictionSlider.AutoButtonColor = false

local sliderFill = Instance.new("Frame", PredictionSlider)
sliderFill.Size = UDim2.new((Prediction / 0.2), 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(255,0,0)

-- Drag logic
local dragging = false
PredictionSlider.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
dragging = true
end
end)
PredictionSlider.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
dragging = false
end
end)
PredictionSlider.InputChanged:Connect(function(input)
if dragging and input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
local pos = math.clamp((input.Position.X - PredictionSlider.AbsolutePosition.X) / PredictionSlider.AbsoluteSize.X, 0, 1)
Prediction = pos * 0.2
sliderFill.Size = UDim2.new(pos, 0, 1, 0)
PredictionLabel.Text = "Prediction: " .. string.format("%.3f", Prediction)
end
end)

-- Auto Unlock toggle
local AutoUnlockToggle = Instance.new("TextButton", CombatFrame)
AutoUnlockToggle.Position = UDim2.new(0, 10, 0, 80)
AutoUnlockToggle.Size = UDim2.new(1, -20, 0, 40)
AutoUnlockToggle.Text = "Auto Unlock: OFF"
AutoUnlockToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
AutoUnlockToggle.TextColor3 = Color3.new(1,1,1)
AutoUnlockToggle.Font = Enum.Font.GothamBold
AutoUnlockToggle.TextSize = 18
AutoUnlockToggle.AutoButtonColor = true

AutoUnlockToggle.MouseButton1Click:Connect(function()
AutoUnlock = not AutoUnlock
if AutoUnlock then
AutoUnlockToggle.Text = "Auto Unlock: ON"
else
AutoUnlockToggle.Text = "Auto Unlock: OFF"
end
end)

-- Accuracy slider
local Accuracy = 100
local AccuracyLabel = Instance.new("TextLabel", CombatFrame)
AccuracyLabel.Position = UDim2.new(0, 10, 0, 130)
AccuracyLabel.Size = UDim2.new(1, -20, 0, 25)
AccuracyLabel.Text = "Accuracy: " .. tostring(Accuracy) .. "%"
AccuracyLabel.TextColor3 = Color3.new(1,1,1)
AccuracyLabel.BackgroundTransparency = 1
AccuracyLabel.Font = Enum.Font.Gotham
AccuracyLabel.TextSize = 18

local AccuracySlider = Instance.new("TextButton", CombatFrame)
AccuracySlider.Position = UDim2.new(0, 10, 0, 160)
AccuracySlider.Size = UDim2.new(1, -20, 0, 20)
AccuracySlider.BackgroundColor3 = Color3.fromRGB(40,40,40)
AccuracySlider.Text = ""
AccuracySlider.AutoButtonColor = false

local accuracyFill = Instance.new("Frame", AccuracySlider)
accuracyFill.Size = UDim2.new(Accuracy/100, 0, 1, 0)
accuracyFill.BackgroundColor3 = Color3.fromRGB(0, 200, 0)

local draggingAcc = false
AccuracySlider.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
draggingAcc = true
end
end)
AccuracySlider.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
draggingAcc = false
end
end)
AccuracySlider.InputChanged:Connect(function(input)
if draggingAcc and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
local pos = math.clamp((input.Position.X - AccuracySlider.AbsolutePosition.X) / AccuracySlider.AbsoluteSize.X, 0, 1)
Accuracy = math.floor(pos * 100)
accuracyFill.Size = UDim2.new(pos, 0, 1, 0)
AccuracyLabel.Text = "Accuracy: " .. tostring(Accuracy) .. "%"
end
end)

-- ======= Visuals Tab =======
local VisualsFrame = contentPages["Visuals"]

local ESPToggle = Instance.new("TextButton", VisualsFrame)
ESPToggle.Size = UDim2.new(1, -20, 0, 40)
ESPToggle.Position = UDim2.new(0, 10, 0, 10)
ESPToggle.Text = "ESP: OFF"
ESPToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ESPToggle.TextColor3 = Color3.new(1,1,1)
ESPToggle.Font = Enum.Font.GothamBold
ESPToggle.TextSize = 18
ESPToggle.AutoButtonColor = true

-- Visuals Tab FOV Toggle
local FOVEnabled = true

local FOVToggle = Instance.new("TextButton", VisualsFrame)
FOVToggle.Size = UDim2.new(1, -20, 0, 40)
FOVToggle.Position = UDim2.new(0, 10, 0, 60)
FOVToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FOVToggle.TextColor3 = Color3.new(1, 1, 1)
FOVToggle.Font = Enum.Font.GothamBold
FOVToggle.TextSize = 18
FOVToggle.AutoButtonColor = true
FOVToggle.Text = "Disable FOV Circle"  -- starts enabled

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

