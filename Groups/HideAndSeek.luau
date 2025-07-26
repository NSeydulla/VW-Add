local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer

Script.AutoWin.HideAndSeek = function()
    if lplr:FindFirstChild("CurrentKeys") then
        Script.Functions.TeleportToSafe()
    else
        Script.Functions.Alert("[Autowin]: Hide and Seek support for Seekers soon...")
    end
end

local function GetHider(): Model?
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == lplr or not plr.Character then
            continue
        end
        local hum = plr.Character:FindFirstChild("Humanoid") :: Humanoid?
        if not hum or not plr:GetAttribute("IsHider") or hum.Health <= 0 then
            continue
        end
        return plr.Character
    end
    return nil
end

TabGroup:AddToggle("TeleportToHider", {
    Text = "Teleport To Hider",
    Default = false,
    Callback = function(Value)
        if Value then
            task.delay(0.5, function()
                if Library.Toggles.TeleportToHider.Value then
                    Library.Toggles.TeleportToHider:SetValue(false)
                end
            end)
            if not lplr.Character then
                return
            end
            if Script.GameState ~= "HideAndSeek" then
                Script.Functions.Alert("Game not running!")
                return
            end
            local hider = GetHider()
            if not hider then
                Script.Functions.Alert("No hider found :(")
                return
            end
            lplr.Character:PivotTo(hider:GetPrimaryPartCFrame())
        end
    end,
}):AddKeyPicker("TTH", {
    Mode = "Toggle",
    Default = "P",
    Text = "Teleport To Hider",
    SyncToggleState = true,
})

local function TeleportSafeHidingSpot()
    if not lplr.Character then
        return
    end
    Script.Functions.SafeTeleport(229.9, 1005.3, 169.4)
end

TabGroup:AddButton("Teleport to Safe Hiding Spot", function()
    if Script.GameState ~= "HideAndSeek" then
        Script.Functions.Alert("Game not running!")
        return
    end
    TeleportSafeHidingSpot()
end)
