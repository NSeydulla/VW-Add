local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
TabGroup:AddToggle("FOVToggle", {
    Text = "FOV",
    Default = false,
    Callback = function(Value)
        if Script.Tasks.FOVChangeTask then
            task.cancel(Script.Tasks.FOVChangeTask)
            Script.Tasks.FOVChangeTask = nil
        end
        if Value then
            Script.Temp.OldFOV = Script.Camera and Script.Camera.FieldOfView or 60
            Script.Tasks.FOVChangeTask = task.spawn(function()
                while Library.Toggles.FOVToggle.Value and not Library.Unloaded do
                    task.wait()
                    if not Script.Camera then
                        continue
                    end
                    Script.Camera.FieldOfView = Library.Options.FOVSlider.Value :: number
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
