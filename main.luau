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

if getgenv().shared.VoidwareLoading then
    return
end
getgenv().shared.VoidwareLoading = true

local library = getgenv().shared.Voidware_InkGame_Library
if library then
    local suc = pcall(function()
        library:Unload()
    end)
    if not suc then
        return
    end
    while getgenv().shared.Voidware_InkGame_Library ~= nil do
        task.wait(0.3)
    end
end

local ModulesFolder = "voidware_linoria/ink_game/modules"
local TabGroupNames = {
    "RedLightGreenLight",
    "Dalgona",
    "HideAndSeek",
    "TugOfWar",
    "JumpRope",
    "GlassBridge",
    "Mingle",
    "Rebel",
    "Player",
    "Security",
    "Fun",
    "Useful",
    "Interaction",
    "AntiDeath",
    "Checkpoint",
    "Misc",
    "Emotes",
    "Performance",
    "MainESP",
    "HideAndSeekESP",
    "ESPSettings",
    "FOV",
    "Menu",
}

pcall(function()
    local isNew = false
    for _, v in ipairs({
        "voidware_linoria",
        "voidware_linoria/ink_game",
        "voidware_linoria/themes",
        "voidware_linoria/ink_game/settings",
        "voidware_linoria/ink_game/themes",
        ModulesFolder,
        ModulesFolder .. "/Groups",
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

local WebVersion = game:HttpGet(repo .. "version.txt")
local Success, ModulesIsFile = pcall(function()
    if not readfile or not writefile or not listfiles then
        return
    end
    local Success, localVersion = pcall(function()
        readfile(ModulesFolder .. "/version.txt")
    end)
    localVersion = Success and localVersion

    if localVersion == WebVersion then
        local groupFiles = listfiles(ModulesFolder .. "/Groups")
        if #groupFiles == #TabGroupNames then
            return true
        end
    end

    writefile(ModulesFolder .. "/Utils.luau", game:HttpGet(repo .. "Utils.luau"))

    for _, module in ipairs(TabGroupNames) do
        writefile(
            ModulesFolder .. "/Groups/" .. module .. ".luau",
            game:HttpGet(repo .. "Groups/" .. module .. ".luau")
        )
    end
    writefile(ModulesFolder .. "/version.txt", WebVersion)
    return true
end)
ModulesIsFile = Success and ModulesIsFile

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

local Window = Library:CreateWindow({
    Title = "Voidware - Ink Game | Version: " .. WebVersion,
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

local Functions
if ModulesIsFile then
    Functions = loadfile(ModulesFolder .. "/Utils.luau")
else
    Functions = loadstring(game:HttpGet(repo .. "Utils.luau"))
end
if not Functions then
    error("Something wrong with utils")
end

Script = Functions(Script, Library)

for _, TabGroup in ipairs(TabGroupNames) do
    local group
    if ModulesIsFile then
        group = loadfile(ModulesFolder .. "/Groups/" .. TabGroup .. ".luau")
    else
        group = loadstring(game:HttpGet(Script.repo .. "Groups/" .. TabGroup .. ".luau"))
    end
    if group then
        group(TabGroups[TabGroup], Script, Library)
    else
        error("Something wrong with '" .. TabGroup .. ".luau'")
    end
end

Library:OnUnload(Script.Functions.OnUnload)
task.spawn(function()
    pcall(Script.Functions.OnLoad)
end)
