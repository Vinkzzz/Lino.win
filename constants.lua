--[[
â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—
â•‘   GOTHAM HUB â€” shared/constants.lua                       â•‘
â•‘                                                              â•‘
â•‘   Returns a table with the brand identity (colors, fonts,    â•‘
â•‘   asset IDs, links, supported games list).                   â•‘
â•‘                                                              â•‘
â•‘   Usage from any script:                                     â•‘
â•‘     local C = loadstring(game:HttpGet(                       â•‘
â•‘       "https://plunderer-hub.caceresforums.workers.dev/"..   â•‘
â•‘       "?file=shared/constants.lua", true))()                 â•‘
â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
]]

local C = {}

-- â”€â”€ Brand colors â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
C.VINO_TINTO_EXTREMO = Color3.fromRGB(170, 170, 170) -- signature light gray accent
C.VINO_HOVER         = Color3.fromRGB(130, 130, 130) -- gray hover
C.ACCENT_TEXT        = Color3.fromRGB(15, 15, 15)    -- dark text on white accent bg
C.BG_HUB             = Color3.fromRGB(11, 11, 11) -- hub background
C.BG_CARD            = Color3.fromRGB(13, 13, 13) -- content cards
C.BG_SIDE            = Color3.fromRGB(8, 8, 8)    -- sidebar
C.BG_ROW             = Color3.fromRGB(18, 18, 18) -- toggle rows / buttons
C.BG_INPUT           = Color3.fromRGB(18, 18, 18) -- text input boxes
C.TEXT_MAIN          = Color3.fromRGB(255, 255, 255)
C.TEXT_DIM           = Color3.fromRGB(180, 180, 180)
C.TEXT_FADE          = Color3.fromRGB(120, 120, 120)
C.TEXT_GREEN         = Color3.fromRGB(100, 220, 100)
C.TEXT_RED           = Color3.fromRGB(220, 60, 70)
C.TEXT_AMBER         = Color3.fromRGB(220, 160, 60)

-- â”€â”€ Asset IDs â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
C.LOGO_ID            = "rbxassetid://102066219072072"
C.DISCORD_IMG_ID     = "rbxassetid://121778919195268"

-- Sidebar tab icons (Roblox official UI icon assets)
C.ICON_MAIN          = "rbxassetid://120809262951948"    -- main
C.ICON_COMBAT        = "rbxassetid://83084672021550"     -- combat
C.ICON_NAV           = "rbxassetid://7733964640"         -- map pin (works)
C.ICON_PARRY         = "rbxassetid://7733774602"         -- shield  (works)
C.ICON_CONFIG        = "â‰¡"                               -- three lines
C.ICON_SETTING       = "rbxassetid://100219331678015"    -- settings
C.ICON_ACTIONS       = "rbxassetid://7733779610"         -- lightning (works)
C.ICON_COLOR         = Color3.fromRGB(240, 240, 240)

-- â”€â”€ Links â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
C.DISCORD_LINK       = "https://discord.gg/AD5NsXxMjn"

-- â”€â”€ Supported games (shown in key system dropdown) â”€â”€
C.SUPPORTED_GAMES = {
    " Flee the Facility",
    " Sell Lemons",
    " VV: Ultimatum",
    " REDLINERS",
    " Murder Mystery 2",
}

-- â”€â”€ Fonts â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
C.FONT_KEY_TITLE     = Enum.Font.Antique     -- key system title
C.FONT_HUB_TITLE     = Enum.Font.Code        -- hub titles / section headers
C.FONT_LABEL         = Enum.Font.SourceSans  -- labels and descriptions
C.FONT_LABEL_BOLD    = Enum.Font.SourceSansBold
C.FONT_OWNER_SUB     = Enum.Font.Bodoni      -- owner subtext ("Noah")
C.FONT_MONO          = Enum.Font.Code        -- keybind text / IDs

return C
