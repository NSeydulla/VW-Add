local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local function GetDalgonaRemote()
    return ReplicatedStorage:WaitForChild("Remotes", 1):WaitForChild("DALGONATEMPREMPTE", 1)
end

local function CompleteDalgonaGame()
    ReplicatedStorage:WaitForChild("Replication"):WaitForChild("Event"):FireServer(unpack({ "Clicked" }))
    GetDalgonaRemote():FireServer(unpack({ { Completed = true } }))
    GetDalgonaRemote():FireServer(unpack({ { Success = true } }))
end

local function BypassDalgonaGame()
    local Character = lplr.Character
    local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character and Character:FindFirstChild("Humanoid")
    local PlayerGui = lplr.PlayerGui
    local DebrisBD = lplr:WaitForChild("DebrisBD")
    local CurrentCamera = workspace.CurrentCamera
    local EffectsFolder = workspace:FindFirstChild("Effects")
    local ImpactFrames = PlayerGui:FindFirstChild("ImpactFrames")

    local originalFieldOfView = CurrentCamera.FieldOfView

    local shapeModel, outlineModel, pickModel, redDotModel
    if EffectsFolder then
        for _, obj in pairs(EffectsFolder:GetChildren()) do
            if obj:IsA("Model") and obj.Name:match("Outline$") then
                outlineModel = obj
            elseif
                obj:IsA("Model")
                and not obj.Name:match("Outline$")
                and obj.Name ~= "Pick"
                and obj.Name ~= "RedDot"
            then
                shapeModel = obj
            elseif obj.Name == "Pick" then
                pickModel = obj
            elseif obj.Name == "RedDot" then
                redDotModel = obj
            end
        end
    end

    local progressBar = ImpactFrames and ImpactFrames:FindFirstChild("ProgressBar")

    local pickViewportModel
    if ImpactFrames then
        for _, obj in pairs(ImpactFrames:GetChildren()) do
            if obj:IsA("ViewportFrame") and obj:FindFirstChild("PickModel") then
                pickViewportModel = obj.PickModel
                break
            end
        end
    end

    local DalgonaRemote = GetDalgonaRemote()

    local cameraOverrideActive = true

    task.spawn(function()
        local Folder = Instance.new("Folder")
        Folder.Name = "RecentGameStartedMessage"
        Folder.Parent = lplr
        if 0.01 then
            task.delay(0.01, function()
                if Folder and Folder.Parent then
                    Folder:Destroy()
                end
            end)
        end

        if shapeModel and shapeModel:FindFirstChild("shape") then
            TweenService:Create(shapeModel.shape, TweenInfo.new(2, Enum.EasingStyle.Quad), {
                Position = shapeModel.shape.Position + Vector3.new(0, 0.5, 0),
            }):Play()
        end

        if shapeModel then
            for _, part in pairs(shapeModel:GetChildren()) do
                if part.Name == "DalgonaClickPart" and part:IsA("BasePart") then
                    TweenService:Create(part, TweenInfo.new(2, Enum.EasingStyle.Quad), {
                        Transparency = 1,
                    }):Play()
                end
            end
        end

        if pickModel and pickModel.Parent then
            TweenService:Create(pickModel, TweenInfo.new(2, Enum.EasingStyle.Quad), {
                Transparency = 1,
            }):Play()
        end
        if redDotModel and redDotModel.Parent then
            TweenService:Create(redDotModel, TweenInfo.new(2, Enum.EasingStyle.Quad), {
                Transparency = 1,
            }):Play()
        end

        if pickViewportModel then
            for _, part in pairs(pickViewportModel:GetDescendants()) do
                if part:IsA("BasePart") then
                    TweenService:Create(part, TweenInfo.new(2, Enum.EasingStyle.Quad), {
                        Transparency = 1,
                    }):Play()
                end
            end
        end

        if HumanoidRootPart then
            TweenService:Create(CurrentCamera, TweenInfo.new(2, Enum.EasingStyle.Quad), {
                CFrame = HumanoidRootPart.CFrame * CFrame.new(
                    0.0841674805,
                    8.45438766,
                    6.69675446,
                    0.999918401,
                    -0.00898250192,
                    0.00907994807,
                    3.31699681e-08,
                    0.710912943,
                    0.703280032,
                    -0.0127722733,
                    -0.703222632,
                    0.710854948
                ),
            }):Play()
        end

        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 1
                part.CanCollide = false
            end
        end

        DalgonaRemote:FireServer({
            Success = true,
        })

        task.wait(2)

        for _, obj in pairs({ shapeModel, outlineModel, pickModel, redDotModel, progressBar }) do
            if obj and obj.Parent then
                obj:Destroy()
            end
        end

        UserInputService.MouseIconEnabled = true
        if PlayerGui:FindFirstChild("Hotbar") and PlayerGui.Hotbar:FindFirstChild("Backpack") then
            TweenService:Create(
                PlayerGui.Hotbar.Backpack,
                TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut),
                {
                    Position = UDim2.new(0, 0, 0, 0),
                }
            ):Play()
        end
        if progressBar then
            DebrisBD:Fire(progressBar, 2)
            TweenService
                :Create(progressBar, TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
                    Position = UDim2.new(progressBar.Position.X.Scale, 0, progressBar.Position.Y.Scale + 1, 0),
                })
                :Play()
        end

        task.wait(0.5)
        cameraOverrideActive = false

        CurrentCamera.CameraType = Enum.CameraType.Custom
        if Humanoid then
            CurrentCamera.CameraSubject = Humanoid
        end
        CurrentCamera.FieldOfView = originalFieldOfView or 70

        Script.Camera = CurrentCamera
    end)

    if Script.Connections.cameraOverrideConnection then
        Script.Connections.cameraOverrideConnection:Disconnect()
        Script.Connections.cameraOverrideConnection = nil
    end
    Script.Connections.cameraOverrideConnection = RunService.RenderStepped:Connect(function()
        if not cameraOverrideActive and Script.Connections.cameraOverrideConnection then
            Script.Connections.cameraOverrideConnection:Disconnect()
            Script.Connections.cameraOverrideConnection = nil
            return
        end

        if CurrentCamera.CameraType == Enum.CameraType.Scriptable then
            CurrentCamera.CameraType = Enum.CameraType.Custom
        end

        if Humanoid and CurrentCamera.CameraSubject ~= Humanoid then
            CurrentCamera.CameraSubject = Humanoid
        end
    end)

    return function()
        cameraOverrideActive = false
        if Script.Connections.cameraOverrideConnection then
            Script.Connections.cameraOverrideConnection:Disconnect()
            Script.Connections.cameraOverrideConnection = nil
        end

        for _, obj in pairs({ shapeModel, outlineModel, pickModel, redDotModel, progressBar }) do
            if obj and obj.Parent then
                obj:Destroy()
            end
        end

        UserInputService.MouseIconEnabled = true
        CurrentCamera.CameraType = Enum.CameraType.Custom
        if Humanoid then
            CurrentCamera.CameraSubject = Humanoid
        end
        CurrentCamera.FieldOfView = originalFieldOfView or 70

        Script.Camera = CurrentCamera
    end
end

local function RestartRemotesScript()
    if lplr.Character and lplr.Character:FindFirstChild("Remotes") then
        local Remotes = lplr.Character:FindFirstChild("Remotes")
        pcall(function()
            Remotes.Disabled = true
            Remotes.Enabled = false
        end)
        task.wait(0.5)
        pcall(function()
            Remotes.Disabled = false
            Remotes.Enabled = true
        end)
    end
end

Script.AutoWin.Dalgona = function()
    Script.Tasks.AutoWinDalgona = task.spawn(function()
        repeat
            task.wait()
        until GetDalgonaRemote()
            or not Library.Toggles.InkGameAutowin.Value
            or Library.Unloaded
        task.wait(3)
        CompleteDalgonaGame()
        BypassDalgonaGame()()
        RestartRemotesScript()
        Script.Tasks.AutoWinDalgona2 = task.spawn(function()
            repeat
                task.wait(1)
                Script.Functions.CheckPlayersVisibility()
            until not GetDalgonaRemote()
                or not Library.Toggles.InkGameAutowin.Value
                or Library.Unloaded
            Script.Tasks.AutoWinDalgona2 = nil
        end)
        task.delay(3, function()
            CompleteDalgonaGame()
            BypassDalgonaGame()()
            RestartRemotesScript()
        end)
        Script.Tasks.AutoWinDalgona = nil
    end)
    return function()
        Script.Functions.CheckPlayersVisibility()
    end
end

Script.OnGame.Dalgona = function()
    if Library.Toggles.ImmuneDalgonaGame.Value then
        Library.Toggles.ImmuneDalgonaGame.Callback(true)
    end
end

TabGroup:AddButton("Complete Dalgona Game", function()
    if not GetDalgonaRemote() then
        Script.Functions.Alert("Game hasn't started yet")
        return
    end
    CompleteDalgonaGame()
    BypassDalgonaGame()()
    Script.Functions.Alert("Completed Dalgona Game!", 2)
    RestartRemotesScript()
    Script.Functions.Alert("Camera should be automatically fixed!", 3)
    table.insert(
        Script.Tasks,
        task.spawn(function()
            repeat
                task.wait(1)
                Script.Functions.CheckPlayersVisibility()
            until not GetDalgonaRemote()
        end)
    )
end)

TabGroup:AddToggle("ImmuneDalgonaGame", {
    Text = "Immune Dalgona Game",
    Default = false,
    Callback = function(Value)
        Script.HookMethods.ImmuneDalgona = nil
        if Script.Connections.DalgonaImuneConnDestroyer then
            Script.Connections.DalgonaImuneConnDestroyer:Disconnect()
            Script.Connections.DalgonaImuneConnDestroyer = nil
        end
        if Value then
            if not hookmetamethod then
                Script.Functions.Alert("Your executor doesn't suport this function :(", 5)
                Library.Toggles.ImmuneDalgonaGame:SetValue(false)
                return
            end
            if Script.GameState ~= "Dalgona" then
                return
            end
            Script.HookMethods.ImmuneDalgona = function(self, method, args)
                if self == "DALGONATEMPREMPTE" and method == "FireServer" then
                    if args[1] ~= nil and type(args[1]) == "table" and args[1].CrackAmount ~= nil then
                        Script.Functions.Alert("Prevented your cookie from cracking", 3)
                        return nil
                    end
                end

                return args
            end
            Script.Connections.DalgonaImuneConnDestroyer = Script.Functions.OnceOnGameChanged(function()
                Library.Toggles.ImmuneDalgonaGame.Callback(false)
            end)
            Script.Functions.Alert("Your cookie will not break from now on!", 3)
        else
            Script.Functions.Alert("Dalgona immune task killed", 3)
        end
    end,
})
