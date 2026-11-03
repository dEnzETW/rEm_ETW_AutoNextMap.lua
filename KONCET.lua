-- ETW ANTI GRAB | UI TEST
-- Standalone file. Does not modify GELUT.lua.
-- UI: draggable panel, minimize, close, ON/OFF toggle.
-- Detection is heuristic: it watches for external joints/constraints.
-- Client-side teleport may be rejected or overridden by the game server.

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local GUI_NAME = "ETW_ANTI_GRAB_UI"
local enabled = false
local destroyed = false

-- Remove an older copy so the panel can always be recreated.
local function getGuiParent()
    if typeof(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    local ok, core = pcall(function() return CoreGui end)
    if ok and core then return core end
    return player:WaitForChild("PlayerGui")
end

local guiParent = getGuiParent()
pcall(function()
    local old = guiParent:FindFirstChild(GUI_NAME)
    if old then old:Destroy() end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = GUI_NAME
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = guiParent

local panel = Instance.new("Frame")
panel.Name = "Main"
panel.Size = UDim2.fromOffset(224, 118)
panel.Position = UDim2.new(0.5, -112, 0.35, 0)
panel.BackgroundColor3 = Color3.fromRGB(24, 27, 34)
panel.BorderSizePixel = 0
panel.Active = true
panel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 10)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(75, 82, 96)
panelStroke.Thickness = 1
panelStroke.Parent = panel

local top = Instance.new("Frame")
top.Name = "TopBar"
top.Size = UDim2.new(1, 0, 0, 32)
top.BackgroundColor3 = Color3.fromRGB(34, 38, 48)
top.BorderSizePixel = 0
top.Active = true
top.Parent = panel

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 10)
topCorner.Parent = top

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -72, 1, 0)
title.Position = UDim2.fromOffset(11, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "ANTI GRAB"
title.TextColor3 = Color3.fromRGB(245, 247, 250)
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(28, 24)
minimize.Position = UDim2.new(1, -62, 0, 4)
minimize.BackgroundColor3 = Color3.fromRGB(65, 72, 86)
minimize.BorderSizePixel = 0
minimize.Font = Enum.Font.GothamBold
minimize.Text = "—"
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.TextSize = 14
minimize.Parent = top
Instance.new("UICorner", minimize).CornerRadius = UDim.new(0, 6)

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(25, 24)
close.Position = UDim2.new(1, -30, 0, 4)
close.BackgroundColor3 = Color3.fromRGB(145, 55, 60)
close.BorderSizePixel = 0
close.Font = Enum.Font.GothamBold
close.Text = "×"
close.TextColor3 = Color3.new(1, 1, 1)
close.TextSize = 16
close.Parent = top
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 20)
status.Position = UDim2.fromOffset(10, 42)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.Text = "Status: OFF"
status.TextColor3 = Color3.fromRGB(190, 195, 205)
status.TextSize = 11
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = panel

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 34)
toggle.Position = UDim2.fromOffset(10, 70)
toggle.BackgroundColor3 = Color3.fromRGB(65, 70, 82)
toggle.BorderSizePixel = 0
toggle.Font = Enum.Font.GothamBold
toggle.Text = "DEFENSE OFF"
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.TextSize = 12
toggle.Parent = panel
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 7)

local minimized = false
local function setEnabled(value)
    enabled = value
    if enabled then
        toggle.Text = "DEFENSE ON"
        toggle.BackgroundColor3 = Color3.fromRGB(45, 125, 88)
        status.Text = "Status: MONITORING"
        status.TextColor3 = Color3.fromRGB(115, 225, 165)
    else
        toggle.Text = "DEFENSE OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(65, 70, 82)
        status.Text = "Status: OFF"
        status.TextColor3 = Color3.fromRGB(190, 195, 205)
    end
end

toggle.MouseButton1Click:Connect(function()
    setEnabled(not enabled)
end)

minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    status.Visible = not minimized
    toggle.Visible = not minimized
    panel.Size = minimized and UDim2.fromOffset(224, 32) or UDim2.fromOffset(224, 118)
    minimize.Text = minimized and "+" or "—"
end)

close.MouseButton1Click:Connect(function()
    destroyed = true
    enabled = false
    screenGui:Destroy()
end)

-- Drag the panel by its title bar.
do
    local dragging = false
    local dragInput
    local dragStart
    local startPosition

    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = panel.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
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
        if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            panel.Position = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
        end
    end)
end

-- Anti-grab monitor settings.
local UP_HEIGHT = 4000
local RANDOM_MIN = 120
local RANDOM_MAX = 260
local SCAN_INTERVAL = 0.12
local ESCAPE_COOLDOWN = 2
local UP_WAIT = 0.25

local character, root
local lastEscape = 0
local characterConnection

local function isOurPart(part)
    return part and part:IsA("BasePart")
        and character and part:IsDescendantOf(character)
end

local function isExternalConstraint(item)
    if not item then return false end
    local p0, p1

    if item:IsA("WeldConstraint") or item:IsA("Weld") or item:IsA("Motor6D") then
        p0, p1 = item.Part0, item.Part1
    elseif item:IsA("RopeConstraint") or item:IsA("RodConstraint")
        or item:IsA("SpringConstraint") or item:IsA("AlignPosition")
        or item:IsA("AlignOrientation") then
        local a0, a1 = item.Attachment0, item.Attachment1
        p0 = a0 and a0.Parent
        p1 = a1 and a1.Parent
    else
        return false
    end

    local own0, own1 = isOurPart(p0), isOurPart(p1)
    return (own0 and p1 and not p1:IsDescendantOf(character))
        or (own1 and p0 and not p0:IsDescendantOf(character))
end

local function findExternalConstraint()
    if not character then return nil end
    for _, item in ipairs(character:GetDescendants()) do
        if isExternalConstraint(item) then return item end
    end
    return nil
end

local function randomOffset()
    local angle = math.random() * math.pi * 2
    local distance = math.random(RANDOM_MIN, RANDOM_MAX)
    return Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)
end

local function escape(reason)
    if not enabled or destroyed or not character or not character.Parent
        or not root or not root.Parent then return end

    local now = os.clock()
    if now - lastEscape < ESCAPE_COOLDOWN then return end
    lastEscape = now

    local originalPosition = root.Position
    local ok = pcall(function()
        character:PivotTo(CFrame.new(originalPosition + Vector3.new(0, UP_HEIGHT, 0)))
    end)

    if not ok then
        status.Text = "Status: TELEPORT FAILED"
        return
    end

    status.Text = "Status: DODGING..."
    task.wait(UP_WAIT)

    if enabled and character and character.Parent and root and root.Parent then
        pcall(function()
            character:PivotTo(CFrame.new(originalPosition + randomOffset()))
        end)
        status.Text = "Status: MONITORING"
    end

    warn("[ANTI GRAB] Dodge attempt:", reason or "external constraint")
end

local function setupCharacter(newCharacter)
    character = newCharacter
    root = character:WaitForChild("HumanoidRootPart", 10)
    if not root then
        status.Text = "Status: CHARACTER NOT READY"
        return
    end

    if characterConnection then
        characterConnection:Disconnect()
        characterConnection = nil
    end

    characterConnection = character.DescendantAdded:Connect(function(item)
        if enabled and isExternalConstraint(item) then
            task.spawn(function()
                escape("new " .. item.ClassName)
            end)
        end
    end)

    status.Text = enabled and "Status: MONITORING" or "Status: OFF"
end

player.CharacterAdded:Connect(setupCharacter)
if player.Character then
    task.spawn(setupCharacter, player.Character)
end

task.spawn(function()
    while not destroyed and screenGui.Parent do
        task.wait(SCAN_INTERVAL)
        if enabled then
            local item = findExternalConstraint()
            if item then
                escape("scan found " .. item.ClassName)
            end
        end
    end
end)

setEnabled(false)
warn("[ANTI GRAB] UI loaded. Tap DEFENSE ON to enable monitoring.")
