local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer
local RunService = game:GetService("RunService")

TabGroup:AddToggle("InkGameAutowin", {
    Text = "Autowin ⭐",
    Default = false,
    Callback = function(Value)
        if Value then
            Script.Functions.Alert("Autowin enabled!", 5)
            if Library.Toggles.Noclip.Value ~= false then
                Library.Toggles.Noclip:SetValue(false)
            end
            Script.Functions.HandleAutowin()
        else
            if Script.Temp.lastCleanupFunction then
                pcall(Script.Temp.lastCleanupFunction)
                Script.Temp.lastCleanupFunction = nil
            end
            Script.Functions.Alert("Autowin disabled!", 3)
        end
    end,
})

TabGroup:AddToggle("FlingAuraToggle", {
    Text = "Fling Aura",
    Default = false,
    Callback = function(Value)
        local function stopFlingAura()
            Script.Temp.FlingAuraActive = false
            if Library.Toggles.Noclip.Value ~= false then
                Library.Toggles.Noclip:SetValue(false)
            end
            if Script.Connections.FlingAuraDeathConn then
                Script.Connections.FlingAuraDeathConn:Disconnect()
                Script.Connections.FlingAuraDeathConn = nil
            end
        end

        if Script.Tasks.FlingAuraTask then
            task.cancel(Script.Tasks.FlingAuraTask)
            Script.Tasks.FlingAuraTask = nil
        end
        if Value then
            Script.Functions.Alert("Fling Aura Enabled", 3)
            Script.Temp.FlingAuraActive = true
            pcall(function()
                if not Library.Toggles.PatchFlingAnticheat.Value then
                    Library.Toggles.PatchFlingAnticheat:SetValue(true)
                end
            end)
            if Library.Toggles.Noclip.Value ~= true then
                Library.Toggles.Noclip:SetValue(true)
            end
            local player = lplr
            local function getRoot(character)
                return character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))
            end
            local humanoid = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
            if humanoid then
                Script.Connections.FlingAuraDeathConn = humanoid.Died:Connect(stopFlingAura)
            end
            Script.Tasks.FlingAuraTask = task.spawn(function()
                local movel = 0.1
                while Script.Temp.FlingAuraActive and not Library.Unloaded do
                    local character = player.Character
                    local root = getRoot(character)
                    if character and character.Parent and root and root.Parent then
                        local originalVel = root.Velocity
                        root.Velocity = originalVel * 10000 + Vector3.new(0, 10000, 0)
                        RunService.RenderStepped:Wait()
                        if character and character.Parent and root and root.Parent then
                            root.Velocity = originalVel
                        end
                        RunService.Stepped:Wait()
                        if character and character.Parent and root and root.Parent then
                            root.Velocity = originalVel + Vector3.new(0, movel, 0)
                            movel = -movel
                        end
                    end
                    RunService.Heartbeat:Wait()
                end
            end)
        else
            pcall(function()
                if Library.Toggles.PatchFlingAnticheat.Value then
                    Library.Toggles.PatchFlingAnticheat:SetValue(false)
                end
            end)
            Script.Functions.Alert("Fling Aura Disabled", 3)
            stopFlingAura()
        end
    end,
})

TabGroup:AddToggle("AntiFlingToggle", {
    Text = "Anti Fling",
    Default = false,
    Callback = function(Value)
        if Script.Tasks.AntiFlingLoop then
            task.cancel(Script.Tasks.AntiFlingLoop)
            Script.Tasks.AntiFlingLoop = nil
        end
        if Value then
            if not hookmetamethod then
                Script.Functions.Alert("[Fling Aura]: Unsupported executor :(")
                Library.Toggles.AntiFlingToggle:SetValue(false)
                return
            end
            Script.Functions.Alert("Anti Fling Enabled", 3)
            Script.Tasks.AntiFlingLoop = task.spawn(function()
                local lastSafeCFrame = nil
                while Library.Toggles.AntiFlingToggle.Value and not Library.Unloaded do
                    task.wait(0.05)
                    local character = lplr.Character
                    local root = character and (Script.Functions.GetRootPart() or character:FindFirstChild("Torso"))
                    if root then
                        local isActiveGame = Script.GameState and Script.AutoWin[Script.GameState] ~= nil
                        for _, part in pairs(character:GetDescendants()) do
                            if
                                part:IsA("BodyMover")
                                or part:IsA("BodyVelocity")
                                or part:IsA("BodyGyro")
                                or part:IsA("BodyThrust")
                                or part:IsA("BodyAngularVelocity")
                            then
                                part:Destroy()
                            end
                        end
                        local maxVel = 100
                        local vel = root.Velocity
                        if vel.Magnitude > maxVel then
                            root.Velocity = Vector3.new(
                                math.clamp(vel.X, -maxVel, maxVel),
                                math.clamp(vel.Y, -maxVel, maxVel),
                                math.clamp(vel.Z, -maxVel, maxVel)
                            )
                        end
                        if (root.Position - lastSafeCFrame.Position).Magnitude < 20 then
                            lastSafeCFrame = root.CFrame
                        elseif
                            lastSafeCFrame
                            and isActiveGame
                            and (root.Position - lastSafeCFrame.Position).Magnitude > 50
                        then
                            root.CFrame = lastSafeCFrame
                            root.Velocity = Vector3.zero
                        end
                    end
                end
                Script.Tasks.AntiFlingLoop = nil
            end)
        else
            Script.Functions.Alert("Anti Fling Disabled", 3)
        end
    end,
})
