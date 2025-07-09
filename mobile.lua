local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Prediction = 0.127047434437305158
local CurrentTarget = nil
local Locking = false

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.ResetOnSpawn = false

local LockButton = Instance.new("TextButton")
LockButton.Size = UDim2.new(0, 100, 0, 40)
LockButton.Position = UDim2.new(0.05, 0, 0.4, 0)
LockButton.Text = "🔒 LOCK"
LockButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
LockButton.TextColor3 = Color3.new(1,1,1)
LockButton.BorderSizePixel = 2
LockButton.Parent = ScreenGui
LockButton.Active = true
LockButton.Draggable = true
LockButton.AutoButtonColor = true

local Tool = Instance.new("Tool")
Tool.RequiresHandle = false
Tool.Name = "Lock Tool"
Tool.Parent = LocalPlayer.Backpack

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
end)

RunService.RenderStepped:Connect(function()
    if Locking and CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Head") then
        local head = CurrentTarget.Character.Head
        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, head.Position + Vector3.new(0, Prediction, 0))
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        if tick() - (LockButton.lastTap or 0) < 0.4 then
            Locking = false
            CurrentTarget = nil
            LockButton.Text = "🔒 LOCK"
        end
        LockButton.lastTap = tick()
    end
end)
