--==============================================================
-- CenzDanceEmoteData DUMPER
-- Execute langsung di executor
--==============================================================

local TARGET_NAME = "CenzDanceEmoteData"

local function findTarget()
	for _, obj in ipairs(game:GetDescendants()) do
		if obj.Name == TARGET_NAME and obj:IsA("ModuleScript") then
			return obj
		end
	end
end

local target = findTarget()

if not target then
	warn("[CenzDump] ❌ CenzDanceEmoteData tidak ditemukan.")
	return
end

print("[CenzDump] ✅ FOUND:", target:GetFullName())

--==============================================================
-- REQUIRE MODULE
--==============================================================

local success, moduleData = pcall(require, target)

if not success then
	warn("[CenzDump] ❌ Require gagal:")
	warn(moduleData)
	return
end

print("[CenzDump] ✅ Module berhasil di-require")

--==============================================================
-- SERIALIZER
--==============================================================

local function indent(level)
	return string.rep("    ", level)
end

local function escapeString(str)
	return string.format("%q", str)
end

local visited = {}

local function serialize(value, level)
	level = level or 0

	local valueType = typeof(value)

	----------------------------------------------------------
	-- BASIC TYPES
	----------------------------------------------------------

	if valueType == "nil" then
		return "nil"

	elseif valueType == "string" then
		return escapeString(value)

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

	----------------------------------------------------------
	-- ROBLOX TYPES
	----------------------------------------------------------

	elseif valueType == "Vector2" then
		return string.format(
			"Vector2.new(%s, %s)",
			tostring(value.X),
			tostring(value.Y)
		)

	elseif valueType == "Vector3" then
		return string.format(
			"Vector3.new(%s, %s, %s)",
			tostring(value.X),
			tostring(value.Y),
			tostring(value.Z)
		)

	elseif valueType == "UDim" then
		return string.format(
			"UDim.new(%s, %s)",
			tostring(value.Scale),
			tostring(value.Offset)
		)

	elseif valueType == "UDim2" then
		return string.format(
			"UDim2.new(%s, %s, %s, %s)",
			tostring(value.X.Scale),
			tostring(value.X.Offset),
			tostring(value.Y.Scale),
			tostring(value.Y.Offset)
		)

	elseif valueType == "Color3" then
		return string.format(
			"Color3.new(%s, %s, %s)",
			tostring(value.R),
			tostring(value.G),
			tostring(value.B)
		)

	elseif valueType == "BrickColor" then
		return string.format(
			"BrickColor.new(%q)",
			value.Name
		)

	elseif valueType == "CFrame" then
		local components = {value:GetComponents()}

		local values = {}

		for i, component in ipairs(components) do
			values[i] = tostring(component)
		end

		return "CFrame.new(" .. table.concat(values, ", ") .. ")"

	elseif valueType == "EnumItem" then
		return tostring(value)

	elseif valueType == "NumberRange" then
		return string.format(
			"NumberRange.new(%s, %s)",
			tostring(value.Min),
			tostring(value.Max)
		)

	elseif valueType == "Rect" then
		return string.format(
			"Rect.new(%s, %s, %s, %s)",
			tostring(value.Min.X),
			tostring(value.Min.Y),
			tostring(value.Max.X),
			tostring(value.Max.Y)
		)

	----------------------------------------------------------
	-- INSTANCE
	----------------------------------------------------------

	elseif valueType == "Instance" then
		local ok, fullName = pcall(function()
			return value:GetFullName()
		end)

		if ok then
			return string.format(
				"--[[ Instance: %s ]] nil",
				fullName
			)
		end

		return '"<Instance>"'

	----------------------------------------------------------
	-- FUNCTION
	----------------------------------------------------------

	elseif valueType == "function" then
		return "function(...) --[[ function tidak bisa diserialize ]] end"

	----------------------------------------------------------
	-- TABLE
	----------------------------------------------------------

	elseif valueType == "table" then
		if visited[value] then
			return '"<recursive table>"'
		end

		visited[value] = true

		local result = {
			"{"
		}

		------------------------------------------------------
		-- CHECK ARRAY
		------------------------------------------------------

		local isArray = true
		local maxIndex = 0
		local count = 0

		for key in pairs(value) do
			count += 1

			if type(key) ~= "number"
				or key <= 0
				or key % 1 ~= 0
			then
				isArray = false
				break
			end

			if key > maxIndex then
				maxIndex = key
			end
		end

		if isArray and maxIndex ~= count then
			isArray = false
		end

		------------------------------------------------------
		-- ARRAY
		------------------------------------------------------

		if isArray then
			for i = 1, maxIndex do
				table.insert(
					result,
					indent(level + 1)
						.. serialize(value[i], level + 1)
						.. ","
				)
			end

		------------------------------------------------------
		-- DICTIONARY
		------------------------------------------------------

		else
			local keys = {}

			for key in pairs(value) do
				table.insert(keys, key)
			end

			table.sort(keys, function(a, b)
				return tostring(a) < tostring(b)
			end)

			for _, key in ipairs(keys) do
				local formattedKey

				if type(key) == "string"
					and string.match(key, "^[%a_][%w_]*$")
				then

					formattedKey = key

				else
					formattedKey =
						"["
						.. serialize(key, level + 1)
						.. "]"
				end

				table.insert(
					result,
					indent(level + 1)
						.. formattedKey
						.. " = "
						.. serialize(value[key], level + 1)
						.. ","
				)
			end
		end

		table.insert(
			result,
			indent(level) .. "}"
		)

		visited[value] = nil

		return table.concat(result, "\n")
	end

	----------------------------------------------------------
	-- FALLBACK
	----------------------------------------------------------

	return string.format(
		"%q",
		"<" .. valueType .. "> " .. tostring(value)
	)
end

--==============================================================
-- BUILD RESULT
--==============================================================

local output

if typeof(moduleData) == "table" then
	output =
		"-- CenzDanceEmoteData\n"
		.. "-- Dumped from: "
		.. target:GetFullName()
		.. "\n\nreturn "
		.. serialize(moduleData, 0)
else
	output =
		"-- CenzDanceEmoteData\n\nreturn "
		.. serialize(moduleData, 0)
end

--==============================================================
-- COPY
--==============================================================

local clipboard =
	setclipboard
	or toclipboard
	or set_clipboard

if clipboard then

	local ok, err = pcall(
		clipboard,
		output
	)

	if ok then
		print("")
		print("==============================================")
		print("[CenzDump] ✅ BERHASIL")
		print("[CenzDump] ✅ CenzDanceEmoteData sudah dicopy")
		print("[CenzDump] ✅ Tinggal CTRL + V")
		print("==============================================")
	else
		warn("[CenzDump] Clipboard error:", err)
	end

else
	warn("[CenzDump] ❌ Executor tidak support setclipboard")
end

--==============================================================
-- OPTIONAL FILE SAVE
--==============================================================

if writefile then
	pcall(function()
		writefile(
			"CenzDanceEmoteData_DUMP.lua",
			output
		)

		print(
			"[CenzDump] 💾 Backup tersimpan: CenzDanceEmoteData_DUMP.lua"
		)
	end)
end
