--[[
    RZKY Studio | Binary Instance Saver v2.0 (Delta mobile)

    Output: genuine RBXL binary, NOT renamed XML.
    Goal: save replicated game structure and human-readable client Luau IF a
    working decompiler is available. If the decompiler fails, do not write a
    misleading 'complete' RBXL file.

    Binary serialization engine (third-party; not embedded):
    https://github.com/FirTheDeveloper/Roblox-Place-Serializer
    This upstream project says it is no longer maintained. Use at your own risk.

    Limitations:
      * Delta's current 'decompilation panicked' cannot be repaired here.
      * Server-only scripts and storage are not visible from a client.
      * A decompiler reconstructs code; it cannot reproduce original source
        comments or guarantee identical semantics.
      * This code is not tested on a live Delta executor.
--]]

local VERSION = "2.0.0"
local ENGINE_URL = "https://raw.githubusercontent.com/FirTheDeveloper/Roblox-Place-Serializer/main/serializer.lua"
local PLAYERS = game:GetService("Players")
local CORE_GUI = game:GetService("CoreGui")
local USER_INPUT = game:GetService("UserInputService")
local MARKETPLACE = game:GetService("MarketplaceService")
local localPlayer = PLAYERS.LocalPlayer
local env = (type(getgenv) == "function" and getgenv()) or _G

local function getDecompileFunction()
    -- A future compatible implementation can be passed through the hook.
    -- Nothing is uploaded to third parties by this file.
    if type(env.RZKY_DECOMPILE) == "function" then
        return env.RZKY_DECOMPILE, "RZKY_DECOMPILE"
    end
    if type(env.decompile) == "function" then
        return env.decompile, "Delta"
    end
    if type(decompile) == "function" then
        return decompile, "Delta"
    end
    return nil, "UNAVAILABLE"
end

local function validSource(s)
    if type(s) ~= "string" or #s < 3 then return false end
    local t = string.lower(s)
    local bad = {
        "decompilation panicked", "decompiler panicked", "failed to decompile",
        "decompilation failed", "decompiler timed out", "no decompiler",
        "unsupported bytecode", "unable to decompile", "decompiler error",
        "source unavailable", "decompiling is disabled",
    }
    for _, p in ipairs(bad) do
        if string.find(t, p, 1, true) then return false end
    end
    if not string.match(s, "%S") then return false end
    -- Reject output that contains only comments without real code.
    local uncommented = s:gsub("%-%-%[%[.-%]%]", "")
    uncommented = uncommented:gsub("%-%-[^\n]*", "")
    return uncommented:match("%S") ~= nil
end

local function safeDecompile(fn, scriptInstance)
    local ok, result = pcall(fn, scriptInstance)
    if not ok then return nil, tostring(result) end
    if validSource(result) then return result end
    return nil, tostring(result):sub(1, 160)
end

local function getSamples()
    local roots = {
        game:GetService("ReplicatedStorage"),
        game:GetService("ReplicatedFirst"),
        game:GetService("StarterGui"),
        game:GetService("StarterPlayer"),
    }
    local samples = {}
    for _, root in ipairs(roots) do
        local ok, descendants = pcall(root.GetDescendants, root)
        if ok then
            for _, item in ipairs(descendants) do
                if item:IsA("ModuleScript") or item:IsA("LocalScript") then
                    samples[#samples + 1] = item
                    break
                end
            end
        end
        if #samples >= 2 then break end
    end
    return samples
end

local function fetch(url)
    local ok, result = pcall(function() return game:HttpGet(url, true) end)
    if ok and type(result) == "string" and #result > 100 then return result end
    error("Gagal mengunduh binary serializer dari GitHub: " .. tostring(result))
end

local function sanitize(name)
    name = tostring(name or "")
    name = name:gsub("%.rbxl$", ""):gsub("%.rbxlx$", "")
    name = name:gsub("[^%w%s_%-]", "_"):gsub("^%s+", ""):gsub("%s+$", "")
    name = name:sub(1, 90)
    if name == "" then name = "RZKYStudio_" .. tostring(game.PlaceId) end
    return name
end

local function new(className, properties, parent)
    local obj = Instance.new(className)
    for key, value in pairs(properties or {}) do obj[key] = value end
    obj.Parent = parent
    return obj
end
local function round(obj, size)
    new("UICorner", {CornerRadius=UDim.new(0, size or 10)}, obj)
end

if env.RZKY_BINARY_SAVER_GUI then
    pcall(function() env.RZKY_BINARY_SAVER_GUI:Destroy() end)
end

local gui = new("ScreenGui", {
    Name="RZKYStudioBinarySaver", ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling, DisplayOrder=100000
}, nil)
local guiParent
if type(gethui) == "function" then
    local ok, r = pcall(gethui)
    if ok and r then guiParent = r end
end
if not guiParent then
    local ok = pcall(function() gui.Parent = CORE_GUI end)
    if not ok then guiParent = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui") end
end
if guiParent then gui.Parent = guiParent end
if not gui.Parent then
    warn("[RZKY Studio] Tidak bisa memasang GUI (gethui/CoreGui/PlayerGui).")
    return
end
env.RZKY_BINARY_SAVER_GUI = gui

local root = new("Frame", {
    Name="Window", AnchorPoint=Vector2.new(.5,.5),
    Position=UDim2.fromScale(.5,.5), Size=UDim2.fromOffset(330, 366),
    BackgroundColor3=Color3.fromRGB(20,26,39), BorderSizePixel=0,
    ClipsDescendants=true
}, gui)
round(root, 15)
new("UIStroke", {Color=Color3.fromRGB(51,77,96),Thickness=1.1},root)
new("UISizeConstraint", {MinSize=Vector2.new(265,290),MaxSize=Vector2.new(380,410)},root)
local view = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(720,1280)
local uiScale = new("UIScale", { Scale=math.min(1, (view.X-22)/330, (view.Y-90)/366) },root)

local header = new("Frame", {Name="Header",Size=UDim2.new(1,0,0,63),BackgroundColor3=Color3.fromRGB(29,41,59),BorderSizePixel=0},root)
local heading = new("TextLabel", {
    Position=UDim2.fromOffset(15,9),Size=UDim2.new(1,-80,0,25),
    BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=17,
    TextColor3=Color3.fromRGB(228,249,247),Text="RZKY STUDIO",TextXAlignment=Enum.TextXAlignment.Left
},header)
new("TextLabel", {
    Position=UDim2.fromOffset(15,34),Size=UDim2.new(1,-75,0,17),
    BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=11,
    TextColor3=Color3.fromRGB(160,196,202),Text="BINARY .RBXL  /  DELTA MOBILE",
    TextXAlignment=Enum.TextXAlignment.Left
},header)
local close = new("TextButton", {
    Position=UDim2.new(1,-45,0,13),Size=UDim2.fromOffset(30,30),
    BackgroundColor3=Color3.fromRGB(62,72,88),BorderSizePixel=0,
    Text="X",TextSize=15,Font=Enum.Font.GothamBold,TextColor3=Color3.new(1,1,1)
},header)
round(close,8)
close.Activated:Connect(function() gui:Destroy(); env.RZKY_BINARY_SAVER_GUI=nil end)

local label1 = new("TextLabel", {
    Position=UDim2.fromOffset(17,77),Size=UDim2.new(1,-34,0,19),
    BackgroundTransparency=1,Font=Enum.Font.GothamMedium,TextSize=13,
    TextColor3=Color3.fromRGB(206,225,233),Text="NAMA FILE (.rbxl otomatis)",
    TextXAlignment=Enum.TextXAlignment.Left
},root)
local fileName = new("TextBox", {
    Position=UDim2.fromOffset(16,105),Size=UDim2.new(1,-32,0,39),
    BackgroundColor3=Color3.fromRGB(36,51,69),BorderSizePixel=0,
    TextColor3=Color3.new(1,1,1),Font=Enum.Font.Gotham,TextSize=14,
    ClearTextOnFocus=false,Text="RZKYStudio_"..tostring(game.PlaceId),
    PlaceholderText="Nama map",TextXAlignment=Enum.TextXAlignment.Left
},root)
round(fileName,9)
new("UIPadding",{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)},fileName)
task.spawn(function()
    local ok, info = pcall(function() return MARKETPLACE:GetProductInfo(game.PlaceId) end)
    if ok and type(info)=="table" and type(info.Name)=="string" and info.Name~="" then
        if fileName.Text == "RZKYStudio_" .. tostring(game.PlaceId) then fileName.Text=info.Name end
    end
end)

local desc = new("TextLabel", {
    Position=UDim2.fromOffset(18,154),Size=UDim2.new(1,-36,0,51),
    BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=12,
    TextColor3=Color3.fromRGB(169,188,204),TextWrapped=true,
    Text="Menyimpan struktur yang direplikasi + mencoba memulihkan source client. Gagal decompile = TIDAK buat file palsu.",
    TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top
},root)
local status = new("TextLabel", {
    Position=UDim2.fromOffset(17,216),Size=UDim2.new(1,-34,0,51),
    BackgroundColor3=Color3.fromRGB(29,43,58),BorderSizePixel=0,
    Font=Enum.Font.Gotham,TextSize=12,TextWrapped=true,
    TextColor3=Color3.fromRGB(204,225,234),Text="Siap. Tekan cek decompiler terlebih dahulu.",
},root)
round(status,8)
local buttonTest = new("TextButton", {
    Position=UDim2.fromOffset(16,280),Size=UDim2.new(.5,-23,0,49),
    BackgroundColor3=Color3.fromRGB(47,69,89),BorderSizePixel=0,
    Text="CEK SOURCE",Font=Enum.Font.GothamBold,TextSize=13,
    TextColor3=Color3.new(1,1,1)
},root)
round(buttonTest,9)
local buttonSave = new("TextButton", {
    Position=UDim2.new(.5,7,0,280),Size=UDim2.new(.5,-23,0,49),
    BackgroundColor3=Color3.fromRGB(40,157,145),BorderSizePixel=0,
    Text="SAVE .RBXL",Font=Enum.Font.GothamBold,TextSize=13,
    TextColor3=Color3.new(1,1,1)
},root)
round(buttonSave,9)
new("TextLabel", {
    Position=UDim2.fromOffset(16,335),Size=UDim2.new(1,-32,0,18),
    BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=10,
    TextColor3=Color3.fromRGB(132,157,166),Text="v"..VERSION.." | Client only | Third-party binary engine"
},root)

-- Drag only through the header, so textbox and buttons remain easy to use.
do
    local dragging, dragStart, frameStart = false,nil,nil
    header.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragStart=input.Position; frameStart=root.Position
            local conn; conn=input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.End then
                    dragging=false; conn:Disconnect()
                end
            end)
        end
    end)
    USER_INPUT.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
            local delta=(input.Position-dragStart)/uiScale.Scale
            root.Position=UDim2.new(frameStart.X.Scale,frameStart.X.Offset+delta.X,frameStart.Y.Scale,frameStart.Y.Offset+delta.Y)
        end
    end)
end

local busy=false
local decompilerName=""
local function checkSource()
    local fn, name = getDecompileFunction()
    decompilerName=name
    if not fn then return false,"Delta tidak menyediakan decompile()." end
    local samples=getSamples()
    if #samples==0 then return false,"Tidak ada LocalScript/ModuleScript untuk tes." end
    local good,bad=0,0
    local lastError=""
    for i=1,math.min(2,#samples) do
        local item=samples[i]
        local source,err=safeDecompile(fn,item)
        if source then good+=1 else bad+=1;lastError=tostring(err or "Unknown error") end
    end
    if bad>0 then
        return false,"Decompile GAGAL ("..bad.."/"..math.min(2,#samples).."): "..lastError:sub(1,55)
    end
    return true,"Tes source OK ("..good.." script). Belum menjamin semua script."
end
local function setStatus(msg, errorColor)
    status.Text=msg
    status.TextColor3=errorColor and Color3.fromRGB(255,164,161) or Color3.fromRGB(202,244,227)
    print("[RZKY Studio] "..msg)
end
buttonTest.Activated:Connect(function()
    if busy then return end
    busy=true;setStatus("Memeriksa decompiler Delta...")
    task.spawn(function()
        local ok,result,msg=pcall(checkSource)
        setStatus(ok and msg or ("Tes gagal: "..tostring(result)), (not ok) or (not result))
        busy=false
    end)
end)

local function saveBinary()
    if type(writefile)~="function" then error("Executor tidak punya writefile().") end
    local originalDecoder, sourceName=getDecompileFunction()
    if not originalDecoder then error("Tidak ada decompiler yang dapat menghasilkan source.") end
    local tested,testInfo=checkSource()
    if not tested then error(testInfo..". Ekspor dibatalkan agar isi script tidak kosong.") end

    local loader = loadstring or load
    if type(loader)~="function" then error("Executor tidak punya loadstring().") end
    local code=fetch(ENGINE_URL)
    local compile,compileErr=loader(code,"RZKYBinarySerializer")
    if not compile then error("Serializer gagal compile: "..tostring(compileErr)) end
    local success,serializer=pcall(compile)
    if not success or type(serializer)~="table" or type(serializer.Save)~="function" then
        error("Serializer tidak memberikan fungsi Save: "..tostring(serializer))
    end

    local attempts,failures=0,0
    local lastFailure=""
    -- This interception is temporary, and is restored after serialization.
    local oldEnvDecompile=rawget(env,"decompile")
    local wrapped=function(scriptInstance,...)
        attempts+=1
        local source,err=safeDecompile(originalDecoder,scriptInstance)
        if source then return source end
        failures+=1
        lastFailure=tostring(err):sub(1,120)
        return "-- [RZKY Studio] SOURCE UNAVAILABLE (export blocked)"
    end
    local patchedEnv, patchError=pcall(function() env.decompile=wrapped end)
    if not patchedEnv then error("Tidak dapat memasang adaptor decompiler: "..tostring(patchError)) end
    local oldGlobalDecompile=rawget(_G,"decompile")
    local patchedGlobal=false
    if env ~= _G then patchedGlobal=pcall(function() _G.decompile=wrapped end) end

    local binary
    local fileBase=sanitize(fileName.Text)
    local filename=fileBase..".rbxl"
    local saveOk,saveErr=xpcall(function()
        serializer.Init()
        serializer.Save(game,fileBase,{
            Binary=true, Decompile=true, Mode="full", MaxThreads=1,
            DecompileTimeout=12, SafeMode=false,
            ShowStatus=false, RemovePlayerCharacters=true,
            SavePlayers=false, IsolateStarterPlayer=true,
            IgnoreDefaultProps=true, IgnoreNotArchivable=true,
            SaveBytecode=false, SaveScriptCache=false,
            AntiIdle=false, BoostFPS=false, KillAllScripts=false,
            AvoidFileOverwrite=false, ReadMe=false,
            Callback=function(payload)
                if typeof(payload)=="buffer" then payload=buffer.tostring(payload) end
                if type(payload)~="string" then error("Callback tidak mengembalikan bytes RBXL") end
                binary=payload
            end,
        })
    end,debug.traceback)
    pcall(function() env.decompile=oldEnvDecompile end)
    if env ~= _G and patchedGlobal then pcall(function() _G.decompile=oldGlobalDecompile end) end

    if not saveOk then error("Binary serializer error: "..tostring(saveErr)) end
    if attempts==0 then
        error("Tidak ada script diproses oleh adaptor decompiler. Hasil source tidak bisa diverifikasi; file tidak ditulis.")
    end
    if failures>0 then
        error("GAGAL: "..failures.." dari "..attempts.." upaya decompile. "..lastFailure..". File tidak ditulis.")
    end
    if not binary then error("Serializer tidak mengembalikan data binary melalui Callback.") end
    local signature="<roblox!\137\255\r\n\26\n"
    if binary:sub(1,#signature) ~= signature then
        error("Output bukan format RBXL binary (signature tidak sesuai). Tidak akan disimpan sebagai .rbxl.")
    end
    if type(isfile)=="function" then
        local i=1;local basename=fileBase
        while isfile(filename) and i<=999 do
            filename=basename.." ("..i..")"..".rbxl";i+=1
        end
    end
    local okWrite,writeErr=pcall(writefile,filename,binary)
    if not okWrite then error("Gagal writefile: "..tostring(writeErr)) end
    if type(readfile)=="function" then
        local okRead,contents=pcall(readfile,filename)
        if okRead and type(contents)=="string" and contents:sub(1,#signature)~=signature then
            error("File tertulis tapi header invalid. Periksa executor filesystem.")
        end
    end
    return filename,attempts,#binary
end

buttonSave.Activated:Connect(function()
    if busy then return end
    busy=true
    buttonSave.Text="SAVING..."
    setStatus("Menguji source lalu menyiapkan .rbxl...")
    task.spawn(function()
        local ok,filename,attempts,bytes=pcall(saveBinary)
        if ok then
            setStatus("SAVED: "..filename.." | decompile: "..attempts.." | size: "..math.floor(bytes/1024).." KB")
        else
            setStatus("TIDAK DISIMPAN: "..tostring(filename):sub(1,160),true)
            warn("[RZKY Studio] "..tostring(filename))
        end
        buttonSave.Text="SAVE .RBXL"
        busy=false
    end)
end)

print("[RZKY Studio] Binary Saver v"..VERSION.." loaded. Genuine RBXL only; source required.")
