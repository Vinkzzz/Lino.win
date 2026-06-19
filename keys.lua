local TweenService = game:GetService("TweenService")

local M = {}

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--    THE KEY â€” change this string to force a global re-auth.
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local MASTER_KEY = "gthm-night"

-- Cache file is per-user and per-game so different accounts and different
-- games each get their own independent 24h session.
local _localPlayer  = game:GetService("Players").LocalPlayer
local _safeName     = (_localPlayer and _localPlayer.Name or "unknown"):gsub("[^%w]", "")
local CACHE_FILE    = ("GothamHub_%s_%d.json"):format(_safeName, game.PlaceId)
local CACHE_DURATION = 24 * 60 * 60

-- â”€â”€ Cache helpers (silently no-op if executor lacks file APIs) â”€â”€
local function readCache()
    if not (readfile and isfile) then return nil end
    if not isfile(CACHE_FILE) then return nil end
    local ok, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile(CACHE_FILE))
    end)
    if not ok or type(data) ~= "table" then return nil end
    return data
end

local function writeCache(key)
    if not writefile then return end
    pcall(function()
        local hs = game:GetService("HttpService")
        writefile(CACHE_FILE, hs:JSONEncode({
            key = key,
            timestamp = os.time(),
        }))
    end)
end

local function clearCache()
    if delfile and isfile and isfile(CACHE_FILE) then
        pcall(delfile, CACHE_FILE)
    end
end

-- â”€â”€ Public API â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
function M.isCacheValid()
    local data = readCache()
    if not data or not data.key or not data.timestamp then return false end
    if data.key ~= MASTER_KEY then return false end
    if (os.time() - data.timestamp) > CACHE_DURATION then return false end
    return true
end

function M.isValidKey(input)
    if type(input) ~= "string" then return false end
    return input:lower():gsub("%s+", "") == MASTER_KEY:lower()
end

function M.timeRemaining()
    -- seconds until cache expires; useful for displaying countdown
    local data = readCache()
    if not data or not data.timestamp then return 0 end
    local elapsed = os.time() - data.timestamp
    return math.max(0, CACHE_DURATION - elapsed)
end

function M.invalidate()
    clearCache()
end

-- â”€â”€ Key GUI â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
-- show(constants, options, onSuccess)
--   constants : table from shared/constants.lua
--   options   : { gameName = string } â€” shown as subtitle
--   onSuccess : function called when user is authorized (cached OR enters key)
function M.show(C, options, onSuccess)
    options = options or {}
    local gameName = options.gameName or "Plunderer Hub"

    -- Fast path: cache hit, skip the GUI entirely
    if M.isCacheValid() then
        task.defer(onSuccess)
        return
    end

    local localPlayer = game:GetService("Players").LocalPlayer
    local playerGui = localPlayer:WaitForChild("PlayerGui")

    -- Destroy any previous key GUI (re-run safe)
    local existing = playerGui:FindFirstChild("GothamKeySystem")
    if existing then existing:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "GothamKeySystem"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 420, 0, 610)
    frame.Position = UDim2.new(0.5, -210, 0.5, -305)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.BackgroundTransparency = 1
    frame.Parent = gui
    Instance.new("UICorner").Parent = frame
    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = C.VINO_TINTO_EXTREMO
    frameStroke.Thickness = 1.5
    frameStroke.Parent = frame
    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {BackgroundTransparency = 0}):Play()

    -- Logo
    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.new(0, 100, 0, 100)
    logo.Position = UDim2.new(0.5, -50, 0, 35)
    logo.BackgroundTransparency = 1
    logo.Image = C.LOGO_ID
    logo.ImageTransparency = 1
    logo.ZIndex = 2
    logo.Parent = frame
    Instance.new("UICorner").Parent = logo
    TweenService:Create(logo, TweenInfo.new(0.6), {ImageTransparency = 0}):Play()

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 148)
    title.BackgroundTransparency = 1
    title.TextColor3 = C.TEXT_MAIN
    title.Text = "GOTHAM HUB"
    title.Font = C.FONT_KEY_TITLE
    title.TextSize = 26
    title.TextTransparency = 1
    title.ZIndex = 2
    title.Parent = frame
    TweenService:Create(title, TweenInfo.new(0.6), {TextTransparency = 0}):Play()

    -- Subtitle (game name)
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -20, 0, 22)
    subtitle.Position = UDim2.new(0, 10, 0, 190)
    subtitle.BackgroundTransparency = 1
    subtitle.TextColor3 = Color3.fromRGB(100, 100, 100)
    subtitle.Text = gameName
    subtitle.Font = C.FONT_KEY_TITLE
    subtitle.TextSize = 13
    subtitle.TextTransparency = 1
    subtitle.ZIndex = 2
    subtitle.Parent = frame
    TweenService:Create(subtitle, TweenInfo.new(0.7), {TextTransparency = 0}):Play()

    -- Divider
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(0, 0, 0, 1)
    divider.Position = UDim2.new(0.5, 0, 0, 225)
    divider.BackgroundColor3 = C.VINO_TINTO_EXTREMO
    divider.BorderSizePixel = 0
    divider.ZIndex = 2
    divider.Parent = frame
    TweenService:Create(divider, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, 0.3),
        {Size = UDim2.new(0, 320, 0, 1), Position = UDim2.new(0.5, -160, 0, 225)}):Play()

    -- Key prompt
    local keyLabel = Instance.new("TextLabel")
    keyLabel.Size = UDim2.new(1, -40, 0, 20)
    keyLabel.Position = UDim2.new(0, 20, 0, 248)
    keyLabel.BackgroundTransparency = 1
    keyLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
    keyLabel.Text = "Enter your access key"
    keyLabel.Font = C.FONT_KEY_TITLE
    keyLabel.TextSize = 12
    keyLabel.TextTransparency = 1
    keyLabel.ZIndex = 2
    keyLabel.Parent = frame
    TweenService:Create(keyLabel, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, 0.4),
        {TextTransparency = 0}):Play()

    -- Input box
    local inputBox = Instance.new("Frame")
    inputBox.Size = UDim2.new(0, 320, 0, 42)
    inputBox.Position = UDim2.new(0.5, -160, 0, 275)
    inputBox.BackgroundColor3 = C.BG_INPUT
    inputBox.BorderSizePixel = 0
    inputBox.BackgroundTransparency = 1
    inputBox.ZIndex = 2
    inputBox.Parent = frame
    Instance.new("UICorner").Parent = inputBox
    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = Color3.fromRGB(40, 40, 40)
    inputStroke.Parent = inputBox
    TweenService:Create(inputBox, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, 0.4),
        {BackgroundTransparency = 0}):Play()

    local textInput = Instance.new("TextBox")
    textInput.Size = UDim2.new(1, -20, 1, 0)
    textInput.Position = UDim2.new(0, 10, 0, 0)
    textInput.BackgroundTransparency = 1
    textInput.TextColor3 = Color3.fromRGB(220, 220, 220)
    textInput.PlaceholderText = "gtham-xxxxxx"
    textInput.PlaceholderColor3 = Color3.fromRGB(60, 60, 60)
    textInput.Text = ""
    textInput.Font = C.FONT_MONO
    textInput.TextSize = 14
    textInput.ClearTextOnFocus = false
    textInput.ZIndex = 3
    textInput.Parent = inputBox

    textInput.Focused:Connect(function()
        TweenService:Create(inputStroke, TweenInfo.new(0.2), {Color = C.VINO_TINTO_EXTREMO}):Play()
    end)
    textInput.FocusLost:Connect(function()
        TweenService:Create(inputStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(40, 40, 40)}):Play()
    end)

    -- Status (error feedback)
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -40, 0, 20)
    statusLabel.Position = UDim2.new(0, 20, 0, 325)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = C.TEXT_RED
    statusLabel.Text = ""
    statusLabel.Font = C.FONT_KEY_TITLE
    statusLabel.TextSize = 12
    statusLabel.ZIndex = 2
    statusLabel.Parent = frame

    -- Confirm button
    local confirmBtn = Instance.new("TextButton")
    confirmBtn.Size = UDim2.new(0, 320, 0, 42)
    confirmBtn.Position = UDim2.new(0.5, -160, 0, 355)
    confirmBtn.BackgroundColor3 = C.VINO_TINTO_EXTREMO
    confirmBtn.BorderSizePixel = 0
    confirmBtn.Text = "Confirm"
    confirmBtn.TextColor3 = Color3.fromRGB(15, 15, 15)
    confirmBtn.Font = C.FONT_KEY_TITLE
    confirmBtn.TextSize = 15
    confirmBtn.BackgroundTransparency = 1
    confirmBtn.ZIndex = 2
    confirmBtn.Parent = frame
    Instance.new("UICorner").Parent = confirmBtn
    Instance.new("UIStroke", confirmBtn).Color = C.VINO_TINTO_EXTREMO
    TweenService:Create(confirmBtn, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, 0.5),
        {BackgroundTransparency = 0}):Play()
    confirmBtn.MouseEnter:Connect(function()
        TweenService:Create(confirmBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.VINO_HOVER}):Play()
    end)
    confirmBtn.MouseLeave:Connect(function()
        TweenService:Create(confirmBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.VINO_TINTO_EXTREMO}):Play()
    end)

    -- Discord section
    local discordLabel = Instance.new("TextLabel")
    discordLabel.Size = UDim2.new(1, -40, 0, 18)
    discordLabel.Position = UDim2.new(0, 20, 0, 415)
    discordLabel.BackgroundTransparency = 1
    discordLabel.TextColor3 = Color3.fromRGB(80, 80, 80)
    discordLabel.Text = "Can't find your key?"
    discordLabel.Font = C.FONT_KEY_TITLE
    discordLabel.TextSize = 11
    discordLabel.TextTransparency = 1
    discordLabel.ZIndex = 2
    discordLabel.Parent = frame
    TweenService:Create(discordLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, 0.6),
        {TextTransparency = 0}):Play()

    local discordBtn = Instance.new("TextButton")
    discordBtn.Size = UDim2.new(0, 180, 0, 34)
    discordBtn.Position = UDim2.new(0.5, -90, 0, 438)
    discordBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    discordBtn.BorderSizePixel = 0
    discordBtn.Text = "ðŸ”—  Join Discord"
    discordBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    discordBtn.Font = C.FONT_KEY_TITLE
    discordBtn.TextSize = 13
    discordBtn.BackgroundTransparency = 1
    discordBtn.ZIndex = 2
    discordBtn.Parent = frame
    Instance.new("UICorner").Parent = discordBtn
    Instance.new("UIStroke", discordBtn).Color = C.VINO_TINTO_EXTREMO
    TweenService:Create(discordBtn, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, 0.6),
        {BackgroundTransparency = 0}):Play()
    discordBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(C.DISCORD_LINK)
            discordBtn.Text = "ðŸ”—  Link Copied!"
            task.delay(2, function() discordBtn.Text = "ðŸ”—  Join Discord" end)
        end
    end)

    -- Supported games dropdown
    local dropArrow = Instance.new("TextButton")
    dropArrow.Size = UDim2.new(0, 180, 0, 22)
    dropArrow.Position = UDim2.new(0.5, -90, 0, 478)
    dropArrow.BackgroundTransparency = 1
    dropArrow.Text = "â–¼  Supported Games"
    dropArrow.TextColor3 = Color3.fromRGB(90, 90, 90)
    dropArrow.Font = C.FONT_KEY_TITLE
    dropArrow.TextSize = 11
    dropArrow.ZIndex = 2
    dropArrow.Parent = frame

    local dropList = Instance.new("Frame")
    dropList.Size = UDim2.new(0, 320, 0, 0)
    dropList.Position = UDim2.new(0.5, -160, 0, 502)
    dropList.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    dropList.BorderSizePixel = 0
    dropList.ClipsDescendants = true
    dropList.ZIndex = 2
    dropList.Parent = frame
    Instance.new("UICorner").Parent = dropList
    Instance.new("UIStroke", dropList).Color = C.VINO_TINTO_EXTREMO
    Instance.new("UIListLayout").Parent = dropList

    for _, name in ipairs(C.SUPPORTED_GAMES) do
        local item = Instance.new("TextLabel")
        item.Size = UDim2.new(1, 0, 0, 28)
        item.BackgroundTransparency = 1
        item.TextColor3 = Color3.fromRGB(180, 180, 180)
        item.Text = "  â€¢ " .. name
        item.Font = C.FONT_LABEL
        item.TextSize = 13
        item.TextXAlignment = Enum.TextXAlignment.Left
        item.ZIndex = 3
        item.Parent = dropList
    end

    local dropOpen = false
    dropArrow.MouseButton1Click:Connect(function()
        dropOpen = not dropOpen
        if dropOpen then
            dropArrow.Text = "â–²  Supported Games"
            TweenService:Create(dropList, TweenInfo.new(0.25, Enum.EasingStyle.Quart),
                {Size = UDim2.new(0, 320, 0, #C.SUPPORTED_GAMES * 28 + 8)}):Play()
        else
            dropArrow.Text = "â–¼  Supported Games"
            TweenService:Create(dropList, TweenInfo.new(0.2, Enum.EasingStyle.Quart),
                {Size = UDim2.new(0, 320, 0, 0)}):Play()
        end
    end)

    -- Shake animation on incorrect key
    local function shake()
        local origin = frame.Position
        for i = 1, 6 do
            local offset = (i % 2 == 0) and 6 or -6
            TweenService:Create(frame, TweenInfo.new(0.04),
                {Position = UDim2.new(origin.X.Scale, origin.X.Offset + offset, origin.Y.Scale, origin.Y.Offset)}):Play()
            task.wait(0.04)
        end
        TweenService:Create(frame, TweenInfo.new(0.04), {Position = origin}):Play()
    end

    -- Confirm
    confirmBtn.MouseButton1Click:Connect(function()
        local input = textInput.Text
        if M.isValidKey(input) then
            statusLabel.Text = ""
            confirmBtn.Text = "Access Granted!"
            confirmBtn.TextColor3 = C.TEXT_GREEN
            writeCache(MASTER_KEY)
            task.delay(0.4, function()
                gui:Destroy()
                task.defer(onSuccess)
            end)
        else
            statusLabel.Text = "Incorrect key"
            statusLabel.TextColor3 = C.TEXT_RED
            task.spawn(shake)
        end
    end)
end

return M
