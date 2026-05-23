local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

repeat task.wait() until player:FindFirstChild("PlayerGui")

local FlySpeed = 60
local Flying = false
local FlyConnection
local BV
local BG
local DefaultGravity = workspace.Gravity

local oldGui = player.PlayerGui:FindFirstChild("MiniFlyGui")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MiniFlyGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = obj
end

local Icon = Instance.new("TextButton")
Icon.Size = UDim2.new(0, 45, 0, 45)
Icon.Position = UDim2.new(0, 15, 0.5, -25)
Icon.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Icon.Text = "✈"
Icon.TextColor3 = Color3.fromRGB(255, 255, 255)
Icon.TextSize = 24
Icon.Font = Enum.Font.GothamBold
Icon.Parent = ScreenGui
Icon.Active = true
Icon.Draggable = true
corner(Icon, 50)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 180, 0, 305)
Main.Position = UDim2.new(0, 70, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Main.Visible = false
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
corner(Main, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -45, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Mini Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 25, 0, 25)
Close.Position = UDim2.new(1, -30, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.TextSize = 13
Close.Font = Enum.Font.GothamBold
Close.Parent = Main
corner(Close, 8)

local function makeButton(text, y, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.Parent = Main
    corner(btn, 10)
    return btn
end

local function makeBox(placeholder, y)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -20, 0, 35)
    box.Position = UDim2.new(0, 10, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
    box.TextSize = 14
    box.Font = Enum.Font.Gotham
    box.Parent = Main
    corner(box, 10)
    return box
end

local Toggle = makeButton("Fly : OFF", 45, Color3.fromRGB(60, 60, 75))
Toggle.Size = UDim2.new(1, -20, 0, 40)

local SpeedBox = makeBox("Speed: 60", 95)
local TPBox = makeBox("Teleport Username", 135)
local TPButton = makeButton("Teleport", 175, Color3.fromRGB(70, 90, 180))
local MorphBox = makeBox("Morph Name", 215)
local MorphButton = makeButton("Morph Monster", 255, Color3.fromRGB(140, 70, 180))

local function StopFly()
    Flying = false
    Toggle.Text = "Fly : OFF"
    Toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    workspace.Gravity = DefaultGravity

    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end

    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")

        if hum then
            hum.PlatformStand = false
            hum.AutoRotate = true
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end

        if hrp then
            local oldBV = hrp:FindFirstChild("FlightVelocity")
            local oldBG = hrp:FindFirstChild("ToolGyro")
            if oldBV then oldBV:Destroy() end
            if oldBG then oldBG:Destroy() end
        end
    end

    BV = nil
    BG = nil
end

local function StartFly()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    if not hum then return end

    local oldBV = hrp:FindFirstChild("FlightVelocity")
    local oldBG = hrp:FindFirstChild("ToolGyro")
    if oldBV then oldBV:Destroy() end
    if oldBG then oldBG:Destroy() end

    BV = Instance.new("BodyVelocity")
    BV.Name = "FlightVelocity"
    BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    BV.Velocity = Vector3.zero
    BV.Parent = hrp

    BG = Instance.new("BodyGyro")
    BG.Name = "ToolGyro"
    BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    BG.P = 5000
    BG.D = 100
    BG.CFrame = hrp.CFrame
    BG.Parent = hrp

    Flying = true
    Toggle.Text = "Fly : ON"
    Toggle.BackgroundColor3 = Color3.fromRGB(60, 160, 90)
    workspace.Gravity = 50

    FlyConnection = RunService.RenderStepped:Connect(function()
        if not Flying or not hrp.Parent then
            StopFly()
            return
        end

        local cam = workspace.CurrentCamera
        local move = Vector3.zero

        hum.PlatformStand = false
        hum.AutoRotate = false

        if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0, 1, 0) end

        if move.Magnitude > 0 then
            move = move.Unit
            BV.Velocity = BV.Velocity:Lerp(move * FlySpeed, 0.18)

            local flatMove = Vector3.new(move.X, 0, move.Z)
            if flatMove.Magnitude > 0 then
                BG.CFrame = BG.CFrame:Lerp(
                    CFrame.lookAt(hrp.Position, hrp.Position + flatMove),
                    0.2
                )
            end
        else
            BV.Velocity = BV.Velocity:Lerp(Vector3.zero, 0.12)
            BG.CFrame = BG.CFrame:Lerp(
                CFrame.lookAt(hrp.Position, hrp.Position + cam.CFrame.LookVector),
                0.15
            )
        end
    end)
end

Toggle.MouseButton1Click:Connect(function()
    if Flying then
        StopFly()
    else
        StartFly()
    end
end)

SpeedBox.FocusLost:Connect(function()
    local value = tonumber(SpeedBox.Text)

    if value then
        FlySpeed = value
        SpeedBox.Text = ""
        SpeedBox.PlaceholderText = "Speed: " .. tostring(FlySpeed)
    else
        SpeedBox.Text = ""
        SpeedBox.PlaceholderText = "Speed harus angka"
    end
end)

TPButton.MouseButton1Click:Connect(function()
    local targetName = TPBox.Text

    if targetName == "" then
        TPBox.PlaceholderText = "Masukkan username"
        return
    end

    local targetPlayer = game.Players:FindFirstChild(targetName)

    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myChar = player.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local targetHRP = targetPlayer.Character.HumanoidRootPart

        if myHRP then
            myHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
            TPBox.Text = ""
            TPBox.PlaceholderText = "Berhasil teleport"
        end
    else
        TPBox.Text = ""
        TPBox.PlaceholderText = "Player tidak ditemukan"
    end
end)

MorphButton.MouseButton1Click:Connect(function()
    local morphName = MorphBox.Text

    if morphName == "" then
        MorphBox.PlaceholderText = "Masukkan morph"
        return
    end

    MorphBox.Text = ""
    MorphBox.PlaceholderText = "Loading morph..."

    task.spawn(function()
        local success, err = pcall(function()
            local mod = require(88521859208314)
            mod.MorphMonster(player.Name, morphName)
        end)

        if success then
            MorphBox.PlaceholderText = "Morph success"
        else
            MorphBox.PlaceholderText = "Morph failed"
            warn(err)
        end
    end)
end)

Icon.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

Close.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    StopFly()
end)
