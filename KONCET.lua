-- ETW ANTI GRAB V2 | PRE-DODGE UI
-- Standalone test. Does not modify GELUT.lua.
-- Earlier warning trigger: nearby player proximity + external constraint detection.
-- Client-side teleport is not guaranteed to override server-authoritative Grab.

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local GUI_NAME = "ETW_ANTI_GRAB_V2"
local enabled, destroyed = false, false

local function guiParent()
    if typeof(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then return result end
    end
    return CoreGui
end

local parent = guiParent()
pcall(function()
    local old = parent:FindFirstChild(GUI_NAME)
    if old then old:Destroy() end
end)

local gui = Instance.new("ScreenGui")
gui.Name = GUI_NAME
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = parent

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(224, 118)
panel.Position = UDim2.new(0.5, -112, 0.32, 0)
panel.BackgroundColor3 = Color3.fromRGB(24, 27, 34)
panel.BorderSizePixel = 0
panel.Active = true
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(75, 82, 96)

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 32)
top.BackgroundColor3 = Color3.fromRGB(34, 38, 48)
top.BorderSizePixel = 0
top.Active = true
top.Parent = panel
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -72, 1, 0)
title.Position = UDim2.fromOffset(11, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "ANTI GRAB V2"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local function makeButton(text, size, pos, color)
    local b = Instance.new("TextButton")
    b.Size, b.Position = size, pos
    b.BackgroundColor3 = color
    b.BorderSizePixel = 0
    b.Font = Enum.Font.GothamBold
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 14
    b.Parent = top
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local minimize = makeButton("—", UDim2.fromOffset(28, 24), UDim2.new(1, -62, 0, 4), Color3.fromRGB(65,72,86))
local close = makeButton("×", UDim2.fromOffset(25, 24), UDim2.new(1, -30, 0, 4), Color3.fromRGB(145,55,60))

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 20)
status.Position = UDim2.fromOffset(10, 42)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.Text = "Status: OFF"
status.TextColor3 = Color3.fromRGB(190,195,205)
status.TextSize = 11
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = panel

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 34)
toggle.Position = UDim2.fromOffset(10, 70)
toggle.BackgroundColor3 = Color3.fromRGB(65,70,82)
toggle.BorderSizePixel = 0
toggle.Font = Enum.Font.GothamBold
toggle.Text = "DEFENSE OFF"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.TextSize = 12
toggle.Parent = panel
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,7)

local minimized = false
local function setEnabled(value)
    enabled = value
    if value then
        toggle.Text = "DEFENSE ON"
        toggle.BackgroundColor3 = Color3.fromRGB(45,125,88)
        status.Text = "Status: PRE-DODGE ACTIVE"
        status.TextColor3 = Color3.fromRGB(115,225,165)
    else
        toggle.Text = "DEFENSE OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(65,70,82)
        status.Text = "Status: OFF"
        status.TextColor3 = Color3.fromRGB(190,195,205)
    end
end

toggle.MouseButton1Click:Connect(function() setEnabled(not enabled) end)
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    status.Visible, toggle.Visible = not minimized, not minimized
    panel.Size = minimized and UDim2.fromOffset(224,32) or UDim2.fromOffset(224,118)
    minimize.Text = minimized and "+" or "—"
end)
close.MouseButton1Click:Connect(function()
    destroyed, enabled = true, false
    gui:Destroy()
end)

-- Drag panel using title bar.
do
    local dragging, dragStart, startPos = false, nil, nil
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, panel.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- Detection and dodge settings.
local DANGER_RADIUS = 18       -- studs; proximity pre-warning
local UP_HEIGHT = 4000
local RANDOM_MIN, RANDOM_MAX = 120, 260
local DODGE_COOLDOWN = 2.0
local UP_WAIT = 0.20

local character, root
local lastDodge = 0
local armed = true
local characterAddedConnection

local function ownPart(part)
    return part and part:IsA("BasePart") and character and part:IsDescendantOf(character)
end

local function externalJoint(item)
    if not item then return false end
    local p0, p1
    if item:IsA("WeldConstraint") or item:IsA("Weld") or item:IsA("Motor6D") then
        p0, p1 = item.Part0, item.Part1
    elseif item:IsA("RopeConstraint") or item:IsA("RodConstraint")
        or item:IsA("SpringConstraint") or item:IsA("AlignPosition")
        or item:IsA("AlignOrientation") then
        local a0, a1 = item.Attachment0, item.Attachment1
        p0, p1 = a0 and a0.Parent, a1 and a1.Parent
    else
        return false
    end
    local a, b = ownPart(p0), ownPart(p1)
    return (a and p1 and not p1:IsDescendantOf(character))
        or (b and p0 and not p0:IsDescendantOf(character))
end

local function randomOffset()
    local angle = math.random() * math.pi * 2
    local dist = math.random(RANDOM_MIN, RANDOM_MAX)
    return Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
end

local function dodge(reason)
    if not enabled or destroyed or not armed then return end
    if not character or not character.Parent or not root or not root.Parent then return end
    if os.clock() - lastDodge < DODGE_COOLDOWN then return end

    lastDodge = os.clock()
    armed = false
    local origin = root.Position

    status.Text = "Status: DODGING!"
    pcall(function()
        character:PivotTo(CFrame.new(origin + Vector3.new(0, UP_HEIGHT, 0)))
    end)

    task.wait(UP_WAIT)

    if enabled and character and character.Parent and root and root.Parent then
        pcall(function()
            character:PivotTo(CFrame.new(origin + randomOffset()))
        end)
    end

    status.Text = enabled and "Status: PRE-DODGE ACTIVE" or "Status: OFF"
    warn("[ANTI GRAB V2] Dodge trigger:", reason)

    -- Re-arm after the nearby player has moved away, or after a short timeout.
    task.spawn(function()
        local started = os.clock()
        while enabled and not destroyed and os.clock() - started < 3 do
            task.wait(0.08)
            local someoneNear = false
            if root and root.Parent then
                for _, other in ipairs(Players:GetPlayers()) do
                    if other ~= player and other.Character then
                        local otherRoot = other.Character:FindFirstChild("HumanoidRootPart")
                        if otherRoot and (otherRoot.Position - root.Position).Magnitude <= DANGER_RADIUS then
                            someoneNear = true
                            break
                        end
                    end
                end
            end
            if not someoneNear then break end
        end
        armed = true
    end)
end

local function setupCharacter(newCharacter)
    character = newCharacter
    root = character:WaitForChild("HumanoidRootPart", 10)
end

player.CharacterAdded:Connect(setupCharacter)
if player.Character then task.spawn(setupCharacter, player.Character) end

-- Per-frame proximity check is more responsive than a 0.12s polling loop.
local renderConnection
renderConnection = RunService.RenderStepped:Connect(function()
    if destroyed then
        if renderConnection then renderConnection:Disconnect() end
        return
    end
    if not enabled or not root or not root.Parent then return end

    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and other.Character then
            local otherRoot = other.Character:FindFirstChild("HumanoidRootPart")
            if otherRoot then
                local distance = (otherRoot.Position - root.Position).Magnitude
                if distance <= DANGER_RADIUS then
                    dodge("player entered " .. DANGER_RADIUS .. "-stud danger radius")
                    return
                end
            end
        end
    end

    -- Also check for an external joint/constraint, as a secondary signal.
    if character then
        for _, item in ipairs(character:GetDescendants()) do
            if externalJoint(item) then
                dodge("external " .. item.ClassName)
                return
            end
        end
    end
end)

setEnabled(false)
warn("[ANTI GRAB V2] UI loaded. Enable DEFENSE to activate proximity pre-dodge.")
