-- ZylxElite GUI (Inspired by Psalms.Tech) -- Designed for both Mobile (Delta) and PC -- Made to feel like a $100 Paid Script - But it's Free 🔥

local Players = game:GetService("Players") local UserInputService = game:GetService("UserInputService") local RunService = game:GetService("RunService") local LocalPlayer = Players.LocalPlayer

-- Gui Library Placeholder (you can plug in your own) local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/SomeLibrary/GuiLib/main/source.lua"))() local Window = Library:CreateWindow({ Name = "ZylxElite", IntroText = "ZylxElite - Free Elite Lock GUI", SaveConfig = true })

-- UI Toggle Button (floating on screen) local guiToggle = Instance.new("TextButton") guiToggle.Size = UDim2.new(0, 30, 0, 30) guiToggle.Position = UDim2.new(0, 10, 0.5, -15) guiToggle.Text = "≡" guiToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0) guiToggle.TextColor3 = Color3.fromRGB(255, 255, 255) guiToggle.BorderSizePixel = 0 guiToggle.Parent = game:GetService("CoreGui")

local visible = true guiToggle.MouseButton1Click:Connect(function() visible = not visible Library:ToggleUI(visible) end)

-- Main Tab local main = Window:CreateTab("Main") main:AddToggle("Enable Lock", false) main:AddSlider("Prediction Value", {min = 0, max = 0.3, value = 0.127}) main:AddToggle("Auto Prediction", true) main:AddDropdown("Aim Part", {"Head", "UpperTorso", "HumanoidRootPart"}) main:AddToggle("Show FOV", true) main:AddSlider("FOV Size", {min = 20, max = 200, value = 90}) main:AddDropdown("Hit Sound", {"Sans", "Pop", "Bell", "Bruh"}) main:AddToggle("Smart Switcher", true)

-- Combat Tab local combat = Window:CreateTab("Combat") combat:AddSlider("Camlock Smoothness", {min = 0, max = 2, value = 1}) combat:AddToggle("Enable CFrame", false) combat:AddToggle("Auto Stomp", false) combat:AddToggle("Auto Air", true) combat:AddToggle("Anti Ground Shot", true) combat:AddToggle("Rapid Fire", false) combat:AddSlider("Jump Prediction", {min = -1, max = 1, value = 0})

-- Controls Tab local controls = Window:CreateTab("Controls") controls:AddDropdown("Lock Mode", {"Tool", "Button", "Controller"}) controls:AddKeybind("Controller Key", Enum.KeyCode.Q) controls:AddButton("Adjust Mobile Button Position") controls:AddSlider("Touch Sensitivity", {min = 0.1, max = 2, value = 1})

-- Visuals Tab local visuals = Window:CreateTab("Visuals") visuals:AddToggle("ESP", false) visuals:AddDropdown("ESP Style", {"Light", "Tactical", "Advanced"}) visuals:AddDropdown("Crosshair Style", {"Dot", "X", "Cat"}) visuals:AddColorpicker("Crosshair Color", Color3.fromRGB(255, 0, 0)) visuals:AddColorpicker("FOV Color", Color3.fromRGB(111, 111, 111)) visuals:AddSlider("FOV Thickness", {min = 1, max = 5, value = 1}) visuals:AddSlider("FOV Transparency", {min = 0, max = 1, value = 1})

-- Misc Tab local misc = Window:CreateTab("Misc") misc:AddButton("Macro Speed Toggle") misc:AddToggle("FPS Optimizer", true) misc:AddToggle("Auto Memory Cleaner", true) misc:AddToggle("Notifications", true) misc:AddButton("Clear Scripts") misc:AddToggle("Ping Optimizer", true) misc:AddToggle("AntiBan", true) misc:AddToggle("Safe Mode", true)

-- GUI Ready print("ZylxElite GUI Loaded Successfully")

 
