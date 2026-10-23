--[[
    rEm - based on HAZE V2.2 CYAN NEON
    Change in this version: renamed UI/notifications and appended whitelist users.
    Existing features retained; no battle features added.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- WHITELIST: original users retained; four new users appended
local WhitelistedUsers = {
    "hanssaputra15",
    "L0rdDarkShad0w",
    "chibhothax",
    "jiejisung00",
    "Mount2702Blanc",
    "ibrak4dabra",
    "chimicaramel",
    "miskalagi"
}

if not table.find(WhitelistedUsers, LocalPlayer.Name) then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "rEm",
            Text = "Access Denied: Username tidak di-whitelist!",
            Duration = 5
        })
    end)
    return
end

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "rEm",
        Text = "Welcome to rEm, " .. LocalPlayer.Name .. "!",
        Duration = 3
    })
end)

-- UI container selection
local PlayerGui
local success = pcall(function()
    PlayerGui = (gethui and gethui()) or game:GetService("CoreGui")
    local _ = PlayerGui.Name
end)
if not success or not PlayerGui then
    PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
end

-- Original large platform feature
if not workspace:FindFirstChild("HansBigPlatform") then
    local p = Instance.new("Part")
    p.Name = "HansBigPlatform" 
    p.Size = Vector3.new(60000, 10, 60000)
    p.Anchored = true
    p.CanCollide = true
    p.Position = Vector3.new(0, -6, 0)
    p.Transparency = 1
    p.Material = Enum.Material.SmoothPlastic
    p.Parent = workspace
end

local oldUIs = {"HAZE_HUB", "CustomGUI", "HazeAutoSell", "HazeEmotes", "HazeUtility", "HAZE_V2", "HAZE_V2_1", "HAZE_V2_2", "rEm"}
for _, uiName in ipairs(oldUIs) do
    pcall(function()
        local old = PlayerGui:FindFirstChild(uiName)
        if old then old:Destroy() end
    end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "rEm"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = PlayerGui end)

-- Intro
local function playIntro()
    local IntroText = Instance.new("TextLabel")
    IntroText.Parent = ScreenGui
    IntroText.BackgroundTransparency = 1
    IntroText.Position = UDim2.new(0.5, 0, 0.5, 0)
    IntroText.Font = Enum.Font.GothamBold
    IntroText.Text = "rEm"
    IntroText.TextColor3 = Color3.fromRGB(0, 255, 255)
    IntroText.TextSize = 0
    IntroText.AnchorPoint = Vector2.new(0.5, 0.5)
    TweenService:Create(IntroText, TweenInfo.new(0.8, Enum.EasingStyle.Back), {TextSize = 60}):Play()
    task.wait(1.2)
    TweenService:Create(IntroText, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
    task.delay(0.8, function() if IntroText then IntroText:Destroy() end end)
end
task.spawn(playIntro)

-- Main UI
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.5, -85, 0.3, 0)
MainFrame.Size = UDim2.new(0, 150, 0, 250)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(170, 85, 255)
Stroke.Thickness = 1.5

local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, -10, 1, -40)
Scroll.Position = UDim2.new(0, 5, 0, 35)
Scroll.BackgroundTransparency = 1
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.ScrollBarThickness = 2
Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 2)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local MenuBtn = Instance.new("TextButton", ScreenGui)
MenuBtn.Size = UDim2.new(0, 42, 0, 42)
MenuBtn.Position = UDim2.new(0, 20, 0.5, -20)
MenuBtn.Text = "r"
MenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MenuBtn.TextColor3 = Color3.fromRGB(170, 85, 255)
MenuBtn.Font = Enum.Font.GothamBold
MenuBtn.TextSize = 24
MenuBtn.Draggable = true
Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(1, 0)
local BtnStroke = Instance.new("UIStroke", MenuBtn)
BtnStroke.Color = Color3.fromRGB(0, 255, 255)
BtnStroke.Thickness = 2
BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MenuBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local function createToggle(name, default, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(0.95, 0, 0, 26)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 10
    btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    local enabled = default
    local function update()
        btn.Text = name .. ": " .. (enabled and "ON" or "OFF")
        btn.BackgroundColor3 = enabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
        callback(enabled)
    end
    btn.MouseButton1Click:Connect(function() enabled = not enabled; update() end)
    update()
end

local function createInput(placeholder, callback)
    local box = Instance.new("TextBox", Scroll)
    box.Size = UDim2.new(0.95, 0, 0, 26)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.Font = Enum.Font.Gotham
    box.TextSize = 10
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)
    box.FocusLost:Connect(function() callback(box.Text) end)
end

-- Anti-Void
getgenv().AntiVoid = false
task.spawn(function()
    while task.wait(0.05) do
        if getgenv().AntiVoid then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root and root.Position.Y < -50 then
                root.Velocity = Vector3.new(0, 0, 0)
                root.CFrame = CFrame.new(0, 50, 0)
            end
        end
    end
end)
createToggle("Anti-Void", false, function(v) getgenv().AntiVoid = v end)

-- Auto Eat / Farm and speed
getgenv().AutoFarm = false
getgenv().SpeedEnabled = false
getgenv().SpeedValue = 100
local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
local setCubesEvent = eventsFolder and eventsFolder:FindFirstChild("SetCubes")
RunService.Heartbeat:Connect(function(delta)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if getgenv().AutoFarm then
        pcall(function()
            if setCubesEvent then setCubesEvent:FireServer() end
            local charEvents = char:FindFirstChild("Events")
            if charEvents then
                local grab = charEvents:FindFirstChild("Grab")
                local eat = charEvents:FindFirstChild("Eat")
                if grab then grab:FireServer(false, false, false) end
                if eat then eat:FireServer() end
            end
        end)
    end

    if hum and root then
        root.Anchored = false

        if getgenv().SpeedEnabled then
            hum.WalkSpeed = getgenv().SpeedValue
        else
            hum.WalkSpeed = 16
        end
    end



end)
createToggle("Auto Eat", false, function(v) getgenv().AutoFarm = v end)
createInput("Speed Value", function(t) getgenv().SpeedValue = tonumber(t) or 60 end)
createToggle("Run Speed", false, function(v) getgenv().SpeedEnabled = v end)


-- Auto Next Map terintegrasi dengan Auto Sell (ETW)
-- Alur: tombol kecil kiri bawah -> tombol "Lewati" -> pilih salah satu map.
getgenv().AutoNextMapEnabled = true

local nextMapBusy = false
local nextMapCooldown = 2.5
local lastNextMapAt = 0

local function getGuiRoots()
    local roots, seen = {}, {}

    local function add(root)
        if root and not seen[root] then
            seen[root] = true
            table.insert(roots, root)
        end
    end

    add(LocalPlayer:FindFirstChildOfClass("PlayerGui"))
    pcall(function()
        if gethui then add(gethui()) end
    end)
    pcall(function()
        add(game:GetService("CoreGui"))
    end)

    return roots
end

local function getVisibleButtons()
    local result, seen = {}, {}

    for _, root in ipairs(getGuiRoots()) do
        local ok, descendants = pcall(function()
            return root:GetDescendants()
        end)

        if ok then
            for _, obj in ipairs(descendants) do
                if not seen[obj]
                    and obj:IsA("GuiButton")
                    and obj.Visible
                    and obj.Active
                    and obj.Parent
                    and obj.AbsoluteSize.X > 0
                    and obj.AbsoluteSize.Y > 0 then

                    seen[obj] = true
                    table.insert(result, obj)
                end
            end
        end
    end

    return result
end

local function buttonText(obj)
    local value = ""

    pcall(function()
        value = tostring(obj.Text or "")
    end)

    if value == "" then
        pcall(function()
            value = tostring(obj.Name or "")
        end)
    end

    return string.lower(value)
        :gsub("%s+", " ")
        :gsub("^%s*(.-)%s*$", "%1")
end

local function activateMapSkip(target)
    if not target or not target.Parent
        or not target.Visible or not target.Active then
        return false
    end

    if typeof(firesignal) == "function" then
        local ok = pcall(function()
            firesignal(target.Activated)
        end)

        if ok then return true end

        pcall(function()
            firesignal(target.MouseButton1Click)
        end)
    end

    if typeof(getconnections) == "function" then
        local ok, fired = pcall(function()
            for _, connection in ipairs(getconnections(target.Activated)) do
                if connection.Function then
                    connection:Fire()
                    return true
                end
            end
            return false
        end)

        if ok and fired then return true end
    end

    return false
end


local function findCornerSkipButton()
    local player = game:GetService("Players").LocalPlayer
    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    if not playerGui then
        return nil
    end

    local screenGui = playerGui:FindFirstChild("ScreenGui")
    if not screenGui then
        return nil
    end

    local adminButtons = screenGui:FindFirstChild("AdminButtons")
    if not adminButtons then
        return nil
    end

    local button = adminButtons:FindFirstChild("ServerOptions")
    if button and button:IsA("GuiButton")
        and button.Visible and button.Active then
        return button
    end

    return nil
end


local function findLewatiButton()
    local player = game:GetService("Players").LocalPlayer
    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    if not playerGui then
        return nil
    end

    local screenGui = playerGui:FindFirstChild("ScreenGui")
    local settings = screenGui and screenGui:FindFirstChild("ServerSettings")
    local frame = settings and settings:FindFirstChild("Frame")
    local skip = frame and frame:FindFirstChild("Skip")
    local button = skip and skip:FindFirstChild("TextButton")

    if button and button:IsA("GuiButton")
        and button.Visible and button.Active then
        return button
    end

    return nil
end


local function findMapChoiceButton(excluded)
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize

    if not viewport then return nil end

    local candidates = {}

    for _, obj in ipairs(getVisibleButtons()) do
        if obj ~= excluded then
            local txt = buttonText(obj)
            local pos = obj.AbsolutePosition
            local size = obj.AbsoluteSize

            local cx = (pos.X + size.X / 2) / viewport.X
            local cy = (pos.Y + size.Y / 2) / viewport.Y

            local isMenuLabel =
                txt == ""
                or txt:find("pengaturan", 1, true)
                or txt:find("jeda", 1, true)
                or txt:find("tidak dihentikan", 1, true)
                or txt == "lewati"
                or txt == "skip"
                or txt:find("lewati peta", 1, true)
                or txt:find("kembali", 1, true)
                or txt:find("tutup", 1, true)
                or txt:find("memuat", 1, true)

            if not isMenuLabel
                and size.X >= 35 and size.Y >= 18
                and cx > 0.15 and cx < 0.9
                and cy > 0.15 and cy < 0.9 then

                table.insert(candidates, {
                    button = obj,
                    score = math.abs(cx - 0.5)
                        + math.abs(cy - 0.5) * 0.7
                })
            end
        end
    end

    table.sort(candidates, function(a, b)
        return a.score < b.score
    end)

    if #candidates > 0 then
        local limit = math.min(#candidates, 3)
        return candidates[math.random(1, limit)].button
    end

    return nil
end


local function requestNextMapAfterSell()
    if not getgenv().AutoNextMapEnabled or nextMapBusy then
        print("[rEm CHECK] STOP: Auto Next Map OFF atau sedang sibuk")
        return
    end

    if os.clock() - lastNextMapAt < nextMapCooldown then
        print("[rEm CHECK] STOP: masih cooldown")
        return
    end

    nextMapBusy = true

    task.spawn(function()
        local function finish()
            nextMapBusy = false
            print("[rEm CHECK] Pemeriksaan selesai")
        end

        print("[rEm CHECK 1] Auto Sell memicu Skip Maps")
        task.wait(0.8)

        local cornerButton = findCornerSkipButton()
        if not cornerButton then
            warn("[rEm CHECK GAGAL 1] Tombol pojok kiri bawah tidak ditemukan")
            finish()
            return
        end

        print("[rEm CHECK 2] Tombol pojok kiri bawah ditemukan:", cornerButton:GetFullName())

        if not activateMapSkip(cornerButton) then
            warn("[rEm CHECK GAGAL 2] Tombol pojok kiri bawah gagal diaktifkan")
            finish()
            return
        end

        print("[rEm CHECK 3] Perintah aktivasi tombol dikirim")
        task.wait(1)

        local lewatiButton = findLewatiButton()
        if not lewatiButton then
            warn("[rEm CHECK GAGAL 3] Tombol Lewati tidak ditemukan")
            finish()
            return
        end

        print("[rEm CHECK 4] Tombol Lewati ditemukan:", lewatiButton:GetFullName())

        if not activateMapSkip(lewatiButton) then
            warn("[rEm CHECK GAGAL 4] Tombol Lewati gagal diaktifkan")
            finish()
            return
        end

        print("[rEm CHECK 5] Perintah aktivasi Lewati dikirim")
        task.wait(1)

        local mapButton = findMapChoiceButton(lewatiButton)
        if not mapButton then
            warn("[rEm CHECK GAGAL 5] Tombol pilihan map tidak ditemukan")
            finish()
            return
        end

        print("[rEm CHECK 6] Kandidat tombol map:", mapButton:GetFullName())

        if not activateMapSkip(mapButton) then
            warn("[rEm CHECK GAGAL 6] Pilihan map gagal diaktifkan")
            finish()
            return
        end

        lastNextMapAt = os.clock()
        print("[rEm CHECK 7] Perintah aktivasi pilihan map dikirim")

        task.wait(8)
        finish()
    end)
end


createToggle("Auto Next Map", true, function(v)
    getgenv().AutoNextMapEnabled = v

    if not v then
        nextMapBusy = false
    end
end)


-- Auto Sell by UI bar detection
getgenv().AutoSellBar = false
local cachedBar = nil
local isSelling = false
local function findBar()
    if cachedBar and cachedBar.Parent then return cachedBar end
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, v in ipairs(playerGui:GetDescendants()) do
            if v:IsA("Frame") and (v.Name:lower():find("bar") or v.Name:lower():find("meter")) then
                cachedBar = v
                return v
            end
        end
    end
    return nil
end
local function getSell()
    local c = LocalPlayer.Character
    local e = c and c:FindFirstChild("Events")
    return e and e:FindFirstChild("Sell")
end
RunService.Heartbeat:Connect(function()
    if not getgenv().AutoSellBar or isSelling then return end
    local b = findBar()
    if b and b.Size.X.Scale >= 1 then
        local s = getSell()
        if s then
            isSelling = true
            local sellSent = pcall(function() s:FireServer() end)
            if sellSent then
                requestNextMapAfterSell()
            end
            task.delay(0.5, function() isSelling = false end)
        end
    end
end)
createToggle("Auto Sell (Bar)", false, function(v) getgenv().AutoSellBar = v end)

-- Dynamic Attack TP
getgenv().AttackTP = false
getgenv().TargetPlayer = ""
local attackTpConnection = nil
createInput("Target Name (Attack TP)", function(t) getgenv().TargetPlayer = t end)
local function getRandomPosition()
    return Vector3.new(math.random(-100, 100), math.random(10, 50), math.random(-100, 100))
end
local function getTargetPlayer(query)
    if query == "" then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if string.find(string.lower(p.Name), string.lower(query), 1, true) or string.find(string.lower(p.DisplayName), string.lower(query), 1, true) then
                return p
            end
        end
    end
    return nil
end
createToggle("Attack TP Loop", false, function(v)
    getgenv().AttackTP = v
    if not v and attackTpConnection then attackTpConnection:Disconnect(); attackTpConnection = nil end
end)
task.spawn(function()
    while true do
        if getgenv().AttackTP then
            local targetPlayer = getTargetPlayer(getgenv().TargetPlayer)
            local char = LocalPlayer.Character
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and char and char:FindFirstChild("HumanoidRootPart") then
                if char.PrimaryPart then char:SetPrimaryPartCFrame(CFrame.new(getRandomPosition())) end
                task.wait(1.5)
                local ce = char:FindFirstChild("Events")
                local grab = ce and ce:FindFirstChild("Grab")
                if grab then pcall(function() grab:FireServer() end) end
                task.wait(2)
                attackTpConnection = RunService.Heartbeat:Connect(function()
                    if getgenv().AttackTP and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and char and char:FindFirstChild("HumanoidRootPart") and char.PrimaryPart then
                        local mySize = char:GetExtentsSize().Z
                        local targetSize = targetPlayer.Character:GetExtentsSize().Z
                        local safeDistance = (mySize / 2) + (targetSize / 2) + 2
                        char:SetPrimaryPartCFrame(targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, safeDistance))
                    end
                end)
                local throwEvent = ce and ce:FindFirstChild("Throw")
                if throwEvent then pcall(function() throwEvent:FireServer() end) end
                task.wait(1.5)
                if attackTpConnection then attackTpConnection:Disconnect(); attackTpConnection = nil end
            end
            task.wait(1)
        else
            task.wait(0.5)
        end
    end
end)

-- Gravity Lock: normal movement, low jump

createToggle("Gravity Lock", false, function(v)
    _G.GravityLock = v

    local player = Players.LocalPlayer

    if _G.GravityLockConnection then
        _G.GravityLockConnection:Disconnect()
        _G.GravityLockConnection = nil
    end

    if not v then return end

    local function applyLowJump(character)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if not humanoid then return end

        humanoid.UseJumpPower = true
        humanoid.JumpPower = 5
        humanoid.JumpHeight = 1

        _G.GravityLockConnection =
            RunService.Heartbeat:Connect(function()
                if not _G.GravityLock or not humanoid.Parent then
                    return
                end

                humanoid.UseJumpPower = true
                humanoid.JumpPower = 5
                humanoid.JumpHeight = 1
            end)
    end

    if player.Character then
        applyLowJump(player.Character)
    end

    player.CharacterAdded:Connect(function(character)
        if _G.GravityLock then
            applyLowJump(character)
        end
    end)
end)


-- God Anti-Ragdoll
createToggle("God Anti-Ragdoll", false, function(v)
    _G.GodModeRagdoll = v
    local player = Players.LocalPlayer
    local RS = game:GetService("ReplicatedStorage")
    if v then
        if not _G.GodLoop then
            _G.GodLoop = RunService.Heartbeat:Connect(function()
                local currentChar = player.Character
                if currentChar then
                    pcall(function()
                        local ev = RS:FindFirstChild("Events")
                        local unrag = ev and ev:FindFirstChild("unRagdoll")
                        if unrag then unrag:FireServer(currentChar) end
                    end)
                    local currentHrp = currentChar:FindFirstChild("HumanoidRootPart")
                    if currentHrp and not currentHrp:FindFirstChild("HazeIronPosture") then
                        local gyro = Instance.new("BodyGyro")
                        gyro.Name = "HazeIronPosture"
                        gyro.MaxTorque = Vector3.new(math.huge, 0, math.huge)
                        gyro.P = 1000000
                        gyro.Parent = currentHrp
                    end
                    local ragdollScript = currentChar:FindFirstChild("RagdollListener")
                    if ragdollScript and ragdollScript:IsA("BaseScript") then ragdollScript.Disabled = true end
                    if currentHrp then currentHrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0) end
                    local hum = currentChar:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                        hum.PlatformStand = false
                        hum.Sit = false
                        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    end
                end
            end)
        end
    elseif _G.GodLoop then
        _G.GodLoop:Disconnect()
        _G.GodLoop = nil
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and hrp:FindFirstChild("HazeIronPosture") then hrp.HazeIronPosture:Destroy() end
            pcall(function()
                local ev = RS:FindFirstChild("Events")
                local unrag = ev and ev:FindFirstChild("unRagdoll")
                if unrag then unrag:FireServer(char) end
            end)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                hum.PlatformStand = false
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end
end)

-- Advanced ESP
local espEnabled = false
local espObjects = {}
local function cariDataBruteForce(targetPlayer, namaData)
    local namaVariasi = {namaData, string.gsub(namaData, " ", ""), string.gsub(namaData, " ", "_")}
    local function cekObjek(obj)
        for _, variasi in ipairs(namaVariasi) do
            if string.lower(obj.Name) == string.lower(variasi) and (obj:IsA("IntValue") or obj:IsA("NumberValue")) then return obj.Value end
        end
        return nil
    end
    for _, obj in ipairs(targetPlayer:GetDescendants()) do local val = cekObjek(obj); if val ~= nil then return val end end
    for _, variasi in ipairs(namaVariasi) do
        local pAttr = targetPlayer:GetAttribute(variasi)
        if pAttr ~= nil then return pAttr end
        if targetPlayer.Character then
            local cAttr = targetPlayer.Character:GetAttribute(variasi)
            if cAttr ~= nil then return cAttr end
        end
    end
    local pGui = targetPlayer:FindFirstChild("PlayerGui")
    if pGui then for _, obj in ipairs(pGui:GetDescendants()) do local val = cekObjek(obj); if val ~= nil then return val end end end
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if string.find(string.lower(obj.Name), string.lower(targetPlayer.Name), 1, true) then
            for _, child in ipairs(obj:GetDescendants()) do local val = cekObjek(child); if val ~= nil then return val end end
        end
    end
    return "?"
end

local function createESP(targetPlayer)
    if targetPlayer == LocalPlayer then return end
    local hl = Instance.new("Highlight")
    hl.Name = "rEmESP"
    hl.FillColor = Color3.fromRGB(0, 255, 255)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    local bgui = Instance.new("BillboardGui")
    bgui.Name = "rEmESPText"
    bgui.AlwaysOnTop = true
    bgui.Size = UDim2.new(0, 180, 0, 100)
    bgui.StudsOffset = Vector3.new(0, 4, 0)
    local text = Instance.new("TextLabel", bgui)
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextStrokeTransparency = 0
    text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    text.Font = Enum.Font.GothamBold
    text.TextSize = 12
    text.TextYAlignment = Enum.TextYAlignment.Bottom
    table.insert(espObjects, {player = targetPlayer, highlight = hl, billboard = bgui, textLabel = text})
end

task.spawn(function()
    while task.wait(1) do
        if espEnabled then
            for _, obj in ipairs(espObjects) do
                local tPlayer = obj.player
                local char = tPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if char and root then
                    if obj.highlight.Parent ~= char then obj.highlight.Parent = char end
                    if obj.billboard.Parent ~= root then obj.billboard.Parent = root end
                    local sizeVal = cariDataBruteForce(tPlayer, "Size")
                    local maxVal = cariDataBruteForce(tPlayer, "MaxSize")
                    if maxVal == "?" then maxVal = cariDataBruteForce(tPlayer, "Max Size") end
                    if maxVal == "?" then maxVal = cariDataBruteForce(tPlayer, "Max") end
                    if maxVal == "?" then maxVal = cariDataBruteForce(tPlayer, "Capacity") end
                    local eatSpeedVal = cariDataBruteForce(tPlayer, "eat speed")
                    if eatSpeedVal == "?" then eatSpeedVal = cariDataBruteForce(tPlayer, "eat level") end
                    local multiVal = cariDataBruteForce(tPlayer, "size multiplier")
                    if multiVal == "?" then multiVal = cariDataBruteForce(tPlayer, "multiplier") end
                    if multiVal == "?" then multiVal = cariDataBruteForce(tPlayer, "multi") end
                    local walkSpeedVal = 16
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then walkSpeedVal = math.floor(hum.WalkSpeed) end
                    obj.textLabel.Text = string.format("[%s]\nSize: %s / %s\nMulti: %s | Eat: %s\nWalkSpeed: %s", tPlayer.Name, tostring(sizeVal), tostring(maxVal), tostring(multiVal), tostring(eatSpeedVal), tostring(walkSpeedVal))
                else
                    obj.highlight.Parent = nil
                    obj.billboard.Parent = nil
                end
            end
        end
    end
end)

for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(function(player)
    for i, obj in ipairs(espObjects) do
        if obj.player == player then
            obj.highlight:Destroy()
            obj.billboard:Destroy()
            table.remove(espObjects, i)
            break
        end
    end
end)

createToggle("Player ESP", false, function(v)
    espEnabled = v
    if not espEnabled then
        for _, obj in ipairs(espObjects) do
            obj.highlight.Parent = nil
            obj.billboard.Parent = nil
        end
    end
end)
