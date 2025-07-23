return function(TabGroup, Script, Library)
    local Players = Script.Services.Players
    local lplr = Players.LocalPlayer
    local RunService = Script.Services.RunService
    local UserInputService = Script.Services.UserInputService

    TabGroup:AddSlider("WonBoostSlider", {
        Text = "Won boost(idk it works or not)",
        Default = lplr.Boosts["Won Boost"].Value,
        Min = 0,
        Max = 3,
        Rounding = 0,
        Callback = function(val)
            lplr.Boosts["Won Boost"].Value = val
        end,
    })

    TabGroup:AddSlider("StrengthBoostSlider", {
        Text = "Strength boost(idk it works or not)",
        Default = lplr.Boosts["Damage Boost"].Value,
        Min = 0,
        Max = 5,
        Rounding = 0,
        Callback = function(val)
            lplr.Boosts["Damage Boost"].Value = val
        end,
    })

    TabGroup:AddSlider("SpeedBoostSlider", {
        Text = "Speed boost",
        Default = lplr.Boosts["Faster Sprint"].Value,
        Min = 0,
        Max = 5,
        Rounding = 0,
        Callback = function(val)
            lplr.Boosts["Faster Sprint"].Value = val
        end,
    })

    TabGroup:AddSlider("SpeedSlider", {
        Text = "Walk Speed",
        Default = 16,
        Min = 0,
        Max = 100,
        Rounding = 1,
        Callback = function(val)
            if not Library.Toggles.SpeedToggle.Value then
                return
            end
            if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
                lplr.Character.Humanoid.WalkSpeed = Library.Options.SpeedSlider.Value
            end
        end,
    })

    TabGroup:AddToggle("SpeedToggle", {
        Text = "Speed",
        Default = false,
        Callback = function(Value)
            if Value then
                Script.Functions.Alert("Speed Enabled", 3)
                if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
                    Script.Temp.OldSpeed = lplr.Character.Humanoid.WalkSpeed
                    lplr.Character.Humanoid.WalkSpeed = Library.Options.SpeedSlider.Value
                end
                Script.Tasks.SpeedToggleTask = task.spawn(function()
                    repeat
                        task.wait(0.5)
                        if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
                            lplr.Character.Humanoid.WalkSpeed = Library.Options.SpeedSlider.Value
                        end
                    until not Library.Toggles.SpeedToggle.Value or Library.Unloaded
                    Script.Tasks.SpeedToggleTask = nil
                end)
            else
                Script.Functions.Alert("Speed Disabled", 3)
                if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
                    lplr.Character.Humanoid.WalkSpeed = Script.Temp.OldSpeed
                    Script.Temp.OldSpeed = nil
                end
            end
        end,
    }):AddKeyPicker("SpeedKey", {
        Mode = "Toggle",
        Default = "C",
        Text = "Speed",
        SyncToggleState = true,
    })

    TabGroup:AddToggle("Noclip", {
        Text = "Noclip",
        Default = false,
        Callback = function(Value)
            Script.Temp.NoclipParts = Script.Temp.NoclipParts or {}
            if Value then
                Script.Functions.Alert("Noclip Enabled", 3)
                Script.Tasks.NoclipTask = task.spawn(function()
                    repeat
                        RunService.Heartbeat:Wait()
                        if lplr.Character then
                            for _, child in pairs(lplr.Character:GetDescendants()) do
                                if child:IsA("BasePart") and child.CanCollide == true then
                                    child.CanCollide = false
                                    Script.Temp.NoclipParts[child] = true
                                end
                            end
                        end
                    until not Library.Toggles.Noclip.Value or Library.Unloaded
                    Script.Tasks.NoclipTask = nil
                end)
            else
                Script.Functions.Alert("Noclip Disabled", 3)
                if lplr.Character and Script.Temp.NoclipParts then
                    for part, _ in pairs(Script.Temp.NoclipParts) do
                        if part and part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                    Script.Temp.NoclipParts = {}
                end
            end
        end,
    }):AddKeyPicker("NoclipKey", {
        Mode = "Toggle",
        Default = "N",
        Text = "Noclip",
        SyncToggleState = true,
    })

    TabGroup:AddToggle("InfiniteJump", {
        Text = "Infinite Jump",
        Default = false,
        Callback = function(Value)
            if Script.Connections.InfiniteJumpConnect then
                Script.Connections.InfiniteJumpConnect:Disconnect()
            end
            if not Value then
                return
            end
            Script.Connections.InfiniteJumpConnect = UserInputService.JumpRequest:Connect(function()
                if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
                    lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end,
    })
end
