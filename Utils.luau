return function(Script, Library)
    local RunService = Script.Services.RunService
    local Players = Script.Services.Players
    local lplr = Players.LocalPlayer

    Script.Temp.OriginalNameCall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = { ... }
        local method = getnamecallmethod()

        for _, func in pairs(Script.HookMethods) do
            args = func(tostring(self), method, args)
            if not args then
                return
            end
        end

        return Script.Temp.OriginalNameCall(self, unpack(args))
    end)

    Script.Temp.SafePlace = CFrame.new(Vector3.new(-108, 331, 462.1))

    return {
        OnGameStateChange = function()
            Script.GameState = workspace.Values.CurrentGame.Value

            if Script.GameState then
                Script.GameState = tostring(Script.GameState)
            end

            if Library.Toggles.InkGameAutowin.Value then
                Script.Functions.HandleAutowin()
            end

            if Script.OnGame[Script.GameState] then
                Script.OnGame[Script.GameState]()
            end
        end,

        OnLoad = function()
            pcall(Script.Functions.OnGameStateChange)
            Script.Connections.OnGameStateChange = workspace
                :WaitForChild("Values")
                :WaitForChild("CurrentGame")
                :GetPropertyChangedSignal("Value")
                :Connect(Script.Functions.OnGameStateChange)
            Library:GiveSignal(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
                if workspace.CurrentCamera then
                    Script.Camera = workspace.CurrentCamera
                end
            end))
            Script.SaveManager:LoadAutoloadConfig()
        end,

        OnUnload = function()
            hookmetamethod(game, "__namecall", Script.Temp.OriginalNameCall)
            if Library._signals then
                for _, v in pairs(Library._signals) do
                    pcall(function()
                        v:Disconnect()
                    end)
                end
            end
            for _, conn in pairs(Script.Connections) do
                if type(conn) == "table" then
                    for _, conn2 in pairs(conn) do
                        pcall(function()
                            conn2:Disconnect()
                        end)
                    end
                else
                    pcall(function()
                        conn:Disconnect()
                    end)
                end
            end
            for _, task in pairs(Script.Tasks) do
                pcall(function()
                    task.cancel(task)
                end)
            end
            for _, temp in pairs(Script.Temp) do
                pcall(function()
                    if temp.Disconnect then
                        temp:Disconnect()
                    elseif temp.Destroy then
                        temp:Destroy()
                    elseif typeof(temp) == "thread" then
                        task.cancel(temp)
                    end
                end)
            end
            for _, espType in pairs(Script.ESPTable) do
                for _, esp in pairs(espType) do
                    pcall(esp.Destroy)
                end
            end
            Library.Unloaded = true
            getgenv().shared.Voidware_InkGame_Library = nil
        end,

        OnceOnGameChanged = function(func)
            return workspace
                :WaitForChild("Values")
                :WaitForChild("CurrentGame")
                :GetPropertyChangedSignal("Value")
                :Once(func)
        end,

        SafeRequire = function(module)
            if Script.Temp[tostring(module)] then
                return Script.Temp[tostring(module)]
            end
            local suc, err = pcall(function()
                return require(module)
            end)
            if not suc then
                Script.Functions.Alert(
                    "[SafeRequire]: Failure loading " .. tostring(module) .. " (" .. tostring(err) .. ")"
                )
            else
                Script.Temp[tostring(module)] = err
            end
            return suc and err
        end,

        HandleAutowin = function()
            if Script.Temp.lastCleanupFunction then
                pcall(Script.Temp.lastCleanupFunction)
                Script.Temp.lastCleanupFunction = nil
            end

            if Script.AutoWin[Script.GameState] then
                Script.Functions.Alert("[Autowin]: Running on " .. tostring(Script.GameState))
                Script.Temp.lastCleanupFunction = Script.AutoWin[Script.GameState]()
            else
                Script.Functions.Alert("[Autowin]: Waiting for the next game...")
            end
        end,

        Alert = function(message: string, time_obj: number): nil
            Library:Notify(message, time_obj or 5)

            local sound = Instance.new("Sound", workspace)
            sound.SoundId = "rbxassetid://4590662766"
            sound.Volume = 2
            sound.PlayOnRemove = true
            sound:Destroy()
        end,

        CheckPlayersVisibility = function()
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "BoneCustom" then
                            if part.Transparency >= 0.99 or part.LocalTransparencyModifier >= 0.99 then
                                part.Transparency = 0
                                part.LocalTransparencyModifier = 0
                            end
                        end
                    end

                    pcall(function()
                        player.Character.HumanoidRootPart.Transparency = 1
                    end)
                    pcall(function()
                        player.Character.Head.BoneCustom.Transparency = 1
                    end)

                    for _, item in pairs(player.Character:GetChildren()) do
                        if item:IsA("Accessory") or item:IsA("Clothing") then
                            if item:IsA("Accessory") then
                                local handle = item:FindFirstChild("Handle")
                                if handle and handle.Transparency >= 0.99 then
                                    handle.Transparency = 0
                                end
                            end
                        end
                    end
                end
            end
        end,

        IsGuard = function(model)
            if
                string.find(model.Name, "Rebel")
                or string.find(model.Name, "HallwayGuard")
                or string.find(string.lower(model.Name), "aggro")
            then
                return true
            end
            return false
        end,

        ApplyHiderSeekerESP = function(esp)
            if esp.Connections.HASPlayerConn then
                esp.Connections.HASPlayerConn:Disconnect()
            end
            if esp.Object:FindFirstChild("BlueVest") then
                esp.Connections.HASPlayerConn = Script.Functions.OnceOnGameChanged(function()
                    esp.SetColor(Library.Options["PlayerESPColor"].Value)
                    esp.Text = esp.Text:gsub("%(Hider%)", "")
                end)
                esp.SetColor(Library.Options["HiderESPColor"].Value)
                esp.Text = esp.Text .. "(Hider)"
            end
            if not esp.Object:FindFirstChild("BlueVest") then
                esp.Connections.HASPlayerConn = Script.Functions.OnceOnGameChanged(function()
                    esp.SetColor(Library.Options["PlayerESPColor"].Value)
                    esp.Text = esp.Text:gsub("%(Seeker%)", "")
                end)
                esp.SetColor(Library.Options["SeekerESPColor"].Value)
                esp.Text = esp.Text .. "(Seeker)"
            end
        end,

        GetRootPart = function()
            if not lplr.Character then
                Script.Functions.Alert("Character not found! try again")
                return
            end
            local hum = lplr.Character:WaitForChild("HumanoidRootPart", 1)
            if not hum then
                Script.Functions.Alert("Humanoid part not found! try again")
            end
            return hum
        end,

        SafeTeleport = function(x: number, y: number, z: number)
            Script.Functions.SafeTeleportToCFrame(CFrame.new(Vector3.new(x, y, z)))
        end,

        SafeTeleportToCFrame = function(cframe: CFrame)
            if not lplr.Character then
                Script.Functions.Alert("Character not found! try again")
                return
            end
            local Value = Library.Toggles.AntiFlingToggle.Value
            if Value then
                Library.Toggles.AntiFlingToggle:SetValue(false)
            end
            lplr.Character:PivotTo(cframe)
            if Value then
                Library.Toggles.AntiFlingToggle:SetValue(true)
            end
        end,

        TeleportToSafe = function()
            local hum = Script.Functions.GetRootPart()
            if not hum then
                return
            end
            Script.Temp.OldLocation = CFrame.new(hum.Position)
            Script.Functions.SafeTeleportToCFrame(Script.Temp.SafePlace)
        end,

        ESP = function(args: ESP)
            if not args.Object then
                return Script.Functions.Alert("ESP Object is nil")
            end

            local ESPManager = {
                Object = args.Object,
                Text = args.Text or "No Text",
                TextParent = args.TextParent,
                Color = args.Color or Color3.new(),
                Offset = args.Offset or Vector3.zero,
                Type = args.Type or "None",

                Highlights = {},
                Humanoid = nil,

                Connections = {},
            }

            local tableIndex = #Script.ESPTable[ESPManager.Type] + 1

            local Highlight = function(part)
                local highlight = Instance.new("BoxHandleAdornment")
                highlight.Adornee = part
                highlight.AlwaysOnTop = true
                highlight.ZIndex = 5
                highlight.Size = part.Size
                highlight.Color3 = ESPManager.Color
                highlight.Transparency = Library.Options.ESPTransparency.Value
                highlight.Parent = part
                table.insert(ESPManager.Highlights, highlight)
            end
            if ESPManager.Object:IsA("BasePart") then
                Highlight(ESPManager.Object)
            end
            for _, part in ipairs(ESPManager.Object:GetChildren()) do
                if part:IsA("BasePart") or part:IsA("Attachment") then
                    Highlight(part)
                end
            end

            local billboardGui = Instance.new("BillboardGui")
            do
                billboardGui.Adornee = ESPManager.TextParent or ESPManager.Object
                billboardGui.AlwaysOnTop = true
                billboardGui.ClipsDescendants = false
                billboardGui.Size = UDim2.new(0, 1, 0, 1)
                billboardGui.StudsOffset = ESPManager.Offset
                billboardGui.Parent = ESPManager.TextParent or ESPManager.Object
            end

            local textLabel = Instance.new("TextLabel")
            do
                textLabel.BackgroundTransparency = 1
                textLabel.Font = Enum.Font.Oswald
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.Text = ESPManager.Text
                textLabel.TextColor3 = ESPManager.Color
                textLabel.TextSize = Library.Options.ESPTextSize.Value
                textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                textLabel.TextStrokeTransparency = 0.75
                textLabel.Parent = billboardGui
            end

            function ESPManager.SetColor(newColor: Color3)
                ESPManager.Color = newColor

                for _, highlight in pairs(ESPManager.Highlights) do
                    highlight.Color3 = newColor
                end

                textLabel.TextColor3 = newColor
            end

            function ESPManager.Destroy()
                for _, conn in pairs(ESPManager.Connections) do
                    pcall(function()
                        conn:Disconnect()
                    end)
                end

                for _, highlight in pairs(ESPManager.Highlights) do
                    highlight:Destroy()
                end
                if billboardGui then
                    billboardGui:Destroy()
                end

                if Script.ESPTable[ESPManager.Type][tableIndex] then
                    Script.ESPTable[ESPManager.Type][tableIndex] = nil
                end
            end

            function ESPManager.GiveSignal(signal)
                table.insert(ESPManager.Connections, signal)
            end

            ESPManager.GiveSignal(RunService.RenderStepped:Connect(function()
                if not ESPManager.Object or not ESPManager.Object:IsDescendantOf(workspace) then
                    ESPManager.Destroy()
                    return
                end

                textLabel.TextSize = Library.Options.ESPTextSize.Value

                if Library.Toggles.ESPDistance.Value then
                    textLabel.Text = string.format(
                        "%s\n[%s]",
                        ESPManager.Text,
                        math.floor((Script.Camera.CFrame.Position - ESPManager.Object:GetPivot().Position).Magnitude)
                    )
                else
                    textLabel.Text = ESPManager.Text
                end
            end))

            if ESPManager.Type == "Player" and Script.GameState == "HideAndSeek" then
                Script.Functions.ApplyHiderSeekerESP(ESPManager)
            end

            Script.ESPTable[ESPManager.Type][tableIndex] = ESPManager
            return ESPManager
        end,
    }
end
