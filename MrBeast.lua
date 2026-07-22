--[[
    Wonder Hub - Escape from Mr. Island Beast
    Hasil deobfuscation dan perapian.
    (Versi tanpa validasi flag otorisasi)
]]

-- =========================================================
-- UI LIBRARY
-- =========================================================

local Fluent = loadstring(game:HttpGet(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
))()

local Window = Fluent:CreateWindow({
    Title = "Escape from Mr. Island Beast",
    SubTitle = "WONDER",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "White",
    MinimizeKey = Enum.KeyCode.LeftAlt
})

local Tabs = {
    Farm = Window:AddTab({
        Title = "Farm",
        Icon = "axe"
    }),

    Combat = Window:AddTab({
        Title = "Combat",
        Icon = "sword"
    }),

    Quests = Window:AddTab({
        Title = "Quests",
        Icon = "clipboard"
    }),

    Chests = Window:AddTab({
        Title = "Chests",
        Icon = "package"
    }),

    ESP = Window:AddTab({
        Title = "Esp",
        Icon = "eye"
    }),

    Settings = Window:AddTab({
        Title = "Settings",
        Icon = "settings"
    })
}

-- =========================================================
-- GAME REMOTES
-- =========================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local MeleeHitRemote = ReplicatedStorage
    :WaitForChild("Events")
    :WaitForChild("meleeHitRemote")

local CollectRemote = ReplicatedStorage
    :WaitForChild("Engine")
    :WaitForChild("Service")
    :WaitForChild("ItemCollect")
    :WaitForChild("collectRemote")

-- =========================================================
-- ITEM FILTERS
-- =========================================================

local ItemNames = {
    Wood = {
        "Log",
        "Wood",
        "Madeira",
        "Trunk"
    },

    Coconut = {
        "Coconut",
        "Coco"
    },

    Egg = {
        "Egg",
        "Ovo"
    },

    Meat = {
        "Meat",
        "Carne"
    },

    Stone = {
        "Stone",
        "Rock",
        "Pedra"
    }
}

local Settings = {
    AutoCutTree = false,
    TreeRange = 15,

    AutoCollectAll = false,
    CollectWood = false,
    CollectCoconut = false,
    CollectEgg = false,
    CollectMeat = false,
    CollectStone = false,

    AutoKill = false,
    KillRange = 15,

    AutoFarmChests = false,
    ChestWaitTime = 3,

    ESPEnabled = false
}

local function listContains(list, value)
    for _, item in ipairs(list) do
        if value == item then
            return true
        end
    end

    return false
end

local function shouldCollect(itemName)
    if Settings.AutoCollectAll then
        return true
    end

    if Settings.CollectWood and listContains(ItemNames.Wood, itemName) then
        return true
    end

    if Settings.CollectCoconut and listContains(ItemNames.Coconut, itemName) then
        return true
    end

    if Settings.CollectEgg and listContains(ItemNames.Egg, itemName) then
        return true
    end

    if Settings.CollectMeat and listContains(ItemNames.Meat, itemName) then
        return true
    end

    if Settings.CollectStone and listContains(ItemNames.Stone, itemName) then
        return true
    end

    return false
end

local function getCharacter()
    local character = LocalPlayer.Character

    if character and character:FindFirstChild("HumanoidRootPart") then
        return character
    end

    return nil
end

local function getGameFolder(folderName)
    local gameFolder = workspace:FindFirstChild("Game")

    if not gameFolder then
        return nil
    end

    return gameFolder:FindFirstChild(folderName)
end

-- =========================================================
-- FARM: TREE CHOPPING
-- =========================================================

Tabs.Farm:AddParagraph({
    Title = "Tree Chopping",
    Content = "Stand near trees to chop them automatically."
})

Tabs.Farm:AddToggle("AutoCut", {
    Title = "Auto Cut Trees",
    Description = "Automatically hits nearby trees.",
    Default = false,

    Callback = function(enabled)
        Settings.AutoCutTree = enabled

        if not enabled then
            return
        end

        task.spawn(function()
            while Settings.AutoCutTree do
                task.wait(0.2)

                local staticFolder = getGameFolder("Static")
                local character = getCharacter()

                if staticFolder and character then
                    for _, object in pairs(staticFolder:GetChildren()) do
                        if object.Name == "Coconut Tree" or object.Name == "Tree" then
                            local treePart = object:FindFirstChildWhichIsA(
                                "BasePart",
                                true
                            )

                            if treePart then
                                local distance = (
                                    character.HumanoidRootPart.Position -
                                    treePart.Position
                                ).Magnitude

                                if distance <= Settings.TreeRange then
                                    MeleeHitRemote:FireServer({}, {object})
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
})

Tabs.Farm:AddSlider("TreeRange", {
    Title = "Axe Range",
    Default = 15,
    Min = 5,
    Max = 35,
    Rounding = 0,

    Callback = function(value)
        Settings.TreeRange = value
    end
})

-- =========================================================
-- FARM: ITEM COLLECTION
-- =========================================================

Tabs.Farm:AddParagraph({
    Title = "Ghost Collect",
    Content = "Teleports super fast to get floor items."
})

Tabs.Farm:AddToggle("CollectAll", {
    Title = "Collect ALL Items",
    Description = "Picks up everything from the ground.",
    Default = false,

    Callback = function(enabled)
        Settings.AutoCollectAll = enabled
    end
})

Tabs.Farm:AddParagraph({
    Title = "Item Filters",
    Content = "Disable 'Collect ALL' to use specific filters."
})

Tabs.Farm:AddToggle("FilterWood", {
    Title = "Collect Wood",
    Default = false,

    Callback = function(enabled)
        Settings.CollectWood = enabled
    end
})

Tabs.Farm:AddToggle("FilterCoco", {
    Title = "Collect Coconuts",
    Default = false,

    Callback = function(enabled)
        Settings.CollectCoconut = enabled
    end
})

Tabs.Farm:AddToggle("FilterEgg", {
    Title = "Collect Eggs",
    Default = false,

    Callback = function(enabled)
        Settings.CollectEgg = enabled
    end
})

Tabs.Farm:AddToggle("FilterMeat", {
    Title = "Collect Meat",
    Default = false,

    Callback = function(enabled)
        Settings.CollectMeat = enabled
    end
})

Tabs.Farm:AddToggle("FilterStone", {
    Title = "Collect Stone",
    Default = false,

    Callback = function(enabled)
        Settings.CollectStone = enabled
    end
})

task.spawn(function()
    while true do
        task.wait(0.3)

        local character = getCharacter()

        local collectionEnabled =
            Settings.AutoCollectAll or
            Settings.CollectWood or
            Settings.CollectCoconut or
            Settings.CollectEgg or
            Settings.CollectMeat or
            Settings.CollectStone

        if character and collectionEnabled then
            local droppedItems = getGameFolder("DroppedItems")

            if droppedItems then
                for _, item in pairs(droppedItems:GetChildren()) do
                    if item:IsA("Model") and shouldCollect(item.Name) then
                        local itemPart = item:FindFirstChildWhichIsA(
                            "BasePart",
                            true
                        )

                        if itemPart then
                            local oldCFrame =
                                character.HumanoidRootPart.CFrame

                            local camera = workspace.CurrentCamera

                            camera.CameraType =
                                Enum.CameraType.Scriptable

                            character.HumanoidRootPart.CFrame =
                                itemPart.CFrame

                            task.wait(0.1)
                            CollectRemote:FireServer(item)
                            task.wait(0.1)

                            character.HumanoidRootPart.CFrame =
                                oldCFrame

                            camera.CameraType =
                                Enum.CameraType.Custom
                        end
                    end
                end
            end
        end
    end
end)

-- =========================================================
-- COMBAT
-- =========================================================

Tabs.Combat:AddToggle("AutoKill", {
    Title = "Kill Aura Animals",
    Description = "Automatically attacks nearby animals.",
    Default = false,

    Callback = function(enabled)
        Settings.AutoKill = enabled

        if not enabled then
            return
        end

        task.spawn(function()
            while Settings.AutoKill do
                task.wait(0.2)

                local entities = getGameFolder("Entities")
                local character = getCharacter()

                if entities and character then
                    for _, entity in pairs(entities:GetChildren()) do
                        local humanoid = entity:FindFirstChild("Humanoid")
                        local rootPart =
                            entity:FindFirstChild("HumanoidRootPart")

                        if
                            entity:IsA("Model") and
                            humanoid and
                            rootPart and
                            humanoid.Health > 0
                        then
                            local distance = (
                                character.HumanoidRootPart.Position -
                                rootPart.Position
                            ).Magnitude

                            if distance <= Settings.KillRange then
                                MeleeHitRemote:FireServer({entity}, {})
                            end
                        end
                    end
                end
            end
        end)
    end
})

Tabs.Combat:AddSlider("KillRange", {
    Title = "Weapon Range",
    Default = 15,
    Min = 5,
    Max = 35,
    Rounding = 0,

    Callback = function(value)
        Settings.KillRange = value
    end
})

-- =========================================================
-- CHESTS
-- =========================================================

Tabs.Chests:AddToggle("AutoFarmChests", {
    Title = "Auto Farm All Chests",
    Description = "Teleports to chests one by one.",
    Default = false,

    Callback = function(enabled)
        Settings.AutoFarmChests = enabled

        if not enabled then
            return
        end

        task.spawn(function()
            local visitedChests = {}

            while Settings.AutoFarmChests do
                local chestFolder = getGameFolder("Chest")

                if chestFolder then
                    local chests = chestFolder:GetChildren()

                    if #chests == 0 then
                        visitedChests = {}
                    end

                    for _, chest in pairs(chests) do
                        if not Settings.AutoFarmChests then
                            break
                        end

                        if not visitedChests[chest] then
                            local chestPart =
                                chest:FindFirstChildWhichIsA(
                                    "BasePart",
                                    true
                                )

                            local character = getCharacter()

                            if chestPart and character then
                                character.HumanoidRootPart.CFrame =
                                    chestPart.CFrame *
                                    CFrame.new(0, 2, 0)

                                visitedChests[chest] = true

                                task.wait(Settings.ChestWaitTime)
                            end
                        end
                    end
                end

                task.wait(1)
            end
        end)
    end
})

Tabs.Chests:AddSlider("ChestDelay", {
    Title = "Wait Time per Chest (Seconds)",
    Default = 3,
    Min = 1,
    Max = 15,
    Rounding = 2,

    Callback = function(value)
        Settings.ChestWaitTime = value
    end
})

Tabs.Chests:AddParagraph({
    Title = "Chest List",
    Content =
        "Loot Box Gold, Loot Box House, Loot Box Wild, " ..
        "Loot box 02, Loot box 03"
})

-- =========================================================
-- ENTITY ESP
-- =========================================================

local function removeESP()
    local entities = getGameFolder("Entities")

    if not entities then
        return
    end

    for _, entity in pairs(entities:GetChildren()) do
        local highlight = entity:FindFirstChild("ESPHighlight")

        if highlight then
            highlight:Destroy()
        end
    end
end

Tabs.ESP:AddToggle("ESPAnimals", {
    Title = "Enable Entity ESP",
    Description = "Shows a highlight around animals.",
    Default = false,

    Callback = function(enabled)
        Settings.ESPEnabled = enabled

        if not enabled then
            removeESP()
        end
    end
})

task.spawn(function()
    while true do
        task.wait(1)

        if Settings.ESPEnabled then
            local entities = getGameFolder("Entities")

            if entities then
                for _, entity in pairs(entities:GetChildren()) do
                    if
                        entity:IsA("Model") and
                        not entity:FindFirstChild("ESPHighlight")
                    then
                        local highlight = Instance.new("Highlight")

                        highlight.Name = "ESPHighlight"
                        highlight.FillTransparency = 0.5
                        highlight.OutlineTransparency = 0
                        highlight.FillColor =
                            Color3.fromRGB(255, 0, 0)

                        highlight.OutlineColor =
                            Color3.fromRGB(255, 255, 255)

                        highlight.Parent = entity
                    end
                end
            end
        end
    end
end)

-- =========================================================
-- QUEST TELEPORTS
-- =========================================================

Tabs.Quests:AddParagraph({
    Title = "Teleports",
    Content = "Quick shortcuts to locations and quest items."
})

Tabs.Quests:AddButton({
    Title = "🔥 TP to Campfire",
    Description = "Teleports you to the nearest campfire.",

    Callback = function()
        local character = getCharacter()

        if not character then
            return
        end

        local campfire =
            workspace:FindFirstChild("Campfire", true) or
            workspace:FindFirstChild("Camp Fire", true) or
            workspace:FindFirstChild("Fogueira", true)

        if campfire then
            local targetPart =
                campfire:FindFirstChildWhichIsA("BasePart", true) or
                campfire.PrimaryPart

            if targetPart then
                character.HumanoidRootPart.CFrame =
                    targetPart.CFrame * CFrame.new(0, 3, 0)

                Fluent:Notify({
                    Title = "Success",
                    Content = "Teleported to the campfire!",
                    Duration = 3
                })
            end
        else
            Fluent:Notify({
                Title = "Error",
                Content = "Campfire not found on the map.",
                Duration = 4
            })
        end
    end
})

local function teleportToMapObject(objectName)
    local character = getCharacter()

    if not character then
        return
    end

    local tiles = getGameFolder("Tiles")

    if not tiles then
        return
    end

    local object = tiles:FindFirstChild(objectName, true)

    if object and object:IsA("Model") then
        local targetPart =
            object:FindFirstChildWhichIsA("BasePart", true) or
            object.PrimaryPart

        if targetPart then
            character.HumanoidRootPart.CFrame =
                targetPart.CFrame * CFrame.new(0, 3, 0)

            Fluent:Notify({
                Title = "Success",
                Content = "Teleported to " .. objectName .. "!",
                Duration = 3
            })
        end
    else
        Fluent:Notify({
            Title = "Error",
            Content =
                objectName ..
                " not found. Wait for the map to generate it.",
            Duration = 4
        })
    end
end

Tabs.Quests:AddButton({
    Title = "🪣 TP to Plastic Bucket",

    Callback = function()
        teleportToMapObject("Plastic Bucket")
    end
})

Tabs.Quests:AddButton({
    Title = "📻 TP to Radio",

    Callback = function()
        teleportToMapObject("Radio")
    end
})

Tabs.Quests:AddButton({
    Title = "🧭 TP to Compass",

    Callback = function()
        teleportToMapObject("Compass")
    end
})

Tabs.Quests:AddButton({
    Title = "🗺️ TP to Map",

    Callback = function()
        teleportToMapObject("Map")
    end
})

-- =========================================================
-- MOBILE MENU BUTTON
-- =========================================================

Tabs.Settings:AddParagraph({
    Title = "Configuration",
    Content =
        "Menu Key: Alt\n" ..
        "Mobile users can use the floating 'W' button " ..
        "to toggle the menu."
})

local oldMobileUI = CoreGui:FindFirstChild("MobileButtonUI")

if oldMobileUI then
    oldMobileUI:Destroy()
end

local mobileGui = Instance.new("ScreenGui")
mobileGui.Name = "MobileButtonUI"
mobileGui.Parent = CoreGui

local mobileButton = Instance.new("TextButton")
mobileButton.Name = "Toggle"
mobileButton.Parent = mobileGui
mobileButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mobileButton.Position = UDim2.new(0.5, -25, 0.1, 0)
mobileButton.Size = UDim2.new(0, 50, 0, 50)
mobileButton.Font = Enum.Font.GothamBold
mobileButton.Text = "W"
mobileButton.TextColor3 = Color3.fromRGB(255, 255, 255)
mobileButton.TextSize = 20
mobileButton.Active = true
mobileButton.Draggable = true

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(1, 0)
buttonCorner.Parent = mobileButton

local buttonStroke = Instance.new("UIStroke")
buttonStroke.Color = Color3.fromRGB(150, 150, 150)
buttonStroke.Thickness = 1.5
buttonStroke.Parent = mobileButton

local fluentGui

task.spawn(function()
    while not fluentGui do
        task.wait(0.5)

        for _, gui in pairs(CoreGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                for _, descendant in pairs(gui:GetDescendants()) do
                    if
                        descendant:IsA("TextLabel") and
                        string.find(
                            descendant.Text,
                            "Escape from Mr. Island Beast",
                            1,
                            true
                        )
                    then
                        fluentGui = gui
                        break
                    end
                end
            end

            if fluentGui then
                break
            end
        end
    end
end)

mobileButton.MouseButton1Click:Connect(function()
    if not fluentGui then
        return
    end

    for _, child in pairs(fluentGui:GetChildren()) do
        if child:IsA("Frame") or child:IsA("CanvasGroup") then
            child.Visible = not child.Visible
        end
    end
end)

Fluent:Notify({
    Title = "Script Loaded",
    Content = "Mobile UI loaded! Movement is now free.",
    Duration = 5
})
