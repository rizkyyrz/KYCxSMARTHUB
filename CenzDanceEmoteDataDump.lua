--==============================================================
-- CenzDanceEmoteData GUI DUMPER
-- Mobile Executor Friendly
--==============================================================

local TARGET_NAME = "CenzDanceEmoteData"

local Players = game:GetService("Players")
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

-- Hapus GUI lama
pcall(function()
	local old = guiParent:FindFirstChild("CenzDanceDumpGUI")

	if old then
		old:Destroy()
	end
end)

--==============================================================
-- GUI
--==============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CenzDanceDumpGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = false
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = guiParent

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0.92, 0, 0.78, 0)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(70, 70, 80)
Stroke.Thickness = 1
Stroke.Parent = Main

--==============================================================
-- HEADER
--==============================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 54)
Header.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local FixBottom = Instance.new("Frame")
FixBottom.Size = UDim2.new(1, 0, 0, 12)
FixBottom.Position = UDim2.new(0, 0, 1, -12)
FixBottom.BackgroundColor3 = Header.BackgroundColor3
FixBottom.BorderSizePixel = 0
FixBottom.Parent = Header

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 16, 0, 5)
Title.Size = UDim2.new(1, -120, 0, 24)
Title.Font = Enum.Font.GothamBold
Title.Text = "CenzDanceEmoteData"
Title.TextColor3 = Color3.fromRGB(245, 245, 245)
Title.TextSize = 17
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Status = Instance.new("TextLabel")
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0, 16, 0, 29)
Status.Size = UDim2.new(1, -120, 0, 18)
Status.Font = Enum.Font.Gotham
Status.Text = "Mencari ModuleScript..."
Status.TextColor3 = Color3.fromRGB(170, 170, 180)
Status.TextSize = 11
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 38, 0, 38)
Close.Position = UDim2.new(1, -46, 0, 8)
Close.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
Close.Text = "×"
Close.TextSize = 24
Close.Font = Enum.Font.GothamBold
Close.TextColor3 = Color3.fromRGB(235, 235, 235)
Close.BorderSizePixel = 0
Close.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = Close

Close.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

--==============================================================
-- TEXT AREA
--==============================================================

local TextBox = Instance.new("TextBox")
TextBox.Name = "DumpOutput"
TextBox.Position = UDim2.new(0, 10, 0, 64)
TextBox.Size = UDim2.new(1, -20, 1, -124)
TextBox.BackgroundColor3 = Color3.fromRGB(13, 13, 16)
TextBox.BorderSizePixel = 0

TextBox.Font = Enum.Font.Code
TextBox.TextSize = 12
TextBox.TextColor3 = Color3.fromRGB(225, 225, 230)

TextBox.TextXAlignment = Enum.TextXAlignment.Left
TextBox.TextYAlignment = Enum.TextYAlignment.Top

TextBox.ClearTextOnFocus = false
TextBox.MultiLine = true
TextBox.TextWrapped = false

TextBox.Text = "-- Loading CenzDanceEmoteData..."

TextBox.Parent = Main

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 8)
BoxCorner.Parent = TextBox

local Padding = Instance.new("UIPadding")
Padding.PaddingLeft = UDim.new(0, 10)
Padding.PaddingRight = UDim.new(0, 10)
Padding.PaddingTop = UDim.new(0, 10)
Padding.PaddingBottom = UDim.new(0, 10)
Padding.Parent = TextBox

--==============================================================
-- BOTTOM BUTTON
--==============================================================

local CopyButton = Instance.new("TextButton")
CopyButton.Position = UDim2.new(0, 10, 1, -50)
CopyButton.Size = UDim2.new(1, -20, 0, 40)
CopyButton.BackgroundColor3 = Color3.fromRGB(238, 238, 242)
CopyButton.BorderSizePixel = 0
CopyButton.Font = Enum.Font.GothamBold
CopyButton.Text = "COPY ALL"
CopyButton.TextColor3 = Color3.fromRGB(20, 20, 24)
CopyButton.TextSize = 13
CopyButton.Parent = Main

local CopyCorner = Instance.new("UICorner")
CopyCorner.CornerRadius = UDim.new(0, 8)
CopyCorner.Parent = CopyButton

--==============================================================
-- DRAG GUI
--==============================================================

do
	local dragging = false
	local dragStart
	local startPos
	local dragInput

	Header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
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
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragInput = input
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
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
-- SERIALIZER
--==============================================================

local visited = {}

local function quote(str)
	return string.format("%q", str)
end

local function indent(level)
	return string.rep("    ", level)
end

local function serialize(value, level)
	level = level or 0

	local valueType = typeof(value)

	if valueType == "nil" then
		return "nil"

	elseif valueType == "string" then
		return quote(value)

	elseif valueType == "number" then
		if value ~= value then
			return "0/0"
		elseif value == math.huge then
			return "math.huge"
		elseif value == -math.huge then
			return "-math.huge"
		end

		return tostring(value)

	elseif valueType == "boolean" then
		return tostring(value)

	elseif valueType == "Vector2" then
		return string.format(
			"Vector2.new(%s, %s)",
			value.X,
			value.Y
		)

	elseif valueType == "Vector3" then
		return string.format(
			"Vector3.new(%s, %s, %s)",
			value.X,
			value.Y,
			value.Z
		)

	elseif valueType == "UDim" then
		return string.format(
			"UDim.new(%s, %s)",
			value.Scale,
			value.Offset
		)

	elseif valueType == "UDim2" then
		return string.format(
			"UDim2.new(%s, %s, %s, %s)",
			value.X.Scale,
			value.X.Offset,
			value.Y.Scale,
			value.Y.Offset
		)

	elseif valueType == "Color3" then
		return string.format(
			"Color3.fromRGB(%d, %d, %d)",
			math.round(value.R * 255),
			math.round(value.G * 255),
			math.round(value.B * 255)
		)

	elseif valueType == "CFrame" then
		local components = {value:GetComponents()}
		local formatted = {}

		for i, component in ipairs(components) do
			formatted[i] = tostring(component)
		end

		return "CFrame.new(" .. table.concat(formatted, ", ") .. ")"

	elseif valueType == "BrickColor" then
		return "BrickColor.new(" .. quote(value.Name) .. ")"

	elseif valueType == "EnumItem" then
		return tostring(value)

	elseif valueType == "NumberRange" then
		return string.format(
			"NumberRange.new(%s, %s)",
			value.Min,
			value.Max
		)

	elseif valueType == "Instance" then
		local ok, path = pcall(function()
			return value:GetFullName()
		end)

		if ok then
			return quote("<Instance: " .. path .. ">")
		end

		return quote("<Instance>")

	elseif valueType == "function" then
		return "function(...) --[[ FUNCTION ]] end"

	elseif valueType == "table" then

		if visited[value] then
			return quote("<recursive table>")
		end

		visited[value] = true

		local result = {"{"}

		local keys = {}

		for key in pairs(value) do
			table.insert(keys, key)
		end

		table.sort(keys, function(a, b)
			return tostring(a) < tostring(b)
		end)

		for _, key in ipairs(keys) do
			local keyString

			if type(key) == "string"
				and string.match(key, "^[%a_][%w_]*$")
			then
				keyString = key
			else
				keyString =
					"["
					.. serialize(key, level + 1)
					.. "]"
			end

			table.insert(
				result,
				indent(level + 1)
					.. keyString
					.. " = "
					.. serialize(value[key], level + 1)
					.. ","
			)
		end

		table.insert(
			result,
			indent(level) .. "}"
		)

		visited[value] = nil

		return table.concat(result, "\n")
	end

	return quote(
		"<" .. valueType .. "> " .. tostring(value)
	)
end

--==============================================================
-- FIND MODULE
--==============================================================

local function findTarget()

	-- Prioritas ReplicatedStorage
	local RS = game:GetService("ReplicatedStorage")

	local found = RS:FindFirstChild(
		TARGET_NAME,
		true
	)

	if found and found:IsA("ModuleScript") then
		return found
	end

	-- Cari seluruh replicated descendants
	for _, obj in ipairs(game:GetDescendants()) do
		if obj.Name == TARGET_NAME
			and obj:IsA("ModuleScript")
		then
			return obj
		end
	end

	return nil
end

--==============================================================
-- DUMP
--==============================================================

task.spawn(function()

	Status.Text = "Mencari " .. TARGET_NAME .. "..."

	local target = findTarget()

	if not target then
		Status.Text = "ModuleScript tidak ditemukan"

		TextBox.Text =
			"-- ERROR\n"
			.. "-- "
			.. TARGET_NAME
			.. " tidak ditemukan dari client."

		return
	end

	Status.Text =
		"FOUND: "
		.. target:GetFullName()

	TextBox.Text =
		"-- Found:\n-- "
		.. target:GetFullName()
		.. "\n\n-- Requiring module..."

	task.wait()

	local ok, moduleData = pcall(
		require,
		target
	)

	if not ok then
		Status.Text = "Require gagal"

		TextBox.Text =
			"-- REQUIRE FAILED\n\n"
			.. tostring(moduleData)

		return
	end

	Status.Text = "Require OK • Membuat output..."

	task.wait()

	local output =
		"--==================================================\n"
		.. "-- CenzDanceEmoteData\n"
		.. "-- Dumped from: "
		.. target:GetFullName()
		.. "\n"
		.. "--==================================================\n\n"
		.. "return "
		.. serialize(moduleData, 0)

	TextBox.Text = output

	Status.Text =
		"READY • "
		.. tostring(#output)
		.. " characters"

	CopyButton.Text = "COPY ALL"
end)

--==============================================================
-- COPY BUTTON
--==============================================================

CopyButton.MouseButton1Click:Connect(function()

	local clipboard =
		setclipboard
		or toclipboard
		or set_clipboard

	if not clipboard then
		CopyButton.Text =
			"EXECUTOR TIDAK SUPPORT CLIPBOARD"

		task.delay(2, function()
			if CopyButton then
				CopyButton.Text = "COPY ALL"
			end
		end)

		return
	end

	local ok = pcall(
		clipboard,
		TextBox.Text
	)

	if ok then
		CopyButton.Text = "COPIED ✓"

		task.delay(1.5, function()
			if CopyButton then
				CopyButton.Text = "COPY ALL"
			end
		end)
	else
		CopyButton.Text = "COPY FAILED"
	end
end)
