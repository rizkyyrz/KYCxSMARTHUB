-- ============================================
-- ROBLOX HUB LOADER TANPA KEY SYSTEM
-- ============================================

local Config = {
    HubName = "Plato Hub V2",
    HubDescription = "Best Roblox Script Hub",

    MainGuiName = "MainGui",
    LoaderGuiName = "PlatoHubLoader",
    OldGuiName = "OldGui",
    LoadedFlag = "Plato_Loaded",

    MainScriptURL = "https://pastebin.com/raw/xxxxxxxx",

    ShowDiscord = true,
    ShowInstagram = true,
    ShowYoutube = true,

    DiscordURL = "https://discord.gg/xxxxxx",
    InstagramURL = "https://instagram.com/xxxxxx",
    YoutubeURL = "https://youtube.com/xxxxxx",

    DiscordIcon = "rbxassetid://123456789",
    InstagramIcon = "rbxassetid://987654321",
    YoutubeIcon = "rbxassetid://123456789"
}

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================
-- FUNGSI UTILITY
-- ============================================

local function safeSetClipboard(text)
    if typeof(setclipboard) == "function" then
        local success = pcall(setclipboard, text)
        return success
    end

    return false
end

local function loadMainScript()
    if _G[Config.LoadedFlag] then
        return false, "Hub sudah dimuat."
    end

    if playerGui:FindFirstChild(Config.OldGuiName) then
        playerGui[Config.OldGuiName]:Destroy()
        task.wait(0.1)
    end

    local success, result = pcall(function()
        local source = game:HttpGet(Config.MainScriptURL)

        local compiled, compileError = loadstring(source)
        if not compiled then
            error("Gagal compile script: " .. tostring(compileError))
        end

        _G[Config.LoadedFlag] = true
        compiled()
    end)

    if not success then
        _G[Config.LoadedFlag] = nil
        return false, tostring(result)
    end

    return true, "Hub berhasil dimuat."
end

-- ============================================
-- MEMBUAT GUI
-- ============================================

local function createGUI()
    local existingGui = playerGui:FindFirstChild(Config.LoaderGuiName)
    if existingGui then
        existingGui:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = Config.LoaderGuiName
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 340, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -170, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = mainFrame

    local border = Instance.new("UIStroke")
    border.Thickness = 2
    border.Color = Color3.fromRGB(40, 40, 40)
    border.Parent = mainFrame

    local header = Instance.new("TextLabel")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    header.Text = Config.HubName
    header.TextColor3 = Color3.fromRGB(0, 170, 255)
    header.Font = Enum.Font.GothamBold
    header.TextSize = 20
    header.Parent = mainFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 15)
    headerCorner.Parent = header

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -38, 0, 10)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 18
    closeButton.ZIndex = 3
    closeButton.Parent = mainFrame

    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    local description = Instance.new("TextLabel")
    description.Name = "Description"
    description.Size = UDim2.new(0.9, 0, 0, 40)
    description.Position = UDim2.new(0.05, 0, 0, 55)
    description.BackgroundTransparency = 1
    description.Text = Config.HubDescription
    description.TextColor3 = Color3.fromRGB(0, 170, 255)
    description.Font = Enum.Font.GothamBold
    description.TextSize = 14
    description.TextWrapped = true
    description.Parent = mainFrame

    local yOffset = 100

    local function createSocialButton(text, color, imageUrl, url)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.85, 0, 0, 35)
        button.Position = UDim2.new(0.075, 0, 0, yOffset)
        button.BackgroundColor3 = color
        button.Text = text
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 14
        button.Parent = mainFrame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = button

        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 20, 0, 20)
        icon.Position = UDim2.new(0.08, 0, 0.5, -10)
        icon.BackgroundTransparency = 1
        icon.Image = imageUrl
        icon.Parent = button

        button.MouseButton1Click:Connect(function()
            if safeSetClipboard(url) then
                button.Text = "Copied!"
            else
                button.Text = "Clipboard tidak tersedia"
            end

            task.delay(1.5, function()
                if button.Parent then
                    button.Text = text
                end
            end)
        end)

        yOffset += 45
    end

    if Config.ShowDiscord then
        createSocialButton(
            "Copy Discord",
            Color3.fromRGB(88, 101, 242),
            Config.DiscordIcon,
            Config.DiscordURL
        )
    end

    if Config.ShowInstagram then
        createSocialButton(
            "Copy Instagram",
            Color3.fromRGB(225, 48, 108),
            Config.InstagramIcon,
            Config.InstagramURL
        )
    end

    if Config.ShowYoutube then
        createSocialButton(
            "Copy YouTube",
            Color3.fromRGB(255, 0, 0),
            Config.YoutubeIcon,
            Config.YoutubeURL
        )
    end

    local loadButton = Instance.new("TextButton")
    loadButton.Name = "LoadButton"
    loadButton.Size = UDim2.new(0.85, 0, 0, 42)
    loadButton.Position = UDim2.new(0.075, 0, 0, yOffset + 5)
    loadButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    loadButton.Text = "Load Hub"
    loadButton.TextColor3 = Color3.new(1, 1, 1)
    loadButton.Font = Enum.Font.GothamBold
    loadButton.TextSize = 15
    loadButton.Parent = mainFrame

    local loadCorner = Instance.new("UICorner")
    loadCorner.CornerRadius = UDim.new(0, 8)
    loadCorner.Parent = loadButton

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(0.9, 0, 0, 35)
    statusLabel.Position = UDim2.new(0.05, 0, 0, yOffset + 52)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Tekan Load Hub untuk menjalankan script"
    statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.TextWrapped = true
    statusLabel.Parent = mainFrame

    mainFrame.Size = UDim2.new(0, 340, 0, yOffset + 100)
    mainFrame.Position = UDim2.new(0.5, -170, 0.5, -(yOffset + 100) / 2)

    local loading = false

    loadButton.MouseButton1Click:Connect(function()
        if loading then
            return
        end

        loading = true
        loadButton.AutoButtonColor = false
        loadButton.Text = "Loading..."
        statusLabel.Text = "Mengambil dan menjalankan script..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 70)

        local success, message = loadMainScript()

        if success then
            statusLabel.Text = message
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
            loadButton.Text = "Loaded"

            task.wait(0.5)

            if screenGui.Parent then
                screenGui:Destroy()
            end
        else
            statusLabel.Text = "Error: " .. message
            statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            loadButton.Text = "Coba Lagi"
            loadButton.AutoButtonColor = true
            loading = false
        end
    end)
end

-- ============================================
-- EKSEKUSI UTAMA
-- ============================================

if playerGui:FindFirstChild(Config.MainGuiName) or _G[Config.LoadedFlag] then
    warn(Config.HubName .. " sudah dimuat.")
else
    createGUI()
end
