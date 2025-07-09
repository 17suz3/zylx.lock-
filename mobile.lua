local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Workspace = workspace

local Prediction = 0.127047434437305158

local CurrentTarget = nil
local Locking = false

-- Helper functions
local function CreateButton(name, size, position, text, parent)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = size
    btn.Position = position
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Text = text
    btn.AutoButtonColor = true
    btn.Active = true
    btn.Draggable = false
    btn.Parent = parent
    return btn
end

local function CreateFrame(name, size, position, parent)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    return frame
end

local function CreateLabel(name, size, position, text, parent)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Text = text
    label.Parent = parent
    return label
end

local function CreateToggle(name, position, default, parent)
    local toggle = Instance.new("TextButton")
    toggle.Name = name
    toggle.Size = UDim2.new(0, 100, 0, 30)
    toggle.Position = position
    toggle.BackgroundColor3 = default and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(100, 100, 100)
    toggle.BorderSizePixel = 0
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 16
    toggle.Text = default and "ON" or "OFF"
    toggle.Parent = parent

    local enabled = default
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(100, 100, 100)
        toggle.Text = enabled and "ON" or "OFF"
    end)

    return toggle, function() return enabled end
end

-- Main GUI setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimlockGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- Tabs frame and buttons
local TabsFrame = CreateFrame("TabsFrame", UDim2.new(0, 270, 0, 350), UDim2.new(0.05, 0, 0.1, 0), ScreenGui)

local Tabs = {"Main", "Combat", "Visuals", "Settings"}
local TabButtons = {}
local TabContents = {}

for i, tabName in ipairs(Tabs) do
    local btn = CreateButton(tabName.."TabBtn", UDim2.new(0, 125, 0, 35), UDim2.new(0, (i-1)*130, 0, 0), tabName, TabsFrame)
    TabButtons[tabName] = btn

    local content = CreateFrame(tabName.."Content", UDim2.new(1, 0, 1, -40), UDim2.new(0, 0, 0, 40), TabsFrame)
    content.Visible = (i == 1)
    TabContents[tabName] = content

    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(TabContents) do v.Visible = false end
        content.Visible = true
    end)
end

-- Main Tab contents
local LockButton = CreateButton("LockButton", UDim2.new(0, 110, 0, 45), UDim2.new(0.1, 0, 0.8, 0), "🔒 LOCK", ScreenGui)
LockButton.Draggable = true

local function ToggleLock()
    if Locking then
        Locking = false
        CurrentTarget = nil
        LockButton.Text = "🔒 LOCK"
    else
        local closest = nil
        local shortest = math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    local screenPos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(head.Position)
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
    end
end

LockButton.MouseButton1Click:Connect(ToggleLock)

local LockTool = Instance.new("Tool")
LockTool.RequiresHandle = false
LockTool.Name = "Lock Tool"
LockTool.Parent = LocalPlayer.Backpack

LockTool.Activated:Connect(function()
    local target = Mouse.Target and Players:GetPlayerFromCharacter(Mouse.Target.Parent)
    if target and target ~= LocalPlayer then
        CurrentTarget = target
        Locking = true
        LockButton.Text = "🔓 UNLOCK"
    end
end)

-- Combat Tab contents
local AutoPredictionToggle, IsAutoPredictionOn = CreateToggle("AutoPredictionToggle", UDim2.new(0, 10, 0, 10), true, TabContents["Combat"])
CreateLabel("AutoPredictionLabel", UDim2.new(0, 120, 0, 10), UDim2.new(0, 120, 0, 10), "Auto Prediction", TabContents["Combat"])

-- Visuals Tab contents
local ESPToggle, IsESPOn = CreateToggle("ESPToggle", UDim2.new(0, 10, 0, 10), true, TabContents["Visuals"])
CreateLabel("ESPLabel", UDim2.new(0, 120, 0, 10), UDim2.new(0, 120, 0, 10), "ESP", TabContents["Visuals"])

local FOVToggle, IsFOVOn = CreateToggle("FOVToggle", UDim2.new(0, 10, 0, 50), false, TabContents["Visuals"])
CreateLabel("FOVLabel", UDim2.new(0, 120, 0, 50), UDim2.new(0, 120, 0, 50), "FOV Circle", TabContents["Visuals"])

local CrosshairToggle, IsCrosshairOn = CreateToggle("CrosshairToggle", UDim2.new(0, 10, 0, 90), true, TabContents["Visuals"])
CreateLabel("CrosshairLabel", UDim2.new(0, 120, 0, 90), UDim2.new(0, 120, 0, 90), "Crosshair", TabContents["Visuals"])

-- Draw ESP boxes and names
local ESPFolder = Instance.new("Folder", ScreenGui)
ESPFolder.Name = "ESPFolder"

local function CreateESPBox(player)
    local box = Instance.new("Frame")
    box.Name = player.Name.."_ESP"
    box.BackgroundTransparency = 0.5
    box.BorderColor3 = Color3.fromRGB(255, 0, 0)
    box.BorderMode = Enum.BorderMode.Outline
    box.Size = UDim2.new(0, 50, 0, 70)
    box.Visible = false
    box.Parent = ESPFolder

    local label = Instance.new("TextLabel")
    label.Name = "NameLabel"
    label.Size = UDim2.new(1, 0, 0, 18)
    label.Position = UDim2.new(0, 0, 0, -18)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Text = player.Name
    label.Parent = box

    return box
end

local ESPBoxes = {}

local function UpdateESP()
    if not IsESPOn() then
        for _, box in pairs(ESPBoxes) do
            box.Visible = false
        end
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(head.Position)
            if onScreen then
                local box = ESPBoxes[player.Name]
                if not box then
                    box = CreateESPBox(player)
                    ESPBoxes[player.Name] = box
                end
                box.Visible = true
                local sizeX = 50
                local sizeY = 70
                box.Size = UDim2.new(0, sizeX, 0, sizeY)
                box.Position = UDim2.new(0, screenPos.X - sizeX / 2, 0, screenPos.Y - sizeY / 2)
            else
                local box = ESPBoxes[player.Name]
                if box then
                    box.Visible = false
                end
            end
        else
            local box = ESPBoxes[player.Name]
            if box then
                box.Visible = false
            end
        end
    end
end

-- FOV Circle
local FOVCircle = Drawing and Drawing.new and Drawing.new("Circle")
if FOVCircle then
    FOVCircle.Radius = 90
    FOVCircle.Color = Color3.fromRGB(255, 0, 0)
    FOVCircle.Thickness = 2
    FOVCircle.NumSides = 64
    FOVCircle.Visible = false
else
    -- Fallback if Drawing API not available
    FOVCircle = nil
end

-- Crosshair
local CrosshairSize = 15
local CrosshairLines = {}

for i = 1,4 do
    local line = Drawing and Drawing.new and Drawing.new("Line")
    if line then
        line.Color = Color3.fromRGB(255,255,255)
        line.Thickness = 2
        line.Transparency = 1
        line.Visible = false
        table.insert(CrosshairLines, line)
    end
end

local function UpdateCrosshair()
    if not IsCrosshairOn() then
        for _, line in pairs(CrosshairLines) do
            if line then line.Visible = false end
        end
        return
    end
    local centerX = workspace.CurrentCamera.ViewportSize.X / 2
    local centerY = workspace.CurrentCamera.ViewportSize.Y / 2
    local size = CrosshairSize

    if #CrosshairLines == 4 then
        CrosshairLines[1].From = Vector2.new(centerX - size, centerY)
        CrosshairLines[1].To = Vector2.new(centerX - 3, centerY)
        CrosshairLines[2].From = Vector2.new(centerX + size, centerY)
        CrosshairLines[2].To = Vector2.new(centerX + 3, centerY)
        CrosshairLines[3].From = Vector2.new(centerX, centerY - size)
        CrosshairLines[3].To = Vector2.new(centerX, centerY - 3)
        CrosshairLines[4].From = Vector2.new(centerX, centerY + size)
        CrosshairLines[4].To = Vector2.new(centerX, centerY + 3)
        for _, line in pairs(CrosshairLines) do
            line.Visible = true
        end
    end
end

-- Main loop
RunService.RenderStepped:Connect(function()
    if Locking and CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Head") then
        local head = CurrentTarget.Character.Head
        local pred = Prediction
        if IsAutoPredictionOn() then
            pred = pred + 0.005 -- Example adjustment for auto prediction
        end
        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, head.Position + Vector3.new(0, pred, 0))
    end
    UpdateESP()
    if FOVCircle then
        FOVCircle.Visible = IsFOVOn()
        local centerX = workspace.CurrentCamera.ViewportSize.X / 2
        local centerY = workspace.CurrentCamera.ViewportSize.Y / 2
        FOVCircle.Position = Vector2.new(centerX, centerY)
    end
    UpdateCrosshair()
end)

-- Double tap lock button to unlock
local lastTap = 0
LockButton.MouseButton1Click:Connect(function()
    if tick() - lastTap < 0.4 then
        Locking = false
        CurrentTarget = nil
        LockButton.Text = "🔒 LOCK"
    end
    lastTap = tick()
end)
