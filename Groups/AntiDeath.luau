local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer

local function TPBackFromAntiDeath()
    if Script.Temp.OldDeathLocation then
        Script.Functions.SafeTeleportToCFrame(Script.Temp.OldDeathLocation)
        Script.Temp.OldDeathLocation = nil
    end
end

TabGroup:AddToggle("AntiDeathToggle", {
    Text = "Anti Death",
    Default = false,
    Callback = function(Value)
        if Script.Temp.AntiDeathTask then
            task.cancel(Script.Temp.AntiDeathTask)
            Script.Temp.AntiDeathTask = nil
        end
        if not Value then
            return
        end
        Script.Temp.AntiDeathTask = task.spawn(function()
            repeat
                task.wait()
                if lplr.Character then
                    local hum = lplr.Character:FindFirstChildOfClass("Humanoid")
                    if not hum then
                        return
                    end
                    if hum.Health <= Library.Options.AntiDeathHealthThreshold.Value then
                        if (Script.Camera.CFrame.Position - Script.Temp.SafePlace.Position).Magnitude > 20 then
                            local humRootPart = Script.Functions.GetRootPart()
                            if humRootPart then
                                Script.Temp.OldDeathLocation = CFrame.new(humRootPart.Position)
                                Script.Temp.OldDeathGame = Script.GameState
                            end
                            Script.Functions.SafeTeleportToCFrame(Script.Temp.SafePlace)
                            Script.Functions.Alert("Teleported to safe place!")
                        end
                    end
                end
            until not Library.Toggles.AntiDeathToggle.Value or Library.Unloaded
        end)
    end,
})

TabGroup:AddSlider("AntiDeathHealthThreshold", {
    Text = "Health Threshold",
    Default = 30,
    Min = 10,
    Max = 90,
    Rounding = 1,
})

TabGroup:AddButton("TP back from AntiDeath", TPBackFromAntiDeath)
