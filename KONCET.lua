local function targetGrabOnce()
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local localEvents = replicatedStorage:FindFirstChild("LocalEvents")
    local grabEvent = localEvents and localEvents:FindFirstChild("Grab")

    if not grabEvent or not grabEvent:IsA("BindableEvent") then
        return false
    end

    -- Hindari memanggil Grab saat loot berada terlalu dekat.
    local _, root = getCharacter()
    if not root then return false end

    local dropNames = {
        Cube=true, Token=true, Candy=true,
        Present=true, Ornament=true, Egg=true
    }

    for _, item in ipairs(workspace:GetDescendants()) do
        if item:IsA("BasePart") and dropNames[item.Name]
            and (item.Position - root.Position).Magnitude <= 6 then
            return false
        end
    end

    local ok = pcall(function()
        grabEvent:Fire()
    end)
    return ok
end

local function targetRun(chosen, token)
    local startCFrame = targetOrigin

    if not targetEnabled or targetToken ~= token
        or chosen.Parent ~= Players then
        targetStop()
        return
    end

    local targetRoot = targetGetRoot(chosen.Character)
    if not targetRoot then
        targetStop()
        return
    end

    -- Mendekat ke belakang target.
    local behind = targetRoot.Position
        - targetRoot.CFrame.LookVector * 2.5

    local char = player.Character
    if char then
        pcall(function()
            char:PivotTo(CFrame.lookAt(behind, targetRoot.Position))
        end)
    end

    task.wait(0.035)

    -- Maksimal 4 percobaan Grab, satu rangkaian saja.
    for attempt = 1, 4 do
        if not targetEnabled or targetToken ~= token then break end

        targetRoot = targetGetRoot(chosen.Character)
        if not targetRoot then break end

        behind = targetRoot.Position
            - targetRoot.CFrame.LookVector * 2.5

        char = player.Character
        if char then
            pcall(function()
                char:PivotTo(CFrame.lookAt(behind, targetRoot.Position))
            end)
        end

        task.wait(0.035)

        if not targetGrabOnce() then break end
        if attempt < 4 then task.wait(0.18) end
    end

    task.wait(1.5)

    -- Kembali ke posisi awal.
    if targetToken == token and startCFrame then
        char = player.Character
        if char then
            pcall(function()
                char:PivotTo(startCFrame)
            end)
        end
    end

    if targetToken == token then
        targetStop()
        if gui.Parent then refreshTargetPlayers() end
    end
end

local function targetToggle(chosen)
    if targetEnabled and targetPlayer == chosen then
        targetStop()
        return
    end

    if autoGrabStop then autoGrabStop() end
    targetStop()

    local root = targetGetRoot(player.Character)
    local targetRoot = targetGetRoot(chosen.Character)
    if not root or not targetRoot then return end

    targetPlayer = chosen
    targetOrigin = root.CFrame
    targetEnabled = true
    targetToken += 1

    local token = targetToken
    targetSetRowState(chosen, true)
    task.spawn(targetRun, chosen, token)
end
