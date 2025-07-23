return function(TabGroup, Script, Library)
    local Players = Script.Services.Players
    local lplr = Players.LocalPlayer

    Script.AutoWin.Mingle = function()
        Library.Toggles.AutoMingleQTE.Callback(true)
        return function() end
    end

    Script.OnGame.Mingle = function()
        if Library.Toggles.AutoMingleQTE.Value then
            Library.Toggles.AutoMingleQTE.Callback(true)
        end
    end

    TabGroup:AddToggle("AutoMingleQTE", {
        Text = "Auto Mingle",
        Default = false,
        Callback = function(Value)
            if Script.Tasks.AutoMingleQTEThread then
                task.cancel(Script.Tasks.AutoMingleQTEThread)
                Script.Tasks.AutoMingleQTEThread = nil
            end
            if Script.Connections.AutoMingleConnDestroyer then
                Script.Connections.AutoMingleConnDestroyer:Disconnect()
                Script.Connections.AutoMingleConnDestroyer = nil
            end
            if not Value or Script.GameState ~= "Mingle" then
                return
            end
            Script.Tasks.AutoMingleQTEThread = task.spawn(function()
                local RemoteForQTE
                while Library.Toggles.AutoMingleQTE.Value and not Library.Unloaded do
                    if lplr.Character then
                        if not RemoteForQTE or not RemoteForQTE.Parent then
                            for _, obj in pairs(lplr.Character:GetChildren()) do
                                if obj:IsA("RemoteEvent") and obj.Name == "RemoteForQTE" then
                                    RemoteForQTE = obj
                                    break
                                end
                            end
                        end
                        pcall(function()
                            RemoteForQTE:FireServer()
                        end)
                    end
                    task.wait(0.5)
                end
                Script.Tasks.AutoMingleQTEThread = nil
            end)
            Script.Connections.AutoMingleConnDestroyer = Script.Functions.OnceOnGameChanged(function()
                Library.Toggles.AutoMingleQTE.Callback(false)
            end)
        end,
    })
end
