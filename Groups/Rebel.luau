return function(TabGroup, Script, Library)
    local ReplicatedStorage = Script.Services.ReplicatedStorage

    TabGroup:AddToggle("ExpandGuardHitbox", {
        Text = "Expand Guard Hitbox",
        Default = false,
        Callback = function(Value)
            if Script.Connections.GuardHitboxConnection then
                Script.Connections.GuardHitboxConnection:Disconnect()
                Script.Connections.GuardHitboxConnection = nil
            end
            local live = workspace:FindFirstChild("Live")
            if not live then
                return
            end
            if Value then
                Script.Connections.GuardHitboxConnection = live.ChildAdded:Connect(function(model)
                    if not Script.Functions.IsGuard(model) then
                        return
                    end
                    local head = model:WaitForChild("Head", 5)
                    if not head or not head:IsA("BasePart") then
                        return
                    end
                    if model and model.Parent and head and head.Parent then
                        head.Size = Vector3.new(4, 4, 4)
                        head.CanCollide = false
                    end
                    local index = #Script.Connections.GuardCharAdded + 1
                    Script.Connections.GuardCharAdded[index] = model.ChildAdded:Connect(function(folder)
                        if folder.Name == "Dead" and folder.ClassName == "Folder" then
                            head.Size = Vector3.new(1, 1, 1)
                            local conn = Script.Connections.GuardCharAdded[index]
                            if conn then
                                conn:Disconnect()
                                Script.Connections.GuardCharAdded[index] = nil
                            end
                        end
                    end)
                end)
                for _, model in pairs(live:GetChildren()) do
                    if not Script.Functions.IsGuard(model) then
                        return
                    end
                    if model:FindFirstChild("Dead") then
                        continue
                    end
                    local head = model:WaitForChild("Head", 5)
                    if not head or not head:IsA("BasePart") then
                        return
                    end
                    if model and model.Parent and head and head.Parent then
                        head.Size = Vector3.new(4, 4, 4)
                        head.CanCollide = false
                    end
                end
            else
                for _, model in ipairs(live:GetChildren()) do
                    if not Script.Functions.IsGuard(model) then
                        return
                    end
                    local head = model:WaitForChild("Head", 5)
                    if not head or not head:IsA("BasePart") then
                        return
                    end
                    if model and model.Parent and head and head.Parent then
                        head.Size = Vector3.new(1, 1, 1)
                    end
                end
            end
        end,
    })

    TabGroup:AddButton("Bring All Guards", function()
        if not Script.Functions.GetRootPart() then
            return
        end
        local myPos = Script.Functions.GetRootPart().Position
        local Live = workspace:WaitForChild("Live")
        for _, guard in pairs(Live:GetChildren()) do
            if Script.Functions.IsGuard(guard) and guard:FindFirstChild("HumanoidRootPart") then
                local guardRoot = guard.HumanoidRootPart
                local lookCFrame = CFrame.new(guardRoot.Position, myPos)
                guardRoot.CFrame = lookCFrame
            end
        end
    end)

    TabGroup:AddToggle("GunMods", {
        Text = "Gun Mods",
        Default = false,
        Callback = function(enable)
            Script.Temp.originalDamageValues = Script.Temp.originalDamageValues or {}
            Script.Temp.originalGunStats = Script.Temp.originalGunStats or {}
            local Guns = ReplicatedStorage:FindFirstChild("Weapons")
                and ReplicatedStorage.Weapons:FindFirstChild("Guns")
            if not Guns then
                return
            end
            -- local GunDamageValues = Script.Functions.SafeRequire(ReplicatedStorage.Modules.GunDamageValues)
            for _, gun in pairs(Guns:GetChildren()) do
                if enable then
                    if not Script.Temp.originalGunStats[gun.Name] then
                        Script.Temp.originalGunStats[gun.Name] = {}
                        for _, stat in ipairs({ "Spread", "FireRateCD", "MaxBullets", "ReloadingSpeed" }) do
                            if gun:FindFirstChild(stat) then
                                Script.Temp.originalGunStats[gun.Name][stat] = gun[stat].Value
                            end
                        end
                    end
                    if gun:FindFirstChild("Spread") then
                        gun.Spread.Value = 0
                    end
                    if gun:FindFirstChild("FireRateCD") then
                        gun.FireRateCD.Value = 0.05
                    end
                    if gun:FindFirstChild("MaxBullets") then
                        gun.MaxBullets.Value = 9999
                    end
                    if gun:FindFirstChild("ReloadingSpeed") then
                        gun.ReloadingSpeed.Value = 0.02
                    end

                -- if GunDamageValues and GunDamageValues[gun.Name] then
                --     if not Script.Temp.originalDamageValues[gun.Name] then
                --         Script.Temp.originalDamageValues[gun.Name] = {}
                --         for part, dmg in pairs(GunDamageValues[gun.Name]) do
                --             Script.Temp.originalDamageValues[gun.Name][part] = dmg
                --         end
                --     end
                --     for part, _ in pairs(GunDamageValues[gun.Name]) do
                --         GunDamageValues[gun.Name][part] = 9999
                --     end
                -- end
                else
                    if Script.Temp.originalGunStats[gun.Name] then
                        for stat, val in pairs(Script.Temp.originalGunStats[gun.Name]) do
                            if gun:FindFirstChild(stat) then
                                gun[stat].Value = val
                            end
                        end
                    end
                    -- if GunDamageValues and GunDamageValues[gun.Name] and Script.Temp.originalDamageValues[gun.Name] then
                    --     for part, val in pairs(Script.Temp.originalDamageValues[gun.Name]) do
                    --         GunDamageValues[gun.Name][part] = val
                    --     end
                    -- end
                end
            end
        end,
    })
end
