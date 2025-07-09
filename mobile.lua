local Players = game:GetService("Players") local RunService = game:GetService("RunService") local UserInputService = game:GetService("UserInputService") local LocalPlayer = Players.LocalPlayer local Mouse = LocalPlayer:GetMouse()

local Prediction = 0.127047434437305158 local CurrentTarget = nil local Locking = false

local ScreenGui = Instance.new("ScreenGui", game.CoreGui) ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame") MainFrame.Size = UDim2.new(0, 200, 0, 250) MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0) MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25) MainFrame.BorderSizePixel = 0 MainFrame.Active = true MainFrame.Draggable = true MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel") Title.Size = UDim2.new(1, 0, 0, 30) Title.BackgroundTransparency = 1 Title.Text = "zylx Lock GUI" Title.TextColor3 = Color3.new(1, 1, 1) Title.Font = Enum.Font.SourceSansBold Title.TextSize = 20 Title.Parent = MainFrame

local LockButtonOption = Instance.new("TextButton") LockButtonOption.Size = UDim2.new(1, -20, 0, 40) LockButtonOption.Position = UDim2.new(0, 10, 0, 40) LockButtonOption.Text = "Enable Lock Button" LockButtonOption.BackgroundColor3 = Color3.fromRGB(40, 40, 40) LockButtonOption.TextColor3 = Color3.new(1, 1, 1) LockButtonOption.Parent = MainFrame

local LockToolOption = Instance.new("TextButton") LockToolOption.Size = UDim2.new(1, -20, 0, 40) LockToolOption.Position = UDim2.new(0, 10, 0, 90) LockToolOption.Text = "Enable Lock Tool" LockToolOption.BackgroundColor3 = Color3.fromRGB(40, 40, 40) LockToolOption.TextColor3 = Color3.new(1, 1, 1) LockToolOption.Parent = MainFrame

local LockButton = Instance.new("TextButton") LockButton.Size = UDim2.new(0, 100, 0, 40) LockButton.Position = UDim2.new(0.05, 0, 0.4, 0) LockButton.Text = "🔒 LOCK" LockButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30) LockButton.TextColor3 = Color3.new(1, 1, 1) LockButton.BorderSizePixel = 2 LockButton.Visible = false LockButton.Parent = ScreenGui LockButton.Active = true LockButton.Draggable = true LockButton.AutoButtonColor = true

local Tool = Instance.new("Tool") Tool.RequiresHandle = false Tool.Name = "Lock Tool" Tool.Enabled = false Tool.Parent = LocalPlayer.Backpack

Tool.Activated:Connect(function() local target = Mouse.Target and Players:GetPlayerFromCharacter(Mouse.Target.Parent) if target and target ~= LocalPlayer then CurrentTarget = target Locking = true LockButton.Text = "🔓 UNLOCK" end end)

LockButton.MouseButton1Click:Connect(function() if Locking then Locking = false CurrentTarget = nil LockButton.Text = "🔒 LOCK" return end

local closest, shortest = nil, math.huge
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

RunService.RenderStepped:Connect(function() if Locking and CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Head") then local head = CurrentTarget.Character.Head workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, head.Position + Vector3.new(0, Prediction, 0)) end end)

UserInputService.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch then if tick() - (LockButton.lastTap or 0) < 0.4 then Locking = false CurrentTarget = nil LockButton.Text = "🔒 LOCK" end LockButton.lastTap = tick() end end)

LockButtonOption.MouseButton1Click:Connect(function() LockButton.Visible = true Tool.Enabled = false end)

LockToolOption.MouseButton1Click:Connect(function() Tool.Enabled = true LockButton.Visible = false end)

