-- If someone somehow found this script
-- This is fork of Voidware!
-- Original scripts discord: discord.gg/voidware
-- Original script owner: Voidware
-- Forked from: https://github.com/VapeVoidware/VW-Add

local repo = "https://raw.githubusercontent.com/NSeydulla/VW-Add/refs/heads/TestingMultiFile/"

--// Setup \\--
if not getgenv().shared then
    getgenv().shared = {}
end

local library = getgenv().shared.Voidware_InkGame_Library
if library then
    local suc = pcall(function()
        library:Unload()
    end)
    if not suc then
        error("[Voidware] Something went wrong while closing another running script")
    end
    local TIMEOUT = 5
    local startTime = tick()
    while getgenv().shared.Voidware_InkGame_Library do
        if tick() - startTime > TIMEOUT then
            error("[Voidware] Timeout while waiting for another script to close")
        end
        task.wait(0.3)
    end
end

pcall(function()
    local isNew = false
    for _, v in ipairs({
        "VW_NSeed",
        "VW_NSeed/ink_game",
        "VW_NSeed/themes",
        "VW_NSeed/ink_game/settings",
        "VW_NSeed/ink_game/themes",
    }) do
        if not isfolder(v) then
            makefolder(v)
            isNew = true
        end
    end

    if isNew then
        writefile("VW_NSeed/themes/default.txt", "Jester")
        writefile("VW_NSeed/ink_game/settings/default.json", "[]")
    end
end)

--// Library \\--
local Library: Obsidian
local SaveManager
local ThemeManager

local loadLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/Obsidian/main/Library.lua"))
if not loadLibrary then
    error("Something wrong with Library")
end
Library = loadLibrary()
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
    Script = Window:AddTab("Script", "sliders-horizontal"),
}

local TabGroups = {
    RedLightGreenLight = Tabs.Main:AddLeftGroupbox("Red Light / Green Light", "traffic-light"),
    Dalgona = Tabs.Main:AddRightGroupbox("Dalgona", "circle"),
    HideAndSeek = Tabs.Main:AddLeftGroupbox("Hide And Seeek", "search"),
    TugOfWar = Tabs.Main:AddRightGroupbox("Tug Of War", "rope"),
    JumpRope = Tabs.Main:AddLeftGroupbox("Jump Rope", "rope"),
    GlassBridge = Tabs.Main:AddRightGroupbox("Glass Bridge", "bridge"),
    Mingle = Tabs.Main:AddLeftGroupbox("Mingle", "users"),
    Rebel = Tabs.Main:AddRightGroupbox("Rebel", "sword"),

    Player = Tabs.Other:AddLeftGroupbox("Player", "user"),
    Security = Tabs.Other:AddRightGroupbox("Security", "shield"),
    Fun = Tabs.Other:AddLeftGroupbox("Fun", "zap"),
    Useful = Tabs.Other:AddRightGroupbox("Useful Stuff", "star"),
    Interaction = Tabs.Other:AddLeftGroupbox("Interaction", "hand-pointer"),
    AntiDeath = Tabs.Other:AddRightGroupbox("Anti Death", "skull"),
    Checkpoint = Tabs.Other:AddRightGroupbox("Checkpoint", "skull"),

    Misc = Tabs.Misc:AddLeftGroupbox("Misc", "wrench"),
    Emotes = Tabs.Misc:AddRightGroupbox("Emote", "smile"),
    Performance = Tabs.Misc:AddRightGroupbox("Performance", "gauge"),

    MainESP = Tabs.Visuals:AddLeftGroupbox("Main ESP", "eye"),
    HideAndSeekESP = Tabs.Visuals:AddLeftGroupbox("Hide and Seek ESP", "search"),
    ESPSettings = Tabs.Visuals:AddRightGroupbox("ESP Settings", "sliders"),
    FOV = Tabs.Visuals:AddRightGroupbox("FOV settings", "user"),

    Menu = Tabs.Script:AddRightGroupbox("Menu", "menu"),
}

local loadThemeManager =
    loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/Obsidian/main/addons/ThemeManager.lua"))
if not loadThemeManager then
    error("Something wrong with ThemeManager")
end
ThemeManager = loadThemeManager()

local loadSaveManager =
    loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/Obsidian/main/addons/SaveManager.lua"))
if not loadSaveManager then
    error("Something wrong with SaveManager")
end
SaveManager = loadSaveManager()

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:SetFolder("VW_NSeed")
SaveManager:SetFolder("VW_NSeed/ink_game")
SaveManager:BuildConfigSection(Tabs.Script)
ThemeManager:ApplyToTab(Tabs.Script)

--// Script \\--
local Script: ScriptType = {
    repo = repo,
    GameState = "unknown",
    Connections = {
        PlayerCharAdded = {},
        GuardCharAdded = {},
    },
    Tasks = {},
    ESPTable = {
        Player = {},
        Guard = {},
        Door = {},
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
    Functions = nil,
}

Script.Functions = Functions(Script, Library)

for TabGroup, group in pairs(GroupFunctions) do
    group(TabGroups[TabGroup], Script, Library)
end

Library:OnUnload(Script.Functions.OnUnload)
task.spawn(function()
    getgenv().shared.VoidwareLoading = nil
    pcall(Script.Functions.OnLoad)
end)
