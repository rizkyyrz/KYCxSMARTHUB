-- [[ CONFIGURATION & DICTIONARY SYSTEM ]]
local ones = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"}
local tens = {"twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"}

local function getUnder100(num)
	if num >= 1 and num <= 19 then
		return ones[num]
	else
		local tenIndex = math.floor(num / 10) - 1
		local oneIndex = num % 10
		if oneIndex == 0 then
			return tens[tenIndex]
		else
			return tens[tenIndex] .. " " .. ones[oneIndex]
		end
	end
end

local function getNumberSpelling(num)
	if num < 1 or num > 10000 then
		return tostring(num)
	end

	if num < 100 then
		return getUnder100(num)
	end

	if num < 1000 then
		local hundredDigit = math.floor(num / 100)
		local remainder = num % 100
		local hundredText = ones[hundredDigit] .. " hundred"

		if remainder == 0 then
			return hundredText
		end

		return hundredText .. " " .. getUnder100(remainder)
	end

	if num < 10000 then
		local thousandDigit = math.floor(num / 1000)
		local remainder = num % 1000
		local thousandText = ones[thousandDigit] .. " thousand"

		if remainder == 0 then
			return thousandText
		end

		if remainder < 100 then
			return thousandText .. " " .. getUnder100(remainder)
		end

		local hundredDigit = math.floor(remainder / 100)
		local lastTwoDigits = remainder % 100
		local hundredText = ones[hundredDigit] .. " hundred"

		if lastTwoDigits == 0 then
			return thousandText .. " " .. hundredText
		end

		return thousandText .. " " .. hundredText .. " " .. getUnder100(lastTwoDigits)
	end

	return "ten thousand"
end


-- [[ SERVICES & LOCAL PLAYER ]]
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- [[ ANTI-AFK OTOMATIS: SELALU AKTIF ]]
player.Idled:Connect(function()
	pcall(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new(0, 0))
	end)
end)

local OBBY_CONFIG = {
	Tamtama = {
		TweenSpeed = 300,
		StepDelay = 3,
		LoopDelay = 1,
	},
	Bintara = {
		TweenSpeed = 300,
		StepDelay = 3,
		LoopDelay = 1,
	},
	Pama = {
		TweenSpeed = 300,
		StepDelay = 3,
		LoopDelay = 1,
	},
}

local lastGameTextBox = nil

local function isValidGameTextBox(textBox, ownGui)
	return textBox
		and textBox:IsA("TextBox")
		and textBox.Parent
		and (not ownGui or not textBox:IsDescendantOf(ownGui))
end

local function sendToTargetTextBox(targetTextBox, message)
	if not isValidGameTextBox(targetTextBox) then
		return false, "Kolom input sudah tidak tersedia"
	end

	local success, err = pcall(function()
		targetTextBox:CaptureFocus()
		task.wait()
		targetTextBox.Text = message
		task.wait(0.05)
		targetTextBox:ReleaseFocus(true)
	end)

	if not success then
		return false, tostring(err)
	end

	return true
end

-- [[ INTERFACE / GUI CREATION (ARMY THEME VERTIKAL & TRANSPARANT) ]]
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SmartHubAutoKataObbyGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 580, 0, 330)
mainFrame.Position = UDim2.new(0.5, -290, 0.4, -165)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 55, 40) 
mainFrame.BackgroundTransparency = 0.35 
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 2.5
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainStroke.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 45)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "SmartHub AUTO KATA & OBBY"
titleLabel.TextColor3 = Color3.fromRGB(245, 245, 235)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 20
titleLabel.Parent = mainFrame

local creatorLabel = Instance.new("TextLabel")
creatorLabel.Size = UDim2.new(0.25, 0, 0, 25)
creatorLabel.Position = UDim2.new(0.02, 0, 1, -30)
creatorLabel.BackgroundTransparency = 1
creatorLabel.Text = "By: Kycuu"
creatorLabel.TextColor3 = Color3.fromRGB(180, 190, 175)
creatorLabel.Font = Enum.Font.SourceSansItalic
creatorLabel.TextSize = 13
creatorLabel.Parent = mainFrame

-- [[ TATA LETAK VERTIKAL: KIRI NAVIGASI ]]
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(0.28, 0, 0.85, 0)
tabContainer.Position = UDim2.new(0.02, 0, 0.12, 0)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local tabListLayout = Instance.new("UIListLayout")
tabListLayout.Padding = UDim.new(0, 4) 
tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabListLayout.Parent = tabContainer

local rgbObjects = {}
table.insert(rgbObjects, mainStroke)

local function makeTabBtn(text, order, active)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 42)
	btn.LayoutOrder = order
	btn.BackgroundColor3 = active and Color3.fromRGB(70, 90, 65) or Color3.fromRGB(35, 43, 32) 
	btn.BackgroundTransparency = 0.2 
	btn.Text = text
	btn.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 205, 195)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 12 
	btn.Parent = tabContainer
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	
	local btnStroke = Instance.new("UIStroke")
	btnStroke.Thickness = 1.5
	btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	btnStroke.Parent = btn
	table.insert(rgbObjects, btnStroke)
	
	return btn
end


local angkaTabBtn   = makeTabBtn("Auto Kata",     1, true)
local tamtamaTabBtn = makeTabBtn("Obby Tamtama", 2, false)
local bintaraTabBtn = makeTabBtn("Obby Bintara", 3, false)
local pamaTabBtn    = makeTabBtn("Obby Pama",    4, false)

-- [[ TATA LETAK VERTIKAL: KANAN KONTEN ]]
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(0.66, 0, 0.85, 0)
contentFrame.Position = UDim2.new(0.32, 0, 0.12, 0)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

----------------------------------------------------
-- [ KONTEN 1: HALAMAN AUTO KATA ]
----------------------------------------------------
local angkaPage = Instance.new("Frame")
angkaPage.Size = UDim2.new(1, 0, 1, 0)
angkaPage.BackgroundTransparency = 1
angkaPage.Parent = contentFrame

local inputTextBox = Instance.new("TextBox")
inputTextBox.Size = UDim2.new(1, 0, 0, 50)
inputTextBox.Position = UDim2.new(0, 0, 0.05, 0)
inputTextBox.BackgroundColor3 = Color3.fromRGB(30, 38, 28)
inputTextBox.BackgroundTransparency = 0.2
inputTextBox.TextColor3 = Color3.fromRGB(150, 255, 100)
inputTextBox.Font = Enum.Font.Code
inputTextBox.TextSize = 15
inputTextBox.Text = "[Klik kolom game lalu klik PLAY]"
inputTextBox.ClearTextOnFocus = false
inputTextBox.Parent = angkaPage
Instance.new("UICorner", inputTextBox).CornerRadius = UDim.new(0, 6)

local inputStroke = Instance.new("UIStroke")
inputStroke.Thickness = 1.2
inputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
inputStroke.Parent = inputTextBox
table.insert(rgbObjects, inputStroke)

local playButton = Instance.new("TextButton")
playButton.Size = UDim2.new(0.47, 0, 0, 45)
playButton.Position = UDim2.new(0, 0, 0.35, 0)
playButton.BackgroundColor3 = Color3.fromRGB(50, 160, 90)
playButton.Text = "PLAY"
playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
playButton.Font = Enum.Font.SourceSansBold
playButton.TextSize = 16
playButton.Parent = angkaPage
Instance.new("UICorner", playButton).CornerRadius = UDim.new(0, 8)

local playStroke = Instance.new("UIStroke")
playStroke.Thickness = 1.2
playStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
playStroke.Parent = playButton
table.insert(rgbObjects, playStroke)

local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(0.47, 0, 0, 45)
stopButton.Position = UDim2.new(0.53, 0, 0.35, 0)
stopButton.BackgroundColor3 = Color3.fromRGB(180, 60, 50)
stopButton.Text = "STOP"
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.Font = Enum.Font.SourceSansBold
stopButton.TextSize = 16
stopButton.Parent = angkaPage
Instance.new("UICorner", stopButton).CornerRadius = UDim.new(0, 8)

local stopStroke = Instance.new("UIStroke")
stopStroke.Thickness = 1.2
stopStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stopStroke.Parent = stopButton
table.insert(rgbObjects, stopStroke)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0.65, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Berhenti"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 190)
statusLabel.Font = Enum.Font.SourceSansItalic
statusLabel.TextSize = 14
statusLabel.Parent = angkaPage

----------------------------------------------------

-- [[ LOGIKA GLOBAL TWEEN TELEPORT BYPASS ]]
local function safeTweenTeleport(targetCFrame, tweenSpeed)
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	local currentPos = hrp.Position
	local distance = (currentPos - targetCFrame.Position).Magnitude
	local speed = tonumber(tweenSpeed) or 250
	local duration = math.clamp(distance / speed, 0.15, 0.8)
	
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
	
	tween:Play()
	tween.Completed:Wait()
end

----------------------------------------------------
-- [ KONTEN 4: HALAMAN OBBY TAMTAMA ]
----------------------------------------------------
local tamtamaPage = Instance.new("Frame")
tamtamaPage.Size = UDim2.new(1, 0, 1, 0)
tamtamaPage.BackgroundTransparency = 1
tamtamaPage.Visible = false
tamtamaPage.Parent = contentFrame

local tamtamaInfo = Instance.new("TextLabel")
tamtamaInfo.Size = UDim2.new(1, 0, 0, 50)
tamtamaInfo.Position = UDim2.new(0, 0, 0.05, 0)
tamtamaInfo.BackgroundColor3 = Color3.fromRGB(30, 38, 28)
tamtamaInfo.BackgroundTransparency = 0.2
tamtamaInfo.Text = "Obby Tamtama Safe Glide (Anti-Cheat Bypass)"
tamtamaInfo.TextColor3 = Color3.fromRGB(230, 200, 50)
tamtamaInfo.Font = Enum.Font.SourceSansBold
tamtamaInfo.TextSize = 14
tamtamaInfo.Parent = tamtamaPage
Instance.new("UICorner", tamtamaInfo).CornerRadius = UDim.new(0, 6)

local tamtamaInfoStroke = Instance.new("UIStroke")
tamtamaInfoStroke.Thickness = 1.2
tamtamaInfoStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
tamtamaInfoStroke.Parent = tamtamaInfo
table.insert(rgbObjects, tamtamaInfoStroke)

local tamtamaPlay = Instance.new("TextButton")
tamtamaPlay.Size = UDim2.new(0.47, 0, 0, 45)
tamtamaPlay.Position = UDim2.new(0, 0, 0.35, 0)
tamtamaPlay.BackgroundColor3 = Color3.fromRGB(50, 150, 80)
tamtamaPlay.Text = "START OBBY"
tamtamaPlay.TextColor3 = Color3.fromRGB(255, 255, 255)
tamtamaPlay.Font = Enum.Font.SourceSansBold
tamtamaPlay.TextSize = 15
tamtamaPlay.Parent = tamtamaPage
Instance.new("UICorner", tamtamaPlay).CornerRadius = UDim.new(0, 8)

local tamtamaPlayStroke = Instance.new("UIStroke")
tamtamaPlayStroke.Thickness = 1.2
tamtamaPlayStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
tamtamaPlayStroke.Parent = tamtamaPlay
table.insert(rgbObjects, tamtamaPlayStroke)

local tamtamaStop = Instance.new("TextButton")
tamtamaStop.Size = UDim2.new(0.47, 0, 0, 45)
tamtamaStop.Position = UDim2.new(0.53, 0, 0.35, 0)
tamtamaStop.BackgroundColor3 = Color3.fromRGB(180, 60, 50)
tamtamaStop.Text = "STOP OBBY"
tamtamaStop.TextColor3 = Color3.fromRGB(255, 255, 255)
tamtamaStop.Font = Enum.Font.SourceSansBold
tamtamaStop.TextSize = 15
tamtamaStop.Parent = tamtamaPage
Instance.new("UICorner", tamtamaStop).CornerRadius = UDim.new(0, 8)

local tamtamaStopStroke = Instance.new("UIStroke")
tamtamaStopStroke.Thickness = 1.2
tamtamaStopStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
tamtamaStopStroke.Parent = tamtamaStop
table.insert(rgbObjects, tamtamaStopStroke)

local tamtamaStatus = Instance.new("TextLabel")
tamtamaStatus.Size = UDim2.new(1, 0, 0, 40)
tamtamaStatus.Position = UDim2.new(0, 0, 0.65, 0)
tamtamaStatus.BackgroundTransparency = 1
tamtamaStatus.Text = "Status: Standby"
tamtamaStatus.TextColor3 = Color3.fromRGB(200, 200, 190)
tamtamaStatus.Font = Enum.Font.SourceSansItalic
tamtamaStatus.TextSize = 14
tamtamaStatus.Parent = tamtamaPage

local rintanganTamtama = {
	{Name = "Rintangan 1", CF = CFrame.new(-120.768, 47.341, 1655.709)},
	{Name = "Rintangan 2", CF = CFrame.new(-118.212, 58.973, 1750.058)},
	{Name = "Rintangan 3", CF = CFrame.new(-171.202, 59.031, 1865.941)},
	{Name = "Rintangan 4", CF = CFrame.new(-258.533, 59.031, 1850.870)},
	{Name = "Rintangan 5", CF = CFrame.new(-252.678, 47.122, 1696.687)},
	{Name = "Rintangan 6", CF = CFrame.new(-245.251, 87.663, 1659.777)}
}

local isTamtamaRunning = false
tamtamaPlay.MouseButton1Click:Connect(function()
	if isTamtamaRunning then return end
	isTamtamaRunning = true
	tamtamaStatus.TextColor3 = Color3.fromRGB(100, 240, 120)
	task.spawn(function()
		while isTamtamaRunning do
			for _, rintangan in ipairs(rintanganTamtama) do
				if not isTamtamaRunning then break end
				tamtamaStatus.Text = "Meluncur ke: " .. rintangan.Name
				pcall(function()
				safeTweenTeleport(rintangan.CF, OBBY_CONFIG.Tamtama.TweenSpeed)
			end)
			task.wait(OBBY_CONFIG.Tamtama.StepDelay)
		end
		task.wait(OBBY_CONFIG.Tamtama.LoopDelay)
		end
	end)
end)
tamtamaStop.MouseButton1Click:Connect(function()
	isTamtamaRunning = false
	tamtamaStatus.Text = "Status: Dihentikan"
	tamtamaStatus.TextColor3 = Color3.fromRGB(240, 100, 90)
end)

----------------------------------------------------
-- [ KONTEN 5: HALAMAN OBBY BINTARA ]
----------------------------------------------------
local bintaraPage = Instance.new("Frame")
bintaraPage.Size = UDim2.new(1, 0, 1, 0)
bintaraPage.BackgroundTransparency = 1
bintaraPage.Visible = false
bintaraPage.Parent = contentFrame

local bintaraInfo = Instance.new("TextLabel")
bintaraInfo.Size = UDim2.new(1, 0, 0, 50)
bintaraInfo.Position = UDim2.new(0, 0, 0.05, 0)
bintaraInfo.BackgroundColor3 = Color3.fromRGB(30, 38, 28)
bintaraInfo.BackgroundTransparency = 0.2
bintaraInfo.Text = "Obby Bintara Safe Glide (Anti-Cheat Bypass)"
bintaraInfo.TextColor3 = Color3.fromRGB(46, 204, 113) 
bintaraInfo.Font = Enum.Font.SourceSansBold
bintaraInfo.TextSize = 14
bintaraInfo.Parent = bintaraPage
Instance.new("UICorner", bintaraInfo).CornerRadius = UDim.new(0, 6)

local bintaraInfoStroke = Instance.new("UIStroke")
bintaraInfoStroke.Thickness = 1.2
bintaraInfoStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
bintaraInfoStroke.Parent = bintaraInfo
table.insert(rgbObjects, bintaraInfoStroke)

local bintaraPlay = Instance.new("TextButton")
bintaraPlay.Size = UDim2.new(0.47, 0, 0, 45)
bintaraPlay.Position = UDim2.new(0, 0, 0.35, 0)
bintaraPlay.BackgroundColor3 = Color3.fromRGB(50, 150, 80)
bintaraPlay.Text = "START OBBY"
bintaraPlay.TextColor3 = Color3.fromRGB(255, 255, 255)
bintaraPlay.Font = Enum.Font.SourceSansBold
bintaraPlay.TextSize = 15
bintaraPlay.Parent = bintaraPage
Instance.new("UICorner", bintaraPlay).CornerRadius = UDim.new(0, 8)

local bintaraPlayStroke = Instance.new("UIStroke")
bintaraPlayStroke.Thickness = 1.2
bintaraPlayStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
bintaraPlayStroke.Parent = bintaraPlay
table.insert(rgbObjects, bintaraPlayStroke)

local bintaraStop = Instance.new("TextButton")
bintaraStop.Size = UDim2.new(0.47, 0, 0, 45)
bintaraStop.Position = UDim2.new(0.53, 0, 0.35, 0)
bintaraStop.BackgroundColor3 = Color3.fromRGB(180, 60, 50)
bintaraStop.Text = "STOP OBBY"
bintaraStop.TextColor3 = Color3.fromRGB(255, 255, 255)
bintaraStop.Font = Enum.Font.SourceSansBold
bintaraStop.TextSize = 15
bintaraStop.Parent = bintaraPage
Instance.new("UICorner", bintaraStop).CornerRadius = UDim.new(0, 8)

local bintaraStopStroke = Instance.new("UIStroke")
bintaraStopStroke.Thickness = 1.2
bintaraStopStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
bintaraStopStroke.Parent = bintaraStop
table.insert(rgbObjects, bintaraStopStroke)

local bintaraStatus = Instance.new("TextLabel")
bintaraStatus.Size = UDim2.new(1, 0, 0, 40)
bintaraStatus.Position = UDim2.new(0, 0, 0.65, 0)
bintaraStatus.BackgroundTransparency = 1
bintaraStatus.Text = "Status: Standby"
bintaraStatus.TextColor3 = Color3.fromRGB(200, 200, 190)
bintaraStatus.Font = Enum.Font.SourceSansItalic
bintaraStatus.TextSize = 14
bintaraStatus.Parent = bintaraPage

local rintanganBintara = {
	{Name = "Rintangan 1", CF = CFrame.new(-278.81, 47.34, 1380.54)},
	{Name = "Rintangan 2", CF = CFrame.new(-265.27, 58.97, 1289.62)},
	{Name = "Rintangan 3", CF = CFrame.new(-217.13, 59.03, 1176.88)},
	{Name = "Rintangan 4", CF = CFrame.new(-139.39, 49.36, 1222.98)},
	{Name = "Rintangan 5", CF = CFrame.new(-219.59, 47.12, 1356.65)},
	{Name = "Rintangan 6", CF = CFrame.new(-219.09, 72.10, 1253.52)},
	{Name = "Rintangan 7", CF = CFrame.new(-221.24, 111.79, 1236.25)}
}

local isBintaraRunning = false
bintaraPlay.MouseButton1Click:Connect(function()
	if isBintaraRunning then return end
	isBintaraRunning = true
	bintaraStatus.TextColor3 = Color3.fromRGB(100, 240, 120)
	task.spawn(function()
		while isBintaraRunning do
			for _, rintangan in ipairs(rintanganBintara) do
				if not isBintaraRunning then break end
				bintaraStatus.Text = "Meluncur ke: " .. rintangan.Name
				pcall(function()
				safeTweenTeleport(rintangan.CF, OBBY_CONFIG.Bintara.TweenSpeed)
			end)
			task.wait(OBBY_CONFIG.Bintara.StepDelay)
		end
		task.wait(OBBY_CONFIG.Bintara.LoopDelay)
		end
	end)
end)
bintaraStop.MouseButton1Click:Connect(function()
	isBintaraRunning = false
	bintaraStatus.Text = "Status: Dihentikan"
	bintaraStatus.TextColor3 = Color3.fromRGB(240, 100, 90)
end)

----------------------------------------------------
-- [ KONTEN 6: HALAMAN OBBY PAMA ]
----------------------------------------------------
local pamaPage = Instance.new("Frame")
pamaPage.Size = UDim2.new(1, 0, 1, 0)
pamaPage.BackgroundTransparency = 1
pamaPage.Visible = false
pamaPage.Parent = contentFrame

local pamaInfo = Instance.new("TextLabel")
pamaInfo.Size = UDim2.new(1, 0, 0, 50)
pamaInfo.Position = UDim2.new(0, 0, 0.05, 0)
pamaInfo.BackgroundColor3 = Color3.fromRGB(30, 38, 28)
pamaInfo.BackgroundTransparency = 0.2
pamaInfo.Text = "Obby Pama Safe Glide (Anti-Cheat Bypass)"
pamaInfo.TextColor3 = Color3.fromRGB(210, 160, 230)
pamaInfo.Font = Enum.Font.SourceSansBold
pamaInfo.TextSize = 14
pamaInfo.Parent = pamaPage
Instance.new("UICorner", pamaInfo).CornerRadius = UDim.new(0, 6)

local pamaInfoStroke = Instance.new("UIStroke")
pamaInfoStroke.Thickness = 1.2
pamaInfoStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
pamaInfoStroke.Parent = pamaInfo
table.insert(rgbObjects, pamaInfoStroke)

local pamaPlay = Instance.new("TextButton")
pamaPlay.Size = UDim2.new(0.47, 0, 0, 45)
pamaPlay.Position = UDim2.new(0, 0, 0.35, 0)
pamaPlay.BackgroundColor3 = Color3.fromRGB(50, 150, 80)
pamaPlay.Text = "START OBBY"
pamaPlay.TextColor3 = Color3.fromRGB(255, 255, 255)
pamaPlay.Font = Enum.Font.SourceSansBold
pamaPlay.TextSize = 15
pamaPlay.Parent = pamaPage
Instance.new("UICorner", pamaPlay).CornerRadius = UDim.new(0, 8)

local pamaPlayStroke = Instance.new("UIStroke")
pamaPlayStroke.Thickness = 1.2
pamaPlayStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
pamaPlayStroke.Parent = pamaPlay
table.insert(rgbObjects, pamaPlayStroke)

local pamaStop = Instance.new("TextButton")
pamaStop.Size = UDim2.new(0.47, 0, 0, 45)
pamaStop.Position = UDim2.new(0.53, 0, 0.35, 0)
pamaStop.BackgroundColor3 = Color3.fromRGB(180, 60, 50)
pamaStop.Text = "STOP OBBY"
pamaStop.TextColor3 = Color3.fromRGB(255, 255, 255)
pamaStop.Font = Enum.Font.SourceSansBold
pamaStop.TextSize = 15
pamaStop.Parent = pamaPage
Instance.new("UICorner", pamaStop).CornerRadius = UDim.new(0, 8)

local pamaStopStroke = Instance.new("UIStroke")
pamaStopStroke.Thickness = 1.2
pamaStopStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
pamaStopStroke.Parent = pamaStop
table.insert(rgbObjects, pamaStopStroke)

local pamaStatus = Instance.new("TextLabel")
pamaStatus.Size = UDim2.new(1, 0, 0, 40)
pamaStatus.Position = UDim2.new(0, 0, 0.65, 0)
pamaStatus.BackgroundTransparency = 1
pamaStatus.Text = "Status: Standby"
pamaStatus.TextColor3 = Color3.fromRGB(200, 200, 190)
pamaStatus.Font = Enum.Font.SourceSansItalic
pamaStatus.TextSize = 14
pamaStatus.Parent = pamaPage

local rintanganPama = {
	{Name = "Rintangan 1", CF = CFrame.new(-9.33, 47.34, 1678.50)},
	{Name = "Rintangan 2", CF = CFrame.new(82.49, 58.97, 1689.52)},
	{Name = "Rintangan 3", CF = CFrame.new(199.40, 58.97, 1716.12)},
	{Name = "Rintangan 4", CF = CFrame.new(182.78, 59.03, 1815.73)},
	{Name = "Rintangan 5", CF = CFrame.new(26.65, 47.12, 1806.97)},
	{Name = "Rintangan 6", CF = CFrame.new(122.29, 47.12, 1743.63)},
	{Name = "Rintangan 7", CF = CFrame.new(139.14, 104.32, 1735.80)},
	{Name = "Rintangan 8", CF = CFrame.new(160.77, 145.40, 1746.83)}
}

local isPamaRunning = false
pamaPlay.MouseButton1Click:Connect(function()
	if isPamaRunning then return end
	isPamaRunning = true
	pamaStatus.TextColor3 = Color3.fromRGB(100, 240, 120)
	task.spawn(function()
		while isPamaRunning do
			for _, rintangan in ipairs(rintanganPama) do
				if not isPamaRunning then break end
				pamaStatus.Text = "Meluncur ke: " .. rintangan.Name
				pcall(function()
				safeTweenTeleport(rintangan.CF, OBBY_CONFIG.Pama.TweenSpeed)
			end)
			task.wait(OBBY_CONFIG.Pama.StepDelay)
		end
		task.wait(OBBY_CONFIG.Pama.LoopDelay)
		end
	end)
end)
pamaStop.MouseButton1Click:Connect(function()
	isPamaRunning = false
	pamaStatus.Text = "Status: Dihentikan"
	pamaStatus.TextColor3 = Color3.fromRGB(240, 100, 90)
end)


-- [[ TOMBOL TOGGLE HIDE/SHOW ]]
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 130, 0, 40)
toggleButton.Position = UDim2.new(1, -145, 0, 15) 
toggleButton.BackgroundColor3 = Color3.fromRGB(35, 43, 32)
toggleButton.BackgroundTransparency = 0.2
toggleButton.Text = "Sembunyikan UI"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 14
toggleButton.ZIndex = 10
toggleButton.Parent = screenGui

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Thickness = 1.5
toggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
toggleStroke.Parent = toggleButton
table.insert(rgbObjects, toggleStroke)

-- Simpan kolom input game terakhir yang pernah difokuskan.
-- TextBox milik GUI script sendiri sengaja diabaikan.
UserInputService.TextBoxFocused:Connect(function(textBox)
	if isValidGameTextBox(textBox, screenGui) then
		lastGameTextBox = textBox
	end
end)

-- [[ LOGIKA AUTO KATA ]]
local AUTO_KATA_DELAY = 1
local AUTO_KATA_MAX = 10000
local isAngkaRunning = false
local autoKataSession = 0

local function startAutoAngka()
	if isAngkaRunning then return end

	local targetTextBox = UserInputService:GetFocusedTextBox()
	if not isValidGameTextBox(targetTextBox, screenGui) then
		targetTextBox = lastGameTextBox
	end

	if not isValidGameTextBox(targetTextBox, screenGui) then
		statusLabel.Text = "Status: Klik kolom input game terlebih dahulu"
		statusLabel.TextColor3 = Color3.fromRGB(240, 100, 90)
		inputTextBox.Text = "[Target input belum dipilih]"
		return
	end

	isAngkaRunning = true
	autoKataSession += 1
	local currentSession = autoKataSession

	statusLabel.Text = "Status: Auto Kata dimulai..."
	statusLabel.TextColor3 = Color3.fromRGB(100, 240, 120)

	task.spawn(function()
		for i = 1, AUTO_KATA_MAX do
			if not isAngkaRunning or currentSession ~= autoKataSession then
				return
			end

			if not isValidGameTextBox(targetTextBox, screenGui) then
				isAngkaRunning = false
				statusLabel.Text = "Status: Kolom input game tidak tersedia"
				statusLabel.TextColor3 = Color3.fromRGB(240, 100, 90)
				inputTextBox.Text = "[Target input hilang]"
				return
			end

			local finalSpellingText = getNumberSpelling(i)
			inputTextBox.Text = finalSpellingText
			statusLabel.Text = string.format("Status: Mengirim %d/%d", i, AUTO_KATA_MAX)

			local success = sendToTargetTextBox(targetTextBox, finalSpellingText)
			if not success then
				isAngkaRunning = false
				statusLabel.Text = "Status: Gagal mengirim kata"
				statusLabel.TextColor3 = Color3.fromRGB(240, 100, 90)
				return
			end

			task.wait(AUTO_KATA_DELAY)
		end

		if currentSession == autoKataSession then
			isAngkaRunning = false
			statusLabel.Text = "Status: Auto Kata selesai (1-10000)!"
			statusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
		end
	end)
end

local function stopAutoAngka()
	isAngkaRunning = false
	autoKataSession += 1
	statusLabel.Text = "Status: Berhenti"
	statusLabel.TextColor3 = Color3.fromRGB(240, 100, 90)
	inputTextBox.Text = "[Dihentikan]"
end

playButton.MouseButton1Click:Connect(startAutoAngka)
stopButton.MouseButton1Click:Connect(stopAutoAngka)


-- [[ NAVIGASI 4 HALAMAN ]]
local function clearAllPages()
	angkaPage.Visible = false
	tamtamaPage.Visible = false
	bintaraPage.Visible = false
	pamaPage.Visible = false

	angkaTabBtn.BackgroundColor3 = Color3.fromRGB(35, 43, 32)
	angkaTabBtn.TextColor3 = Color3.fromRGB(200, 205, 195)
	tamtamaTabBtn.BackgroundColor3 = Color3.fromRGB(35, 43, 32)
	tamtamaTabBtn.TextColor3 = Color3.fromRGB(200, 205, 195)
	bintaraTabBtn.BackgroundColor3 = Color3.fromRGB(35, 43, 32)
	bintaraTabBtn.TextColor3 = Color3.fromRGB(200, 205, 195)
	pamaTabBtn.BackgroundColor3 = Color3.fromRGB(35, 43, 32)
	pamaTabBtn.TextColor3 = Color3.fromRGB(200, 205, 195)
end

local function activateTab(page, button)
	clearAllPages()
	page.Visible = true
	button.BackgroundColor3 = Color3.fromRGB(70, 90, 65)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
end

angkaTabBtn.MouseButton1Click:Connect(function()
	activateTab(angkaPage, angkaTabBtn)
end)

tamtamaTabBtn.MouseButton1Click:Connect(function()
	activateTab(tamtamaPage, tamtamaTabBtn)
end)

bintaraTabBtn.MouseButton1Click:Connect(function()
	activateTab(bintaraPage, bintaraTabBtn)
end)

pamaTabBtn.MouseButton1Click:Connect(function()
	activateTab(pamaPage, pamaTabBtn)
end)

local function toggleGuiVisibility()
	if mainFrame.Visible then
		mainFrame.Visible = false
		toggleButton.Text = "Tampilkan UI"
		toggleButton.BackgroundColor3 = Color3.fromRGB(70, 90, 65)
	else
		mainFrame.Visible = true
		toggleButton.Text = "Sembunyikan UI"
		toggleButton.BackgroundColor3 = Color3.fromRGB(35, 43, 32)
	end
end
toggleButton.MouseButton1Click:Connect(toggleGuiVisibility)

-- [[ ENGINE LOOP UTAMA EFEK RGB CHROMA PELANGI ]]
RunService.RenderStepped:Connect(function()
	local totalObjects = #rgbObjects
	for idx, strokeObject in ipairs(rgbObjects) do
		if strokeObject and strokeObject.Parent then
			local hueShift = (tick() * 0.15) + (idx / totalObjects * 0.5)
			strokeObject.Color = Color3.fromHSV(hueShift % 1, 0.85, 1)
		end
	end
end)
