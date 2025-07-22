-- If someone somehow found this script
-- This is fork of Voidware!
-- Original scripts discord: discord.gg/voidware
-- Original script owner: Voidware
-- Forked from: https://github.com/VapeVoidware/VW-Add

if not getgenv().shared then
    getgenv().shared = {}
end

if getgenv().shared.Voidware_InkGame_Library then
    local suc = pcall(function()
        getgenv().shared.Voidware_InkGame_Library:Unload()
    end)
    if not suc then
        return
    end
    while getgenv().shared.Voidware_InkGame_Library ~= nil do
        task.wait(0.1)
    end
end

pcall(function()
    local isNew = false
    for _, v in pairs({"voidware_linoria", "voidware_linoria/ink_game", "voidware_linoria/themes", "voidware_linoria/ink_game/settings", "voidware_linoria/ink_game/themes"}) do
        if not isfolder(v) then makefolder(v); isNew = true; end
    end

    if isNew then
        pcall(function()
            writefile("voidware_linoria/themes/default.txt", "Jester")
        end)
        pcall(function()
            writefile("voidware_linoria/ink_game/settings/default.json", "[]")
        end)
    end
end)

--// Library \\--
local repo = "https://raw.githubusercontent.com/mstudio45/Obsidian/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
getgenv().shared.Voidware_InkGame_Library = Library
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = getgenv().Library.Options
local Toggles = getgenv().Library.Toggles

local Window = Library:CreateWindow({
    Title = "Voidware - Ink Game",
    Footer = "This is fork of Voidware! Original scripts discord - discord.gg/voidware",
    Center = true,
    AutoShow = true,
    Resizable = true,
    ShowCustomCursor = true,
    TabPadding = 2,
    MenuFadeTime = 0
})

local Tabs = {
    Main = Window:AddTab("Main", "gamepad-2"),
    Other = Window:AddTab("Other", "settings"),
    Misc = Window:AddTab("Misc", "wrench"),
    Visuals = Window:AddTab("Visuals", "eye"),
    ["UI Settings"] = Window:AddTab("UI Settings", "sliders-horizontal"),
}

local PlayerGroup = Tabs.Main:AddLeftGroupbox("Player", "user")
local GreenLightRedLightGroup = Tabs.Main:AddRightGroupbox("Red Light / Green Light", "traffic-light")
local DalgonaGameGroup = Tabs.Main:AddLeftGroupbox("Dalgona Game", "circle")
local HideAndSeekGroup = Tabs.Main:AddRightGroupbox("Hide And Seeek", "search")
local TugOfWarGroup = Tabs.Main:AddLeftGroupbox("Tug Of War", "rope")
local JumpRopeGroup = Tabs.Main:AddRightGroupbox("Jump Rope", "rope")
local GlassBridgeGroup = Tabs.Main:AddLeftGroupbox("Glass Bridge", "bridge")
local MingleGroup = Tabs.Main:AddRightGroupbox("Mingle", "users")
local SecurityGroup = Tabs.Main:AddLeftGroupbox("Security", "shield")
local RebelGroup = Tabs.Main:AddRightGroupbox("Rebel", "sword")

local FunGroup = Tabs.Other:AddLeftGroupbox("Fun", "zap")
local UsefulGroup = Tabs.Other:AddRightGroupbox("Useful Stuff", "star")
local InteractionGroup = Tabs.Other:AddLeftGroupbox("Interaction", "hand-pointer")
local AntiDeathGroup = Tabs.Other:AddRightGroupbox("Anti Death", "skull")

local MiscGroup = Tabs.Misc:AddLeftGroupbox("Misc", "wrench")
local EmotesGroup = Tabs.Misc:AddRightGroupbox("Emote", "smile")
local PerformanceGroup = Tabs.Misc:AddRightGroupbox("Performance", "gauge")

local MainESPGroup = Tabs.Visuals:AddLeftGroupbox("Main ESP", "eye")
local HASESPGroup = Tabs.Visuals:AddLeftGroupbox("Hide and Seek ESP", "search")
local ESPSettingsGroup = Tabs.Visuals:AddRightGroupbox("ESP Settings", "sliders")
local FOVGroupBox = Tabs.Visuals:AddRightGroupbox("FOV settings", "user")

local MenuGroup = Tabs["UI Settings"]:AddRightGroupbox("Menu", "menu")

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:SetFolder("voidware_linoria")
SaveManager:SetFolder("voidware_linoria/ink_game")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

local Script = {
    GameState = "unknown",
    Services = setmetatable({}, {
        __index = function(self, key)
            local suc, service = pcall(game.GetService, game, key)
            if suc and service then
                self[key] = service
                return service
            else
                warn(`[Services] Warning: "{key}" is not a valid Roblox service.`)
                return nil
            end
        end
    }),
    Connections = {
        PlayerCharAdded = {},
        GuardCharAdded = {}
    },
    Tasks = {},
    Functions = {},
    ESPTable = {
        Player = {},
        Guard = {},
        Door = {},
        Hider = {},
        Seeker = {},
        None = {},
        Key = {},
        ["Escape Door"] = {}
    },
    HookMethods = {},
    Temp = {}
}

Script.Temp.OriginalNameCall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    for _, func in pairs(Script.HookMethods) do
        args = func(tostring(self), method, args)
        if not args then return end
    end

    return Script.Temp.OriginalNameCall(self, unpack(args))
end)

local Players = Script.Services.Players
local Lighting = Script.Services.Lighting
local RunService = Script.Services.RunService
local TweenService = Script.Services.TweenService
local UserInputService = Script.Services.UserInputService
local ReplicatedStorage = Script.Services.ReplicatedStorage
local ProximityPromptService = Script.Services.ProximityPromptService
local VirtualUser = Script.Services.VirtualUser

local lplr = Players.LocalPlayer

local camera = workspace.CurrentCamera

function Script.Functions.OnLoad()
    pcall(function()
        Script.Functions.OnGameStateChange()
    end)
    Script.Connections.OnGameStateChange = workspace:WaitForChild("Values"):WaitForChild("CurrentGame"):GetPropertyChangedSignal("Value")
        :Connect(
            Script.Functions.OnGameStateChange
        )
    for _, player in pairs(Players:GetPlayers()) do
        if player == lplr then continue end
        Script.Functions.SetupPlayerConnection(player)
    end
    Script.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
        if player == lplr then return end
        Script.Functions.SetupPlayerConnection(player)
    end)
    task.spawn(function()
        Script.Functions.RefreshEmoteList()
        local Animations = ReplicatedStorage:WaitForChild("Animations")
        local Emotes = Animations:WaitForChild("Emotes")
        Library:GiveSignal(Emotes.ChildAdded:Connect(Script.Functions.RefreshEmoteList))
        Library:GiveSignal(Emotes.ChildRemoved:Connect(Script.Functions.RefreshEmoteList))
    end)
    Library:GiveSignal(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        if workspace.CurrentCamera then
            camera = workspace.CurrentCamera
        end
    end))
    SaveManager:LoadAutoloadConfig()
end

Library:OnUnload(function()
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
    pcall(Script.Functions.TeleportBackFromSafe)
    getgenv().shared.Voidware_InkGame_Library = nil
end)

function Script.Functions.SetupPlayerConnection(player: Player)
    if player.Character then
        if Toggles.PlayerESP.Value then
            Script.Functions.PlayerESP(player)
        end
    end

    Script.Connections.PlayerCharAdded[player.Name] = player.CharacterAdded:Connect(function(newCharacter)
        task.delay(0.1, function()
            if Toggles.PlayerESP.Value then
                Script.Functions.PlayerESP(player)
            end
        end)
    end)
end

function Script.Functions.SafeRequire(module)
    if Script.Temp[tostring(module)] then return Script.Temp[tostring(module)] end
    local suc, err = pcall(function()
        return require(module)
    end)
    if not suc then
        Script.Functions.Alert("[SafeRequire]: Failure loading "..tostring(module).." ("..tostring(err)..")")
    else
        Script.Temp[tostring(module)] = err
    end
    return suc and err
end

function Script.Functions.Alert(message: string, time_obj: number)
    Library:Notify(message, time_obj or 5)

    local sound = Instance.new("Sound", workspace) do
        sound.SoundId = "rbxassetid://4590662766"
        sound.Volume = 2
        sound.PlayOnRemove = true
        sound:Destroy()
    end
end

function Script.Functions.GetRootPart()
    if not lplr.Character then return end
    return lplr.Character:WaitForChild("HumanoidRootPart", 10)
end

function Script.Functions.GetHumanoid()
    if not lplr.Character then return end
    return lplr.Character:WaitForChild("Humanoid", 10)
end

function Script.Functions.DistanceFromCharacter(position: Instance | Vector3)
    if typeof(position) == "Instance" then
        position = position:GetPivot().Position
    end
    return (camera.CFrame.Position - position).Magnitude
end

function Script.Functions.RestartRemotesScript()
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

function Script.Functions.OnGameStateChange()
    Script.Temp.OldDeathLocation = nil
    Script.GameState = workspace.Values.CurrentGame.Value
    print("Game State: '"..Script.GameState.."'")
    if Script.GameState then
        Script.GameState = tostring(Script.GameState)
    end

    if Script.GameState and Toggles.InkGameAutowin.Value then
        Script.Functions.HandleAutowin()
    end

    if Script.GameState == "RedLightGreenLight" then
        if Toggles.RedLightGodmode.Value then
            Toggles.RedLightGodmode.Callback(true)
        end
        Script.Tasks.RLGLDropdownRefresh = task.spawn(function()
            repeat
                local injured = Script.Functions.GetAllInjuredPlayers()
                local names = {}
                for _, entry in ipairs(injured) do
                    table.insert(names, entry.player.DisplayName)
                end
                Options.RLGLInjuredPlayer:SetValues(names)
                task.wait(3)
            until Library.Unloaded
        end)
        Script.Connections.RLGLInjuredTableRefresh = Script.Functions.OnceOnGameChanged(function()
            task.cancel(Script.Tasks.RLGLDropdownRefresh)
            Options.RLGLInjuredPlayer:SetValues({})
            Options.RLGLInjuredPlayer:SetValue(nil)
        end)
    elseif Script.GameState == "Dalgona" then
        if Toggles.ImmuneDalgonaGame.Value then
            Toggles.ImmuneDalgonaGame.Callback(true)
        end
    elseif Script.GameState == "HideAndSeek" then
        if Toggles.KeyESP.Value then
            Toggles.KeyESP.Callback(true)
        end
        if Toggles.DoorESP.Value then
            Toggles.DoorESP.Callback(true)
        end
        if Toggles.EscapeDoorESP.Value then
            Toggles.EscapeDoorESP.Callback(true)
        end
        task.delay(1, function()
            for _, esp in pairs(Script.ESPTable["Player"]) do
                Script.Functions.ApplyHiderSeekerESP(esp)
            end
        end)
    elseif Script.GameState == "TugOfWar" then
        if Toggles.AutoPull.Value then
            Toggles.AutoPull.Callback(true)
        end
    elseif Script.GameState == "Mingle" then
        if Toggles.AutoMingleQTE.Value then
            Toggles.AutoMingleQTE.Callback(true)
        end
    elseif Script.GameState == "GlassBridge" then
        if Toggles.RevealGlassBridge.Value then
            local bridge = workspace:WaitForChild("GlassBridge", 10)
            if not bridge then
                Script.Functions.Alert("[Glass Bridge]: glass bridge object not found! please retoggle the toggle")
            else
                Toggles.RevealGlassBridge.Callback(true)
            end
        end
    end
end

function Script.Functions.OnceOnGameChanged(func)
    return workspace:WaitForChild("Values"):WaitForChild("CurrentGame"):GetPropertyChangedSignal("Value"):Once(func)
end

function Script.Functions.ESP(args: ESP)
    if not args.Object then return Script.Functions.Alert("ESP Object is nil") end

    local ESPManager = {
        Object = args.Object,
        Text = args.Text or "No Text",
        TextParent = args.TextParent,
        Color = args.Color or Color3.new(),
        Offset = args.Offset or Vector3.zero,
        Type = args.Type or "None",

        Highlights = {},
        Humanoid = nil,

        Connections = {}
    }

    local tableIndex = #Script.ESPTable[ESPManager.Type] + 1

    local Highlight = function(part)
        local highlight = Instance.new("BoxHandleAdornment")
        highlight.Adornee = part
        highlight.AlwaysOnTop = true
        highlight.ZIndex = 5
        highlight.Size = part.Size
        highlight.Color3 = ESPManager.Color
        highlight.Transparency = Options.ESPTransparency.Value
        highlight.Parent = part
        table.insert(ESPManager.Highlights, highlight)
    end
    if ESPManager.Object:IsA("BasePart") then
        Highlight(ESPManager.Object)
    end
    for _, part in ipairs(ESPManager.Object:GetChildren()) do
        if part:IsA("BasePart") then
            Highlight(part)
        end
    end

    local billboardGui = Instance.new("BillboardGui") do
        billboardGui.Adornee = ESPManager.TextParent or ESPManager.Object
        billboardGui.AlwaysOnTop = true
        billboardGui.ClipsDescendants = false
        billboardGui.Size = UDim2.new(0, 1, 0, 1)
        billboardGui.StudsOffset = ESPManager.Offset
        billboardGui.Parent = ESPManager.TextParent or ESPManager.Object
    end

    local textLabel = Instance.new("TextLabel") do
        textLabel.BackgroundTransparency = 1
        textLabel.Font = Enum.Font.Oswald
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.Text = ESPManager.Text
        textLabel.TextColor3 = ESPManager.Color
        textLabel.TextSize = Options.ESPTextSize.Value
        textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        textLabel.TextStrokeTransparency = 0.75
        textLabel.Parent = billboardGui
    end

    function ESPManager.SetColor(newColor: Color3)
        ESPManager.Color = newColor

        for _, highlight in pairs(ESPManager.Highlights) do
            highlight.Color3 = newColor
        end

        textLabel.TextColor3 = newColor
    end

    function ESPManager.Destroy()
        for _, conn in pairs(ESPManager.Connections) do
            pcall(function()
                conn:Disconnect()
            end)
        end

        for _, highlight in pairs(ESPManager.Highlights) do
            highlight:Destroy()
        end
        if billboardGui then billboardGui:Destroy() end

        if Script.ESPTable[ESPManager.Type][tableIndex] then
            Script.ESPTable[ESPManager.Type][tableIndex] = nil
        end
    end

    function ESPManager.GiveSignal(signal)
        table.insert(ESPManager.Connections, signal)
    end

    ESPManager.GiveSignal(RunService.RenderStepped:Connect(function()
        if not ESPManager.Object or not ESPManager.Object:IsDescendantOf(workspace) then
            ESPManager.Destroy()
            return
        end

        for _, highlight in pairs(ESPManager.Highlights) do
            highlight.Transparency = Toggles.ESPHighlight.Value and Options.ESPTransparency.Value or 1
        end

        textLabel.TextSize = Options.ESPTextSize.Value

        if Toggles.ESPDistance.Value then
            textLabel.Text = string.format("%s\n[%s]", ESPManager.Text, math.floor(Script.Functions.DistanceFromCharacter(ESPManager.Object)))
        else
            textLabel.Text = ESPManager.Text
        end
    end))

    if ESPManager.Type == "Player" and Script.GameState == "HideAndSeek" then
        Script.Functions.ApplyHiderSeekerESP(ESPManager)
    end

    Script.ESPTable[ESPManager.Type][tableIndex] = ESPManager
    return ESPManager
end

function Script.Functions.GuardESP(character)
    if character then
        task.spawn(function()
            if not character:WaitForChild("Humanoid", 5) then
                Script.Functions.Alert('Guard finded, but Humanoid child not')
            else
                local guardESP = Script.Functions.ESP({
                    Object = character,
                    Text = ".",
                    Color = Options.GuardESPColor.Value,
                    Offset = Vector3.new(0, 4, 0),
                    Type = "Guard"
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

function Script.Functions.PlayerESP(player: Player)
    if not (player.Character and player.Character.PrimaryPart and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0) then return end

    local playerESP = Script.Functions.ESP({
        Type = "Player",
        Object = player.Character,
        Text = string.format("%s [%s]", player.DisplayName, math.ceil(player.Character.Humanoid.Health)),
        TextParent = player.Character.PrimaryPart,
        Offset = Vector3.new(0, 1, 0),
        Color = Options.PlayerESPColor.Value
    })

    playerESP.GiveSignal(player.Character.Humanoid.HealthChanged:Connect(function(newHealth)
        if newHealth > 0 then
            playerESP.Text = string.format("%s [%s]", player.DisplayName, math.ceil(newHealth))
        else
            playerESP.Destroy()
        end
    end))
end

function Script.Functions.ApplyHiderSeekerESP(esp)
    if esp.Connections.HASPlayerConn then
        esp.Connections.HASPlayerConn:Disconnect()
    end
    if esp.Object:FindFirstChild("BlueVest") then
        esp.Connections.HASPlayerConn = Script.Functions.OnceOnGameChanged(function()
            esp.SetColor(Options['PlayerESPColor'].Value)
            esp.Text = esp.Text:gsub('%(Hider%)', "")
        end)
        esp.SetColor(Options['HiderESPColor'].Value)
        esp.Text = esp.Text.."(Hider)"
    end
    if not esp.Object:FindFirstChild("BlueVest") then
        esp.Connections.HASPlayerConn = Script.Functions.OnceOnGameChanged(function()
            esp.SetColor(Options['PlayerESPColor'].Value)
            esp.Text = esp.Text:gsub('%(Seeker%)', "")
        end)
        esp.SetColor(Options['SeekerESPColor'].Value)
        esp.Text = esp.Text.."(Seeker)"
    end
end

function Script.Functions.KeyESP(key)
    if string.find(key.Name, "DroppedKey") then
        Script.Functions.ESP({
            Object = key,
            Text = key.Name:gsub("DroppedKey", "") .. " key",
            Color = Options.KeyESPColor.Value,
            Offset = Vector3.new(0, 1, 0),
            Type = "Key",
        })
    end
end

function Script.Functions.DoorESP(door)
    if door.Name ~= "FullDoorAnimated" then return end
    local keyNeeded = door:GetAttribute("KeyNeeded")
    keyNeeded = keyNeeded and " (Key: "..keyNeeded..")" or ""
    Script.Functions.ESP({
        Object = door,
        Text = "Door" .. keyNeeded,
        Color = Options.DoorESPColor.Value,
        Offset = Vector3.new(0, 2, 0),
        Type = "Door",
    })
end

function Script.Functions.EscapeDoorESP(door)
    if not door:FindFirstChild("IgnoreBorders") then
        Script.Functions.ESP({
            Object = door,
            Text = "Escape Door",
            Color = Options.EscapeDoorESPColor.Value,
            Offset = Vector3.new(0, 2, 0),
            Type = "Escape Door",
        })
    end
end

function Script.Functions.ExecuteClick()
    ReplicatedStorage:WaitForChild("Replication"):WaitForChild("Event"):FireServer(unpack({"Clicked"}))
end

function Script.Functions.CompleteDalgonaGame()
    Script.Functions.ExecuteClick()
    Script.Functions.GetDalgonaRemote():FireServer(unpack({{Completed = true}}))
    Script.Functions.GetDalgonaRemote():FireServer(unpack({{Success = true}}))
end

function Script.Functions.BypassDalgonaGame()
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
            elseif obj:IsA("Model") and not obj.Name:match("Outline$") and obj.Name ~= "Pick" and obj.Name ~= "RedDot" then
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

    local DalgonaRemote = Script.Functions.GetDalgonaRemote()

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
                Position = shapeModel.shape.Position + Vector3.new(0, 0.5, 0)
            }):Play()
        end

        if shapeModel then
            for _, part in pairs(shapeModel:GetChildren()) do
                if part.Name == "DalgonaClickPart" and part:IsA("BasePart") then
                    TweenService:Create(part, TweenInfo.new(2, Enum.EasingStyle.Quad), {
                        Transparency = 1
                    }):Play()
                end
            end
        end

        if pickModel and pickModel.Parent then
            TweenService:Create(pickModel, TweenInfo.new(2, Enum.EasingStyle.Quad), {
                Transparency = 1
            }):Play()
        end
        if redDotModel and redDotModel.Parent then
            TweenService:Create(redDotModel, TweenInfo.new(2, Enum.EasingStyle.Quad), {
                Transparency = 1
            }):Play()
        end

        if pickViewportModel then
            for _, part in pairs(pickViewportModel:GetDescendants()) do
                if part:IsA("BasePart") then
                    TweenService:Create(part, TweenInfo.new(2, Enum.EasingStyle.Quad), {
                        Transparency = 1
                    }):Play()
                end
            end
        end

        if HumanoidRootPart then
            TweenService:Create(CurrentCamera, TweenInfo.new(2, Enum.EasingStyle.Quad), {
                CFrame = HumanoidRootPart.CFrame * CFrame.new(0.0841674805, 8.45438766, 6.69675446, 0.999918401, -0.00898250192, 0.00907994807, 3.31699681e-08, 0.710912943, 0.703280032, -0.0127722733, -0.703222632, 0.710854948)
            }):Play()
        end

        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 1
                part.CanCollide = false
            end
        end

        DalgonaRemote:FireServer({
            Success = true
        })

        task.wait(2)

        for _, obj in pairs({shapeModel, outlineModel, pickModel, redDotModel, progressBar}) do
            if obj and obj.Parent then
                obj:Destroy()
            end
        end

        UserInputService.MouseIconEnabled = true
        if PlayerGui:FindFirstChild("Hotbar") and PlayerGui.Hotbar:FindFirstChild("Backpack") then
            TweenService:Create(PlayerGui.Hotbar.Backpack, TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
                Position = UDim2.new(0, 0, 0, 0)
            }):Play()
        end
        if progressBar then
            DebrisBD:Fire(progressBar, 2)
            TweenService:Create(progressBar, TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
                Position = UDim2.new(progressBar.Position.X.Scale, 0, progressBar.Position.Y.Scale + 1, 0)
            }):Play()
        end

        task.wait(0.5)
        cameraOverrideActive = false

        CurrentCamera.CameraType = Enum.CameraType.Custom
        if Humanoid then
            CurrentCamera.CameraSubject = Humanoid
        end
        CurrentCamera.FieldOfView = originalFieldOfView or 70

        camera = CurrentCamera
    end)

    if Script.Connections.cameraOverrideConnection then
        Script.Connections.cameraOverrideConnection:Disconnect()
        Script.Connections.cameraOverrideConnection = nil
    end
    Script.Connections.cameraOverrideConnection = RunService.RenderStepped:Connect(function()
        if not cameraOverrideActive then
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

        for _, obj in pairs({shapeModel, outlineModel, pickModel, redDotModel, progressBar}) do
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

        camera = CurrentCamera
    end
end

function Script.Functions.GetDalgonaRemote()
    return ReplicatedStorage:WaitForChild("Remotes", 1):WaitForChild("DALGONATEMPREMPTE", 1)
end

function Script.Functions.RestoreVisibility(character)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "BoneCustom" then
            if part.Transparency >= 0.99 or part.LocalTransparencyModifier >= 0.99 then
                part.Transparency = 0
                part.LocalTransparencyModifier = 0
            end
        end
    end

    pcall(function()
        character.HumanoidRootPart.Transparency = 1
    end)
    pcall(function()
        character.Head.BoneCustom.Transparency = 1
    end)

    for _, item in pairs(character:GetChildren()) do
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

function Script.Functions.CheckPlayersVisibility()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            Script.Functions.RestoreVisibility(player.Character)
        end
    end
end

function Script.Functions.DisableAntiFling()
    if Toggles.AntiFlingToggle.Value then
        Toggles.AntiFlingToggle:SetValue(false)
    end
end

function Script.Functions.EnableAntiFling()
    if not Toggles.AntiFlingToggle.Value then
        Toggles.AntiFlingToggle:SetValue(true)
    end
end

function Script.Functions.TeleportSafe()
    if not lplr.Character then return end
    pcall(function()
        Script.Temp.OldLocation = CFrame.new(Script.Functions.GetRootPart().Position)
    end)
    Script.Functions.DisableAntiFling()
    lplr.Character:PivotTo(CFrame.new(Vector3.new(-108, 329.1, 462.1)))
end

function Script.Functions.TeleportBackFromSafe()
    local OldLocation = Script.Temp.OldLocation
    if not OldLocation then
        Script.Functions.Alert("[Invalid location]")
        return
    end
    if not lplr.Character then return end
    Script.Functions.DisableAntiFling()
    lplr.Character:PivotTo(OldLocation)
end

function Script.Functions.TeleportSafeHidingSpot()
    if not lplr.Character then return end
    Script.Functions.DisableAntiFling()
    lplr.Character:PivotTo(CFrame.new(Vector3.new(229.9, 1005.3, 169.4)))
end

local function isGuard(model)
    if string.find(model.Name, "Rebel") or string.find(model.Name, "HallwayGuard") or string.find(string.lower(model.Name), "aggro") then
        return true
    end
    return false
end

MainESPGroup:AddToggle("PlayerESP", {
    Text = "Player",
    Default = false,
    Callback = function(Value)
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player == lplr then continue end
                Script.Functions.PlayerESP(player)
            end
        else
            for _, esp in pairs(Script.ESPTable["Player"]) do
                esp.Destroy()
            end
        end
    end
}):AddColorPicker("PlayerESPColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        for _, esp in pairs(Script.ESPTable["Player"]) do
            esp.SetColor(Value)
        end
    end
})

MainESPGroup:AddToggle("GuardESP", {
    Text = "Guard",
    Default = false,
    Callback = function(Value)
        if Script.Connections.GuardAddedConnection then
            Script.Connections.GuardAddedConnection:Disconnect()
            Script.Connections.GuardAddedConnection = nil
        end
        if Value then
            local live = workspace:FindFirstChild("Live")
            if not live then return end
            Script.Connections.GuardAddedConnection = live.ChildAdded:Connect(function(v)
                if isGuard(v) then
                    Script.Functions.GuardESP(v)
                end
            end)
            for _, child in pairs(live:GetChildren()) do
                if isGuard(child) then
                    if child:FindFirstChild("Dead") then continue end
                    Script.Functions.GuardESP(child)
                end
            end
        else
            for _, esp in pairs(Script.ESPTable["Guard"]) do
                esp.Destroy()
            end
        end
    end
}):AddColorPicker("GuardESPColor", {
    Default = Color3.fromRGB(200, 100, 200),
    Callback = function(Value)
        for _, esp in pairs(Script.ESPTable["Guard"]) do
            esp.SetColor(Value)
        end
    end
})

HASESPGroup:AddLabel("Hider"):AddColorPicker("HiderESPColor", {
    Default = Color3.fromRGB(0, 255, 0),
    Callback = function(Value)
        if Script.GameState ~= "HideAndSeek" then return end
        for _, esp in pairs(Script.ESPTable['Player']) do
            if esp.Text:sub(-7) == "(Hider)" then
                esp.SetColor(Value)
            end
        end
    end,
})

HASESPGroup:AddLabel("Seeker"):AddColorPicker("SeekerESPColor", {
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        if Script.GameState ~= "HideAndSeek" then return end
        for _, esp in pairs(Script.ESPTable['Player']) do
            if esp.Text:sub(-8) == "(Seeker)" then
                esp.SetColor(Value)
            end
        end
    end,
})

HASESPGroup:AddToggle("KeyESP", {
    Text = "Key",
    Default = false,
    Callback = function(Value)
        if Script.Connections["KeyESPDestroyer"] then
            Script.Connections["KeyESPDestroyer"]:Disconnect()
            Script.Connections["KeyESPDestroyer"] = nil
        end
        if Script.Connections["KeyESPDescendant"] then
            Script.Connections["KeyESPDescendant"]:Disconnect()
            Script.Connections["KeyESPDescendant"] = nil
        end
        if Value then
            if Script.GameState ~= "HideAndSeek" then return end
            local EffectsFolder = workspace:FindFirstChild("Effects")
            for _, key in pairs(EffectsFolder:GetChildren()) do
                Script.Functions.KeyESP(key)
            end
            Script.Connections["KeyESPDescendant"] = EffectsFolder.DescendantAdded:Connect(function(descendant)
                Script.Functions.KeyESP(descendant)
            end)
            Script.Connections["KeyESPDestroyer"] = Script.Functions.OnceOnGameChanged(function()
                Toggles.KeyESP.Callback(false)
            end)
        else
            for _, esp in pairs(Script.ESPTable["Key"]) do
                esp.Destroy()
            end
        end
    end
}):AddColorPicker("KeyESPColor", {
    Default = Color3.fromRGB(255, 255, 0),
    Callback = function(Value)
        for _, esp in pairs(Script.ESPTable["Key"]) do
            esp.SetColor(Value)
        end
    end
})

HASESPGroup:AddToggle("DoorESP", {
    Text = "Door",
    Default = false,
    Callback = function(Value)
        if Script.Connections["DoorESPDestroyer"] then
            Script.Connections["DoorESPDestroyer"]:Disconnect()
            Script.Connections["DoorESPDestroyer"] = nil
        end
        if Script.Connections["DoorESPDescendant"] then
            Script.Connections["DoorESPDescendant"]:Disconnect()
            Script.Connections["DoorESPDescendant"] = nil
        end
        if Value then
            if Script.GameState ~= "HideAndSeek" then return end
            local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")
            if not hideAndSeekMap then
                Script.Functions.Alert("Hide And Seek map not found!")
                return
            end
            local newFixedDoors = hideAndSeekMap:FindFirstChild("NEWFIXEDDOORS")
            for _, floor in pairs(newFixedDoors and newFixedDoors:GetChildren() or {}) do
                for _, door in pairs(floor:GetChildren()) do
                    Script.Functions.DoorESP(door)
                end
            end
            Script.Connections["DoorESPDescendant"] = newFixedDoors.DescendantAdded:Connect(function(descendant)
                Script.Functions.DoorESP(descendant)
            end)
            Script.Connections["DoorESPDestroyer"] = Script.Functions.OnceOnGameChanged(function()
                Toggles.DoorESP.Callback(false)
            end)
        else
            for _, esp in pairs(Script.ESPTable["Door"]) do
                esp.Destroy()
            end
        end
    end
}):AddColorPicker("DoorESPColor", {
    Default = Color3.fromRGB(0, 128, 255),
    Callback = function(Value)
        for _, esp in pairs(Script.ESPTable["Door"]) do
            esp.SetColor(Value)
        end
    end
})

HASESPGroup:AddToggle("EscapeDoorESP", {
    Text = "EscapeDoor",
    Default = false,
    Callback = function(Value)
        if Script.Connections["EscapeDoorESPDestroyer"] then
            Script.Connections["EscapeDoorESPDestroyer"]:Disconnect()
            Script.Connections["EscapeDoorESPDestroyer"] = nil
        end
        if Script.Connections["EscapeDoorESPDescendant"] then
            Script.Connections["EscapeDoorESPDescendant"]:Disconnect()
            Script.Connections["EscapeDoorESPDescendant"] = nil
        end
        if Value then
            if Script.GameState ~= "HideAndSeek" then return end
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
                            Script.Functions.EscapeDoorESP(door)
                        end
                    end
                end
            end
            Script.Connections["EscapeDoorESPDescendant"] = newFixedDoors.DescendantAdded:Connect(function(descendant)
                if descendant.Name == "EXITDOOR" then
                    Script.Functions.EscapeDoorESP(descendant)
                end
            end)
            Script.Connections["EscapeDoorESPDestroyer"] = Script.Functions.OnceOnGameChanged(function()
                Toggles.EscapeDoorESP.Callback(false)
            end)
        else
            for _, esp in pairs(Script.ESPTable["Escape Door"]) do
                esp.Destroy()
            end
        end
    end
}):AddColorPicker("EscapeDoorESPColor", {
    Default = Color3.fromRGB(255, 0, 255),
    Callback = function(Value)
        for _, esp in pairs(Script.ESPTable["Escape Door"]) do
            esp.SetColor(Value)
        end
    end
})

ESPSettingsGroup:AddToggle("ESPHighlight", {
    Text = "Enable Highlight",
    Default = true,
})

ESPSettingsGroup:AddToggle("ESPDistance", {
    Text = "Show Distance",
    Default = true,
})

ESPSettingsGroup:AddSlider("ESPTransparency", {
    Text = "Transparency",
    Default = 0.75,
    Min = 0,
    Max = 1,
    Rounding = 2
})

ESPSettingsGroup:AddSlider("ESPTextSize", {
    Text = "Text Size",
    Default = 22,
    Min = 16,
    Max = 26,
    Rounding = 0
})


FOVGroupBox:AddToggle("FOVToggle", {
    Text = "FOV",
    Default = false,
    Callback = function(Value)
        if Script.Tasks.FOVChangeTask then
            task.cancel(Script.Tasks.FOVChangeTask)
            Script.Tasks.FOVChangeTask = nil
        end
        if Value then
            Script.Temp.OldFOV = camera and camera.FieldOfView or 60
            Script.Tasks.FOVChangeTask = task.spawn(function()
                while Toggles.FOVToggle.Value and not Library.Unloaded do
                    task.wait()
                    if not camera then continue end
                    camera.FieldOfView = Options.FOVSlider.Value
                end
            end)
        end
    end
})

FOVGroupBox:AddSlider("FOVSlider", {
    Text = "FOV",
    Default = 60,
    Min = 10,
    Max = 120,
    Rounding = 1
})

InteractionGroup:AddToggle("NoInteractDelay", {
    Text = "Instant Interact",
    Default = false,
    Callback = function(Value)
        if Script.Connections.NoInteractDelayConnection then
            Script.Connections.NoInteractDelayConnection:Disconnect()
            Script.Connections.NoInteractDelayConnection = nil
        end
        if not Value then return end
        Script.Connections.NoInteractDelayConnection = ProximityPromptService.PromptShown:Connect(function(prompt)
            prompt.HoldDuration = 0
        end)
    end
})

Script.Temp.ActivePrompts = {}

function Script.Functions.PromptDistChange(prompt)
    if prompt:IsA("ProximityPrompt") then
        if not Script.Temp.ActivePrompts[prompt] then
            Script.Temp.ActivePrompts[prompt] = prompt.MaxActivationDistance
        end
        if Toggles.PromptReachToggle.Value then
            prompt.MaxActivationDistance = Script.Temp.ActivePrompts[prompt] * Options.PromptReachSlider.Value
        else
            prompt.MaxActivationDistance = Script.Temp.ActivePrompts[prompt]
        end
    end
end

function Script.Functions.AllPromptDistChange()
    if not Toggles.PromptReachToggle.Value then return end
    for _, prompt in pairs(Script.Temp.ActivePrompts) do
        Script.Functions.PromptDistChange(prompt)
    end
end

InteractionGroup:AddToggle("PromptReachToggle", {
    Text = "Interaction Reach",
    Default = false,
    Callback = function(Value)
        if Script.Connections.PromptReachConnection then
            Script.Connections.PromptReachConnection:Disconnect()
            Script.Connections.PromptReachConnection = nil
        end
        if not Value then
            Script.Functions.AllPromptDistChange()
            return
        end
        Script.Connections.PromptReachConnection = workspace.DescendantAdded:Connect(function(prompt)
            Script.Functions.PromptDistChange(prompt)
        end)
    end
})

InteractionGroup:AddSlider("PromptReachSlider", {
    Text = "Interaction Reach Multiplier",
    Default = 1.5,
    Min = 1,
    Max = 2,
    Rounding = 1,
    Callback = function(_)
        Script.Functions.AllPromptDistChange()
    end
})

function Script.Functions.FindCarryPrompt(plr)
    if not plr.Character then return false end
    if not plr.Character:FindFirstChild("HumanoidRootPart") then return false end
    if not (plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Humanoid").Health > 0) then return false end

    local CarryPrompt = plr.Character.HumanoidRootPart:FindFirstChild("CarryPrompt")
    return CarryPrompt
end

function Script.Functions.GetAllInjuredPlayers()
    local injured = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == lplr then continue end
        if plr:GetAttribute("IsDead") then continue end
        local CarryPrompt = Script.Functions.FindCarryPrompt(plr)
        if not CarryPrompt then continue end
        if plr.Character and plr.Character:FindFirstChild("SafeRedLightGreenLight") then continue end
        if plr.Character and plr.Character:FindFirstChild("IsBeingHeld") then continue end
        table.insert(injured, {player = plr, carryPrompt = CarryPrompt})
    end
    return injured
end

function Script.Functions.WinRLGL()
    if not lplr.Character then return end
    Script.Functions.DisableAntiFling()
    lplr.Character:PivotTo(CFrame.new(Vector3.new(-100.8, 1030, 115)))
end

GreenLightRedLightGroup:AddToggle("RedLightGodmode", {
    Text = "Godmode",
    Default = false,
    Callback = function(Value)
        if Script.Connections.RLGLConnDestroyer then
            pcall(function() Script.Connections.RLGLConnDestroyer:Disconnect() end)
            Script.Connections.RLGLConnDestroyer = nil
        end
        if Script.Connections.RLGL_Connection then
            pcall(function() Script.Connections.RLGL_Connection:Disconnect() end)
            Script.Connections.RLGL_Connection = nil
        end
        Script.HookMethods.RLGLGodmode = nil
        if not Value then
            Script.Functions.Alert("Red Light Green Light Godmode Disabled", 3)
            return
        end
        if not hookmetamethod then
            Script.Functions.Alert("Your executor doesn't support this :(")
            Toggles.RedLightGodMode:SetValue(false)
            return
        end
        if Script.GameState ~= "RedLightGreenLight" then return end
        local TrafficLightImage = lplr.PlayerGui:FindFirstChild("ImpactFrames") and lplr.PlayerGui.ImpactFrames:FindFirstChild("TrafficLightEmpty")
        local lastRootPartCFrame = nil
        local isGreenLight = true
        if TrafficLightImage and ReplicatedStorage:FindFirstChild("Effects") and ReplicatedStorage.Effects:FindFirstChild("Images") and ReplicatedStorage.Effects.Images:FindFirstChild("TrafficLights") and ReplicatedStorage.Effects.Images.TrafficLights:FindFirstChild("GreenLight") then
            isGreenLight = TrafficLightImage.Image == ReplicatedStorage.Effects.Images.TrafficLights.GreenLight.Image
        end
        Script.Connections.RLGL_Connection = ReplicatedStorage.Remotes.Effects.OnClientEvent:Connect(function(EffectsData)
            if EffectsData.EffectName ~= "TrafficLight" then return end
            isGreenLight = EffectsData.GreenLight == true
            local root = Script.Functions.GetRootPart()
            if root then
                lastRootPartCFrame = root.CFrame
            end
        end)
        Script.HookMethods.RLGLGodmode = function(self, method, args)
            if self == "rootCFrame" and method == "FireServer" then
                if not isGreenLight and lastRootPartCFrame then
                    args[1] = lastRootPartCFrame
                end
            end
            return args
        end
        Script.Connections["RLGLConnDestroyer"] = Script.Functions.OnceOnGameChanged(function()
            Toggles.RedLightGodmode.Callback(false)
        end)
        Script.Functions.Alert("Red Light Green Light Godmode Enabled", 3)
    end
})

GreenLightRedLightGroup:AddButton("Complete Red Light / Green Light", function()
    if Script.GameState ~= "RedLightGreenLight" then
        Script.Functions.Alert("Game not running")
        return
    end
    Script.Functions.WinRLGL()
end)

GreenLightRedLightGroup:AddButton("Remove Injured Walking", function()
    if Script.GameState ~= "RedLightGreenLight" then
        Script.Functions.Alert("Game not running")
        return
    end
    if lplr.Character and lplr.Character:FindFirstChild("InjuredWalking") then
        lplr.Character.InjuredWalking:Destroy()
    end
    Toggles.AntiRagdoll.Callback(false)
end)

GreenLightRedLightGroup:AddButton("Bring Random Injured Player", function()
    if Script.GameState ~= "RedLightGreenLight" then
        Script.Functions.Alert("Game not running")
        return
    end
    local injured = Script.Functions.GetAllInjuredPlayers()[1]
    if not injured then
        Script.Functions.Alert("No injured player found!", 2)
        return
    end
    if lplr.Character and injured.player.Character and injured.player.Character.PrimaryPart then
        Script.Temp.PauseAntiFling = true
        lplr.Character:PivotTo(injured.player.Character:GetPrimaryPartCFrame())
        task.wait(0.2)
        local CarryPrompt = Script.Functions.FindCarryPrompt(injured.player)
        if CarryPrompt then
            pcall(function()
                CarryPrompt.HoldDuration = 0
                CarryPrompt:InputHoldBegin()
            end)
        end
        task.wait(0.2)
        Script.Functions.WinRLGL()
        task.wait(0.2)
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ClickedButton"):FireServer(unpack({{tryingtoleave = true}}))
        task.wait(0.2)
        Script.Temp.PauseAntiFling = false
    end
end)

GreenLightRedLightGroup:AddDropdown("RLGLInjuredPlayer", {
    Text = "Bring Injured Player",
    Values = {},
    AllowNull = true,
    Callback = function(val)
        if not val then return end
        local injured = Script.Functions.GetAllInjuredPlayers()
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
            Script.Temp.PauseAntiFling = true
            if Toggles.RedLightGodmode.Value then
                Toggles.RedLightGodmode:SetValue(false)
            end
            lplr.Character:PivotTo(selected.player.Character:GetPrimaryPartCFrame())
            task.wait(0.2)
            local CarryPrompt = Script.Functions.FindCarryPrompt(selected.player)
            if CarryPrompt then
                pcall(function()
                    CarryPrompt.HoldDuration = 0
                    CarryPrompt:InputHoldBegin()
                end)
            end
            task.wait(0.2)
            Script.Functions.WinRLGL()
            task.wait(0.2)
            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ClickedButton"):FireServer(unpack({{tryingtoleave = true}}))
            task.wait(0.2)
            Script.Temp.PauseAntiFling = false
        end
    end
})

DalgonaGameGroup:AddButton("Complete Dalgona Game", function()
    if not Script.Functions.GetDalgonaRemote() then
        Script.Functions.Alert("Game hasn't started yet")
        return
    end
    Script.Functions.CompleteDalgonaGame()
    Script.Functions.BypassDalgonaGame()()
    Script.Functions.Alert("Completed Dalgona Game!", 2)
    Script.Functions.RestartRemotesScript()
    Script.Functions.Alert("Camera should be automatically fixed!", 3)
    table.insert(Script.Tasks, task.spawn(function()
        repeat
            task.wait(1)
            Script.Functions.CheckPlayersVisibility()
        until not Script.Functions.GetDalgonaRemote()
    end))
end)

DalgonaGameGroup:AddToggle("ImmuneDalgonaGame", {
    Text = "Immune Dalgona Game",
    Default = false,
    Callback = function(Value)
        Script.HookMethods.ImmuneDalgona = nil
        if Script.Connections["DalgonaImuneConnDestroyer"] then
            Script.Connections["DalgonaImuneConnDestroyer"]:Disconnect()
            Script.Connections["DalgonaImuneConnDestroyer"] = nil
        end
        if Value then
            if not hookmetamethod then
                Script.Functions.Alert("Your executor doesn't suport this function :(", 5)
                Toggles.ImmuneDalgonaGame:SetValue(false)
                return
            end
            if Script.GameState ~= "Dalgona" then return end
            Script.HookMethods.ImmuneDalgona = function(self, method, args)
                if self == "DALGONATEMPREMPTE" and method == "FireServer" then
                    if args[1] ~= nil and type(args[1]) == "table" and args[1].CrackAmount ~= nil then
                        Script.Functions.Alert("Prevented your cookie from cracking", 3)
                        return nil
                    end
                end

                return args
            end
            Script.Connections["DalgonaImuneConnDestroyer"] = Script.Functions.OnceOnGameChanged(function()
                Toggles.ImmuneDalgonaGame.Callback(false)
            end)
            Script.Functions.Alert("Your cookie will not break from now on!", 3)
        end
    end
})

TugOfWarGroup:AddToggle("AutoPull", {
    Text = "Auto Pull",
    Default = false,
    Callback = function(Value)
        if Script.Tasks.AutoPullTask then
            task.cancel(Script.Temp.AutoPullTask)
            Script.Tasks.AutoPullTask = nil
        end
        if Script.Connections.TugOfWarConnDestroyer then
            Script.Connections.TugOfWarConnDestroyer:Disconnect()
            Script.Connections.TugOfWarConnDestroyer = nil
        end
        if not Value or Script.GameState ~= "TugOfWar" then return end
        Script.Tasks.AutoPullTask = task.spawn(function()
            repeat
                ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TemporaryReachedBindable"):FireServer(
                    unpack({{GameQTE = true}})
                )
                task.wait(Options.AutoPullDelay.Value)
            until not Toggles.AutoPull.Value or Library.Unloaded
            Script.Tasks.AutoPullTask = nil
        end)
        Script.Connections.TugOfWarConnDestroyer = Script.Functions.OnceOnGameChanged(function()
            Toggles.AutoPull.Callback(false)
        end)
    end
})

TugOfWarGroup:AddSlider("AutoPullDelay", {
    Text = "Auto Pull Delay",
    Default = 0.2,
    Min = 0,
    Max = 1.5,
    Rounding = 2
})

function Script.Functions.WinJumpRope()
    if not lplr.Character then return end
    Script.Functions.DisableAntiFling()
    lplr.Character:PivotTo(CFrame.new(Vector3.new(732.4, 197.14, 931.1644)))
end

JumpRopeGroup:AddToggle("AutoSurviveJumpRope", {
    Text = "Anti Fall [beta]",
    Default = false,
    Callback = function(enabled)
        if Script.Connections.JumpRope_AutoSurviveCon then
            Script.Connections.JumpRope_AutoSurviveCon:Disconnect()
            Script.Connections.JumpRope_AutoSurviveCon = nil
        end
        if enabled then
            local char = lplr.Character
            if char and workspace:FindFirstChild("JumpRope") and workspace.JumpRope:FindFirstChild("FallColllisionYClient") then
                local root = char:FindFirstChild("HumanoidRootPart")
                local fallY = workspace.JumpRope.FallColllisionYClient.Position.y
                pcall(function()
                    workspace.JumpRope.FallColllisionYClient:Destory()
                end)
                Script.Connections.JumpRope_AutoSurviveCon = RunService.RenderStepped:Connect(function()
                    if root and fallY and root.Position.Y <= fallY.Position.Y then
                        root.CFrame = root.CFrame + Vector3.new(0, 5, 0)
                    end
                end)
            else
                Script.Functions.Alert("Game not running or Fall Detection is missing", 3)
                Toggles.AutoSurviveJumpRope:SetValue(false)
            end
        end
    end
})

JumpRopeGroup:AddButton("Destroy Fall Detection [beta]", function()
    if Script.GameState ~= "JumpRope" then
        Script.Functions.Alert("Game not running")
        return
    end
    local suc = pcall(function()
        workspace.JumpRope.FallColllisionYClient:Destory()
        workspace.JumpRope.FallColllisionY:Destroy()
        workspace.JumpRope.COLLISIONCHECK:Destroy()
    end)
    if suc then
        Script.Functions.Alert("Successfully destroyed fall detection!", 1.5)
    else
        Script.Functions.Alert("Fall detection part not found!", 3)
    end
end)

JumpRopeGroup:AddButton("Complete Jump Rope Game", function()
    if Script.GameState ~= "JumpRope" then
        Script.Functions.Alert("Game not running")
        return
    end
    Script.Functions.WinJumpRope()
    if not lplr.Character then return end
    local a = lplr.Character:FindFirstChild("SafeJumpRope") or Instance.new("Folder")
    a.Name = "SafeJumpRope"
    a.Parent = lplr.Character
end)

JumpRopeGroup:AddToggle("AutoPerfectJumpRope", {
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
    end
})

MingleGroup:AddToggle("AutoMingleQTE", {
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
        if not Value or Script.GameState ~= "Mingle" then return end
        Script.Tasks.AutoMingleQTEThread = task.spawn(function()
            local RemoteForQTE
            while Toggles.AutoMingleQTE.Value and not Library.Unloaded do
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
            Toggles.AutoMingleQTE.Callback(false)
        end)
    end
})

function Script.Functions.WinGlassBridge()
    if not lplr.Character then return end
    Script.Functions.DisableAntiFling()
    lplr.Character:PivotTo(CFrame.new(Vector3.new(-203.9, 520.7, -1534.3485) + Vector3.new(0, 5, 0)))
end

GlassBridgeGroup:AddButton("Complete Glass Bridge Game", function()
    if Script.GameState ~= "GlassBridge" then
        Script.Functions.Alert("Game not running")
        return
    end
    Script.Functions.WinGlassBridge()
end)

GlassBridgeGroup:AddToggle("RevealGlassBridge", {
    Text = "Reveal Glass Bridge",
    Default = false,
    Callback = function(Value)
        if Script.GameState ~= "GlassBridge" then return end
        local glassHolder = workspace:FindFirstChild("GlassBridge") and workspace.GlassBridge:FindFirstChild("GlassHolder")
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

                    if not Value then continue end

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
            Script.Functions.Alert("[Voidware]: Safe tiles are green, breakable tiles are red!", 10)
        end
    end
})

function Script.Functions.GetHider()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == lplr then continue end
        if not plr.Character then continue end
        if not plr:GetAttribute("IsHider") then continue end
        if plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            return plr.Character
        end
    end
    return nil
end

HideAndSeekGroup:AddToggle("TeleportToHider", {
    Text = "Teleport To Hider",
    Default = false,
    Callback = function(Value)
        if Value then
            task.delay(0.5, function()
                if Toggles.TeleportToHider.Value then
                    Toggles.TeleportToHider:SetValue(false)
                end
            end)
            if not lplr.Character then return end
            if Script.GameState ~= "HideAndSeek" then
                Script.Functions.Alert("Game not running!")
                return
            end
            local hider = Script.Functions.GetHider()
            if not hider then
                Script.Functions.Alert("No hider found :(")
                return
            end
            lplr.Character:PivotTo(hider:GetPrimaryPartCFrame())
        end
    end
}):AddKeyPicker("TTH", {
    Mode = "Toggle",
    Default = "P",
    Text = "Teleport To Hider",
    SyncToggleState = true
})
HideAndSeekGroup:AddButton("Teleport to Safe Hiding Spot", function()
    if Script.GameState ~= "HideAndSeek" then
        Script.Functions.Alert("Game not running!")
        return
    end
    Script.Functions.TeleportSafeHidingSpot()
end)

RebelGroup:AddToggle("ExpandGuardHitbox", {
    Text = "Expand Guard Hitbox",
    Default = false,
    Callback = function(Value)
        if Script.Connections.GuardHitboxConnection then
            Script.Connections.GuardHitboxConnection:Disconnect()
            Script.Connections.GuardHitboxConnection = nil
        end
        local live = workspace:FindFirstChild("Live")
        if not live then return end
        if Value then
            Script.Connections.GuardHitboxConnection = live.ChildAdded:Connect(function(model)
                if not isGuard(model) then return end
                local head = model:WaitForChild("Head", 5)
                if not head or not head:IsA("BasePart") then return end
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
                if not isGuard(model) then return end
                if model:FindFirstChild("Dead") then continue end
                local head = model:WaitForChild("Head", 5)
                if not head or not head:IsA("BasePart") then return end
                if model and model.Parent and head and head.Parent then
                    head.Size = Vector3.new(4, 4, 4)
                    head.CanCollide = false
                end
            end
        else
            for _, model in ipairs(live:GetChildren()) do
                if not isGuard(model) then return end
                local head = model:WaitForChild("Head", 5)
                if not head or not head:IsA("BasePart") then return end
                if model and model.Parent and head and head.Parent then
                    head.Size = Vector3.new(1, 1, 1)
                end
            end
        end
    end
})

RebelGroup:AddButton("Bring All Guards", function()
    if not Script.Functions.GetRootPart() then return end
    local myPos = Script.Functions.GetRootPart().Position
    local Live = workspace:WaitForChild("Live")
    for _, guard in pairs(Live:GetChildren()) do
        if isGuard(guard) and guard:FindFirstChild("HumanoidRootPart")then
            local guardRoot = guard.HumanoidRootPart
            local lookCFrame = CFrame.new(guardRoot.Position, myPos)
            guardRoot.CFrame = lookCFrame
        end
    end
end)

RebelGroup:AddToggle("GunMods", {
    Text = "Gun Mods",
    Default = false,
    Callback = function(enable)
        Script.Temp.originalDamageValues = Script.Temp.originalDamageValues or {}
        Script.Temp.originalGunStats = Script.Temp.originalGunStats or {}
        local Guns = ReplicatedStorage:FindFirstChild("Weapons") and ReplicatedStorage.Weapons:FindFirstChild("Guns")
        if not Guns then return end
        -- local GunDamageValues = Script.Functions.SafeRequire(ReplicatedStorage.Modules.GunDamageValues)
        for _, gun in pairs(Guns:GetChildren()) do
            if enable then
                if not Script.Temp.originalGunStats[gun.Name] then
                    Script.Temp.originalGunStats[gun.Name] = {}
                    for _, stat in ipairs({"Spread", "FireRateCD", "MaxBullets", "ReloadingSpeed"}) do
                        if gun:FindFirstChild(stat) then
                            Script.Temp.originalGunStats[gun.Name][stat] = gun[stat].Value
                        end
                    end
                end
                if gun:FindFirstChild("Spread") then gun.Spread.Value = 0 end
                if gun:FindFirstChild("FireRateCD") then gun.FireRateCD.Value = 0.05 end
                if gun:FindFirstChild("MaxBullets") then gun.MaxBullets.Value = 9999 end
                if gun:FindFirstChild("ReloadingSpeed") then gun.ReloadingSpeed.Value = 0.02 end

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
    end
})

function Script.Functions.GetEmotesMeta()
    local Animations = ReplicatedStorage:WaitForChild("Animations", 10)
    if not Animations then Script.Functions.Alert("[GetEmotesMeta]: Animations folder timeout!"); return end
    local Emotes = Animations:WaitForChild("Emotes", 10)
    if not Emotes then Script.Functions.Alert("[GetEmotesMeta]: Emotes folder timeout!"); return end
    local res = {}
    for i, v in pairs(Emotes:GetChildren()) do
        if v.ClassName ~= "Animation" then continue end
        if not v.AnimationId then continue end

        if res[v.Name] then
            Script.Functions.Alert("[GetEmotesMeta | Resolver]: The emote "..tostring(v.Name).." is duplicated! Overwriting past data...")
        end

        res[v.Name] = {
            anim = v.AnimationId,
            object = v
        }
    end
    Script.Temp.EmoteList = res
    return res
end

function Script.Functions.RefreshEmoteList()
    local w = function(str) Script.Functions.Alert("[RefreshEmoteList]: "..tostring(str)) end
    local res = Script.Functions.GetEmotesMeta()
    if not res then w("res not found!"); return end
    if not Options.EmotesList then w("Emotes List Option not found!"); return end
    local tab = {}
    for i,v in pairs(res) do
        table.insert(tab, tostring(i))
    end
    Options.EmotesList:SetValues(tab)
end

EmotesGroup:AddDropdown("EmotesList", {
    Text = 'Emotes List',
    Values = {},
    AllowNull = true
})

EmotesGroup:AddButton("Play Emote", function()
    if Options.EmotesList.Value then
        local emoteId = Script.Temp.EmoteList ~= nil and Script.Temp.EmoteList[Options.EmotesList.Value]
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

            if Script.Temp.EmoteTrack and typeof(Script.Temp.EmoteTrack) == "Instance" and Script.Temp.EmoteTrack:IsA("AnimationTrack") then
                pcall(function() Script.Temp.EmoteTrack:Stop() end)
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
            Options.EmoteList:SetValue(nil)
            Script.Functions.RefreshEmoteList()
        end
    else
        Script.Functions.Alert("No Emote Selected!", 3)
    end
end)

EmotesGroup:AddButton("Stop Emoting", function()
    if Script.Temp.EmoteTrack and typeof(Script.Temp.EmoteTrack) == "Instance" and Script.Temp.EmoteTrack:IsA("AnimationTrack") then
        pcall(function() Script.Temp.EmoteTrack:Stop() end)
        Script.Temp.EmoteTrack = nil
    end
end)

MiscGroup:AddToggle("AntiRagdoll", {
    Text = "Anti Ragdoll",
    Default = false,
    Callback = function(Value)
        if Script.Tasks.RagdollBlockConn then
            Script.Tasks.RagdollBlockConn:Disconnect()
            Script.Tasks.RagdollBlockConn = nil
        end
        local Character = lplr.Character
        if not Character then return end
        local Humanoid = Character:FindFirstChild("Humanoid")
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if not (Humanoid and HumanoidRootPart) then return end
        for _, child in ipairs(Character:GetChildren()) do
            if child.Name == "Ragdoll" then
                pcall(function() child:Destroy() end)
            end
        end
        pcall(function()
            Humanoid.PlatformStand = false
            Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        end)
        if not Value then return end
        Script.Tasks.RagdollBlockConn = Character.ChildAdded:Connect(function(child)
            if child.Name == "Ragdoll" then
                pcall(function() child:Destroy() end)
                pcall(function()
                    Humanoid.PlatformStand = false
                    Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
                    Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                end)
            end
        end)
    end
})

MiscGroup:AddButton("Fix Camera", function()
    if camera then
        camera.CameraType = Enum.CameraType.Custom
        if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = lplr.Character:FindFirstChild("Humanoid")
        end
    end
end)

MiscGroup:AddButton("Reset Camera \n [Might Break camera!]", function()
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

MiscGroup:AddButton("Skip Cutscene", function()
    if camera then
        camera.CameraType = Enum.CameraType.Custom
        if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = lplr.Character:FindFirstChild("Humanoid")
        end
    end
end)

MiscGroup:AddToggle("TeleportToSafePlace", {
    Text = "Teleport To Safe Place",
    Default = false,
    Callback = function(Value)
        if Value then
            Script.Functions.Alert("Teleported to Safe Place, disable to go back", 3)
            Script.Functions.TeleportSafe()
        else
            Script.Functions.Alert("Teleported back from Safe Place", 3)
            Script.Functions.TeleportBackFromSafe()
        end
    end
}):AddKeyPicker("TTSPKey", {
    Mode = "Toggle",
    Default = "L",
    Text = "Teleport To Safe Place",
    SyncToggleState = true
})

MiscGroup:AddButton("Fix Players Visibility", Script.Functions.CheckPlayersVisibility)

PlayerGroup:AddSlider("WonBoostSlider", {
    Text = "Won boost(idk it works or not)",
    Default = lplr.Boosts['Won Boost'].Value,
    Min = 0,
    Max = 3,
    Rounding = 0,
    Callback = function(val)
        lplr.Boosts['Won Boost'].Value = val
    end
})

PlayerGroup:AddSlider("StrengthBoostSlider", {
    Text = "Strength boost(idk it works or not)",
    Default = lplr.Boosts['Damage Boost'].Value,
    Min = 0,
    Max = 5,
    Rounding = 0,
    Callback = function(val)
        lplr.Boosts['Damage Boost'].Value = val
    end
})

PlayerGroup:AddSlider("SpeedBoostSlider", {
    Text = "Speed boost",
    Default = lplr.Boosts['Faster Sprint'].Value,
    Min = 0,
    Max = 5,
    Rounding = 0,
    Callback = function(val)
        lplr.Boosts['Faster Sprint'].Value = val
    end
})

PlayerGroup:AddSlider("SpeedSlider", {
    Text = "Walk Speed",
    Default = 16,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Callback = function(val)
        if not Toggles.SpeedToggle.Value then return end
        if not lplr.Character then return end
        if not lplr.Character:FindFirstChild("Humanoid") then return end
        lplr.Character.Humanoid.WalkSpeed = Options.SpeedSlider.Value
    end
})

PlayerGroup:AddToggle("SpeedToggle", {
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
                lplr.Character.Humanoid.WalkSpeed = Options.SpeedSlider.Value
            end
            Script.Tasks.SpeedToggleTask = task.spawn(function()
                repeat
                    task.wait(0.5)
                    if not Toggles.SpeedToggle.Value then return end
                    if not lplr.Character then return end
                    if not lplr.Character:FindFirstChild("Humanoid") then return end
                    if Value then
                        lplr.Character.Humanoid.WalkSpeed = Options.SpeedSlider.Value
                    end
                until not Toggles.SpeedToggle.Value or Library.Unloaded
                Script.Tasks.SpeedToggleTask = nil
            end)
        else
            Script.Functions.Alert("Speed Disabled", 3)
            if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
                lplr.Character.Humanoid.WalkSpeed = Script.Temp.OldSpeed
                Script.Temp.OldSpeed = nil
            end
        end
    end
}):AddKeyPicker("SpeedKey", {
    Mode = "Toggle",
    Default = "C",
    Text = "Speed",
    SyncToggleState = true
})

PlayerGroup:AddToggle("Noclip", {
    Text = "Noclip",
    Default = false,
    Callback = function(Value)
        Script.Temp.NoclipParts = Script.Temp.NoclipParts or {}
        if Script.Tasks.NoclipTask then
            task.cancel(Script.Tasks.NoclipTask)
            Script.Tasks.NoclipTask = nil
        end
        if Value then
            Script.Functions.Alert("Noclip Enabled", 3)
            Script.Tasks.NoclipTask = task.spawn(function()
                repeat
                    RunService.Heartbeat:Wait()
                    if lplr.Character ~= nil then
                        for _, child in pairs(lplr.Character:GetDescendants()) do
                            if child:IsA("BasePart") and child.CanCollide == true then
                                child.CanCollide = false
                                Script.Temp.NoclipParts[child] = true
                            end
                        end
                    end
                until not Toggles.Noclip.Value or Library.Unloaded
                Script.Tasks.NoclipTask = nil
            end)
        else
            Script.Functions.Alert("Noclip Disabled", 3)
            if lplr.Character ~= nil and Script.Temp.NoclipParts then
                for part, _ in pairs(Script.Temp.NoclipParts) do
                    if part and part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
                Script.Temp.NoclipParts = {}
            end
        end
    end
}):AddKeyPicker("NoclipKey", {
    Mode = "Toggle",
    Default = "N",
    Text = "Noclip",
    SyncToggleState = true
})

PlayerGroup:AddToggle("InfiniteJump", {
    Text = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        if Script.Connections.InfiniteJumpConnect then
            Script.Connections.InfiniteJumpConnect:Disconnect()
        end
        if not Value then return end
        Script.Connections.InfiniteJumpConnect = UserInputService.JumpRequest:Connect(function()
            if not lplr.Character then return end
            if not lplr.Character:FindFirstChild("Humanoid") then return end
            lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
})

SecurityGroup:AddToggle("Fling Character Hook", {
    Text = "Fling Character Hook",
    Default = false,
    Callback = function(Value)
        if Value then
            local function PatchFlingAnticheat()
                local char = lplr.Character
                if not char then return end
                local root = Script.Functions.GetRootPart()
                if not root then return end

                local anticheatStates = { "Stun", "Anchor", "RotateDisabled", "CantRun", "InCutscene", "DisableHeadLookAt" }
                if not Script.Temp.FlingAnticheatChildConn then
                    Script.Temp.FlingAnticheatChildConn = char.ChildAdded:Connect(function(child)
                        if table.find(anticheatStates, child.Name) then
                            task.delay(0.01, function() child:Destroy() end)
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
    end
})

SecurityGroup:AddToggle("Block Anticheat Remote", {
    Text = "Block Anticheat Remote",
    Default = false,
    Callback = function(call)
        if not hookmetamethod then
            return
        end
        Script.HookMethods.Anticheat = nil
        if not call then return end
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
    end
})

SecurityGroup:AddToggle("AntiAfk", {
    Text = "Anti AFK",
    Default = true,
    Callback = function(Value)
        if Script.Connections.AntiAfkConnection then
            pcall(function()
                Script.Connections.AntiAfkConnection:Disconnect()
            end)
        end
        if not Value then return end
        Script.Connections.AntiAfkConnection = lplr.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), camera.CFrame)
            wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), camera.CFrame)
        end)
    end
})

SecurityGroup:AddToggle("StaffDetector", {
    Text = "Staff Detector",
    Default = true,
    Callback = function(Value)
        if Value then
            local STAFF_GROUP_ID = 12398672
            local STAFF_MIN_RANK = 120
            local staffRoles = {
                [120] = "moderator",
                [254] = "dev",
                [255] = "owner"
            }
            Script.Temp.DetectedStaff = Script.Temp.DetectedStaff or {}
            local function checkPlayerStaff(player)
                local success, rank = pcall(function()
                    return player:GetRankInGroup(STAFF_GROUP_ID)
                end)
                if success and rank and rank >= STAFF_MIN_RANK then
                    local roleName = staffRoles[rank] or ("rank " .. tostring(rank))
                    Script.Functions.Alert("[StaffDetector] Staff detected: " .. player.Name .. " (" .. roleName .. ")", 10)
                    Script.Temp.DetectedStaff[player.UserId] = {Name = player.Name, Role = roleName}
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
                    Script.Functions.Alert("[StaffDetector] Staff left: " .. staffInfo.Name .. " (" .. staffInfo.Role .. ")", 10)
                    Script.Temp.DetectedStaff[player.UserId] = nil
                end
            end)
        else
            if Script.Temp.StaffDetectorConnections then
                for _, conn in pairs(Script.Temp.StaffDetectorConnections) do
                    pcall(function() conn:Disconnect() end)
                end
                Script.Temp.StaffDetectorConnections = nil
            end
            Script.Temp.DetectedStaff = nil
            Script.Functions.Alert("[StaffDetector] Staff detection disabled.", 3)
        end
    end
})

PerformanceGroup:AddToggle("LowGFX", {
    Text = "Low GFX",
    Default = false,
    Callback = function(Value)
        if Script.Connections.LowGFX_DescendantConn then
            Script.Connections.LowGFX_DescendantConn:Disconnect()
            Script.Connections.LowGFX_DescendantConn = nil
        end
        if Value then
            Script.Temp.LowGFX_Originals = Script.Temp.LowGFX_Originals or {}
            local Terrain = workspace:FindFirstChildOfClass('Terrain')
            if Terrain then
                Script.Temp.LowGFX_Originals.Terrain = {
                    WaterWaveSize = Terrain.WaterWaveSize,
                    WaterWaveSpeed = Terrain.WaterWaveSpeed,
                    WaterReflectance = Terrain.WaterReflectance,
                    WaterTransparency = Terrain.WaterTransparency
                }
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 1
            end
            Script.Temp.LowGFX_Originals.Lighting = {
                GlobalShadows = Lighting.GlobalShadows,
                FogEnd = Lighting.FogEnd,
                FogStart = Lighting.FogStart
            }
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.FogStart = 9e9
            pcall(function()
                Script.Temp.LowGFX_Originals.QualityLevel = settings().Rendering.QualityLevel
                settings().Rendering.QualityLevel = 1
            end)
            Script.Temp.LowGFX_Originals.BaseParts = {}
            for i,v in pairs(game:GetDescendants()) do
                if v:IsA("BasePart") then
                    Script.Temp.LowGFX_Originals.BaseParts[v] = {
                        Material = v.Material,
                        Reflectance = v.Reflectance,
                        BackSurface = v.BackSurface,
                        BottomSurface = v.BottomSurface,
                        FrontSurface = v.FrontSurface,
                        LeftSurface = v.LeftSurface,
                        RightSurface = v.RightSurface,
                        TopSurface = v.TopSurface
                    }
                    v.Material = "Plastic"
                    v.Reflectance = 0
                    v.BackSurface = "SmoothNoOutlines"
                    v.BottomSurface = "SmoothNoOutlines"
                    v.FrontSurface = "SmoothNoOutlines"
                    v.LeftSurface = "SmoothNoOutlines"
                    v.RightSurface = "SmoothNoOutlines"
                    v.TopSurface = "SmoothNoOutlines"
                elseif v:IsA("Decal") then
                    Script.Temp.LowGFX_Originals[v] = v.Transparency
                    v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    Script.Temp.LowGFX_Originals[v] = v.Lifetime
                    v.Lifetime = NumberRange.new(0)
                end
            end
            Script.Temp.LowGFX_Originals.PostEffects = {}
            for i,v in pairs(Lighting:GetDescendants()) do
                if v:IsA("PostEffect") then
                    Script.Temp.LowGFX_Originals.PostEffects[v] = v.Enabled
                    v.Enabled = false
                end
            end
            Script.Connections.LowGFX_DescendantConn = workspace.DescendantAdded:Connect(function(child)
                task.spawn(function()
                    if child:IsA('ForceField') or child:IsA('Sparkles') or child:IsA('Smoke') or child:IsA('Fire') or child:IsA('Beam') then
                        RunService.Heartbeat:Wait()
                        child:Destroy()
                    end
                end)
            end)
        else
            local Terrain = workspace:FindFirstChildOfClass('Terrain')
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
                    if typeof(v) == "Instance" and v:IsA("Decal") then
                        v.Transparency = val
                    elseif typeof(v) == "Instance" and (v:IsA("ParticleEmitter") or v:IsA("Trail")) then
                        v.Lifetime = val
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
    end
})

PerformanceGroup:AddToggle("DisableEffects", {
    Text = "Disable Effects",
    Default = false,
    Callback = function(Value)
            if Script.Temp.DisableEffectsConnection then
                pcall(function()
                    Script.Temp.DisableEffectsConnection:Disconnect()
                end)
                Script.Temp.DisableEffectsConnection = nil
            end
        if not Value then return end
        local Effects = workspace:WaitForChild("Effects", 15)
        if not Effects then return end
        for _,v in pairs(Effects:GetDescendants()) do
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
    end
})

local States = {
    RedLightGreenLight = function()
        local AutoWinRLGL = true
        if Script.Tasks.AutoWinRLGLTask then
            task.cancel(Script.Tasks.AutoWinRLGLTask)
            Script.Tasks.AutoWinRLGLTask = nil
        end
        Script.Tasks.AutoWinRLGLTask = task.spawn(function()
            repeat
                Script.Functions.WinRLGL()
                task.wait(5)
            until not AutoWinRLGL or not Toggles.InkGameAutowin.Value or Script.GameState ~= "RedLightGreenLight"
        end)
        Toggles.AntiFlingToggle.Callback(true)
        return function()
            AutoWinRLGL = false
            Toggles.AntiFlingToggle.Callback(false)
        end
    end,
    Mingle = function()
        Toggles.AutoMingleQTE.Callback(true)
        return function()
            Toggles.AutoMingleQTE.Callback(false)
        end
    end,
    TugOfWar = function()
        Toggles.AutoPull.Callback(true)

        return function()
            Toggles.AutoPull.Callback(false)
        end
    end,
    GlassBridge = function()
        task.spawn(function()
            Toggles.RevealGlassBridge.Callback(true)
        end)
        local AutoWinGlassBridge = true
        if Script.Tasks.AutoWinGlassBridgeTask then
            task.cancel(Script.Tasks.AutoWinGlassBridgeTask)
            Script.Tasks.AutoWinGlassBridgeTask = nil
        end
        Script.Tasks.AutoWinGlassBridgeTask = task.spawn(function()
            task.wait(15)
            repeat
                Script.Functions.WinGlassBridge()
                task.wait(3)
            until not AutoWinGlassBridge or not Toggles.InkGameAutowin.Value or Library.Unloaded
        end)
        return function()
            AutoWinGlassBridge = false
        end
    end,
    HideAndSeek = function()
        if lplr:FindFirstChild("CurrentKeys") then
            Script.Functions.TeleportSafe()
        else
            Script.Functions.Alert("[Autowin]: Hide and Seek support for Seekers soon...")
        end
    end,
    LightsOut = Script.Functions.TeleportSafe,
    Dalgona = function()
        table.insert(Script.Tasks, task.spawn(function()
            repeat task.wait() until Script.Functions.GetDalgonaRemote() or not Toggles.InkGameAutowin.Value or Library.Unloaded
            if not Toggles.InkGameAutowin.Value then return end
            task.wait(3)
            Script.Functions.CompleteDalgonaGame()
            Script.Functions.BypassDalgonaGame()()
            Script.Functions.RestartRemotesScript()
            table.insert(Script.Tasks, task.spawn(function()
                repeat
                    task.wait(1)
                    Script.Functions.CheckPlayersVisibility()
                until not Script.Functions.GetDalgonaRemote()
            end))
            task.delay(3, function()
                Script.Functions.CompleteDalgonaGame()
                Script.Functions.BypassDalgonaGame()()
                Script.Functions.RestartRemotesScript()
            end)
        end))

        return function()
            Script.Functions.CheckPlayersVisibility()
        end
    end,
    JumpRope = function()
        local call = true
        task.spawn(function()
            task.wait(15)
            repeat
                Script.Functions.WinJumpRope()
                task.wait(3)
            until not call or not Toggles.InkGameAutowin.Value or Library.Unloaded
        end)
        return function()
            call = false
        end
    end
}

local lastCleanupFunction = function() end

function Script.Functions.HandleAutowin()
    if lastCleanupFunction then
        pcall(lastCleanupFunction)
    end
    if Toggles.Noclip.Value ~= false then
        Toggles.Noclip:SetValue(false)
    end

    if States[Script.GameState] then
        Script.Functions.Alert("[Autowin]: Running on "..tostring(Script.GameState))
        lastCleanupFunction = States[Script.GameState]()
    else
        Script.Functions.Alert("[Autowin]: Waiting for the next game...")
    end
end

FunGroup:AddToggle("InkGameAutowin", {
    Text = "Autowin ⭐",
    Default = false,
    Callback = function(Value)
        if Value then
            Script.Functions.Alert("Autowin enabled!", 5)
            Script.Functions.HandleAutowin()
        else
            Script.Functions.Alert("Autowin disabled!", 3)
        end
    end
})

FunGroup:AddToggle("FlingAuraToggle", {
    Text = "Fling Aura",
    Default = false,
    Callback = function(Value)
        local function stopFlingAura()
            Script.Temp.FlingAuraActive = false
            if Toggles.Noclip.Value ~= false then
                Toggles.Noclip:SetValue(false)
            end
            if Script.Connection.FlingAuraDeathConn then
                Script.Connection.FlingAuraDeathConn:Disconnect()
                Script.Connection.FlingAuraDeathConn = nil
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
                if not Toggles.PatchFlingAnticheat.Value then
                    Toggles.PatchFlingAnticheat:SetValue(true)
                end
            end)
            if Toggles.Noclip.Value ~= true then
                Toggles.Noclip:SetValue(true)
            end
            local player = lplr
            local function getRoot(character)
                return character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))
            end
            local humanoid = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
            if humanoid then
                Script.Connection.FlingAuraDeathConn = humanoid.Died:Connect(stopFlingAura)
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
                if Toggles.PatchFlingAnticheat.Value then
                    Toggles.PatchFlingAnticheat:SetValue(false)
                end
            end)
            Script.Functions.Alert("Fling Aura Disabled", 3)
            stopFlingAura()
        end
    end
})

FunGroup:AddToggle("AntiFlingToggle", {
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
                Toggles.AntiFlingToggle:SetValue(false)
                return
            end
            Script.Temp.PauseAntiFling = nil
            Script.Functions.Alert("Anti Fling Enabled", 3)
            Script.Tasks.AntiFlingLoop = task.spawn(function()
                local lastSafeCFrame = nil
                while Toggles.AntiFlingToggle.Value and not Library.Unloaded do
                    task.wait(0.05)
                    if Script.Temp.PauseAntiFling then continue end
                    local character = lplr.Character
                    local root = character and (Script.Functions.GetRootPart() or character:FindFirstChild("Torso"))
                    if root then
                        local gs = Script.GameState
                        local isActiveGame = gs and States[gs] ~= nil
                        for _, part in pairs(character:GetDescendants()) do
                            if part:IsA("BodyMover") or part:IsA("BodyVelocity") or part:IsA("BodyGyro") or part:IsA("BodyThrust") or part:IsA("BodyAngularVelocity") then
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
                        elseif lastSafeCFrame and isActiveGame and (root.Position - lastSafeCFrame.Position).Magnitude > 50 then
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
    end
})

UsefulGroup:AddToggle("AutoSkipDialog", {
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
                local DialogueFrameAnnouncement = PlayerGui and PlayerGui:FindFirstChild("DialogueGUI") and PlayerGui.DialogueGUI:FindFirstChild("DialogueFrameAnnouncement")
                while Toggles.AutoSkipDialog.Value and not Library.Unloaded do
                    if lplr:GetAttribute("_DialogueOpen") or (DialogueFrameAnnouncement and DialogueFrameAnnouncement.Visible) then
                        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DialogueRemote"):FireServer(unpack({"Skipped"}))
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

UsefulGroup:AddToggle("FullbrightToggle", {
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
                if not Toggles.FullbrightToggle.Value then return end
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
    end
})

local function TPBackFromAntiDeath()
    if Script.Temp.OldDeathLocation then
        Script.Functions.DisableAntiFling()
        lplr.Character:PivotTo(Script.Temp.OldDeathLocation)
        Script.Temp.OldDeathLocation = nil
    end
end

AntiDeathGroup:AddToggle("AntiDeathToggle", {
    Text = "Anti Death",
    Default = false,
    Callback = function(Value)
        if Script.Temp.AntiDeathTask then
            task.cancel(Script.Temp.AntiDeathTask)
            Script.Temp.AntiDeathTask = nil
        end
        TPBackFromAntiDeath()
        if not Value then return end
        Script.Temp.AntiDeathTask = task.spawn(function()
            repeat
                task.wait()
                if lplr.Character then
                    local hum = lplr.Character:FindFirstChildOfClass("Humanoid")
                    if not hum then return end
                    if hum.Health <= Options.AntiDeathHealthThreshold.Value then
                        if not Script.Temp.OldDeathLocation then
                            pcall(function()
                                Script.Temp.OldDeathLocation = CFrame.new(Script.Functions.GetRootPart().Position)
                            end)
                            Script.Functions.DisableAntiFling()
                            lplr.Character:PivotTo(CFrame.new(Vector3.new(-108, 329.1, 462.1)))
                        end
                    end
                end
            until not Toggles.AntiDeathToggle.Value or Library.Unloaded
        end)
    end
})

AntiDeathGroup:AddSlider("AntiDeathHealthThreshold", {
    Text = "Health Threshold",
    Default = 30,
    Min = 10,
    Max = 90,
    Rounding = 1
})

AntiDeathGroup:AddButton("TP back from AntiDeath", TPBackFromAntiDeath)

MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "Menu keybind",
})

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = false,
    Text = "Open Keybind Menu",
    Callback = function(value)
        Library.KeybindFrame.Visible = value
    end
})

MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = true,
    Callback = function(Value)
        Library.ShowCustomCursor = Value
    end
})

MenuGroup:AddButton("Unload Script", function() Library:Unload() end)

MenuGroup:AddButton("Reset Settings", function()
    SaveManager:SaveAutoloadConfig("default")
    pcall(function()
        writefile("voidware_linoria/ink_game/settings/default.json", "[]")
    end)
    pcall(function()
        Library:Unload()
    end)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NSeydulla/VW-Add/main/inkgame.lua", true))()
end)

Library.ToggleKeybind = Options.MenuKeybind

task.spawn(function() pcall(Script.Functions.OnLoad) end)