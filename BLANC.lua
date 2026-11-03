
-- ETW GLOBAL LOOT V6
-- Based on Test.lua: canCollect + instantMagnet
-- Standalone | Original Test.lua remains unchanged

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
if not player then return end

local ENV = (getgenv and getgenv()) or _G

-- Cleanup previous V6
if ENV._ETW_GLOBAL_LOOT_V6 then
    pcall(function()
        ENV._ETW_GLOBAL_LOOT_V6:Destroy()
    end)
end

local running = true
local enabled = false

local targets = {}
local lastTouch = {}

local detected = 0
local attempted = 0
local removed = 0

local SCAN_INTERVAL = 0.35
local TOUCH_COOLDOWN = 0.8

local VALID_DROPS = {
    Token = true,
    Candy = true
}

-- Same eligibility logic as Test.lua
local function canCollect(item)
    if not item or not item:IsA("BasePart") or not item.Parent then
        return false
    end

    if not VALID_DROPS[item.Name] then
        return false
    end

    local owner = item:FindFirstChild("Owner")
    local timeLeft = item:FindFirstChild("TimeLeft")

    if owner and owner.Value ~= "" and owner.Value ~= player.Name then
        if timeLeft and tonumber(timeLeft.Value) and timeLeft.Value > 0 then
            return false
        end
    end

    return true
end

-- Register exact loot parts anywhere in Workspace
local function register(obj)
    if obj and obj:IsA("BasePart") and VALID_DROPS[obj.Name] then
        targets[obj] = true
    end
end

local function unregister(obj)
    if targets[obj] then
        targets[obj] = nil
        lastTouch[obj] = nil
        removed += 1
    end
end

-- Initial global scan
for _, obj in ipairs(Workspace:GetDescendants()) do
    register(obj)
end

-- Monitor newly replicated loot
local addedConnection = Workspace.DescendantAdded:Connect(register)
local removingConnection = Workspace.DescendantRemoving:Connect(unregister)

local function getRoot()
    local character = player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

-- UI parent
local guiParent

pcall(function()
    if typeof(gethui) == "function" then
        guiParent = gethui()
    end
end)

guiParent = guiParent or player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "ETWGlobalLootV6"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = guiParent

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(205, 172)
frame.Position = UDim2.new(0, 18, 0.48, 0)
frame.BackgroundColor3 = Color3.fromRGB(17, 21, 28)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 11)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(75, 90, 105)
stroke.Thickness = 1
stroke.Parent = frame

local function makeLabel(text, y, height, bold)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 0, height)
    label.Position = UDim2.fromOffset(8, y)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(240, 244, 248)
    label.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    return label
end

makeLabel("GLOBAL LOOT MAGNET V6", 6, 22, true)

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -16, 0, 29)
toggle.Position = UDim2.fromOffset(8, 32)
toggle.BackgroundColor3 = Color3.fromRGB(105, 45, 45)
toggle.Text = "MAGNET : OFF"
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 12
toggle.Parent = frame

Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 7)

local detectedLabel = makeLabel("DETECTED : 0", 68, 18, false)
local attemptedLabel = makeLabel("TOUCH ATTEMPTS : 0", 88, 18, false)
local removedLabel = makeLabel("REMOVED : 0 (UNVERIFIED)", 108, 18, false)
local statusLabel = makeLabel("STATUS : READY", 128, 18, true)

local reset = Instance.new("TextButton")
reset.Size = UDim2.new(1, -16, 0, 21)
reset.Position = UDim2.fromOffset(8, 148)
reset.BackgroundColor3 = Color3.fromRGB(48, 57, 68)
reset.Text = "RESET COUNTERS"
reset.TextColor3 = Color3.new(1, 1, 1)
reset.Font = Enum.Font.GothamBold
reset.TextSize = 10
reset.Parent = frame

Instance.new("UICorner", reset).CornerRadius = UDim.new(0, 6)

local function updateUI()
    detectedLabel.Text = "DETECTED : " .. detected
    attemptedLabel.Text = "TOUCH ATTEMPTS : " .. attempted
    removedLabel.Text = "REMOVED : " .. removed .. " (UNVERIFIED)"
    statusLabel.Text = enabled and "STATUS : SCANNING" or "STATUS : READY"
end

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled

    toggle.Text = enabled and "MAGNET : ON" or "MAGNET : OFF"
    toggle.BackgroundColor3 = enabled
        and Color3.fromRGB(30, 115, 75)
        or Color3.fromRGB(105, 45, 45)

    updateUI()
end)

reset.MouseButton1Click:Connect(function()
    detected = 0
    attempted = 0
    removed = 0
    updateUI()
end)

-- Draggable panel: touch and mouse
local dragging = false
local dragInput
local dragStart
local startPosition

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then

        dragging = true
        dragStart = input.Position
        startPosition = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart

        frame.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

-- Global scanner + original touch mechanism
task.spawn(function()
    while running do
        if enabled then
            local root = getRoot()
            detected = 0

            if root and typeof(firetouchinterest) == "function" then
                for item in pairs(targets) do
                    if item.Parent and canCollect(item) then
                        detected += 1

                        local now = os.clock()
                        local previous = lastTouch[item] or 0

                        if now - previous >= TOUCH_COOLDOWN then
                            lastTouch[item] = now

                            local success = pcall(function()
                                firetouchinterest(root, item, 0)
                                firetouchinterest(root, item, 1)
                            end)

                            if success then
                                attempted += 1
                            end
                        end
                    end
                end
            end

            updateUI()
        end

        task.wait(SCAN_INTERVAL)
    end
end)

local controller = {}

function controller:Destroy()
    running = false
    enabled = false

    if addedConnection then
        addedConnection:Disconnect()
    end

    if removingConnection then
        removingConnection:Disconnect()
    end

    gui:Destroy()
end

ENV._ETW_GLOBAL_LOOT_V6 = controller

print("ETW GLOBAL LOOT V6 loaded")

