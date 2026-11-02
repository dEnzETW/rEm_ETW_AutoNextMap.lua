-- ETW.DRAMA REVISION 12 - Revisi 11 base + mutually-exclusive AutoFarm/Auto EAT recovery integration
--aislop warning, but i dont care about it 

-- WHITELIST ACCESS GATE (adapted from rEm.lua)
local WhitelistedUsers = {
    "kkiktto",
    "L0rdDarkShad0w",
    "chibhothax",
    "KaiYangX_58858",
    "Mount2702Blanc",
    "ibrak4dabra",
    "chimicaramel",
    "miskalagi",
    "syunako52",
    "Carlydemul",
    "ChickenMcNuggetsBG"
}

local whitelistPlayer = game:GetService("Players").LocalPlayer
if not whitelistPlayer or not table.find(WhitelistedUsers, whitelistPlayer.Name) then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "ETWDRAMA",
            Text = "Access Denied: Username tidak di-whitelist!",
            Duration = 5
        })
    end)
    return
end

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "ETWDRAMA",
        Text = "Welcome, " .. whitelistPlayer.Name .. "!",
        Duration = 3
    })
end)















-- Защита от дублирования интерфейса
if getgenv()._HUB_CLEAN_ACTIVE and type(getgenv()._HUB_CLEAN_ACTIVE.unload) == "function" then
    pcall(getgenv()._HUB_CLEAN_ACTIVE.unload)
    task.wait(0.15)
end

-- === СЕРВИСЫ И УТИЛИТЫ ===
local G = {
    Services = {
        Players = game:GetService("Players"),
        TweenService = game:GetService("TweenService"),
        UserInputService = game:GetService("UserInputService"),
        RunService = game:GetService("RunService"),
        Stats = game:GetService("Stats"),
        Workspace = game:GetService("Workspace"),
        ReplicatedStorage = game:GetService("ReplicatedStorage"),
        CoreGui = game:GetService("CoreGui")
    },
    Math = {
        v3 = Vector3.new,
        ud2 = UDim2.new,
        ud = UDim.new,
        c3 = Color3.fromRGB,
        cf = CFrame.new,
        tw = TweenInfo.new,
        rgb = Color3.fromRGB,
        clamp = math.clamp,
        floor = math.floor
    }
}

local player = G.Services.Players.LocalPlayer or G.Services.Players.PlayerAdded:Wait()
local Camera = G.Services.Workspace.CurrentCamera or G.Services.Workspace:FindFirstChildOfClass("Camera")
local isTouchDevice = G.Services.UserInputService.TouchEnabled

-- Revisi 4: UI mengikuti referensi Cyan Neon dengan layout HP, tab berikon, dan panel status tetap di atas.
local THEME = {
    cyan = G.Math.rgb(0, 235, 255),
    cyanSoft = G.Math.rgb(0, 155, 180),
    panel = G.Math.rgb(8, 14, 20),
    panel2 = G.Math.rgb(10, 22, 29),
    button = G.Math.rgb(12, 29, 37),
    buttonActive = G.Math.rgb(0, 76, 91),
    text = G.Math.rgb(225, 250, 255),
    muted = G.Math.rgb(116, 166, 177)
}

-- Хранилище состояний переключателей и игровых систем (Язык по умолчанию: English)
local states = {
    language = "English",
    menuKey = "F1",
    watermark = true,
    
    -- Игровые модули
    randomTPFarm = false,
    autoSell = true,
    flashVacuum = false,
    instantMagnet = false,
    playerESP = false,
    antiVoid = false,
    antiAnchor = false,
    bigPlatform = false,
    speedEnabled = false,
    speedValue = 100,
    fly = false,
    noclip = false,
    infJump = false,
    autoRewards = false,
    
    -- Слайдеры и настройки
    flySpeed = 60,
    tpDelay = 0.05
}

local LOCALIZATION = {
    English = {
        -- Вкладки
        tabFarm = "FARM",
        tabAttackTP = "TP ATTACK",
        tabTPTarget = "TP TARGET",
        tabAutoGrabTarget = "AUTO GRAB TARGET",
        tabMagnet = "COIN & CANDY",
        tabVisuals = "VISUALS",
        tabCombat = "COMBAT",
        tabMovement = "MOVEMENT",
        tabRewards = "REWARDS",
        tabSettings = "SETTINGS",
        
        -- Уведомления
        titleAlert = "ALERT",
        titleWarning = "WARNING",
        titleSuccess = "SUCCESS",
        titleInfo = "NOTIFICATION",
        
        searchPlaceholder = "Search features...",
        tipToggle = "Tip: Press %s to Toggle Menu",
        
        -- Секции
        secFarm = "MAP AUTO-FARM",
        secSell = "AUTO-SELL CONTROLLER",
        secMagnet = "COLLECTION SYSTEMS",
        secVisuals = "RADAR & DETECTION",
        secCombat = "DEFENSE & COMBAT",
        secMove = "MOBILITY MODIFIERS",
        secRewards = "DAILY & TIMED GIFTS",
        secPrefs = "FRAMEWORK PREFERENCES",
        
        -- Функции: Фарм
        toggleRandomFarm = "Auto farm",
        toggleAutoEat = "Auto EAT",
        toggleAutoSell = "Auto-Sell on Full Size",
        btnForceSell = "Force Sell Now",
        
        -- Функции: Магнит
        toggleFlashVacuum = "Tp to money",
        toggleInstantMagnet = "Auto Absorb Coin Candy",
        btnSweepOnce = "1-Click Full Sweep",
        
        -- Функции: Визуал
        togglePlayerESP = "Player Stats ESP",
        
        -- Функции: Бой
        toggleRunSpeed = "Run Speed",
        inputSpeedValue = "Speed Value",
        toggleAntiVoid = "Anti-Void",
        toggleAntiAnchor = "Anti Anchor",
        toggleBigPlatform = "Big Platform",
        
        -- Функции: Движение
        toggleFly = "Flight Mode (Fly)",
        toggleNoclip = "Wall Noclip",
        toggleInfJump = "Infinite Jump",
        sliderFlySpeed = "Flight Speed",
        
        -- Функции: Награды
        toggleAutoRewards = "Auto-Claim Timed Rewards",
        btnClaimAllNow = "Claim All Ready Rewards",
        
        -- Модальные окна и настройки
        modalCloseTitle = "EXIT MENU",
        modalCloseDesc = "Are you sure you want to unload and close the interface?",
        modalBtnConfirm = "Exit",
        modalBtnCancel = "Cancel",
        
        langBtn = "Language: English",
        menuKeyBtn = "Menu Keybind: ",
        pressAnyKey = "Press any key...",
        btnViewChangelog = "📋 View Changelog",
        
        -- Внутриигровой статус
        statusSellSuccess = "Size sold successfully!",
        statusRewardsClaimed = "Rewards claimed!",
        espEdible = "EDIBLE",
        espDanger = "DANGER!"
    },
    Russian = {
        -- Вкладки
        tabFarm = "ФАРМ",
        tabAttackTP = "TP ATTACK",
        tabTPTarget = "TP TARGET",
        tabAutoGrabTarget = "AUTO GRAB TARGET",
        tabMagnet = "COIN & CANDY",
        tabVisuals = "ВИЗУАЛ",
        tabCombat = "БОЙ",
        tabMovement = "ДВИЖЕНИЕ",
        tabRewards = "НАГРАДЫ",
        tabSettings = "НАСТРОЙКИ",
        
        -- Уведомления
        titleAlert = "ТРЕВОГА",
        titleWarning = "ВНИМАНИЕ",
        titleSuccess = "УСПЕХ",
        titleInfo = "ИНФОРМАЦИЯ",
        
        searchPlaceholder = "Поиск функций...",
        tipToggle = "Подсказка: Нажми %s для меню",
        
        -- Секции
        secFarm = "АВТО-ФАРМ КАРТЫ",
        secSell = "УПРАВЛЕНИЕ ПРОДАЖЕЙ",
        secMagnet = "СИСТЕМЫ СБОРА",
        secVisuals = "РАДАР И ОБНАРУЖЕНИЕ",
        secCombat = "ЗАЩИТА И БОЙ",
        secMove = "МОДИФИКАТОРЫ ДВИЖЕНИЯ",
        secRewards = "ТАЙМЕРЫ И ПОДАРКИ",
        secPrefs = "НАСТРОЙКИ ИНТЕРФЕЙСА",
        
        -- Функции: Фарм
        toggleRandomFarm = "Авто фарм",
        toggleAutoEat = "Авто ЕДА",
        toggleAutoSell = "Авто-Продажа при заполнении",
        btnForceSell = "Продать размер сейчас",
        
        -- Функции: Магнит
        toggleFlashVacuum = "Тп к деньгам",
        toggleInstantMagnet = "Автосбор Coin Candy",
        btnSweepOnce = "Собрать все деньги за 1 раз",
        
        -- Функции: Визуал
        togglePlayerESP = "ESP статистики игроков",
        
        -- Функции: Бой
        toggleRunSpeed = "Скорость",
        inputSpeedValue = "Значение скорости",
        toggleAntiVoid = "Анти-Пустота",
        toggleAntiAnchor = "Анти-якорь",
        toggleBigPlatform = "Большая платформа",
        
        -- Функции: Движение
        toggleFly = "Режим полета (Fly)",
        toggleNoclip = "Проход сквозь стены (Noclip)",
        toggleInfJump = "Бесконечный прыжок",
        sliderFlySpeed = "Скорость полета",
        
        -- Функции: Награды
        toggleAutoRewards = "Авто-Сбор наград таймера",
        btnClaimAllNow = "Забрать все готовые награды",
        
        -- Модальные окна и настройки
        modalCloseTitle = "ЗАКРЫТЬ МЕНЮ?",
        modalCloseDesc = "Вы уверены, что хотите полностью выгрузить и закрыть интерфейс?",
        modalBtnConfirm = "Выйти",
        modalBtnCancel = "Отмена",
        
        langBtn = "Язык: Русский",
        menuKeyBtn = "Клавиша Меню: ",
        pressAnyKey = "Нажмите клавишу...",
        btnViewChangelog = "📋 Посмотреть Ченджлог",
        
        -- Внутриигровой статус
        statusSellSuccess = "Размер успешно продан!",
        statusRewardsClaimed = "Награды собраны!",
        espEdible = "МОЖНО СЪЕСТЬ",
        espDanger = "ОПАСНОСТЬ!"
    }
}

local function getText(key)
    local lang = states.language or "English"
    return (LOCALIZATION[lang] and LOCALIZATION[lang][key]) or (LOCALIZATION.English and LOCALIZATION.English[key]) or key
end

-- ====================================================================
--                     ВНУТРИИГРОВОЙ ДВИЖОК И ХУКИ
-- ====================================================================
local Character = player.Character or player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
end)

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
    if isFullServerFlag then
        return true
    end

    local playerGui = player:FindFirstChild("PlayerGui")
    local sellGui = playerGui and playerGui:FindFirstChild("ScreenGui") and playerGui.ScreenGui:FindFirstChild("Sell")
    if sellGui then
        local warn = sellGui:FindFirstChild("WarningText")
        if warn and warn.Visible and warn.TextTransparency < 0.5 then
            return true
        end

        local sellText = sellGui:FindFirstChild("SellText")
        if sellText and sellText.Visible then
            return true
        end

        local bar = sellGui:FindFirstChild("ProgressBar")
        if bar and bar.Size.X.Scale >= 0.98 then
            return true
        end
    end

    return false
end

local function executeSell()
    local events = getCharEvents()
    if events and events.Sell then
        events.Sell:FireServer()
    end

    local playerGui = player:FindFirstChild("PlayerGui")
    local sellGui = playerGui and playerGui:FindFirstChild("ScreenGui") and playerGui.ScreenGui:FindFirstChild("Sell")
    if sellGui then
        local btn = sellGui:FindFirstChild("SellButton")
        if btn and typeof(firesignal) == "function" then
            firesignal(btn.Activated)
            firesignal(btn.MouseButton1Click)
        end
    end

    isFullServerFlag = false
end

local GROUND_KEYWORDS = {
    "ground", "grass", "dirt", "soil", "sand", "floor", 
    "road", "path", "terrain", "base", "plate", "mud", "earth"
}

-- Только валидные системные материалы Roblox
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

local function isGroundPart(part)
    if not part or not part:IsA("BasePart") then return false end
    
    -- 1. Проверка по валидному материалу
    if part.Material and GROUND_MATERIALS[part.Material] then
        return true
    end

    -- 2. Проверка по названию (любые объекты со словом "dirt", "grass", "ground" и т.д.)
    local lowerName = string.lower(part.Name)
    for _, keyword in ipairs(GROUND_KEYWORDS) do
        if string.find(lowerName, keyword) then
            return true
        end
    end

    -- 3. Проверка плоских горизонтальных плит
    if part.Size.Y <= 5 and (part.Size.X >= 8 or part.Size.Z >= 8) then
        return true
    end

    return false
end

local function getRandomEdiblePart()
    local map = Workspace:FindFirstChild("Map")
    if not map then return nil end

    local allDescendants = map:GetDescendants()
    if #allDescendants == 0 then return nil end

    -- Считываем текущий размер (из Character или leaderstats)
    local char = player.Character
    local rawSize = char and char:FindFirstChild("Size") and char.Size.Value or 1
    local leaderSize = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Size") and player.leaderstats.Size.Value or rawSize
    local currentSize = math.max(rawSize, leaderSize)

    -- Если размер меньше 400 — берем СТРОГО землю
    local prioritizeGround = (currentSize < 400)

    -- 1. Быстрый случайный поиск (O(1) оптимизация для мобилок)
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
                    return randomObj, true -- Только подходящая поверхность земли.
                end
            else
                -- После 400 размера едим всё подряд (дома, стены, заборы)
                return randomObj, false
            end
        end
    end

    -- 2. Если за 40 случайных попыток земля не выпала, ищем ближайший блок земли
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

    -- Не телепортируемся к случайному объекту, если валидная земля не найдена.
    return nil, nil
end

local VALID_DROPS = {
    ["Cube"] = true,
    ["Token"] = true,
    ["Candy"] = true,
    ["Present"] = true,
    ["Ornament"] = true,
    ["Egg"] = true
}

local function canCollect(item)
    if not item or not item:IsA("BasePart") or not item.Parent then return false end
    if not VALID_DROPS[item.Name] then return false end

    local owner = item:FindFirstChild("Owner")
    local timeLeft = item:FindFirstChild("TimeLeft")

    if owner and owner.Value ~= "" and owner.Value ~= player.Name then
        if timeLeft and timeLeft.Value > 0 then
            return false
        end
    end

    return true
end

local function getPrioritizedDrops()
    local drops = {}
    local myPos = HumanoidRootPart.Position

    for _, obj in ipairs(G.Services.Workspace:GetChildren()) do
        if canCollect(obj) then
            local dist = (obj.Position - myPos).Magnitude
            local timeLeftVal = obj:FindFirstChild("TimeLeft") and obj.TimeLeft.Value or 15
            table.insert(drops, {
                Part = obj,
                Dist = dist,
                TimeLeft = timeLeftVal
            })
        end
    end

    table.sort(drops, function(a, b)
        if a.TimeLeft <= 4 and b.TimeLeft > 4 then
            return true
        elseif b.TimeLeft <= 4 and a.TimeLeft > 4 then
            return false
        end
        return a.Dist < b.Dist
    end)

    return drops
end

local function claimTimedRewards()
    local playerGui = player:FindFirstChild("PlayerGui")
    local rewardsGui = playerGui and playerGui:FindFirstChild("ScreenGui") and playerGui.ScreenGui:FindFirstChild("Rewards")
    if rewardsGui then
        local grid = rewardsGui:FindFirstChild("TimedRewards") and rewardsGui.TimedRewards:FindFirstChild("RewardGrid")
        if grid then
            for _, btn in ipairs(grid:GetChildren()) do
                if btn:IsA("ImageButton") or btn:IsA("TextButton") then
                    local timeLbl = btn:FindFirstChild("Time") or btn:FindFirstChildWhichIsA("TextLabel")
                    if timeLbl then
                        local txt = string.upper(timeLbl.Text)
                        if txt == "CLAIM" or txt == "00:00" or txt == "0:00" or not string.find(txt, ":") then
                            if typeof(firesignal) == "function" then
                                firesignal(btn.Activated)
                                firesignal(btn.MouseButton1Click)
                            end
                        end
                    end
                end
            end
        end
    end

    local timedFolder = player:FindFirstChild("TimedRewards")
    local rewardRemote = G.Services.ReplicatedStorage:FindFirstChild("Events") and G.Services.ReplicatedStorage.Events:FindFirstChild("RewardEvent")
    if timedFolder and rewardRemote then
        local now = os.time()
        for idx, val in ipairs(timedFolder:GetChildren()) do
            if (val:IsA("IntValue") or val:IsA("NumberValue")) and now >= val.Value then
                rewardRemote:FireServer(idx)
                rewardRemote:FireServer(val.Name)
            end
        end
    end

    local spinRemote = G.Services.ReplicatedStorage:FindFirstChild("Events") and G.Services.ReplicatedStorage.Events:FindFirstChild("SpinEvent")
    if spinRemote then
        spinRemote:FireServer()
    end
end

-- ====================================================================
--                     ВЫПОЛНЕНИЕ UI ЭЛЕМЕНТОВ
-- ====================================================================
local function create(className, properties, children)
    local obj = Instance.new(className)
    for k, v in pairs(properties or {}) do obj[k] = v end
    if children then for _, child in ipairs(children) do child.Parent = obj end end
    return obj
end

local function cCorner(r, p) return create("UICorner", {CornerRadius = G.Math.ud(0, r or 8), Parent = p}) end
local function cStroke(c, t, p) return create("UIStroke", {Color = c or G.Math.rgb(55, 55, 65), Thickness = t or 1, Parent = p}) end
local function cTextConstraint(minS, maxS, p)
    return create("UITextSizeConstraint", {
        MinTextSize = minS or 8,
        MaxTextSize = maxS or 11,
        Parent = p
    })
end

local function getGuiParent()
    local s, h = pcall(function() return gethui and gethui() end)
    if s and h then return h end
    local s2, cg = pcall(function() return game:GetService("CoreGui") end)
    if s2 and cg and pcall(function() local t = Instance.new("Folder", cg) t:Destroy() end) then
        return cg
    end
    return player:WaitForChild("PlayerGui", 10) or player:FindFirstChild("PlayerGui")
end

pcall(function()
    local p = getGuiParent()
    if p then
        local old = p:FindFirstChild("CleanHub_BW_Main")
        if old then old:Destroy() end
        local oldNotif = p:FindFirstChild("CleanHub_Notifications")
        if oldNotif then oldNotif:Destroy() end
    end
end)

local function setSmartFade(targetFrame, isFading)
    if not targetFrame then return end
    local tweenInfo = G.Math.tw(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local fadeDelta = isFading and 0.20 or 0

    pcall(function()
        if isFading then
            if targetFrame:GetAttribute("BaseBgTrans") == nil then
                targetFrame:SetAttribute("BaseBgTrans", targetFrame.BackgroundTransparency)
            end
            G.Services.TweenService:Create(targetFrame, tweenInfo, {BackgroundTransparency = 0.20}):Play()
        else
            local base = targetFrame:GetAttribute("BaseBgTrans") or 0
            G.Services.TweenService:Create(targetFrame, tweenInfo, {BackgroundTransparency = base}):Play()
            targetFrame:SetAttribute("BaseBgTrans", nil)
        end
    end)

    for _, obj in ipairs(targetFrame:GetDescendants()) do
        pcall(function()
            if obj:IsA("GuiObject") then
                if isFading then
                    if obj:GetAttribute("BaseBgTrans") == nil then
                        obj:SetAttribute("BaseBgTrans", obj.BackgroundTransparency)
                    end
                    local baseBg = obj:GetAttribute("BaseBgTrans")
                    if baseBg < 0.95 then
                        local targetVal = G.Math.clamp(baseBg + fadeDelta, 0, 1)
                        G.Services.TweenService:Create(obj, tweenInfo, {BackgroundTransparency = targetVal}):Play()
                    end
                else
                    local baseBg = obj:GetAttribute("BaseBgTrans")
                    if baseBg ~= nil then
                        G.Services.TweenService:Create(obj, tweenInfo, {BackgroundTransparency = baseBg}):Play()
                        obj:SetAttribute("BaseBgTrans", nil)
                    end
                end
            end

            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                if isFading then
                    if obj:GetAttribute("BaseTxtTrans") == nil then
                        obj:SetAttribute("BaseTxtTrans", obj.TextTransparency)
                    end
                    local baseTxt = obj:GetAttribute("BaseTxtTrans")
                    if baseTxt < 0.95 then
                        local targetVal = G.Math.clamp(baseTxt + fadeDelta, 0, 1)
                        G.Services.TweenService:Create(obj, tweenInfo, {TextTransparency = targetVal}):Play()
                    end
                else
                    local baseTxt = obj:GetAttribute("BaseTxtTrans")
                    if baseTxt ~= nil then
                        G.Services.TweenService:Create(obj, tweenInfo, {TextTransparency = baseTxt}):Play()
                        obj:SetAttribute("BaseTxtTrans", nil)
                    end
                end
            end

            if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
                if isFading then
                    if obj:GetAttribute("BaseImgTrans") == nil then
                        obj:SetAttribute("BaseImgTrans", obj.ImageTransparency)
                    end
                    local baseImg = obj:GetAttribute("BaseImgTrans")
                    if baseImg < 0.95 then
                        local targetVal = G.Math.clamp(baseImg + fadeDelta, 0, 1)
                        G.Services.TweenService:Create(obj, tweenInfo, {ImageTransparency = targetVal}):Play()
                    end
                else
                    local baseImg = obj:GetAttribute("BaseImgTrans")
                    if baseImg ~= nil then
                        G.Services.TweenService:Create(obj, tweenInfo, {ImageTransparency = baseImg}):Play()
                        obj:SetAttribute("BaseImgTrans", nil)
                    end
                end
            end

            if obj:IsA("UIStroke") then
                if isFading then
                    if obj:GetAttribute("BaseStrokeTrans") == nil then
                        obj:SetAttribute("BaseStrokeTrans", obj.Transparency)
                    end
                    local baseStroke = obj:GetAttribute("BaseStrokeTrans")
                    if baseStroke < 0.95 then
                        local targetVal = G.Math.clamp(baseStroke + fadeDelta, 0, 1)
                        G.Services.TweenService:Create(obj, tweenInfo, {Transparency = targetVal}):Play()
                    end
                else
                    local baseStroke = obj:GetAttribute("BaseStrokeTrans")
                    if baseStroke ~= nil then
                        G.Services.TweenService:Create(obj, tweenInfo, {Transparency = baseStroke}):Play()
                        obj:SetAttribute("BaseStrokeTrans", nil)
                    end
                end
            end
        end)
    end
end

local function makeDraggable(gui, target)
    target = target or gui
    local dragging, dragInput, dragStart, startPos
    
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            setSmartFade(target, true)
        end
    end)
    
    G.Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                setSmartFade(target, false)
            end
        end 
    end)
    
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    G.Services.UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            target.Position = G.Math.ud2(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ====================================================================
--                  СИСТЕМА УВЕДОМЛЕНИЙ (TOASTS)
-- ====================================================================
local NotificationGui = create("ScreenGui", {
    Name = "CleanHub_Notifications",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    Parent = getGuiParent()
})

local NOTIFY_COLORS = {
    Info = G.Math.rgb(240, 240, 250),
    Success = G.Math.rgb(255, 255, 255),
    Warning = G.Math.rgb(220, 220, 230),
    Error = G.Math.rgb(255, 75, 75),
    Background = G.Math.rgb(18, 18, 22),
    Stroke = G.Math.rgb(50, 50, 60)
}

local activeToastList = {}
local function getToastResponsiveConfig()
    local cam = G.Services.Workspace.CurrentCamera or Camera
    local vp = (cam and cam.ViewportSize) or Vector2.new(1280, 720)
    local isSmall = vp.X < 750 or isTouchDevice
    local cardWidth = isSmall and G.Math.clamp(G.Math.floor(vp.X * 0.42), 200, 250) or 290
    local cardHeight = isSmall and 48 or 56

    return {
        CARD_WIDTH = cardWidth,
        CARD_HEIGHT = cardHeight,
        PADDING = isSmall and 6 or 8,
        OFFSET_X = isSmall and 10 or 20,
        OFFSET_Y = isSmall and 12 or 22,
        ANIM_TIME = 0.3,
        TITLE_SIZE = isSmall and 11 or 12,
        DESC_SIZE = isSmall and 9 or 11,
        BAR_WIDTH = 3,
        MAX_STACK = 4,
        isSmall = isSmall
    }
end

local function repositionToasts()
    local cfg = getToastResponsiveConfig()
    for i, data in ipairs(activeToastList) do
        local targetY = cfg.OFFSET_Y + (i - 1) * (cfg.CARD_HEIGHT + cfg.PADDING)
        local targetPos = G.Math.ud2(1, -(cfg.CARD_WIDTH + cfg.OFFSET_X), 0, targetY)
        G.Services.TweenService:Create(data.frame, G.Math.tw(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = targetPos
        }):Play()
    end
end

local function showNotification(message, nType, title, duration)
    if not message or message == "" then return end
    duration = duration or 3.0
    nType = nType or "Info"
    local accentColor = NOTIFY_COLORS[nType] or NOTIFY_COLORS.Info
    local cfg = getToastResponsiveConfig()

    if not title then
        if nType == "Error" then title = getText("titleAlert")
        elseif nType == "Warning" then title = getText("titleWarning")
        elseif nType == "Success" then title = getText("titleSuccess")
        else title = getText("titleInfo") end
    end

    if #activeToastList >= cfg.MAX_STACK then
        local oldest = activeToastList[1]
        if oldest and oldest.dismiss then oldest.dismiss() end
    end

    local nextIndex = #activeToastList + 1
    local spawnY = cfg.OFFSET_Y + (nextIndex - 1) * (cfg.CARD_HEIGHT + cfg.PADDING)
    local startPos = G.Math.ud2(1, 40, 0, spawnY)
    local finalPos = G.Math.ud2(1, -(cfg.CARD_WIDTH + cfg.OFFSET_X), 0, spawnY)

    local frame = create("Frame", {
        Name = "Toast_" .. tick(),
        Size = G.Math.ud2(0, cfg.CARD_WIDTH, 0, cfg.CARD_HEIGHT),
        Position = startPos,
        BackgroundColor3 = NOTIFY_COLORS.Background,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = NotificationGui
    }, {
        cCorner(8),
        create("UIStroke", {Color = NOTIFY_COLORS.Stroke, Thickness = 1}),
        create("Frame", {
            Name = "Accent",
            Size = G.Math.ud2(0, cfg.BAR_WIDTH, 1, 0),
            BackgroundColor3 = accentColor,
            BorderSizePixel = 0
        }),
        create("TextLabel", {
            Name = "Title",
            Size = G.Math.ud2(1, -18, 0, cfg.isSmall and 14 or 18),
            Position = G.Math.ud2(0, 12, 0, 4),
            BackgroundTransparency = 1,
            Text = tostring(title),
            TextColor3 = accentColor,
            Font = Enum.Font.GothamBold,
            TextSize = cfg.TITLE_SIZE,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        create("TextLabel", {
            Name = "Desc",
            Size = G.Math.ud2(1, -18, 0, cfg.isSmall and 24 or 28),
            Position = G.Math.ud2(0, 12, 0, 20),
            BackgroundTransparency = 1,
            Text = tostring(message),
            TextColor3 = G.Math.rgb(215, 215, 225),
            Font = Enum.Font.GothamMedium,
            TextSize = cfg.DESC_SIZE,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        create("Frame", {
            Name = "TimerBar",
            Size = G.Math.ud2(1, 0, 0, 2),
            Position = G.Math.ud2(0, 0, 1, -2),
            BackgroundColor3 = accentColor,
            BorderSizePixel = 0
        })
    })

    local isDismissed = false
    local notifyData = { frame = frame }

    local function dismissToast()
        if isDismissed then return end
        isDismissed = true

        local exitTween = G.Services.TweenService:Create(frame, G.Math.tw(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = G.Math.ud2(1, 40, 0, frame.Position.Y.Offset),
            BackgroundTransparency = 1
        })
        exitTween:Play()
        exitTween.Completed:Wait()

        for i, item in ipairs(activeToastList) do
            if item == notifyData then
                table.remove(activeToastList, i)
                break
            end
        end

        frame:Destroy()
        repositionToasts()
    end

    notifyData.dismiss = dismissToast
    activeToastList[#activeToastList + 1] = notifyData

    G.Services.TweenService:Create(frame, G.Math.tw(cfg.ANIM_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = finalPos
    }):Play()

    local tBar = frame:FindFirstChild("TimerBar")
    if tBar then
        G.Services.TweenService:Create(tBar, G.Math.tw(duration, Enum.EasingStyle.Linear), {
            Size = G.Math.ud2(0, 0, 0, 2)
        }):Play()
    end

    task.delay(duration, dismissToast)
end
-- ====================================================================
--                  ОСНОВНОЙ КОМПОНЕНТ ИНТЕРФЕЙСА
-- ====================================================================
local function BuildHubUI()
    local S = {
        Runtime = { running = true, connections = {} },
        Pages = {},
        TabBtns = {},
        currentActiveTabBtn = nil,
        registeredSearchElements = {},
        registeredRows = {},
        localizedLabels = {},
        UI_STORAGE = {}
    }

    S.ScreenGui = create("ScreenGui", {
        Name = "CleanHub_BW_Main",
        Parent = getGuiParent(),
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })

    local vp = Camera.ViewportSize
    local isSmallScreen = vp.X <= 900 or isTouchDevice
    -- Revisi 5: ukuran HP sengaja dibuat kecil dan stabil, tanpa berubah-ubah antar revisi.
    local initialWidth, initialHeight
    local topBarHeight = isSmallScreen and 58 or 70
    local maxPanelWidth = math.max(250, math.min(isSmallScreen and 330 or 560, vp.X - 20))
    local minPanelWidth = math.min(isSmallScreen and 250 or 420, maxPanelWidth)
    local maxPanelHeight = math.max(220, math.min(isSmallScreen and 285 or 440, vp.Y - 24))
    local minPanelHeight = math.min(isSmallScreen and 220 or 340, maxPanelHeight)
    local sidebarWidth
    if isSmallScreen then
        initialWidth = G.Math.floor(G.Math.clamp(vp.X * 0.58, minPanelWidth, maxPanelWidth))
        initialHeight = G.Math.floor(G.Math.clamp(vp.Y * 0.34, minPanelHeight, maxPanelHeight))
        sidebarWidth = G.Math.floor(G.Math.clamp(initialWidth * 0.31, 78, 98))
    else
        initialWidth = G.Math.clamp(vp.X * 0.42, minPanelWidth, maxPanelWidth)
        initialHeight = G.Math.clamp(vp.Y * 0.50, minPanelHeight, maxPanelHeight)
        sidebarWidth = G.Math.floor(G.Math.clamp(initialWidth * 0.34, 145, 198))
    end
    initialWidth = G.Math.clamp(initialWidth, minPanelWidth, maxPanelWidth)
    initialHeight = G.Math.clamp(initialHeight, minPanelHeight, maxPanelHeight)

    S.MainFrame = create("Frame", {
        Name = "MainFrame",
        Size = G.Math.ud2(0, initialWidth, 0, initialHeight),
        Position = G.Math.ud2(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = THEME.panel,
        BackgroundTransparency = 0.12,
        Active = true,
        ClipsDescendants = true,
        Parent = S.ScreenGui
    }, {
        cCorner(16),
        create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, G.Math.rgb(4, 43, 53)),
                ColorSequenceKeypoint.new(0.48, G.Math.rgb(5, 13, 19)),
                ColorSequenceKeypoint.new(1, G.Math.rgb(0, 31, 40))
            }),
            Rotation = 28
        }),
        create("UIStroke", {Color = THEME.cyan, Thickness = 4, Transparency = 0.68}),
        cStroke(THEME.cyan, 1.8),
        create("UISizeConstraint", {
            MinSize = Vector2.new(minPanelWidth, minPanelHeight),
            MaxSize = Vector2.new(maxPanelWidth, maxPanelHeight)
        })
    })

    S.MainScale = create("UIScale", {Scale = 1, Parent = S.MainFrame})

    S.TopBar = create("Frame", {
        Name = "TopBar",
        Size = G.Math.ud2(1, 0, 0, topBarHeight),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = S.MainFrame
    }, {
        create("TextLabel", {
            Size = G.Math.ud2(1, -88, 0, isSmallScreen and 30 or 34),
            Position = G.Math.ud2(0, isSmallScreen and 9 or 15, 0, 0),
            BackgroundTransparency = 1,
            Text = "ETWDRAMA",
            TextColor3 = THEME.cyan,
            Font = Enum.Font.GothamBlack,
            TextSize = isSmallScreen and 12 or 13,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    })
    makeDraggable(S.TopBar, S.MainFrame)

    S.closeBtn = create("TextButton", {
        Name = "CloseBtn",
        Size = G.Math.ud2(0, 32, 0, 32),
        Position = G.Math.ud2(1, -42, 0, isSmallScreen and 2 or 3),
        BackgroundColor3 = THEME.button,
        Text = "X",
        TextColor3 = G.Math.rgb(200, 200, 210),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        AutoButtonColor = false,
        Parent = S.TopBar
    }, { cCorner(9), cStroke(THEME.cyan, 1.2) })

    S.minBtn = create("TextButton", {
        Name = "MinBtn",
        Size = G.Math.ud2(0, 32, 0, 32),
        Position = G.Math.ud2(1, -80, 0, isSmallScreen and 2 or 3),
        BackgroundColor3 = THEME.button,
        Text = "—",
        TextColor3 = G.Math.rgb(200, 200, 210),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        AutoButtonColor = false,
        Parent = S.TopBar
    }, { cCorner(9), cStroke(THEME.cyan, 1.2) })

    S.closeBtn.MouseEnter:Connect(function()
        G.Services.TweenService:Create(S.closeBtn, G.Math.tw(0.15), {BackgroundColor3 = THEME.buttonActive, TextColor3 = THEME.cyan}):Play()
    end)
    S.closeBtn.MouseLeave:Connect(function()
        G.Services.TweenService:Create(S.closeBtn, G.Math.tw(0.15), {BackgroundColor3 = THEME.button, TextColor3 = THEME.text}):Play()
    end)

    S.minBtn.MouseEnter:Connect(function()
        G.Services.TweenService:Create(S.minBtn, G.Math.tw(0.15), {BackgroundColor3 = THEME.buttonActive, TextColor3 = THEME.cyan}):Play()
    end)
    S.minBtn.MouseLeave:Connect(function()
        G.Services.TweenService:Create(S.minBtn, G.Math.tw(0.15), {BackgroundColor3 = THEME.button, TextColor3 = THEME.text}):Play()
    end)

    S.ResizeGrip = create("ImageButton", {
        Name = "ResizeCorner",
        Size = G.Math.ud2(0, 20, 0, 20),
        Position = G.Math.ud2(1, 0, 1, 0),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5854832560",
        ImageColor3 = THEME.cyan,
        ImageTransparency = 0.15,
        ZIndex = 25,
        Parent = S.MainFrame
    })

    local isResizing = false
    local resizeStartPos = Vector2.new(0, 0)
    local resizeStartSize = Vector2.new(S.MainFrame.AbsoluteSize.X, S.MainFrame.AbsoluteSize.Y)

    S.ResizeGrip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isResizing = true
            resizeStartPos = Vector2.new(input.Position.X, input.Position.Y)
            resizeStartSize = Vector2.new(S.MainFrame.AbsoluteSize.X, S.MainFrame.AbsoluteSize.Y)
            G.Services.TweenService:Create(S.ResizeGrip, G.Math.tw(0.1), {ImageColor3 = G.Math.rgb(255, 255, 255), ImageTransparency = 0}):Play()
        end
    end)

    S.Runtime.connections[#S.Runtime.connections + 1] = G.Services.UserInputService.InputChanged:Connect(function(input)
        if isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - resizeStartPos
            local minW = minPanelWidth
            local minH = minPanelHeight
            local maxW = math.max(minW, math.min(isSmallScreen and 330 or 560, Camera.ViewportSize.X - 20))
            local maxH = math.max(minH, math.min(isSmallScreen and 285 or 440, Camera.ViewportSize.Y - 24))
            S.MainFrame.Size = G.Math.ud2(0, G.Math.clamp(resizeStartSize.X + delta.X, minW, math.max(minW, maxW)), 0, G.Math.clamp(resizeStartSize.Y + delta.Y, minH, math.max(minH, maxH)))
        end
    end)

    S.Runtime.connections[#S.Runtime.connections + 1] = G.Services.UserInputService.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and isResizing then
            isResizing = false
            G.Services.TweenService:Create(S.ResizeGrip, G.Math.tw(0.2), {ImageColor3 = THEME.cyan, ImageTransparency = 0.15}):Play()
        end
    end)

    S.Sidebar = create("Frame", {
        Name = "Sidebar",
        Size = G.Math.ud2(0, sidebarWidth, 1, -topBarHeight),
        Position = G.Math.ud2(0, 0, 0, topBarHeight),
        BackgroundColor3 = THEME.panel2,
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = S.MainFrame
    }, {
        cCorner(16),
        create("Frame", {Name = "TopPatch", Size = G.Math.ud2(1, 0, 0, 16), Position = G.Math.ud2(0, 0, 0, 0), BackgroundColor3 = THEME.panel2, BorderSizePixel = 0}),
        create("Frame", {Name = "RightPatch", Size = G.Math.ud2(0, 16, 1, 0), Position = G.Math.ud2(1, -16, 0, 0), BackgroundColor3 = THEME.panel2, BorderSizePixel = 0})
    })
    create("Frame", {
        Name = "SidebarNeonDivider",
        Size = G.Math.ud2(0, 1, 1, -topBarHeight),
        Position = G.Math.ud2(0, sidebarWidth - 1, 0, topBarHeight),
        BackgroundColor3 = THEME.cyanSoft,
        BackgroundTransparency = 0.28,
        BorderSizePixel = 0,
        ZIndex = 8,
        Parent = S.MainFrame
    })

    S.SidebarContent = create("ScrollingFrame", {
        Name = "ButtonContainer",
        Size = G.Math.ud2(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = isSmallScreen and 5 or 7,
        ScrollBarImageColor3 = THEME.cyan,
        CanvasSize = G.Math.ud2(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ZIndex = 6,
        Parent = S.Sidebar
    }, {
        create("UIPadding", {PaddingTop = G.Math.ud(0, 4), PaddingBottom = G.Math.ud(0, 4)}),
        create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = G.Math.ud(0, 3), HorizontalAlignment = Enum.HorizontalAlignment.Center})
    })

    S.ContentBackdrop = create("Frame", {
        Name = "ContentBackdrop",
        Size = G.Math.ud2(1, -sidebarWidth, 1, -topBarHeight),
        Position = G.Math.ud2(0, sidebarWidth, 0, topBarHeight),
        BackgroundColor3 = THEME.panel,
        BackgroundTransparency = 0.18,
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = S.MainFrame
    }, { cCorner(14) })

    S.Content = create("Frame", {
        Name = "Content",
        Size = G.Math.ud2(1, -sidebarWidth, 1, -topBarHeight),
        Position = G.Math.ud2(0, sidebarWidth, 0, topBarHeight),
        BackgroundTransparency = 1,
        ZIndex = 5,
        Parent = S.MainFrame
    })

    -- Search bar removed per request to give feature pages more room.
    S.SearchContainer = nil
    S.SearchBox = nil
    S.SearchClearBtn = nil

    S.MiniButton = create("TextButton", {
        Size = G.Math.ud2(0, 48, 0, 48),
        Position = G.Math.ud2(0, 20, 0.5, -24),
        BackgroundColor3 = THEME.button,
        Text = "",
        Visible = false,
        Parent = S.ScreenGui
    }, {
        cCorner(12),
        cStroke(THEME.cyan, 1.5),
        create("ImageLabel", {
            Size = G.Math.ud2(1, -14, 1, -14),
            Position = G.Math.ud2(0, 7, 0, 7),
            BackgroundTransparency = 1,
            Image = "rbxassetid://7059346373",
            ImageColor3 = THEME.cyan,
            ScaleType = Enum.ScaleType.Fit
        })
    })
    makeDraggable(S.MiniButton)

    -- Status card seperti referensi: dua baris, outline Cyan Neon, tetap di atas layar.
    local watermarkWidth = math.max(120, initialWidth - 16)
    local watermarkHeight = isSmallScreen and 24 or 30
    S.wmFrame = create("Frame", {
        Name = "Watermark",
        Size = G.Math.ud2(0, watermarkWidth, 0, watermarkHeight),
        Position = G.Math.ud2(0, 8, 0, topBarHeight - watermarkHeight - 1),
        AnchorPoint = Vector2.new(0, 0),
        BackgroundColor3 = G.Math.rgb(3, 20, 27),
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Visible = states.watermark,
        ZIndex = 30,
        Parent = S.MainFrame
    }, {
        cCorner(9),
        create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, G.Math.rgb(4, 39, 49)),
                ColorSequenceKeypoint.new(0.55, G.Math.rgb(3, 17, 23)),
                ColorSequenceKeypoint.new(1, G.Math.rgb(3, 35, 45))
            }),
            Rotation = 0
        }),
        create("UIStroke", {Color = THEME.cyan, Thickness = isSmallScreen and 2 or 2.5, Transparency = 0.35}),
        cStroke(THEME.cyan, 1.1),
        create("TextLabel", {
            Name = "StatusTitle",
            Size = G.Math.ud2(1, -8, 0, isSmallScreen and 10 or 13),
            Position = G.Math.ud2(0, 4, 0, 0),
            BackgroundTransparency = 1,
            Text = "dEnzCreator",
            TextColor3 = THEME.cyan,
            Font = Enum.Font.GothamBlack,
            TextSize = isSmallScreen and 8 or 10,
            TextScaled = false,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 31
        }),
        create("TextLabel", {
            Name = "StatsTxt",
            Size = G.Math.ud2(1, -8, 0, isSmallScreen and 10 or 13),
            Position = G.Math.ud2(0, 4, 0, isSmallScreen and 11 or 14),
            BackgroundTransparency = 1,
            Text = "HUB | FPS: 60 | Ping: 0ms",
            TextColor3 = THEME.text,
            Font = Enum.Font.GothamBold,
            TextSize = isSmallScreen and 6 or 8,
            TextScaled = false,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 31
        })
    })

    S.ModalOverlay = create("Frame", {
        Name = "ModalOverlay",
        Size = G.Math.ud2(1, 0, 1, 0),
        BackgroundColor3 = G.Math.rgb(0, 0, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 50,
        Parent = S.MainFrame
    }, { cCorner(14) })

    S.ModalCard = create("Frame", {
        Name = "ModalCard",
        Size = G.Math.ud2(0, 290, 0, 145),
        Position = G.Math.ud2(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = THEME.panel2,
        ZIndex = 51,
        Parent = S.ModalOverlay
    }, {
        cCorner(12),
        cStroke(THEME.cyan, 1.5),
        create("TextLabel", {
            Name = "Title",
            Size = G.Math.ud2(1, -20, 0, 24),
            Position = G.Math.ud2(0, 10, 0, 14),
            BackgroundTransparency = 1,
            Text = getText("modalCloseTitle"),
            TextColor3 = G.Math.rgb(255, 255, 255),
            Font = Enum.Font.GothamBlack,
            TextSize = 13,
            ZIndex = 52
        }),
        create("TextLabel", {
            Name = "Desc",
            Size = G.Math.ud2(1, -28, 0, 36),
            Position = G.Math.ud2(0, 14, 0, 42),
            BackgroundTransparency = 1,
            Text = getText("modalCloseDesc"),
            TextColor3 = G.Math.rgb(180, 180, 195),
            Font = Enum.Font.GothamMedium,
            TextSize = 11,
            TextWrapped = true,
            ZIndex = 52
        })
    })

    S.ModalBtnRow = create("Frame", {
        Size = G.Math.ud2(1, -24, 0, 32),
        Position = G.Math.ud2(0, 12, 1, -44),
        BackgroundTransparency = 1,
        ZIndex = 52,
        Parent = S.ModalCard
    }, {
        create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = G.Math.ud(0.06, 0), HorizontalAlignment = Enum.HorizontalAlignment.Center})
    })

    S.modalBtnCancel = create("TextButton", {
        Size = G.Math.ud2(0.47, 0, 1, 0),
        BackgroundColor3 = G.Math.rgb(32, 32, 40),
        Text = getText("modalBtnCancel"),
        TextColor3 = G.Math.rgb(220, 220, 235),
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        ZIndex = 53,
        Parent = S.ModalBtnRow
    }, { cCorner(6), cStroke(G.Math.rgb(50, 50, 65), 1) })

    S.modalBtnConfirm = create("TextButton", {
        Size = G.Math.ud2(0.47, 0, 1, 0),
        BackgroundColor3 = G.Math.rgb(210, 45, 45),
        Text = getText("modalBtnConfirm"),
        TextColor3 = G.Math.rgb(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        ZIndex = 53,
        Parent = S.ModalBtnRow
    }, { cCorner(6) })

    S.showCloseConfirmation = function(show)
        if show then
            S.ModalOverlay.Visible = true
            S.ModalCard.Size = G.Math.ud2(0, 260, 0, 130)
            G.Services.TweenService:Create(S.ModalOverlay, G.Math.tw(0.2), {BackgroundTransparency = 0.45}):Play()
            G.Services.TweenService:Create(S.ModalCard, G.Math.tw(0.25, Enum.EasingStyle.Back), {Size = G.Math.ud2(0, 290, 0, 145)}):Play()
        else
            local t = G.Services.TweenService:Create(S.ModalOverlay, G.Math.tw(0.18), {BackgroundTransparency = 1})
            G.Services.TweenService:Create(S.ModalCard, G.Math.tw(0.18), {Size = G.Math.ud2(0, 260, 0, 130)}):Play()
            t:Play()
            t.Completed:Connect(function()
                if S.ModalOverlay.BackgroundTransparency >= 0.99 then
                    S.ModalOverlay.Visible = false
                end
            end)
        end
    end

    S.closeBtn.MouseButton1Click:Connect(function() S.showCloseConfirmation(true) end)
    S.modalBtnCancel.MouseButton1Click:Connect(function() S.showCloseConfirmation(false) end)
    S.modalBtnConfirm.MouseButton1Click:Connect(function()
        S.Runtime.running = false
        states.antiVoid = false
        states.bigPlatform = false
        local oldPlatform = G.Services.Workspace:FindFirstChild("ETW_DRAMA_BigPlatform")
        if oldPlatform then pcall(function() oldPlatform:Destroy() end) end
        for _, c in ipairs(S.Runtime.connections) do if c.Connected then c:Disconnect() end end
        table.clear(S.Runtime.connections)
        S.ScreenGui:Destroy()
        if NotificationGui then NotificationGui:Destroy() end
        getgenv()._HUB_CLEAN_ACTIVE = nil
    end)

    S.guiOpen = true
    S.setMenuOpen = function(open)
        S.guiOpen = open
        if open then
            S.MiniButton.Visible = false
            S.MainFrame.Visible = true
            setSmartFade(S.MainFrame, false)
            S.MainScale.Scale = 0.88
            G.Services.TweenService:Create(S.MainScale, G.Math.tw(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Scale = 1}):Play()
        else
            S.showCloseConfirmation(false)
            local t = G.Services.TweenService:Create(S.MainScale, G.Math.tw(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Scale = 0.85})
            setSmartFade(S.MainFrame, true)
            t:Play()
            t.Completed:Connect(function()
                if not S.guiOpen then
                    S.MainFrame.Visible = false
                    S.MiniButton.Visible = true
                    S.MiniButton.Size = G.Math.ud2(0, 36, 0, 36)
                    G.Services.TweenService:Create(S.MiniButton, G.Math.tw(0.25, Enum.EasingStyle.Back), {Size = G.Math.ud2(0, 48, 0, 48)}):Play()
                end
            end)
        end
    end

    S.minBtn.MouseButton1Click:Connect(function() S.setMenuOpen(false) end)
    S.MiniButton.MouseButton1Click:Connect(function() S.setMenuOpen(true) end)

    S.applySearchFilter = function(query)
        query = string.lower(query or "")
        S.SearchClearBtn.Visible = (query ~= "")

        for _, item in ipairs(S.registeredSearchElements) do
            if item.container and item.container.Parent then
                if query == "" then
                    item.container.Visible = true
                else
                    local match = false
                    local mainTxt = string.lower(getText(item.key) or item.key)
                    if string.find(mainTxt, query, 1, true) ~= nil then
                        match = true
                    elseif item.subKeys then
                        for _, sk in ipairs(item.subKeys) do
                            local subTxt = string.lower(getText(sk) or sk)
                            if string.find(subTxt, query, 1, true) ~= nil then
                                match = true
                                break
                            end
                        end
                    end
                    item.container.Visible = match
                end
            end
        end

        for _, rowData in ipairs(S.registeredRows) do
            local row = rowData.frame
            if row and row.Parent then
                if query == "" then
                    row.Visible = (rowData.defaultVisible ~= false)
                else
                    local hasVisible = false
                    for _, c in ipairs(row:GetChildren()) do
                        if c:IsA("GuiObject") and not c:IsA("UIListLayout") and not c:IsA("UIPadding") and c.Visible then
                            hasVisible = true
                            break
                        end
                    end
                    row.Visible = hasVisible
                end
            end
        end
    end

    -- Search filter is disabled because the search UI was removed.

    S.createPage = function(internalName, tabKey)
        local page = create("ScrollingFrame", {
            Name = internalName,
            Size = G.Math.ud2(1, -20, 1, isSmallScreen and -12 or -18),
            Position = G.Math.ud2(0, 10, 0, isSmallScreen and 8 or 12),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            Visible = false,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = G.Math.ud2(0, 0, 0, 0),
            ZIndex = 6,
            Parent = S.Content
        }, {
            create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = G.Math.ud(0, isSmallScreen and 3 or 6), HorizontalAlignment = Enum.HorizontalAlignment.Center}),
            create("UIPadding", {PaddingTop = G.Math.ud(0, 2), PaddingBottom = G.Math.ud(0, 8)})
        })
        S.Pages[internalName] = page

        local tabIcons = {
            tabFarm = "♧", tabAttackTP = "⚡", tabTPTarget = "⌖", tabAutoGrabTarget = "✊", tabMagnet = "∩", tabVisuals = "◉",
            tabCombat = "⚔", tabMovement = "↗", tabRewards = "✦", tabSettings = "⚙"
        }
        local btn = create("TextButton", {
            Size = G.Math.ud2(0.91, 0, 0, isSmallScreen and 27 or 37),
            BackgroundColor3 = THEME.button,
            BackgroundTransparency = 0.22,
            Text = (tabIcons[tabKey] or "›") .. "   " .. getText(tabKey),
            TextColor3 = G.Math.rgb(245, 250, 255),
            Font = Enum.Font.GothamBold,
            TextSize = isSmallScreen and 10 or 12,
            TextScaled = true,
            TextWrapped = false,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClipsDescendants = true,
            LayoutOrder = (#S.TabBtns >= 4) and (#S.TabBtns + 2) or (#S.TabBtns + 1),
            ZIndex = 7,
            Parent = S.SidebarContent
        }, {
            cCorner(10),
            cStroke(THEME.cyanSoft, 0.9),
            cTextConstraint(8, isSmallScreen and 10 or 13),
            create("UIPadding", {PaddingLeft = G.Math.ud(0, isSmallScreen and 7 or 11), PaddingRight = G.Math.ud(0, 3)})
        })
        S.TabBtns[#S.TabBtns + 1] = {instance = btn, key = tabKey}

        btn.MouseEnter:Connect(function() 
            if S.currentActiveTabBtn ~= btn then 
                G.Services.TweenService:Create(btn, G.Math.tw(0.15), {TextColor3 = THEME.cyan}):Play() 
            end 
        end)
        btn.MouseLeave:Connect(function() 
            if S.currentActiveTabBtn ~= btn then 
                G.Services.TweenService:Create(btn, G.Math.tw(0.15), {TextColor3 = G.Math.rgb(245, 250, 255)}):Play() 
            end 
        end)
        btn.MouseButton1Click:Connect(function()
            S.currentActiveTabBtn = btn
            for _, p in pairs(S.Pages) do p.Visible = false end
            for _, b in pairs(S.TabBtns) do
                if b.instance ~= btn then
                    G.Services.TweenService:Create(b.instance, G.Math.tw(0.2), {TextColor3 = G.Math.rgb(245, 250, 255), BackgroundTransparency = 0.22, BackgroundColor3 = THEME.button}):Play()
                local outline = b.instance:FindFirstChildOfClass("UIStroke")
                if outline then G.Services.TweenService:Create(outline, G.Math.tw(0.2), {Color = THEME.cyanSoft, Transparency = 0.15}):Play() end
                end
            end
            page.Visible = true
            G.Services.TweenService:Create(btn, G.Math.tw(0.2), {TextColor3 = THEME.cyan, BackgroundColor3 = THEME.buttonActive, BackgroundTransparency = 0.03}):Play()
            local activeOutline = btn:FindFirstChildOfClass("UIStroke")
            if activeOutline then G.Services.TweenService:Create(activeOutline, G.Math.tw(0.2), {Color = THEME.cyan, Transparency = 0}):Play() end
        end)

        return page
    end

    S.createDivider = function(parent, text, order)
        return create("TextLabel", {
            Size = G.Math.ud2(0.98, 0, 0, 18),
            BackgroundTransparency = 1,
            Text = "— " .. string.upper(text) .. " —",
            TextColor3 = THEME.muted,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            LayoutOrder = order or 0,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 7,
            Parent = parent
        })
    end

    local function updateRowChildren(row, childHeight)
        if not row then return end
        local children = {}
        for _, child in ipairs(row:GetChildren()) do
            if child:IsA("GuiObject") and not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                table.insert(children, child)
            end
        end
        local n = #children
        if n == 0 then return end
        local gap = 6
        local h = childHeight or row.Size.Y.Offset
        if h <= 0 then h = 38 end
        for _, child in ipairs(children) do
            child.Size = G.Math.ud2(1 / n, -math.floor(((n - 1) * gap) / n), 0, h)
        end
    end

    S.createRow = function(parent, height, order)
        height = height or 38
        local row = create("Frame", {
            Name = "Row",
            Size = G.Math.ud2(0.98, 0, 0, height),
            BackgroundTransparency = 1,
            LayoutOrder = order or 0,
            ZIndex = 7,
            Parent = parent
        }, {
            create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = G.Math.ud(0, 6),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder
            })
        })
        S.registeredRows[#S.registeredRows + 1] = {frame = row, defaultVisible = true, height = height}
        return row
    end

    S.createToggle = function(parent, key, cb)
        local isInsideRow = (parent:IsA("Frame") and parent.Name ~= "Farm" and parent.Name ~= "Magnet" and parent.Name ~= "Visuals" and parent.Name ~= "Combat" and parent.Name ~= "Movement" and parent.Name ~= "Rewards" and parent.Name ~= "Settings")
        local isOn = (states[key] == true)

        local btn = create("TextButton", {
            Name = "Toggle_" .. key,
            Size = isInsideRow and G.Math.ud2(0.48, 0, 0, isSmallScreen and 31 or 38) or G.Math.ud2(0.98, 0, 0, isSmallScreen and 31 or 38),
            BackgroundColor3 = THEME.button,
            BackgroundTransparency = 0.12,
            AutoButtonColor = false,
            Text = "",
            ClipsDescendants = true,
            ZIndex = 7,
            Parent = parent
        }, { cCorner(10), cStroke(isOn and THEME.cyan or THEME.cyanSoft, isOn and 1.35 or 0.9) })

        local label = create("TextLabel", {
            Name = "BtnLabel",
            Size = G.Math.ud2(1, -48, 1, -4),
            Position = G.Math.ud2(0, 8, 0, 2),
            BackgroundTransparency = 1,
            Text = getText(key),
            TextColor3 = THEME.text,
            Font = Enum.Font.GothamBold,
            TextSize = isSmallScreen and 10 or 11,
            TextScaled = true,
            TextWrapped = false,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 8,
            Parent = btn
        }, { cTextConstraint(isSmallScreen and 8 or 9, isSmallScreen and 10 or 11) })

        local switchTrack = create("Frame", {
            Name = "Track",
            Size = G.Math.ud2(0, 34, 0, 18),
            Position = G.Math.ud2(1, -44, 0.5, -9),
            BackgroundColor3 = isOn and THEME.cyan or G.Math.rgb(20, 43, 51),
            ZIndex = 8,
            Parent = btn
        }, { cCorner(9) })

        local switchDot = create("Frame", {
            Name = "Dot",
            Size = G.Math.ud2(0, 14, 0, 14),
            Position = isOn and G.Math.ud2(1, -16, 0.5, -7) or G.Math.ud2(0, 2, 0.5, -7),
            BackgroundColor3 = isOn and G.Math.rgb(2, 22, 28) or THEME.muted,
            ZIndex = 9,
            Parent = switchTrack
        }, { cCorner(7) })

        local stroke = btn:FindFirstChildOfClass("UIStroke")

        local function updateVisual(state)
            G.Services.TweenService:Create(switchTrack, G.Math.tw(0.16), {BackgroundColor3 = state and THEME.cyan or G.Math.rgb(20, 43, 51)}):Play()
            G.Services.TweenService:Create(switchDot, G.Math.tw(0.16, Enum.EasingStyle.Quad), {
                Position = state and G.Math.ud2(1, -16, 0.5, -7) or G.Math.ud2(0, 2, 0.5, -7),
                BackgroundColor3 = state and G.Math.rgb(2, 22, 28) or THEME.muted
            }):Play()
            G.Services.TweenService:Create(label, G.Math.tw(0.16), {
                TextColor3 = THEME.text
            }):Play()
            if stroke then
                G.Services.TweenService:Create(stroke, G.Math.tw(0.16), {
                    Color = state and THEME.cyan or THEME.cyanSoft
                }):Play()
            end
        end

        S.UI_STORAGE[key] = S.UI_STORAGE[key] or {}
        table.insert(S.UI_STORAGE[key], {type = "toggle", track = switchTrack, dot = switchDot, label = label, update = updateVisual})
        S.registeredSearchElements[#S.registeredSearchElements + 1] = {container = btn, key = key}

        btn.MouseButton1Click:Connect(function()
            G.Services.TweenService:Create(btn, G.Math.tw(0.08), {BackgroundColor3 = THEME.buttonActive}):Play()
            task.delay(0.1, function()
                G.Services.TweenService:Create(btn, G.Math.tw(0.15), {BackgroundColor3 = THEME.button}):Play()
            end)

            states[key] = not states[key]
            updateVisual(states[key])
            if cb then cb(states[key]) end
        end)

        return btn
    end

    S.createSlider = function(parent, min, max, default, key, step, cb)
        step = step or 1
        states[key] = G.Math.clamp(default or min, min, max)

        local cont = create("Frame", {
            Name = "Slider_" .. key,
            Size = G.Math.ud2(0.98, 0, 0, 52),
            BackgroundColor3 = THEME.button,
            BackgroundTransparency = 0.12,
            ClipsDescendants = true,
            ZIndex = 7,
            Parent = parent
        }, { cCorner(10), cStroke(THEME.cyanSoft, 0.9) })

        local lbl = create("TextLabel", {
            Name = "Title",
            Size = G.Math.ud2(1, -74, 0, 20),
            Position = G.Math.ud2(0, 10, 0, 4),
            BackgroundTransparency = 1,
            Text = getText(key),
            TextColor3 = THEME.text,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextScaled = true,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 8,
            Parent = cont
        }, { cTextConstraint(8, 11) })

        local valBox = create("TextBox", {
            Name = "ValueInput",
            Size = G.Math.ud2(0, 48, 0, 18),
            Position = G.Math.ud2(1, -58, 0, 5),
            BackgroundColor3 = THEME.panel2,
            Text = tostring(states[key]),
            TextColor3 = THEME.text,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            ClearTextOnFocus = false,
            ZIndex = 8,
            Parent = cont
        }, { cCorner(5), cStroke(THEME.cyanSoft, 0.8) })

        local decBtn = create("TextButton", {
            Name = "DecBtn",
            Size = G.Math.ud2(0, 24, 0, 22),
            Position = G.Math.ud2(0, 8, 0, 25),
            BackgroundColor3 = THEME.buttonActive,
            Text = "—",
            TextColor3 = THEME.cyan,
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            AutoButtonColor = false,
            ZIndex = 9,
            Parent = cont
        }, { cCorner(5), cStroke(THEME.cyanSoft, 0.8) })

        local incBtn = create("TextButton", {
            Name = "IncBtn",
            Size = G.Math.ud2(0, 24, 0, 22),
            Position = G.Math.ud2(1, -32, 0, 25),
            BackgroundColor3 = THEME.buttonActive,
            Text = "+",
            TextColor3 = THEME.cyan,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            AutoButtonColor = false,
            ZIndex = 9,
            Parent = cont
        }, { cCorner(5), cStroke(THEME.cyanSoft, 0.8) })

        local hitZone = create("TextButton", {
            Name = "SlideHitZone",
            Size = G.Math.ud2(1, -74, 0, 22),
            Position = G.Math.ud2(0, 37, 0, 25),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 9,
            Parent = cont
        })

        local slideTrack = create("Frame", {
            Name = "TrackVisual",
            Size = G.Math.ud2(1, 0, 0, 6),
            Position = G.Math.ud2(0, 0, 0.5, -3),
            BackgroundColor3 = THEME.panel,
            BorderSizePixel = 0,
            ZIndex = 8,
            Parent = hitZone
        }, { cCorner(3) })

        local fillPct = G.Math.clamp((states[key] - min) / (max - min), 0, 1)
        local fill = create("Frame", {
            Name = "Fill",
            Size = G.Math.ud2(fillPct, 0, 1, 0),
            BackgroundColor3 = THEME.cyan,
            ZIndex = 9,
            Parent = slideTrack
        }, { cCorner(3) })

        local function applyVal(val, updateBox)
            val = G.Math.clamp(val, min, max)
            if step > 0 then val = G.Math.floor((val / step) + 0.5) * step end
            states[key] = val
            local pct = G.Math.clamp((val - min) / (max - min), 0, 1)
            G.Services.TweenService:Create(fill, G.Math.tw(0.08), {Size = G.Math.ud2(pct, 0, 1, 0)}):Play()
            if updateBox then valBox.Text = tostring(val) end
            if cb then cb(val) end
        end

        decBtn.MouseButton1Click:Connect(function()
            applyVal(states[key] - step, true)
            G.Services.TweenService:Create(decBtn, G.Math.tw(0.08), {BackgroundColor3 = THEME.cyanSoft}):Play()
            task.delay(0.1, function() G.Services.TweenService:Create(decBtn, G.Math.tw(0.1), {BackgroundColor3 = THEME.buttonActive}):Play() end)
        end)

        incBtn.MouseButton1Click:Connect(function()
            applyVal(states[key] + step, true)
            G.Services.TweenService:Create(incBtn, G.Math.tw(0.08), {BackgroundColor3 = THEME.cyanSoft}):Play()
            task.delay(0.1, function() G.Services.TweenService:Create(incBtn, G.Math.tw(0.1), {BackgroundColor3 = THEME.buttonActive}):Play() end)
        end)

        valBox.FocusLost:Connect(function()
            local num = tonumber(valBox.Text)
            if num then applyVal(num, true) else valBox.Text = tostring(states[key]) end
        end)

        local dragging = false
        hitZone.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                local percent = G.Math.clamp((input.Position.X - hitZone.AbsolutePosition.X) / hitZone.AbsoluteSize.X, 0, 1)
                applyVal(min + (max - min) * percent, true)
            end
        end)

        G.Services.UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        G.Services.UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local percent = G.Math.clamp((input.Position.X - hitZone.AbsolutePosition.X) / hitZone.AbsoluteSize.X, 0, 1)
                applyVal(min + (max - min) * percent, true)
            end
        end)

        S.UI_STORAGE[key] = S.UI_STORAGE[key] or {}
        table.insert(S.UI_STORAGE[key], {type = "slider", fill = fill, box = valBox, label = lbl, apply = applyVal})
        S.registeredSearchElements[#S.registeredSearchElements + 1] = {container = cont, key = key}

        return cont
    end

    S.createActionButton = function(parent, key, cb)
        local isInsideRow = (parent:IsA("Frame") and parent.Name ~= "Farm" and parent.Name ~= "Magnet" and parent.Name ~= "Visuals" and parent.Name ~= "Combat" and parent.Name ~= "Movement" and parent.Name ~= "Rewards" and parent.Name ~= "Settings")
        
        local label = create("TextLabel", {
            Name = "BtnLabel",
            Size = G.Math.ud2(1, -14, 1, -4),
            Position = G.Math.ud2(0, 7, 0, 2),
            BackgroundTransparency = 1,
            Text = getText(key),
            TextColor3 = G.Math.rgb(240, 240, 250),
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextScaled = true,
            TextWrapped = true,
            ZIndex = 8
        }, { cTextConstraint(8, 11) })

        local btn = create("TextButton", {
            Name = "Action_" .. key,
            Size = isInsideRow and G.Math.ud2(0.48, 0, 0, isSmallScreen and 31 or 38) or G.Math.ud2(0.98, 0, 0, isSmallScreen and 31 or 38),
            Text = "",
            BackgroundColor3 = THEME.button,
            BackgroundTransparency = 0.08,
            AutoButtonColor = false,
            ClipsDescendants = true,
            ZIndex = 7,
            Parent = parent
        }, { cCorner(10), cStroke(THEME.cyanSoft, 1), label })

        S.localizedLabels[#S.localizedLabels + 1] = {instance = label, key = key}
        S.registeredSearchElements[#S.registeredSearchElements + 1] = {container = btn, key = key}

        btn.MouseButton1Click:Connect(function()
            G.Services.TweenService:Create(btn, G.Math.tw(0.08), {BackgroundColor3 = THEME.buttonActive}):Play()
            task.delay(0.12, function()
                G.Services.TweenService:Create(btn, G.Math.tw(0.15), {BackgroundColor3 = THEME.button}):Play()
            end)
            if cb then cb() end
        end)

        return btn
    end

    -- ====================================================================
    --                  МОДАЛЬНОЕ ОКНО ЧЕНДЖЛОГА
    -- ====================================================================
    local changelogData = {
        version = "v5.0 Master",
        changes = {
            Russian = {
                "Удалена авто-покупка улучшений по запросу",
                "Flash-Вакуум переписан с приоритетом TimeLeft и сортировкой дистанции",
                "Исправлен авто-сбор наград таймера и колеса фортуны",
                "Рандом ТП фарм теперь ориентируется строго на цель перед захватом",
                "Авто-селл полностью синхронизирован с сервером и WarningText",
                "Добавлена полная двуязычная локализация (RU/EN, по умолчанию EN)"
            },
            English = {
                "Removed auto-purchasing upgrades per user request",
                "Flash Vacuum redesigned with TimeLeft priority and distance sorting",
                "Fixed timed reward and lucky wheel auto-claiming",
                "Random TP Farm now strictly orients towards target before grab",
                "Auto-Sell perfectly synchronized with server error and WarningText",
                "Full bilingual localization integrated (RU/EN, default English)"
            }
        }
    }

    local function showChangelogModal()
        local vpNow = Camera.ViewportSize
        local isSmall = vpNow.X < 700 or isTouchDevice
        local cardW = isSmall and G.Math.clamp(G.Math.floor(vpNow.X * 0.85), 280, 370) or 400
        local cardH = isSmall and G.Math.clamp(G.Math.floor(vpNow.Y * 0.70), 260, 350) or 340

        local overlay = create("TextButton", {
            Name = "ChangelogOverlay",
            Size = G.Math.ud2(1, 0, 1, 0),
            BackgroundColor3 = G.Math.rgb(0, 0, 0),
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Text = "",
            ZIndex = 60,
            Parent = S.ScreenGui
        })

        local card = create("Frame", {
            Name = "ChangelogCard",
            Size = G.Math.ud2(0, cardW * 0.8, 0, cardH * 0.8),
            Position = G.Math.ud2(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = G.Math.rgb(14, 14, 18),
            ZIndex = 61,
            ClipsDescendants = true,
            Parent = overlay
        }, {
            cCorner(12),
            cStroke(G.Math.rgb(65, 65, 80), 1.5)
        })
        makeDraggable(card)

        local topBar = create("Frame", {Size = G.Math.ud2(1, 0, 0, 42), BackgroundTransparency = 1, ZIndex = 62, Parent = card})
        create("TextLabel", {
            Size = G.Math.ud2(0.65, 0, 1, 0),
            Position = G.Math.ud2(0, 14, 0, 0),
            BackgroundTransparency = 1,
            Text = (states.language == "Russian") and "ЧТО НОВОГО" or "WHAT'S NEW",
            TextColor3 = G.Math.rgb(255, 255, 255),
            Font = Enum.Font.GothamBlack,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 63,
            Parent = topBar
        })

        local closeBtn = create("TextButton", {
            Size = G.Math.ud2(0, 26, 0, 26),
            Position = G.Math.ud2(1, -38, 0.5, -13),
            BackgroundColor3 = THEME.button,
            Text = "X",
            TextColor3 = THEME.cyan,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            AutoButtonColor = false,
            ZIndex = 63,
            Parent = topBar
        }, { cCorner(8), cStroke(THEME.cyanSoft, 1) })

        local scroll = create("ScrollingFrame", {
            Size = G.Math.ud2(1, -24, 1, -96),
            Position = G.Math.ud2(0, 12, 0, 44),
            BackgroundColor3 = G.Math.rgb(18, 18, 24),
            ScrollBarThickness = 3,
            CanvasSize = G.Math.ud2(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ZIndex = 62,
            Parent = card
        }, {
            cCorner(8),
            cStroke(G.Math.rgb(40, 40, 50), 1),
            create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = G.Math.ud(0, 6)}),
            create("UIPadding", {PaddingTop = G.Math.ud(0, 8), PaddingBottom = G.Math.ud(0, 8), PaddingLeft = G.Math.ud(0, 8), PaddingRight = G.Math.ud(0, 8)})
        })

        local curList = changelogData.changes[states.language] or changelogData.changes.English
        for _, textLine in ipairs(curList) do
            create("Frame", {
                Size = G.Math.ud2(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = G.Math.rgb(22, 22, 28),
                ZIndex = 63,
                Parent = scroll
            }, {
                cCorner(6),
                create("UIPadding", {PaddingTop = G.Math.ud(0, 6), PaddingBottom = G.Math.ud(0, 6), PaddingLeft = G.Math.ud(0, 8), PaddingRight = G.Math.ud(0, 8)}),
                create("TextLabel", {
                    Size = G.Math.ud2(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Text = "• " .. textLine,
                    TextColor3 = G.Math.rgb(230, 230, 240),
                    Font = Enum.Font.GothamMedium,
                    TextSize = 11,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 64
                })
            })
        end

        local okBtn = create("TextButton", {
            Size = G.Math.ud2(1, -24, 0, 32),
            Position = G.Math.ud2(0, 12, 1, -42),
            BackgroundColor3 = G.Math.rgb(32, 32, 42),
            Text = (states.language == "Russian") and "Понятно!" or "Got it!",
            TextColor3 = G.Math.rgb(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            ZIndex = 63,
            Parent = card
        }, { cCorner(6), cStroke(G.Math.rgb(60, 60, 75), 1) })

        local function closeModal()
            local tw = G.Services.TweenService:Create(overlay, G.Math.tw(0.18), {BackgroundTransparency = 1})
            G.Services.TweenService:Create(card, G.Math.tw(0.18), {Size = G.Math.ud2(0, cardW * 0.8, 0, cardH * 0.8)}):Play()
            tw:Play()
            tw.Completed:Connect(function() overlay:Destroy() end)
        end

        closeBtn.MouseButton1Click:Connect(closeModal)
        okBtn.MouseButton1Click:Connect(closeModal)

        G.Services.TweenService:Create(overlay, G.Math.tw(0.25), {BackgroundTransparency = 0.5}):Play()
        G.Services.TweenService:Create(card, G.Math.tw(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = G.Math.ud2(0, cardW, 0, cardH)}):Play()
    end

    -- ====================================================================
    --                     НАПОЛНЕНИЕ ВКЛАДОК
    -- ====================================================================
    local pageFarm = S.createPage("Farm", "tabFarm")
    local pageAttackTP = S.createPage("AttackTP", "tabAttackTP")
    local pageTPTarget = S.createPage("TPTarget", "tabTPTarget")
    local pageAutoGrabTarget = S.createPage("AutoGrabTarget", "tabAutoGrabTarget")
    local pageMagnet = S.createPage("Magnet", "tabMagnet")
    create("Frame", {
        Name = "PrimaryTabsDivider",
        Size = G.Math.ud2(0.86, 0, 0, 1),
        BackgroundColor3 = THEME.cyanSoft,
        BackgroundTransparency = 0.18,
        BorderSizePixel = 0,
        LayoutOrder = 5,
        ZIndex = 7,
        Parent = S.SidebarContent
    })
    local pageVisuals = S.createPage("Visuals", "tabVisuals")
    local pageCombat = S.createPage("Combat", "tabCombat")
    local pageMovement = S.createPage("Movement", "tabMovement")
    local pageRewards = S.createPage("Rewards", "tabRewards")
    local pageSettings = S.createPage("Settings", "tabSettings")

    -- 1. ВКЛАДКА: ФАРМ (FARM)
    S.createDivider(pageFarm, getText("secFarm"), 1)
    local farmRow1 = S.createRow(pageFarm, 38, 2)
    local function syncFarmToggle(key, value)
        local entries = S.UI_STORAGE[key]
        if entries then
            for _, elem in ipairs(entries) do
                if elem.update then pcall(elem.update, value) end
            end
        end
    end
    local toggleFarm = S.createToggle(farmRow1, "toggleRandomFarm", function(val)
        states.randomTPFarm = val
        if val then
            states.autoEat = false
            syncFarmToggle("toggleAutoEat", false)
        end
        showNotification(getText("toggleRandomFarm") .. ": " .. (val and "ON" or "OFF"), val and "Success" or "Warning")
    end)
    -- AutoFarm and Auto EAT are mutually exclusive; both share only one managed Grab/Eat loop.
    local toggleAutoEat = S.createToggle(farmRow1, "toggleAutoEat", function(val)
        states.autoEat = val
        if val then
            states.randomTPFarm = false
            syncFarmToggle("toggleRandomFarm", false)
        end
        showNotification(getText("toggleAutoEat") .. ": " .. (val and "ON" or "OFF"), val and "Success" or "Info")
    end)

    S.createDivider(pageFarm, getText("secSell"), 3)
    local farmRow2 = S.createRow(pageFarm, 38, 4)
    local toggleSell = S.createToggle(farmRow2, "toggleAutoSell", function(val)
        states.autoSell = val
        showNotification(getText("toggleAutoSell") .. ": " .. (val and "ON" or "OFF"), "Info")
    end)
    local btnSell = S.createActionButton(farmRow2, "btnForceSell", function()
        executeSell()
        showNotification(getText("statusSellSuccess"), "Success")
    end)

    -- 2. ВКЛАДКА: МАГНИТ (MAGNET)
    S.createDivider(pageMagnet, getText("secMagnet"), 1)
    local magRow1 = S.createRow(pageMagnet, 38, 2)
    local toggleVacuum = S.createToggle(magRow1, "toggleFlashVacuum", function(val)
        states.flashVacuum = val
        showNotification(getText("toggleFlashVacuum") .. ": " .. (val and "ON" or "OFF"), val and "Success" or "Warning")
    end)
    local toggleTouchMag = S.createToggle(magRow1, "toggleInstantMagnet", function(val)
        states.instantMagnet = val
        showNotification(getText("toggleInstantMagnet") .. ": " .. (val and "ON" or "OFF"), "Info")
    end)

    local magRow2 = S.createRow(pageMagnet, 38, 3)
    local btnSweep = S.createActionButton(magRow2, "btnSweepOnce", function()
        task.spawn(function()
            local dropsList = getPrioritizedDrops()
            if #dropsList > 0 and HumanoidRootPart then
                local startCF = HumanoidRootPart.CFrame
                for _, itemData in ipairs(dropsList) do
                    local itemPart = itemData.Part
                    if itemPart and itemPart.Parent and canCollect(itemPart) then
                        HumanoidRootPart.CFrame = itemPart.CFrame * CFrame.new(0, 0.4, 0)
                        HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0.1, 0)
                        if typeof(firetouchinterest) == "function" then
                            firetouchinterest(HumanoidRootPart, itemPart, 0)
                            firetouchinterest(HumanoidRootPart, itemPart, 1)
                        end
                        G.Services.RunService.Heartbeat:Wait()
                    end
                end
                HumanoidRootPart.CFrame = startCF
                HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                showNotification("Sweep complete! Gathered items.", "Success")
            end
        end)
    end)

    -- 3. ВКЛАДКА: ВИЗУАЛ (VISUALS)
    S.createDivider(pageVisuals, getText("secVisuals"), 1)
    local visRow1 = S.createRow(pageVisuals, 38, 2)
    local toggleESP = S.createToggle(visRow1, "togglePlayerESP", function(val)
        states.playerESP = val
        showNotification(getText("togglePlayerESP") .. ": " .. (val and "ON" or "OFF"), "Info")
    end)

    -- 4. ВКЛАДКА: БОЙ (COMBAT)
    S.createDivider(pageCombat, getText("secCombat"), 1)
    local speedInputRow = S.createRow(pageCombat, 52, 1)
    local speedInputFrame = create("Frame", {
        Name = "SpeedValueInputFrame",
        Size = G.Math.ud2(0.98, 0, 0, 48),
        BackgroundColor3 = THEME.button,
        BackgroundTransparency = 0.12,
        ZIndex = 7,
        Parent = speedInputRow
    }, { cCorner(10), cStroke(THEME.cyanSoft, 0.9) })
    create("TextLabel", {
        Name = "SpeedValueLabel",
        Size = G.Math.ud2(0.48, -10, 1, 0),
        Position = G.Math.ud2(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = getText("inputSpeedValue"),
        TextColor3 = THEME.text,
        Font = Enum.Font.GothamBold,
        TextSize = isSmallScreen and 10 or 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 8,
        Parent = speedInputFrame
    })
    local speedValueBox = create("TextBox", {
        Name = "SpeedValueInput",
        Size = G.Math.ud2(0.45, -8, 0, 30),
        Position = G.Math.ud2(0.53, 0, 0.5, -15),
        BackgroundColor3 = THEME.panel2,
        Text = tostring(states.speedValue),
        PlaceholderText = "Any number",
        TextColor3 = THEME.cyan,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 8,
        Parent = speedInputFrame
    }, { cCorner(7), cStroke(THEME.cyan, 1) })
    speedValueBox.FocusLost:Connect(function()
        local value = tonumber(speedValueBox.Text)
        if value and value >= 0 then
            states.speedValue = value
            speedValueBox.Text = tostring(value)
        else
            speedValueBox.Text = tostring(states.speedValue)
            showNotification("Enter a number 0 or higher", "Warning")
        end
    end)

    local speedToggleRow = S.createRow(pageCombat, 38, 2)
    local toggleRunSpeed = S.createToggle(speedToggleRow, "toggleRunSpeed", function(val)
        states.speedEnabled = val
        showNotification(getText("toggleRunSpeed") .. ": " .. (val and "ON" or "OFF"), "Info")
    end)
    local safetyRow = S.createRow(pageCombat, 38, 4)
    local toggleAntiVoid = S.createToggle(safetyRow, "toggleAntiVoid", function(val)
        states.antiVoid = val
        showNotification(getText("toggleAntiVoid") .. ": " .. (val and "ON" or "OFF"), "Info")
    end)
    local toggleBigPlatform = S.createToggle(safetyRow, "toggleBigPlatform", function(val)
        states.bigPlatform = val
        showNotification(getText("toggleBigPlatform") .. ": " .. (val and "ON" or "OFF"), "Info")
    end)
    local antiAnchorRow = S.createRow(pageCombat, 38, 5)
    local toggleAntiAnchor = S.createToggle(antiAnchorRow, "toggleAntiAnchor", function(val)
        states.antiAnchor = val
        showNotification(getText("toggleAntiAnchor") .. ": " .. (val and "ON" or "OFF"), "Info")
    end)

    -- ATTACK TP has its own page immediately below FARM in the sidebar.
    -- Compact layout: player list begins immediately, without a section heading.
    local attackTPEnabled = false
    local attackTPPhase = "idle"
    local attackTarget = nil
    local attackFollowConnection = nil
    local attackPlayerButtons = {}

    local attackPlayerList = create("ScrollingFrame", {
        Name = "AttackTPPlayerList",
        Size = G.Math.ud2(0.98, 0, 0, isSmallScreen and 250 or 330),
        Active = true,
        BackgroundColor3 = Color3.fromRGB(7, 18, 27),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ScrollBarThickness = isSmallScreen and 6 or 8,
        ScrollBarImageColor3 = THEME.cyan,
        CanvasSize = G.Math.ud2(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        LayoutOrder = 1,
        Parent = pageAttackTP
    }, {
        cCorner(8),
        cStroke(THEME.cyanSoft, 1),
        create("UIListLayout", {
            Padding = G.Math.ud(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder
        }),
        create("UIPadding", {
            PaddingTop = G.Math.ud(0, 5),
            PaddingBottom = G.Math.ud(0, 5),
            PaddingLeft = G.Math.ud(0, 5),
            PaddingRight = G.Math.ud(0, 5)
        })
    })

    -- Route actions through createActionButton's existing MouseButton1Click handler.
    -- This matches the rest of Drama's controls and is reliable on touch devices.
    local attackRefreshAction, attackToggleAction, attackStopAction
    local attackRefreshRow = S.createRow(pageAttackTP, 44, 3)
    local attackRefreshBtn = S.createActionButton(attackRefreshRow, "btnAttackTPRefresh", function()
        if attackRefreshAction then attackRefreshAction() end
    end)

    -- The ON/OFF switch lives on each player's own row, matching the approved preview.
    local function styleAttackButton(btn, label, color)
        if not btn then return end
        local lbl = btn:FindFirstChild("BtnLabel")
        if lbl then lbl.Text = label end
        btn.BackgroundColor3 = color
    end
    styleAttackButton(attackRefreshBtn, "REFRESH PLAYERS", THEME.button)

    local function attackGetCharacter()
        local char = player.Character
        if not char then return nil, nil end
        return char, char:FindFirstChild("HumanoidRootPart")
    end

    local function attackRandomPosition()
        return Vector3.new(math.random(-140, 140), math.random(10, 50), math.random(-140, 140))
    end

    local function attackDisconnectFollow()
        if attackFollowConnection then
            attackFollowConnection:Disconnect()
            attackFollowConnection = nil
        end
    end

    local function attackStop(message)
        attackTPEnabled = false
        attackTPPhase = "idle"
        attackDisconnectFollow()
    end

    local function attackRefreshPlayers()
        -- Remove only rows owned by this list; preserve UIListLayout/UIPadding/stable controls.
        for _, child in ipairs(attackPlayerList:GetChildren()) do
            if string.sub(child.Name, 1, 16) == "AttackTargetRow_" then
                child:Destroy()
            end
        end

        attackPlayerButtons = {}

        local allPlayers = G.Services.Players:GetPlayers()
        table.sort(allPlayers, function(a, b)
            return string.lower(a.DisplayName .. a.Name) < string.lower(b.DisplayName .. b.Name)
        end)

        local targets = {}
        for _, targetPlayer in ipairs(allPlayers) do
            if targetPlayer ~= player then
                table.insert(targets, targetPlayer)
            end
        end

        -- Always keep at least eight visible rows so the panel layout stays consistent.
        local slotCount = math.max(8, #targets)
        for i = 1, slotCount do
            local targetPlayer = targets[i]
            local selected = targetPlayer ~= nil
                and targetPlayer == attackTarget
                and attackTPEnabled

            local row = create("TextButton", {
                Name = "AttackTargetRow_" .. (targetPlayer and tostring(targetPlayer.UserId) or ("Empty_" .. tostring(i))),
                Size = G.Math.ud2(1, -2, 0, isSmallScreen and 34 or 38),
                BackgroundColor3 = selected and Color3.fromRGB(0, 67, 82) or Color3.fromRGB(8, 30, 40),
                BackgroundTransparency = targetPlayer and 0 or 0.55,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
                Active = targetPlayer ~= nil,
                Selectable = targetPlayer ~= nil,
                LayoutOrder = i,
                ZIndex = 31,
                Parent = attackPlayerList
            }, {
                cCorner(7),
                cStroke(selected and THEME.cyan or THEME.cyanSoft, selected and 1.8 or 0.7)
            })

            create("TextLabel", {
                Name = "PlayerName",
                Size = G.Math.ud2(1, -16, 1, 0),
                Position = G.Math.ud2(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = targetPlayer and (targetPlayer.DisplayName .. "  (@" .. targetPlayer.Name .. ")") or "— Slot kosong —",
                TextColor3 = selected and THEME.cyan or (targetPlayer and THEME.text or THEME.muted),
                Font = Enum.Font.GothamBold,
                TextSize = isSmallScreen and 9 or 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Active = false,
                ZIndex = 32,
                Parent = row
            })

            attackPlayerButtons[#attackPlayerButtons + 1] = row

            if targetPlayer then
                local thisPlayer = targetPlayer
                row.Activated:Connect(function()
                    if thisPlayer.Parent ~= G.Services.Players then
                        attackRefreshPlayers()
                        return
                    end

                    if attackTPEnabled and attackTarget == thisPlayer then
                        attackStop("Attack TP OFF: " .. thisPlayer.Name)
                    else
                        if attackTPEnabled then
                            attackStop("Target diganti")
                        end
                        attackTarget = thisPlayer
                        attackTPEnabled = true
                        attackTPPhase = "idle"
                    end

                    attackRefreshPlayers()
                end)
            end
        end

    end

    attackRefreshAction = attackRefreshPlayers
    attackToggleAction = function()
        if attackTPEnabled then
            attackStop("Attack TP dihentikan")
            return
        end
        if not attackTarget or attackTarget.Parent ~= G.Services.Players then
            return
        end
        attackTPEnabled = true
        attackTPPhase = "idle"
    end
    attackStopAction = function() attackStop("Attack TP dihentikan") end

    G.Services.Players.PlayerAdded:Connect(function()
        task.defer(attackRefreshPlayers)
    end)
    G.Services.Players.PlayerRemoving:Connect(function(leavingPlayer)
        if leavingPlayer == attackTarget then
            attackTarget = nil
            attackStop("Target keluar")
        end
        task.defer(attackRefreshPlayers)
    end)

    -- Rev 7 cadence: random TP every 0.3s; then Grab, follow target, and Throw.
    task.spawn(function()
        while S.Runtime.running do
            if attackTPEnabled and attackTPPhase ~= "follow" then
                local char, root = attackGetCharacter()
                if char and root then
                    pcall(function() char:PivotTo(CFrame.new(attackRandomPosition())) end)
                end
                task.wait(0.3)
            else
                task.wait(0.05)
            end
        end
    end)

    task.spawn(function()
        while S.Runtime.running do
            if not attackTPEnabled then
                task.wait(0.15)
            else
                local target = attackTarget
                local char, root = attackGetCharacter()
                local targetChar = target and target.Character
                local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                if target and target.Parent == G.Services.Players and targetRoot and char and root then
                    attackTPPhase = "prepare"
                    task.wait(1.5)
                    if not S.Runtime.running or not attackTPEnabled then attackTPPhase = "idle"; continue end

                    char, root = attackGetCharacter()
                    local events = char and char:FindFirstChild("Events")
                    local grab = events and events:FindFirstChild("Grab")
                    if grab then pcall(function() grab:FireServer() end) end

                    task.wait(2)
                    if not S.Runtime.running or not attackTPEnabled then attackTPPhase = "idle"; continue end

                    target = attackTarget
                    targetChar = target and target.Character
                    targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                    char, root = attackGetCharacter()
                    events = char and char:FindFirstChild("Events")
                    if targetRoot and char and root then
                        attackTPPhase = "follow"
                        attackFollowConnection = G.Services.RunService.Heartbeat:Connect(function()
                            if not S.Runtime.running or not attackTPEnabled then return end
                            local currentTarget = attackTarget
                            local currentTargetChar = currentTarget and currentTarget.Character
                            local currentTargetRoot = currentTargetChar and currentTargetChar:FindFirstChild("HumanoidRootPart")
                            local currentChar, currentRoot = attackGetCharacter()
                            if currentTargetRoot and currentTargetChar and currentChar and currentRoot then
                                local mySize = currentChar:GetExtentsSize().Z
                                local targetSize = currentTargetChar:GetExtentsSize().Z
                                local safeDistance = (mySize / 2) + (targetSize / 2) + 2
                                currentChar:PivotTo(currentTargetRoot.CFrame * CFrame.new(0, 0, safeDistance))
                            end
                        end)
                    end

                    local throwEvent = events and events:FindFirstChild("Throw")
                    if throwEvent then pcall(function() throwEvent:FireServer() end) end
                    task.wait(1.5)
                    attackDisconnectFollow()
                    attackTPPhase = "idle"
                    task.wait(1)
                else
                    attackTPPhase = "idle"
                    task.wait(0.2)
                end
            end
        end
        attackStop("Drama dihentikan")
    end)

    -- Defer initial population until the rest of the UI has been constructed.
    -- Keep a failed refresh from aborting creation of later feature tabs.
    task.defer(function()
        if S.Runtime.running then
            local ok, err = pcall(attackRefreshPlayers)
            if not ok then warn("[ETWDRAMA] TP ATTACK player refresh failed:", err) end
        end
    end)
    task.delay(0.75, function()
        if S.Runtime.running then
            local ok, err = pcall(attackRefreshPlayers)
            if not ok then warn("[ETWDRAMA] TP ATTACK player refresh failed:", err) end
        end
    end)


    local autoGrabStop

    -- ====================================================================
    -- TP TARGET: separate cycle, same player-row toggle style as TP ATTACK.
    -- Click a player row to activate; click it again to stop.
    -- Cycle: teleport close behind target -> wait 1.5s -> random nearby area.
    -- ====================================================================
    -- Compact layout: refresh control at the top-right, followed immediately by player rows.

    local tpTargetEnabled = false
    local tpTargetPlayer = nil
    local tpTargetToken = 0
    local tpTargetOrigin = nil
    local tpTargetRows = {}
    local tpTargetRefreshAction

    local tpTargetRefreshRow = create("Frame", {
        Name = "TPTargetRefreshRow",
        Size = G.Math.ud2(0.98, 0, 0, 26),
        BackgroundTransparency = 1,
        LayoutOrder = 0,
        ZIndex = 7,
        Parent = pageTPTarget
    })
    local tpTargetRefreshBtn = S.createActionButton(tpTargetRefreshRow, "btnAttackTPRefresh", function()
        if tpTargetRefreshAction then tpTargetRefreshAction() end
    end)
    tpTargetRefreshBtn.Size = G.Math.ud2(0, isSmallScreen and 82 or 96, 0, 23)
    tpTargetRefreshBtn.AnchorPoint = Vector2.new(1, 0)
    tpTargetRefreshBtn.Position = G.Math.ud2(1, 0, 0, 0)
    styleAttackButton(tpTargetRefreshBtn, "REFRESH", THEME.button)

    local function tpTargetGetRoot(char)
        return char and char:FindFirstChild("HumanoidRootPart") or nil
    end

    local function tpTargetSetRowState(target, active)
        local row = tpTargetRows[target]
        if not row or not row.Parent then return end
        row.BackgroundColor3 = active and Color3.fromRGB(0, 67, 82) or Color3.fromRGB(8, 30, 40)
        local stroke = row:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Color = active and THEME.cyan or THEME.cyanSoft
            stroke.Thickness = active and 1.8 or 0.7
        end
        local label = row:FindFirstChild("PlayerName")
        if label then label.TextColor3 = active and THEME.cyan or THEME.text end
    end

    local function tpTargetStop()
        tpTargetEnabled = false
        tpTargetToken += 1
        local previous = tpTargetPlayer
        tpTargetPlayer = nil
        tpTargetOrigin = nil
        if previous then tpTargetSetRowState(previous, false) end
    end

    local function tpTargetRandomCFrame()
        local base = tpTargetOrigin
        if not base then
            local root = tpTargetGetRoot(player.Character)
            base = root and root.CFrame or nil
        end
        if not base then return nil end

        local angle = math.random() * math.pi * 2
        local distance = math.random(20, 80)
        local offset = Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)
        local position = base.Position + offset
        return CFrame.new(position, position + base.LookVector)
    end

    local function tpTargetRun(target, token)
        while S.Runtime.running and tpTargetEnabled and tpTargetToken == token and tpTargetPlayer == target do
            if target.Parent ~= G.Services.Players then break end

            local targetRoot = tpTargetGetRoot(target.Character)
            local localRoot = tpTargetGetRoot(player.Character)
            if not targetRoot or not localRoot then
                task.wait(0.2)
            else
                -- Positive local Z places the character behind the target's facing direction.
                local behind = targetRoot.CFrame * CFrame.new(0, 0, 2.5)
                local char = player.Character
                if char then pcall(function() char:PivotTo(CFrame.new(behind.Position, targetRoot.Position)) end) end

                local elapsed = 0
                while elapsed < 1.5 and S.Runtime.running and tpTargetEnabled and tpTargetToken == token do
                    local step = math.min(0.1, 1.5 - elapsed)
                    task.wait(step)
                    elapsed += step
                end

                if S.Runtime.running and tpTargetEnabled and tpTargetToken == token then
                    local currentChar = player.Character
                    local destination = tpTargetRandomCFrame()
                    if currentChar and destination then
                        pcall(function() currentChar:PivotTo(destination) end)
                    end
                end
            end
            task.wait(0.05)
        end

        if tpTargetToken == token then
            tpTargetStop()
            task.defer(function()
                if S.Runtime.running then tpTargetRefreshAction() end
            end)
        end
    end

    local function tpTargetToggle(target)
        if autoGrabStop then autoGrabStop() end
        if tpTargetEnabled and tpTargetPlayer == target then
            tpTargetStop()
            return
        end

        tpTargetStop()
        local root = tpTargetGetRoot(player.Character)
        if not root then
            showNotification("Character is not ready yet", "Warning")
            return
        end

        tpTargetPlayer = target
        tpTargetOrigin = root.CFrame
        tpTargetEnabled = true
        tpTargetToken += 1
        local token = tpTargetToken
        tpTargetSetRowState(target, true)
        task.spawn(tpTargetRun, target, token)
    end

    tpTargetRefreshAction = function()
        for _, child in ipairs(pageTPTarget:GetChildren()) do
            if string.sub(child.Name, 1, 12) == "TPTargetRow_" then
                child:Destroy()
            end
        end
        tpTargetRows = {}

        local targets = {}
        for _, target in ipairs(G.Services.Players:GetPlayers()) do
            if target ~= player then table.insert(targets, target) end
        end
        table.sort(targets, function(a, b)
            return string.lower(a.DisplayName .. a.Name) < string.lower(b.DisplayName .. b.Name)
        end)

        local slotCount = math.max(8, #targets)
        for i = 1, slotCount do
            local target = targets[i]
            local selected = target ~= nil and target == tpTargetPlayer and tpTargetEnabled
            local row = create("TextButton", {
                Name = "TPTargetRow_" .. (target and tostring(target.UserId) or ("Empty_" .. tostring(i))),
                Size = G.Math.ud2(0.98, 0, 0, isSmallScreen and 34 or 38),
                BackgroundColor3 = selected and Color3.fromRGB(0, 67, 82) or Color3.fromRGB(8, 30, 40),
                BackgroundTransparency = target and 0 or 0.55,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
                Active = target ~= nil,
                Selectable = target ~= nil,
                LayoutOrder = i,
                ZIndex = 7,
                Parent = pageTPTarget
            }, {
                cCorner(7),
                cStroke(selected and THEME.cyan or THEME.cyanSoft, selected and 1.8 or 0.7)
            })

            create("TextLabel", {
                Name = "PlayerName",
                Size = G.Math.ud2(1, -16, 1, 0),
                Position = G.Math.ud2(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = target and (target.DisplayName .. "  (@" .. target.Name .. ")") or "— Slot kosong —",
                TextColor3 = selected and THEME.cyan or (target and THEME.text or THEME.muted),
                Font = Enum.Font.GothamBold,
                TextSize = isSmallScreen and 9 or 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Active = false,
                ZIndex = 8,
                Parent = row
            })

            if target then
                tpTargetRows[target] = row
                local thisTarget = target
                row.Activated:Connect(function()
                    if thisTarget.Parent ~= G.Services.Players then
                        tpTargetRefreshAction()
                        return
                    end
                    tpTargetToggle(thisTarget)
                    tpTargetRefreshAction()
                end)
            end
        end
    end

    S.Runtime.connections[#S.Runtime.connections + 1] = G.Services.Players.PlayerAdded:Connect(function()
        task.defer(function()
            if S.Runtime.running and tpTargetRefreshAction then tpTargetRefreshAction() end
        end)
    end)
    S.Runtime.connections[#S.Runtime.connections + 1] = G.Services.Players.PlayerRemoving:Connect(function(leavingPlayer)
        if leavingPlayer == tpTargetPlayer then tpTargetStop() end
        task.defer(function()
            if S.Runtime.running and tpTargetRefreshAction then tpTargetRefreshAction() end
        end)
    end)

    tpTargetRefreshAction()
    task.delay(0.75, function()
        if S.Runtime.running then tpTargetRefreshAction() end
    end)

    -- ====================================================================
    -- AUTO GRAB TARGET: integrated V8 logic, placed directly below TP TARGET.
    -- Mutually exclusive with TP TARGET; only one teleport cycle may run.
    -- ====================================================================
    local autoGrabEnabled = false
    local autoGrabSelectedPlayer = nil
    local autoGrabToken = 0
    local autoGrabStartCFrame = nil
    local autoGrabRows = {}
    local autoGrabRefreshAction

    local AUTO_GRAB_ATTEMPTS = 4
    local AUTO_GRAB_ATTEMPT_DELAY = 0.18
    local AUTO_GRAB_BEFORE_DELAY = 0.035
    local AUTO_GRAB_HOLD_TIME = 1.5
    local AUTO_GRAB_RETURN_DELAY = 0.15
    local AUTO_GRAB_CYCLE_DELAY = 0.35
    local AUTO_GRAB_DROP_RADIUS = 6
    local AUTO_GRAB_BEHIND_DISTANCE = 2.5
    local AUTO_GRAB_BEHIND_HEIGHT = 0.15
    local AUTO_GRAB_LEAD_TIME = 0.10
    local AUTO_GRAB_MAX_LEAD = 1.25
    local AUTO_GRAB_DROP_NAMES = {Cube=true, Token=true, Candy=true, Present=true, Ornament=true, Egg=true}

    local autoGrabRefreshRow = create("Frame", {
        Name = "AutoGrabTargetRefreshRow",
        Size = G.Math.ud2(0.98, 0, 0, 26),
        BackgroundTransparency = 1,
        LayoutOrder = 0,
        ZIndex = 7,
        Parent = pageAutoGrabTarget
    })
    local autoGrabRefreshBtn = S.createActionButton(autoGrabRefreshRow, "btnAttackTPRefresh", function()
        if autoGrabRefreshAction then autoGrabRefreshAction() end
    end)
    autoGrabRefreshBtn.Size = G.Math.ud2(0, isSmallScreen and 82 or 96, 0, 23)
    autoGrabRefreshBtn.AnchorPoint = Vector2.new(1, 0)
    autoGrabRefreshBtn.Position = G.Math.ud2(1, 0, 0, 0)
    styleAttackButton(autoGrabRefreshBtn, "REFRESH", THEME.button)

    local function autoGrabGetCharacter(targetPlayer)
        targetPlayer = targetPlayer or player
        local character = targetPlayer.Character
        if not character then return nil, nil, nil end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root or humanoid.Health <= 0 then return nil, nil, nil end
        return character, humanoid, root
    end

    local function autoGrabTeleport(cframe)
        local character = player.Character
        if not character or not cframe then return false end
        return pcall(function() character:PivotTo(cframe) end)
    end

    local function autoGrabTargetValid(target, token)
        local _, _, root = autoGrabGetCharacter(target)
        return S.Runtime.running and autoGrabEnabled and autoGrabToken == token
            and autoGrabSelectedPlayer == target and target ~= nil
            and target.Parent == G.Services.Players and root ~= nil
    end

    local function autoGrabTeleportBehind(targetRoot)
        if not targetRoot or not targetRoot.Parent then return false end
        local velocity = targetRoot.AssemblyLinearVelocity
        local lead = Vector3.new(velocity.X, 0, velocity.Z) * AUTO_GRAB_LEAD_TIME
        if lead.Magnitude > AUTO_GRAB_MAX_LEAD then lead = lead.Unit * AUTO_GRAB_MAX_LEAD end
        local predictedPosition = targetRoot.Position + lead
        local behindPosition = predictedPosition - targetRoot.CFrame.LookVector * AUTO_GRAB_BEHIND_DISTANCE
            + Vector3.new(0, AUTO_GRAB_BEHIND_HEIGHT, 0)
        return autoGrabTeleport(CFrame.lookAt(behindPosition, predictedPosition))
    end

    local function autoGrabNearbyDrop()
        local _, _, root = autoGrabGetCharacter(player)
        if not root then return true, "character unavailable" end
        local ok, result = pcall(function()
            for _, item in ipairs(G.Services.Workspace:GetDescendants()) do
                if item:IsA("BasePart") and AUTO_GRAB_DROP_NAMES[item.Name] then
                    local ancestor = item.Parent
                    local belongsToCharacter = false
                    while ancestor and ancestor ~= G.Services.Workspace do
                        if ancestor:IsA("Model") and G.Services.Players:GetPlayerFromCharacter(ancestor) then
                            belongsToCharacter = true
                            break
                        end
                        ancestor = ancestor.Parent
                    end
                    if not belongsToCharacter and (item.Position - root.Position).Magnitude <= AUTO_GRAB_DROP_RADIUS then
                        return item.Name
                    end
                end
            end
            return nil
        end)
        if not ok then return true, "drop scan failed" end
        if result then return true, "nearby drop: " .. tostring(result) end
        return false, nil
    end

    local function autoGrabFire()
        local localEvents = G.Services.ReplicatedStorage:FindFirstChild("LocalEvents")
        local grabEvent = localEvents and localEvents:FindFirstChild("Grab")
        if not grabEvent or not grabEvent:IsA("BindableEvent") then
            return false, "LocalEvents.Grab unavailable"
        end
        local blocked, reason = autoGrabNearbyDrop()
        if blocked then return false, "Grab skipped: " .. tostring(reason) end
        local ok, err = pcall(function() grabEvent:Fire() end)
        if not ok then return false, "Grab failed: " .. tostring(err) end
        return true, "Grab called"
    end

    autoGrabStop = function()
        autoGrabEnabled = false
        autoGrabToken += 1
        local previous = autoGrabSelectedPlayer
        autoGrabSelectedPlayer = nil
        autoGrabStartCFrame = nil
        if previous then
            local row = autoGrabRows[previous]
            if row and row.Parent then
                row.BackgroundColor3 = Color3.fromRGB(8, 30, 40)
                local stroke = row:FindFirstChildOfClass("UIStroke")
                if stroke then stroke.Color = THEME.cyanSoft; stroke.Thickness = 0.7 end
                local label = row:FindFirstChild("PlayerName")
                if label then label.TextColor3 = THEME.text end
            end
        end
    end

    local function autoGrabSetRowState(target, active)
        local row = autoGrabRows[target]
        if not row or not row.Parent then return end
        row.BackgroundColor3 = active and Color3.fromRGB(0, 67, 82) or Color3.fromRGB(8, 30, 40)
        local stroke = row:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Color = active and THEME.cyan or THEME.cyanSoft; stroke.Thickness = active and 1.8 or 0.7 end
        local label = row:FindFirstChild("PlayerName")
        if label then label.TextColor3 = active and THEME.cyan or THEME.text end
    end

    local function autoGrabRun(target, token, startCFrame)
        while autoGrabTargetValid(target, token) do
            local _, _, targetRoot = autoGrabGetCharacter(target)
            local _, _, myRoot = autoGrabGetCharacter(player)
            if not targetRoot or not myRoot then break end
            if not autoGrabTeleportBehind(targetRoot) then break end
            task.wait(AUTO_GRAB_BEFORE_DELAY)

            local anyGrabCalled = false
            for attempt = 1, AUTO_GRAB_ATTEMPTS do
                if not autoGrabTargetValid(target, token) then break end
                targetRoot = select(3, autoGrabGetCharacter(target))
                if not targetRoot or not autoGrabTeleportBehind(targetRoot) then break end
                task.wait(AUTO_GRAB_BEFORE_DELAY)
                targetRoot = select(3, autoGrabGetCharacter(target))
                if not targetRoot or not autoGrabTeleportBehind(targetRoot) then break end
                local called = autoGrabFire()
                if called then
                    anyGrabCalled = true
                else
                    break
                end
                if attempt < AUTO_GRAB_ATTEMPTS then task.wait(AUTO_GRAB_ATTEMPT_DELAY) end
            end

            if anyGrabCalled and autoGrabTargetValid(target, token) then
                local elapsed = 0
                while elapsed < AUTO_GRAB_HOLD_TIME and autoGrabTargetValid(target, token) do
                    local step = math.min(0.1, AUTO_GRAB_HOLD_TIME - elapsed)
                    task.wait(step)
                    elapsed += step
                end
            end
            if not autoGrabEnabled or autoGrabToken ~= token then break end
            if startCFrame then autoGrabTeleport(startCFrame) end
            task.wait(AUTO_GRAB_RETURN_DELAY)
            task.wait(AUTO_GRAB_CYCLE_DELAY)
        end
        if autoGrabToken == token then
            autoGrabStop()
            task.defer(function()
                if S.Runtime.running and autoGrabRefreshAction then autoGrabRefreshAction() end
            end)
        end
    end

    local function autoGrabToggle(target)
        if autoGrabEnabled and autoGrabSelectedPlayer == target then
            autoGrabStop()
            return
        end
        -- Safety: never allow TP TARGET and AUTO GRAB TARGET to run together.
        tpTargetStop()
        autoGrabStop()
        local _, _, myRoot = autoGrabGetCharacter(player)
        local _, _, targetRoot = autoGrabGetCharacter(target)
        if not myRoot or not targetRoot then
            showNotification("Character or target is not ready", "Warning")
            return
        end
        autoGrabSelectedPlayer = target
        autoGrabStartCFrame = myRoot.CFrame
        autoGrabEnabled = true
        autoGrabToken += 1
        local token = autoGrabToken
        local startCFrame = autoGrabStartCFrame
        autoGrabSetRowState(target, true)
        task.spawn(autoGrabRun, target, token, startCFrame)
    end

    autoGrabRefreshAction = function()
        for _, child in ipairs(pageAutoGrabTarget:GetChildren()) do
            if string.sub(child.Name, 1, 18) == "AutoGrabTargetRow_" then child:Destroy() end
        end
        autoGrabRows = {}
        local targets = {}
        for _, target in ipairs(G.Services.Players:GetPlayers()) do
            if target ~= player then table.insert(targets, target) end
        end
        table.sort(targets, function(a, b)
            return string.lower(a.DisplayName .. a.Name) < string.lower(b.DisplayName .. b.Name)
        end)
        local slotCount = math.max(8, #targets)
        for i = 1, slotCount do
            local target = targets[i]
            local selected = target ~= nil and target == autoGrabSelectedPlayer and autoGrabEnabled
            local row = create("TextButton", {
                Name = "AutoGrabTargetRow_" .. (target and tostring(target.UserId) or ("Empty_" .. tostring(i))),
                Size = G.Math.ud2(0.98, 0, 0, isSmallScreen and 34 or 38),
                BackgroundColor3 = selected and Color3.fromRGB(0, 67, 82) or Color3.fromRGB(8, 30, 40),
                BackgroundTransparency = target and 0 or 0.55,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
                Active = target ~= nil,
                Selectable = target ~= nil,
                LayoutOrder = i,
                ZIndex = 7,
                Parent = pageAutoGrabTarget
            }, {cCorner(7), cStroke(selected and THEME.cyan or THEME.cyanSoft, selected and 1.8 or 0.7)})
            create("TextLabel", {
                Name = "PlayerName",
                Size = G.Math.ud2(1, -16, 1, 0),
                Position = G.Math.ud2(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = target and (target.DisplayName .. "  (@" .. target.Name .. ")") or "— Slot kosong —",
                TextColor3 = selected and THEME.cyan or (target and THEME.text or THEME.muted),
                Font = Enum.Font.GothamBold,
                TextSize = isSmallScreen and 9 or 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Active = false,
                ZIndex = 8,
                Parent = row
            })
            if target then
                autoGrabRows[target] = row
                local thisTarget = target
                row.Activated:Connect(function()
                    if thisTarget.Parent ~= G.Services.Players then
                        autoGrabRefreshAction()
                        return
                    end
                    autoGrabToggle(thisTarget)
                    autoGrabRefreshAction()
                end)
            end
        end
    end

    S.Runtime.connections[#S.Runtime.connections + 1] = G.Services.Players.PlayerAdded:Connect(function()
        task.defer(function()
            if S.Runtime.running then
                if tpTargetRefreshAction then tpTargetRefreshAction() end
                if autoGrabRefreshAction then autoGrabRefreshAction() end
            end
        end)
    end)
    S.Runtime.connections[#S.Runtime.connections + 1] = G.Services.Players.PlayerRemoving:Connect(function(leavingPlayer)
        if leavingPlayer == tpTargetPlayer then tpTargetStop() end
        if leavingPlayer == autoGrabSelectedPlayer then autoGrabStop() end
        task.defer(function()
            if S.Runtime.running then
                if tpTargetRefreshAction then tpTargetRefreshAction() end
                if autoGrabRefreshAction then autoGrabRefreshAction() end
            end
        end)
    end)

    autoGrabRefreshAction()
    task.delay(0.75, function()
        if S.Runtime.running and autoGrabRefreshAction then autoGrabRefreshAction() end
    end)

    -- 5. ВКЛАДКА: ДВИЖЕНИЕ (MOVEMENT)
    S.createDivider(pageMovement, getText("secMove"), 1)
    local moveRow1 = S.createRow(pageMovement, 38, 2)
    local toggleFly = S.createToggle(moveRow1, "toggleFly", function(val)
        states.fly = val
        showNotification(getText("toggleFly") .. ": " .. (val and "ON" or "OFF"), "Info")
    end)
    local toggleNoclip = S.createToggle(moveRow1, "toggleNoclip", function(val)
        states.noclip = val
        showNotification(getText("toggleNoclip") .. ": " .. (val and "ON" or "OFF"), "Info")
    end)

    local moveRow2 = S.createRow(pageMovement, 38, 3)
    local toggleJump = S.createToggle(moveRow2, "toggleInfJump", function(val)
        states.infJump = val
        showNotification(getText("toggleInfJump") .. ": " .. (val and "ON" or "OFF"), "Info")
    end)

    local moveSliderRow = S.createRow(pageMovement, 52, 4)
    local sliderSpeed = S.createSlider(moveSliderRow, 16, 400, 60, "sliderFlySpeed", 2, function(val)
        states.flySpeed = val
    end)

    -- 6. ВКЛАДКА: НАГРАДЫ (REWARDS)
    S.createDivider(pageRewards, getText("secRewards"), 1)
    local rewRow1 = S.createRow(pageRewards, 38, 2)
    local toggleRewards = S.createToggle(rewRow1, "toggleAutoRewards", function(val)
        states.autoRewards = val
        showNotification(getText("toggleAutoRewards") .. ": " .. (val and "ON" or "OFF"), "Info")
    end)
    local btnClaim = S.createActionButton(rewRow1, "btnClaimAllNow", function()
        claimTimedRewards()
        showNotification(getText("statusRewardsClaimed"), "Success")
    end)

    -- 7. ВКЛАДКА: НАСТРОЙКИ (SETTINGS)
    S.createDivider(pageSettings, getText("secPrefs"), 1)
    local setRow1 = S.createRow(pageSettings, 36, 2)
    local setRow2 = S.createRow(pageSettings, 36, 3)

    local langBtn = create("TextButton", {
        Size = G.Math.ud2(1, 0, 1, 0),
        BackgroundColor3 = THEME.button,
        Text = getText("langBtn"),
        TextColor3 = THEME.text,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextScaled = true,
        TextWrapped = true,
        ClipsDescendants = true,
        ZIndex = 7,
        Parent = setRow1
    }, {cCorner(10), cStroke(THEME.cyanSoft, 0.9), cTextConstraint(9, 12)})

    local keybindBtn = create("TextButton", {
        Size = G.Math.ud2(1, 0, 1, 0),
        BackgroundColor3 = THEME.button,
        Text = getText("menuKeyBtn") .. "[" .. tostring(states.menuKey) .. "]",
        TextColor3 = THEME.text,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextScaled = true,
        TextWrapped = true,
        ClipsDescendants = true,
        ZIndex = 7,
        Parent = setRow2
    }, {cCorner(10), cStroke(THEME.cyanSoft, 0.9), cTextConstraint(9, 12)})

    local changelogBtn = create("TextButton", {
        Size = G.Math.ud2(0.98, 0, 0, 34),
        BackgroundColor3 = THEME.button,
        Text = getText("btnViewChangelog"),
        TextColor3 = THEME.text,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextScaled = true,
        TextWrapped = true,
        ClipsDescendants = true,
        LayoutOrder = 4,
        ZIndex = 7,
        Parent = pageSettings
    }, {cCorner(10), cStroke(THEME.cyanSoft, 0.9), cTextConstraint(9, 12)})
    changelogBtn.MouseButton1Click:Connect(showChangelogModal)

    local isListeningKey = false
    keybindBtn.MouseButton1Click:Connect(function()
        if isListeningKey then return end
        isListeningKey = true
        keybindBtn.Text = getText("pressAnyKey")
        keybindBtn.TextColor3 = G.Math.rgb(255, 255, 255)

        local bindConn
        bindConn = G.Services.UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode and input.KeyCode ~= Enum.KeyCode.Unknown then
                states.menuKey = input.KeyCode.Name
                keybindBtn.Text = getText("menuKeyBtn") .. "[" .. tostring(states.menuKey) .. "]"
                keybindBtn.TextColor3 = G.Math.rgb(220, 220, 235)
                isListeningKey = false
                bindConn:Disconnect()
            end
        end)
    end)

    langBtn.MouseButton1Click:Connect(function()
        states.language = (states.language == "English") and "Russian" or "English"
        langBtn.Text = getText("langBtn")
        keybindBtn.Text = getText("menuKeyBtn") .. "[" .. tostring(states.menuKey) .. "]"
        changelogBtn.Text = getText("btnViewChangelog")
        if S.SearchBox then S.SearchBox.PlaceholderText = getText("searchPlaceholder") end
        
        S.ModalCard.Title.Text = getText("modalCloseTitle")
        S.ModalCard.Desc.Text = getText("modalCloseDesc")
        S.modalBtnCancel.Text = getText("modalBtnCancel")
        S.modalBtnConfirm.Text = getText("modalBtnConfirm")

        local localizedTabIcons = {
            tabFarm = "♧", tabAttackTP = "⚡", tabTPTarget = "⌖", tabAutoGrabTarget = "✊", tabMagnet = "∩", tabVisuals = "◉",
            tabCombat = "⚔", tabMovement = "↗", tabRewards = "✦", tabSettings = "⚙"
        }
        for _, tab in ipairs(S.TabBtns) do
            tab.instance.Text = (localizedTabIcons[tab.key] or "›") .. "   " .. getText(tab.key)
        end
        for k, arr in pairs(S.UI_STORAGE) do
            local txt = getText(k)
            for _, ui in ipairs(arr) do
                if ui.label then
                    ui.label.Text = txt
                end
            end
        end
        for _, obj in ipairs(S.localizedLabels) do
            if obj.instance and obj.instance.Parent then
                obj.instance.Text = getText(obj.key)
            end
        end
        showNotification("Language: " .. states.language, "Info")
    end)

    -- ====================================================================
    --             СИСТЕМА ДИНАМИЧЕСКОЙ СЕТКИ (RESPONSIVE GRID)
    -- ====================================================================
    local currentLayoutMode = nil
    local function setRowDefVisible(row, isVis)
        for _, r in ipairs(S.registeredRows) do
            if r.frame == row then
                r.defaultVisible = isVis
                break
            end
        end
    end

    S.updateResponsiveLayout = function(force)
        local curWidth = S.MainFrame.AbsoluteSize.X
        local newMode = "Compact"
        if curWidth >= 660 then
            newMode = "Wide"
        else
            newMode = "Compact"
        end

        if not force and newMode == currentLayoutMode then
            return
        end
        currentLayoutMode = newMode

        updateRowChildren(farmRow1, 38)
        updateRowChildren(farmRow2, 38)
        updateRowChildren(magRow1, 38)
        updateRowChildren(magRow2, 38)
        updateRowChildren(visRow1, 38)
        updateRowChildren(comRow1, 38)
        updateRowChildren(moveRow1, 38)
        updateRowChildren(moveRow2, 38)
        updateRowChildren(moveSliderRow, 52)
        updateRowChildren(rewRow1, 38)
        updateRowChildren(setRow1, 36)
        updateRowChildren(setRow2, 36)

        if S.SearchBox and S.SearchBox.Text ~= "" then
            S.applySearchFilter(S.SearchBox.Text)
        end
    end

    S.Runtime.connections[#S.Runtime.connections + 1] = S.MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        S.updateResponsiveLayout(false)
    end)
    S.updateResponsiveLayout(true)

    pageFarm.Visible = true
    if S.TabBtns[1] and S.TabBtns[1].instance then
        S.currentActiveTabBtn = S.TabBtns[1].instance
        G.Services.TweenService:Create(S.TabBtns[1].instance, G.Math.tw(0.2), {
            TextColor3 = THEME.cyan,
            BackgroundColor3 = THEME.buttonActive,
            BackgroundTransparency = 0.03
        }):Play()
        local firstTabOutline = S.TabBtns[1].instance:FindFirstChildOfClass("UIStroke")
        if firstTabOutline then
            firstTabOutline.Color = THEME.cyan
            firstTabOutline.Transparency = 0
        end
    end

    -- ====================================================================
    --              ФОНОВЫЕ ПОТОКИ И ИГРОВЫЕ СИСТЕМЫ
    -- ====================================================================
    S.Runtime.connections[#S.Runtime.connections + 1] = G.Services.UserInputService.InputBegan:Connect(function(i, gp)
        if gp or not i or not i.KeyCode or i.KeyCode == Enum.KeyCode.Unknown then return end
        if i.KeyCode.Name == states.menuKey then
            S.setMenuOpen(not S.guiOpen)
        end
    end)

    -- ==============================================================================
    -- AUTO EAT: standalone EAT + GRAB timing matched to rEm Heartbeat pattern.
    -- Auto-sell is included in the same toggle and uses the existing game helpers.
    -- ==============================================================================
    task.spawn(function()
        local lastAutoSell = 0
        while S.Runtime.running do
            if states.autoEat or states.randomTPFarm then
                local char = player.Character
                local events = getCharEvents()
                local currentChunk = char and char:FindFirstChild("CurrentChunk")
                -- Refresh LocalEvents on each pass: a one-time startup lookup can stay nil
                -- if the folder/remotes are created after this script starts.
                local localEvents = G.Services.ReplicatedStorage:FindFirstChild("LocalEvents")
                local localGrab = localEvents and localEvents:FindFirstChild("Grab")
                local localEat = localEvents and localEvents:FindFirstChild("Eat")

                if char and events then
                    -- Match rEm's per-Heartbeat approach, but use this managed loop
                    -- so the feature can be turned off cleanly.
                    pcall(function()
                        -- Same event cadence as the standalone rEm-matched test:
                        -- attempt both Grab and Eat each loop iteration.
                        if localGrab then
                            localGrab:Fire()
                        elseif events.Grab then
                            events.Grab:FireServer(false, false, false)
                        end

                        if localEat then
                            localEat:Fire()
                        elseif events.Eat then
                            events.Eat:FireServer()
                        end
                    end)

                    -- Sell on full inventory with a small debounce; reuses the existing
                    -- full-inventory detector and sale routine.
                    if isInventoryFull() and (os.clock() - lastAutoSell) >= 0.8 then
                        lastAutoSell = os.clock()
                        pcall(executeSell)
                    end
                end
                task.wait()
            else
                task.wait(0.1)
            end
        end
    end)

    -- ==============================================================================
    -- AUTOFARM RECOVERY LOOP: no regular timed teleport.
    -- AutoFarm keeps using the shared Grab/Eat loop above. Teleport only after
    -- 2 seconds without observable size progress; CurrentChunk alone is not proof of eating.
    -- Wait 0.8s after moving.
    -- ==============================================================================
    task.spawn(function()
        local NO_PROGRESS_TIMEOUT = 2.0
        local POST_TELEPORT_LOAD_WAIT = 0.8
        local RESCAN_WAIT = 0.5
        local RECOVERY_COOLDOWN = 1.5
        local lastProgressAt = os.clock()
        local lastRecoveryAt = 0
        local lastObservedSize = 0
        local lastTarget = nil
        local recoveryBusy = false

        local function observedSize(char)
            local charSizeObj = char and char:FindFirstChild("Size")
            local charSize = charSizeObj and tonumber(charSizeObj.Value) or 0
            local stats = player:FindFirstChild("leaderstats")
            local statObj = stats and stats:FindFirstChild("Size")
            local statSize = statObj and tonumber(statObj.Value) or 0
            return math.max(charSize, statSize)
        end

        -- A nearby valid edible surface means the player still has something to eat.
        -- In that case, keep farming in place even if the size counter updates slowly.
        local function hasEdibleSurfaceNearby(char, root)
            local map = G.Services.Workspace:FindFirstChild("Map")
            if not map or not root then return false end

            local charSizeObj = char and char:FindFirstChild("Size")
            local rawSize = charSizeObj and tonumber(charSizeObj.Value) or 1
            local stats = player:FindFirstChild("leaderstats")
            local statObj = stats and stats:FindFirstChild("Size")
            local statSize = statObj and tonumber(statObj.Value) or rawSize
            local prioritizeGround = math.max(rawSize, statSize) < 400
            local nearbyRadius = 9

            for _, obj in ipairs(map:GetDescendants()) do
                if obj:IsA("BasePart")
                    and obj.Name ~= "Bedrock"
                    and obj.Name ~= "Barrier"
                    and obj.CanCollide
                    and obj.Transparency < 0.8
                    and obj.Size.Magnitude > 2.5
                    and obj.Position.Y > 0 then
                    local acceptable = (not prioritizeGround) or isGroundPart(obj)
                    if acceptable and (obj.Position - root.Position).Magnitude <= nearbyRadius then
                        return true
                    end
                end
            end
            return false
        end

        while S.Runtime.running do
            if states.randomTPFarm then
                local char = player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local chunk = char and char:FindFirstChild("CurrentChunk")
                if char and hum and hrp and hum.Health > 0 then
                    local sizeNow = observedSize(char)
                    local hasChunk = chunk and chunk.Value ~= nil
                    local edibleNearby = hasEdibleSurfaceNearby(char, hrp)

                    if sizeNow > lastObservedSize + 0.001 then
                        lastObservedSize = sizeNow
                        lastProgressAt = os.clock()
                    elseif edibleNearby or hasChunk then
                        -- Stay in place while a nearby candidate surface or active CurrentChunk exists.
                        -- CurrentChunk is only a guard signal, not proof of size progress.
                        lastProgressAt = os.clock()
                    elseif os.clock() - lastProgressAt >= NO_PROGRESS_TIMEOUT
                        and not recoveryBusy and os.clock() - lastRecoveryAt >= RECOVERY_COOLDOWN then
                        recoveryBusy = true
                        lastRecoveryAt = os.clock()
                        local target, isGround = getRandomEdiblePart()
                        if target and target.Parent and target:IsDescendantOf(G.Services.Workspace) and target ~= lastTarget then
                            lastTarget = target
                            local partPos = target.Position
                            local standPos, lookTarget
                            if isGround then
                                standPos = partPos + Vector3.new(math.random(-1,1), hum.HipHeight + 0.2, math.random(-1,1))
                                lookTarget = partPos - Vector3.new(0, 2, 0)
                            else
                                standPos = partPos + Vector3.new(0, hum.HipHeight + 0.5, 2.5)
                                lookTarget = Vector3.new(partPos.X, standPos.Y, partPos.Z)
                            end
                            hrp.CFrame = CFrame.new(standPos, lookTarget)
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            hrp.AssemblyAngularVelocity = Vector3.zero
                            lastProgressAt = os.clock()
                            task.wait(POST_TELEPORT_LOAD_WAIT)
                            local currentChar = player.Character
                            lastObservedSize = observedSize(currentChar)
                        else
                            -- No new candidate: stay put and rescan, don't teleport to spawn/center.
                            task.wait(RESCAN_WAIT)
                        end
                        lastProgressAt = os.clock()
                        recoveryBusy = false
                    end
                end
            else
                -- Reset watchdog while AutoFarm is off; Auto EAT mode never teleports.
                lastProgressAt = os.clock()
                lastObservedSize = observedSize(player.Character)
                recoveryBusy = false
            end
            task.wait(0.05)
        end
    end)

    -- 2. ПОТОК: FLASH VACUUM (СВЕРХБЫСТРЫЙ МАГНИТ)
    task.spawn(function()
        while S.Runtime.running do
            if states.flashVacuum then
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                    local hrp = char.HumanoidRootPart
                    local hum = char.Humanoid

                    if hum.Health > 0 then
                        local dropsList = getPrioritizedDrops()
                        if #dropsList > 0 then
                            local startCF = hrp.CFrame

                            for _, itemData in ipairs(dropsList) do
                                if not states.flashVacuum then break end
                                local itemPart = itemData.Part

                                if itemPart and itemPart.Parent and canCollect(itemPart) then
                                    hrp.CFrame = itemPart.CFrame * CFrame.new(0, 0.4, 0)
                                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0.1, 0)

                                    if typeof(firetouchinterest) == "function" then
                                        firetouchinterest(hrp, itemPart, 0)
                                        firetouchinterest(hrp, itemPart, 1)
                                    end

                                    G.Services.RunService.Heartbeat:Wait()
                                end
                            end

                            hrp.CFrame = startCF
                            hrp.AssemblyLinearVelocity = Vector3.zero
                        end
                    end
                end
            end
            task.wait(0.2)
        end
    end)

    -- 3. AUTO ABSORB COIN CANDY: scan all Workspace descendants.
    -- Uses simulated touch only; the character is never teleported or repositioned.
    local function isCoinCandyObject(obj)
        if not obj or not obj:IsA("BasePart") then return false end

        local current = obj
        while current and current ~= G.Services.Workspace do
            local normalizedName = string.lower(current.Name):gsub("[%s_%-]", "")
            if normalizedName == "coincandy" then
                return true
            end
            current = current.Parent
        end
        return false
    end

    task.spawn(function()
        while S.Runtime.running do
            if states.instantMagnet then
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 and typeof(firetouchinterest) == "function" then
                    for _, obj in ipairs(G.Services.Workspace:GetDescendants()) do
                        if not states.instantMagnet then break end
                        if isCoinCandyObject(obj) and obj.Parent then
                            pcall(function()
                                firetouchinterest(hrp, obj, 0)
                                firetouchinterest(hrp, obj, 1)
                            end)
                        end
                    end
                end
            end
            task.wait(0.12)
        end
    end)

    -- 4. ПОТОК: АВТО-СБОР НАГРАД
    task.spawn(function()
        while S.Runtime.running do
            if states.autoRewards then
                claimTimedRewards()
            end
            task.wait(3.0)
        end
    end)

    -- 5. ANTI-VOID + BIG PLATFORM + ANTI-ANCHOR (independent toggles)
    local antiVoidConnection = nil
    local antiAnchorConnection = nil
    local etwBigPlatform = nil

    local function ensureBigPlatform()
        if etwBigPlatform and etwBigPlatform.Parent then return end
        local part = Instance.new("Part")
        part.Name = "ETW_DRAMA_BigPlatform"
        part.Size = Vector3.new(90000, 10, 90000)
        part.Anchored = true
        part.CanCollide = true
        part.Transparency = 1
        part.Material = Enum.Material.Fabric
        part.Position = Vector3.new(0, -6, 0)
        part.Parent = G.Services.Workspace
        etwBigPlatform = part
    end

    local function removeBigPlatform()
        if etwBigPlatform then
            pcall(function() etwBigPlatform:Destroy() end)
            etwBigPlatform = nil
        end
    end

    task.spawn(function()
        while S.Runtime.running do
            if states.antiVoid and not antiVoidConnection then
                antiVoidConnection = G.Services.RunService.Heartbeat:Connect(function()
                    if not S.Runtime.running or not states.antiVoid then return end
                    local char = player.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root and root.Position.Y < -50 then
                        root.AssemblyLinearVelocity = Vector3.zero
                        root.AssemblyAngularVelocity = Vector3.zero
                        root.CFrame = CFrame.new(0, 50, 0)
                    end
                end)
            elseif not states.antiVoid and antiVoidConnection then
                antiVoidConnection:Disconnect()
                antiVoidConnection = nil
            end

            if states.antiAnchor and not antiAnchorConnection then
                antiAnchorConnection = G.Services.RunService.RenderStepped:Connect(function()
                    if not S.Runtime.running or not states.antiAnchor then return end
                    local char = player.Character
                    if not char then return end
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.Anchored then
                            part.Anchored = false
                        end
                    end
                end)
            elseif not states.antiAnchor and antiAnchorConnection then
                antiAnchorConnection:Disconnect()
                antiAnchorConnection = nil
            end

            if states.bigPlatform then
                ensureBigPlatform()
            else
                removeBigPlatform()
            end
            task.wait(0.1)
        end
        if antiVoidConnection then antiVoidConnection:Disconnect(); antiVoidConnection = nil end
        if antiAnchorConnection then antiAnchorConnection:Disconnect(); antiAnchorConnection = nil end
        removeBigPlatform()
    end)

    

-- 6. ПОТОК: RUN SPEED (Speed Value без фиксированного максимума)
local speedConnection = nil
task.spawn(function()
    while S.Runtime.running do
        if states.speedEnabled and not speedConnection then
            speedConnection = G.Services.RunService.Heartbeat:Connect(function(delta)
                if not S.Runtime.running or not states.speedEnabled then return end
                local char = player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 then
                    hrp.Anchored = false
                    local moveDirection = hum.MoveDirection
                    if moveDirection.Magnitude > 0 then
                        local nextPosition = hrp.Position + moveDirection * states.speedValue * delta
                        hrp.CFrame = CFrame.new(nextPosition, nextPosition + hrp.CFrame.LookVector)
                    end
                end
            end)
        elseif not states.speedEnabled and speedConnection then
            speedConnection:Disconnect()
            speedConnection = nil
        end
        task.wait(0.1)
    end
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
end)



    -- 8. PLAYER STATS ESP (adapted from rEm.lua; compact labels)
    local ESPFolder = Instance.new("Folder")
    ESPFolder.Name = "PlayerStatsESPFolder"
    ESPFolder.Parent = S.ScreenGui

    local espObjects = {}

    local function findPlayerStat(targetPlayer, statName)
        local variants = {statName, string.gsub(statName, " ", ""), string.gsub(statName, " ", "_")}
        local function checkObject(obj)
            for _, variant in ipairs(variants) do
                if string.lower(obj.Name) == string.lower(variant)
                    and (obj:IsA("IntValue") or obj:IsA("NumberValue")) then
                    return obj.Value
                end
            end
            return nil
        end
        for _, obj in ipairs(targetPlayer:GetDescendants()) do
            local value = checkObject(obj)
            if value ~= nil then return value end
        end
        for _, variant in ipairs(variants) do
            local value = targetPlayer:GetAttribute(variant)
            if value ~= nil then return value end
            if targetPlayer.Character then
                value = targetPlayer.Character:GetAttribute(variant)
                if value ~= nil then return value end
            end
        end
        local pGui = targetPlayer:FindFirstChild("PlayerGui")
        if pGui then
            for _, obj in ipairs(pGui:GetDescendants()) do
                local value = checkObject(obj)
                if value ~= nil then return value end
            end
        end
        for _, obj in ipairs(G.Services.ReplicatedStorage:GetDescendants()) do
            if string.find(string.lower(obj.Name), string.lower(targetPlayer.Name), 1, true) then
                for _, child in ipairs(obj:GetDescendants()) do
                    local value = checkObject(child)
                    if value ~= nil then return value end
                end
            end
        end
        return "?"
    end

    local function findStatAny(targetPlayer, names)
        for _, name in ipairs(names) do
            local value = findPlayerStat(targetPlayer, name)
            if value ~= "?" then return value end
        end
        return "?"
    end

    local function createPlayerStatsESP(targetPlayer)
        if targetPlayer == player or espObjects[targetPlayer] then return end
        local highlight = Instance.new("Highlight")
        highlight.Name = "rEmPlayerStatsHighlight"
        highlight.FillColor = G.Math.rgb(0, 225, 245)
        highlight.OutlineColor = G.Math.rgb(255, 255, 255)
        highlight.FillTransparency = 0.65
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "rEmPlayerStatsText"
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 190, 0, 76)
        billboard.StudsOffset = Vector3.new(0, 3.2, 0)

        local label = Instance.new("TextLabel")
        label.Name = "Stats"
        label.Parent = billboard
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.TextColor3 = G.Math.rgb(255, 255, 255)
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = G.Math.rgb(0, 0, 0)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 10
        label.TextWrapped = true
        label.TextYAlignment = Enum.TextYAlignment.Bottom

        local playerIndex = 0
        for _, otherPlayer in ipairs(G.Services.Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.UserId <= targetPlayer.UserId then
                playerIndex += 1
            end
        end
        billboard.StudsOffset = Vector3.new(0, 3.2 + ((playerIndex % 4) * 0.8), 0)

        espObjects[targetPlayer] = {highlight = highlight, billboard = billboard, label = label}
    end

    local function removePlayerStatsESP(targetPlayer)
        local entry = espObjects[targetPlayer]
        if not entry then return end
        entry.highlight:Destroy()
        entry.billboard:Destroy()
        espObjects[targetPlayer] = nil
    end

    for _, targetPlayer in ipairs(G.Services.Players:GetPlayers()) do
        createPlayerStatsESP(targetPlayer)
    end
    G.Services.Players.PlayerAdded:Connect(createPlayerStatsESP)
    G.Services.Players.PlayerRemoving:Connect(removePlayerStatsESP)

    task.spawn(function()
        while S.Runtime.running do
            for targetPlayer, entry in pairs(espObjects) do
                if targetPlayer.Parent ~= G.Services.Players then
                    removePlayerStatsESP(targetPlayer)
                elseif states.playerESP then
                    local character = targetPlayer.Character
                    local root = character and character:FindFirstChild("HumanoidRootPart")
                    if character and root then
                        entry.highlight.Parent = character
                        entry.billboard.Parent = root
                        local sizeVal = findStatAny(targetPlayer, {"Size"})
                        local maxVal = findStatAny(targetPlayer, {"MaxSize", "Max Size", "Max", "Capacity"})
                        local multiVal = findStatAny(targetPlayer, {"Size Multiplier", "Multiplier", "Multi"})
                        local eatVal = findStatAny(targetPlayer, {"eat speed", "eat level"})
                        local hum = character:FindFirstChildOfClass("Humanoid")
                        local walkSpeed = hum and math.floor(hum.WalkSpeed) or 16
                        entry.label.Text = string.format("[%s]\nSize: %s / %s\nMulti: %s | Eat: %s\nWalkSpeed: %s", targetPlayer.Name, tostring(sizeVal), tostring(maxVal), tostring(multiVal), tostring(eatVal), tostring(walkSpeed))
                    else
                        entry.highlight.Parent = nil
                        entry.billboard.Parent = nil
                    end
                else
                    entry.highlight.Parent = nil
                    entry.billboard.Parent = nil
                end
            end
            task.wait(1)
        end
        for targetPlayer in pairs(espObjects) do removePlayerStatsESP(targetPlayer) end
    end)

    -- ==============================================================================
    -- 8. ПОЛЕТ (FLY) — ИСПРАВЛЕННОЕ 3D-УПРАВЛЕНИЕ (MOBILE TOUCH + PC WASD/SPACE)
    -- ==============================================================================
    local flyBV = nil
    local flyBG = nil

    task.spawn(function()
        local uis = G.Services.UserInputService

        while S.Runtime.running do
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")

            if states.fly and hrp and hum and hum.Health > 0 then
                -- Отключаем физику ходьбы, чтобы персонаж не спотыкался
                hum.PlatformStand = true

                -- Создаем контроллеры физики, если их еще нет
                if not flyBV or flyBV.Parent ~= hrp then
                    flyBV = Instance.new("BodyVelocity")
                    flyBV.Name = "AdminFlyBV_Fixed"
                    flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    flyBV.Velocity = Vector3.zero
                    flyBV.Parent = hrp

                    flyBG = Instance.new("BodyGyro")
                    flyBG.Name = "AdminFlyBG_Fixed"
                    flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                    flyBG.P = 50000
                    flyBG.D = 500
                    flyBG.CFrame = hrp.CFrame
                    flyBG.Parent = hrp
                end

                local cam = G.Services.Workspace.CurrentCamera or Camera
                local camCF = cam.CFrame
                local worldMove = hum.MoveDirection

                local targetVelocity = Vector3.zero

                -- Joystick / WASD: Humanoid.MoveDirection уже berupa arah gerak dunia.
                -- Pakai arah ini langsung agar Fly mengikuti joystick dengan natural,
                -- tanpa mengubah arah berdasarkan kemiringan kamera.
                if worldMove.Magnitude > 0.05 then
                    targetVelocity = worldMove.Unit * states.flySpeed
                end

                -- 2. Вертикальное перемещение (Вверх / Вниз)
                if not isTouchDevice then
                    -- Управление для ПК
                    if uis:IsKeyDown(Enum.KeyCode.Space) then
                        targetVelocity = targetVelocity + Vector3.new(0, states.flySpeed, 0)
                    end
                    if uis:IsKeyDown(Enum.KeyCode.LeftShift) or uis:IsKeyDown(Enum.KeyCode.LeftControl) then
                        targetVelocity = targetVelocity - Vector3.new(0, states.flySpeed, 0)
                    end
                else
                    -- Управление для телефонов (Кнопка прыжка поднимает вверх)
                    if hum.Jump then
                        targetVelocity = targetVelocity + Vector3.new(0, states.flySpeed * 0.8, 0)
                    end
                end

                flyBV.Velocity = targetVelocity
                flyBG.CFrame = camCF
            else
                -- При выключении очищаем физику и возвращаем персонажа на ноги
                if flyBV then flyBV:Destroy(); flyBV = nil end
                if flyBG then flyBG:Destroy(); flyBG = nil end
                if hum and hum.PlatformStand then
                    hum.PlatformStand = false
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end
            task.wait()
        end

        if flyBV then flyBV:Destroy() end
        if flyBG then flyBG:Destroy() end
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.PlatformStand = false
        end
    end)

    -- 10. NOCLIP (ПРОХОД СКВОЗЬ СТЕНЫ)
    S.Runtime.connections[#S.Runtime.connections + 1] = G.Services.RunService.Stepped:Connect(function()
        if states.noclip and player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)

    -- 11. INFINITE JUMP
    S.Runtime.connections[#S.Runtime.connections + 1] = G.Services.UserInputService.JumpRequest:Connect(function()
        if states.infJump and player.Character then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)

    -- 12. FPS И ПИНГ МОНИТОР
    local frameCount = 0
    local frameTime = 0
    local currentFPS = 60

    S.Runtime.connections[#S.Runtime.connections + 1] = G.Services.RunService.RenderStepped:Connect(function(dt)
        if not S.Runtime.running then return end
        frameCount = frameCount + 1
        frameTime = frameTime + dt
        if frameTime >= 1.0 then
            currentFPS = G.Math.clamp(G.Math.floor(frameCount / frameTime), 1, 999)
            frameCount = 0
            frameTime = 0
        end
    end)

    task.spawn(function()
        while S.Runtime.running do
            task.wait(1.0)
            local ping = 0
            pcall(function()
                local net = G.Services.Stats and G.Services.Stats:FindFirstChild("Network")
                local ssi = net and net:FindFirstChild("ServerStatsItem")
                local dp = ssi and ssi:FindFirstChild("Data Ping")
                if dp and dp.GetValue then ping = G.Math.floor(dp:GetValue()) end
            end)
            if ping <= 0 then
                pcall(function()
                    if player and player.GetNetworkPing then
                        ping = G.Math.floor(player:GetNetworkPing() * 1000)
                    end
                end)
            end
            if S.wmFrame and S.wmFrame:FindFirstChild("StatsTxt") then
                S.wmFrame.StatsTxt.Text = string.format("HUB | FPS: %d | Ping: %dms", currentFPS, math.max(1, ping))
            end
        end
    end)

    getgenv()._HUB_CLEAN_ACTIVE = {
        unload = function()
            pcall(function()
                S.Runtime.running = false
                states.antiVoid = false
                states.antiAnchor = false
                states.bigPlatform = false
                local oldPlatform = G.Services.Workspace:FindFirstChild("ETW_DRAMA_BigPlatform")
                if oldPlatform then pcall(function() oldPlatform:Destroy() end) end
                S.ScreenGui:Destroy()
                if NotificationGui then NotificationGui:Destroy() end
                for _, conn in ipairs(S.Runtime.connections) do if conn.Connected then conn:Disconnect() end end
                table.clear(S.Runtime.connections)
            end)
        end
    }

    showNotification(string.format(getText("tipToggle"), states.menuKey), "Info")
end

BuildHubUI()
