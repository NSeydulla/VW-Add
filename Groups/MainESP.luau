return function(TabGroup, Script, Library)
    local Players = Script.Services.Players
    local lplr = Players.LocalPlayer

    local function PlayerESP(player: Player)
        if
            not (
                player.Character
                and player.Character.PrimaryPart
                and player.Character:FindFirstChild("Humanoid")
                and player.Character.Humanoid.Health > 0
            )
        then
            return
        end

        local playerESP = Script.Functions.ESP({
            Type = "Player",
            Object = player.Character,
            Text = string.format("%s [%s]", player.DisplayName, math.ceil(player.Character.Humanoid.Health)),
            TextParent = player.Character.PrimaryPart,
            Offset = Vector3.new(0, 1, 0),
            Color = Library.Options.PlayerESPColor.Value,
        })

        playerESP.GiveSignal(player.Character.Humanoid.HealthChanged:Connect(function(newHealth)
            if newHealth > 0 then
                playerESP.Text = string.format("%s [%s]", player.DisplayName, math.ceil(newHealth))
            else
                playerESP.Destroy()
            end
        end))
    end

    TabGroup:AddToggle("PlayerESP", {
        Text = "Player",
        Default = false,
        Callback = function(Value)
            if Value then
                for _, player in pairs(Players:GetPlayers()) do
                    if player == lplr then
                        continue
                    end
                    PlayerESP(player)
                end
            else
                for _, esp in pairs(Script.ESPTable["Player"]) do
                    esp.Destroy()
                end
            end
        end,
    }):AddColorPicker("PlayerESPColor", {
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            for _, esp in pairs(Script.ESPTable["Player"]) do
                esp.SetColor(Value)
            end
        end,
    })

    local function SetupPlayerConnection(player: Player)
        if player == lplr then
            return
        end
        if player.Character then
            if Library.Toggles.PlayerESP.Value then
                PlayerESP(player)
            end
        end

        Script.Connections.PlayerCharAdded[player.Name] = player.CharacterAdded:Connect(function(newCharacter)
            task.delay(0.1, function()
                if Library.Toggles.PlayerESP.Value then
                    PlayerESP(player)
                end
            end)
        end)
    end

    for _, player in pairs(Players:GetPlayers()) do
        SetupPlayerConnection(player)
    end
    Script.Connections.PlayerAdded = Players.PlayerAdded:Connect(SetupPlayerConnection)

    local function GuardESP(character)
        if character then
            task.spawn(function()
                if not character:WaitForChild("Humanoid", 5) then
                    Script.Functions.Alert("Guard finded, but Humanoid child not")
                else
                    local guardESP = Script.Functions.ESP({
                        Object = character,
                        Text = ".",
                        Color = Library.Options.GuardESPColor.Value,
                        Offset = Vector3.new(0, 4, 0),
                        Type = "Guard",
                    })
                    guardESP.GiveSignal(character.ChildAdded:Connect(function(v)
                        if v.Name == "Dead" and v.ClassName == "Folder" then
                            guardESP.Destroy()
                        end
                    end))
                end
            end)
        end
    end

    TabGroup:AddToggle("GuardESP", {
        Text = "Guard",
        Default = false,
        Callback = function(Value)
            if Script.Connections.GuardAddedConnection then
                Script.Connections.GuardAddedConnection:Disconnect()
                Script.Connections.GuardAddedConnection = nil
            end
            if Value then
                local live = workspace:FindFirstChild("Live")
                if not live then
                    return
                end
                Script.Connections.GuardAddedConnection = live.ChildAdded:Connect(function(v)
                    if Script.Functions.IsGuard(v) then
                        GuardESP(v)
                    end
                end)
                for _, child in pairs(live:GetChildren()) do
                    if Script.Functions.IsGuard(child) then
                        if child:FindFirstChild("Dead") then
                            continue
                        end
                        GuardESP(child)
                    end
                end
            else
                for _, esp in pairs(Script.ESPTable["Guard"]) do
                    esp.Destroy()
                end
            end
        end,
    }):AddColorPicker("GuardESPColor", {
        Default = Color3.fromRGB(200, 100, 200),
        Callback = function(Value)
            for _, esp in pairs(Script.ESPTable["Guard"]) do
                esp.SetColor(Value)
            end
        end,
    })
end
