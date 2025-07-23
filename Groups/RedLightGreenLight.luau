return function(TabGroup, Script, Library)
    local Players = Script.Services.Players
    local lplr = Players.LocalPlayer
    local ReplicatedStorage = Script.Services.ReplicatedStorage

    local function WinRLGL()
        if not lplr.Character then
            return
        end
        Script.Functions.SafeTeleport(-100.8, 1028, 115)
    end

    Script.AutoWin.RedLightGreenLight = function()
        local AutoWinRLGL = true
        if Script.Tasks.AutoWinRLGLTask then
            task.cancel(Script.Tasks.AutoWinRLGLTask)
            Script.Tasks.AutoWinRLGLTask = nil
        end
        Script.Tasks.AutoWinRLGLTask = task.spawn(function()
            repeat
                WinRLGL()
                task.wait(3)
            until not AutoWinRLGL
                or not Library.Toggles.InkGameAutowin.Value
                or Script.GameState ~= "RedLightGreenLight"
        end)
        return function()
            AutoWinRLGL = false
        end
    end

    local function FindCarryPrompt(plr)
        if not plr.Character then
            return false
        end
        if not plr.Character:FindFirstChild("HumanoidRootPart") then
            return false
        end
        if not (plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Humanoid").Health > 0) then
            return false
        end

        local CarryPrompt = plr.Character.HumanoidRootPart:FindFirstChild("CarryPrompt")
        return CarryPrompt
    end

    local function GetAllInjuredPlayers()
        local injured = {}
        for _, plr in pairs(Players:GetPlayers()) do
            if plr == lplr then
                continue
            end
            if plr:GetAttribute("IsDead") then
                continue
            end
            local CarryPrompt = FindCarryPrompt(plr)
            if not CarryPrompt then
                continue
            end
            if plr.Character and plr.Character:FindFirstChild("SafeRedLightGreenLight") then
                continue
            end
            if plr.Character and plr.Character:FindFirstChild("IsBeingHeld") then
                continue
            end
            table.insert(injured, { player = plr, carryPrompt = CarryPrompt })
        end
        return injured
    end

    Script.OnGame.RedLightGreenLight = function()
        if Library.Toggles.RedLightGodmode.Value then
            Library.Toggles.RedLightGodmode.Callback(true)
        end
        Script.Tasks.RLGLDropdownRefresh = task.spawn(function()
            repeat
                local injured = GetAllInjuredPlayers()
                local names = {}
                for _, entry in ipairs(injured) do
                    table.insert(names, entry.player.DisplayName)
                end
                Library.Options.RLGLInjuredPlayer:SetValues(names)
                task.wait(3)
            until Library.Unloaded
        end)
        Script.Connections.RLGLInjuredTableRefresh = Script.Functions.OnceOnGameChanged(function()
            task.cancel(Script.Tasks.RLGLDropdownRefresh)
            Library.Options.RLGLInjuredPlayer:SetValues({})
            Library.Options.RLGLInjuredPlayer:SetValue(nil)
        end)
    end

    TabGroup:AddToggle("RedLightGodmode", {
        Text = "Godmode",
        Default = false,
        Callback = function(Value)
            if Script.Connections.RLGLConnDestroyer then
                pcall(function()
                    Script.Connections.RLGLConnDestroyer:Disconnect()
                end)
                Script.Connections.RLGLConnDestroyer = nil
            end
            if Script.Connections.RLGL_Connection then
                pcall(function()
                    Script.Connections.RLGL_Connection:Disconnect()
                end)
                Script.Connections.RLGL_Connection = nil
            end
            Script.HookMethods.RLGLGodmode = nil
            if not Value then
                Script.Functions.Alert("Red Light Green Light Godmode Disabled", 3)
                return
            end
            if not hookmetamethod then
                Script.Functions.Alert("Your executor doesn't support this :(")
                Library.Toggles.RedLightGodMode:SetValue(false)
                return
            end
            if Script.GameState ~= "RedLightGreenLight" then
                return
            end
            local TrafficLightImage = lplr.PlayerGui:FindFirstChild("ImpactFrames")
                and lplr.PlayerGui.ImpactFrames:FindFirstChild("TrafficLightEmpty")
            local lastRootPartCFrame = nil
            local root = Script.Functions.GetRootPart()
            if root then
                lastRootPartCFrame = root.CFrame
            end
            local isGreenLight = true
            if
                TrafficLightImage
                and ReplicatedStorage:FindFirstChild("Effects")
                and ReplicatedStorage.Effects:FindFirstChild("Images")
                and ReplicatedStorage.Effects.Images:FindFirstChild("TrafficLights")
                and ReplicatedStorage.Effects.Images.TrafficLights:FindFirstChild("GreenLight")
            then
                isGreenLight = TrafficLightImage.Image
                    == ReplicatedStorage.Effects.Images.TrafficLights.GreenLight.Image
            end
            Script.Connections.RLGL_Connection = ReplicatedStorage.Remotes.Effects.OnClientEvent:Connect(
                function(EffectsData)
                    if EffectsData.EffectName ~= "TrafficLight" then
                        return
                    end
                    isGreenLight = EffectsData.GreenLight == true
                    local root = Script.Functions.GetRootPart()
                    if root then
                        lastRootPartCFrame = root.CFrame
                    end
                end
            )
            Script.HookMethods.RLGLGodmode = function(self, method, args)
                if self == "rootCFrame" and method == "FireServer" then
                    if not isGreenLight and lastRootPartCFrame then
                        args[1] = lastRootPartCFrame
                    end
                end
                return args
            end
            Script.Connections["RLGLConnDestroyer"] = Script.Functions.OnceOnGameChanged(function()
                Library.Toggles.RedLightGodmode.Callback(false)
            end)
            Script.Functions.Alert("Red Light Green Light Godmode Enabled", 3)
        end,
    })

    TabGroup:AddButton("Complete Red Light / Green Light", function()
        if Script.GameState ~= "RedLightGreenLight" then
            Script.Functions.Alert("Game not running")
            return
        end
        WinRLGL()
    end)

    TabGroup:AddButton("Remove Injured Walking", function()
        if Script.GameState ~= "RedLightGreenLight" then
            Script.Functions.Alert("Game not running")
            return
        end
        Library.Toggles.AntiRagdoll.Callback(false)
    end)

    TabGroup:AddButton("Bring Random Injured Player", function()
        if Script.GameState ~= "RedLightGreenLight" then
            Script.Functions.Alert("Game not running")
            return
        end
        local injured = GetAllInjuredPlayers()[1]
        if not injured then
            Script.Functions.Alert("No injured player found!", 2)
            return
        end
        if lplr.Character and injured.player.Character and injured.player.Character.PrimaryPart then
            Script.Functions.SafeTeleportToCFrame(injured.player.Character:GetPrimaryPartCFrame())
            task.wait(0.2)
            local CarryPrompt = FindCarryPrompt(injured.player)
            if CarryPrompt then
                pcall(function()
                    CarryPrompt.HoldDuration = 0
                    CarryPrompt:InputHoldBegin()
                end)
            end
            task.wait(0.2)
            WinRLGL()
            task.wait(0.2)
            ReplicatedStorage:WaitForChild("Remotes")
                :WaitForChild("ClickedButton")
                :FireServer(unpack({ { tryingtoleave = true } }))
            task.wait(0.2)
        end
    end)

    TabGroup:AddDropdown("RLGLInjuredPlayer", {
        Text = "Bring Injured Player",
        Values = {},
        AllowNull = true,
        Callback = function(val)
            if not val then
                return
            end
            local injured = GetAllInjuredPlayers()
            local selected = nil
            for _, entry in ipairs(injured) do
                if entry.player.DisplayName == val then
                    selected = entry
                    break
                end
            end
            if not selected then
                Script.Functions.Alert("No injured player found!", 2)
                return
            end
            if lplr.Character and selected.player.Character and selected.player.Character.PrimaryPart then
                if Library.Toggles.RedLightGodmode.Value then
                    Library.Toggles.RedLightGodmode:SetValue(false)
                end
                Script.Functions.SafeTeleportToCFrame(selected.player.Character:GetPrimaryPartCFrame())
                task.wait(0.2)
                local CarryPrompt = FindCarryPrompt(selected.player)
                if CarryPrompt then
                    pcall(function()
                        CarryPrompt.HoldDuration = 0
                        CarryPrompt:InputHoldBegin()
                    end)
                end
                task.wait(0.2)
                WinRLGL()
                task.wait(0.2)
                ReplicatedStorage:WaitForChild("Remotes")
                    :WaitForChild("ClickedButton")
                    :FireServer(unpack({ { tryingtoleave = true } }))
                task.wait(0.2)
            end
        end,
    })
end
