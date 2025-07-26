local TabGroup: ObsidianGroupBox, Script: ScriptType, _: Obsidian = ...
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer

TabGroup:AddToggle("AntiRagdoll", {
    Text = "Anti Ragdoll",
    Default = false,
    Callback = function(Value)
        if Script.Connections.RagdollBlockConn then
            Script.Connections.RagdollBlockConn:Disconnect()
            Script.Connections.RagdollBlockConn = nil
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
                pcall(function()
                    child:Destroy()
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

        for _, folderName in pairs({ "Stun", "RotateDisabled", "RagdollWakeupImmunity", "InjuredWalking" }) do
            local folder = Character:FindFirstChild(folderName)
            if folder then
                folder:Destroy()
            end
        end

        for _, obj in pairs(HumanoidRootPart:GetChildren()) do
            if obj:IsA("BallSocketConstraint") or obj.Name:match("^CacheAttachment") then
                obj:Destroy()
            end
        end
        -- local Torso = Character:FindFirstChild("Torso")
        -- local joints = { "Left Hip", "Left Shoulder", "Neck", "Right Hip", "Right Shoulder" }
        -- for _, jointName in pairs(joints) do
        --     local motor = Torso:FindFirstChild(jointName)
        --     if motor and motor:IsA("Motor6D") and not motor.Part0 then
        --         motor.Part0 = Torso
        --     end
        -- end
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") and part:FindFirstChild("BoneCustom") then
                part.BoneCustom:Destroy()
            end
        end
        if not Value then
            return
        end
        Script.Connections.RagdollBlockConn = Character.ChildAdded:Connect(function(child)
            if child.Name == "Ragdoll" then
                task.delay(0.1, function()
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
local function TeleportBackFromSafe()
    local OldLocation = Script.Temp.OldLocation
    if not OldLocation then
        Script.Functions.Alert("[Invalid location]")
        return
    end
    if not lplr.Character then
        return
    end
    Script.Functions.SafeTeleportToCFrame(OldLocation)
end

TabGroup:AddToggle("TeleportToSafePlace", {
    Text = "Teleport To Safe Place",
    Default = false,
    Callback = function(Value)
        if Value then
            Script.Functions.Alert("Teleported to Safe Place, disable to go back", 3)
            Script.Functions.TeleportToSafe()
        else
            Script.Functions.Alert("Teleported back from Safe Place", 3)
            TeleportBackFromSafe()
        end
    end,
}):AddKeyPicker("TTSPKey", {
    Mode = "Toggle",
    Default = "L",
    Text = "Teleport To Safe Place",
    SyncToggleState = true,
})

TabGroup:AddButton("Fix Players Visibility", Script.Functions.CheckPlayersVisibility)
