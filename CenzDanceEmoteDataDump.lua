--==============================================================
-- CenzDanceEmoteData MOBILE PAGED DUMPER
-- Dances / Emotes
-- Numeric order
-- 50 entries per page
--==============================================================

local TARGET_NAME = "CenzDanceEmoteData"
local PAGE_SIZE = 50

local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

--==============================================================
-- GUI PARENT
--==============================================================

local guiParent = CoreGui

if gethui then
	local ok, hui = pcall(gethui)

	if ok and hui then
		guiParent = hui
	end
end

pcall(function()
	local old = guiParent:FindFirstChild("CenzDancePagedDump")

	if old then
		old:Destroy()
	end
end)

--==============================================================
-- COLORS
--==============================================================

local BG = Color3.fromRGB(18, 18, 22)
local HEADER = Color3.fromRGB(26, 26, 32)
local PANEL = Color3.fromRGB(12, 12, 15)
local BUTTON = Color3.fromRGB(42, 42, 50)
local ACTIVE = Color3.fromRGB(235, 235, 240)

--==============================================================
-- GUI
--==============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CenzDancePagedDump"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = guiParent

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0.94, 0, 0.82, 0)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = BG
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(65, 65, 75)
Stroke.Thickness = 1
Stroke.Parent = Main

--==============================================================
-- HEADER
--==============================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 56)
Header.BackgroundColor3 = HEADER
Header.BorderSizePixel = 0
Header.Parent = Main

Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local Fix = Instance.new("Frame")
Fix.Size = UDim2.new(1, 0, 0, 12)
Fix.Position = UDim2.new(0, 0, 1, -12)
Fix.BackgroundColor3 = HEADER
Fix.BorderSizePixel = 0
Fix.Parent = Header

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 14, 0, 6)
Title.Size = UDim2.new(1, -65, 0, 22)
Title.Font = Enum.Font.GothamBold
Title.Text = "CenzDanceEmoteData"
Title.TextSize = 17
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Status = Instance.new("TextLabel")
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0, 14, 0, 29)
Status.Size = UDim2.new(1, -65, 0, 18)
Status.Font = Enum.Font.Gotham
Status.Text = "Loading..."
Status.TextSize = 11
Status.TextColor3 = Color3.fromRGB(165, 165, 175)
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 38, 0, 38)
Close.Position = UDim2.new(1, -46, 0, 9)
Close.BackgroundColor3 = BUTTON
Close.BorderSizePixel = 0
Close.Text = "×"
Close.TextSize = 23
Close.Font = Enum.Font.GothamBold
Close.TextColor3 = Color3.new(1, 1, 1)
Close.Parent = Header

Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)

Close.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

--==============================================================
-- TABS
--==============================================================

local Tabs = Instance.new("Frame")
Tabs.Position = UDim2.new(0, 10, 0, 66)
Tabs.Size = UDim2.new(1, -20, 0, 38)
Tabs.BackgroundTransparency = 1
Tabs.Parent = Main

local DancesButton = Instance.new("TextButton")
DancesButton.Size = UDim2.new(0.5, -4, 1, 0)
DancesButton.BackgroundColor3 = ACTIVE
DancesButton.BorderSizePixel = 0
DancesButton.Text = "DANCES"
DancesButton.Font = Enum.Font.GothamBold
DancesButton.TextSize = 12
DancesButton.TextColor3 = BG
DancesButton.Parent = Tabs

Instance.new("UICorner", DancesButton).CornerRadius = UDim.new(0, 8)

local EmotesButton = Instance.new("TextButton")
EmotesButton.Position = UDim2.new(0.5, 4, 0, 0)
EmotesButton.Size = UDim2.new(0.5, -4, 1, 0)
EmotesButton.BackgroundColor3 = BUTTON
EmotesButton.BorderSizePixel = 0
EmotesButton.Text = "EMOTES"
EmotesButton.Font = Enum.Font.GothamBold
EmotesButton.TextSize = 12
EmotesButton.TextColor3 = Color3.new(1, 1, 1)
EmotesButton.Parent = Tabs

Instance.new("UICorner", EmotesButton).CornerRadius = UDim.new(0, 8)

--==============================================================
-- TEXT OUTPUT
--==============================================================

local Output = Instance.new("TextBox")
Output.Position = UDim2.new(0, 10, 0, 114)
Output.Size = UDim2.new(1, -20, 1, -176)
Output.BackgroundColor3 = PANEL
Output.BorderSizePixel = 0

Output.Font = Enum.Font.Code
Output.TextSize = 12
Output.TextColor3 = Color3.fromRGB(225, 225, 230)

Output.TextXAlignment = Enum.TextXAlignment.Left
Output.TextYAlignment = Enum.TextYAlignment.Top

Output.MultiLine = true
Output.ClearTextOnFocus = false
Output.TextEditable = false
Output.TextWrapped = false

Output.Text = "-- Loading..."

Output.Parent = Main

Instance.new("UICorner", Output).CornerRadius = UDim.new(0, 8)

local Padding = Instance.new("UIPadding")
Padding.PaddingLeft = UDim.new(0, 9)
Padding.PaddingRight = UDim.new(0, 9)
Padding.PaddingTop = UDim.new(0, 9)
Padding.PaddingBottom = UDim.new(0, 9)
Padding.Parent = Output

--==============================================================
-- PAGE CONTROLS
--==============================================================

local Controls = Instance.new("Frame")
Controls.Position = UDim2.new(0, 10, 1, -52)
Controls.Size = UDim2.new(1, -20, 0, 42)
Controls.BackgroundTransparency = 1
Controls.Parent = Main

local Prev = Instance.new("TextButton")
Prev.Size = UDim2.new(0.22, 0, 1, 0)
Prev.BackgroundColor3 = BUTTON
Prev.BorderSizePixel = 0
Prev.Text = "< PREV"
Prev.Font = Enum.Font.GothamBold
Prev.TextSize = 11
Prev.TextColor3 = Color3.new(1, 1, 1)
Prev.Parent = Controls

Instance.new("UICorner", Prev).CornerRadius = UDim.new(0, 8)

local Copy = Instance.new("TextButton")
Copy.Position = UDim2.new(0.24, 0, 0, 0)
Copy.Size = UDim2.new(0.52, 0, 1, 0)
Copy.BackgroundColor3 = ACTIVE
Copy.BorderSizePixel = 0
Copy.Text = "COPY PAGE"
Copy.Font = Enum.Font.GothamBold
Copy.TextSize = 12
Copy.TextColor3 = BG
Copy.Parent = Controls

Instance.new("UICorner", Copy).CornerRadius = UDim.new(0, 8)

local Next = Instance.new("TextButton")
Next.Position = UDim2.new(0.78, 0, 0, 0)
Next.Size = UDim2.new(0.22, 0, 1, 0)
Next.BackgroundColor3 = BUTTON
Next.BorderSizePixel = 0
Next.Text = "NEXT >"
Next.Font = Enum.Font.GothamBold
Next.TextSize = 11
Next.TextColor3 = Color3.new(1, 1, 1)
Next.Parent = Controls

Instance.new("UICorner", Next).CornerRadius = UDim.new(0, 8)

--==============================================================
-- DRAG
--==============================================================

do
	local dragging = false
	local dragStart
	local startPos
	local dragInput

	Header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1
		then
			dragging = true
			dragStart = input.Position
			startPos = Main.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	Header.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseMovement
		then
			dragInput = input
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart

			Main.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

--==============================================================
-- DATA
--==============================================================

local moduleData

local currentSection = "Dances"
local currentPage = 1

--==============================================================
-- FORMAT HELPERS
--==============================================================

local function formatString(str)
	return string.format("%q", tostring(str))
end

local function formatValue(value)
	local valueType = typeof(value)

	if valueType == "string" then
		return formatString(value)

	elseif valueType == "number"
		or valueType == "boolean"
	then
		return tostring(value)

	elseif valueType == "EnumItem" then
		return tostring(value)

	elseif valueType == "Color3" then
		return string.format(
			"Color3.fromRGB(%d, %d, %d)",
			math.round(value.R * 255),
			math.round(value.G * 255),
			math.round(value.B * 255)
		)

	elseif valueType == "Vector3" then
		return string.format(
			"Vector3.new(%s, %s, %s)",
			value.X,
			value.Y,
			value.Z
		)

	elseif valueType == "Vector2" then
		return string.format(
			"Vector2.new(%s, %s)",
			value.X,
			value.Y
		)

	elseif valueType == "nil" then
		return "nil"
	end

	return formatString(
		"<" .. valueType .. "> " .. tostring(value)
	)
end

--==============================================================
-- ENTRY FORMAT
--==============================================================

local function formatEntry(entry, index)

	if type(entry) ~= "table" then
		return string.format(
			"[%d] = %s,",
			index,
			formatValue(entry)
		)
	end

	-- Format khusus CenzDance:
	-- { "NAME", AnimationId }

	if entry[1] ~= nil and entry[2] ~= nil then

		return string.format(
			'[%d] = { %s, %s },',
			index,
			formatValue(entry[1]),
			formatValue(entry[2])
		)
	end

	-- Fallback table
	local lines = {
		string.format("[%d] = {", index)
	}

	local keys = {}

	for key in pairs(entry) do
		table.insert(keys, key)
	end

	table.sort(keys, function(a, b)

		if type(a) == "number"
			and type(b) == "number"
		then
			return a < b
		end

		return tostring(a) < tostring(b)
	end)

	for _, key in ipairs(keys) do

		table.insert(
			lines,
			string.format(
				"    [%s] = %s,",
				formatValue(key),
				formatValue(entry[key])
			)
		)
	end

	table.insert(lines, "},")

	return table.concat(lines, "\n")
end

--==============================================================
-- PAGE
--==============================================================

local function getSection()

	if not moduleData then
		return {}
	end

	local section = moduleData[currentSection]

	if type(section) ~= "table" then
		return {}
	end

	return section
end

local function getPageCount()

	local section = getSection()

	return math.max(
		1,
		math.ceil(#section / PAGE_SIZE)
	)
end

local function render()

	local section = getSection()
	local pageCount = getPageCount()

	if currentPage > pageCount then
		currentPage = pageCount
	end

	if currentPage < 1 then
		currentPage = 1
	end

	local startIndex =
		(currentPage - 1) * PAGE_SIZE + 1

	local endIndex =
		math.min(
			startIndex + PAGE_SIZE - 1,
			#section
		)

	local lines = {}

	table.insert(
		lines,
		"--=================================================="
	)

	table.insert(
		lines,
		"-- CenzDanceEmoteData."
			.. currentSection
	)

	table.insert(
		lines,
		"-- PAGE "
			.. currentPage
			.. " / "
			.. pageCount
	)

	table.insert(
		lines,
		"-- ITEMS "
			.. startIndex
			.. " - "
			.. endIndex
			.. " / "
			.. #section
	)

	table.insert(
		lines,
		"--=================================================="
	)

	table.insert(lines, "")

	table.insert(
		lines,
		"CenzDanceEmoteData."
			.. currentSection
			.. " = {"
	)

	for i = startIndex, endIndex do

		local entry = section[i]

		table.insert(
			lines,
			"    "
				.. string.gsub(
					formatEntry(entry, i),
					"\n",
					"\n    "
				)
		)
	end

	table.insert(lines, "}")

	Output.Text =
		table.concat(lines, "\n")

	Status.Text =
		currentSection
		.. " • "
		.. #section
		.. " items • Page "
		.. currentPage
		.. "/"
		.. pageCount

	Prev.TextTransparency =
		currentPage <= 1 and 0.55 or 0

	Next.TextTransparency =
		currentPage >= pageCount and 0.55 or 0
end

--==============================================================
-- TAB SWITCHING
--==============================================================

local function selectSection(name)

	currentSection = name
	currentPage = 1

	if name == "Dances" then

		DancesButton.BackgroundColor3 = ACTIVE
		DancesButton.TextColor3 = BG

		EmotesButton.BackgroundColor3 = BUTTON
		EmotesButton.TextColor3 =
			Color3.new(1, 1, 1)

	else

		EmotesButton.BackgroundColor3 = ACTIVE
		EmotesButton.TextColor3 = BG

		DancesButton.BackgroundColor3 = BUTTON
		DancesButton.TextColor3 =
			Color3.new(1, 1, 1)
	end

	render()
end

DancesButton.MouseButton1Click:Connect(function()
	selectSection("Dances")
end)

EmotesButton.MouseButton1Click:Connect(function()
	selectSection("Emotes")
end)

--==============================================================
-- PREV / NEXT
--==============================================================

Prev.MouseButton1Click:Connect(function()

	if currentPage > 1 then
		currentPage -= 1
		render()
	end
end)

Next.MouseButton1Click:Connect(function()

	local pages = getPageCount()

	if currentPage < pages then
		currentPage += 1
		render()
	end
end)

--==============================================================
-- COPY CURRENT PAGE
--==============================================================

Copy.MouseButton1Click:Connect(function()

	local clipboard =
		setclipboard
		or toclipboard
		or set_clipboard

	if not clipboard then

		Copy.Text =
			"NO CLIPBOARD"

		task.delay(1.5, function()
			if Copy then
				Copy.Text = "COPY PAGE"
			end
		end)

		return
	end

	local ok = pcall(
		clipboard,
		Output.Text
	)

	if ok then

		Copy.Text =
			"COPIED PAGE "
			.. currentPage
			.. " ✓"

	else
		Copy.Text = "COPY FAILED"
	end

	task.delay(1.5, function()

		if Copy then
			Copy.Text = "COPY PAGE"
		end
	end)
end)

--==============================================================
-- FIND MODULE
--==============================================================

local function findModule()

	local RS = game:GetService(
		"ReplicatedStorage"
	)

	local target =
		RS:FindFirstChild(
			TARGET_NAME,
			true
		)

	if target
		and target:IsA("ModuleScript")
	then
		return target
	end

	for _, obj in ipairs(
		game:GetDescendants()
	) do

		if obj.Name == TARGET_NAME
			and obj:IsA("ModuleScript")
		then
			return obj
		end
	end

	return nil
end

--==============================================================
-- LOAD
--==============================================================

task.spawn(function()

	Status.Text =
		"Mencari "
		.. TARGET_NAME
		.. "..."

	local target = findModule()

	if not target then

		Status.Text =
			"ModuleScript tidak ditemukan"

		Output.Text =
			"-- ERROR\n"
			.. "-- "
			.. TARGET_NAME
			.. " tidak ditemukan."

		return
	end

	Status.Text =
		"FOUND • "
		.. target:GetFullName()

	Output.Text =
		"-- Found:\n-- "
		.. target:GetFullName()
		.. "\n\n-- Require..."

	task.wait()

	local ok, result =
		pcall(
			require,
			target
		)

	if not ok then

		Status.Text =
			"Require FAILED"

		Output.Text =
			"-- REQUIRE FAILED\n\n"
			.. tostring(result)

		return
	end

	if type(result) ~= "table" then

		Status.Text =
			"Return bukan table"

		Output.Text =
			"-- Module return type:\n"
			.. typeof(result)
			.. "\n\n"
			.. tostring(result)

		return
	end

	moduleData = result

	Status.Text = "READY"

	selectSection("Dances")
end)
