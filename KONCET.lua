-- ANTI GRAB TEST
-- Standalone prototype for Eat The World.
-- Does NOT modify GELUT.lua.
--
-- Behavior:
--   1. Watches the local character for suspicious external constraints.
--   2. If a likely grab is detected, teleports 4,000 studs upward.
--   3. Then moves to a random offset near the pre-escape location.
--
-- IMPORTANT:
--   This is heuristic detection, not guaranteed protection. The server may
--   reject/undo client-side teleports, and some grab systems are not visible
--   through client-side constraints. False positives are possible.
--
-- To stop: set _G.ETW_ANTI_GRAB_TEST = false in the executor.

local Players = game:GetService("Players")
local player = Players.LocalPlayer

_G.ETW_ANTI_GRAB_TEST = true

local UP_HEIGHT = 4000
local RANDOM_MIN = 120
local RANDOM_MAX = 260
local SCAN_INTERVAL = 0.12
local ESCAPE_COOLDOWN = 2.0
local UP_WAIT = 0.25

local character, humanoid, root
local lastEscape = 0
local connections = {}

local function disconnectConnections()
    for _, connection in ipairs(connections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(connections)
end

local function isOurPart(part)
    return part and part:IsA("BasePart")
        and character and part:IsDescendantOf(character)
end

local function externalConstraint(instance)
    if not instance then return false end

    local p0, p1

    if instance:IsA("WeldConstraint")
        or instance:IsA("Weld")
        or instance:IsA("Motor6D") then
        p0, p1 = instance.Part0, instance.Part1

    elseif instance:IsA("RopeConstraint")
        or instance:IsA("RodConstraint")
        or instance:IsA("SpringConstraint")
        or instance:IsA("AlignPosition")
        or instance:IsA("AlignOrientation") then

        local a0, a1 = instance.Attachment0, instance.Attachment1
        p0 = a0 and a0.Parent
        p1 = a1 and a1.Parent

    else
        return false
    end

    local own0, own1 = isOurPart(p0), isOurPart(p1)
    return (own0 and p1 and not p1:IsDescendantOf(character))
        or (own1 and p0 and not p0:IsDescendantOf(character))
end

local function findGrabConstraint()
    if not character then return nil end
    for _, item in ipairs(character:GetDescendants()) do
        if externalConstraint(item) then
            return item
        end
    end
end

local function randomOffset()
    local angle = math.random() * math.pi * 2
    local distance = math.random(RANDOM_MIN, RANDOM_MAX)
    return Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)
end

local function escape(reason)
    if not _G.ETW_ANTI_GRAB_TEST then return end
    if not character or not character.Parent or not root or not root.Parent then return end

    local now = os.clock()
    if now - lastEscape < ESCAPE_COOLDOWN then return end
    lastEscape = now

    local originalPosition = root.Position

    pcall(function()
        character:PivotTo(CFrame.new(originalPosition + Vector3.new(0, UP_HEIGHT, 0)))
    end)

    task.wait(UP_WAIT)

    if _G.ETW_ANTI_GRAB_TEST and character and character.Parent and root and root.Parent then
        pcall(function()
            character:PivotTo(CFrame.new(originalPosition + randomOffset()))
        end)
    end

    warn("[ANTI GRAB TEST] Escape triggered:", reason or "possible grab")
end

local function setupCharacter(newCharacter)
    disconnectConnections()
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid", 10)
    root = character:WaitForChild("HumanoidRootPart", 10)

    if not humanoid or not root then
        warn("[ANTI GRAB TEST] Character parts not ready.")
        return
    end

    table.insert(connections, character.DescendantAdded:Connect(function(item)
        if externalConstraint(item) then
            task.spawn(function()
                escape("new external " .. item.ClassName)
            end)
        end
    end))

    warn("[ANTI GRAB TEST] Monitoring character for possible Grab.")
end

player.CharacterAdded:Connect(setupCharacter)
if player.Character then
    setupCharacter(player.Character)
end

task.spawn(function()
    while _G.ETW_ANTI_GRAB_TEST do
        task.wait(SCAN_INTERVAL)
        local constraint = findGrabConstraint()
        if constraint then
            escape("scan found " .. constraint.ClassName)
        end
    end
end)

warn("[ANTI GRAB TEST] Loaded. Set _G.ETW_ANTI_GRAB_TEST = false to stop.")
