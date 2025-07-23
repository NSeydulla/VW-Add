return function(TabGroup, Script, Library)
    local Players = Script.Services.Players
    local lplr = Players.LocalPlayer

    Script.AutoWin.HideAndSeek = function()
        if lplr:FindFirstChild("CurrentKeys") then
            Script.Functions.TeleportToSafe()
        else
            Script.Functions.Alert("[Autowin]: Hide and Seek support for Seekers soon...")
        end
    end

    local function GetHider()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr == lplr then
                continue
            end
            if not plr.Character then
                continue
            end
            if not plr:GetAttribute("IsHider") then
                continue
            end
            if plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                return plr.Character
            end
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
end
