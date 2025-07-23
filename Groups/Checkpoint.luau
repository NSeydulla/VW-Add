return function(TabGroup, Script, Library)
    TabGroup:AddButton("Set checkpoint", function()
        local hum = Script.Functions.GetRootPart()
        if not hum then
            return
        end
        Script.Temp.Checkpoint = CFrame.new(hum.Position)
        Script.Functions.Alert("Checkpoint set!")
    end)

    TabGroup:AddButton("TP to checkpoint", function()
        local hum = Script.Functions.GetRootPart()
        if not hum then
            return
        end
        Script.Temp.BackCheckpoint = CFrame.new(hum.Position)
        Script.Functions.SafeTeleportToCFrame(Script.Temp.Checkpoint)
    end)

    TabGroup:AddButton("TP back", function()
        Script.Functions.SafeTeleportToCFrame(Script.Temp.BackCheckpoint)
    end)
end
