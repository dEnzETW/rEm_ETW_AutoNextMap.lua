-- ETW.DRAMA — TEST ONLY: Teleport / Grab User panel
-- Layout follows the TP ATTACK player-list pattern:
-- one player per row, DisplayName (@username), ON/OFF toggle on that row.
-- SAFE UI PROTOTYPE: ON/OFF only updates preview status; it does not teleport,
-- grab, attach, or control players in Eat the World or any third-party game.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("ETWDRAMA_TEST_TeleportGrabPanel")
if old then old:Destroy() end

local camera = workspace.CurrentCamera
local isSmallScreen = camera and camera.ViewportSize.X < 700

local C = {
    panel = Color3.fromRGB(7, 18, 27),
    row = Color3.fromRGB(8, 30, 40),
    selected = Color3.fromRGB(0, 67, 82),
    cyan = Color3.fromRGB(0, 220, 255),
    cyanSoft = Color3.fromRGB(42, 118, 135),
    text = Color3.fromRGB(245, 250, 255),
    muted = Color3.fromRGB(155, 180, 190),
    button = Color3.fromRGB(15, 48, 61),
    on = Color3.fromRGB(0, 145, 115),
    off = Color3.fromRGB(55, 66, 73),
}

local gui = Instance.new("ScreenGui")
gui.Name = "ETWDRAMA_TEST_TeleportGrabPanel"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = PlayerGui

local panel = Instance.new("Frame")
panel.Name = "TeleportGrabPanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(isSmallScreen and 320 or 390, isSmallScreen and 420 or 485)
panel.BackgroundColor3 = C.panel
panel.BorderSizePixel = 0
panel.Parent = gui

local pc = Instance.new("UICorner")
pc.CornerRadius = UDim.new(0, 10)
pc.Parent = panel
local ps = Instance.new("UIStroke")
ps.Color = C.cyanSoft
ps.Thickness = 1.2
ps.Parent = panel

local function makeLabel(parent, name, text, size, pos, textSize, color, font)
    local o = Instance.new("TextLabel")
    o.Name = name
    o.Size = size
    o.Position = pos
    o.BackgroundTransparency = 1
    o.Text = text
    o.TextColor3 = color or C.text
    o.Font = font or Enum.Font.GothamBold
    o.TextSize = textSize or 12
    o.TextXAlignment = Enum.TextXAlignment.Left
    o.TextTruncate = Enum.TextTruncate.AtEnd
    o.Parent = parent
    return o
end

makeLabel(panel, "Title", "TELEPORT + GRAB USER",
    UDim2.new(1, -28, 0, 28), UDim2.fromOffset(14, 10),
    isSmallScreen and 14 or 16, C.cyan, Enum.Font.GothamBlack)
makeLabel(panel, "Subtitle", "PLAYER CONTROL • TEST ONLY",
    UDim2.new(1, -28, 0, 18), UDim2.fromOffset(14, 38), 10, C.muted)

local status = makeLabel(panel, "Status", "Pilih pemain dari daftar",
    UDim2.new(1, -28, 0, 22), UDim2.fromOffset(14, 62), 11, C.text)

local list = Instance.new("ScrollingFrame")
list.Name = "TeleportGrabPlayerList"
list.Position = UDim2.fromOffset(10, 90)
list.Size = UDim2.new(1, -20, 0, isSmallScreen and 205 or 265)
list.BackgroundColor3 = Color3.fromRGB(5, 14, 21)
list.BorderSizePixel = 0
list.ScrollBarThickness = isSmallScreen and 5 or 7
list.ScrollBarImageColor3 = C.cyan
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new()
list.ScrollingDirection = Enum.ScrollingDirection.Y
list.Active = true
list.Parent = panel

local lc = Instance.new("UICorner")
lc.CornerRadius = UDim.new(0, 8)
lc.Parent = list
local ls = Instance.new("UIStroke")
ls.Color = C.cyanSoft
ls.Thickness = 0.8
ls.Parent = list
local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 5)
pad.PaddingBottom = UDim.new(0, 5)
pad.PaddingLeft = UDim.new(0, 5)
pad.PaddingRight = UDim.new(0, 5)
pad.Parent = list
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 4)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local selectedPlayer
local rowByUserId = {}
local enabledByUserId = {}

local function makeButton(parent, name, text, position, size, callback, color)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Position = position
    btn.Size = size
    btn.BackgroundColor3 = color or C.button
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = true
    btn.Text = text
    btn.TextColor3 = C.text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = btn
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.cyanSoft
    stroke.Thickness = 0.8
    stroke.Parent = btn
    btn.Activated:Connect(callback)
    return btn
end

local function updateRow(row, target)
    local active = enabledByUserId[target.UserId] == true
    local chosen = selectedPlayer == target
    row.BackgroundColor3 = chosen and C.selected or C.row
    local stroke = row:FindFirstChildOfClass("UIStroke")
    if stroke then
        stroke.Color = chosen and C.cyan or C.cyanSoft
        stroke.Thickness = chosen and 1.6 or 0.8
    end
    local toggle = row:FindFirstChild("PlayerActionToggle")
    if toggle then
        toggle.Text = active and "ON" or "OFF"
        toggle.BackgroundColor3 = active and C.on or C.off
    end
end

local function refreshPlayers()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("Frame") and child.Name:sub(1, 14) == "TestTargetRow_" then
            child:Destroy()
        end
    end
    rowByUserId = {}

    local allPlayers = Players:GetPlayers()
    table.sort(allPlayers, function(a, b)
        return string.lower(a.DisplayName .. a.Name) < string.lower(b.DisplayName .. b.Name)
    end)

    local count = 0
    for _, target in ipairs(allPlayers) do
        if target ~= LocalPlayer then
            count += 1
            if enabledByUserId[target.UserId] == nil then
                enabledByUserId[target.UserId] = false
            end

            local row = Instance.new("Frame")
            row.Name = "TestTargetRow_" .. tostring(target.UserId)
            row.Size = UDim2.new(1, -2, 0, isSmallScreen and 48 or 54)
            row.BackgroundColor3 = C.row
            row.BorderSizePixel = 0
            row.LayoutOrder = count
            row.Parent = list

            local rc = Instance.new("UICorner")
            rc.CornerRadius = UDim.new(0, 9)
            rc.Parent = row
            local rs = Instance.new("UIStroke")
            rs.Color = C.cyanSoft
            rs.Thickness = 0.8
            rs.Parent = row

            local nameButton = Instance.new("TextButton")
            nameButton.Name = "PlayerName"
            nameButton.Position = UDim2.fromOffset(0, 0)
            nameButton.Size = UDim2.new(1, -78, 1, 0)
            nameButton.BackgroundTransparency = 1
            nameButton.AutoButtonColor = false
            nameButton.Text = target.DisplayName .. " (@" .. target.Name .. ")"
            nameButton.TextColor3 = C.text
            nameButton.Font = Enum.Font.GothamBlack
            nameButton.TextSize = isSmallScreen and 12 or 14
            nameButton.TextXAlignment = Enum.TextXAlignment.Left
            nameButton.TextTruncate = Enum.TextTruncate.AtEnd
            nameButton.Parent = row
            local np = Instance.new("UIPadding")
            np.PaddingLeft = UDim.new(0, 10)
            np.PaddingRight = UDim.new(0, 4)
            np.Parent = nameButton

            local toggle = Instance.new("TextButton")
            toggle.Name = "PlayerActionToggle"
            toggle.AnchorPoint = Vector2.new(1, 0.5)
            toggle.Position = UDim2.new(1, -6, 0.5, 0)
            toggle.Size = UDim2.fromOffset(isSmallScreen and 62 or 68, isSmallScreen and 30 or 34)
            toggle.BorderSizePixel = 0
            toggle.Font = Enum.Font.GothamBlack
            toggle.TextSize = 12
            toggle.TextColor3 = C.text
            toggle.Parent = row
            local tc = Instance.new("UICorner")
            tc.CornerRadius = UDim.new(0, 8)
            tc.Parent = toggle
            local ts = Instance.new("UIStroke")
            ts.Color = C.cyanSoft
            ts.Thickness = 0.8
            ts.Parent = toggle

            rowByUserId[target.UserId] = row

            nameButton.Activated:Connect(function()
                selectedPlayer = target
                status.Text = "Dipilih: " .. target.DisplayName .. " (@" .. target.Name .. ")"
                for _, other in pairs(rowByUserId) do
                    local id = tonumber(other.Name:match("(%d+)$"))
                    local p = id and Players:GetPlayerByUserId(id)
                    if p then updateRow(other, p) end
                end
            end)

            toggle.Activated:Connect(function()
                local newValue = not enabledByUserId[target.UserId]
                enabledByUserId[target.UserId] = newValue
                selectedPlayer = target
                updateRow(row, target)
                if newValue then
                    status.Text = "ON (preview): " .. target.DisplayName .. " — aksi tidak dijalankan"
                else
                    status.Text = "OFF: " .. target.DisplayName
                end
            end)

            updateRow(row, target)
        end
    end

    if count == 0 then
        status.Text = "Tidak ada pemain lain di server"
    elseif not selectedPlayer or not selectedPlayer.Parent then
        status.Text = "Pilih pemain dari daftar"
    end
end

makeButton(panel, "RefreshPlayers", "REFRESH PLAYERS",
    UDim2.fromOffset(10, isSmallScreen and 305 or 365),
    UDim2.new(1, -20, 0, 32), refreshPlayers, C.button)

makeLabel(panel, "SafetyNote",
    "ON/OFF hanya mengubah status UI; teleport/grab tidak dijalankan.",
    UDim2.new(1, -20, 0, 28),
    UDim2.fromOffset(10, isSmallScreen and 344 or 404),
    9, C.muted, Enum.Font.Gotham)

Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(function(leaving)
    enabledByUserId[leaving.UserId] = nil
    if selectedPlayer == leaving then
        selectedPlayer = nil
        status.Text = "Pemain terpilih keluar — pilih lagi"
    end
    task.defer(refreshPlayers)
end)

refreshPlayers()
