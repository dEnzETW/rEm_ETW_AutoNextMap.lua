-- TP_TARGET_STANDALONE.lua
-- Standalone manual TP TARGET for Roblox client executors.
-- Click a player row: move behind that player once, wait 1.5 seconds,
-- then return to the position where the action started.
-- Grab is intentionally manual: use the game's normal Grab button yourself.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

local GUI_NAME = "TP_TARGET_STANDALONE"
pcall(function()
    local old = CoreGui:FindFirstChild(GUI_NAME)
    if old then old:Destroy() end
end)

local busy = false
local selectedPlayer = nil
local actionToken = 0

local function getCharacterParts(player)
    local character = player and player.Character
    if not character then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not root then return nil end
    return character, humanoid, root
end

local function make(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local gui = make("ScreenGui", {
    Name = GUI_NAME,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, CoreGui)

local main = make("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(235, 285),
    Position = UDim2.new(0.5, -117, 0.35, 0),
    BackgroundColor3 = Color3.fromRGB(24, 26, 31),
    BorderSizePixel = 0
}, gui)
make("UICorner", {CornerRadius = UDim.new(0, 10)}, main)
make("UIStroke", {Color = Color3.fromRGB(75, 80, 90), Thickness = 1}, main)

local top = make("Frame", {
    Size = UDim2.new(1, 0, 0, 38),
    BackgroundColor3 = Color3.fromRGB(34, 37, 44),
    BorderSizePixel = 0
}, main)
make("UICorner", {CornerRadius = UDim.new(0, 10)}, top)

local title = make("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(12, 0),
    Size = UDim2.new(1, -76, 1, 0),
    Font = Enum.Font.GothamSemibold,
    Text = "TP TARGET",
    TextColor3 = Color3.fromRGB(245, 245, 245),
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left
}, top)

local minimize = make("TextButton", {
    Position = UDim2.new(1, -34, 0, 5),
    Size = UDim2.fromOffset(26, 26),
    BackgroundColor3 = Color3.fromRGB(55, 59, 68),
    BorderSizePixel = 0,
    Font = Enum.Font.GothamBold,
    Text = "—",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 16
}, top)
make("UICorner", {CornerRadius = UDim.new(0, 6)}, minimize)

local status = make("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(12, 43),
    Size = UDim2.new(1, -24, 0, 24),
    Font = Enum.Font.Gotham,
    Text = "Pilih player untuk menjalankan TP sekali",
    TextColor3 = Color3.fromRGB(180, 185, 195),
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left
}, main)

local list = make("ScrollingFrame", {
    Name = "PlayerList",
    Position = UDim2.fromOffset(10, 70),
    Size = UDim2.new(1, -20, 1, -80),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    CanvasSize = UDim2.new(0, 0, 0, 0)
}, main)

local layout = make("UIListLayout", {
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.Name
}, list)

local function setStatus(message)
    if status and status.Parent then status.Text = message end
end

local function runOnce(target)
    if busy then
        setStatus("Tunggu proses sebelumnya selesai")
        return
    end
    if not target or target == LocalPlayer then return end

    local _, _, targetRoot = getCharacterParts(target)
    local _, _, myRoot = getCharacterParts(LocalPlayer)
    if not targetRoot or not myRoot then
        setStatus("Character player tidak tersedia")
        return
    end

    busy = true
    actionToken += 1
    local myToken = actionToken
    local startCFrame = myRoot.CFrame

    setStatus("Menuju " .. target.DisplayName .. "...")
    local ok, err = pcall(function()
        local _, _, currentTargetRoot = getCharacterParts(target)
        local _, _, currentMyRoot = getCharacterParts(LocalPlayer)
        if not currentTargetRoot or not currentMyRoot then
            error("Character tidak tersedia")
        end

        -- Berdiri dekat belakang target, tanpa memanggil remote Grab.
        local velocity = currentTargetRoot.AssemblyLinearVelocity
        local predicted = currentTargetRoot.Position + velocity * 0.12
        local behind = -currentTargetRoot.CFrame.LookVector * 2.5
        currentMyRoot.CFrame = CFrame.lookAt(
            predicted + behind + Vector3.new(0, 0.15, 0),
            predicted
        )

        setStatus("Dekat target — gunakan Grab bawaan game")
        task.wait(1.5)

        if myToken == actionToken then
            local _, _, returnRoot = getCharacterParts(LocalPlayer)
            if returnRoot then
                returnRoot.CFrame = startCFrame
            end
        end
    end)

    if myToken == actionToken then
        busy = false
        if ok then
            setStatus("Selesai — kembali ke titik awal")
        else
            local _, _, returnRoot = getCharacterParts(LocalPlayer)
            if returnRoot then pcall(function() returnRoot.CFrame = startCFrame end) end
            setStatus("Gagal: " .. tostring(err))
        end
    end
end

local function refreshPlayers()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local players = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(players, p) end
    end
    table.sort(players, function(a, b)
        return string.lower(a.DisplayName) < string.lower(b.DisplayName)
    end)

    for index, p in ipairs(players) do
        local row = make("TextButton", {
            Name = string.format("%03d_%s", index, p.Name),
            Size = UDim2.new(1, -4, 0, 34),
            BackgroundColor3 = Color3.fromRGB(43, 47, 56),
            BorderSizePixel = 0,
            AutoButtonColor = true,
            Font = Enum.Font.Gotham,
            Text = p.DisplayName .. "  @" .. p.Name,
            TextColor3 = Color3.fromRGB(240, 240, 242),
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        }, list)
        make("UICorner", {CornerRadius = UDim.new(0, 6)}, row)
        make("UIPadding", {PaddingLeft = UDim.new(0, 9)}, row)
        row.MouseButton1Click:Connect(function()
            selectedPlayer = p
            runOnce(p)
        end)
    end

    list.CanvasSize = UDim2.new(0, 0, 0, #players * 39)
    if #players == 0 then
        setStatus("Belum ada player lain di server")
    elseif not busy then
        setStatus("Pilih player untuk menjalankan TP sekali")
    end
end

local minimized = false
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    list.Visible = not minimized
    status.Visible = not minimized
    main.Size = minimized and UDim2.fromOffset(235, 38) or UDim2.fromOffset(235, 285)
    minimize.Text = minimized and "+" or "—"
end)

-- Drag panel with mouse or touch.
local dragging = false
local dragInput, dragStart, startPosition
top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
top.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end)

Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)
refreshPlayers()

print("[TP TARGET STANDALONE] Loaded")
