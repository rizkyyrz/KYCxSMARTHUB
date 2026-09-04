--[[
    Behavioral deobfuscation of FayintXhub/FayintExploit: Copy-Maps
    Original protector: FayintObfuscator V2

    Notes:
    - Names that were destroyed by virtualization were reconstructed by role.
    - The save engine is not embedded in the protected wrapper. It is downloaded
      at runtime from FayintXhub/FayintLibrary/FYSavemap.luau.
    - The original "Save Terrain" switch changes its UI state but is not passed
      to the save engine. That behavior is preserved below.
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local SAVE_LIBRARY_URL =
    "https://raw.githubusercontent.com/FayintXhub/FayintLibrary/refs/heads/main/FYSavemap.luau"

local function warnMobile(scope, message)
    warn("[FayintX Mobile][" .. tostring(scope) .. "] " .. tostring(message))
end

local taskLibrary = task
local legacyWait = wait
local legacySpawn = spawn

local function taskWait(seconds)
    if taskLibrary and type(taskLibrary.wait) == "function" then
        return taskLibrary.wait(seconds)
    end
    if type(legacyWait) == "function" then
        return legacyWait(seconds)
    end
    return RunService.Heartbeat:Wait()
end

local function taskSpawn(callback, ...)
    local arguments = { ... }
    local unpackValues = table.unpack or unpack

    if taskLibrary and type(taskLibrary.spawn) == "function" then
        return taskLibrary.spawn(callback, unpackValues(arguments))
    end
    if type(legacySpawn) == "function" then
        return legacySpawn(function()
            callback(unpackValues(arguments))
        end)
    end

    local thread = coroutine.create(callback)
    local ok, result = coroutine.resume(thread, unpackValues(arguments))
    if not ok then
        warnMobile("taskSpawn", result)
    end
    return thread
end

local function clamp(value, minimum, maximum)
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
end

local function getPlayerGui()
    local localPlayer = Players.LocalPlayer
    if not localPlayer then return nil end

    local ok, playerGui = pcall(function()
        return localPlayer:FindFirstChildOfClass("PlayerGui") or localPlayer:WaitForChild("PlayerGui", 5)
    end)
    return ok and playerGui or nil
end

local function getUiCandidates()
    local candidates = {}
    local seen = {}

    local function add(candidate)
        if candidate and not seen[candidate] then
            seen[candidate] = true
            candidates[#candidates + 1] = candidate
        end
    end

    if type(gethui) == "function" then
        local ok, hiddenUi = pcall(gethui)
        if ok then add(hiddenUi) end
    end

    add(CoreGui)
    add(getPlayerGui())
    return candidates
end

local function protectScreenGui(screenGui)
    local protector
    if type(syn) == "table" and type(syn.protect_gui) == "function" then
        protector = syn.protect_gui
    elseif type(protect_gui) == "function" then
        protector = protect_gui
    elseif type(protectgui) == "function" then
        protector = protectgui
    end

    if protector then
        pcall(protector, screenGui)
    end
end

local function attachScreenGui(screenGui)
    protectScreenGui(screenGui)
    local lastError = "No compatible UI parent"

    for _, candidate in ipairs(getUiCandidates()) do
        local ok, err = pcall(function()
            screenGui.Parent = candidate
        end)
		if ok then
			return candidate
		end
        lastError = err or lastError
    end

    error("Cannot attach GUI. Executor blocked gethui/CoreGui/PlayerGui: " .. tostring(lastError))
end

local function findOldGui()
    for _, parent in ipairs(getUiCandidates()) do
        local ok, result = pcall(function()
            return parent:FindFirstChild("FayintXCopy")
        end)
        if ok and result then return result end
    end
    return nil
end

local function httpGet(url)
    local errors = {}
    local function attempt(label, callback)
        local ok, result = pcall(callback)
        if ok and type(result) == "string" and #result > 0 then
            return result
        end
        errors[#errors + 1] = label .. ": " .. tostring(result)
        return nil
    end

    local body = attempt("game:HttpGet", function()
        return game:HttpGet(url, true)
    end)
    if body then return body end

    if type(httpget) == "function" then
        body = attempt("httpget", function() return httpget(url) end)
        if body then return body end
    end

    local requestFunction = nil
    if type(request) == "function" then
        requestFunction = request
    elseif type(http_request) == "function" then
        requestFunction = http_request
    elseif type(syn) == "table" and type(syn.request) == "function" then
        requestFunction = syn.request
    end

    if requestFunction then
        body = attempt("request", function()
            local response = requestFunction({ Url = url, Method = "GET" })
            if type(response) == "table" then
                local status = response.StatusCode or response.Status
                if status and tonumber(status) and tonumber(status) >= 400 then
                    error("HTTP " .. tostring(status))
                end
                return response.Body or response.body
            end
            return response
        end)
        if body then return body end
    end

    error("Unable to download save library. " .. table.concat(errors, " | "))
end

local function compileSource(source, chunkName)
    local compiler = loadstring or load
    if type(compiler) ~= "function" then
        error("Executor does not support loadstring")
    end

    local compiled, compileError = compiler(source, chunkName or "FayintSaveMap")
    if type(compiled) ~= "function" then
        error("Save library failed to compile: " .. tostring(compileError))
    end
    return compiled
end

local function writeFile(fileName, contents)
    local writer = writefile
    if type(writer) ~= "function" and type(write_file) == "function" then
        writer = write_file
    end
    if type(writer) ~= "function" then
        error("Executor does not support writefile")
    end

    local ok, err = pcall(writer, fileName, contents)
    if not ok then
        error("writefile failed: " .. tostring(err))
    end
end

local oldGui = findOldGui()
if oldGui then
    pcall(function() oldGui:Destroy() end)
end

local function executorName()
    local identify = identifyexecutor or getexecutorname
    if identify then
        local ok, name = pcall(identify)
        if ok and type(name) == "string" then
            return name
        end
    end
    return "Unknown"
end

local function create(className, properties)
    local object = Instance.new(className)
    for key, value in pairs(properties or {}) do
        if key ~= "Parent" then
            local ok, err = pcall(function()
                object[key] = value
            end)
            if not ok then
                warnMobile(className .. "." .. tostring(key), err)
            end
        end
    end
    local parent = properties and properties.Parent or nil
    if parent then
        local ok, err = pcall(function()
            object.Parent = parent
        end)
        if not ok then
            warnMobile(className .. ".Parent", err)
        end
    end
    return object
end

local function addCorner(parent, scale, offset)
    return create("UICorner", {
        CornerRadius = UDim.new(scale or 0, offset or 10),
        Parent = parent,
    })
end

local function addStroke(parent, color, transparency, thickness)
    return create("UIStroke", {
        Color = color or Color3.fromRGB(90, 90, 90),
        Transparency = transparency or 0.4,
        Thickness = thickness or 1.2,
        Parent = parent,
    })
end

local COLORS = {
    background = Color3.fromRGB(18, 18, 18),
    panel = Color3.fromRGB(26, 26, 26),
    control = Color3.fromRGB(35, 35, 35),
    controlOn = Color3.fromRGB(60, 60, 70),
    accent = Color3.fromRGB(255, 255, 255),
    text = Color3.fromRGB(200, 200, 200),
    muted = Color3.fromRGB(170, 170, 170),
    success = Color3.fromRGB(80, 200, 120),
    warning = Color3.fromRGB(255, 140, 0),
    failure = Color3.fromRGB(220, 20, 60),
}

local state = {
    mode = "optimized",
    saving = false,
    cancelled = false,
    startedAt = 0,
    noScripts = false,
    scriptCache = true,
    saveBytecode = false,
    ignoreDefaultProperties = true,
    safeMode = false,
    saveTerrain = true, -- UI-only in the protected original.
}

local gui = create("ScreenGui", {
    Name = "FayintXCopy",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
local uiParent = attachScreenGui(gui)

local main = create("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0.36, 0, 0.42, 0),
    BackgroundColor3 = COLORS.background,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = gui,
})
addCorner(main, 0, 14)
addStroke(main, COLORS.text, 0.4, 1.8)
create("UIAspectRatioConstraint", { AspectRatio = 0.78, Parent = main })
create("UISizeConstraint", {
    MinSize = Vector2.new(240, 340),
    MaxSize = Vector2.new(480, 680),
    Parent = main,
})

local topBar = create("Frame", {
    Name = "TopBar",
    Size = UDim2.new(1, 0, 0.16, 0),
    BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0,
    ZIndex = 2,
    Parent = main,
})
addCorner(topBar, 0, 14)

local title = create("TextLabel", {
    Name = "Title",
    Position = UDim2.new(0, 16, 0.08, 0),
    Size = UDim2.new(0.7, 0, 0.38, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "SAVEMAP | FAYINTX",
    TextColor3 = COLORS.accent,
    TextScaled = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = topBar,
})

create("TextLabel", {
    Name = "Description",
    Position = UDim2.new(0, 16, 0.49, 0),
    Size = UDim2.new(0.7, 0, 0.3, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = executorName() .. " Executor",
    TextColor3 = COLORS.text,
    TextScaled = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = topBar,
})

local closeButton = create("TextButton", {
    Name = "Close",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(0.955, 0, 0.08, 0),
    Size = UDim2.new(0.09, 0, 0.44, 0),
    BackgroundColor3 = Color3.fromRGB(45, 45, 45),
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.GothamBold,
    Text = "×",
    TextColor3 = COLORS.muted,
    TextSize = 28,
    Parent = topBar,
})
addCorner(closeButton, 0.25, 0)
addStroke(closeButton)

local tabs = create("Frame", {
    Name = "TabContainer",
    Position = UDim2.new(0, 16, 0.16, 0),
    Size = UDim2.new(1, -32, 0.115, 0),
    BackgroundTransparency = 1,
    Parent = main,
})

local function makeTab(name, text, position, selected)
    local button = create("TextButton", {
        Name = name,
        Position = position,
        Size = UDim2.new(0.48, 0, 0.75, 0),
        BackgroundColor3 = selected and COLORS.controlOn or COLORS.control,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.GothamBold,
        Text = text,
        TextColor3 = selected and COLORS.accent or COLORS.muted,
        TextSize = 14,
        Parent = tabs,
    })
    addCorner(button, 0.25, 0)
    return button
end

local saveTab = makeTab("SaveTab", "SAVE", UDim2.new(0, 0, 0.125, 0), true)
local settingsTab = makeTab("SettingsTab", "SETTINGS", UDim2.new(0.52, 0, 0.125, 0), false)

local content = create("Frame", {
    Name = "Content",
    Position = UDim2.new(0, 16, 0.275, 0),
    Size = UDim2.new(1, -32, 0.7, 0),
    BackgroundTransparency = 1,
    Parent = main,
})

local savePage = create("Frame", {
    Name = "SavePage",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Parent = content,
})

local settingsPage = create("Frame", {
    Name = "SettingsPage",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Visible = false,
    Parent = content,
})

create("TextLabel", {
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(1, 0, 0.04, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "Save Mode:",
    TextColor3 = COLORS.text,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = savePage,
})

local modeContainer = create("Frame", {
    Position = UDim2.new(0, 0, 0.045, 0),
    Size = UDim2.new(1, 0, 0.09, 0),
    BackgroundTransparency = 1,
    Parent = savePage,
})

local modeButtons = {}
local function makeModeButton(text, mode, x)
    local button = create("TextButton", {
        Position = UDim2.new(x, 0, 0, 0),
        Size = UDim2.new(0.33, -2, 1, 0),
        BackgroundColor3 = mode == state.mode and COLORS.controlOn or COLORS.control,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.GothamBold,
        Text = text,
        TextColor3 = mode == state.mode and COLORS.accent or COLORS.muted,
        TextSize = 11,
        Parent = modeContainer,
    })
    addCorner(button, 0.15, 0)
    modeButtons[mode] = button
    button.MouseButton1Click:Connect(function()
        state.mode = mode
        for candidateMode, candidate in pairs(modeButtons) do
            local selected = candidateMode == mode
            candidate.BackgroundColor3 = selected and COLORS.controlOn or COLORS.control
            candidate.TextColor3 = selected and COLORS.accent or COLORS.muted
        end
    end)
end

makeModeButton("FULL", "full", 0)
makeModeButton("OPT", "optimized", 0.335)
makeModeButton("SCRIPTS", "scripts", 0.67)

create("TextLabel", {
    Position = UDim2.new(0, 0, 0.155, 0),
    Size = UDim2.new(1, 0, 0.04, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "File Name:",
    TextColor3 = COLORS.text,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = savePage,
})

local filenameBox = create("TextBox", {
    Position = UDim2.new(0, 0, 0.2, 0),
    Size = UDim2.new(1, 0, 0.09, 0),
    BackgroundColor3 = COLORS.control,
    BorderSizePixel = 0,
    ClearTextOnFocus = false,
    Font = Enum.Font.Gotham,
    PlaceholderText = "FayintSaveMap",
    Text = "FayintSaveMap",
    TextColor3 = COLORS.accent,
    TextSize = 13,
    Parent = savePage,
})
addCorner(filenameBox, 0, 8)

local progressBackground = create("Frame", {
    Position = UDim2.new(0, 0, 0.33, 0),
    Size = UDim2.new(1, 0, 0.055, 0),
    BackgroundColor3 = COLORS.control,
    BorderSizePixel = 0,
    Parent = savePage,
})
addCorner(progressBackground, 1, 0)

local progressFill = create("Frame", {
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = COLORS.accent,
    BorderSizePixel = 0,
    Parent = progressBackground,
})
addCorner(progressFill, 1, 0)

local progressText = create("TextLabel", {
    Position = UDim2.new(0, 0, 0.395, 0),
    Size = UDim2.new(1, 0, 0.05, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "0%",
    TextColor3 = COLORS.text,
    TextSize = 11,
    Parent = savePage,
})

local statusText = create("TextLabel", {
    Position = UDim2.new(0, 0, 0.45, 0),
    Size = UDim2.new(1, 0, 0.05, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "Status: Ready",
    TextColor3 = COLORS.text,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = savePage,
})

local detailText = create("TextLabel", {
    Position = UDim2.new(0, 0, 0.5, 0),
    Size = UDim2.new(1, 0, 0.05, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "Ready to save",
    TextColor3 = COLORS.muted,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = savePage,
})

local function makeActionButton(name, text, y, color, sizeY)
    local button = create("TextButton", {
        Name = name,
        Position = UDim2.new(0, 0, y, 0),
        Size = UDim2.new(1, 0, sizeY or 0.1, 0),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.GothamBold,
        Text = text,
        TextColor3 = COLORS.accent,
        TextSize = 14,
        Parent = savePage,
    })
    addCorner(button, 0, 8)
    return button
end

local startButton = makeActionButton("StartButton", "🚀 START SAVING", 0.62, COLORS.accent, 0.11)
startButton.TextColor3 = COLORS.background
local guideButton = makeActionButton("HowToButton", "ℹ️ DETAILED GUIDE", 0.75, COLORS.control, 0.09)
guideButton.TextSize = 12
local cancelButton = makeActionButton("CancelButton", "❌ CANCEL", 0.86, COLORS.failure, 0.09)
cancelButton.TextSize = 12
cancelButton.Visible = false

local function makeToggle(label, y, stateKey)
    create("TextLabel", {
        Position = UDim2.new(0, 0, y, 0),
        Size = UDim2.new(0.7, 0, 0.095, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = label,
        TextColor3 = COLORS.text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = settingsPage,
    })

    local button = create("TextButton", {
        Position = UDim2.new(1, -40, y + 0.02, 0),
        Size = UDim2.new(0, 40, 0, 20),
        BackgroundColor3 = state[stateKey] and COLORS.controlOn or COLORS.control,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        Parent = settingsPage,
    })
    addCorner(button, 1, 0)

    local knob = create("Frame", {
        Position = UDim2.new(0, state[stateKey] and 22 or 2, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        BackgroundColor3 = COLORS.accent,
        BorderSizePixel = 0,
        Parent = button,
    })
    addCorner(knob, 1, 0)

    button.MouseButton1Click:Connect(function()
        state[stateKey] = not state[stateKey]
        TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, state[stateKey] and 22 or 2, 0.5, -8),
        }):Play()
        TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = state[stateKey] and COLORS.controlOn or COLORS.control,
        }):Play()
    end)
end

makeToggle("Disable Decompile", 0.02, "noScripts")
makeToggle("Use Cache", 0.17, "scriptCache")
makeToggle("Save Bytecode", 0.32, "saveBytecode")
makeToggle("Ignore Default Props", 0.47, "ignoreDefaultProperties")
makeToggle("Safe Mode", 0.62, "safeMode")
makeToggle("Save Terrain", 0.77, "saveTerrain")

local function setPage(page)
    local showSave = page == "save"
    savePage.Visible = showSave
    settingsPage.Visible = not showSave
    saveTab.BackgroundColor3 = showSave and COLORS.controlOn or COLORS.control
    saveTab.TextColor3 = showSave and COLORS.accent or COLORS.muted
    settingsTab.BackgroundColor3 = showSave and COLORS.control or COLORS.controlOn
    settingsTab.TextColor3 = showSave and COLORS.muted or COLORS.accent
end

saveTab.MouseButton1Click:Connect(function() setPage("save") end)
settingsTab.MouseButton1Click:Connect(function() setPage("settings") end)

local function setProgress(percent, status, detail, color)
    percent = clamp(percent, 0, 100)
    TweenService:Create(progressFill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(percent / 100, 0, 1, 0),
        BackgroundColor3 = color or COLORS.accent,
    }):Play()
    progressText.Text = string.format("%d%%", percent)
    statusText.Text = "Status: " .. status .. string.format(" (%.1fs)", os.clock() - state.startedAt)
    detailText.Text = detail
end

local function notify(titleText, bodyText, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = titleText,
            Text = bodyText,
            Duration = duration or 5,
        })
    end)
end

local function recursiveCount(root)
    local total = 1
    local function walk(instance)
        for _, child in ipairs(instance:GetChildren()) do
            total = total + 1
            walk(child)
        end
    end
    walk(root)
    return total
end

local function resetButtons()
    state.saving = false
    startButton.Text = "🚀 START SAVING"
    startButton.BackgroundColor3 = COLORS.accent
    startButton.TextColor3 = COLORS.background
    cancelButton.Visible = false
    guideButton.Visible = true
end

local function saveMap()
    if state.saving then return end

    state.saving = true
    state.cancelled = false
    state.startedAt = os.clock()
    startButton.Text = "⏳ SAVING..."
    startButton.BackgroundColor3 = COLORS.warning
    startButton.TextColor3 = COLORS.accent
    cancelButton.Visible = true
    guideButton.Visible = false

    taskSpawn(function()
        local ok, err = pcall(function()
            setProgress(0, "Initializing", "Preparing save system...")
            taskWait(0.3)
            if state.cancelled then return end

            setProgress(5, "Scanning", "Counting instances...")
            local roots = {
                game:GetService("Workspace"),
                game:GetService("Lighting"),
                game:GetService("ReplicatedStorage"),
            }
            local totalInstances = 0
            for _, root in ipairs(roots) do
                totalInstances = totalInstances + recursiveCount(root)
            end
            detailText.Text = "Total instances: " .. totalInstances
            taskWait(0.2)
            if state.cancelled then return end

            setProgress(10, "Loading", "Loading save module...")
            local source = httpGet(SAVE_LIBRARY_URL)
            local factory = compileSource(source, "FayintSaveMap")
            local saveInstance = factory()
            if type(saveInstance) ~= "function" then
                error("Save library did not return a function")
            end
            taskWait(0.2)
            if state.cancelled then return end

            setProgress(15, "Configuring", "Building save options...")
            local requestedName = filenameBox.Text ~= "" and filenameBox.Text or "FayintSaveMap"
            local outputName = requestedName .. ".rbxlx"
            taskWait(0.2)

            setProgress(20, "Processing", "Starting instance processing...")
            saveInstance({
                ReadMe = true,
                FilePath = requestedName,
                AntiIdle = true,
                noscripts = state.noScripts,
                SaveBytecode = state.saveBytecode,
                ShowStatus = false,
                SafeMode = state.safeMode,
                AlternativeWritefile = true,
                scriptcache = state.scriptCache,
                AvoidFileOverwrite = true,
                __DEBUG_MODE = false,
                mode = state.mode,
                timeout = 15,
                IgnoreDefaultProperties = state.ignoreDefaultProperties,
                Callback = function(serializedData, _chunks, totalSize)
                    if state.cancelled then return end
                    setProgress(95, "Writing", "Finalizing file write...", COLORS.success)
                    writeFile(outputName, serializedData)
                    local sizeMb = (tonumber(totalSize) or #serializedData) / (1024 * 1024)
                    setProgress(100, "Completed", string.format("File saved successfully (%.2f MB)", sizeMb), COLORS.success)
                end,
            })

            if state.cancelled then return end
            setProgress(100, "Completed", string.format("Saved %d instances successfully!", totalInstances), COLORS.success)
            startButton.Text = "✅ SAVED!"
            startButton.BackgroundColor3 = COLORS.success
            notify("SaveMap Complete", outputName .. " saved successfully", 6)
            print("\n[SaveMap] File saved: " .. outputName)
            print("[SaveMap] Location: Executor Folder > Workspace > FayintSaveMap")
            taskWait(3)
        end)

        if not ok then
            setProgress(0, "Error", "Save failed - Check console", COLORS.failure)
            startButton.Text = "❌ FAILED"
            startButton.BackgroundColor3 = COLORS.failure
            startButton.TextColor3 = COLORS.accent
            notify("SaveMap Error", tostring(err), 7)
            warn("[SaveMap]", err)
            taskWait(3)
        elseif state.cancelled then
            setProgress(0, "Cancelled", "Save process was cancelled by user", COLORS.failure)
        end

        resetButtons()
    end)
end

startButton.MouseButton1Click:Connect(saveMap)
cancelButton.MouseButton1Click:Connect(function()
    state.cancelled = true
    setProgress(0, "Cancelled", "Save process was cancelled by user", COLORS.failure)
    notify("SaveMap", "Save process cancelled", 4)
    resetButtons()
end)

guideButton.MouseButton1Click:Connect(function()
    local guide = create("ScreenGui", {
        Name = "SaveMapGuide",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    protectScreenGui(guide)
    local guideAttached, guideError = pcall(function()
        guide.Parent = uiParent
    end)
    if not guideAttached then
        warnMobile("GuideGui", guideError)
        attachScreenGui(guide)
    end
    local modal = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 450, 0, 300),
        BackgroundColor3 = Color3.fromRGB(15, 8, 12),
        BorderSizePixel = 0,
        Parent = guide,
    })
    addCorner(modal, 0, 14)
    addStroke(modal)

    create("TextLabel", {
        Position = UDim2.new(0, 20, 0, 16),
        Size = UDim2.new(1, -40, 1, -70),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = [[DETAILED SAVEMAP GUIDE

TERRAIN SUPPORT:
• Use PAID executors for terrain copying
• Free executors may NOT support terrain

FILE LOCATION:
• Executor Folder > Workspace > FayintSaveMap
• Files saved as .rbxlx format

SAVE MODES: FULL / OPT / SCRIPTS
IF ERROR: Join Discord or try another save mode]],
        TextColor3 = COLORS.text,
        TextSize = 13,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = modal,
    })

    local dismiss = create("TextButton", {
        Position = UDim2.new(0, 20, 1, -48),
        Size = UDim2.new(1, -40, 0, 32),
        BackgroundColor3 = COLORS.control,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = "CLOSE",
        TextColor3 = COLORS.accent,
        TextSize = 13,
        Parent = modal,
    })
    addCorner(dismiss, 0, 8)
    dismiss.MouseButton1Click:Connect(function() guide:Destroy() end)

    print([[\n==================================================
📝 DETAILED SAVEMAP GUIDE
==================================================
TERRAIN SUPPORT:
• Use PAID executors for terrain copying
• Free executors may NOT support terrain

FILE LOCATION:
• Executor Folder > Workspace > FayintSaveMap
• Files saved as .rbxlx format

SAVE MODES:
• FULL - Save everything
• OPT - Optimized (recommended)
• SCRIPTS - Scripts only

IF ERROR:
• Join Discord for support
• Try different save mode
==================================================]])
end)

closeButton.MouseButton1Click:Connect(function()
    TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
    }):Play()
    taskWait(0.25)
    main.Visible = false
end)

-- Mobile/desktop dragging.
do
    local dragging = false
    local dragInput
    local dragStart
    local startPosition

    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    main.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)
end

setProgress(0, "Ready", "Ready to save", COLORS.accent)
main.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0.36, 0, 0.42, 0),
}):Play()

notify("FayintX SaveMap", "GUI loaded successfully", 5)
print("[SaveMap] GUI Loaded - Executor:", executorName())
print("[SaveMap] Note: Some executors may not support terrain saving")
print("[SaveMap] Files saved to: Executor Folder > Workspace > FayintSaveMap")
