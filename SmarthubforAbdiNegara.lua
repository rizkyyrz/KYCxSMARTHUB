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
	if num == 1000 then return "one thousand" end
	if num < 100 then
		return getUnder100(num)
	else
		local hundredDigit = math.floor(num / 100)
		local remainder = num % 100
		local hundredText = ones[hundredDigit] .. " hundred"
		if remainder == 0 then
			return hundredText
		else
			return hundredText .. " " .. getUnder100(remainder)
		end
	end
end

-- [[ INTERFACE WITH ROBLOX CHAT & TARGET GAME UI ]]
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function sendToFocusedTextBox(message)
	local focusedTextBox = UserInputService:GetFocusedTextBox()
	if focusedTextBox then
		pcall(function()
			focusedTextBox.Text = message
			task.wait(0.05)
			focusedTextBox:ReleaseFocus(true) 
		end)
	else
		print("[Smarthub SYSTEM]: Klik dulu kolom input game sebelum memulai.")
	end
end

local function sendToPublicChat(message)
	pcall(function()
		if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
			local targetChannel = TextChatService:FindFirstChild("RBXGeneral", true) or TextChatService:FindFirstChild("RBXSystem", true)
			if targetChannel and targetChannel:IsA("TextChannel") then
				targetChannel:SendAsync(message)
				return
			end
		end
		local sayMessageRequest = ReplicatedStorage:FindFirstChild("SayMessageRequest", true)
		if sayMessageRequest and sayMessageRequest:IsA("RemoteEvent") then
			sayMessageRequest:FireServer(message, "All")
		end
	end)
end

-- [[ INTERFACE / GUI CREATION (ARMY THEME VERTIKAL & TRANSPARANT) ]]
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SmarthubMultiSystemGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 580, 0, 400)
mainFrame.Position = UDim2.new(0.5, -290, 0.4, -200)
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
titleLabel.Text = "SMARTHUB MULTI SYSTEM UI v13.0"
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
	btn.Size = UDim2.new(1, 0, 0, 34)
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

local angkaTabBtn    = makeTabBtn("Auto Angka",    1, true)
local latihanTabBtn  = makeTabBtn("Latihan",       2, false)
local expTabBtn      = makeTabBtn("Auto EXP",      3, false)
local tamtamaTabBtn  = makeTabBtn("Obby Tamtama",  4, false)
local bintaraTabBtn  = makeTabBtn("Obby Bintara",  5, false)
local pamaTabBtn     = makeTabBtn("Obby Pama",     6, false)
local espTabBtn      = makeTabBtn("ESP Player",    7, false)
local playerTabBtn   = makeTabBtn("Fitur Player",  8, false)

-- [[ TATA LETAK VERTIKAL: KANAN KONTEN ]]
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(0.66, 0, 0.85, 0)
contentFrame.Position = UDim2.new(0.32, 0, 0.12, 0)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

----------------------------------------------------
-- [ KONTEN 1: HALAMAN OTOMATISASI ANGKA ]
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
-- [ KONTEN 2: HALAMAN OTOMATISASI LATIHAN ]
----------------------------------------------------
local latihanPage = Instance.new("Frame")
latihanPage.Size = UDim2.new(1, 0, 1, 0)
latihanPage.BackgroundTransparency = 1
latihanPage.Visible = false
latihanPage.Parent = contentFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = latihanPage

local function createLatihanRow(name, startText, stopText, order)
	local rowFrame = Instance.new("Frame")
	rowFrame.Size = UDim2.new(1, 0, 0, 44)
	rowFrame.BackgroundTransparency = 1
	rowFrame.LayoutOrder = order
	rowFrame.Parent = latihanPage
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.24, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.fromRGB(240, 245, 235)
	label.Font = Enum.Font.SourceSansBold
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = rowFrame
	
	local startBtn = Instance.new("TextButton")
	startBtn.Size = UDim2.new(0.35, 0, 0.8, 0)
	startBtn.Position = UDim2.new(0.27, 0, 0.1, 0)
	startBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 80)
	startBtn.Text = "Latihan"
	startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	startBtn.Font = Enum.Font.SourceSansBold
	startBtn.TextSize = 13
	startBtn.Parent = rowFrame
	Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 6)
	
	local rowStroke1 = Instance.new("UIStroke")
	rowStroke1.Thickness = 1.2
	rowStroke1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	rowStroke1.Parent = startBtn
	table.insert(rgbObjects, rowStroke1)
	
	local stopBtn = Instance.new("TextButton")
	stopBtn.Size = UDim2.new(0.35, 0, 0.8, 0)
	stopBtn.Position = UDim2.new(0.65, 0, 0.1, 0)
	stopBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 50)
	stopBtn.Text = "Berhenti"
	stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	stopBtn.Font = Enum.Font.SourceSansBold
	stopBtn.TextSize = 13
	stopBtn.Parent = rowFrame
	Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 6)
	
	local rowStroke2 = Instance.new("UIStroke")
	rowStroke2.Thickness = 1.2
	rowStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	rowStroke2.Parent = stopBtn
	table.insert(rgbObjects, rowStroke2)
	
	startBtn.MouseButton1Click:Connect(function() task.spawn(function() sendToPublicChat(startText) end) end)
	stopBtn.MouseButton1Click:Connect(function() task.spawn(function() sendToPublicChat(stopText) end) end)
end

createLatihanRow("PUSHUP", "siap sikap pushup", "siap pushup selesai", 1)
createLatihanRow("SITUP",  "siap sikap situp",  "siap situp selesai",  2)
createLatihanRow("PULLUP", "siap sikap pullup", "siap pullup selesai", 3)
createLatihanRow("JJS",    "siap sikap jjs",    "siap jjs selesai",    4)

----------------------------------------------------
-- [ KONTEN 3: HALAMAN AUTO EXP ]
----------------------------------------------------
local expPage = Instance.new("Frame")
expPage.Size = UDim2.new(1, 0, 1, 0)
expPage.BackgroundTransparency = 1
expPage.Visible = false
expPage.Parent = contentFrame

local targetInputBox = Instance.new("TextBox")
targetInputBox.Size = UDim2.new(1, 0, 0, 45)
targetInputBox.Position = UDim2.new(0, 0, 0.05, 0)
targetInputBox.BackgroundColor3 = Color3.fromRGB(30, 38, 28)
targetInputBox.BackgroundTransparency = 0.2
targetInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
targetInputBox.Font = Enum.Font.SourceSansBold
targetInputBox.TextSize = 15
targetInputBox.Text = "100"
targetInputBox.PlaceholderText = " Masukkan Target EXP %"
targetInputBox.Parent = expPage
Instance.new("UICorner", targetInputBox).CornerRadius = UDim.new(0, 6)

local expInputStroke = Instance.new("UIStroke")
expInputStroke.Thickness = 1.2
expInputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
expInputStroke.Parent = targetInputBox
table.insert(rgbObjects, expInputStroke)

local expPlayBtn = Instance.new("TextButton")
expPlayBtn.Size = UDim2.new(0.47, 0, 0, 45)
expPlayBtn.Position = UDim2.new(0, 0, 0.35, 0)
expPlayBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 80)
expPlayBtn.Text = "START EXP"
expPlayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
expPlayBtn.Font = Enum.Font.SourceSansBold
expPlayBtn.TextSize = 15
expPlayBtn.Parent = expPage
Instance.new("UICorner", expPlayBtn).CornerRadius = UDim.new(0, 8)

local expPlayStroke = Instance.new("UIStroke")
expPlayStroke.Thickness = 1.2
expPlayStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
expPlayStroke.Parent = expPlayBtn
table.insert(rgbObjects, expPlayStroke)

local expStopBtn = Instance.new("TextButton")
expStopBtn.Size = UDim2.new(0.47, 0, 0, 45)
expStopBtn.Position = UDim2.new(0.53, 0, 0.35, 0)
expStopBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 50)
expStopBtn.Text = "STOP EXP"
expStopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
expStopBtn.Font = Enum.Font.SourceSansBold
expStopBtn.TextSize = 15
expStopBtn.Parent = expPage
Instance.new("UICorner", expStopBtn).CornerRadius = UDim.new(0, 8)

local expStopStroke = Instance.new("UIStroke")
expStopStroke.Thickness = 1.2
expStopStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
expStopStroke.Parent = expStopBtn
table.insert(rgbObjects, expStopStroke)

local expStatusLabel = Instance.new("TextLabel")
expStatusLabel.Size = UDim2.new(1, 0, 0, 50)
expStatusLabel.Position = UDim2.new(0, 0, 0.65, 0)
expStatusLabel.BackgroundTransparency = 1
expStatusLabel.Text = "Status EXP: Idle (Menunggu)"
expStatusLabel.TextColor3 = Color3.fromRGB(200, 205, 195)
expStatusLabel.Font = Enum.Font.SourceSansItalic
expStatusLabel.TextSize = 14
expStatusLabel.Parent = expPage

local isExpRunning = false

local function fireGameRemotes()
	for _, object in pairs(ReplicatedStorage:GetDescendants()) do
		if object:IsA("RemoteEvent") then
			local name = string.lower(object.Name)
			if string.find(name, "pushup") or string.find(name, "situp") or string.find(name, "pullup") or string.find(name, "jjs") or string.find(name, "exercise") or string.find(name, "train") or string.find(name, "exp") then
				pcall(function()
					object:FireServer()
					object:FireServer(true)
					object:FireServer("Start")
					object:FireServer("Complete")
				end)
			end
		end
	end
end

local function startExpLoop()
	if isExpRunning then return end
	isExpRunning = true
	local targetPercent = tonumber(targetInputBox.Text) or 100
	expStatusLabel.TextColor3 = Color3.fromRGB(100, 240, 120)
	
	task.spawn(function()
		while isExpRunning do
			expStatusLabel.Text = "Mengejar Target EXP: " .. targetPercent .. "%"
			fireGameRemotes()
			sendToPublicChat("siap sikap pushup")
			task.wait(0.5)
			sendToPublicChat("siap pushup selesai")
			task.wait(0.5)
		end
	end)
end

expPlayBtn.MouseButton1Click:Connect(startExpLoop)
expStopBtn.MouseButton1Click:Connect(function()
	isExpRunning = false
	expStatusLabel.Text = "Status EXP: Dihentikan"
	expStatusLabel.TextColor3 = Color3.fromRGB(240, 100, 90)
end)

-- [[ LOGIKA GLOBAL TWEEN TELEPORT BYPASS - SUPER CEPAT 700 ]]
local function safeTweenTeleport(targetCFrame)
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	local currentPos = hrp.Position
	local distance = (currentPos - targetCFrame.Position).Magnitude
	local duration = math.clamp(distance / 700, 0.03, 0.15)  -- ⚡ SUPER CEPAT
	
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
	
	tween:Play()
	tween.Completed:Wait()
end

----------------------------------------------------
-- [ KONTEN 4: HALAMAN OBBY TAMTAMA + SKIP TO END ]
----------------------------------------------------
local tamtamaPage = Instance.new("Frame")
tamtamaPage.Size = UDim2.new(1, 0, 1, 0)
tamtamaPage.BackgroundTransparency = 1
tamtamaPage.Visible = false
tamtamaPage.Parent = contentFrame

local tamtamaInfo = Instance.new("TextLabel")
tamtamaInfo.Size = UDim2.new(1, 0, 0, 40)
tamtamaInfo.Position = UDim2.new(0, 0, 0.02, 0)
tamtamaInfo.BackgroundColor3 = Color3.fromRGB(30, 38, 28)
tamtamaInfo.BackgroundTransparency = 0.2
tamtamaInfo.Text = "Obby Tamtama | Loop biasa atau Skip ke Akhir"
tamtamaInfo.TextColor3 = Color3.fromRGB(230, 200, 50)
tamtamaInfo.Font = Enum.Font.SourceSansBold
tamtamaInfo.TextSize = 13
tamtamaInfo.Parent = tamtamaPage
Instance.new("UICorner", tamtamaInfo).CornerRadius = UDim.new(0, 6)

local tamtamaInfoStroke = Instance.new("UIStroke")
tamtamaInfoStroke.Thickness = 1.2
tamtamaInfoStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
tamtamaInfoStroke.Parent = tamtamaInfo
table.insert(rgbObjects, tamtamaInfoStroke)

local tamtamaPlay = Instance.new("TextButton")
tamtamaPlay.Size = UDim2.new(0.45, 0, 0, 40)
tamtamaPlay.Position = UDim2.new(0.02, 0, 0.22, 0)
tamtamaPlay.BackgroundColor3 = Color3.fromRGB(50, 150, 80)
tamtamaPlay.Text = "LOOP OBBY"
tamtamaPlay.TextColor3 = Color3.fromRGB(255, 255, 255)
tamtamaPlay.Font = Enum.Font.SourceSansBold
tamtamaPlay.TextSize = 13
tamtamaPlay.Parent = tamtamaPage
Instance.new("UICorner", tamtamaPlay).CornerRadius = UDim.new(0, 6)

local tamtamaPlayStroke = Instance.new("UIStroke")
tamtamaPlayStroke.Thickness = 1.2
tamtamaPlayStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
tamtamaPlayStroke.Parent = tamtamaPlay
table.insert(rgbObjects, tamtamaPlayStroke)

local tamtamaStop = Instance.new("TextButton")
tamtamaStop.Size = UDim2.new(0.45, 0, 0, 40)
tamtamaStop.Position = UDim2.new(0.53, 0, 0.22, 0)
tamtamaStop.BackgroundColor3 = Color3.fromRGB(180, 60, 50)
tamtamaStop.Text = "STOP"
tamtamaStop.TextColor3 = Color3.fromRGB(255, 255, 255)
tamtamaStop.Font = Enum.Font.SourceSansBold
tamtamaStop.TextSize = 13
tamtamaStop.Parent = tamtamaPage
Instance.new("UICorner", tamtamaStop).CornerRadius = UDim.new(0, 6)

local tamtamaStopStroke = Instance.new("UIStroke")
tamtamaStopStroke.Thickness = 1.2
tamtamaStopStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
tamtamaStopStroke.Parent = tamtamaStop
table.insert(rgbObjects, tamtamaStopStroke)

local tamtamaSkip = Instance.new("TextButton")
tamtamaSkip.Size = UDim2.new(1, -8, 0, 40)
tamtamaSkip.Position = UDim2.new(0.02, 0, 0.45, 0)
tamtamaSkip.BackgroundColor3 = Color3.fromRGB(220, 180, 20)
tamtamaSkip.Text = "SKIP KE AKHIR (5s Progress)"
tamtamaSkip.TextColor3 = Color3.fromRGB(255, 255, 255)
tamtamaSkip.Font = Enum.Font.SourceSansBold
tamtamaSkip.TextSize = 14
tamtamaSkip.Parent = tamtamaPage
Instance.new("UICorner", tamtamaSkip).CornerRadius = UDim.new(0, 6)

local tamtamaSkipStroke = Instance.new("UIStroke")
tamtamaSkipStroke.Thickness = 1.2
tamtamaSkipStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
tamtamaSkipStroke.Parent = tamtamaSkip
table.insert(rgbObjects, tamtamaSkipStroke)

local tamtamaStatus = Instance.new("TextLabel")
tamtamaStatus.Size = UDim2.new(1, 0, 0, 35)
tamtamaStatus.Position = UDim2.new(0, 0, 0.72, 0)
tamtamaStatus.BackgroundTransparency = 1
tamtamaStatus.Text = "Status: Standby"
tamtamaStatus.TextColor3 = Color3.fromRGB(200, 200, 190)
tamtamaStatus.Font = Enum.Font.SourceSansItalic
tamtamaStatus.TextSize = 13
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
				pcall(function() safeTweenTeleport(rintangan.CF) end)
				task.wait(4.5)
			end
			task.wait(2)
		end
	end)
end)
tamtamaStop.MouseButton1Click:Connect(function()
	isTamtamaRunning = false
	tamtamaStatus.Text = "Status: Dihentikan"
	tamtamaStatus.TextColor3 = Color3.fromRGB(240, 100, 90)
end)

-- Fungsi SKIP KE AKHIR (fake progress)
tamtamaSkip.MouseButton1Click:Connect(function()
	isTamtamaRunning = false
	tamtamaStatus.TextColor3 = Color3.fromRGB(255, 215, 0)
	local finish = rintanganTamtama[6]
	task.spawn(function()
		for i = 1, 5 do
			tamtamaStatus.Text = "Memproses skip... " .. i .. "/5"
			sendToPublicChat("siap sikap pushup")
			task.wait(0.6)
			sendToPublicChat("siap pushup selesai")
			task.wait(0.4)
		end
		tamtamaStatus.Text = "Teleport ke AKHIR..."
		pcall(function() safeTweenTeleport(finish.CF) end)
		tamtamaStatus.Text = "Status: Sampai di AKHIR!"
		tamtamaStatus.TextColor3 = Color3.fromRGB(100, 240, 120)
	end)
end)

----------------------------------------------------
-- [ KONTEN 5: HALAMAN OBBY BINTARA + SKIP TO END ]
----------------------------------------------------
local bintaraPage = Instance.new("Frame")
bintaraPage.Size = UDim2.new(1, 0, 1, 0)
bintaraPage.BackgroundTransparency = 1
bintaraPage.Visible = false
bintaraPage.Parent = contentFrame

local bintaraInfo = Instance.new("TextLabel")
bintaraInfo.Size = UDim2.new(1, 0, 0, 40)
bintaraInfo.Position = UDim2.new(0, 0, 0.02, 0)
bintaraInfo.BackgroundColor3 = Color3.fromRGB(30, 38, 28)
bintaraInfo.BackgroundTransparency = 0.2
bintaraInfo.Text = "Obby Bintara | Loop biasa atau Skip ke Akhir"
bintaraInfo.TextColor3 = Color3.fromRGB(46, 204, 113)
bintaraInfo.Font = Enum.Font.SourceSansBold
bintaraInfo.TextSize = 13
bintaraInfo.Parent = bintaraPage
Instance.new("UICorner", bintaraInfo).CornerRadius = UDim.new(0, 6)

local bintaraInfoStroke = Instance.new("UIStroke")
bintaraInfoStroke.Thickness = 1.2
bintaraInfoStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
bintaraInfoStroke.Parent = bintaraInfo
table.insert(rgbObjects, bintaraInfoStroke)

local bintaraPlay = Instance.new("TextButton")
bintaraPlay.Size = UDim2.new(0.45, 0, 0, 40)
bintaraPlay.Position = UDim2.new(0.02, 0, 0.22, 0)
bintaraPlay.BackgroundColor3 = Color3.fromRGB(50, 150, 80)
bintaraPlay.Text = "LOOP OBBY"
bintaraPlay.TextColor3 = Color3.fromRGB(255, 255, 255)
bintaraPlay.Font = Enum.Font.SourceSansBold
bintaraPlay.TextSize = 13
bintaraPlay.Parent = bintaraPage
Instance.new("UICorner", bintaraPlay).CornerRadius = UDim.new(0, 6)

local bintaraPlayStroke = Instance.new("UIStroke")
bintaraPlayStroke.Thickness = 1.2
bintaraPlayStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
bintaraPlayStroke.Parent = bintaraPlay
table.insert(rgbObjects, bintaraPlayStroke)

local bintaraStop = Instance.new("TextButton")
bintaraStop.Size = UDim2.new(0.45, 0, 0, 40)
bintaraStop.Position = UDim2.new(0.53, 0, 0.22, 0)
bintaraStop.BackgroundColor3 = Color3.fromRGB(180, 60, 50)
bintaraStop.Text = "STOP"
bintaraStop.TextColor3 = Color3.fromRGB(255, 255, 255)
bintaraStop.Font = Enum.Font.SourceSansBold
bintaraStop.TextSize = 13
bintaraStop.Parent = bintaraPage
Instance.new("UICorner", bintaraStop).CornerRadius = UDim.new(0, 6)

local bintaraStopStroke = Instance.new("UIStroke")
bintaraStopStroke.Thickness = 1.2
bintaraStopStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
bintaraStopStroke.Parent = bintaraStop
table.insert(rgbObjects, bintaraStopStroke)

local bintaraSkip = Instance.new("TextButton")
bintaraSkip.Size = UDim2.new(1, -8, 0, 40)
bintaraSkip.Position = UDim2.new(0.02, 0, 0.45, 0)
bintaraSkip.BackgroundColor3 = Color3.fromRGB(220, 180, 20)
bintaraSkip.Text = "SKIP KE AKHIR (5s Progress)"
bintaraSkip.TextColor3 = Color3.fromRGB(255, 255, 255)
bintaraSkip.Font = Enum.Font.SourceSansBold
bintaraSkip.TextSize = 14
bintaraSkip.Parent = bintaraPage
Instance.new("UICorner", bintaraSkip).CornerRadius = UDim.new(0, 6)

local bintaraSkipStroke = Instance.new("UIStroke")
bintaraSkipStroke.Thickness = 1.2
bintaraSkipStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
bintaraSkipStroke.Parent = bintaraSkip
table.insert(rgbObjects, bintaraSkipStroke)

local bintaraStatus = Instance.new("TextLabel")
bintaraStatus.Size = UDim2.new(1, 0, 0, 35)
bintaraStatus.Position = UDim2.new(0, 0, 0.72, 0)
bintaraStatus.BackgroundTransparency = 1
bintaraStatus.Text = "Status: Standby"
bintaraStatus.TextColor3 = Color3.fromRGB(200, 200, 190)
bintaraStatus.Font = Enum.Font.SourceSansItalic
bintaraStatus.TextSize = 13
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
				pcall(function() safeTweenTeleport(rintangan.CF) end)
				task.wait(4.5)
			end
			task.wait(2)
		end
	end)
end)
bintaraStop.MouseButton1Click:Connect(function()
	isBintaraRunning = false
	bintaraStatus.Text = "Status: Dihentikan"
	bintaraStatus.TextColor3 = Color3.fromRGB(240, 100, 90)
end)

bintaraSkip.MouseButton1Click:Connect(function()
	isBintaraRunning = false
	bintaraStatus.TextColor3 = Color3.fromRGB(255, 215, 0)
	local finish = rintanganBintara[7]
	task.spawn(function()
		for i = 1, 5 do
			bintaraStatus.Text = "Memproses skip... " .. i .. "/5"
			sendToPublicChat("siap sikap pushup")
			task.wait(0.6)
			sendToPublicChat("siap pushup selesai")
			task.wait(0.4)
		end
		bintaraStatus.Text = "Teleport ke AKHIR..."
		pcall(function() safeTweenTeleport(finish.CF) end)
		bintaraStatus.Text = "Status: Sampai di AKHIR!"
		bintaraStatus.TextColor3 = Color3.fromRGB(100, 240, 120)
	end)
end)

----------------------------------------------------
-- [ KONTEN 6: HALAMAN OBBY PAMA + SKIP TO END ]
----------------------------------------------------
local pamaPage = Instance.new("Frame")
pamaPage.Size = UDim2.new(1, 0, 1, 0)
pamaPage.BackgroundTransparency = 1
pamaPage.Visible = false
pamaPage.Parent = contentFrame

local pamaInfo = Instance.new("TextLabel")
pamaInfo.Size = UDim2.new(1, 0, 0, 40)
pamaInfo.Position = UDim2.new(0, 0, 0.02, 0)
pamaInfo.BackgroundColor3 = Color3.fromRGB(30, 38, 28)
pamaInfo.BackgroundTransparency = 0.2
pamaInfo.Text = "Obby Pama | Loop biasa atau Skip ke Akhir"
pamaInfo.TextColor3 = Color3.fromRGB(210, 160, 230)
pamaInfo.Font = Enum.Font.SourceSansBold
pamaInfo.TextSize = 13
pamaInfo.Parent = pamaPage
Instance.new("UICorner", pamaInfo).CornerRadius = UDim.new(0, 6)

local pamaInfoStroke = Instance.new("UIStroke")
pamaInfoStroke.Thickness = 1.2
pamaInfoStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
pamaInfoStroke.Parent = pamaInfo
table.insert(rgbObjects, pamaInfoStroke)

local pamaPlay = Instance.new("TextButton")
pamaPlay.Size = UDim2.new(0.45, 0, 0, 40)
pamaPlay.Position = UDim2.new(0.02, 0, 0.22, 0)
pamaPlay.BackgroundColor3 = Color3.fromRGB(50, 150, 80)
pamaPlay.Text = "LOOP OBBY"
pamaPlay.TextColor3 = Color3.fromRGB(255, 255, 255)
pamaPlay.Font = Enum.Font.SourceSansBold
pamaPlay.TextSize = 13
pamaPlay.Parent = pamaPage
Instance.new("UICorner", pamaPlay).CornerRadius = UDim.new(0, 6)

local pamaPlayStroke = Instance.new("UIStroke")
pamaPlayStroke.Thickness = 1.2
pamaPlayStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
pamaPlayStroke.Parent = pamaPlay
table.insert(rgbObjects, pamaPlayStroke)

local pamaStop = Instance.new("TextButton")
pamaStop.Size = UDim2.new(0.45, 0, 0, 40)
pamaStop.Position = UDim2.new(0.53, 0, 0.22, 0)
pamaStop.BackgroundColor3 = Color3.fromRGB(180, 60, 50)
pamaStop.Text = "STOP"
pamaStop.TextColor3 = Color3.fromRGB(255, 255, 255)
pamaStop.Font = Enum.Font.SourceSansBold
pamaStop.TextSize = 13
pamaStop.Parent = pamaPage
Instance.new("UICorner", pamaStop).CornerRadius = UDim.new(0, 6)

local pamaStopStroke = Instance.new("UIStroke")
pamaStopStroke.Thickness = 1.2
pamaStopStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
pamaStopStroke.Parent = pamaStop
table.insert(rgbObjects, pamaStopStroke)

local pamaSkip = Instance.new("TextButton")
pamaSkip.Size = UDim2.new(1, -8, 0, 40)
pamaSkip.Position = UDim2.new(0.02, 0, 0.45, 0)
pamaSkip.BackgroundColor3 = Color3.fromRGB(220, 180, 20)
pamaSkip.Text = "SKIP KE AKHIR (5s Progress)"
pamaSkip.TextColor3 = Color3.fromRGB(255, 255, 255)
pamaSkip.Font = Enum.Font.SourceSansBold
pamaSkip.TextSize = 14
pamaSkip.Parent = pamaPage
Instance.new("UICorner", pamaSkip).CornerRadius = UDim.new(0, 6)

local pamaSkipStroke = Instance.new("UIStroke")
pamaSkipStroke.Thickness = 1.2
pamaSkipStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
pamaSkipStroke.Parent = pamaSkip
table.insert(rgbObjects, pamaSkipStroke)

local pamaStatus = Instance.new("TextLabel")
pamaStatus.Size = UDim2.new(1, 0, 0, 35)
pamaStatus.Position = UDim2.new(0, 0, 0.72, 0)
pamaStatus.BackgroundTransparency = 1
pamaStatus.Text = "Status: Standby"
pamaStatus.TextColor3 = Color3.fromRGB(200, 200, 190)
pamaStatus.Font = Enum.Font.SourceSansItalic
pamaStatus.TextSize = 13
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
				pcall(function() safeTweenTeleport(rintangan.CF) end)
				task.wait(4.5)
			end
			task.wait(2)
		end
	end)
end)
pamaStop.MouseButton1Click:Connect(function()
	isPamaRunning = false
	pamaStatus.Text = "Status: Dihentikan"
	pamaStatus.TextColor3 = Color3.fromRGB(240, 100, 90)
end)

pamaSkip.MouseButton1Click:Connect(function()
	isPamaRunning = false
	pamaStatus.TextColor3 = Color3.fromRGB(255, 215, 0)
	local finish = rintanganPama[8]
	task.spawn(function()
		for i = 1, 5 do
			pamaStatus.Text = "Memproses skip... " .. i .. "/5"
			sendToPublicChat("siap sikap pushup")
			task.wait(0.6)
			sendToPublicChat("siap pushup selesai")
			task.wait(0.4)
		end
		pamaStatus.Text = "Teleport ke AKHIR..."
		pcall(function() safeTweenTeleport(finish.CF) end)
		pamaStatus.Text = "Status: Sampai di AKHIR!"
		pamaStatus.TextColor3 = Color3.fromRGB(100, 240, 120)
	end)
end)

----------------------------------------------------
-- [ KONTEN 7: HALAMAN ESP PLAYER (BARU) ]
----------------------------------------------------
local espPage = Instance.new("Frame")
espPage.Size = UDim2.new(1, 0, 1, 0)
espPage.BackgroundTransparency = 1
espPage.Visible = false
espPage.Parent = contentFrame

local espInfo = Instance.new("TextLabel")
espInfo.Size = UDim2.new(1, 0, 0, 50)
espInfo.Position = UDim2.new(0, 0, 0.05, 0)
espInfo.BackgroundColor3 = Color3.fromRGB(30, 38, 28)
espInfo.BackgroundTransparency = 0.2
espInfo.Text = "Extra Sensory Perception (Health & Distance Tracker)"
espInfo.TextColor3 = Color3.fromRGB(0, 255, 255)
espInfo.Font = Enum.Font.SourceSansBold
espInfo.TextSize = 13
espInfo.Parent = espPage
Instance.new("UICorner", espInfo).CornerRadius = UDim.new(0, 6)

local espInfoStroke = Instance.new("UIStroke")
espInfoStroke.Thickness = 1.2
espInfoStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
espInfoStroke.Parent = espInfo
table.insert(rgbObjects, espInfoStroke)

local espPlayBtn = Instance.new("TextButton")
espPlayBtn.Size = UDim2.new(0.47, 0, 0, 45)
espPlayBtn.Position = UDim2.new(0, 0, 0.35, 0)
espPlayBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 80)
espPlayBtn.Text = "ESP AKTIF (ON)"
espPlayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
espPlayBtn.Font = Enum.Font.SourceSansBold
espPlayBtn.TextSize = 15
espPlayBtn.Parent = espPage
Instance.new("UICorner", espPlayBtn).CornerRadius = UDim.new(0, 8)

local espPlayStroke = Instance.new("UIStroke")
espPlayStroke.Thickness = 1.2
espPlayStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
espPlayStroke.Parent = espPlayBtn
table.insert(rgbObjects, espPlayStroke)

local espStopBtn = Instance.new("TextButton")
espStopBtn.Size = UDim2.new(0.47, 0, 0, 45)
espStopBtn.Position = UDim2.new(0.53, 0, 0.35, 0)
espStopBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 50)
espStopBtn.Text = "ESP MATI (OFF)"
espStopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
espStopBtn.Font = Enum.Font.SourceSansBold
espStopBtn.TextSize = 15
espStopBtn.Parent = espPage
Instance.new("UICorner", espStopBtn).CornerRadius = UDim.new(0, 8)

local espStopStroke = Instance.new("UIStroke")
espStopStroke.Thickness = 1.2
espStopStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
espStopStroke.Parent = espStopBtn
table.insert(rgbObjects, espStopStroke)

local espStatusLabel = Instance.new("TextLabel")
espStatusLabel.Size = UDim2.new(1, 0, 0, 40)
espStatusLabel.Position = UDim2.new(0, 0, 0.65, 0)
espStatusLabel.BackgroundTransparency = 1
espStatusLabel.Text = "Status ESP: Nonaktif"
espStatusLabel.TextColor3 = Color3.fromRGB(200, 200, 190)
espStatusLabel.Font = Enum.Font.SourceSansItalic
espStatusLabel.TextSize = 14
espStatusLabel.Parent = espPage

local isEspActive = false
local currentBillboardGuis = {}

local function clearAllESP()
	for _, bGui in pairs(currentBillboardGuis) do
		if bGui then bGui:Destroy() end
	end
	currentBillboardGuis = {}
end

local function createESPForPlayer(targetPlayer)
	if targetPlayer == player then return end
	
	local function setupCharacterESP(character)
		local head = character:WaitForChild("Head", 5)
		local humanoid = character:WaitForChild("Humanoid", 5)
		if not head or not humanoid then return end
		
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "Smarthub_ESP_" .. targetPlayer.Name
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.AlwaysOnTop = true
		billboard.ExtentsOffset = Vector3.new(0, 2.5, 0)
		billboard.Adornee = head
		billboard.Parent = head
		table.insert(currentBillboardGuis, billboard)
		
		local espTextLabel = Instance.new("TextLabel")
		espTextLabel.Size = UDim2.new(1, 0, 1, 0)
		espTextLabel.BackgroundTransparency = 1
		espTextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		espTextLabel.TextStrokeTransparency = 0
		espTextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		espTextLabel.Font = Enum.Font.SourceSansBold
		espTextLabel.TextSize = 14
		espTextLabel.Parent = billboard
		
		task.spawn(function()
			while isEspActive and character.Parent and humanoid.Health > 0 do
				local localCharacter = player.Character
				if localCharacter and localCharacter:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("HumanoidRootPart") then
					local distance = (localCharacter.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
					local health = math.floor(humanoid.Health)
					local maxHealth = math.floor(humanoid.MaxHealth)
					
					if health > 50 then
						espTextLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
					else
						espTextLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
					end
					
					espTextLabel.Text = string.format("%s\n[HP: %d/%d] | [Jarak: %dm]", targetPlayer.Name, health, maxHealth, math.floor(distance))
				end
				task.wait(0.1)
			end
			billboard:Destroy()
		end)
	end
	
	if targetPlayer.Character then
		task.spawn(setupCharacterESP, targetPlayer.Character)
	end
	targetPlayer.CharacterAdded:Connect(function(char)
		if isEspActive then task.spawn(setupCharacterESP, char) end
	end)
end

espPlayBtn.MouseButton1Click:Connect(function()
	if isEspActive then return end
	isEspActive = true
	espStatusLabel.Text = "Status ESP: AKTIF (Melacak)"
	espStatusLabel.TextColor3 = Color3.fromRGB(100, 240, 120)
	
	for _, otherPlayer in pairs(Players:GetPlayers()) do
		createESPForPlayer(otherPlayer)
	end
	
	Players.PlayerAdded:Connect(function(newPlayer)
		if isEspActive then createESPForPlayer(newPlayer) end
	end)
end)

espStopBtn.MouseButton1Click:Connect(function()
	isEspActive = false
	clearAllESP()
	espStatusLabel.Text = "Status ESP: Nonaktif"
	espStatusLabel.TextColor3 = Color3.fromRGB(240, 100, 90)
end)

----------------------------------------------------
-- [ KONTEN 8: HALAMAN FITUR PLAYER (SPEED & JUMP) ]
----------------------------------------------------
local playerPage = Instance.new("Frame")
playerPage.Size = UDim2.new(1, 0, 1, 0)
playerPage.BackgroundTransparency = 1
playerPage.Visible = false
playerPage.Parent = contentFrame

local playerListLayout = Instance.new("UIListLayout")
playerListLayout.Padding = UDim.new(0, 15)
playerListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
playerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerListLayout.Parent = playerPage

local function createModifierRow(titleText, placeholder, layoutOrder, callback)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 50)
	row.BackgroundTransparency = 1
	row.LayoutOrder = layoutOrder
	row.Parent = playerPage
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.45, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = titleText
	label.TextColor3 = Color3.fromRGB(240, 245, 235)
	label.Font = Enum.Font.SourceSansBold
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row
	
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.5, 0, 0.8, 0)
	box.Position = UDim2.new(0.5, 0, 0.1, 0)
	box.BackgroundColor3 = Color3.fromRGB(35, 43, 32)
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.Font = Enum.Font.SourceSansBold
	box.TextSize = 14
	box.Text = ""
	box.PlaceholderText = placeholder
	box.Parent = row
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
	
	local boxStroke = Instance.new("UIStroke")
	boxStroke.Thickness = 1.2
	boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	boxStroke.Parent = box
	table.insert(rgbObjects, boxStroke)
	
	box.FocusLost:Connect(function(enterPressed)
		local val = tonumber(box.Text)
		if val then callback(val) end
	end)
end

createModifierRow("Kecepatan Jalan (Speed):", "Bawaan: 16", 1, function(value)
	pcall(function()
		local character = player.Character or player.CharacterAdded:Wait()
		character:WaitForChild("Humanoid").WalkSpeed = value
	end)
end)

createModifierRow("Kekuatan Lompat (Jump):", "Bawaan: 50", 2, function(value)
	pcall(function()
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.UseJumpPower = true
		humanoid.JumpPower = value
	end)
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

-- [[ LOGIKA UTAMA CONTROLLER ]]
local isAngkaRunning = false
local function startAutoAngka()
	if isAngkaRunning then return end
	isAngkaRunning = true
	statusLabel.Text = "Status: Berjalan (1s Delay)..."
	statusLabel.TextColor3 = Color3.fromRGB(100, 240, 120)

	for i = 1, 1000 do
		if not isAngkaRunning then break end
		local finalSpellingText = getNumberSpelling(i) 
		inputTextBox.Text = finalSpellingText 
		if isAngkaRunning then
			sendToFocusedTextBox(finalSpellingText)
		end
		task.wait(1) 
	end

	if isAngkaRunning then
		isAngkaRunning = false
		statusLabel.Text = "Status: Selesai (1-1000)!"
		statusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	end
end

local function stopAutoAngka()
	isAngkaRunning = false
	statusLabel.Text = "Status: Berhenti"
	statusLabel.TextColor3 = Color3.fromRGB(240, 100, 90)
	inputTextBox.Text = "[Dihentikan]"
end

playButton.MouseButton1Click:Connect(startAutoAngka)
stopButton.MouseButton1Click:Connect(stopAutoAngka)

-- Logika Navigasi
local function clearAllPages()
	angkaPage.Visible = false
	latihanPage.Visible = false
	expPage.Visible = false
	tamtamaPage.Visible = false
	bintaraPage.Visible = false
	pamaPage.Visible = false
	espPage.Visible = false
	playerPage.Visible = false
	
	angkaTabBtn.BackgroundColor3 = Color3.fromRGB(35, 43, 32); angkaTabBtn.TextColor3 = Color3.fromRGB(200, 205, 195)
	latihanTabBtn.BackgroundColor3 = Color3.fromRGB(35, 43, 32); latihanTabBtn.TextColor3 = Color3.fromRGB(200, 205, 195)
	expTabBtn.BackgroundColor3 = Color3.fromRGB(35, 43, 32); expTabBtn.TextColor3 = Color3.fromRGB(200, 205, 195)
	tamtamaTabBtn.BackgroundColor3 = Color3.fromRGB(35, 43, 32); tamtamaTabBtn.TextColor3 = Color3.fromRGB(200, 205, 195)
	bintaraTabBtn.BackgroundColor3 = Color3.fromRGB(35, 43, 32); bintaraTabBtn.TextColor3 = Color3.fromRGB(200, 205, 195)
	pamaTabBtn.BackgroundColor3 = Color3.fromRGB(35, 43, 32); pamaTabBtn.TextColor3 = Color3.fromRGB(200, 205, 195)
	espTabBtn.BackgroundColor3 = Color3.fromRGB(35, 43, 32); espTabBtn.TextColor3 = Color3.fromRGB(200, 205, 195)
	playerTabBtn.BackgroundColor3 = Color3.fromRGB(35, 43, 32); playerTabBtn.TextColor3 = Color3.fromRGB(200, 205, 195)
end

local function activateTab(page, button)
	clearAllPages()
	page.Visible = true
	button.BackgroundColor3 = Color3.fromRGB(70, 90, 65)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
end

angkaTabBtn.MouseButton1Click:Connect(function() activateTab(angkaPage, angkaTabBtn) end)
latihanTabBtn.MouseButton1Click:Connect(function() activateTab(latihanPage, latihanTabBtn) end)
expTabBtn.MouseButton1Click:Connect(function() activateTab(expPage, expTabBtn) end)
tamtamaTabBtn.MouseButton1Click:Connect(function() activateTab(tamtamaPage, tamtamaTabBtn) end)
bintaraTabBtn.MouseButton1Click:Connect(function() activateTab(bintaraPage, bintaraTabBtn) end)
pamaTabBtn.MouseButton1Click:Connect(function() activateTab(pamaPage, pamaTabBtn) end)
espTabBtn.MouseButton1Click:Connect(function() activateTab(espPage, espTabBtn) end)
playerTabBtn.MouseButton1Click:Connect(function() activateTab(playerPage, playerTabBtn) end)

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
