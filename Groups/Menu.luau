local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
TabGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "Menu keybind",
})
Library.ToggleKeybind = Library.Options.MenuKeybind

TabGroup:AddToggle("KeybindMenuOpen", {
    Default = false,
    Text = "Open Keybind Menu",
    Callback = function(value)
        Library.KeybindFrame.Visible = value
    end,
})

TabGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = true,
    Callback = function(Value)
        Library.ShowCustomCursor = Value
    end,
})

TabGroup:AddButton("Unload Script", function()
    Library:Unload()
end)

TabGroup:AddButton("Reset Settings", function()
    Script.SaveManager:SaveAutoloadConfig("default")
    pcall(function()
        writefile("voidware_linoria/ink_game/settings/default.json", "[]")
    end)
    pcall(function()
        Library:Unload()
    end)
    local load = loadstring(game:HttpGet(Script.repo .. "inkgame.luau"))
    if load then
        load()
    end
end)
