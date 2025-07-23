return function(TabGroup, Script, Library)
    local Players = Script.Services.Players
    local lplr = Players.LocalPlayer

    TabGroup:AddToggle("AntiRagdoll", {
        Text = "Anti Ragdoll",
        Default = false,
        Callback = function(Value)
            if Script.Tasks.RagdollBlockConn then
                Script.Tasks.RagdollBlockConn:Disconnect()
                Script.Tasks.RagdollBlockConn = nil
            end
            local Character = lplr.Character
            if not Character then
                return
            end
            local Humanoid = Character:FindFirstChild("Humanoid")
            local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
            if not (Humanoid and HumanoidRootPart) then
                return
            end
            for _, child in ipairs(Character:GetChildren()) do
                if child.Name == "Ragdoll" then
                    task.delay(0.01, function()
                        pcall(function()
                            child:Destroy()
                        end)
                    end)
                end
            end
            pcall(function()
                Humanoid.PlatformStand = false
                Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            end)
            if not Value then
                return
            end
            Script.Tasks.RagdollBlockConn = Character.ChildAdded:Connect(function(child)
                if child.Name == "Ragdoll" then
                    pcall(function()
                        child:Destroy()
                    end)
                    pcall(function()
                        Humanoid.PlatformStand = false
                        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
                        Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                    end)
                end
            end)
        end,
    })

    TabGroup:AddButton("Fix Camera", function()
        if Script.Camera then
            Script.Camera.CameraType = Enum.CameraType.Custom
            if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
                Script.Camera.CameraSubject = lplr.Character:FindFirstChild("Humanoid")
            end
        end
    end)

    TabGroup:AddButton("Reset Camera \n [Might Break camera!]", function()
        if workspace.CurrentCamera then
            pcall(function()
                workspace.CurrentCamera:Destroy()
            end)
        end
        local new = Instance.new("Camera")
        new.Parent = workspace
        workspace.CurrentCamera = new
        new.CameraType = Enum.CameraType.Custom
        new.CameraSubject = lplr.Character.Humanoid
    end)

    TabGroup:AddButton("Skip Cutscene", function()
        if Script.Camera then
            Script.Camera.CameraType = Enum.CameraType.Custom
            if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
                Script.Camera.CameraSubject = lplr.Character:FindFirstChild("Humanoid")
            end
        end
    end)

    TabGroup:AddToggle("TeleportToSafePlace", {
        Text = "Teleport To Safe Place",
        Default = false,
        Callback = function(Value)
            if Value then
                Script.Functions.Alert("Teleported to Safe Place, disable to go back", 3)
                Script.Functions.TeleportToSafe()
            else
                Script.Functions.Alert("Teleported back from Safe Place", 3)
                Script.Functions.TeleportBackFromSafe()
            end
        end,
    }):AddKeyPicker("TTSPKey", {
        Mode = "Toggle",
        Default = "L",
        Text = "Teleport To Safe Place",
        SyncToggleState = true,
    })

    TabGroup:AddButton("Fix Players Visibility", Script.Functions.CheckPlayersVisibility)
end
