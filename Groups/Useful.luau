local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

TabGroup:AddToggle("AutoSkipDialog", {
    Text = "Auto Skip Dialogue",
    Default = false,
    Callback = function(Value)
        if Script.Temp.AutoSkipDialogLoop then
            task.cancel(Script.Temp.AutoSkipDialogLoop)
            Script.Temp.AutoSkipDialogLoop = nil
        end
        if Value then
            Script.Temp.AutoSkipDialogLoop = task.spawn(function()
                local PlayerGui = lplr:FindFirstChild("PlayerGui")
                local DialogueFrameAnnouncement = PlayerGui
                    and PlayerGui:FindFirstChild("DialogueGUI")
                    and PlayerGui.DialogueGUI:FindFirstChild("DialogueFrameAnnouncement")
                while Library.Toggles.AutoSkipDialog.Value and not Library.Unloaded do
                    if
                        lplr:GetAttribute("_DialogueOpen")
                        or (DialogueFrameAnnouncement and DialogueFrameAnnouncement.Visible)
                    then
                        ReplicatedStorage:WaitForChild("Remotes")
                            :WaitForChild("DialogueRemote")
                            :FireServer(unpack({ "Skipped" }))
                    end
                    task.wait(1)
                end
            end)
        end
    end,
})

TabGroup:AddToggle("FullbrightToggle", {
    Text = "Fullbright",
    Default = false,
    Callback = function(enabled)
        Script.Temp.FullbrightSettings = Script.Temp.FullbrightSettings or {}
        Script.Temp.FullbrightConn = Script.Temp.FullbrightConn or nil
        if enabled then
            local settings = Script.Temp.FullbrightSettings
            settings.Brightness = Lighting.Brightness
            settings.ClockTime = Lighting.ClockTime
            settings.FogEnd = Lighting.FogEnd
            settings.GlobalShadows = Lighting.GlobalShadows
            settings.OutdoorAmbient = Lighting.OutdoorAmbient
            settings.Ambient = Lighting.Ambient
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            if Script.Temp.FullbrightConn then
                Script.Temp.FullbrightConn:Disconnect()
            end
            Script.Temp.FullbrightConn = Lighting.Changed:Connect(function()
                if not Library.Toggles.FullbrightToggle.Value then
                    return
                end
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
                Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
                Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            end)
        else
            local settings = Script.Temp.FullbrightSettings or {}
            for k, v in pairs(settings) do
                Lighting[k] = v
            end
            if Script.Temp.FullbrightConn then
                Script.Temp.FullbrightConn:Disconnect()
                Script.Temp.FullbrightConn = nil
            end
        end
    end,
})
