-- If someone somehow found this script
-- This is fork of Voidware!
-- Original scripts discord: discord.gg/voidware
-- Original script owner: Voidware
-- Forked from: https://github.com/VapeVoidware/VW-Add

--// Setup \\--
if not getgenv().shared then
    getgenv().shared = {}
end

if getgenv().shared.Voidware_InkGame_Library then
    local suc = pcall(function()
        getgenv().shared.Voidware_InkGame_Library:Unload()
    end)
    if not suc then
        return
    end
    while getgenv().shared.Voidware_InkGame_Library ~= nil do
        task.wait(0.1)
    end
end

pcall(function()
    local isNew = false
    for _, v in ipairs({
        "voidware_linoria",
        "voidware_linoria/ink_game",
        "voidware_linoria/themes",
        "voidware_linoria/ink_game/settings",
        "voidware_linoria/ink_game/themes",
    }) do
        if not isfolder(v) then
            makefolder(v)
            isNew = true
        end
    end

    if isNew then
        pcall(function()
            writefile("voidware_linoria/themes/default.txt", "Jester")
        end)
        pcall(function()
            writefile("voidware_linoria/ink_game/settings/default.json", "[]")
        end)
    end
end)

--// Library \\--
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/Obsidian/main/Library.lua"))()
local ThemeManager =
    loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/Obsidian/main/addons/ThemeManager.lua"))()
local SaveManager =
    loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/Obsidian/main/addons/SaveManager.lua"))()
getgenv().shared.Voidware_InkGame_Library = Library

local Window = Library:CreateWindow({
    Title = "Voidware - Ink Game",
    Footer = "This is fork of Voidware! Original scripts discord - discord.gg/voidware",
    Center = true,
    AutoShow = true,
    Resizable = true,
    ShowCustomCursor = true,
    TabPadding = 2,
    MenuFadeTime = 0,
})

local Tabs = {
    Main = Window:AddTab("Main", "gamepad-2"),
    Other = Window:AddTab("Other", "settings"),
    Misc = Window:AddTab("Misc", "wrench"),
    Visuals = Window:AddTab("Visuals", "eye"),
    ["UI Settings"] = Window:AddTab("UI Settings", "sliders-horizontal"),
}

local TabGroups = {
    Player = Tabs.Main:AddLeftGroupbox("Player", "user"),
    RedLightGreenLight = Tabs.Main:AddRightGroupbox("Red Light / Green Light", "traffic-light"),
    Dalgona = Tabs.Main:AddLeftGroupbox("Dalgona", "circle"),
    HideAndSeek = Tabs.Main:AddRightGroupbox("Hide And Seeek", "search"),
    TugOfWar = Tabs.Main:AddLeftGroupbox("Tug Of War", "rope"),
    JumpRope = Tabs.Main:AddRightGroupbox("Jump Rope", "rope"),
    GlassBridge = Tabs.Main:AddLeftGroupbox("Glass Bridge", "bridge"),
    Mingle = Tabs.Main:AddRightGroupbox("Mingle", "users"),
    Security = Tabs.Main:AddLeftGroupbox("Security", "shield"),
    Rebel = Tabs.Main:AddRightGroupbox("Rebel", "sword"),

    Fun = Tabs.Other:AddLeftGroupbox("Fun", "zap"),
    Useful = Tabs.Other:AddRightGroupbox("Useful Stuff", "star"),
    Interaction = Tabs.Other:AddLeftGroupbox("Interaction", "hand-pointer"),
    AntiDeath = Tabs.Other:AddRightGroupbox("Anti Death", "skull"),

    Misc = Tabs.Misc:AddLeftGroupbox("Misc", "wrench"),
    Emotes = Tabs.Misc:AddRightGroupbox("Emote", "smile"),
    Performance = Tabs.Misc:AddRightGroupbox("Performance", "gauge"),

    MainESP = Tabs.Visuals:AddLeftGroupbox("Main ESP", "eye"),
    HideAndSeekESP = Tabs.Visuals:AddLeftGroupbox("Hide and Seek ESP", "search"),
    ESPSettings = Tabs.Visuals:AddRightGroupbox("ESP Settings", "sliders"),
    FOV = Tabs.Visuals:AddRightGroupbox("FOV settings", "user"),

    Menu = Tabs["UI Settings"]:AddRightGroupbox("Menu", "menu"),
}
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:SetFolder("voidware_linoria")
SaveManager:SetFolder("voidware_linoria/ink_game")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

--// Script \\--
local Script = {
    repo = "https://raw.githubusercontent.com/NSeydulla/VW-Add/refs/heads/TestingMultiFile/",
    GameState = "unknown",
    Services = setmetatable({}, {
        __index = function(self, key)
            local suc, service = pcall(game.GetService, game, key)
            if suc and service then
                self[key] = service
                return service
            else
                warn(`[Services] Warning: "{key}" is not a valid Roblox service.`)
                return nil
            end
        end,
    }),
    Connections = {
        PlayerCharAdded = {},
        GuardCharAdded = {},
    },
    Tasks = {},
    ESPTable = {
        Player = {},
        Guard = {},
        Door = {},
        Hider = {},
        Seeker = {},
        None = {},
        Key = {},
        ["Escape Door"] = {},
    },
    AutoWin = {},
    OnGame = {},
    HookMethods = {},
    Temp = {},
    SaveManager = SaveManager,
    ThemeManager = ThemeManager,
    Camera = workspace.CurrentCamera,
}

Script.Functions = loadstring(game:HttpGet(Script.repo .. "Utils.luau"))()(Script, Library)
Script.AutoWin.LightsOut = Script.Functions.TeleportToSafe

for _, TabGroup in ipairs({
    "Player",
    "RedLightGreenLight",
    "Dalgona",
    "HideAndSeek",
    "TugOfWar",
    "JumpRope",
    "GlassBridge",
    "Mingle",
    "Security",
    "Rebel",
    "Fun",
    "Useful",
    "Interaction",
    "AntiDeath",
    "Misc",
    "Emotes",
    "Performance",
    "MainESP",
    "HideAndSeekESP",
    "ESPSettings",
    "FOV",
    "Menu",
}) do
    loadstring(game:HttpGet(Script.repo .. "Groups/" .. TabGroup .. ".luau"))()(TabGroups[TabGroup], Script, Library)
end

Library:OnUnload(Script.Functions.OnUnload)
task.spawn(function()
    pcall(Script.Functions.OnLoad)
end)
