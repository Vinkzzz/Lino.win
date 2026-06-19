--[[
â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—
â•‘   GOTHAM HUB â€” shared/ui.lua                              â•‘
â•‘                                                              â•‘
â•‘   Reusable UI widget library. Returns a factory that, given  â•‘
â•‘   a script's State / Keybinds / Connections tables, exposes  â•‘
â•‘   widget builders bound to that script's state.              â•‘
â•‘                                                              â•‘
â•‘   Usage:                                                     â•‘
â•‘     local UILib = loadstring(httpget(...))()                 â•‘
â•‘     local UI = UILib.new({                                   â•‘
â•‘         constants    = C,                                    â•‘
â•‘         States       = States,                               â•‘
â•‘         Keybinds     = Keybinds,                             â•‘
â•‘         Connections  = Connections,                          â•‘
â•‘         getListening = function() return ListeningToBind end,â•‘
â•‘         setListening = function(v) ListeningToBind = v end,  â•‘
â•‘     })                                                       â•‘
â•‘     UI.createFeatureRow(scroll, "Auto Farm", 110, "autofarm")â•‘
â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
]]

local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local UILib = {}

function UILib.new(cfg)
    -- Required config:
    --   constants    : table from shared/constants.lua
    --   States       : table of boolean feature flags (mutated by toggles)
    --   Keybinds     : table of KeyCode bindings per feature
    --   Connections  : table to push RBXScriptConnections into for cleanup
    --   getListening : function returning currently-listening feature name (or nil)
    --   setListening : function(featOrNil) â€” sets/clears the listening target
    local C            = cfg.constants
    local States       = cfg.States
    local Keybinds     = cfg.Keybinds
    local Connections  = cfg.Connections
    local getListening = cfg.getListening
    local setListening = cfg.setListening

    local UI = {}

    -- â”€â”€ Section heading (small title + separator) â”€â”€
    function UI.createSectionTitle(parent, text, yPos)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -20, 0, 28)
        lbl.Position = UDim2.new(0, 15, 0, yPos)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = C.TEXT_MAIN
        lbl.Text = text
        lbl.Font = C.FONT_HUB_TITLE
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = parent
        return lbl
    end

    -- â”€â”€ Sidebar nav item (optional icon + label) â”€â”€
    -- iconAssetId: "rbxassetid://..." for image, or a short text/symbol like "â– "
    function UI.createNavItem(parent, iconAssetId, labelText, yPos)
        local nav = Instance.new("Frame")
        nav.Size = UDim2.new(1, -20, 0, 40)
        nav.Position = UDim2.new(0, 10, 0, yPos)
        nav.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        nav.Parent = parent
        Instance.new("UICorner").Parent = nav
        Instance.new("UIStroke", nav).Color = C.VINO_TINTO_EXTREMO

        local labelMargin = 16
        local icon = nil
        if iconAssetId and iconAssetId ~= "" then
            if iconAssetId:sub(1, 3) == "rbx" then
                -- Image icon
                icon = Instance.new("ImageLabel")
                icon.Size = UDim2.new(0, 18, 0, 18)
                icon.Position = UDim2.new(0, 12, 0.5, -9)
                icon.BackgroundTransparency = 1
                icon.Image = iconAssetId
                icon.ImageColor3 = C.ICON_COLOR
                icon.ScaleType = Enum.ScaleType.Fit
                icon.Parent = nav
            else
                -- Text / Unicode symbol icon â€” always renders, tints with TextColor3
                icon = Instance.new("TextLabel")
                icon.Size = UDim2.new(0, 18, 0, 18)
                icon.Position = UDim2.new(0, 12, 0.5, -9)
                icon.BackgroundTransparency = 1
                icon.Text = iconAssetId
                icon.TextColor3 = C.ICON_COLOR
                icon.Font = Enum.Font.GothamBold
                icon.TextSize = 14
                icon.TextXAlignment = Enum.TextXAlignment.Center
                icon.TextYAlignment = Enum.TextYAlignment.Center
                icon.Parent = nav
            end
            labelMargin = 38
        end

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -labelMargin - 4, 1, 0)
        lbl.Position = UDim2.new(0, labelMargin, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = C.TEXT_DIM
        lbl.Text = labelText
        lbl.Font = C.FONT_LABEL_BOLD
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = nav

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = nav

        return btn, lbl, icon
    end

    -- â”€â”€ Feature row (label + keybind button + animated toggle switch) â”€â”€
    -- Reads/writes States[feat]; binds Keybinds[feat] through the listening setter.
    function UI.createFeatureRow(parent, name, yPos, feat)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -30, 0, 32)
        row.Position = UDim2.new(0, 15, 0, yPos)
        row.BackgroundTransparency = 1
        row.Parent = parent

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.55, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = C.TEXT_DIM
        lbl.Text = name
        lbl.Font = C.FONT_LABEL
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local bindBtn = Instance.new("TextButton")
        bindBtn.Size = UDim2.new(0, 52, 0, 20)
        bindBtn.Position = UDim2.new(1, -95, 0.5, -10)
        bindBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        bindBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
        bindBtn.Font = C.FONT_MONO
        bindBtn.TextSize = 11
        bindBtn.BorderSizePixel = 0
        bindBtn.Parent = row
        Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 4)
        Instance.new("UIStroke", bindBtn).Color = Color3.fromRGB(55,55,55)

        local track = Instance.new("Frame")
        track.Size = UDim2.new(0, 36, 0, 18)
        track.Position = UDim2.new(1, -36, 0.5, -9)
        track.BorderSizePixel = 0
        track.Parent = row
        Instance.new("UICorner").Parent = track

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 12, 0, 12)
        knob.BackgroundColor3 = C.TEXT_MAIN
        knob.Parent = track
        Instance.new("UICorner").Parent = knob

        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(1, 0, 1, 0)
        toggleBtn.BackgroundTransparency = 1
        toggleBtn.Text = ""
        toggleBtn.Parent = track

        local rc = RunService.RenderStepped:Connect(function()
            if getListening() == feat then
                bindBtn.Text = "[?]"
            else
                local k = Keybinds[feat]
                bindBtn.Text = "[" .. (k and k.Name or "None") .. "]"
            end
            if feat ~= "uitoggle" then
                if States[feat] then
                    track.BackgroundColor3 = C.VINO_TINTO_EXTREMO  -- white
                    knob.BackgroundColor3 = C.ACCENT_TEXT or Color3.fromRGB(15,15,15) -- dark knob on white
                    knob.Position = UDim2.new(1, -15, 0.5, -6)
                else
                    track.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                    knob.BackgroundColor3 = C.TEXT_MAIN               -- white knob on dark
                    knob.Position = UDim2.new(0, 3, 0.5, -6)
                end
            else
                track.Visible = false
            end
        end)
        table.insert(Connections, rc)

        toggleBtn.MouseButton1Click:Connect(function()
            States[feat] = not States[feat]
        end)
        bindBtn.MouseButton1Click:Connect(function()
            setListening(feat)
        end)

        return row
    end

    -- â”€â”€ Slider (label + draggable bar + numeric readout) â”€â”€
    -- callback(value) is fired on every change.
    function UI.createSlider(parent, name, yPos, minV, maxV, defaultV, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -30, 0, 40)
        row.Position = UDim2.new(0, 15, 0, yPos)
        row.BackgroundTransparency = 1
        row.Parent = parent

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.4, 0, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = C.TEXT_DIM
        lbl.Text = name
        lbl.Font = C.FONT_LABEL
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local valLbl = Instance.new("TextLabel")
        valLbl.Size = UDim2.new(0.2, 0, 0, 20)
        valLbl.Position = UDim2.new(0.8, 0, 0, 0)
        valLbl.BackgroundTransparency = 1
        valLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
        valLbl.Text = tostring(defaultV)
        valLbl.Font = C.FONT_MONO
        valLbl.TextSize = 12
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.Parent = row

        local bgTrack = Instance.new("Frame")
        bgTrack.Size = UDim2.new(1, 0, 0, 6)
        bgTrack.Position = UDim2.new(0, 0, 0, 26)
        bgTrack.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        bgTrack.BorderSizePixel = 0
        bgTrack.Parent = row
        Instance.new("UICorner").Parent = bgTrack

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((defaultV - minV) / (maxV - minV), 0, 1, 0)
        fill.BackgroundColor3 = C.VINO_TINTO_EXTREMO
        fill.BorderSizePixel = 0
        fill.Parent = bgTrack
        Instance.new("UICorner").Parent = fill

        local trigger = Instance.new("TextButton")
        trigger.Size = UDim2.new(1, 0, 3, 0)
        trigger.Position = UDim2.new(0, 0, 0.5, -9)
        trigger.BackgroundTransparency = 1
        trigger.Text = ""
        trigger.Parent = bgTrack

        local dragging = false
        local function updateSlider(input)
            local pos = math.clamp((input.Position.X - bgTrack.AbsolutePosition.X) / bgTrack.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            local val = math.floor(minV + (maxV - minV) * pos)
            valLbl.Text = tostring(val)
            callback(val)
        end
        trigger.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true updateSlider(i) end
        end)
        local c1 = UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        local c2 = UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(i) end
        end)
        table.insert(Connections, c1)
        table.insert(Connections, c2)

        return row
    end

    -- â”€â”€ Action button (title + description, with hover) â”€â”€
    function UI.createActionButton(parent, label, description, yPos, textColor)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -30, 0, 60)
        btn.Position = UDim2.new(0, 15, 0, yPos)
        btn.BackgroundColor3 = C.BG_ROW
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.Parent = parent
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = C.VINO_TINTO_EXTREMO
        Instance.new("UICorner").Parent = btn

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -20, 0, 28)
        title.Position = UDim2.new(0, 15, 0, 8)
        title.BackgroundTransparency = 1
        title.TextColor3 = textColor or C.TEXT_MAIN
        title.Text = label
        title.Font = C.FONT_LABEL_BOLD
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = btn

        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -20, 0, 18)
        desc.Position = UDim2.new(0, 15, 0, 36)
        desc.BackgroundTransparency = 1
        desc.TextColor3 = Color3.fromRGB(100, 100, 100)
        desc.Text = description
        desc.Font = C.FONT_LABEL
        desc.TextSize = 12
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = btn

        btn.MouseEnter:Connect(function()
            stroke.Color = Color3.fromRGB(120, 0, 10)
            btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        end)
        btn.MouseLeave:Connect(function()
            stroke.Color = C.VINO_TINTO_EXTREMO
            btn.BackgroundColor3 = C.BG_ROW
        end)

        return btn
    end

    -- â”€â”€ Mini multi-select toggle row (used in Combat tab) â”€â”€
    -- Renders a list of options each with its own switch bound to selectionTbl[key].
    function UI.createMultiSelect(parent, caption, yPos, selectionTbl, optionKeys)
        local cap = Instance.new("TextLabel")
        cap.Size = UDim2.new(1, -30, 0, 20)
        cap.Position = UDim2.new(0, 15, 0, yPos)
        cap.BackgroundTransparency = 1
        cap.TextColor3 = C.TEXT_FADE
        cap.Text = caption
        cap.Font = C.FONT_MONO
        cap.TextSize = 11
        cap.TextXAlignment = Enum.TextXAlignment.Left
        cap.Parent = parent
        for i, key in ipairs(optionKeys) do
            local r = Instance.new("Frame")
            r.Size = UDim2.new(1, -50, 0, 22)
            r.Position = UDim2.new(0, 25, 0, yPos + 22 + (i - 1) * 24)
            r.BackgroundTransparency = 1
            r.Parent = parent
            local t = Instance.new("TextLabel")
            t.Size = UDim2.new(1, -46, 1, 0)
            t.BackgroundTransparency = 1
            t.Text = key
            t.TextColor3 = Color3.fromRGB(200, 200, 200)
            t.Font = C.FONT_LABEL
            t.TextSize = 12
            t.TextXAlignment = Enum.TextXAlignment.Left
            t.Parent = r
            local track = Instance.new("Frame")
            track.Size = UDim2.new(0, 30, 0, 14)
            track.Position = UDim2.new(1, -30, 0.5, -7)
            track.BorderSizePixel = 0
            track.Parent = r
            Instance.new("UICorner").Parent = track
            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 10, 0, 10)
            knob.BackgroundColor3 = C.TEXT_MAIN
            knob.Parent = track
            Instance.new("UICorner").Parent = knob
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.Parent = track
            local rc = RunService.RenderStepped:Connect(function()
                if selectionTbl[key] then
                    track.BackgroundColor3 = C.VINO_TINTO_EXTREMO
                    knob.Position = UDim2.new(1, -12, 0.5, -5)
                else
                    track.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                    knob.Position = UDim2.new(0, 2, 0.5, -5)
                end
            end)
            table.insert(Connections, rc)
            btn.MouseButton1Click:Connect(function()
                selectionTbl[key] = not selectionTbl[key]
            end)
        end
        return #optionKeys * 24 + 22
    end

    return UI
end

return UILib
