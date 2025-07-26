-- Generated automatically
local Functions = function(...)
local Script: ScriptType, Library: Obsidian = ...
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer

return {
    OnGameStateChange = function()
        Script.GameState = workspace.Values.CurrentGame.Value

        if Script.GameState then
            Script.GameState = tostring(Script.GameState)
        end

        if Library.Toggles.InkGameAutowin.Value then
            Script.Functions.HandleAutowin()
        end

        local onGameFunc = Script.OnGame[Script.GameState]
        if onGameFunc then
            onGameFunc()
        end
    end,

    OnLoad = function()
        Script.Temp.OriginalNameCall = hookmetamethod(game, "__namecall", function(self, ...)
            local args = { ... }
            local method = getnamecallmethod()

            for _, func in pairs(Script.HookMethods) do
                args = func(tostring(self), method, args)
                if not args then
                    return
                end
            end

            return Script.Temp.OriginalNameCall(self, unpack(args))
        end)

        Script.Temp.SafePlace = CFrame.new(Vector3.new(-108, 331, 462.1))
        Script.AutoWin.LightsOut = Script.Functions.TeleportToSafe
        pcall(Script.Functions.OnGameStateChange)
        Script.Connections.OnGameStateChange = workspace
            :WaitForChild("Values")
            :WaitForChild("CurrentGame")
            :GetPropertyChangedSignal("Value")
            :Connect(Script.Functions.OnGameStateChange)
        Library:GiveSignal(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
            if workspace.CurrentCamera then
                Script.Camera = workspace.CurrentCamera
            end
        end))
        Script.SaveManager:LoadAutoloadConfig()
    end,

    OnUnload = function()
        hookmetamethod(game, "__namecall", Script.Temp.OriginalNameCall)
        if Library._signals then
            for _, v in pairs(Library._signals) do
                pcall(function()
                    v:Disconnect()
                end)
            end
        end
        for _, conn in pairs(Script.Connections) do
            if type(conn) == "table" then
                for _, conn2 in pairs(conn) do
                    pcall(function()
                        conn2:Disconnect()
                    end)
                end
            else
                pcall(function()
                    conn:Disconnect()
                end)
            end
        end
        for _, task in pairs(Script.Tasks) do
            pcall(function()
                task.cancel(task)
            end)
        end
        for _, temp in pairs(Script.Temp) do
            pcall(function()
                if temp.Disconnect then
                    temp:Disconnect()
                elseif temp.Destroy then
                    temp:Destroy()
                elseif typeof(temp) == "thread" then
                    task.cancel(temp)
                end
            end)
        end
        for _, espType in pairs(Script.ESPTable) do
            for _, esp in pairs(espType) do
                pcall(esp.Destroy)
            end
        end
        Library.Unloaded = true
        getgenv().shared.Voidware_InkGame_Library = nil
    end,

    OnceOnGameChanged = function(func)
        return workspace:WaitForChild("Values"):WaitForChild("CurrentGame"):GetPropertyChangedSignal("Value"):Once(func)
    end,

    SafeRequire = function(module: Instance)
        if Script.Temp[tostring(module)] then
            return Script.Temp[tostring(module)]
        end
        local suc, err = pcall(function()
            return require(module)
        end)
        if not suc then
            Script.Functions.Alert(
                "[SafeRequire]: Failure loading " .. tostring(module) .. " (" .. tostring(err) .. ")"
            )
        else
            Script.Temp[tostring(module)] = err
        end
        return suc and err
    end,

    HandleAutowin = function()
        if Script.Temp.lastCleanupFunction then
            pcall(Script.Temp.lastCleanupFunction)
            Script.Temp.lastCleanupFunction = nil
        end

        local autoWinFunc = Script.AutoWin[Script.GameState]
        if autoWinFunc then
            Script.Functions.Alert("[Autowin]: Running on " .. tostring(Script.GameState))
            Script.Temp.lastCleanupFunction = autoWinFunc()
        else
            Script.Functions.Alert("[Autowin]: Waiting for the next game...")
        end
    end,

    Alert = function(message: string, time: number?)
        Library:Notify(message, time or 5)

        local sound = Instance.new("Sound", workspace)
        sound.SoundId = "rbxassetid://4590662766"
        sound.Volume = 2
        sound.PlayOnRemove = true
        sound:Destroy()
    end,

    CheckPlayersVisibility = function()
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "BoneCustom" then
                        if part.Transparency >= 0.99 or part.LocalTransparencyModifier >= 0.99 then
                            part.Transparency = 0
                            part.LocalTransparencyModifier = 0
                        end
                    end
                end

                pcall(function()
                    player.Character.HumanoidRootPart.Transparency = 1
                end)
                pcall(function()
                    player.Character.Head.BoneCustom.Transparency = 1
                end)

                for _, item in pairs(player.Character:GetChildren()) do
                    if item:IsA("Accessory") or item:IsA("Clothing") then
                        if item:IsA("Accessory") then
                            local handle = item:FindFirstChild("Handle")
                            if handle and handle.Transparency >= 0.99 then
                                handle.Transparency = 0
                            end
                        end
                    end
                end
            end
        end
    end,

    IsGuard = function(model: Model): boolean
        if
            string.find(model.Name, "Rebel")
            or string.find(model.Name, "HallwayGuard")
            or string.find(string.lower(model.Name), "aggro")
        then
            return true
        end
        return false
    end,

    ApplyHiderSeekerESP = function(esp: ESP)
        if esp.Connections.HASPlayerConn then
            esp.Connections.HASPlayerConn:Disconnect()
        end
        if esp.Object:FindFirstChild("BlueVest") then
            esp.Connections.HASPlayerConn = Script.Functions.OnceOnGameChanged(function()
                esp.SetColor(Library.Options["PlayerESPColor"].Value :: Color3)
                esp.Text = esp.Text:gsub("%(Hider%)", "")
            end)
            esp.SetColor(Library.Options["HiderESPColor"].Value :: Color3)
            esp.Text = esp.Text .. "(Hider)"
        end
        if not esp.Object:FindFirstChild("BlueVest") then
            esp.Connections.HASPlayerConn = Script.Functions.OnceOnGameChanged(function()
                esp.SetColor(Library.Options["PlayerESPColor"].Value :: Color3)
                esp.Text = esp.Text:gsub("%(Seeker%)", "")
            end)
            esp.SetColor(Library.Options["SeekerESPColor"].Value :: Color3)
            esp.Text = esp.Text .. "(Seeker)"
        end
    end,

    GetRootPart = function(): Part?
        if not lplr.Character then
            Script.Functions.Alert("Character not found! try again")
            return
        end
        local hum = lplr.Character:WaitForChild("HumanoidRootPart", 1)
        if not hum then
            Script.Functions.Alert("Humanoid part not found! try again")
        end
        return hum :: Part?
    end,

    SafeTeleport = function(x: number, y: number, z: number)
        Script.Functions.SafeTeleportToCFrame(CFrame.new(Vector3.new(x, y, z)))
    end,

    SafeTeleportToCFrame = function(cframe: CFrame)
        if not lplr.Character then
            Script.Functions.Alert("Character not found! try again")
            return
        end
        local Value = Library.Toggles.AntiFlingToggle.Value
        if Value then
            Library.Toggles.AntiFlingToggle:SetValue(false)
        end
        lplr.Character:PivotTo(cframe)
        if Value then
            Library.Toggles.AntiFlingToggle:SetValue(true)
        end
    end,

    TeleportToSafe = function()
        local hum = Script.Functions.GetRootPart()
        if not hum then
            return
        end
        Script.Temp.OldLocation = CFrame.new(hum.Position)
        Script.Functions.SafeTeleportToCFrame(Script.Temp.SafePlace)
    end,

    ESP = function(args: ESPArgs): ESP?
        if not args.Object then
            return Script.Functions.Alert("ESP Object is nil")
        end

        local self: ESP = {
            Object = args.Object,
            Text = args.Text or "No Text",
            TextParent = args.TextParent,
            Color = args.Color or Color3.new(),
            Offset = args.Offset or Vector3.zero,
            Type = args.Type or "None",
            Highlights = {},
            Connections = {},
            Destroy = function() end,
            SetColor = function() end,
            GiveSignal = function() end,
        }

        local tableIndex = #Script.ESPTable[self.Type] + 1

        local function Highlight(part)
            local highlight = Instance.new("BoxHandleAdornment")
            highlight.Adornee = part
            highlight.AlwaysOnTop = true
            highlight.ZIndex = 5
            highlight.Size = part.Size
            highlight.Color3 = self.Color
            highlight.Transparency = Library.Options.ESPTransparency.Value
            highlight.Parent = part
            table.insert(self.Highlights, highlight)
        end
        if self.Object:IsA("BasePart") then
            Highlight(self.Object)
        end
        for _, part in ipairs(self.Object:GetChildren()) do
            if part:IsA("BasePart") or part:IsA("Attachment") then
                Highlight(part)
            end
        end

        local billboardGui = Instance.new("BillboardGui")
        do
            billboardGui.Adornee = self.TextParent or self.Object
            billboardGui.AlwaysOnTop = true
            billboardGui.ClipsDescendants = false
            billboardGui.Size = UDim2.new(0, 1, 0, 1)
            billboardGui.StudsOffset = self.Offset
            billboardGui.Parent = self.TextParent or self.Object
        end

        local textLabel = Instance.new("TextLabel")
        do
            textLabel.BackgroundTransparency = 1
            textLabel.Font = Enum.Font.Oswald
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.Text = self.Text
            textLabel.TextColor3 = self.Color
            textLabel.TextSize = Library.Options.ESPTextSize.Value
            textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            textLabel.TextStrokeTransparency = 0.75
            textLabel.Parent = billboardGui
        end

        self.SetColor = function(newColor: Color3)
            self.Color = newColor

            for _, highlight in pairs(self.Highlights) do
                highlight.Color3 = newColor
            end

            textLabel.TextColor3 = newColor
        end

        self.Destroy = function()
            for _, conn in pairs(self.Connections) do
                pcall(function()
                    conn:Disconnect()
                end)
            end

            for _, highlight in pairs(self.Highlights) do
                highlight:Destroy()
            end
            if billboardGui then
                billboardGui:Destroy()
            end

            if Script.ESPTable[self.Type][tableIndex] then
                Script.ESPTable[self.Type][tableIndex] = nil
            end
        end

        self.GiveSignal = function(signal)
            table.insert(self.Connections, signal)
        end

        self.GiveSignal(RunService.RenderStepped:Connect(function()
            if not self.Object or not self.Object:IsDescendantOf(workspace) then
                self.Destroy()
                return
            end

            textLabel.TextSize = Library.Options.ESPTextSize.Value

            if Library.Toggles.ESPDistance.Value then
                local pos: Vector3? = nil

                if self.Object:IsA("Model") then
                    pos = (self.Object :: Model):GetPivot().Position
                elseif self.Object:IsA("BasePart") then
                    pos = (self.Object :: BasePart).Position
                end
                if pos then
                    textLabel.Text = string.format(
                        "%s\n[%s]",
                        self.Text,
                        tostring(math.floor((Script.Camera.CFrame.Position - pos).Magnitude))
                    )
                else
                    textLabel.Text = self.Text
                end
            else
                textLabel.Text = self.Text
            end
        end))

        if self.Type == "Player" and Script.GameState == "HideAndSeek" then
            Script.Functions.ApplyHiderSeekerESP(self)
        end

        Script.ESPTable[self.Type][tableIndex] = self
        return self
    end,
}
end

local GroupFunctions = {

AntiDeath = function(...)
local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer

local function TPBackFromAntiDeath()
    if Script.Temp.OldDeathLocation then
        Script.Functions.SafeTeleportToCFrame(Script.Temp.OldDeathLocation)
        Script.Temp.OldDeathLocation = nil
    end
end

TabGroup:AddToggle("AntiDeathToggle", {
    Text = "Anti Death",
    Default = false,
    Callback = function(Value)
        if Script.Temp.AntiDeathTask then
            task.cancel(Script.Temp.AntiDeathTask)
            Script.Temp.AntiDeathTask = nil
        end
        if not Value then
            return
        end
        Script.Temp.AntiDeathTask = task.spawn(function()
            repeat
                task.wait()
                if lplr.Character then
                    local hum = lplr.Character:FindFirstChildOfClass("Humanoid")
                    if not hum then
                        return
                    end
                    if hum.Health <= Library.Options.AntiDeathHealthThreshold.Value then
                        if (Script.Camera.CFrame.Position - Script.Temp.SafePlace.Position).Magnitude > 20 then
                            local humRootPart = Script.Functions.GetRootPart()
                            if humRootPart then
                                Script.Temp.OldDeathLocation = CFrame.new(humRootPart.Position)
                                Script.Temp.OldDeathGame = Script.GameState
                            end
                            Script.Functions.SafeTeleportToCFrame(Script.Temp.SafePlace)
                            Script.Functions.Alert("Teleported to safe place!")
                        end
                    end
                end
            until not Library.Toggles.AntiDeathToggle.Value or Library.Unloaded
        end)
    end,
})

TabGroup:AddSlider("AntiDeathHealthThreshold", {
    Text = "Health Threshold",
    Default = 30,
    Min = 10,
    Max = 90,
    Rounding = 1,
})

TabGroup:AddButton("TP back from AntiDeath", TPBackFromAntiDeath)
end,

Checkpoint = function(...)
local TabGroup: ObsidianGroupBox, Script: ScriptType, _: Obsidian = ...
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
end,

Dalgona = function(...)
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
end,

Emotes = function(...)
local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function GetEmotesMeta()
    local Animations = ReplicatedStorage:WaitForChild("Animations", 10)
    if not Animations then
        Script.Functions.Alert("[GetEmotesMeta]: Animations folder timeout!")
        return
    end
    local Emotes = Animations:WaitForChild("Emotes", 10)
    if not Emotes then
        Script.Functions.Alert("[GetEmotesMeta]: Emotes folder timeout!")
        return
    end
    local res = {}
    for i, v in pairs(Emotes:GetChildren()) do
        if v.ClassName ~= "Animation" then
            continue
        end
        if not v.AnimationId then
            continue
        end

        if res[v.Name] then
            Script.Functions.Alert(
                "[GetEmotesMeta | Resolver]: The emote "
                    .. tostring(v.Name)
                    .. " is duplicated! Overwriting past data..."
            )
        end

        res[v.Name] = {
            anim = v.AnimationId,
            object = v,
        }
    end
    Script.Temp.EmoteList = res
    return res
end

local function RefreshEmoteList()
    local w = function(str)
        Script.Functions.Alert("[RefreshEmoteList]: " .. tostring(str))
    end
    local res = GetEmotesMeta()
    if not res then
        w("res not found!")
        return
    end
    if not Library.Options.EmotesList then
        w("Emotes List Option not found!")
        return
    end
    local tab = {}
    for i, v in pairs(res) do
        table.insert(tab, tostring(i))
    end
    Library.Options.EmotesList:SetValues(tab)
end

TabGroup:AddDropdown("EmotesList", {
    Text = "Emotes List",
    Values = {},
    AllowNull = true,
})

TabGroup:AddButton("Play Emote", function()
    if Library.Options.EmotesList.Value then
        local emoteId = Script.Temp.EmoteList ~= nil and Script.Temp.EmoteList[Library.Options.EmotesList.Value]
        if emoteId and emoteId.anim and emoteId.object then
            local character = lplr and lplr.Character
            if not character then
                Script.Functions.Alert("[Emote] No character found!", 3)
                return
            end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then
                Script.Functions.Alert("[Emote] No humanoid found!", 3)
                return
            end

            if
                Script.Temp.EmoteTrack
                and typeof(Script.Temp.EmoteTrack) == "Instance"
                and Script.Temp.EmoteTrack:IsA("AnimationTrack")
            then
                pcall(function()
                    Script.Temp.EmoteTrack:Stop()
                end)
                Script.Temp.EmoteTrack = nil
            end

            local animId = emoteId
            if emoteId.object and emoteId.object.AnimationId then
                animId = emoteId.object.AnimationId
            end
            if not animId or animId == "" then
                Script.Functions.Alert("[Emote] Invalid AnimationId!", 3)
                return
            end
            local anim = Instance.new("Animation")
            anim.AnimationId = animId
            local track
            local success, _ = pcall(function()
                track = humanoid:LoadAnimation(anim)
                track.Priority = Enum.AnimationPriority.Action
                track:Play()
                Script.Temp.EmoteTrack = track
            end)
            if not success or not track then
                Script.Functions.Alert("[Emote] Failed to play emote!", 3)
                return
            end
        else
            Script.Functions.Alert("Error! Invalid emote selected")
            Library.Options.EmoteList:SetValue(nil)
            RefreshEmoteList()
        end
    else
        Script.Functions.Alert("No Emote Selected!", 3)
    end
end)

TabGroup:AddButton("Stop Emoting", function()
    if
        Script.Temp.EmoteTrack
        and typeof(Script.Temp.EmoteTrack) == "Instance"
        and Script.Temp.EmoteTrack:IsA("AnimationTrack")
    then
        pcall(function()
            Script.Temp.EmoteTrack:Stop()
        end)
        Script.Temp.EmoteTrack = nil
    end
end)

task.spawn(function()
    RefreshEmoteList()
    local Animations = ReplicatedStorage:WaitForChild("Animations")
    local Emotes = Animations:WaitForChild("Emotes")
    Library:GiveSignal(Emotes.ChildAdded:Connect(RefreshEmoteList))
    Library:GiveSignal(Emotes.ChildRemoved:Connect(RefreshEmoteList))
end)
end,

ESPSettings = function(...)
local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
local function ChangeTransparency(Value)
    local v = 1
    if Value then
        v = Library.Options.ESPTransparency.Value
    end
    -- task.delay(0.1, function()
    for i, ESPs in pairs(Script.ESPTable) do
        for j, esp in pairs(ESPs) do
            for _, highlight in pairs(esp.Highlights) do
                highlight.Transparency = v
            end
        end
    end
    -- end)
end

TabGroup:AddToggle("ESPHighlight", {
    Text = "Enable Highlight",
    Default = true,
    Callback = ChangeTransparency,
})

TabGroup:AddToggle("ESPDistance", {
    Text = "Show Distance",
    Default = true,
})

TabGroup:AddSlider("ESPTransparency", {
    Text = "Transparency",
    Default = 0.75,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function()
        ChangeTransparency(Library.Toggles.ESPHighlight.Value)
    end,
})

TabGroup:AddSlider("ESPTextSize", {
    Text = "Text Size",
    Default = 22,
    Min = 16,
    Max = 26,
    Rounding = 0,
})
end,

FOV = function(...)
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
end,

Fun = function(...)
local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer
local RunService = game:GetService("RunService")

TabGroup:AddToggle("InkGameAutowin", {
    Text = "Autowin ⭐",
    Default = false,
    Callback = function(Value)
        if Value then
            Script.Functions.Alert("Autowin enabled!", 5)
            if Library.Toggles.Noclip.Value ~= false then
                Library.Toggles.Noclip:SetValue(false)
            end
            Script.Functions.HandleAutowin()
        else
            if Script.Temp.lastCleanupFunction then
                pcall(Script.Temp.lastCleanupFunction)
                Script.Temp.lastCleanupFunction = nil
            end
            Script.Functions.Alert("Autowin disabled!", 3)
        end
    end,
})

TabGroup:AddToggle("FlingAuraToggle", {
    Text = "Fling Aura",
    Default = false,
    Callback = function(Value)
        local function stopFlingAura()
            Script.Temp.FlingAuraActive = false
            if Library.Toggles.Noclip.Value ~= false then
                Library.Toggles.Noclip:SetValue(false)
            end
            if Script.Connections.FlingAuraDeathConn then
                Script.Connections.FlingAuraDeathConn:Disconnect()
                Script.Connections.FlingAuraDeathConn = nil
            end
        end

        if Script.Tasks.FlingAuraTask then
            task.cancel(Script.Tasks.FlingAuraTask)
            Script.Tasks.FlingAuraTask = nil
        end
        if Value then
            Script.Functions.Alert("Fling Aura Enabled", 3)
            Script.Temp.FlingAuraActive = true
            pcall(function()
                if not Library.Toggles.PatchFlingAnticheat.Value then
                    Library.Toggles.PatchFlingAnticheat:SetValue(true)
                end
            end)
            if Library.Toggles.Noclip.Value ~= true then
                Library.Toggles.Noclip:SetValue(true)
            end
            local player = lplr
            local function getRoot(character)
                return character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))
            end
            local humanoid = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
            if humanoid then
                Script.Connections.FlingAuraDeathConn = humanoid.Died:Connect(stopFlingAura)
            end
            Script.Tasks.FlingAuraTask = task.spawn(function()
                local movel = 0.1
                while Script.Temp.FlingAuraActive and not Library.Unloaded do
                    local character = player.Character
                    local root = getRoot(character)
                    if character and character.Parent and root and root.Parent then
                        local originalVel = root.Velocity
                        root.Velocity = originalVel * 10000 + Vector3.new(0, 10000, 0)
                        RunService.RenderStepped:Wait()
                        if character and character.Parent and root and root.Parent then
                            root.Velocity = originalVel
                        end
                        RunService.Stepped:Wait()
                        if character and character.Parent and root and root.Parent then
                            root.Velocity = originalVel + Vector3.new(0, movel, 0)
                            movel = -movel
                        end
                    end
                    RunService.Heartbeat:Wait()
                end
            end)
        else
            pcall(function()
                if Library.Toggles.PatchFlingAnticheat.Value then
                    Library.Toggles.PatchFlingAnticheat:SetValue(false)
                end
            end)
            Script.Functions.Alert("Fling Aura Disabled", 3)
            stopFlingAura()
        end
    end,
})

TabGroup:AddToggle("AntiFlingToggle", {
    Text = "Anti Fling",
    Default = false,
    Callback = function(Value)
        if Script.Tasks.AntiFlingLoop then
            task.cancel(Script.Tasks.AntiFlingLoop)
            Script.Tasks.AntiFlingLoop = nil
        end
        if Value then
            if not hookmetamethod then
                Script.Functions.Alert("[Fling Aura]: Unsupported executor :(")
                Library.Toggles.AntiFlingToggle:SetValue(false)
                return
            end
            Script.Functions.Alert("Anti Fling Enabled", 3)
            Script.Tasks.AntiFlingLoop = task.spawn(function()
                local lastSafeCFrame = nil
                while Library.Toggles.AntiFlingToggle.Value and not Library.Unloaded do
                    task.wait(0.05)
                    local character = lplr.Character
                    local root = character and (Script.Functions.GetRootPart() or character:FindFirstChild("Torso"))
                    if root then
                        local isActiveGame = Script.GameState and Script.AutoWin[Script.GameState] ~= nil
                        for _, part in pairs(character:GetDescendants()) do
                            if
                                part:IsA("BodyMover")
                                or part:IsA("BodyVelocity")
                                or part:IsA("BodyGyro")
                                or part:IsA("BodyThrust")
                                or part:IsA("BodyAngularVelocity")
                            then
                                part:Destroy()
                            end
                        end
                        local maxVel = 100
                        local vel = root.Velocity
                        if vel.Magnitude > maxVel then
                            root.Velocity = Vector3.new(
                                math.clamp(vel.X, -maxVel, maxVel),
                                math.clamp(vel.Y, -maxVel, maxVel),
                                math.clamp(vel.Z, -maxVel, maxVel)
                            )
                        end
                        if (root.Position - lastSafeCFrame.Position).Magnitude < 20 then
                            lastSafeCFrame = root.CFrame
                        elseif
                            lastSafeCFrame
                            and isActiveGame
                            and (root.Position - lastSafeCFrame.Position).Magnitude > 50
                        then
                            root.CFrame = lastSafeCFrame
                            root.Velocity = Vector3.zero
                        end
                    end
                end
                Script.Tasks.AntiFlingLoop = nil
            end)
        else
            Script.Functions.Alert("Anti Fling Disabled", 3)
        end
    end,
})
end,

GlassBridge = function(...)
local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer

local function WinGlassBridge()
    if not lplr.Character then
        return
    end
    Script.Functions.SafeTeleport(-203.9, 525.7, -1534.3485)
end

Script.AutoWin.GlassBridge = function()
    task.spawn(function()
        Library.Toggles.RevealGlassBridge.Callback(true)
    end)
    WinGlassBridge()
    return function() end
end

Script.OnGame.GlassBridge = function()
    if Library.Toggles.RevealGlassBridge.Value then
        local bridge = workspace:WaitForChild("GlassBridge", 1)
        if not bridge then
            Script.Functions.Alert("[Glass Bridge]: glass bridge object not found! please retoggle the toggle")
        else
            Library.Toggles.RevealGlassBridge.Callback(true)
        end
    end
end

TabGroup:AddButton("Complete Glass Bridge Game", function()
    if Script.GameState ~= "GlassBridge" then
        Script.Functions.Alert("Game not running")
        return
    end
    WinGlassBridge()
end)

TabGroup:AddToggle("RevealGlassBridge", {
    Text = "Reveal Glass Bridge",
    Default = false,
    Callback = function(Value)
        if Script.GameState ~= "GlassBridge" then
            return
        end
        local glassBridge = workspace:FindFirstChild("GlassBridge")
        local glassHolder
        if glassBridge then
            glassHolder = glassBridge:FindFirstChild("GlassHolder")
        end
        if not glassHolder then
            Script.Functions.Alert("GlassHolder not found in workspace.GlassBridge")
            return
        end
        for _, tilePair in pairs(glassHolder:GetChildren()) do
            for _, tileModel in pairs(tilePair:GetChildren()) do
                if tileModel:IsA("Model") and tileModel.PrimaryPart then
                    local primaryPart = tileModel.PrimaryPart
                    for _, child in ipairs(primaryPart:GetChildren()) do
                        if child:IsA("BoxHandleAdornment") then
                            child:Destroy()
                        end
                    end

                    if not Value then
                        continue
                    end

                    local isKillBreaking = primaryPart:GetAttribute("ActuallyKilling") ~= nil
                    local isDelayedBreaking = primaryPart:GetAttribute("DelayedBreaking") ~= nil

                    local targetColor = Color3.fromRGB(0, 255, 0)

                    if isKillBreaking then
                        targetColor = Color3.fromRGB(255, 0, 0)
                    elseif isDelayedBreaking then
                        targetColor = Color3.fromRGB(255, 255, 0)
                    end

                    local highlight = Instance.new("BoxHandleAdornment")
                    highlight.Adornee = primaryPart
                    highlight.AlwaysOnTop = true
                    highlight.ZIndex = 5
                    highlight.Size = primaryPart.Size
                    highlight.Color3 = targetColor
                    highlight.Transparency = 0.6
                    highlight.Parent = primaryPart
                end
            end
        end
        if Value then
            Script.Functions.Alert("Safe tiles are green, breakable tiles are red!", 10)
        end
    end,
})
end,

HideAndSeek = function(...)
local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer

Script.AutoWin.HideAndSeek = function()
    if lplr:FindFirstChild("CurrentKeys") then
        Script.Functions.TeleportToSafe()
    else
        Script.Functions.Alert("[Autowin]: Hide and Seek support for Seekers soon...")
    end
end

local function GetHider(): Model?
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == lplr or not plr.Character then
            continue
        end
        local hum = plr.Character:FindFirstChild("Humanoid") :: Humanoid?
        if not hum or not plr:GetAttribute("IsHider") or hum.Health <= 0 then
            continue
        end
        return plr.Character
    end
    return nil
end

TabGroup:AddToggle("TeleportToHider", {
    Text = "Teleport To Hider",
    Default = false,
    Callback = function(Value)
        if Value then
            task.delay(0.5, function()
                if Library.Toggles.TeleportToHider.Value then
                    Library.Toggles.TeleportToHider:SetValue(false)
                end
            end)
            if not lplr.Character then
                return
            end
            if Script.GameState ~= "HideAndSeek" then
                Script.Functions.Alert("Game not running!")
                return
            end
            local hider = GetHider()
            if not hider then
                Script.Functions.Alert("No hider found :(")
                return
            end
            lplr.Character:PivotTo(hider:GetPrimaryPartCFrame())
        end
    end,
}):AddKeyPicker("TTH", {
    Mode = "Toggle",
    Default = "P",
    Text = "Teleport To Hider",
    SyncToggleState = true,
})

local function TeleportSafeHidingSpot()
    if not lplr.Character then
        return
    end
    Script.Functions.SafeTeleport(229.9, 1005.3, 169.4)
end

TabGroup:AddButton("Teleport to Safe Hiding Spot", function()
    if Script.GameState ~= "HideAndSeek" then
        Script.Functions.Alert("Game not running!")
        return
    end
    TeleportSafeHidingSpot()
end)
end,

HideAndSeekESP = function(...)
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
end,

Interaction = function(...)
local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
local ProximityPromptService = game:GetService("ProximityPromptService")

TabGroup:AddToggle("NoInteractDelay", {
    Text = "Instant Interact",
    Default = false,
    Callback = function(Value)
        if Script.Connections.NoInteractDelayConnection then
            Script.Connections.NoInteractDelayConnection:Disconnect()
            Script.Connections.NoInteractDelayConnection = nil
        end
        if not Value then
            return
        end
        Script.Connections.NoInteractDelayConnection = ProximityPromptService.PromptShown:Connect(function(prompt)
            prompt.HoldDuration = 0
        end)
    end,
})

Script.Temp.ActivePrompts = {}

local function PromptDistChange(prompt)
    if prompt:IsA("ProximityPrompt") then
        if not Script.Temp.ActivePrompts[prompt] then
            Script.Temp.ActivePrompts[prompt] = prompt.MaxActivationDistance
        end
        if Library.Toggles.PromptReachToggle.Value then
            prompt.MaxActivationDistance = Script.Temp.ActivePrompts[prompt] * Library.Options.PromptReachSlider.Value
        else
            prompt.MaxActivationDistance = Script.Temp.ActivePrompts[prompt]
        end
    end
end

local function AllPromptDistChange()
    if not Library.Toggles.PromptReachToggle.Value then
        return
    end
    for _, prompt in pairs(Script.Temp.ActivePrompts) do
        PromptDistChange(prompt)
    end
end

TabGroup:AddToggle("PromptReachToggle", {
    Text = "Interaction Reach",
    Default = false,
    Callback = function(Value)
        if Script.Connections.PromptReachConnection then
            Script.Connections.PromptReachConnection:Disconnect()
            Script.Connections.PromptReachConnection = nil
        end
        if not Value then
            AllPromptDistChange()
            return
        end
        Script.Connections.PromptReachConnection = workspace.DescendantAdded:Connect(function(prompt)
            PromptDistChange(prompt)
        end)
    end,
})

TabGroup:AddSlider("PromptReachSlider", {
    Text = "Interaction Reach Multiplier",
    Default = 1.5,
    Min = 1,
    Max = 2,
    Rounding = 1,
    Callback = function(_)
        AllPromptDistChange()
    end,
})
end,

JumpRope = function(...)
local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer
local RunService = game:GetService("RunService")

local function WinJumpRope()
    if not lplr.Character then
        return
    end
    Script.Functions.SafeTeleport(732.4, 197.14, 931.1644)
end

Script.AutoWin.JumpRope = function()
    local call = true
    task.spawn(function()
        task.wait(15)
        repeat
            WinJumpRope()
            task.wait(3)
        until not call or not Library.Toggles.InkGameAutowin.Value or Library.Unloaded
    end)
    return function()
        call = false
    end
end

TabGroup:AddToggle("AutoSurviveJumpRope", {
    Text = "Anti Fall [beta]",
    Default = false,
    Callback = function(enabled)
        if Script.Connections.JumpRope_AutoSurviveCon then
            Script.Connections.JumpRope_AutoSurviveCon:Disconnect()
            Script.Connections.JumpRope_AutoSurviveCon = nil
        end
        if enabled then
            local char = lplr.Character
            local jumpRope = workspace:FindFirstChild("JumpRope")
            local fallCollisionClient
            if jumpRope then
                fallCollisionClient = jumpRope:FindFirstChild("FallColllisionYClient")
            end
            if char and fallCollisionClient then
                local root = char:FindFirstChild("HumanoidRootPart")
                local fallY = fallCollisionClient.Position.y
                pcall(function()
                    fallCollisionClient:Destroy()
                end)
                Script.Connections.JumpRope_AutoSurviveCon = RunService.RenderStepped:Connect(function()
                    if root and fallY and root.Position.Y <= fallY.Position.Y then
                        root.CFrame = root.CFrame + Vector3.new(0, 5, 0)
                    end
                end)
            else
                Script.Functions.Alert("Game not running or Fall Detection is missing", 3)
                Library.Toggles.AutoSurviveJumpRope:SetValue(false)
            end
        end
    end,
})

TabGroup:AddButton("Destroy Fall Detection [beta]", function()
    if Script.GameState ~= "JumpRope" then
        Script.Functions.Alert("Game not running")
        return
    end
    local suc, res = pcall(function()
        local suc = false
        local jumpRope = workspace:FindFirstChild("JumpRope")
        if jumpRope then
            local fallCollisionClient = jumpRope:FindFirstChild("FallColllisionYClient")
            local fallCollisionY = jumpRope:FindFirstChild("FallColllisionY")
            local collisionCheck = jumpRope:FindFirstChild("COLLISIONCHECK")
            if fallCollisionClient then
                fallCollisionClient:Destroy()
            end
            if fallCollisionY then
                fallCollisionY:Destroy()
            end
            if collisionCheck then
                collisionCheck:Destroy()
            end
            suc = fallCollisionClient and fallCollisionY and collisionCheck
        end
        return suc
    end)
    if suc and res then
        Script.Functions.Alert("Successfully destroyed fall detection!", 1.5)
    else
        Script.Functions.Alert("Fall detection part not found!", 3)
    end
end)

TabGroup:AddButton("Complete Jump Rope Game", function()
    if Script.GameState ~= "JumpRope" then
        Script.Functions.Alert("Game not running")
        return
    end
    WinJumpRope()
    if not lplr.Character then
        return
    end
    local a = lplr.Character:FindFirstChild("SafeJumpRope") or Instance.new("Folder")
    a.Name = "SafeJumpRope"
    a.Parent = lplr.Character
end)

TabGroup:AddToggle("AutoPerfectJumpRope", {
    Text = "Auto Perfect [beta]",
    Default = false,
    Callback = function(call)
        if Script.Connections.JumpRope_AutoPerfectCon then
            Script.Connections.JumpRope_AutoPerfectCon:Disconnect()
            Script.Connections.JumpRope_AutoPerfectCon = nil
        end
        if call then
            Script.Connections.JumpRope_AutoPerfectCon = game:GetService("RunService").RenderStepped:Connect(function()
                local char = lplr.Character
                if char then
                    local indicator = nil
                    for _, obj in ipairs(char:GetDescendants()) do
                        if obj:IsA("NumberValue") and obj.Name:lower():find("indicator") then
                            indicator = obj
                            break
                        end
                    end
                    if indicator then
                        indicator.Value = 0
                    end
                end
            end)
        end
    end,
})
end,

MainESP = function(...)
local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer

local function PlayerESP(player: Player)
    local char = player.Character
    if not char or not char.PrimaryPart then
        return
    end
    local humanoid = char:FindFirstChild("Humanoid") :: Humanoid?
    if not humanoid or humanoid.Health <= 0 then
        return
    end

    local playerESP = Script.Functions.ESP({
        Type = "Player",
        Object = char,
        Text = string.format("%s [%s]", player.DisplayName, tostring(math.ceil(humanoid.Health))),
        TextParent = char.PrimaryPart,
        Offset = Vector3.new(0, 2, 0),
        Color = Library.Options.PlayerESPColor.Value,
    })

    playerESP.GiveSignal(humanoid.HealthChanged:Connect(function(newHealth)
        if newHealth > 0 then
            playerESP.Text = string.format("%s [%s]", player.DisplayName, tostring(math.ceil(newHealth)))
        else
            playerESP.Destroy()
        end
    end))
end

TabGroup:AddToggle("PlayerESP", {
    Text = "Player",
    Default = false,
    Callback = function(Value)
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player == lplr then
                    continue
                end
                PlayerESP(player)
            end
        else
            for _, esp in pairs(Script.ESPTable["Player"]) do
                esp.Destroy()
            end
        end
    end,
}):AddColorPicker("PlayerESPColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        for _, esp in pairs(Script.ESPTable["Player"]) do
            esp.SetColor(Value)
        end
    end,
})

local function SetupPlayerConnection(player: Player)
    if player == lplr then
        return
    end
    if player.Character then
        if Library.Toggles.PlayerESP.Value then
            PlayerESP(player)
        end
    end

    Script.Connections.PlayerCharAdded[player.Name] = player.CharacterAdded:Connect(function(newCharacter)
        task.delay(0.1, function()
            if Library.Toggles.PlayerESP.Value then
                PlayerESP(player)
            end
        end)
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    SetupPlayerConnection(player)
end
Script.Connections.PlayerAdded = Players.PlayerAdded:Connect(SetupPlayerConnection)
Script.Connections.PlayerRemoved = Players.PlayerRemoving:Connect(function(player: Player) end)

local function GuardESP(character)
    if character then
        task.spawn(function()
            if not character:WaitForChild("Humanoid", 5) then
                Script.Functions.Alert("Guard finded, but Humanoid child not")
            else
                local guardESP = Script.Functions.ESP({
                    Object = character,
                    Text = ".",
                    Color = Library.Options.GuardESPColor.Value,
                    Offset = Vector3.new(0, 4, 0),
                    Type = "Guard",
                })
                guardESP.GiveSignal(character.ChildAdded:Connect(function(v)
                    if v.Name == "Dead" and v.ClassName == "Folder" then
                        guardESP.Destroy()
                    end
                end))
            end
        end)
    end
end

TabGroup:AddToggle("GuardESP", {
    Text = "Guard",
    Default = false,
    Callback = function(Value)
        if Script.Connections.GuardAddedConnection then
            Script.Connections.GuardAddedConnection:Disconnect()
            Script.Connections.GuardAddedConnection = nil
        end
        if Value then
            local live = workspace:FindFirstChild("Live")
            if not live then
                return
            end
            Script.Connections.GuardAddedConnection = live.ChildAdded:Connect(function(v)
                if Script.Functions.IsGuard(v) then
                    GuardESP(v)
                end
            end)
            for _, child in pairs(live:GetChildren()) do
                if Script.Functions.IsGuard(child) then
                    if child:FindFirstChild("Dead") then
                        continue
                    end
                    GuardESP(child)
                end
            end
        else
            for _, esp in pairs(Script.ESPTable["Guard"]) do
                esp.Destroy()
            end
        end
    end,
}):AddColorPicker("GuardESPColor", {
    Default = Color3.fromRGB(200, 100, 200),
    Callback = function(Value)
        for _, esp in pairs(Script.ESPTable["Guard"]) do
            esp.SetColor(Value)
        end
    end,
})
end,

Menu = function(...)
local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
TabGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "Menu keybind",
})
Library.ToggleKeybind = Library.Options.MenuKeybind

TabGroup:AddToggle("KeybindMenuOpen", {
    Default = false,
    Text = "Open Keybind Menu",
    Callback = function(value)
        Library.KeybindFrame.Visible = value
    end,
})

TabGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = true,
    Callback = function(Value)
        Library.ShowCustomCursor = Value
    end,
})

TabGroup:AddButton("Unload Script", function()
    Library:Unload()
end)

TabGroup:AddButton("Reset Settings", function()
    Script.SaveManager:SaveAutoloadConfig("default")
    pcall(function()
        writefile("voidware_linoria/ink_game/settings/default.json", "[]")
    end)
    pcall(function()
        Library:Unload()
    end)
    local load = loadstring(game:HttpGet(Script.repo .. "inkgame.luau"))
    if load then
        load()
    end
end)
end,

Mingle = function(...)
local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
local Players = game:GetService("Players")
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
end,

Misc = function(...)
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

        -- for _, obj in pairs(HumanoidRootPart:GetChildren()) do
        --     if obj:IsA("BallSocketConstraint") or obj.Name:match("^CacheAttachment") then
        --         obj:Destroy()
        --     end
        -- end
        local Torso = Character:FindFirstChild("Torso")
        local joints = { "Left Hip", "Left Shoulder", "Neck", "Right Hip", "Right Shoulder" }
        for _, jointName in pairs(joints) do
            local motor = Torso:FindFirstChild(jointName)
            if motor and motor:IsA("Motor6D") and not motor.Part0 then
                motor.Part0 = Torso
            end
        end
        -- for _, part in pairs(Character:GetChildren()) do
        --     if part:IsA("BasePart") and part:FindFirstChild("BoneCustom") then
        --         part.BoneCustom:Destroy()
        --     end
        -- end
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
end,

Performance = function(...)
local TabGroup: ObsidianGroupBox, Script: ScriptType, _: Obsidian = ...
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

TabGroup:AddToggle("LowGFX", {
    Text = "Low GFX",
    Default = false,
    Callback = function(Value)
        if Script.Connections.LowGFX_DescendantConn then
            Script.Connections.LowGFX_DescendantConn:Disconnect()
            Script.Connections.LowGFX_DescendantConn = nil
        end
        if Value then
            Script.Temp.LowGFX_Originals = Script.Temp.LowGFX_Originals or {}
            local Terrain = workspace:FindFirstChildOfClass("Terrain")
            if Terrain then
                Script.Temp.LowGFX_Originals.Terrain = {
                    WaterWaveSize = Terrain.WaterWaveSize,
                    WaterWaveSpeed = Terrain.WaterWaveSpeed,
                    WaterReflectance = Terrain.WaterReflectance,
                    WaterTransparency = Terrain.WaterTransparency,
                }
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 1
            end
            Script.Temp.LowGFX_Originals.Lighting = {
                GlobalShadows = Lighting.GlobalShadows,
                FogEnd = Lighting.FogEnd,
                FogStart = Lighting.FogStart,
            }
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.FogStart = 9e9
            pcall(function()
                Script.Temp.LowGFX_Originals.QualityLevel = settings().Rendering.QualityLevel
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            end)
            Script.Temp.LowGFX_Originals.BaseParts = {}
            for i, v in pairs(game:GetDescendants()) do
                if v:IsA("BasePart") then
                    local part = v :: BasePart
                    Script.Temp.LowGFX_Originals.BaseParts[part] = {
                        Material = part.Material,
                        Reflectance = part.Reflectance,
                        BackSurface = part.BackSurface,
                        BottomSurface = part.BottomSurface,
                        FrontSurface = part.FrontSurface,
                        LeftSurface = part.LeftSurface,
                        RightSurface = part.RightSurface,
                        TopSurface = part.TopSurface,
                    }
                    part.Material = "Plastic"
                    part.Reflectance = 0
                    part.BackSurface = "SmoothNoOutlines"
                    part.BottomSurface = "SmoothNoOutlines"
                    part.FrontSurface = "SmoothNoOutlines"
                    part.LeftSurface = "SmoothNoOutlines"
                    part.RightSurface = "SmoothNoOutlines"
                    part.TopSurface = "SmoothNoOutlines"
                elseif v:IsA("Decal") then
                    local decal = v :: Decal
                    Script.Temp.LowGFX_Originals[decal] = decal.Transparency
                    decal.Transparency = 1
                elseif v:IsA("ParticleEmitter") then
                    local particle = v :: ParticleEmitter
                    Script.Temp.LowGFX_Originals[particle] = particle.Lifetime
                    particle.Lifetime = 0
                elseif v:IsA("Trail") then
                    local trail = v :: Trail
                    Script.Temp.LowGFX_Originals[trail] = trail.Lifetime
                    trail.Lifetime = 0
                end
            end
            Script.Temp.LowGFX_Originals.PostEffects = {}
            for i, v in pairs(Lighting:GetDescendants()) do
                if v:IsA("PostEffect") then
                    Script.Temp.LowGFX_Originals.PostEffects[v] = v.Enabled
                    v.Enabled = false
                end
            end
            Script.Connections.LowGFX_DescendantConn = workspace.DescendantAdded:Connect(function(child)
                task.spawn(function()
                    if
                        child:IsA("ForceField")
                        or child:IsA("Sparkles")
                        or child:IsA("Smoke")
                        or child:IsA("Fire")
                        or child:IsA("Beam")
                    then
                        RunService.Heartbeat:Wait()
                        child:Destroy()
                    end
                end)
            end)
        else
            local Terrain = workspace:FindFirstChildOfClass("Terrain")
            if Terrain and Script.Temp.LowGFX_Originals and Script.Temp.LowGFX_Originals.Terrain then
                Terrain.WaterWaveSize = Script.Temp.LowGFX_Originals.Terrain.WaterWaveSize
                Terrain.WaterWaveSpeed = Script.Temp.LowGFX_Originals.Terrain.WaterWaveSpeed
                Terrain.WaterReflectance = Script.Temp.LowGFX_Originals.Terrain.WaterReflectance
                Terrain.WaterTransparency = Script.Temp.LowGFX_Originals.Terrain.WaterTransparency
            end
            if Script.Temp.LowGFX_Originals and Script.Temp.LowGFX_Originals.Lighting then
                Lighting.GlobalShadows = Script.Temp.LowGFX_Originals.Lighting.GlobalShadows
                Lighting.FogEnd = Script.Temp.LowGFX_Originals.Lighting.FogEnd
                Lighting.FogStart = Script.Temp.LowGFX_Originals.Lighting.FogStart
            end
            pcall(function()
                if Script.Temp.LowGFX_Originals and Script.Temp.LowGFX_Originals.QualityLevel then
                    settings().Rendering.QualityLevel = Script.Temp.LowGFX_Originals.QualityLevel
                end
            end)
            if Script.Temp.LowGFX_Originals and Script.Temp.LowGFX_Originals.BaseParts then
                for v, props in pairs(Script.Temp.LowGFX_Originals.BaseParts) do
                    if v and v.Parent then
                        v.Material = props.Material
                        v.Reflectance = props.Reflectance
                        v.BackSurface = props.BackSurface
                        v.BottomSurface = props.BottomSurface
                        v.FrontSurface = props.FrontSurface
                        v.LeftSurface = props.LeftSurface
                        v.RightSurface = props.RightSurface
                        v.TopSurface = props.TopSurface
                    end
                end
            end
            if Script.Temp.LowGFX_Originals then
                for v, val in pairs(Script.Temp.LowGFX_Originals) do
                    if typeof(v) == "Instance" then
                        if v:IsA("Decal") then
                            v.Transparency = val
                        elseif v:IsA("ParticleEmitter") then
                            local particle = v :: ParticleEmitter
                            particle.Lifetime = val
                        elseif v:IsA("Trail") then
                            local trail = v :: Trail
                            trail.Lifetime = val
                        end
                    end
                end
            end
            if Script.Temp.LowGFX_Originals and Script.Temp.LowGFX_Originals.PostEffects then
                for v, enabled in pairs(Script.Temp.LowGFX_Originals.PostEffects) do
                    if v and v.Parent then
                        v.Enabled = enabled
                    end
                end
            end
            Script.Temp.LowGFX_Originals = nil
        end
    end,
})

TabGroup:AddToggle("DisableEffects", {
    Text = "Disable Effects",
    Default = false,
    Callback = function(Value)
        if Script.Temp.DisableEffectsConnection then
            pcall(function()
                Script.Temp.DisableEffectsConnection:Disconnect()
            end)
            Script.Temp.DisableEffectsConnection = nil
        end
        if not Value then
            return
        end
        local Effects = workspace:WaitForChild("Effects", 15)
        if not Effects then
            return
        end
        for _, v in pairs(Effects:GetDescendants()) do
            if not string.find(v.Name, "DroppedKey") then
                v:Destroy()
            end
        end
        Script.Temp.DisableEffectsConnection = Effects.ChildAdded:Connect(function(v)
            pcall(function()
                if not string.find(v.Name, "DroppedKey") then
                    v:Destroy()
                end
            end)
        end)
    end,
})
end,

Player = function(...)
local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

TabGroup:AddSlider("WonBoostSlider", {
    Text = "Won boost(idk it works or not)",
    Default = lplr.Boosts["Won Boost"].Value,
    Min = 0,
    Max = 3,
    Rounding = 0,
    Callback = function(val)
        lplr.Boosts["Won Boost"].Value = val
    end,
})

TabGroup:AddSlider("StrengthBoostSlider", {
    Text = "Strength boost(idk it works or not)",
    Default = lplr.Boosts["Damage Boost"].Value,
    Min = 0,
    Max = 5,
    Rounding = 0,
    Callback = function(val)
        lplr.Boosts["Damage Boost"].Value = val
    end,
})

TabGroup:AddSlider("SpeedBoostSlider", {
    Text = "Speed boost",
    Default = lplr.Boosts["Faster Sprint"].Value,
    Min = 0,
    Max = 5,
    Rounding = 0,
    Callback = function(val)
        lplr.Boosts["Faster Sprint"].Value = val
    end,
})

TabGroup:AddSlider("SpeedSlider", {
    Text = "Walk Speed",
    Default = 16,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Callback = function(val)
        if not Library.Toggles.SpeedToggle.Value then
            return
        end
        if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
            lplr.Character.Humanoid.WalkSpeed = Library.Options.SpeedSlider.Value
        end
    end,
})

TabGroup:AddToggle("SpeedToggle", {
    Text = "Speed",
    Default = false,
    Callback = function(Value)
        if Script.Tasks.SpeedToggleTask then
            task.cancel(Script.Tasks.SpeedToggleTask)
            Script.Tasks.SpeedToggleTask = nil
        end
        if Value then
            Script.Functions.Alert("Speed Enabled", 3)
            if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
                Script.Temp.OldSpeed = lplr.Character.Humanoid.WalkSpeed
                lplr.Character.Humanoid.WalkSpeed = Library.Options.SpeedSlider.Value
            end
            Script.Tasks.SpeedToggleTask = task.spawn(function()
                repeat
                    task.wait(0.5)
                    if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
                        lplr.Character.Humanoid.WalkSpeed = Library.Options.SpeedSlider.Value
                    end
                until not Library.Toggles.SpeedToggle.Value or Library.Unloaded
                Script.Tasks.SpeedToggleTask = nil
            end)
        else
            Script.Functions.Alert("Speed Disabled", 3)
            if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
                lplr.Character.Humanoid.WalkSpeed = Script.Temp.OldSpeed
                Script.Temp.OldSpeed = nil
            end
        end
    end,
}):AddKeyPicker("SpeedKey", {
    Mode = "Toggle",
    Default = "C",
    Text = "Speed",
    SyncToggleState = true,
})

TabGroup:AddToggle("Noclip", {
    Text = "Noclip",
    Default = false,
    Callback = function(Value)
        if Script.Tasks.NoclipTask then
            task.cancel(Script.Tasks.NoclipTask)
            Script.Tasks.NoclipTask = nil
        end
        Script.Temp.NoclipParts = Script.Temp.NoclipParts or {}
        if Value then
            Script.Functions.Alert("Noclip Enabled", 3)
            Script.Tasks.NoclipTask = task.spawn(function()
                repeat
                    RunService.Heartbeat:Wait()
                    if lplr.Character then
                        for _, child in pairs(lplr.Character:GetDescendants()) do
                            if child:IsA("BasePart") and child.CanCollide == true then
                                child.CanCollide = false
                                Script.Temp.NoclipParts[child] = true
                            end
                        end
                    end
                until not Library.Toggles.Noclip.Value or Library.Unloaded
                Script.Tasks.NoclipTask = nil
            end)
        else
            Script.Functions.Alert("Noclip Disabled", 3)
            if lplr.Character and Script.Temp.NoclipParts then
                for part, _ in pairs(Script.Temp.NoclipParts) do
                    if part and part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
                Script.Temp.NoclipParts = {}
            end
        end
    end,
}):AddKeyPicker("NoclipKey", {
    Mode = "Toggle",
    Default = "N",
    Text = "Noclip",
    SyncToggleState = true,
})

TabGroup:AddToggle("InfiniteJump", {
    Text = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        if Script.Connections.InfiniteJumpConnect then
            Script.Connections.InfiniteJumpConnect:Disconnect()
        end
        if not Value then
            return
        end
        Script.Connections.InfiniteJumpConnect = UserInputService.JumpRequest:Connect(function()
            if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
                lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end,
})
end,

Rebel = function(...)
local TabGroup: ObsidianGroupBox, Script: ScriptType, _: Obsidian = ...
local ReplicatedStorage = game:GetService("ReplicatedStorage")

TabGroup:AddToggle("ExpandGuardHitbox", {
    Text = "Expand Guard Hitbox",
    Default = false,
    Callback = function(Value)
        if Script.Connections.GuardHitboxConnection then
            Script.Connections.GuardHitboxConnection:Disconnect()
            Script.Connections.GuardHitboxConnection = nil
        end
        local live = workspace:FindFirstChild("Live")
        if not live then
            return
        end
        if Value then
            Script.Connections.GuardHitboxConnection = live.ChildAdded:Connect(function(model)
                if not Script.Functions.IsGuard(model) then
                    return
                end
                local head = model:WaitForChild("Head", 5)
                if not head or not head:IsA("BasePart") then
                    return
                end
                if model and model.Parent and head and head.Parent then
                    head.Size = Vector3.new(4, 4, 4)
                    head.CanCollide = false
                end
                local index = #Script.Connections.GuardCharAdded + 1
                Script.Connections.GuardCharAdded[index] = model.ChildAdded:Connect(function(folder)
                    if folder.Name == "Dead" and folder.ClassName == "Folder" then
                        head.Size = Vector3.new(1, 1, 1)
                        local conn = Script.Connections.GuardCharAdded[index]
                        if conn then
                            conn:Disconnect()
                            Script.Connections.GuardCharAdded[index] = nil
                        end
                    end
                end)
            end)
            for _, model in pairs(live:GetChildren()) do
                if not Script.Functions.IsGuard(model) then
                    return
                end
                if model:FindFirstChild("Dead") then
                    continue
                end
                local head = model:WaitForChild("Head", 5)
                if not head or not head:IsA("BasePart") then
                    return
                end
                if model and model.Parent and head and head.Parent then
                    head.Size = Vector3.new(4, 4, 4)
                    head.CanCollide = false
                end
            end
        else
            for _, model in ipairs(live:GetChildren()) do
                if not Script.Functions.IsGuard(model) then
                    return
                end
                local head = model:WaitForChild("Head", 5)
                if not head or not head:IsA("BasePart") then
                    return
                end
                if model and model.Parent and head and head.Parent then
                    head.Size = Vector3.new(1, 1, 1)
                end
            end
        end
    end,
})

TabGroup:AddButton("Bring All Guards", function()
    local humRootPart = Script.Functions.GetRootPart()
    if not humRootPart then
        return
    end
    local myPos = humRootPart.Position
    local Live = workspace:WaitForChild("Live")
    for _, guard in pairs(Live:GetChildren()) do
        if Script.Functions.IsGuard(guard) and guard:FindFirstChild("HumanoidRootPart") then
            local guardRoot = guard.HumanoidRootPart
            local lookCFrame = CFrame.new(guardRoot.Position, myPos)
            guardRoot.CFrame = lookCFrame
        end
    end
end)

TabGroup:AddToggle("GunMods", {
    Text = "Gun Mods",
    Default = false,
    Callback = function(enable)
        Script.Temp.originalDamageValues = Script.Temp.originalDamageValues or {}
        Script.Temp.originalGunStats = Script.Temp.originalGunStats or {}
        local Guns = ReplicatedStorage:FindFirstChild("Weapons") and ReplicatedStorage.Weapons:FindFirstChild("Guns")
        if not Guns then
            return
        end
        -- local GunDamageValues = Script.Functions.SafeRequire(ReplicatedStorage.Modules.GunDamageValues)
        for _, gun in pairs(Guns:GetChildren()) do
            if enable then
                if not Script.Temp.originalGunStats[gun.Name] then
                    Script.Temp.originalGunStats[gun.Name] = {}
                    for _, stat in ipairs({ "Spread", "FireRateCD", "MaxBullets", "ReloadingSpeed" }) do
                        if gun:FindFirstChild(stat) then
                            Script.Temp.originalGunStats[gun.Name][stat] = gun[stat].Value
                        end
                    end
                end
                if gun:FindFirstChild("Spread") then
                    gun.Spread.Value = 0
                end
                if gun:FindFirstChild("FireRateCD") then
                    gun.FireRateCD.Value = 0.05
                end
                if gun:FindFirstChild("MaxBullets") then
                    gun.MaxBullets.Value = 9999
                end
                if gun:FindFirstChild("ReloadingSpeed") then
                    gun.ReloadingSpeed.Value = 0.02
                end

                -- if GunDamageValues and GunDamageValues[gun.Name] then
                --     if not Script.Temp.originalDamageValues[gun.Name] then
                --         Script.Temp.originalDamageValues[gun.Name] = {}
                --         for part, dmg in pairs(GunDamageValues[gun.Name]) do
                --             Script.Temp.originalDamageValues[gun.Name][part] = dmg
                --         end
                --     end
                --     for part, _ in pairs(GunDamageValues[gun.Name]) do
                --         GunDamageValues[gun.Name][part] = 9999
                --     end
                -- end
            else
                if Script.Temp.originalGunStats[gun.Name] then
                    for stat, val in pairs(Script.Temp.originalGunStats[gun.Name]) do
                        if gun:FindFirstChild(stat) then
                            gun[stat].Value = val
                        end
                    end
                end
                -- if GunDamageValues and GunDamageValues[gun.Name] and Script.Temp.originalDamageValues[gun.Name] then
                --     for part, val in pairs(Script.Temp.originalDamageValues[gun.Name]) do
                --         GunDamageValues[gun.Name][part] = val
                --     end
                -- end
            end
        end
    end,
})
end,

RedLightGreenLight = function(...)
local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function WinRLGL()
    if not lplr.Character then
        return
    end
    Script.Functions.SafeTeleport(-100.8, 1028, 115)
end

Script.AutoWin.RedLightGreenLight = function()
    local AutoWinRLGL = true
    if Script.Tasks.AutoWinRLGL then
        task.cancel(Script.Tasks.AutoWinRLGL)
        Script.Tasks.AutoWinRLGL = nil
    end
    Script.Tasks.AutoWinRLGL = task.spawn(function()
        repeat
            WinRLGL()
            task.wait(3)
        until not AutoWinRLGL
            or not Library.Toggles.InkGameAutowin.Value
            or Script.GameState ~= "RedLightGreenLight"
        Script.Tasks.AutoWinRLGL = nil
    end)
    return function()
        AutoWinRLGL = false
    end
end

local function FindCarryPrompt(plr)
    if not plr.Character then
        return false
    end
    if not plr.Character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    if not (plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Humanoid").Health > 0) then
        return false
    end

    local CarryPrompt = plr.Character.HumanoidRootPart:FindFirstChild("CarryPrompt")
    return CarryPrompt
end

local function GetAllInjuredPlayers()
    local injured = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == lplr then
            continue
        end
        if plr:GetAttribute("IsDead") then
            continue
        end
        local CarryPrompt = FindCarryPrompt(plr)
        if not CarryPrompt then
            continue
        end
        if plr.Character and plr.Character:FindFirstChild("SafeRedLightGreenLight") then
            continue
        end
        if plr.Character and plr.Character:FindFirstChild("IsBeingHeld") then
            continue
        end
        table.insert(injured, { player = plr, carryPrompt = CarryPrompt })
    end
    return injured
end

Script.OnGame.RedLightGreenLight = function()
    if Library.Toggles.RedLightGodmode.Value then
        Library.Toggles.RedLightGodmode.Callback(true)
    end
    Script.Tasks.RLGLDropdownRefresh = task.spawn(function()
        repeat
            local injured = GetAllInjuredPlayers()
            local names = {}
            for _, entry in ipairs(injured) do
                table.insert(names, entry.player.DisplayName)
            end
            Library.Options.RLGLInjuredPlayer:SetValues(names)
            task.wait(3)
        until Library.Unloaded
    end)
    Script.Connections.RLGLInjuredTableRefresh = Script.Functions.OnceOnGameChanged(function()
        if Script.Tasks.RLGLDropdownRefresh then
            task.cancel(Script.Tasks.RLGLDropdownRefresh)
            Script.Tasks.RLGLDropdownRefresh = nil
        end
        Library.Options.RLGLInjuredPlayer:SetValues({})
        Library.Options.RLGLInjuredPlayer:SetValue(nil)
    end)
end

TabGroup:AddToggle("RedLightGodmode", {
    Text = "Godmode",
    Default = false,
    Callback = function(Value)
        if Script.Connections.RLGLConnDestroyer then
            pcall(function()
                Script.Connections.RLGLConnDestroyer:Disconnect()
            end)
            Script.Connections.RLGLConnDestroyer = nil
        end
        if Script.Connections.RLGL_Connection then
            pcall(function()
                Script.Connections.RLGL_Connection:Disconnect()
            end)
            Script.Connections.RLGL_Connection = nil
        end
        Script.HookMethods.RLGLGodmode = nil
        if not Value then
            Script.Functions.Alert("Red Light Green Light Godmode Disabled", 3)
            return
        end
        if not hookmetamethod then
            Script.Functions.Alert("Your executor doesn't support this :(")
            Library.Toggles.RedLightGodMode:SetValue(false)
            return
        end
        if Script.GameState ~= "RedLightGreenLight" then
            return
        end
        local TrafficLightImage = lplr.PlayerGui:FindFirstChild("ImpactFrames")
            and lplr.PlayerGui.ImpactFrames:FindFirstChild("TrafficLightEmpty")
        local lastRootPartCFrame = nil
        local root = Script.Functions.GetRootPart()
        if root then
            lastRootPartCFrame = root.CFrame
        end
        local isGreenLight = true
        if
            TrafficLightImage
            and ReplicatedStorage:FindFirstChild("Effects")
            and ReplicatedStorage.Effects:FindFirstChild("Images")
            and ReplicatedStorage.Effects.Images:FindFirstChild("TrafficLights")
            and ReplicatedStorage.Effects.Images.TrafficLights:FindFirstChild("GreenLight")
        then
            isGreenLight = TrafficLightImage.Image == ReplicatedStorage.Effects.Images.TrafficLights.GreenLight.Image
        end
        Script.Connections.RLGL_Connection = ReplicatedStorage.Remotes.Effects.OnClientEvent:Connect(
            function(EffectsData)
                if EffectsData.EffectName ~= "TrafficLight" then
                    return
                end
                isGreenLight = EffectsData.GreenLight == true
                local root = Script.Functions.GetRootPart()
                if root then
                    lastRootPartCFrame = root.CFrame
                end
            end
        )
        Script.HookMethods.RLGLGodmode = function(self, method, args)
            if self == "rootCFrame" and method == "FireServer" then
                if not isGreenLight and lastRootPartCFrame then
                    args[1] = lastRootPartCFrame
                end
            end
            return args
        end
        Script.Connections.RLGLConnDestroyer = Script.Functions.OnceOnGameChanged(function()
            Library.Toggles.RedLightGodmode.Callback(false)
        end)
        Script.Functions.Alert("Red Light Green Light Godmode Enabled", 3)
    end,
})

TabGroup:AddButton("Complete Red Light / Green Light", function()
    if Script.GameState ~= "RedLightGreenLight" then
        Script.Functions.Alert("Game not running")
        return
    end
    WinRLGL()
end)

TabGroup:AddButton("Remove Injured Walking", function()
    if Script.GameState ~= "RedLightGreenLight" then
        Script.Functions.Alert("Game not running")
        return
    end
    Library.Toggles.AntiRagdoll.Callback(false)
end)

TabGroup:AddButton("Bring Random Injured Player", function()
    if Script.GameState ~= "RedLightGreenLight" then
        Script.Functions.Alert("Game not running")
        return
    end
    local injured = GetAllInjuredPlayers()[1]
    if not injured then
        Script.Functions.Alert("No injured player found!", 2)
        return
    end
    if lplr.Character and injured.player.Character and injured.player.Character.PrimaryPart then
        Script.Functions.SafeTeleportToCFrame(injured.player.Character:GetPrimaryPartCFrame())
        task.wait(0.2)
        local CarryPrompt = FindCarryPrompt(injured.player)
        if CarryPrompt then
            pcall(function()
                CarryPrompt.HoldDuration = 0
                CarryPrompt:InputHoldBegin()
            end)
        end
        task.wait(0.2)
        WinRLGL()
        task.wait(0.2)
        ReplicatedStorage:WaitForChild("Remotes")
            :WaitForChild("ClickedButton")
            :FireServer(unpack({ { tryingtoleave = true } }))
        task.wait(0.2)
    end
end)

TabGroup:AddDropdown("RLGLInjuredPlayer", {
    Text = "Bring Injured Player",
    Values = {},
    AllowNull = true,
    Callback = function(val)
        if not val then
            return
        end
        local injured = GetAllInjuredPlayers()
        local selected = nil
        for _, entry in ipairs(injured) do
            if entry.player.DisplayName == val then
                selected = entry
                break
            end
        end
        if not selected then
            Script.Functions.Alert("No injured player found!", 2)
            return
        end
        if lplr.Character and selected.player.Character and selected.player.Character.PrimaryPart then
            if Library.Toggles.RedLightGodmode.Value then
                Library.Toggles.RedLightGodmode:SetValue(false)
            end
            Script.Functions.SafeTeleportToCFrame(selected.player.Character:GetPrimaryPartCFrame())
            task.wait(0.2)
            local CarryPrompt = FindCarryPrompt(selected.player)
            if CarryPrompt then
                pcall(function()
                    CarryPrompt.HoldDuration = 0
                    CarryPrompt:InputHoldBegin()
                end)
            end
            task.wait(0.2)
            WinRLGL()
            task.wait(0.2)
            ReplicatedStorage:WaitForChild("Remotes")
                :WaitForChild("ClickedButton")
                :FireServer(unpack({ { tryingtoleave = true } }))
            task.wait(0.2)
        end
    end,
})
end,

Security = function(...)
local TabGroup: ObsidianGroupBox, Script: ScriptType, _: Obsidian = ...
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

TabGroup:AddToggle("Fling Character Hook", {
    Text = "Fling Character Hook",
    Default = false,
    Callback = function(Value)
        if Value then
            local function PatchFlingAnticheat()
                local char = lplr.Character
                if not char then
                    return
                end
                local root = Script.Functions.GetRootPart()
                if not root then
                    return
                end

                local anticheatStates =
                    { "Stun", "Anchor", "RotateDisabled", "CantRun", "InCutscene", "DisableHeadLookAt" }
                if not Script.Temp.FlingAnticheatChildConn then
                    Script.Temp.FlingAnticheatChildConn = char.ChildAdded:Connect(function(child)
                        if table.find(anticheatStates, child.Name) then
                            task.delay(0.01, function()
                                child:Destroy()
                            end)
                        end
                    end)
                end

                if not Script.Temp.FlingAnticheatMT then
                    local mt = getrawmetatable(root)
                    Script.Temp.FlingAnticheatOldNewIndex = mt.__newindex
                    setreadonly(mt, false)
                    mt.__newindex = function(self, key, value)
                        if self == root and key == "Anchored" and value == true then
                            return
                        end
                        return Script.Temp.FlingAnticheatOldNewIndex(self, key, value)
                    end
                    setreadonly(mt, true)
                    Script.Temp.FlingAnticheatMT = mt
                end
            end

            Script.Temp.FlingAnticheatCharConn = lplr.CharacterAdded:Connect(function(char)
                task.wait(1)
                PatchFlingAnticheat()
            end)
            if lplr.Character then
                PatchFlingAnticheat()
            end
            Script.Functions.Alert("Anticheat Patched!", 3)
        else
            if Script.Temp.FlingAnticheatCharConn then
                Script.Temp.FlingAnticheatCharConn:Disconnect()
                Script.Temp.FlingAnticheatCharConn = nil
            end
            if Script.Temp.FlingAnticheatChildConn then
                Script.Temp.FlingAnticheatChildConn:Disconnect()
                Script.Temp.FlingAnticheatChildConn = nil
            end
            if Script.Temp.FlingAnticheatMT and Script.Temp.FlingAnticheatOldNewIndex then
                local root = Script.Functions.GetRootPart()
                if root then
                    local mt = Script.Temp.FlingAnticheatMT
                    setreadonly(mt, false)
                    mt.__newindex = Script.Temp.FlingAnticheatOldNewIndex
                    setreadonly(mt, true)
                end
                Script.Temp.FlingAnticheatMT = nil
                Script.Temp.FlingAnticheatOldNewIndex = nil
            end
            Script.Functions.Alert("Anticheat Patch Disabled!", 3)
        end
    end,
})

TabGroup:AddToggle("Block Anticheat Remote", {
    Text = "Block Anticheat Remote",
    Default = false,
    Callback = function(call)
        if not hookmetamethod then
            return
        end
        Script.HookMethods.Anticheat = nil
        if not call then
            return
        end
        Script.HookMethods.Anticheat = function(self, method, args)
            if self == "TemporaryReachedBindable" and method == "FireServer" then
                if type(args[1]) == "table" and (args[1].FallingPlayer ~= nil or args[1].funnydeath ~= nil) then
                    return nil
                end
            end

            if self == "RandomOtherRemotes" and method == "FireServer" then
                if type(args[1]) == "table" and args[1].FallenOffMap ~= nil then
                    return nil
                end
            end
            return args
        end
    end,
})

TabGroup:AddToggle("AntiAfk", {
    Text = "Anti AFK",
    Default = true,
    Callback = function(Value)
        if Script.Connections.AntiAfkConnection then
            pcall(function()
                Script.Connections.AntiAfkConnection:Disconnect()
            end)
        end
        if not Value then
            return
        end
        Script.Connections.AntiAfkConnection = lplr.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), Script.Camera.CFrame)
            wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), Script.Camera.CFrame)
        end)
    end,
})

TabGroup:AddToggle("StaffDetector", {
    Text = "Staff Detector",
    Default = true,
    Callback = function(Value)
        if Value then
            local STAFF_GROUP_ID = 12398672
            local STAFF_MIN_RANK = 120
            local staffRoles = {
                [120] = "moderator",
                [254] = "dev",
                [255] = "owner",
            }
            Script.Temp.DetectedStaff = Script.Temp.DetectedStaff or {}
            local function checkPlayerStaff(player)
                local success, rank = pcall(function()
                    return player:GetRankInGroup(STAFF_GROUP_ID)
                end)
                if success and rank and rank >= STAFF_MIN_RANK then
                    local roleName = staffRoles[rank] or ("rank " .. tostring(rank))
                    Script.Functions.Alert(
                        "[StaffDetector] Staff detected: " .. player.Name .. " (" .. roleName .. ")",
                        10
                    )
                    Script.Temp.DetectedStaff[player.UserId] = { Name = player.Name, Role = roleName }
                    return true
                end
                return false
            end
            Script.Temp.StaffDetectorConnections = Script.Temp.StaffDetectorConnections or {}
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= lplr then
                    checkPlayerStaff(player)
                end
            end
            Script.Temp.StaffDetectorConnections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
                if player ~= lplr then
                    task.wait(1)
                    checkPlayerStaff(player)
                end
            end)
            Script.Temp.StaffDetectorConnections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
                local staffInfo = Script.Temp.DetectedStaff and Script.Temp.DetectedStaff[player.UserId]
                if staffInfo then
                    Script.Functions.Alert(
                        "[StaffDetector] Staff left: " .. staffInfo.Name .. " (" .. staffInfo.Role .. ")",
                        10
                    )
                    Script.Temp.DetectedStaff[player.UserId] = nil
                end
            end)
        else
            if Script.Temp.StaffDetectorConnections then
                for _, conn in pairs(Script.Temp.StaffDetectorConnections) do
                    pcall(function()
                        conn:Disconnect()
                    end)
                end
                Script.Temp.StaffDetectorConnections = nil
            end
            Script.Temp.DetectedStaff = nil
            Script.Functions.Alert("[StaffDetector] Staff detection disabled.", 3)
        end
    end,
})
end,

TugOfWar = function(...)
local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
                task.wait(Library.Options.AutoPullDelay.Value :: number)
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
end,

Useful = function(...)
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
end,
}

-- If someone somehow found this script
-- This is fork of Voidware!
-- Original scripts discord: discord.gg/voidware
-- Original script owner: Voidware
-- Forked from: https://github.com/VapeVoidware/VW-Add

local repo = "https://raw.githubusercontent.com/NSeydulla/VW-Add/refs/heads/TestingMultiFile/"

--// Setup \\--
if not getgenv().shared then
    getgenv().shared = {}
end

local library = getgenv().shared.Voidware_InkGame_Library
if library then
    local suc = pcall(function()
        library:Unload()
    end)
    if not suc then
        error("[Voidware] Something went wrong while closing another running script")
    end
    local TIMEOUT = 5
    local startTime = tick()
    while getgenv().shared.Voidware_InkGame_Library do
        if tick() - startTime > TIMEOUT then
            error("[Voidware] Timeout while waiting for another script to close")
        end
        task.wait(0.3)
    end
end

pcall(function()
    local isNew = false
    for _, v in ipairs({
        "VW_NSeed",
        "VW_NSeed/ink_game",
        "VW_NSeed/themes",
        "VW_NSeed/ink_game/settings",
        "VW_NSeed/ink_game/themes",
    }) do
        if not isfolder(v) then
            makefolder(v)
            isNew = true
        end
    end

    if isNew then
        writefile("VW_NSeed/themes/default.txt", "Jester")
        writefile("VW_NSeed/ink_game/settings/default.json", "[]")
    end
end)

--// Library \\--
local Library: Obsidian
local SaveManager
local ThemeManager

local loadLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/Obsidian/main/Library.lua"))
if not loadLibrary then
    error("Something wrong with Library")
end
Library = loadLibrary()
getgenv().shared.Voidware_InkGame_Library = Library

local Window = Library:CreateWindow({
    Title = "Voidware - Ink Game",
    Footer = "This is fork of Voidware! Original scripts discord - discord.gg/voidware",
    Center = true,
    AutoShow = true,
    Resizable = true,
    ShowCustomCursor = true,
    TabPadding = 2,
    MenuFadeTime = 0,
})

local Tabs = {
    Main = Window:AddTab("Main", "gamepad-2"),
    Other = Window:AddTab("Other", "settings"),
    Misc = Window:AddTab("Misc", "wrench"),
    Visuals = Window:AddTab("Visuals", "eye"),
    Script = Window:AddTab("Script", "sliders-horizontal"),
}

local TabGroups = {
    RedLightGreenLight = Tabs.Main:AddLeftGroupbox("Red Light / Green Light", "traffic-light"),
    Dalgona = Tabs.Main:AddRightGroupbox("Dalgona", "circle"),
    HideAndSeek = Tabs.Main:AddLeftGroupbox("Hide And Seeek", "search"),
    TugOfWar = Tabs.Main:AddRightGroupbox("Tug Of War", "rope"),
    JumpRope = Tabs.Main:AddLeftGroupbox("Jump Rope", "rope"),
    GlassBridge = Tabs.Main:AddRightGroupbox("Glass Bridge", "bridge"),
    Mingle = Tabs.Main:AddLeftGroupbox("Mingle", "users"),
    Rebel = Tabs.Main:AddRightGroupbox("Rebel", "sword"),

    Player = Tabs.Other:AddLeftGroupbox("Player", "user"),
    Security = Tabs.Other:AddRightGroupbox("Security", "shield"),
    Fun = Tabs.Other:AddLeftGroupbox("Fun", "zap"),
    Useful = Tabs.Other:AddRightGroupbox("Useful Stuff", "star"),
    Interaction = Tabs.Other:AddLeftGroupbox("Interaction", "hand-pointer"),
    AntiDeath = Tabs.Other:AddRightGroupbox("Anti Death", "skull"),
    Checkpoint = Tabs.Other:AddRightGroupbox("Checkpoint", "skull"),

    Misc = Tabs.Misc:AddLeftGroupbox("Misc", "wrench"),
    Emotes = Tabs.Misc:AddRightGroupbox("Emote", "smile"),
    Performance = Tabs.Misc:AddRightGroupbox("Performance", "gauge"),

    MainESP = Tabs.Visuals:AddLeftGroupbox("Main ESP", "eye"),
    HideAndSeekESP = Tabs.Visuals:AddLeftGroupbox("Hide and Seek ESP", "search"),
    ESPSettings = Tabs.Visuals:AddRightGroupbox("ESP Settings", "sliders"),
    FOV = Tabs.Visuals:AddRightGroupbox("FOV settings", "user"),

    Menu = Tabs.Script:AddRightGroupbox("Menu", "menu"),
}

local loadThemeManager =
    loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/Obsidian/main/addons/ThemeManager.lua"))
if not loadThemeManager then
    error("Something wrong with ThemeManager")
end
ThemeManager = loadThemeManager()

local loadSaveManager =
    loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/Obsidian/main/addons/SaveManager.lua"))
if not loadSaveManager then
    error("Something wrong with SaveManager")
end
SaveManager = loadSaveManager()

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:SetFolder("VW_NSeed")
SaveManager:SetFolder("VW_NSeed/ink_game")
SaveManager:BuildConfigSection(Tabs.Script)
ThemeManager:ApplyToTab(Tabs.Script)

--// Script \\--
local Script: ScriptType = {
    repo = repo,
    GameState = "unknown",
    Connections = {
        PlayerCharAdded = {},
        GuardCharAdded = {},
    },
    Tasks = {},
    ESPTable = {
        Player = {},
        Guard = {},
        Door = {},
        None = {},
        Key = {},
        ["Escape Door"] = {},
    },
    AutoWin = {},
    OnGame = {},
    HookMethods = {},
    Temp = {},
    SaveManager = SaveManager,
    ThemeManager = ThemeManager,
    Camera = workspace.CurrentCamera,
    Functions = nil,
}

Script.Functions = Functions(Script, Library)

for TabGroup, group in pairs(GroupFunctions) do
    group(TabGroups[TabGroup], Script, Library)
end

Library:OnUnload(Script.Functions.OnUnload)
task.spawn(function()
    getgenv().shared.VoidwareLoading = nil
    pcall(Script.Functions.OnLoad)
end)
