--[[
    AUTO GRAB PLAYER - ISOLATED TEST BUILD
    Purpose:
      1) Select one player from the list.
      2) Move behind that player.
      3) Fire the game's Character.Events.Grab RemoteEvent once.
      4) Return to the saved starting CFrame.
    No automatic Throw, Eat, Candy scan, coin scan, or repeated farming loop.

    IMPORTANT:
    - This only tests the client-side sequence and whether the game accepts the grab.
    - It cannot guarantee that the server attaches/carries another player.
    - The script deliberately does not force-move another player's character.
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Clean up only this test UI.
local GUI_NAME = "AUTO_GRAB_PLAYER_TEST"
local oldGui
pcall(function()
    if gethui then oldGui = gethui():FindFirstChild(GUI_NAME) end
end)
if not oldGui then oldGui = CoreGui:FindFirstChild(GUI_NAME) end
if not oldGui then oldGui = PlayerGui:FindFirstChild(GUI_NAME) end
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = GUI_NAME
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local parented = false
local busy = false
local attemptId = 0
pcall(function()
    if gethui then
        gui.Parent = gethui()
        parented = true
    end
end)
if not parented then
    pcall(function()
        gui.Parent = CoreGui
        parented = true
    end)
end
if not parented then gui.Parent = PlayerGui end

local C = {
    bg = Color3.fromRGB(17, 17, 21),
    panel = Color3.fromRGB(29, 28, 34),
    row = Color3.fromRGB(43, 42, 49),
    active = Color3.fromRGB(94, 25, 43),
    red = Color3.fromRGB(190, 32, 54),
    white = Color3.fromRGB(245, 243, 247),
    muted = Color3.fromRGB(155, 150, 160),
    green = Color3.fromRGB(80, 190, 120),
    yellow = Color3.fromRGB(235, 190, 75),
}

local function round(obj, radius)
    local u = Instance.new("UICorner")
    u.CornerRadius = UDim.new(0, radius)
    u.Parent = obj
end

local function makeLabel(parent, text, size, pos, textSize, color, font)
    local x = Instance.new("TextLabel")
    x.BackgroundTransparency = 1
    x.Size = size
    x.Position = pos
    x.Text = text
    x.TextColor3 = color or C.white
    x.TextSize = textSize or 10
    x.Font = font or Enum.Font.Gotham
    x.TextXAlignment = Enum.TextXAlignment.Left
    x.TextYAlignment = Enum.TextYAlignment.Center
    x.Parent = parent
    return x
end

local panel = Instance.new("Frame")
panel.Name = "TestPanel"
panel.Size = UDim2.fromOffset(205, 285)
panel.Position = UDim2.new(0.06, 0, 0.22, 0)
panel.BackgroundColor3 = C.bg
panel.BorderSizePixel = 0
panel.Parent = gui
round(panel, 13)

local stroke = Instance.new("UIStroke")
stroke.Color = C.red
stroke.Thickness = 1.5
stroke.Parent = panel

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 31)
header.BackgroundColor3 = C.panel
header.BorderSizePixel = 0
header.Parent = panel
round(header, 12)

makeLabel(header, "AUTO GRAB PLAYER  •  TEST", UDim2.new(1, -38, 1, 0),
    UDim2.fromOffset(9, 0), 9, C.white, Enum.Font.GothamBold)

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(23, 22)
close.Position = UDim2.new(1, -28, 0, 4)
close.BackgroundColor3 = C.red
close.BorderSizePixel = 0
close.Text = "×"
close.TextColor3 = C.white
close.TextSize = 16
close.Font = Enum.Font.GothamBold
close.Parent = header
round(close, 6)
close.Activated:Connect(function()
    if busy then
        setStatus("Tunggu percobaan selesai sebelum menutup panel.", C.yellow)
        return
    end
    gui:Destroy()
end)

-- Drag panel from header.
do
    local dragging, dragInput, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = panel.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input == dragInput
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            panel.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local status = makeLabel(panel, "Pilih satu player untuk tes.", 
    UDim2.new(1, -16, 0, 28), UDim2.fromOffset(9, 35), 8, C.muted)
status.TextWrapped = true

local list = Instance.new("ScrollingFrame")
list.Name = "PlayerList"
list.Size = UDim2.new(1, -14, 1, -91)
list.Position = UDim2.fromOffset(7, 65)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 2
list.ScrollBarImageColor3 = C.red
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new()
list.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 4)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local refresh = Instance.new("TextButton")
refresh.Size = UDim2.new(1, -14, 0, 21)
refresh.Position = UDim2.new(0, 7, 1, -25)
refresh.BackgroundColor3 = C.panel
refresh.BorderSizePixel = 0
refresh.Text = "REFRESH PLAYER LIST"
refresh.TextColor3 = C.white
refresh.TextSize = 8
refresh.Font = Enum.Font.GothamBold
refresh.Parent = panel
round(refresh, 6)

local function getRoot(plr)
    local char = plr and plr.Character
    if not char then return nil, nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 or not root then return nil, nil end
    return char, root
end

local function setStatus(message, color)
    if status and status.Parent then
        status.Text = message
        status.TextColor3 = color or C.muted
    end
end

local function doGrabTest(target)
    if busy then
        setStatus("Sedang menjalankan satu percobaan. Tunggu selesai.", C.yellow)
        return
    end
    if not target or target == LocalPlayer or target.Parent ~= Players then
        setStatus("Target tidak valid.", C.yellow)
        return
    end

    local myChar, myRoot = getRoot(LocalPlayer)
    local targetChar, targetRoot = getRoot(target)
    if not myChar or not myRoot or not targetChar or not targetRoot then
        setStatus("Karakter kamu atau target belum siap.", C.yellow)
        return
    end

    local startCFrame = myRoot.CFrame
    local characterAtStart = myChar
    busy = true
    attemptId += 1
    local thisAttempt = attemptId

    task.spawn(function()
        local function stillCurrent()
            return gui.Parent ~= nil and busy and attemptId == thisAttempt
                and target.Parent == Players
        end

        setStatus("Mendekati " .. target.DisplayName .. "...", C.yellow)

        -- Roblox local +Z is behind the target's facing direction.
        local behind = targetRoot.CFrame * CFrame.new(0, 0, 2.5)
        local moved, moveErr = pcall(function()
            local currentChar = LocalPlayer.Character
            if not currentChar then error("Character unavailable") end
            currentChar:PivotTo(CFrame.lookAt(behind.Position, targetRoot.Position))
        end)

        if not moved then
            setStatus("Teleport mendekat gagal: " .. tostring(moveErr), C.yellow)
            busy = false
            return
        end

        task.wait(0.12)
        if not stillCurrent() then
            busy = false
            return
        end

        -- Use the same server-side Grab path found in GELUT's TP ATTACK.
        local currentChar = LocalPlayer.Character
        local events = currentChar and currentChar:FindFirstChild("Events")
        local grabRemote = events and events:FindFirstChild("Grab")

        if not grabRemote or not grabRemote:IsA("RemoteEvent") then
            -- Return to the saved point if the expected remote is absent.
            pcall(function()
                local c = LocalPlayer.Character
                if c then c:PivotTo(startCFrame) end
            end)
            setStatus("Events.Grab RemoteEvent tidak ditemukan. Tes dihentikan.", C.yellow)
            busy = false
            return
        end

        local fired, fireErr = pcall(function()
            grabRemote:FireServer()
        end)

        if not fired then
            pcall(function()
                local c = LocalPlayer.Character
                if c then c:PivotTo(startCFrame) end
            end)
            setStatus("Pemanggilan Grab gagal: " .. tostring(fireErr), C.yellow)
            busy = false
            return
        end

        setStatus("Grab dipanggil. Kembali ke posisi awal...", C.yellow)
        task.wait(0.22)

        if stillCurrent() then
            pcall(function()
                local c = LocalPlayer.Character
                if c then c:PivotTo(startCFrame) end
            end)
        end

        task.wait(0.45)

        if stillCurrent() then
            local _, myRootAfter = getRoot(LocalPlayer)
            local _, targetRootAfter = getRoot(target)
            if myRootAfter and targetRootAfter then
                local distance = (myRootAfter.Position - targetRootAfter.Position).Magnitude
                if distance <= 12 then
                    setStatus("Target dekat setelah kembali (" ..
                        math.floor(distance) .. " studs). Periksa apakah benar ikut terbawa.", C.green)
                else
                    setStatus("Grab event terkirim, tetapi target belum terlihat ikut dekat (" ..
                        math.floor(distance) .. " studs). Belum terkonfirmasi.", C.yellow)
                end
            else
                setStatus("Grab event terkirim. Status target belum bisa diperiksa.", C.yellow)
            end
        end

        busy = false
    end)
end

local function refreshPlayers()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local targets = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(targets, plr)
        end
    end
    table.sort(targets, function(a, b)
        return string.lower(a.DisplayName .. a.Name) < string.lower(b.DisplayName .. b.Name)
    end)

    for index, target in ipairs(targets) do
        local row = Instance.new("TextButton")
        row.Name = "Target_" .. tostring(target.UserId)
        row.LayoutOrder = index
        row.Size = UDim2.new(1, -2, 0, 27)
        row.BackgroundColor3 = C.row
        row.BorderSizePixel = 0
        row.AutoButtonColor = false
        row.Text = target.DisplayName .. "  (@" .. target.Name .. ")"
        row.TextColor3 = C.white
        row.TextSize = 8
        row.Font = Enum.Font.GothamBold
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.Parent = list
        round(row, 6)

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 7)
        pad.PaddingRight = UDim.new(0, 5)
        pad.Parent = row

        row.Activated:Connect(function()
            doGrabTest(target)
        end)
    end

    if #targets == 0 then
        setStatus("Belum ada player lain di server.")
    else
        setStatus("Ketuk nama player. Satu klik = satu tes Grab.")
    end
end

refresh.Activated:Connect(refreshPlayers)
Players.PlayerAdded:Connect(function()
    task.defer(refreshPlayers)
end)
Players.PlayerRemoving:Connect(function()
    task.defer(refreshPlayers)
end)

refreshPlayers()
