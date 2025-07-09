local zxly = {
    Prediction = 0.127,
    Camlock = {
        Enabled = true,
        UseClosestPart = true,
        TargetBodyParts = { "Head", "UpperTorso" },
        Prediction = 0.127,
        AirPrediction = 0.127,
        Smoothness = 0.1,
        AirSmoothness = 1,
        Mode = "Button",
        AutoUnlock = true
    },
    TargetAim = {
        Enabled = true,
        Prediction = 0.127,
        AirPrediction = 0.127,
        Accuracy = 100,
        UseNearestPart = true,
        AimAtMultipleParts = false,
        Parts = { "Head", "UpperTorso" }
    },
    SmartSystem = {
        AutoSwitchPart = true,
        DynamicPrediction = true,
        AntiLockDetection = true
    },
    BulletTeleport = {
        Enabled = true
    },
    SpeedButton = {
        Enabled = true,
        ResetAfter = 10
    },
    GUI = {
        Tabs = { "Main", "Combat", "Visuals", "Exploits", "Misc" },
        LockButton = true
    },
    System = {
        AutoFPSManager = true,
        MemoryCleaner = true
    },
    Visuals = {
        FOV = {
            Visible = true,
            Size = 90,
            Color = Color3.fromRGB(255, 0, 0)
        },
        HitEffect = {
            Enabled = true,
            Duration = 1,
            Color = Color3.fromRGB(255, 0, 0)
        },
        Trace = true
    },
    AntiBan = {
        Enabled = true,
        Silent = true,
        UpdateCheck = true
    }
}

local function AimlockScript()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Mouse = LocalPlayer:GetMouse()

    local function GetClosestTarget()
        local closestPlayer = nil
        local shortestDistance = math.huge
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    local screenPos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(head.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
        return closestPlayer
    end

    Mouse.Button1Down:Connect(function()
        if zxly.TargetAim.Enabled then
            local target = GetClosestTarget()
            if target and target.Character then
                local head = target.Character:FindFirstChild("Head")
                if head then
                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, head.Position + Vector3.new(0, zxly.Prediction, 0))
                end
            end
        end
    end)
end

spawn(AimlockScript)
