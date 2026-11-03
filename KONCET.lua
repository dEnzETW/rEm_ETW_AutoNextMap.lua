
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local PLATFORM_NAME = "ETW_DRAMA_BIG_FF_TEST"

local PLATFORM_SIZE = Vector3.new(10000000,5000,10000000)
local PLATFORM_POSITION = Vector3.new(0, -6, 0)

local platform = nil

local function removePlatform()
    local existing = Workspace:FindFirstChild(PLATFORM_NAME)
    if existing then
        pcall(function()
            existing:Destroy()
        end)
    end
    platform = nil
end

local function createPlatform()
    if platform and platform.Parent then
        return
    end

    -- Clean up an older test copy first.
    removePlatform()

    local part = Instance.new("Part")
    part.Name = PLATFORM_NAME
    part.Size = PLATFORM_SIZE
    part.Position = PLATFORM_POSITION
    part.Anchored = true
    part.CanCollide = true
    part.Transparency = 1
    part.Material = Enum.Material.Fabric
    part.Parent = Workspace

    platform = part
    print("[BIG FF TEST] Created:", part.Name, part.Size)
end

-- Recreate after respawn if the test platform was removed.
player.CharacterAdded:Connect(function()
    task.wait(1)
    if not platform or not platform.Parent then
        createPlatform()
    end
end)

-- Create immediately.
createPlatform()

-- Optional cleanup helper:
-- Run this line in the executor console if you want to remove the test platform:
-- game:GetService("Workspace"):FindFirstChild("ETW_DRAMA_BIG_FF_TEST"):Destroy()
