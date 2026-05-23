local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

repeat task.wait() until player:FindFirstChild("PlayerGui")

local FlySpeed = 60
local Flying = false
local FlyConnection
local BV
local BG

local oldGui = player.PlayerGui:FindFirstChild("MiniFlyGui")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MiniFlyGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = player:WaitForChild("PlayerGui")

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
Icon.ZIndex = 999
Instance.new("UICorner", Icon).CornerRadius = UDim.new(1, 0)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 180, 0, 305)
Main.Position = UDim2.new(0, 70, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Main.Visible = false
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Main.ZIndex = 999
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -35, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "MiniHub by RZKY"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main
Title.ZIndex = 1000

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 25, 0, 25)
Close.Position = UDim2.new(1, -30, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.TextSize = 13
Close.Font = Enum.Font.GothamBold
Close.Parent = Main
Close.ZIndex = 1000
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(1, -20, 0, 40)
Toggle.Position = UDim2.new(0, 10, 0, 45)
Toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
Toggle.Text = "Fly : OFF"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.TextSize = 15
Toggle.Font = Enum.Font.GothamBold
Toggle.Parent = Main
Toggle.ZIndex = 1000
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 10)

local SpeedBox = Instance.new("TextBox")
SpeedBox.Size = UDim2.new(1, -20, 0, 35)
SpeedBox.Position = UDim2.new(0, 10, 0, 95)
SpeedBox.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
SpeedBox.PlaceholderText = "Speed: 60"
SpeedBox.Text = ""
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
SpeedBox.TextSize = 14
SpeedBox.Font = Enum.Font.Gotham
SpeedBox.Parent = Main
SpeedBox.ZIndex = 1000
Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 10)

local TPBox = Instance.new("TextBox")
TPBox.Size = UDim2.new(1, -20, 0, 35)
TPBox.Position = UDim2.new(0, 10, 0, 135)
TPBox.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
TPBox.PlaceholderText = "Teleport Username"
TPBox.Text = ""
TPBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TPBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
TPBox.TextSize = 14
TPBox.Font = Enum.Font.Gotham
TPBox.Parent = Main
TPBox.ZIndex = 1000
Instance.new("UICorner", TPBox).CornerRadius = UDim.new(0, 10)

local TPButton = Instance.new("TextButton")
TPButton.Size = UDim2.new(1, -20, 0, 35)
TPButton.Position = UDim2.new(0, 10, 0, 175)
TPButton.BackgroundColor3 = Color3.fromRGB(70, 90, 180)
TPButton.Text = "Teleport"
TPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TPButton.TextSize = 14
TPButton.Font = Enum.Font.GothamBold
TPButton.Parent = Main
TPButton.ZIndex = 1000
Instance.new("UICorner", TPButton).CornerRadius = UDim.new(0, 10)

local SizeBox = Instance.new("TextBox")
SizeBox.Size = UDim2.new(1, -20, 0, 35)
SizeBox.Position = UDim2.new(0, 10, 0, 215)
SizeBox.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
SizeBox.PlaceholderText = "Body Size: 1 - 5"
SizeBox.Text = ""
SizeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SizeBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
SizeBox.TextSize = 14
SizeBox.Font = Enum.Font.Gotham
SizeBox.Parent = Main
SizeBox.ZIndex = 1000
Instance.new("UICorner", SizeBox).CornerRadius = UDim.new(0, 10)

local SizeButton = Instance.new("TextButton")
SizeButton.Size = UDim2.new(1, -20, 0, 35)
SizeButton.Position = UDim2.new(0, 10, 0, 255)
SizeButton.BackgroundColor3 = Color3.fromRGB(120, 80, 180)
SizeButton.Text = "Apply Body Size"
SizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SizeButton.TextSize = 14
SizeButton.Font = Enum.Font.GothamBold
SizeButton.Parent = Main
SizeButton.ZIndex = 1000
Instance.new("UICorner", SizeButton).CornerRadius = UDim.new(0, 10)

local function StopFly()
    Flying = false
    Toggle.Text = "Fly : OFF"
    Toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 75)

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
            local oldBV = hrp:FindFirstChild("FlyVelocity")
            local oldBG = hrp:FindFirstChild("FlyGyro")

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

    local oldBV = hrp:FindFirstChild("FlyVelocity")
    local oldBG = hrp:FindFirstChild("FlyGyro")

    if oldBV then oldBV:Destroy() end
    if oldBG then oldBG:Destroy() end

    BV = Instance.new("BodyVelocity")
    BV.Name = "FlyVelocity"
    BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    BV.Velocity = Vector3.new(0, 0, 0)
    BV.Parent = hrp

    BG = Instance.new("BodyGyro")
    BG.Name = "FlyGyro"
    BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    BG.P = 9000
    BG.CFrame = hrp.CFrame
    BG.Parent = hrp

    Flying = true
    Toggle.Text = "Fly : ON"
    Toggle.BackgroundColor3 = Color3.fromRGB(60, 160, 90)

    FlyConnection = RunService.RenderStepped:Connect(function()
        if not Flying or not hrp.Parent then
            StopFly()
            return
        end

        local cam = workspace.CurrentCamera
        local move = Vector3.new(0, 0, 0)

        hum.PlatformStand = false
        hum.AutoRotate = false
        hum:ChangeState(Enum.HumanoidStateType.Freefall)

        local forward = cam.CFrame.LookVector
        local right = cam.CFrame.RightVector

        if UIS:IsKeyDown(Enum.KeyCode.W) then
            move = move + forward
        end

        if UIS:IsKeyDown(Enum.KeyCode.S) then
            move = move - forward
        end

        if UIS:IsKeyDown(Enum.KeyCode.A) then
            move = move - right
        end

        if UIS:IsKeyDown(Enum.KeyCode.D) then
            move = move + right
        end

        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            move = move + Vector3.new(0, 1, 0)
        end

        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            move = move - Vector3.new(0, 1, 0)
        end

        if move.Magnitude > 0 then
            BV.Velocity = move.Unit * FlySpeed
            BG.CFrame = CFrame.new(
                hrp.Position,
                hrp.Position + Vector3.new(move.X, move.Y * 0.35, move.Z)
            )
        else
            BV.Velocity = Vector3.new(0, 0, 0)
            BG.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
        end
    end)
end

local function SetBodySize(scale)
    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local scaleNames = {
        "BodyHeightScale",
        "BodyWidthScale",
        "BodyDepthScale",
        "HeadScale"
    }

    for _, scaleName in ipairs(scaleNames) do
        local scaleValue = hum:FindFirstChild(scaleName)

        if scaleValue then
            scaleValue.Value = scale
        end
    end
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
        SpeedBox.PlaceholderText = "Speed: " .. tostring(FlySpeed)
        SpeedBox.Text = ""
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

    if targetPlayer
    and targetPlayer.Character
    and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then

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

SizeButton.MouseButton1Click:Connect(function()
    local value = tonumber(SizeBox.Text)

    if value then
        value = math.clamp(value, 0.5, 5)
        SetBodySize(value)

        SizeBox.Text = ""
        SizeBox.PlaceholderText = "Body Size: " .. tostring(value)
    else
        SizeBox.Text = ""
        SizeBox.PlaceholderText = "Masukkan angka"
    end
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
