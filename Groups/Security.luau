return function(TabGroup, Script, Library)
    local Players = Script.Services.Players
    local lplr = Players.LocalPlayer
    local VirtualUser = Script.Services.VirtualUser

    TabGroup:AddToggle("Fling Character Hook", {
        Text = "Fling Character Hook",
        Default = false,
        Callback = function(Value)
            if Value then
                local function PatchFlingAnticheat()
                    local char = lplr.Character
                    if not char then
                        return
                    end
                    local root = Script.Functions.GetRootPart()
                    if not root then
                        return
                    end

                    local anticheatStates =
                        { "Stun", "Anchor", "RotateDisabled", "CantRun", "InCutscene", "DisableHeadLookAt" }
                    if not Script.Temp.FlingAnticheatChildConn then
                        Script.Temp.FlingAnticheatChildConn = char.ChildAdded:Connect(function(child)
                            if table.find(anticheatStates, child.Name) then
                                task.delay(0.01, function()
                                    child:Destroy()
                                end)
                            end
                        end)
                    end

                    if not Script.Temp.FlingAnticheatMT then
                        local mt = getrawmetatable(root)
                        Script.Temp.FlingAnticheatOldNewIndex = mt.__newindex
                        setreadonly(mt, false)
                        mt.__newindex = function(self, key, value)
                            if self == root and key == "Anchored" and value == true then
                                return
                            end
                            return Script.Temp.FlingAnticheatOldNewIndex(self, key, value)
                        end
                        setreadonly(mt, true)
                        Script.Temp.FlingAnticheatMT = mt
                    end
                end

                Script.Temp.FlingAnticheatCharConn = lplr.CharacterAdded:Connect(function(char)
                    task.wait(1)
                    PatchFlingAnticheat()
                end)
                if lplr.Character then
                    PatchFlingAnticheat()
                end
                Script.Functions.Alert("Anticheat Patched!", 3)
            else
                if Script.Temp.FlingAnticheatCharConn then
                    Script.Temp.FlingAnticheatCharConn:Disconnect()
                    Script.Temp.FlingAnticheatCharConn = nil
                end
                if Script.Temp.FlingAnticheatChildConn then
                    Script.Temp.FlingAnticheatChildConn:Disconnect()
                    Script.Temp.FlingAnticheatChildConn = nil
                end
                if Script.Temp.FlingAnticheatMT and Script.Temp.FlingAnticheatOldNewIndex then
                    local root = Script.Functions.GetRootPart()
                    if root then
                        local mt = Script.Temp.FlingAnticheatMT
                        setreadonly(mt, false)
                        mt.__newindex = Script.Temp.FlingAnticheatOldNewIndex
                        setreadonly(mt, true)
                    end
                    Script.Temp.FlingAnticheatMT = nil
                    Script.Temp.FlingAnticheatOldNewIndex = nil
                end
                Script.Functions.Alert("Anticheat Patch Disabled!", 3)
            end
        end,
    })

    TabGroup:AddToggle("Block Anticheat Remote", {
        Text = "Block Anticheat Remote",
        Default = false,
        Callback = function(call)
            if not hookmetamethod then
                return
            end
            Script.HookMethods.Anticheat = nil
            if not call then
                return
            end
            Script.HookMethods.Anticheat = function(self, method, args)
                if self == "TemporaryReachedBindable" and method == "FireServer" then
                    if type(args[1]) == "table" and (args[1].FallingPlayer ~= nil or args[1].funnydeath ~= nil) then
                        return nil
                    end
                end

                if self == "RandomOtherRemotes" and method == "FireServer" then
                    if type(args[1]) == "table" and args[1].FallenOffMap ~= nil then
                        return nil
                    end
                end
                return args
            end
        end,
    })

    TabGroup:AddToggle("AntiAfk", {
        Text = "Anti AFK",
        Default = true,
        Callback = function(Value)
            if Script.Connections.AntiAfkConnection then
                pcall(function()
                    Script.Connections.AntiAfkConnection:Disconnect()
                end)
            end
            if not Value then
                return
            end
            Script.Connections.AntiAfkConnection = lplr.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0, 0), Script.Camera.CFrame)
                wait(1)
                VirtualUser:Button2Up(Vector2.new(0, 0), Script.Camera.CFrame)
            end)
        end,
    })

    TabGroup:AddToggle("StaffDetector", {
        Text = "Staff Detector",
        Default = true,
        Callback = function(Value)
            if Value then
                local STAFF_GROUP_ID = 12398672
                local STAFF_MIN_RANK = 120
                local staffRoles = {
                    [120] = "moderator",
                    [254] = "dev",
                    [255] = "owner",
                }
                Script.Temp.DetectedStaff = Script.Temp.DetectedStaff or {}
                local function checkPlayerStaff(player)
                    local success, rank = pcall(function()
                        return player:GetRankInGroup(STAFF_GROUP_ID)
                    end)
                    if success and rank and rank >= STAFF_MIN_RANK then
                        local roleName = staffRoles[rank] or ("rank " .. tostring(rank))
                        Script.Functions.Alert(
                            "[StaffDetector] Staff detected: " .. player.Name .. " (" .. roleName .. ")",
                            10
                        )
                        Script.Temp.DetectedStaff[player.UserId] = { Name = player.Name, Role = roleName }
                        return true
                    end
                    return false
                end
                Script.Temp.StaffDetectorConnections = Script.Temp.StaffDetectorConnections or {}
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= lplr then
                        checkPlayerStaff(player)
                    end
                end
                Script.Temp.StaffDetectorConnections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
                    if player ~= lplr then
                        task.wait(1)
                        checkPlayerStaff(player)
                    end
                end)
                Script.Temp.StaffDetectorConnections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
                    local staffInfo = Script.Temp.DetectedStaff and Script.Temp.DetectedStaff[player.UserId]
                    if staffInfo then
                        Script.Functions.Alert(
                            "[StaffDetector] Staff left: " .. staffInfo.Name .. " (" .. staffInfo.Role .. ")",
                            10
                        )
                        Script.Temp.DetectedStaff[player.UserId] = nil
                    end
                end)
            else
                if Script.Temp.StaffDetectorConnections then
                    for _, conn in pairs(Script.Temp.StaffDetectorConnections) do
                        pcall(function()
                            conn:Disconnect()
                        end)
                    end
                    Script.Temp.StaffDetectorConnections = nil
                end
                Script.Temp.DetectedStaff = nil
                Script.Functions.Alert("[StaffDetector] Staff detection disabled.", 3)
            end
        end,
    })
end
