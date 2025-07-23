return function(TabGroup, Script, Library)
    local ReplicatedStorage = Script.Services.ReplicatedStorage

    Script.AutoWin.TugOfWar = function()
        Library.Toggles.AutoPull.Callback(true)
        return function() end
    end

    Script.OnGame.TugOfWar = function()
        if Library.Toggles.AutoPull.Value then
            Library.Toggles.AutoPull.Callback(true)
        end
    end

    TabGroup:AddToggle("AutoPull", {
        Text = "Auto Pull",
        Default = false,
        Callback = function(Value)
            if Script.Tasks.AutoPullTask then
                task.cancel(Script.Tasks.AutoPullTask)
                Script.Tasks.AutoPullTask = nil
            end
            if Script.Connections.TugOfWarConnDestroyer then
                Script.Connections.TugOfWarConnDestroyer:Disconnect()
                Script.Connections.TugOfWarConnDestroyer = nil
            end
            if not Value or Script.GameState ~= "TugOfWar" then
                return
            end
            Script.Tasks.AutoPullTask = task.spawn(function()
                repeat
                    ReplicatedStorage:WaitForChild("Remotes")
                        :WaitForChild("TemporaryReachedBindable")
                        :FireServer(unpack({ { GameQTE = true } }))
                    task.wait(Library.Options.AutoPullDelay.Value)
                until not Library.Toggles.AutoPull.Value or Library.Unloaded
                Script.Tasks.AutoPullTask = nil
            end)
            Script.Connections.TugOfWarConnDestroyer = Script.Functions.OnceOnGameChanged(function()
                Library.Toggles.AutoPull.Callback(false)
                Script.Functions.Alert("TugOfWar Auto Pull task ended")
            end)
            Script.Functions.Alert("TugOfWar Auto Pull task started")
        end,
    })

    TabGroup:AddSlider("AutoPullDelay", {
        Text = "Auto Pull Delay",
        Default = 0.2,
        Min = 0,
        Max = 1.5,
        Rounding = 2,
    })
end
