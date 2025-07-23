return function(TabGroup, Script, Library)
    TabGroup:AddToggle("FOVToggle", {
        Text = "FOV",
        Default = false,
        Callback = function(Value)
            if Script.Tasks.FOVChangeTask then
                task.cancel(Script.Tasks.FOVChangeTask)
                Script.Tasks.FOVChangeTask = nil
            end
            if Value then
                Script.Temp.OldFOV = Script.camera and Script.camera.FieldOfView or 60
                Script.Tasks.FOVChangeTask = task.spawn(function()
                    while Library.Toggles.FOVToggle.Value and not Library.Unloaded do
                        task.wait()
                        if not Script.camera then
                            continue
                        end
                        Script.camera.FieldOfView = Library.Options.FOVSlider.Value
                    end
                end)
            end
        end,
    })

    TabGroup:AddSlider("FOVSlider", {
        Text = "FOV",
        Default = 60,
        Min = 10,
        Max = 120,
        Rounding = 1,
    })
end
