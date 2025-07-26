local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
Script.OnGame.HideAndSeek = function()
    if Library.Toggles.KeyESP.Value then
        Library.Toggles.KeyESP.Callback(true)
    end
    if Library.Toggles.DoorESP.Value then
        Library.Toggles.DoorESP.Callback(true)
    end
    if Library.Toggles.EscapeDoorESP.Value then
        Library.Toggles.EscapeDoorESP.Callback(true)
    end
    task.delay(1, function()
        for _, esp in pairs(Script.ESPTable["Player"]) do
            Script.Functions.ApplyHiderSeekerESP(esp)
        end
    end)
end

TabGroup:AddLabel("Hider"):AddColorPicker("HiderESPColor", {
    Default = Color3.fromRGB(0, 255, 0),
    Callback = function(Value)
        if Script.GameState ~= "HideAndSeek" then
            return
        end
        for _, esp in pairs(Script.ESPTable["Player"]) do
            if esp.Text:sub(-7) == "(Hider)" then
                esp.SetColor(Value)
            end
        end
    end,
})

TabGroup:AddLabel("Seeker"):AddColorPicker("SeekerESPColor", {
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        if Script.GameState ~= "HideAndSeek" then
            return
        end
        for _, esp in pairs(Script.ESPTable["Player"]) do
            if esp.Text:sub(-8) == "(Seeker)" then
                esp.SetColor(Value)
            end
        end
    end,
})
local function KeyESP(key)
    if string.find(key.Name, "DroppedKey") then
        Script.Functions.ESP({
            Object = key,
            Text = key.Name:gsub("DroppedKey", "") .. " key",
            Color = Library.Options.KeyESPColor.Value,
            Offset = Vector3.new(0, 1, 0),
            Type = "Key",
        })
    end
end
TabGroup:AddToggle("KeyESP", {
    Text = "Key",
    Default = false,
    Callback = function(Value)
        if Script.Connections.KeyESPDestroyer then
            Script.Connections.KeyESPDestroyer:Disconnect()
            Script.Connections.KeyESPDestroyer = nil
        end
        if Script.Connections.KeyESPDescendant then
            Script.Connections.KeyESPDescendant:Disconnect()
            Script.Connections.KeyESPDescendant = nil
        end
        if Value then
            if Script.GameState ~= "HideAndSeek" then
                return
            end
            local EffectsFolder = workspace:FindFirstChild("Effects")
            for _, key in pairs(EffectsFolder:GetChildren()) do
                KeyESP(key)
            end
            Script.Connections.KeyESPDescendant = EffectsFolder.DescendantAdded:Connect(function(descendant)
                KeyESP(descendant)
            end)
            Script.Connections.KeyESPDestroyer = Script.Functions.OnceOnGameChanged(function()
                Library.Toggles.KeyESP.Callback(false)
            end)
        else
            for _, esp in pairs(Script.ESPTable["Key"]) do
                esp.Destroy()
            end
        end
    end,
}):AddColorPicker("KeyESPColor", {
    Default = Color3.fromRGB(255, 255, 0),
    Callback = function(Value)
        for _, esp in pairs(Script.ESPTable["Key"]) do
            esp.SetColor(Value)
        end
    end,
})
local function DoorESP(door)
    if door.Name ~= "FullDoorAnimated" then
        return
    end
    local keyNeeded = door:GetAttribute("KeyNeeded")
    keyNeeded = keyNeeded and " (Key: " .. keyNeeded .. ")" or ""
    Script.Functions.ESP({
        Object = door,
        Text = "Door" .. keyNeeded,
        Color = Library.Options.DoorESPColor.Value,
        Offset = Vector3.new(0, 2, 0),
        Type = "Door",
    })
end
TabGroup:AddToggle("DoorESP", {
    Text = "Door",
    Default = false,
    Callback = function(Value)
        if Script.Connections.DoorESPDestroyer then
            Script.Connections.DoorESPDestroyer:Disconnect()
            Script.Connections.DoorESPDestroyer = nil
        end
        if Script.Connections.DoorESPDescendant then
            Script.Connections.DoorESPDescendant:Disconnect()
            Script.Connections.DoorESPDescendant = nil
        end
        if Value then
            if Script.GameState ~= "HideAndSeek" then
                return
            end
            local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")
            if not hideAndSeekMap then
                Script.Functions.Alert("Hide And Seek map not found!")
                return
            end
            local newFixedDoors = hideAndSeekMap:FindFirstChild("NEWFIXEDDOORS")
            for _, floor in pairs(newFixedDoors and newFixedDoors:GetChildren() or {}) do
                for _, door in pairs(floor:GetChildren()) do
                    DoorESP(door)
                end
            end
            Script.Connections.DoorESPDescendant = newFixedDoors.DescendantAdded:Connect(function(descendant)
                DoorESP(descendant)
            end)
            Script.Connections.DoorESPDestroyer = Script.Functions.OnceOnGameChanged(function()
                Library.Toggles.DoorESP.Callback(false)
            end)
        else
            for _, esp in pairs(Script.ESPTable["Door"]) do
                esp.Destroy()
            end
        end
    end,
}):AddColorPicker("DoorESPColor", {
    Default = Color3.fromRGB(0, 128, 255),
    Callback = function(Value)
        for _, esp in pairs(Script.ESPTable["Door"]) do
            esp.SetColor(Value)
        end
    end,
})
local function EscapeDoorESP(door)
    if not door:FindFirstChild("IgnoreBorders") then
        Script.Functions.ESP({
            Object = door,
            Text = "Escape Door",
            Color = Library.Options.EscapeDoorESPColor.Value,
            Offset = Vector3.new(0, 2, 0),
            Type = "Escape Door",
        })
    end
end
TabGroup:AddToggle("EscapeDoorESP", {
    Text = "EscapeDoor",
    Default = false,
    Callback = function(Value)
        if Script.Connections.EscapeDoorESPDestroyer then
            Script.Connections.EscapeDoorESPDestroyer:Disconnect()
            Script.Connections.EscapeDoorESPDestroyer = nil
        end
        if Script.Connections.EscapeDoorESPDescendant then
            Script.Connections.EscapeDoorESPDescendant:Disconnect()
            Script.Connections.EscapeDoorESPDescendant = nil
        end
        if Value then
            if Script.GameState ~= "HideAndSeek" then
                return
            end
            local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")
            if not hideAndSeekMap then
                Script.Functions.Alert("Hide And Seek map not found!")
                return
            end
            local newFixedDoors = hideAndSeekMap:FindFirstChild("NEWFIXEDDOORS")
            for _, floor in pairs(newFixedDoors and newFixedDoors:GetChildren() or {}) do
                for _, group in pairs(floor:GetChildren()) do
                    if group.Name == "EXITDOORS" then
                        for _, door in pairs(group:GetChildren()) do
                            EscapeDoorESP(door)
                        end
                    end
                end
            end
            Script.Connections.EscapeDoorESPDescendant = newFixedDoors.DescendantAdded:Connect(function(descendant)
                if descendant.Name == "EXITDOOR" then
                    EscapeDoorESP(descendant)
                end
            end)
            Script.Connections.EscapeDoorESPDestroyer = Script.Functions.OnceOnGameChanged(function()
                Library.Toggles.EscapeDoorESP.Callback(false)
            end)
        else
            for _, esp in pairs(Script.ESPTable["Escape Door"]) do
                esp.Destroy()
            end
        end
    end,
}):AddColorPicker("EscapeDoorESPColor", {
    Default = Color3.fromRGB(255, 0, 255),
    Callback = function(Value)
        for _, esp in pairs(Script.ESPTable["Escape Door"]) do
            esp.SetColor(Value)
        end
    end,
})
