--[[
ETW.DRAMA - RAW TP FARM STANDALONE TEST
Purpose: isolate the TP Farm behavior from the user's original RAW source.
This is a separate test script; it does not edit ETW.DRAMA Revisi 11.
Auto EAT is not included as a separate feature.
The original RAW TP Farm's Grab -> ChunkLoaded -> Eat sequence and tpDelay=0.05
are retained for the first baseline test.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("ETW_RAW_TPFarm_Test")
if oldGui then oldGui:Destroy() end

local states = {
    randomTPFarm = false,
    autoSell = true,
    tpDelay = 0.05,
}

local GROUND_KEYWORDS = {
    "ground", "grass", "dirt", "soil", "sand", "floor",
    "road", "path", "terrain", "base", "plate", "mud", "earth"
}

local GROUND_MATERIALS = {
    [Enum.Material.Grass] = true,
    [Enum.Material.Ground] = true,
    [Enum.Material.Mud] = true,
    [Enum.Material.Sand] = true,
    [Enum.Material.LeafyGrass] = true,
    [Enum.Material.Cobblestone] = true,
    [Enum.Material.Asphalt] = true,
    [Enum.Material.Slate] = true
}

local function getCharEvents()
    local char = player.Character
    if not char then return nil end
    local ev = char:FindFirstChild("Events")
    if ev then
        return {
            Grab = ev:FindFirstChild("Grab"),
            Eat = ev:FindFirstChild("Eat"),
            Throw = ev:FindFirstChild("Throw"),
            Sell = ev:FindFirstChild("Sell"),
            ChunkLoaded = ev:FindFirstChild("ChunkLoaded")
        }
    end
    return nil
end

local isFullServerFlag = false
local function hookServerEatError()
    local char = player.Character
    if not char then return end
    local ev = char:FindFirstChild("Events")
    if ev and ev:FindFirstChild("Eat") then
        ev.Eat.OnClientEvent:Connect(function()
            isFullServerFlag = true
        end)
    end
end
hookServerEatError()
player.CharacterAdded:Connect(function()
    task.wait(1)
    hookServerEatError()
end)

local function isInventoryFull()
    if isFullServerFlag then return true end

    local pg = player:FindFirstChild("PlayerGui")
    local screen = pg and pg:FindFirstChild("ScreenGui")
    local sellGui = screen and screen:FindFirstChild("Sell")
    if sellGui then
        local warn = sellGui:FindFirstChild("WarningText")
        if warn and warn.Visible and warn.TextTransparency < 0.5 then
            return true
        end
        local sellText = sellGui:FindFirstChild("SellText")
        if sellText and sellText.Visible then return true end
        local bar = sellGui:FindFirstChild("ProgressBar")
        if bar and bar.Size.X.Scale >= 0.98 then return true end
    end
    return false
end

local function executeSell()
    local events = getCharEvents()
    if events and events.Sell then events.Sell:FireServer() end

    local pg = player:FindFirstChild("PlayerGui")
    local screen = pg and pg:FindFirstChild("ScreenGui")
    local sellGui = screen and screen:FindFirstChild("Sell")
    if sellGui then
        local btn = sellGui:FindFirstChild("SellButton")
        if btn and typeof(firesignal) == "function" then
            firesignal(btn.Activated)
            firesignal(btn.MouseButton1Click)
        end
    end
    isFullServerFlag = false
end

local function isGroundPart(part)
    if not part or not part:IsA("BasePart") then return false end
    if part.Material and GROUND_MATERIALS[part.Material] then return true end

    local lowerName = string.lower(part.Name)
    for _, keyword in ipairs(GROUND_KEYWORDS) do
        if string.find(lowerName, keyword, 1, true) then return true end
    end

    if part.Size.Y <= 5 and (part.Size.X >= 8 or part.Size.Z >= 8) then
        return true
    end
    return false
end

-- Target selection copied from the supplied RAW source.
local function getRandomEdiblePart()
    local map = Workspace:FindFirstChild("Map")
    if not map then return nil end

    local allDescendants = map:GetDescendants()
    if #allDescendants == 0 then return nil end

    local char = player.Character
    local sizeObj = char and char:FindFirstChild("Size")
    local rawSize = sizeObj and sizeObj.Value or 1
    local stats = player:FindFirstChild("leaderstats")
    local leaderSizeObj = stats and stats:FindFirstChild("Size")
    local leaderSize = leaderSizeObj and leaderSizeObj.Value or rawSize
    local currentSize = math.max(rawSize, leaderSize)

    local prioritizeGround = currentSize < 400
    local fallbackPart = nil

    for _ = 1, 40 do
        local randomObj = allDescendants[math.random(1, #allDescendants)]
        if randomObj:IsA("BasePart")
            and randomObj.Name ~= "Bedrock"
            and randomObj.Name ~= "Barrier"
            and randomObj.CanCollide
            and randomObj.Transparency < 0.8
            and randomObj.Size.Magnitude > 2.5
            and randomObj.Position.Y > 0 then

            if prioritizeGround then
                if isGroundPart(randomObj) then
                    return randomObj, true
                elseif not fallbackPart then
                    fallbackPart = randomObj
                end
            else
                return randomObj, false
            end
        end
    end

    if prioritizeGround then
        for _, obj in ipairs(allDescendants) do
            if obj:IsA("BasePart")
                and obj.Name ~= "Bedrock"
                and obj.Name ~= "Barrier"
                and obj.CanCollide
                and obj.Transparency < 0.8
                and obj.Position.Y > 0
                and isGroundPart(obj) then
                return obj, true
            end
        end
    end

    return fallbackPart, false
end

-- Minimal standalone panel: start/stop the RAW TP Farm test.
local CYAN = Color3.fromRGB(0, 235, 255)
local DARK = Color3.fromRGB(8, 15, 22)
local WHITE = Color3.fromRGB(235, 250, 255)

local gui = Instance.new("ScreenGui")
gui.Name = "ETW_RAW_TPFarm_Test"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(235, 112)
panel.Position = UDim2.new(0.5, -117, 0.25, 0)
panel.BackgroundColor3 = DARK
panel.BackgroundTransparency = 0.06
panel.BorderSizePixel = 0
panel.Active = true
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke")
stroke.Color = CYAN
stroke.Thickness = 1.5
stroke.Parent = panel

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(10, 6)
title.Size = UDim2.new(1, -20, 0, 24)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = CYAN
title.Text = "RAW TP FARM TEST"
title.Parent = panel

local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Position = UDim2.fromOffset(10, 31)
status.Size = UDim2.new(1, -20, 0, 18)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextColor3 = WHITE
status.Text = "Status: OFF | tpDelay: 0.05s"
status.Parent = panel

local toggle = Instance.new("TextButton")
toggle.Position = UDim2.fromOffset(10, 56)
toggle.Size = UDim2.new(1, -20, 0, 38)
toggle.BackgroundColor3 = Color3.fromRGB(12, 30, 38)
toggle.TextColor3 = WHITE
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 13
toggle.Text = "START TP FARM"
toggle.AutoButtonColor = true
toggle.Parent = panel
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 7)
local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = CYAN
toggleStroke.Thickness = 1
toggleStroke.Parent = toggle

local function updateUI()
    status.Text = states.randomTPFarm and "Status: ON | tpDelay: 0.05s" or "Status: OFF | tpDelay: 0.05s"
    toggle.Text = states.randomTPFarm and "STOP TP FARM" or "START TP FARM"
end

toggle.Activated:Connect(function()
    states.randomTPFarm = not states.randomTPFarm
    updateUI()
end)

-- LOOP A: TP Farm only. No Grab/Eat calls in this loop.
task.spawn(function()
    local TELEPORT_INTERVAL = 10
    local lastTeleportAt = 0

    while gui.Parent do
        if states.randomTPFarm and os.clock() - lastTeleportAt >= TELEPORT_INTERVAL then
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if char and hrp and hum and hum.Health > 0 then
                local targetPart, isGround = getRandomEdiblePart()
                if targetPart and targetPart.Parent then
                    local partPos = targetPart.Position
                    local standPos
                    local lookTarget

                    if isGround then
                        standPos = partPos + Vector3.new(
                            math.random(-1, 1), hum.HipHeight + 0.2,
                            math.random(-1, 1)
                        )
                        lookTarget = partPos - Vector3.new(0, 2, 0)
                    else
                        standPos = partPos + Vector3.new(0, hum.HipHeight + 0.5, 2.5)
                        lookTarget = Vector3.new(partPos.X, standPos.Y, partPos.Z)
                    end

                    hrp.CFrame = CFrame.new(standPos, lookTarget)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                    lastTeleportAt = os.clock()
                end
            end
        end
        task.wait(0.05)
    end
end)

-- LOOP B: independent Grab/Eat cadence, not tied to teleport timing.
-- Uses the local-event pattern found in the supplied RAW/rEm-derived source.
task.spawn(function()
    local localEvents = ReplicatedStorage:WaitForChild("LocalEvents")
    local localGrab = localEvents:WaitForChild("Grab")
    local localEat = localEvents:WaitForChild("Eat")

    while gui.Parent do
        if states.randomTPFarm then
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if char and hum and hum.Health > 0 then
                pcall(function() localGrab:Fire() end)
                pcall(function() localEat:Fire() end)
            end
            task.wait()
        else
            task.wait(0.1)
        end
    end
end)

-- LOOP C: auto-sell independently checks whether the inventory bar is full.
task.spawn(function()
    local lastSellAt = 0
    while gui.Parent do
        if states.randomTPFarm and states.autoSell and isInventoryFull()
            and os.clock() - lastSellAt >= 0.8 then
            lastSellAt = os.clock()
            pcall(executeSell)
            task.wait(0.25)
        else
            task.wait(0.1)
        end
    end
end)

-- Close button / unload cleanup.
local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(24, 22)
close.Position = UDim2.new(1, -29, 0, 5)
close.BackgroundTransparency = 1
close.Text = "×"
close.TextColor3 = WHITE
close.Font = Enum.Font.GothamBold
close.TextSize = 18
close.Parent = panel
close.Activated:Connect(function()
    states.randomTPFarm = false
    gui:Destroy()
end)
