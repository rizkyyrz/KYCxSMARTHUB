local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local MainWin = Library.CreateLib("SMART PLAYER MENU", "DarkTheme")

local PlayerTab = MainWin:NewTab("Player")
local PlayerSec = PlayerTab:NewSection("Movement")

_G.Fly = false
_G.FlySpeed = 60

local flyConnection
local flyBV

local function StopFly()
    _G.Fly = false

    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")

        if hum then
            hum.PlatformStand = false
        end

        if hrp then
            local old = hrp:FindFirstChild("FlyVelocity")
            if old then
                old:Destroy()
            end
        end
    end

    flyBV = nil
end

local function StartFly()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")

    local old = hrp:FindFirstChild("FlyVelocity")
    if old then
        old:Destroy()
    end

    flyBV = Instance.new("BodyVelocity")
    flyBV.Name = "FlyVelocity"
    flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBV.Velocity = Vector3.new(0, 0, 0)
    flyBV.Parent = hrp

    _G.Fly = true

    flyConnection = RunService.RenderStepped:Connect(function()
        if not _G.Fly or not hrp.Parent then
            StopFly()
            return
        end

        hum.PlatformStand = true

        local cam = workspace.CurrentCamera
        local move = Vector3.new(0, 0, 0)

        if UIS:IsKeyDown(Enum.KeyCode.W) then
            move = move + cam.CFrame.LookVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.S) then
            move = move - cam.CFrame.LookVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.A) then
            move = move - cam.CFrame.RightVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.D) then
            move = move + cam.CFrame.RightVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            move = move + Vector3.new(0, 1, 0)
        end

        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            move = move - Vector3.new(0, 1, 0)
        end

        if move.Magnitude > 0 then
            flyBV.Velocity = move.Unit * _G.FlySpeed
        else
            flyBV.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

PlayerSec:NewToggle("Fly", "Character Fly", function(state)
    if state then
        StartFly()
    else
        StopFly()
    end
end)

PlayerSec:NewSlider("Fly Speed", "Atur kecepatan terbang", 200, 20, function(value)
    _G.FlySpeed = value
end)

player.CharacterAdded:Connect(function()
    StopFly()
end)
