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
    if not isfolder("voidware_linoria") then makefolder("voidware_linoria"); isNew = true; end
    for _, v in pairs({"voidware_linoria/ink_game", "voidware_linoria/themes", "voidware_linoria/ink_game/settings", "voidware_linoria/ink_game/themes"}) do
        if not isfolder(v) then makefolder(v); isNew = true; end
    end

    if isNew then
        writefile("voidware_linoria/themes/default.txt", "Jester")
    end
end)

local allowedlibs = {"Obsidian", "LinoriaLib"}
local default = "Obsidian"
local suc, targetlib = pcall(function()
    local res = default
    if not isfile("Voidware_InkGame_Library_Choice.txt") then
        writefile("Voidware_InkGame_Library_Choice.txt", res)
    else
        local suc, opt = pcall(function()
            return readfile("Voidware_InkGame_Library_Choice.txt")
        end)
        if suc then
            res = tostring(opt)
        end
    end

    if not table.find(allowedlibs, res) then
        res = default
    end
    writefile("Voidware_InkGame_Library_Choice.txt", res)
    return res
end)
if not suc then
    targetlib = default
end

--// Library \\--
local repo = "https://raw.githubusercontent.com/mstudio45/"..tostring(targetlib).."/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
getgenv().shared.Voidware_InkGame_Library = Library
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options
local Toggles
if targetlib == "Obsidian" then
    Options = getgenv().Library.Options
    Toggles = getgenv().Library.Toggles
else 
    Options = getgenv().Linoria.Options
    Toggles = getgenv().Linoria.Toggles   
end

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

local Services = setmetatable({}, {
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
})

local SharedFunctions = {}

function SharedFunctions.Invisible(arg1, arg2, arg3)
    for _, part in ipairs(arg1:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 1
            if arg3 then
                part.CanCollide = false
            end
        end
    end
end

function SharedFunctions.CreateFolder(parent, name, lifetime, opts)
    local Folder = Instance.new("Folder")
    Folder.Name = name
    if opts then
        if opts.ObjectValue then
            Folder.Value = opts.ObjectValue
        end
        if opts.Attributes then
            for k, v in pairs(opts.Attributes) do
                Folder:SetAttribute(k, v)
            end
        end
    end
    Folder.Parent = parent
    if lifetime then
        task.delay(lifetime, function()
            if Folder and Folder.Parent then
                Folder:Destroy()
            end
        end)
    end
    return Folder
end

local Players = Services.Players
local Lighting = Services.Lighting
local RunService = Services.RunService
local HttpService = Services.HttpService
local TweenService = Services.TweenService
local UserInputService = Services.UserInputService
local ReplicatedStorage = Services.ReplicatedStorage
local ProximityPromptService = Services.ProximityPromptService

local lplr = Players.LocalPlayer

local camera = workspace.CurrentCamera

type ESP = {
    Color: Color3,
    IsEntity: boolean,
    Object: Instance,
    Offset: Vector3,
    Text: string,
    TextParent: Instance,
    Type: string,
}

local Script = {
    GameState = "unknown",
    Services = Services,
    Connections = {},
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
    Temp = {}
}

local States = {}

function Script.Functions.Alert(message: string, time_obj: number)
    Library:Notify(message, time_obj or 5)

    local sound = Instance.new("Sound", workspace) do
        sound.SoundId = "rbxassetid://4590662766"
        sound.Volume = 2
        sound.PlayOnRemove = true
        sound:Destroy()
    end
end

function Script.Functions.Warn(message: string)
    warn("WARN - voidware:", message)
end

function Script.Functions.ApplyHiderSeekerEsp(esp)
    if esp.Object:FindFirstChild("BlueVest") and Toggles['HiderESP'].Value then
        if esp.Connections.HiderPlayerConn then
            esp.Connections.HiderPlayerConn:Disconnect()
        end
        esp.Connections.HiderPlayerConn = Script.Functions.OnceOnGameChanged(function()
            esp.SetColor(Options['PlayerEspColor'].Value)
            esp.Text = esp.Text:gsub('(Hider)', "")
        end)
        esp.Color = Options['HiderEspColor'].Value
        esp.Text = esp.Text.."(Hider)"
    end
    if not esp.Object:FindFirstChild("BlueVest") and Toggles['SeekerESP'].Value then
        if esp.Connections.SeekerPlayerConn then
            esp.Connections.SeekerPlayerConn:Disconnect()
        end
        esp.Connections.SeekerPlayerConn = Script.Functions.OnceOnGameChanged(function()
            esp.SetColor(Options['PlayerEspColor'].Value)
            esp.Text = esp.Text:gsub('(Seeker)', "")
        end)
        esp.Color = Options['SeekerEspColor'].Value
        esp.Text = esp.Text.."(Seeker)"
    end
end

function Script.Functions.ESP(args: ESP)
    if not args.Object then return Script.Functions.Warn("ESP Object is nil") end

    local ESPManager = {
        Object = args.Object,
        Text = args.Text or "No Text",
        TextParent = args.TextParent,
        Color = args.Color or Color3.new(),
        Offset = args.Offset or Vector3.zero,
        IsEntity = args.IsEntity or false,
        Type = args.Type or "None",

        Highlights = {},
        Humanoid = nil,
        RSConnection = nil,

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

    if ESPManager.Type == "Player" then
        Script.Functions.ApplyHiderSeekerEsp(ESPManager)
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
        if ESPManager.RSConnection then
            ESPManager.RSConnection:Disconnect()
        end

        for _, highlight in pairs(ESPManager.Highlights) do
            highlight:Destroy()
        end
        if billboardGui then billboardGui:Destroy() end

        if Script.ESPTable[ESPManager.Type][tableIndex] then
            Script.ESPTable[ESPManager.Type][tableIndex] = nil
        end

        for _, conn in pairs(ESPManager.Connections) do
            pcall(function()
                conn:Disconnect()
            end)
        end
        ESPManager.Connections = {}
    end

    ESPManager.RSConnection = RunService.RenderStepped:Connect(function()
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
    end)

    function ESPManager.GiveSignal(signal)
        table.insert(ESPManager.Connections, signal)
    end

    Script.ESPTable[ESPManager.Type][tableIndex] = ESPManager
    return ESPManager
end

function Script.Functions.KeyESP(key)
    local esp = Script.Functions.ESP({
        Object = key,
        Text = key.Name:gsub("DroppedKey", "") .. " key",
        Color = Options.KeyEspColor.Value,
        Offset = Vector3.new(0, 1, 0),
        Type = "Key",
        IsEntity = true
    })
end

function Script.Functions.DoorESP(door)
    local keyNeeded = door:GetAttribute("KeyNeeded")
    keyNeeded = keyNeeded and " (Key: "..keyNeeded..")" or ""
    local esp = Script.Functions.ESP({
        Object = door,
        Text = "Door" .. keyNeeded,
        Color = Options.DoorEspColor.Value,
        Offset = Vector3.new(0, 2, 0),
        Type = "Door",
        IsEntity = true
    })
end

function Script.Functions.EscapeDoorESP(door)
    if not door:FindFirstChild("IgnoreBorders") then
        local esp = Script.Functions.ESP({
            Object = door,
            Text = "Escape Door",
            Color = Options.EscapeDoorEspColor.Value,
            Offset = Vector3.new(0, 2, 0),
            Type = "Escape Door",
            IsEntity = true
        })
    end
end

function Script.Functions.GuardESP(character)
    if character then
        if not character:WaitForChild("Humanoid", 2) then
            warn('Guard finded, but Humanoid child not')
        else
            local guardEsp = Script.Functions.ESP({
                Object = character,
                Text = ".",
                Color = Options.GuardEspColor.Value,
                Offset = Vector3.new(0, 4, 0),
                Type = "Guard"
            })
            guardEsp.GiveSignal(character.ChildAdded:Connect(function(v)
                if v.Name == "Dead" and v.ClassName == "Folder" then
                    guardEsp.Destroy()
                end
            end))
        end
    end
end

function Script.Functions.PlayerESP(player: Player)
    if not (player.Character and player.Character.PrimaryPart and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0) then return end
    
    local playerEsp = Script.Functions.ESP({
        Type = "Player",
        Object = player.Character,
        Text = string.format("%s [%s]", player.DisplayName, math.ceil(player.Character.Humanoid.Health)),
        TextParent = player.Character.PrimaryPart,
        Offset = Vector3.new(0, 1, 0),
        Color = Options.PlayerEspColor.Value
    })

    playerEsp.GiveSignal(player.Character.Humanoid.HealthChanged:Connect(function(newHealth)
        if newHealth > 0 then
            playerEsp.Text = string.format("%s [%s]", player.DisplayName, math.ceil(newHealth))
        else
            playerEsp.Destroy()
        end
    end))
end

Script.Functions.SafeRequire = function(module)
    if Script.Temp[tostring(module)] then return Script.Temp[tostring(module)] end
    local suc, err = pcall(function()
        return require(module)
    end)
    if not suc then
        warn("[SafeRequire]: Failure loading "..tostring(module).." ("..tostring(err)..")")
    else
        Script.Temp[tostring(module)] = err
    end
    return suc and err
end

Script.Functions.ExecuteClick = function()
    local args = {
        "Clicked"
    }
    ReplicatedStorage:WaitForChild("Replication"):WaitForChild("Event"):FireServer(unpack(args))    
end

Script.Functions.CompleteDalgonaGame = function()
    Script.Functions.ExecuteClick()
    local args = {
        {
            Completed = true
        }
    }
    Script.Functions.GetDalgonaRemote():FireServer(unpack(args))

    local args = {
        {
            Success = true
        }
    }
    Script.Functions.GetDalgonaRemote():FireServer(unpack(args))
end

function Script.Functions.RevealGlassBridge()
    local glassHolder = workspace:FindFirstChild("GlassBridge") and workspace.GlassBridge:FindFirstChild("GlassHolder")
    if not glassHolder then
        warn("GlassHolder not found in workspace.GlassBridge")
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

    Script.Functions.EffectsNotification("[Voidware]: Safe tiles are green, breakable tiles are red!", 10)
end

Script.Functions.OnLoad = function()
    for _, player in pairs(Players:GetPlayers()) do
        if player == lplr then continue end
        Script.Functions.SetupOtherPlayerConnection(player)
    end
    Library:GiveSignal(Players.PlayerAdded:Connect(function(player)
        if player == lplr then return end
        Script.Functions.SetupOtherPlayerConnection(player)
    end))
end

Library:OnUnload(function()
    if Library._signals then
        for _, v in pairs(Library._signals) do
            pcall(function()
                v:Disconnect()
            end)
        end
    end
    for _, conn in pairs(Script.Connections) do
        pcall(function()
            conn:Disconnect()
        end)
    end
    for _, task in pairs(Script.Tasks) do
        pcall(function()
            task.cancel(task)
        end)
    end
    for _, espType in pairs(Script.ESPTable) do
        for _, esp in pairs(espType) do
            pcall(esp.Destroy)
        end
    end
    Library.Unloaded = true
    getgenv().shared.Voidware_InkGame_Library = nil
end)

local EffectsModule
function Script.Functions.EffectsNotification(text, dur)
    EffectsModule = EffectsModule or Script.Functions.SafeRequire(ReplicatedStorage.Modules.Effects) or {
        AnnouncementTween = function(args)
            Script.Functions.Alert(args.AnnouncementDisplayText, args.DisplayTime)
        end
    }

    dur = dur or 5
    text = tostring(text)

    EffectsModule.AnnouncementTween({
        AnnouncementOneLine = true,
        FasterTween = true,
        DisplayTime = dur,
        AnnouncementDisplayText = text
    })
end

Script.Functions.BypassRagdoll = function()
    local Character = lplr.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChild("Humanoid")
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    local Torso = Character:FindFirstChild("Torso")
    if not (Humanoid and HumanoidRootPart and Torso) then return end

    if Script.Tasks.RagdollBlockConn then
        Script.Tasks.RagdollBlockConn:Disconnect()
    end
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

    for _, child in ipairs(Character:GetChildren()) do
        if child.Name == "Ragdoll" then
            pcall(function() child:Destroy() end)
        end
    end

    for _, folderName in pairs({"Stun", "RotateDisabled", "RagdollWakeupImmunity", "InjuredWalking"}) do
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
    -- local joints = {"Left Hip", "Left Shoulder", "Neck", "Right Hip", "Right Shoulder"}
    -- for _, jointName in pairs(joints) do
    --     local motor = Torso:FindFirstChild(jointName)
    --     if motor and motor:IsA("Motor6D") and not motor.Part0 then
    --         motor.Part0 = Torso
    --     end
    -- end
    -- for _, part in pairs(Character:GetChildren()) do
    --     if part:IsA("BasePart") and part:FindFirstChild("BoneCustom") then
    --         part.BoneCustom:Destroy()
    --     end
    -- end
end

Script.Functions.BypassDalgonaGame = function()
    local Character = lplr.Character
    local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character and Character:FindFirstChild("Humanoid")
    local PlayerGui = lplr.PlayerGui
    local DebrisBD = lplr:WaitForChild("DebrisBD")
    local CurrentCamera = workspace.CurrentCamera
    local EffectsFolder = workspace:FindFirstChild("Effects")
    local ImpactFrames = PlayerGui:FindFirstChild("ImpactFrames")

    local originalCameraType = CurrentCamera.CameraType
    local originalCameraSubject = CurrentCamera.CameraSubject
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
        SharedFunctions.CreateFolder(lplr, "RecentGameStartedMessage", 0.01)

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

        SharedFunctions.Invisible(Character, 0, true)

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

Script.Functions.GetRootPart = function()
    if not lplr.Character then return end
    return lplr.Character:WaitForChild("HumanoidRootPart", 10)
end

Script.Functions.GetHumanoid = function()
    if not lplr.Character then return end
    return lplr.Character:WaitForChild("Humanoid", 10)
end

function Script.Functions.GetDalgonaRemote()
    return ReplicatedStorage:WaitForChild("Remotes", 1):WaitForChild("DALGONATEMPREMPTE", 1)
end

function Script.Functions.DistanceFromCharacter(position: Instance | Vector3)
    if typeof(position) == "Instance" then
        position = position:GetPivot().Position
    end
    return (camera.CFrame.Position - position).Magnitude
end

Script.Functions.FixCamera = function()
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
end

Script.Functions.RestoreVisibility = function(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "BoneCustom" then
            if part.Transparency >= 0.99 or part.LocalTransparencyModifier >= 0.99 then
                wasInvisible = true
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

Script.Functions.CheckPlayersVisibility = function()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            Script.Functions.RestoreVisibility(player.Character)
        end
    end
end

function Script.Functions.SetupOtherPlayerConnection(player: Player)
    if player.Character then
        if Toggles.PlayerESP.Value then
            Script.Functions.PlayerESP(player)
        end
    end

    Library:GiveSignal(player.CharacterAdded:Connect(function(newCharacter)
        task.delay(0.1, function()
            if Toggles.PlayerESP.Value then
                Script.Functions.PlayerESP(player)
            end
        end)
    end))
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

function Script.Functions.WinRLGL()
    if not lplr.Character then return end
    local call = Toggles.AntiFlingToggle.Value
    Script.Functions.DisableAntiFling()
    lplr.Character:PivotTo(CFrame.new(Vector3.new(-100.8, 1030, 115)))
    if call then
        task.delay(0.5, Script.Functions.EnableAntiFling)
    end
end

function Script.Functions.TeleportSafe()
    if not lplr.Character then return end
    pcall(function()
        Script.Temp.OldLocation = CFrame.new(Script.Functions.GetRootPart().Position)
    end)
    local call = Toggles.AntiFlingToggle.Value
    Script.Functions.DisableAntiFling()
    lplr.Character:PivotTo(CFrame.new(Vector3.new(-108, 329.1, 462.1)))
    if call then
        task.delay(0.5, Script.Functions.EnableAntiFling)
    end
end

function Script.Functions.TeleportBackFromSafe()
    local OldLocation = Script.Temp.OldLocation
    if not OldLocation then
        warn("[Invalid location]")
        return
    end
    if not lplr.Character then return end
    local call = Toggles.AntiFlingToggle.Value
    Script.Functions.DisableAntiFling()
    lplr.Character:PivotTo(OldLocation)
    if call then
        task.delay(0.5, Script.Functions.EnableAntiFling)
    end
end

function Script.Functions.TeleportSafeHidingSpot()
    if not lplr.Character then return end
    local call = Toggles.AntiFlingToggle.Value
    Script.Functions.DisableAntiFling()
    lplr.Character:PivotTo(CFrame.new(Vector3.new(229.9, 1005.3, 169.4)))
    if call then
        task.delay(0.5, Script.Functions.EnableAntiFling)
    end
end

function Script.Functions.WinGlassBridge()
    if not lplr.Character then return end
    local call = Toggles.AntiFlingToggle.Value
    Script.Functions.DisableAntiFling()
    lplr.Character:PivotTo(CFrame.new(Vector3.new(-203.9, 520.7, -1534.3485) + Vector3.new(0, 5, 0)))
    if call then
        task.delay(0.5, Script.Functions.EnableAntiFling)
    end
end

local function isGuard(model)
    if string.find(model.Name, "Rebel") or string.find(model.Name, "HallwayGuard") or string.find(string.lower(model.Name), "aggro") then
        return true
    end
    return false
end

local MAIN_ESP_META = {
    {
        metaName = "PlayerESP",
        text = "Player",
        default = false,
        color = {
            metaName = "PlayerEspColor",
            default = Color3.fromRGB(255, 255, 255)
        },
        func = function()
            for _, player in pairs(Players:GetPlayers()) do
                if player == lplr then continue end
                Script.Functions.PlayerESP(player)
            end
        end
    },
    {
        metaName = "GuardESP",
        text = "Guard",
        default = false,
        color = {
            metaName = "GuardEspColor",
            default = Color3.fromRGB(200, 100, 200)
        },
        func = function()
            local live = workspace:FindFirstChild("Live")
            if not live then return end
            if Script.Connections.GuardAddedConnection then
                Script.Connections.GuardAddedConnection:Disconnect()
            end
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
        end
    }
}

local MainESPGroup = Tabs.Visuals:AddLeftGroupbox("Main ESP", "eye") do
    for _, meta in pairs(MAIN_ESP_META) do
        MainESPGroup:AddToggle(meta.metaName, {
            Text = meta.text,
            Default = meta.default
        }):AddColorPicker(meta.color.metaName, {
            Default = meta.color.default
        })

        Toggles[meta.metaName]:OnChanged(function(call)
            if call then
                meta.func()
            else
                for _, esp in pairs(Script.ESPTable[meta.text]) do
                    esp.Destroy()
                end
                if meta.metaName == "GuardESP" and Script.Connections.GuardAddedConnection then
                    Script.Connections.GuardAddedConnection:Disconnect()
                    Script.Connections.GuardAddedConnection = nil
                end
            end
        end)

        Options[meta.color.metaName]:OnChanged(function(value)
            for _, esp in pairs(Script.ESPTable[meta.text]) do
                esp.SetColor(value)
            end
        end)
    end
end

local HIDE_AND_SEEK_ESP_META = {
    {
        metaName = "HiderESP",
        text = "Hider",
        default = false,
        color = {
            metaName = "HiderEspColor",
            text = "Player",
            default = Color3.fromRGB(0, 255, 0)
        },
        func = function() end
    },
    {
        metaName = "SeekerESP",
        text = "Seeker",
        default = false,
        color = {
            metaName = "SeekerEspColor",
            text = "Player",
            default = Color3.fromRGB(255, 0, 0)
        },
        func = function() end
    },
    {
        metaName = "KeyESP",
        text = "Key",
        default = false,
        color = {
            metaName = "KeyEspColor",
            default = Color3.fromRGB(255, 255, 0)
        },
        func = function()
            local EffectsFolder = workspace:FindFirstChild("Effects")
            for _, key in pairs(EffectsFolder:GetChildren()) do
                if string.find(key.Name, "DroppedKey") then
                    Script.Functions.KeyESP(key)
                end
            end
        end,
        descendantcheck = function(descendant)
            if string.find(descendant.Name, "DroppedKey") and descendant.Parent and descendant.Parent.Name == "Effects" then
                Script.Functions.KeyESP(descendant)
            end
        end
    },
    {
        metaName = "DoorESP",
        text = "Door",
        default = false,
        color = {
            metaName = "DoorEspColor",
            default = Color3.fromRGB(0, 128, 255)
        },
        func = function()
            print('DoorEsp enabled')
            local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")
            if hideAndSeekMap then
                local newFixedDoors = hideAndSeekMap:WaitForChild("NEWFIXEDDOORS", 2)
                for _, floor in pairs(newFixedDoors:GetChildren()) do
                    for _, door in pairs(floor:GetChildren()) do
                        if door.Name == "FullDoorAnimated" then
                            Script.Functions.DoorESP(door)
                        end
                    end
                end
            end
        end,
        descendantcheck = function(descendant)
            local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")
            if not hideAndSeekMap then return end
            if descendant.Name == "FullDoorAnimated" and descendant.Parent and descendant.Parent.Parent and descendant.Parent.Parent.Name == "NEWFIXEDDOORS" then
                Script.Functions.DoorESP(descendant)
            end
        end
    },
    {
        metaName = "EscapeDoorESP",
        text = "Escape Door",
        default = false,
        color = {
            metaName = "EscapeDoorEspColor",
            default = Color3.fromRGB(255, 0, 255)
        },
        func = function()
            local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")
            if hideAndSeekMap then
                local newFixedDoors = hideAndSeekMap:WaitForChild("NEWFIXEDDOORS", 2)
                for _, floor in pairs(newFixedDoors:GetChildren()) do
                    for _, group in pairs(floor:GetChildren()) do
                        if group.Name == "EXITDOORS" then
                            for _, door in pairs(group:GetChildren()) do
                                Script.Functions.EscapeDoorESP(door)
                            end
                        end
                    end
                end
            end
        end,
        descendantcheck = function(descendant)
            local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")
            if not hideAndSeekMap then return end
            if descendant.Name == "EXITDOOR" and descendant.Parent and descendant.Parent.Name == "EXITDOORS" then
                Script.Functions.EscapeDoorESP(descendant)
            end
        end
    },
}

function Script.Functions.OnceOnGameChanged(func)
    return workspace:WaitForChild("Values"):WaitForChild("CurrentGame"):GetPropertyChangedSignal("Value"):Once(func)
end

function Script.Functions.HideAndSeekFuncCaller(meta)
    if Script.Connections[meta.text] then
        Script.Connections[meta.text]:Disconnect()
        Script.Connections[meta.text] = nil
    end
    if Script.Connections[meta.text.."descendant"] then
        Script.Connections[meta.text.."descendant"]:Disconnect()
        Script.Connections[meta.text.."descendant"] = nil
    end
    if Script.Connections[meta.text.."descDestroy"] then
        Script.Connections[meta.text.."descDestroy"]:Disconnect()
        Script.Connections[meta.text.."descDestroy"] = nil
    end
    meta.func()
    Script.Connections[meta.text] = Script.Functions.OnceOnGameChanged(function()
        for _, esp in pairs(Script.ESPTable[meta.text]) do
            esp.Destroy()
        end
    end)
    if meta.descendantcheck then
        Script.Connections[meta.text.."descendant"] = workspace.DescendantAdded:Connect(function(descendant)
            if Script.GameState ~= "HideAndSeek" then return end
            meta.descendantcheck(descendant)
        end)
        Script.Connections[meta.text.."descDestroy"] = Script.Functions.OnceOnGameChanged(function()
            if Script.Connections[meta.text.."descendant"] then
                Script.Connections[meta.text.."descendant"]:Disconnect()
                Script.Connections[meta.text.."descendant"] = nil
            end
        end)
    end
end

local ESPGroupBox = Tabs.Visuals:AddLeftGroupbox("Hide and Seek ESP", "search") do
    for _, meta in pairs(HIDE_AND_SEEK_ESP_META) do
        ESPGroupBox:AddToggle(meta.metaName, {
            Text = meta.text,
            Default = meta.default
        }):AddColorPicker(meta.color.metaName, {
            Default = meta.color.default
        })

        Toggles[meta.metaName]:OnChanged(function(call)
            if call then
                if Script.GameState ~= "HideAndSeek" then return end
                Script.Functions.HideAndSeekFuncCaller(meta)
            else
                if Script.Connections[meta.text] then
                    Script.Connections[meta.text]:Disconnect()
                    Script.Connections[meta.text] = nil
                end
                if Script.Connections[meta.text.."descendant"] then
                    Script.Connections[meta.text.."descendant"]:Disconnect()
                    Script.Connections[meta.text.."descendant"] = nil
                end
                if Script.Connections[meta.text.."descDestroy"] then
                    Script.Connections[meta.text.."descDestroy"]:Disconnect()
                    Script.Connections[meta.text.."descDestroy"] = nil
                end
                for _, esp in pairs(Script.ESPTable[meta.text]) do
                    esp.Destroy()
                end
            end
        end)

        Options[meta.color.metaName]:OnChanged(function(value)
            if Script.GameState ~= "HideAndSeek" then return end
            local mtext = meta.color.text or meta.text
            local check = function(_) return true end
            if mtext == "Player" then
                if meta.metaName == "SeekerESP" then
                    check = function(t) return t:sub(-8) == "(Seeker)" end
                end
                if meta.metaName == "HiderESP" then
                    check = function(t) return t:sub(-7) == "(Hider)" end
                end
            end
            if Toggles[meta.metaName].Value then
                for _, esp in pairs(Script.ESPTable[mtext]) do
                    if check(esp.Text) then
                        esp.SetColor(value)
                    end
                end
            end
        end)
    end
end

local ESPSettingsGroupBox = Tabs.Visuals:AddRightGroupbox("ESP Settings", "sliders") do
    ESPSettingsGroupBox:AddToggle("ESPHighlight", {
        Text = "Enable Highlight",
        Default = true,
    })

    ESPSettingsGroupBox:AddToggle("ESPDistance", {
        Text = "Show Distance",
        Default = true,
    })

    ESPSettingsGroupBox:AddSlider("ESPTransparency", {
        Text = "Transparency",
        Default = 0.75,
        Min = 0,
        Max = 1,
        Rounding = 2
    })

    ESPSettingsGroupBox:AddSlider("ESPTextSize", {
        Text = "Text Size",
        Default = 22,
        Min = 16,
        Max = 26,
        Rounding = 0
    })
end

local SelfGroupBox = Tabs.Visuals:AddRightGroupbox("Self", "user") do
    SelfGroupBox:AddToggle("FOVToggle", {
        Text = "FOV",
        Default = false
    })
    SelfGroupBox:AddSlider("FOVSlider", {
        Text = "FOV",
        Default = 60, 
        Min = 10,
        Max = 120,
        Rounding = 1
    })
end

local FunGroupBox = Tabs.Other:AddLeftGroupbox("Fun", "zap") do
    FunGroupBox:AddToggle("InkGameAutowin", {
        Text = "Autowin ⭐",
        Default = false
    })

    Toggles.InkGameAutowin:OnChanged(function(call)
        if call then
            Script.Functions.EffectsNotification("Autowin enabled!", 5)
            Script.Functions.HandleAutowin()
        else
            Script.Functions.Alert("Autowin disabled!", 3)
        end
    end)

    FunGroupBox:AddToggle("FlingAuraToggle", {
        Text = "Fling Aura",
        Default = false
    })
    
    FunGroupBox:AddToggle("AntiFlingToggle", {
        Text = "Anti Fling",
        Default = false
    })
    
    Toggles.AntiFlingToggle:OnChanged(function(call)
        if Script.Tasks.AntiFlingLoop then
            task.cancel(Script.Tasks.AntiFlingLoop)
            Script.Tasks.AntiFlingLoop = nil
        end
        if call then
            if not hookmetamethod then
                Script.Functions.Alert("[Fling Aura]: Unsupported executor :(")
                Toggles.AntiFlingToggle:SetValue(false)
                return
            end
            Script.Temp.PauseAntiFling = nil
            Script.Functions.Alert("Anti Fling Enabled", 3)
            Script.Temp.AntiFlingActive = true
            Script.Tasks.AntiFlingLoop = task.spawn(function()
                local lastSafeCFrame = nil
                while Script.Temp.AntiFlingActive and not Library.Unloaded do
                    if Script.Temp.PauseAntiFling then return end
                    local character = lplr.Character
                    local root = character and (Script.Functions.GetRootPart() or character:FindFirstChild("Torso"))
                    if root then
                        local gs = Script.GameState
                        local isActiveGame = gs and gs ~= "" and States[gs] ~= nil
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
                        if not lastSafeCFrame or (root.Position - lastSafeCFrame.Position).Magnitude < 20 then
                            lastSafeCFrame = root.CFrame
                        elseif isActiveGame and (root.Position - lastSafeCFrame.Position).Magnitude > 50 then
                            root.CFrame = lastSafeCFrame
                            root.Velocity = Vector3.zero
                        end
                    end
                    task.wait(0.05)
                end
                Script.Tasks.AntiFlingLoop = nil
            end)
        else
            Script.Functions.Alert("Anti Fling Disabled", 3)
            Script.Temp.AntiFlingActive = false
        end
    end)
end

local InteractionGroup = Tabs.Other:AddLeftGroupbox("Interaction", "hand-pointer") do
    InteractionGroup:AddToggle("NoInteractDelay", {
        Text = "Instant Interact",
        Default = false
    })
    Toggles.NoInteractDelay:OnChanged(function(call)
        if Script.Connections.NoInteractDelayConnection then
            Script.Connections.NoInteractDelayConnection:Disconnect()
            Script.Connections.NoInteractDelayConnection = nil
        end
        if not call then return end
        Script.Connections.NoInteractDelayConnection = ProximityPromptService.PromptShown:Connect(function(prompt)
            prompt.HoldDuration = 0
        end)
    end)
    InteractionGroup:AddSlider("PromptReachSlider", {
        Text = "Interaction Reach Multiplier",
        Default = 1.5,
        Min = 1,
        Max = 2,
        Rounding = 1
    })
    InteractionGroup:AddToggle("PromptReachToggle", {
        Text = "Interaction Reach",
        Default = false
    })

    Script.Temp.ActivePrompts = {}

    Options.PromptReachSlider:OnChanged(function(_)
        if not Toggles.PromptReachToggle.Value then return end
        for _, prompt in pairs(Script.Temp.ActivePrompts) do
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
    end)

    Toggles.PromptReachToggle:OnChanged(function(call)
        if Script.Connections.PromptReachConnection then
            Script.Connections.PromptReachConnection:Disconnect()
            Script.Connections.PromptReachConnection = nil
        end
        for _, prompt in pairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                if not Script.Temp.ActivePrompts[prompt] then
                    Script.Temp.ActivePrompts[prompt] = prompt.MaxActivationDistance
                end
                prompt.MaxActivationDistance = Script.Temp.ActivePrompts[prompt]
                if call then
                    prompt.MaxActivationDistance = prompt.MaxActivationDistance * Options.PromptReachSlider.Value
                end
            end
        end
        if call then
            Script.Connections.PromptReachConnection = workspace.DescendantAdded:Connect(function(obj)
                if obj:IsA("ProximityPrompt") then
                    Script.Temp.ActivePrompts[obj] = obj.MaxActivationDistance
                    obj.MaxActivationDistance = Script.Temp.ActivePrompts[obj] * Options.PromptReachSlider.Value
                    obj.Destroying:Once(function()
                        if Script.Temp.ActivePrompts[obj] then
                            Script.Temp.ActivePrompts[obj] = nil
                        end
                    end)
                end
            end)
        end
    end)
end

function Script.Functions.FindCarryPrompt(plr)
    if not plr.Character then return false end
    if not plr.Character:FindFirstChild("HumanoidRootPart") then return false end
    if not (plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Humanoid").Health > 0) then return false end

    local CarryPrompt = plr.Character.HumanoidRootPart:FindFirstChild("CarryPrompt")
    return CarryPrompt
end

function Script.Functions.FireCarryPrompt(plr)
    local CarryPrompt = Script.Functions.FindCarryPrompt(plr)
    if not CarryPrompt then return false end

    local suc = pcall(function()
        CarryPrompt.HoldDuration = 0
        CarryPrompt:InputHoldBegin()
    end)
    return suc
end

function Script.Functions.FindInjuredPlayer()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == lplr then continue end
        if plr:GetAttribute("IsDead") then continue end
        local CarryPrompt = Script.Functions.FindCarryPrompt(plr)
        if not CarryPrompt then continue end
        if plr.Character and plr.Character:FindFirstChild("SafeRedLightGreenLight") then continue end
        if plr.Character and plr.Character:FindFirstChild("IsBeingHeld") then continue end
        return plr, CarryPrompt
    end
end

function Script.Functions.UnCarryPerson()
    local args = {
        {
            tryingtoleave = true
        }
    }
    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ClickedButton"):FireServer(unpack(args))    
end

local GreenLightRedLightGroup = Tabs.Main:AddLeftGroupbox("Red Light / Green Light", "traffic-light") do
    GreenLightRedLightGroup:AddToggle("RedLightGodmode", {
        Text = "Godmode",
        Default = false
    })
    
    local RLGL_OriginalNamecall
    Toggles.RedLightGodmode:OnChanged(function(enabled)
        if enabled then
            if not hookmetamethod then
                Script.Functions.Alert("Your executor doesn't support this :(")
                Toggles.RedLightGodMode:SetValue(false)
                return
            end
            local TrafficLightImage = lplr.PlayerGui:FindFirstChild("ImpactFrames") and lplr.PlayerGui.ImpactFrames:FindFirstChild("TrafficLightEmpty")
            local lastRootPartCFrame = nil
            local isGreenLight = true
            if TrafficLightImage and ReplicatedStorage:FindFirstChild("Effects") and ReplicatedStorage.Effects:FindFirstChild("Images") and ReplicatedStorage.Effects.Images:FindFirstChild("TrafficLights") and ReplicatedStorage.Effects.Images.TrafficLights:FindFirstChild("GreenLight") then
                isGreenLight = TrafficLightImage.Image == ReplicatedStorage.Effects.Images.TrafficLights.GreenLight.Image
            end
            local function updateState()
                local root = Script.Functions.GetRootPart()
                if root then
                    lastRootPartCFrame = root.CFrame
                end
            end
            updateState()
            local RLGL_Connection = ReplicatedStorage.Remotes.Effects.OnClientEvent:Connect(function(EffectsData)
                if EffectsData.EffectName ~= "TrafficLight" then return end
                isGreenLight = EffectsData.GreenLight == true
                updateState()
            end)
            Script.Connections.RLGL_Connection = RLGL_Connection
            RLGL_OriginalNamecall = RLGL_OriginalNamecall or hookmetamethod(game, "__namecall", function(self, ...)
                local args = {...}
                local method = getnamecallmethod()
                if tostring(self) == "rootCFrame" and method == "FireServer" and Script.GameState == "RedLightGreenLight" then
                    if Toggles.RedLightGodmode.Value and not isGreenLight and lastRootPartCFrame then
                        args[1] = lastRootPartCFrame
                        return RLGL_OriginalNamecall(self, unpack(args))
                    end
                end
                return RLGL_OriginalNamecall(self, ...)
            end)
            Script.Temp.RLGL_OriginalNamecall = RLGL_OriginalNamecall
            Script.Functions.Alert("Red Light Green Light Godmode Enabled", 3)
        else
            if Script.Connections.RLGL_Connection then
                pcall(function() Script.Connections.RLGL_Connection:Disconnect() end)
                Script.Connections.RLGL_Connection = nil
            end
            if Script.Temp.RLGL_OriginalNamecall then
                hookmetamethod(game, "__namecall", Script.Temp.RLGL_OriginalNamecall)
                Script.Temp.RLGL_OriginalNamecall = nil
            end
            Script.Functions.Alert("Red Light Green Light Godmode Disabled", 3)
        end
    end)
    GreenLightRedLightGroup:AddButton("Complete Red Light / Green Light", function()
        if not game.Workspace:FindFirstChild("RedLightGreenLight") then
            Script.Functions.Alert("Game not running")
            return
        end
        Script.Functions.WinRLGL()
    end)
    GreenLightRedLightGroup:AddButton("Remove Injured Walking", function()
        if lplr.Character and lplr.Character:FindFirstChild("InjuredWalking") then
            lplr.Character.InjuredWalking:Destroy()
        end
        Script.Functions.BypassRagdoll()
        if Script.Tasks.RagdollBlockConn then
            Script.Tasks.RagdollBlockConn:Disconnect()
            Script.Tasks.RagdollBlockConn = nil
        end
    end)
    GreenLightRedLightGroup:AddButton("Bring Injured Player", function()
        local injuredPlayer, carryPrompt = Script.Functions.FindInjuredPlayer()
        if not injuredPlayer or not carryPrompt then
            Script.Functions.Alert("No injured player found!", 2)
            return
        end
        if lplr.Character and injuredPlayer.Character and injuredPlayer.Character.PrimaryPart then
            Script.Temp.PauseAntiFling = true
            lplr.Character:PivotTo(injuredPlayer.Character:GetPrimaryPartCFrame())
            task.wait(0.2)
            Script.Functions.FireCarryPrompt(injuredPlayer)
            task.wait(0.2)
            Script.Functions.WinRLGL()
            task.wait(0.2)
            Script.Functions.UnCarryPerson()
            task.wait(0.2)
            Script.Temp.PauseAntiFling = false
        end
    end)

    GreenLightRedLightGroup:AddToggle("LoopBringPlayers", {
        Text = "Loop Bring Players",
        Default = false
    }):OnChanged(function(val)
        if Script.Tasks.bringLoopThread then
            task.cancel(Script.Tasks.bringLoopThread)
            Script.Tasks.bringLoopThread = nil
        end
        if val then
            Script.Tasks.bringLoopThread = task.spawn(function()
                while Toggles.LoopBringPlayers.Value and Script.GameState == "RedLightGreenLight" and not Library.Unloaded do
                    local injuredPlayer, carryPrompt = Script.Functions.FindInjuredPlayer()
                    if injuredPlayer and carryPrompt and lplr.Character and injuredPlayer.Character and injuredPlayer.Character.PrimaryPart then
                        Script.Temp.PauseAntiFling = true
                        if Toggles.RedLightGodmode.Value then
                            Toggles.RedLightGodmode:SetValue(false)
                        end
                        lplr.Character:PivotTo(injuredPlayer.Character:GetPrimaryPartCFrame())
                        task.wait(0.2)
                        Script.Functions.FireCarryPrompt(injuredPlayer)
                        task.wait(0.2)
                        Script.Functions.WinRLGL()
                        tsk.wait(0.2)
                        Script.Functions.UnCarryPerson()
                        task.wait(0.2)
                        Script.Temp.PauseAntiFling = false
                    end
                    task.wait(1)
                end
                Script.Tasks.bringLoopThread = nil
            end)
        end
    end)
    Toggles.LoopBringPlayers:SetVisible(false)
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

local DalgonaGameGroup = Tabs.Main:AddLeftGroupbox("Dalgona Game", "circle") do
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
        Default = false
    })
    Toggles.ImmuneDalgonaGame:OnChanged(function(call)
        if call then
            if not hookmetamethod then
                Script.Functions.Alert("Your executor doesn't suport this function :(", 5)
                Toggles.ImmuneDalgonaGame:SetValue(false)
                return
            end
            local DalgonaRemoteHook
            DalgonaRemoteHook = hookmetamethod(game, "__namecall", function(self, ...)
                local args = {...}
                local method = getnamecallmethod()

                if tostring(self) == "DALGONATEMPREMPTE" and method == "FireServer" then
                    if args[1] ~= nil and type(args[1]) == "table" and args[1].CrackAmount ~= nil then
                        Script.Functions.Alert("Prevented your cookie from cracking", 3)
                        return nil
                    end
                end
                
                return DalgonaRemoteHook(self, unpack(args))
            end)
            Script.Temp.DalgonaRemoteHook = DalgonaRemoteHook
            Script.Functions.Alert("Your cookie will not break from now on!", 3)
        else
            if not hookmetamethod then return end
            if not Script.Temp.DalgonaRemoteHook then return end
            hookmetamethod(game, '__namecall', Script.Temp.DalgonaRemoteHook)
        end
    end)
end

local TugOfWarGroup = Tabs.Main:AddLeftGroupbox("Tug Of War", "rope") do
    TugOfWarGroup:AddToggle("AutoPull", {
        Text = "Auto Pull",
        Default = false
    })
    TugOfWarGroup:AddSlider("AutoPullDelay", {
        Text = "Auto Pull Delay",
        Default = 0.2,
        Min = 0,
        Max = 1.5,
        Rounding = 2
    })
end

function Script.Functions.AutoMingle(call)
    if Script.Tasks.AutoMingleQTEThread then
        task.cancel(Script.Tasks.AutoMingleQTEThread)
        Script.Tasks.AutoMingleQTEThread = nil
    end
    if not call or Script.GameState ~= "Mingle" then return end
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
end

local MingleGroup = Tabs.Main:AddLeftGroupbox("Mingle", "users") do
    MingleGroup:AddToggle("AutoMingleQTE", {
        Text = "Auto Mingle",
        Default = false
    })
    Toggles.AutoMingleQTE:OnChanged(AutoMingle)
end

local GlassBridgeGroup = Tabs.Main:AddLeftGroupbox("Glass Bridge", "bridge") do
    GlassBridgeGroup:AddButton("Complete Glass Bridge Game", function()
        if not workspace:FindFirstChild("GlassBridge") then
            Script.Functions.Alert("Game not running")
            return
        end
        Script.Functions.WinGlassBridge()
    end)
    
    GlassBridgeGroup:AddToggle("RevealGlassBridge", {
        Text = "Reveal Glass Bridge",
        Default = false
    })
    Toggles.RevealGlassBridge:OnChanged(function(call)
        if call then
            if workspace:FindFirstChild("GlassBridge") then
                Script.Functions.RevealGlassBridge()
            end
        end
    end)
end

function Script.Functions.GetHider()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == lplr then continue end
        if not plr.Character then continue end
        if not plr.Character:FindFirstChild("BlueVest") then continue end
        if plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            return plr.Character
        end
    end
end

local HideAndSeekGroup = Tabs.Main:AddRightGroupbox("Hide And Seeek", "search") do
    HideAndSeekGroup:AddToggle("TeleportToHider", {
        Text = "Teleport To Hider",
        Default = false
    }):AddKeyPicker("TTH", {
        Mode = "Toggle",
        Default = "P",
        Text = "Teleport To Hider",
        SyncToggleState = true
    })
    Toggles.TeleportToHider:OnChanged(function(call)
        if call then
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
    end)
    HideAndSeekGroup:AddToggle("StaminaBypass", {
        Text = "Infinite Stamina",
        Default = false
    })
    Toggles.StaminaBypass:OnChanged(function(enabled)
        if Script.Tasks.StaminaBypassLoop then
            task.cancel(Script.Tasks.StaminaBypassLoop)
            Script.Tasks.StaminaBypassLoop = nil
        end
        if enabled then
            Script.Tasks.StaminaBypassLoop = task.spawn(function()
                while Toggles.StaminaBypass.Value and not Library.Unloaded do
                    local char = lplr.Character
                    if char then
                        local stamina = char:FindFirstChild("StaminaVal")
                        if stamina then
                            stamina.Value = 100
                        end
                    end
                    task.wait(0.1)
                end
                Script.Tasks.StaminaBypassLoop = nil
            end)
        end
    end)
    HideAndSeekGroup:AddButton("Teleport to Safe Hiding Spot", function()
        if Script.GameState == "HideAndSeek" then
            Script.Functions.TeleportSafeHidingSpot()
        end
    end)
end

function Script.Functions.Wallcheck(attackerCharacter, targetCharacter, additionalIgnore)
    if not (attackerCharacter and targetCharacter) then
        return false
    end
    local humanoidRootPart = attackerCharacter.PrimaryPart
    local targetRootPart = targetCharacter.PrimaryPart
    if not (humanoidRootPart and targetRootPart) then
        return false
    end
    local origin = humanoidRootPart.Position
    local targetPosition = targetRootPart.Position
    local direction = targetPosition - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.RespectCanCollide = true
    local ignoreList = {attackerCharacter}
    if additionalIgnore and typeof(additionalIgnore) == "table" then
        for _, item in pairs(additionalIgnore) do
            table.insert(ignoreList, item)
        end
    end
    raycastParams.FilterDescendantsInstances = ignoreList
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    if raycastResult then
        if raycastResult.Instance:IsDescendantOf(targetCharacter) then
            return true
        else
            return false
        end
    else
        return true
    end
end

local RebelGroup = Tabs.Main:AddRightGroupbox("Rebel", "sword") do
    RebelGroup:AddToggle("ExpandGuardHitbox", {
        Text = "Expand Guard Hitbox",
        Default = false
    })

    local processedModels = {}
    local TARGET_SIZE = Vector3.new(4, 4, 4)
    local DEFAULT_SIZE = Vector3.new(1, 1, 1)

    local function cleanup()
        for model, head in pairs(processedModels) do
            if head and head.Parent then
                pcall(function()
                    head.Size = DEFAULT_SIZE
                    head.CanCollide = true
                end)
            end
        end
        processedModels = {}
    end

    Toggles.ExpandGuardHitbox:OnChanged(function(call)
        if Script.Tasks.ExpandGuardHitboxLoop then
            task.cancel(Script.Tasks.ExpandGuardHitboxLoop)
            Script.Tasks.ExpandGuardHitboxLoop = nil
        end
        if call then
            Script.Tasks.ExpandGuardHitboxLoop = task.spawn(function()
                repeat
                    local liveFolder = workspace:FindFirstChild("Live")
                    if not Toggles.ExpandGuardHitbox.Value or not liveFolder then return end
                    for _, model in ipairs(liveFolder:GetChildren()) do
                        if not isGuard(model) then continue end
                        if processedModels[model] then continue end

                        local head = model:FindFirstChild("Head")
                        if not head or not head:IsA("BasePart") then continue end
                        processedModels[model] = head
                    end
                    for model, head in pairs(processedModels) do
                        if model and model.Parent and head and head.Parent then
                            if head.Size ~= TARGET_SIZE then
                                head.Size = TARGET_SIZE
                                head.CanCollide = false
                            end
                        else
                            processedModels[model] = nil
                        end
                    end
                    task.wait(3)
                until not Toggles.ExpandGuardHitbox.Value or Library.Unloaded
                Script.Tasks.ExpandGuardHitboxLoop = nil
            end)
        else
            cleanup()
        end
    end)
    
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

    RebelGroup:AddToggle("GunMods", { Text = "Gun Mods", Default = false })
    
    local originalGunStats = {}
    local originalDamageValues = {}
    local function patchGunStats(enable)
        local Guns = ReplicatedStorage:FindFirstChild("Weapons") and ReplicatedStorage.Weapons:FindFirstChild("Guns")
        if not Guns then return end
        local GunDamageValues = Script.Functions.SafeRequire(ReplicatedStorage.Modules.GunDamageValues)
        for _, gun in pairs(Guns:GetChildren()) do
            if enable then
                if not originalGunStats[gun.Name] then
                    originalGunStats[gun.Name] = {}
                    for _, stat in ipairs({"Spread", "FireRateCD", "MaxBullets", "ReloadingSpeed"}) do
                        if gun:FindFirstChild(stat) then
                            originalGunStats[gun.Name][stat] = gun[stat].Value
                        end
                    end
                end
                if gun:FindFirstChild("Spread") then gun.Spread.Value = 0 end
                if gun:FindFirstChild("FireRateCD") then gun.FireRateCD.Value = 0.01 end
                if gun:FindFirstChild("MaxBullets") then gun.MaxBullets.Value = 999 end
                if gun:FindFirstChild("ReloadingSpeed") then gun.ReloadingSpeed.Value = 0.01 end

                if GunDamageValues and GunDamageValues[gun.Name] then
                    if not originalDamageValues[gun.Name] then
                        originalDamageValues[gun.Name] = {}
                        for part, dmg in pairs(GunDamageValues[gun.Name]) do
                            originalDamageValues[gun.Name][part] = dmg
                        end
                    end
                    for part, _ in pairs(GunDamageValues[gun.Name]) do
                        GunDamageValues[gun.Name][part] = 9999
                    end
                end
            else
                if originalGunStats[gun.Name] then
                    for stat, val in pairs(originalGunStats[gun.Name]) do
                        if gun:FindFirstChild(stat) then
                            gun[stat].Value = val
                        end
                    end
                end
                if GunDamageValues and GunDamageValues[gun.Name] and originalDamageValues[gun.Name] then
                    for part, val in pairs(originalDamageValues[gun.Name]) do
                        GunDamageValues[gun.Name][part] = val
                    end
                end
            end
        end
    end

    Toggles.GunMods:OnChanged(function(enabled)
        patchGunStats(enabled)
    end)
end

function Script.Functions.GetKeysOfTable(tab)
	local res = {}
	for i,v in pairs(tab) do 
        table.insert(res, tostring(i))
    end
	return res
end

function Script.Functions.GetEmotesMeta()
    local Animations = ReplicatedStorage:WaitForChild("Animations", 10)
    if not Animations then Script.Functions.Warn("[GetEmotesMeta]: Animations folder timeout!"); return end
    local Emotes = Animations:WaitForChild("Emotes", 10)
    if not Emotes then Script.Functions.Warn("[GetEmotesMeta]: Emotes folder timeout!"); return end
    local res = {}
    for i, v in pairs(Emotes:GetChildren()) do
        if v.ClassName ~= "Animation" then continue end
        if not v.AnimationId then continue end

        if res[v.Name] then
            Script.Functions.Warn("[GetEmotesMeta | Resolver]: The emote "..tostring(v.Name).." is duplicated! Overwriting past data...")
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
    local w = function(str) Script.Functions.Warn("[RefreshEmoteList]: "..tostring(str)) end
    local res = Script.Functions.GetEmotesMeta()
    if not res then w("res not found!") return end
    if not Options.EmotesList then w("Emotes List Option not found!") return end
    Options.EmotesList:SetValues(Script.Functions.GetKeysOfTable(res))
end

function Script.Functions.HookEmotesFolder()
    Script.Functions.RefreshEmoteList()
    local Animations = ReplicatedStorage:WaitForChild("Animations")
    local Emotes = Animations:WaitForChild("Emotes")
    Library:GiveSignal(Emotes.ChildAdded:Connect(Script.Functions.RefreshEmoteList))
    Library:GiveSignal(Emotes.ChildRemoved:Connect(Script.Functions.RefreshEmoteList))
end

function Script.Functions.ValidateEmote(emote : string)
    return Script.Temp.EmoteList ~= nil and Script.Temp.EmoteList[emote]
end

function Script.Functions.PlayEmote(emoteId, emoteObject)
    -- emoteId is AnimationId (string), emoteObject is an Animation instance
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
    if emoteObject and emoteObject.AnimationId then
        animId = emoteObject.AnimationId
    end
    if not animId or animId == "" then
        Script.Functions.Alert("[Emote] Invalid AnimationId!", 3)
        return
    end
    local anim = Instance.new("Animation")
    anim.AnimationId = animId
    local track
    local success, err = pcall(function()
        track = humanoid:LoadAnimation(anim)
        track.Priority = Enum.AnimationPriority.Action
        track:Play()
        Script.Temp.EmoteTrack = track
    end)
    if not success or not track then
        Script.Functions.Alert("[Emote] Failed to play emote!", 3)
        return
    end
end

local EmotesGroup = Tabs.Misc:AddRightGroupbox("Emote", "smile") do
    EmotesGroup:AddDropdown("EmotesList", { 
        Text = 'Emotes List', 
        Values = {}, 
        AllowNull = true 
    })
    task.spawn(Script.Functions.HookEmotesFolder)
    EmotesGroup:AddButton("Play Emote", function()
        if Options.EmotesList.Value then
            local emoteId = Script.Functions.ValidateEmote(Options.EmotesList.Value)
            if emoteId and emoteId.anim and emoteId.object then
                Script.Functions.PlayEmote(emoteId.anim, emoteId.object)
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
end

local MiscGroup = Tabs.Misc:AddLeftGroupbox("Misc", "wrench") do
    MiscGroup:AddToggle("AntiRagdoll", {
        Text = "Anti Ragdoll + No Stun",
        Default = false
    })

    MiscGroup:AddButton("Remove Ragdoll Effect", function()
        Script.Functions.BypassRagdoll()
        if Script.Tasks.RagdollBlockConn then
            Script.Tasks.RagdollBlockConn:Disconnect()
            Script.Tasks.RagdollBlockConn = nil
        end
    end)

    MiscGroup:AddToggle("SpectateModeToggler", {
        Text = "Enable Spectator Mode",
        Default = false
    })
    Toggles.SpectateModeToggler:OnChanged(function(call)
        workspace.Values.CanSpectateIfWonGame.Value = call
    end)
    MiscGroup:AddButton("Fix Camera", function()
        -- Script.Functions.FixCamera
        if camera then
            camera.CameraType = Enum.CameraType.Custom
            if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = lplr.Character:FindFirstChild("Humanoid")
            end
        end
    end)
    MiscGroup:AddButton("Reset Camera \n [Might Break camera!]", Script.Functions.FixCamera)
    MiscGroup:AddButton("Skip Cutscene", function()
        -- Script.Functions.FixCamera
        if camera then
            camera.CameraType = Enum.CameraType.Custom
            if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = lplr.Character:FindFirstChild("Humanoid")
            end
        end
    end)
    MiscGroup:AddToggle("TeleportToSafePlace", {
        Text = "Teleport To Safe Place",
        Default = false
    }):AddKeyPicker("TTSPKey", {
        Mode = "Toggle",
        Default = "L",
        Text = "Teleport To Safe Place",
        SyncToggleState = true
    })
    Toggles.TeleportToSafePlace:OnChanged(function(call)
        if call then
            Script.Functions.Alert("Teleported to Safe Place, disable to go back", 3)
            Script.Functions.TeleportSafe()
        else
            Script.Functions.TeleportBackFromSafe()
        end
    end)

    function Script.Functions.ToggleTPTSP()
        pcall(function()
            if not Toggles.TeleportToSafePlace.Value then
                Toggles.TeleportToSafePlace:SetValue(true)
            end
        end)
    end

    MiscGroup:AddButton("Fix Players Visibility", Script.Functions.CheckPlayersVisibility)
end

Toggles.AntiRagdoll:OnChanged(function(call)
    if Script.Tasks.AntiRagdollLoop then
        task.cancel(Script.Tasks.AntiRagdollLoop)
        Script.Tasks.AntiRagdollLoop = nil
    end
    if Script.Tasks.RagdollBlockConn then
        Script.Tasks.RagdollBlockConn:Disconnect()
        Script.Tasks.RagdollBlockConn = nil
    end
    if call then
        Script.Functions.Alert("Anti Ragdoll + No Stun Enabled", 3)
        Script.Functions.BypassRagdoll()
        Script.Tasks.AntiRagdollLoop = task.spawn(function()
            while Toggles.AntiRagdoll.Value and not Library.Unloaded do
                Script.Functions.BypassRagdoll()
                task.wait(0.1)
            end
        end)
    else
        Script.Functions.Alert("Anti Ragdoll + No Stun Disabled", 3)
    end
end)

Library:GiveSignal(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    if workspace.CurrentCamera then
        camera = workspace.CurrentCamera
    end
end))

Toggles.FOVToggle:OnChanged(function(call)
    if Script.Tasks.FOVChangeTask then
        task.cancel(Script.Tasks.FOVChangeTask)
        Script.Tasks.FOVChangeTask = nil
    end
    if call then
        Script.Temp.OldFOV = camera and camera.FieldOfView or 60
        Script.Tasks.FOVChangeTask = task.spawn(function()
            repeat 
                local AutoRun = lplr:FindFirstChild("AutoRun")
                if AutoRun and AutoRun.Value then return end
                if camera then
                    camera.FieldOfView = Options.FOVSlider.Value
                end
                task.wait()
            until not Toggles.FOVToggle.Value or Library.Unloaded
        end)
    end
end)

local PlayerGroupBox = Tabs.Main:AddRightGroupbox("Player", "user") do
    PlayerGroupBox:AddSlider("WonBoostSlider", {
        Text = "Won boost",
        Default = lplr.Boosts['Won Boost'].Value,
        Min = 0,
        Max = 3,
        Rounding = 0
    })

    PlayerGroupBox:AddSlider("StrengthBoostSlider", {
        Text = "Strength boost",
        Default = lplr.Boosts['Damage Boost'].Value,
        Min = 0,
        Max = 5,
        Rounding = 0
    })

    PlayerGroupBox:AddSlider("SpeedBoostSlider", {
        Text = "Speed boost",
        Default = lplr.Boosts['Faster Sprint'].Value,
        Min = 0,
        Max = 5,
        Rounding = 0
    })

    PlayerGroupBox:AddSlider("SpeedSlider", {
        Text = "Walk Speed",
        Default = 30,
        Min = 0,
        Max = 100,
        Rounding = 1
    })
    
    PlayerGroupBox:AddToggle("SpeedToggle", {
        Text = "Speed",
        Default = false
    }):AddKeyPicker("SpeedKey", {
        Mode = "Toggle",
        Default = "C",
        Text = "Speed",
        SyncToggleState = true
    })

    PlayerGroupBox:AddToggle("Noclip", {
        Text = "Noclip",
        Default = false
    }):AddKeyPicker("NoclipKey", {
        Mode = "Toggle",
        Default = "N",
        Text = "Noclip",
        SyncToggleState = true
    })

    PlayerGroupBox:AddToggle("InfiniteJump", {
        Text = "Infinite Jump",
        Default = false
    })

    Toggles.InfiniteJump:OnChanged(function(call)
        if Script.Connections.InfiniteJumpConnect then
            Script.Connections.InfiniteJumpConnect:Disconnect()
        end
        if not call then return end
        Script.Connections.InfiniteJumpConnect = UserInputService.JumpRequest:Connect(function()
            if not lplr.Character then return end
            if not lplr.Character:FindFirstChild("Humanoid") then return end
            lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end)

    PlayerGroupBox:AddToggle("Fly", {
        Text = "Fly",
        Default = false
    })
    
    PlayerGroupBox:AddSlider("FlySpeed", {
        Text = "Fly Speed",
        Default = 40,
        Min = 10,
        Max = 100,
        Rounding = 1,
        Compact = true,
    })
end

Toggles.Fly:SetVisible(false)
Options.FlySpeed:SetVisible(false)

Toggles.FlingAuraToggle:OnChanged(function(call)
    local function setNoclip(state)
    end

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
    if call then
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
end)

Toggles.Noclip:OnChanged(function(call)
    Script.Temp.NoclipParts = Script.Temp.NoclipParts or {}
    if call then
        Script.Functions.Alert("Noclip Enabled", 3)
        local function NoclipLoop()
            if lplr.Character ~= nil then
                for _, child in pairs(lplr.Character:GetDescendants()) do
                    if child:IsA("BasePart") and child.CanCollide == true then
                        child.CanCollide = false
                        Script.Temp.NoclipParts[child] = true
                    end
                end
            end
        end
        if Script.Tasks.NoclipTask then
            task.cancel(Script.Tasks.NoclipTask)
            Script.Tasks.NoclipTask = nil
        end
        Script.Tasks.NoclipTask = task.spawn(function()
            repeat 
                RunService.Heartbeat:Wait()
                NoclipLoop()
            until not Toggles.Noclip.Value or Library.Unloaded
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
end)

Options.SpeedBoostSlider:OnChanged(function(val)
    lplr.Boosts['Faster Sprint'].Value = val
end)

Options.StrengthBoostSlider:OnChanged(function(val)
    lplr.Boosts['Damage Boost'].Value = val
end)

Options.WonBoostSlider:OnChanged(function(val)
    lplr.Boosts['Won Boost'].Value = val
end)

Options.SpeedSlider:OnChanged(function(val)
    if not Toggles.SpeedToggle.Value then return end
    if not lplr.Character then return end
    if not lplr.Character:FindFirstChild("Humanoid") then return end
    lplr.Character.Humanoid.WalkSpeed = Options.SpeedSlider.Value
end)

Toggles.SpeedToggle:OnChanged(function(call)
    if call then
        Script.Functions.Alert("Speed Enabled", 3)
        if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
            Script.Temp.OldSpeed = lplr.Character.Humanoid.WalkSpeed
            lplr.Character.Humanoid.WalkSpeed = Options.SpeedSlider.Value
        end
        if Script.Tasks.SpeedToggleTask then
            task.cancel(Script.Tasks.SpeedToggleTask)
            Script.Tasks.SpeedToggleTask = nil
        end
        Script.Tasks.SpeedToggleTask = task.spawn(function()
            repeat
                task.wait(0.5)
                if not Toggles.SpeedToggle.Value then return end
                if not lplr.Character then return end
                if not lplr.Character:FindFirstChild("Humanoid") then return end
                if call then
                    lplr.Character.Humanoid.WalkSpeed = Options.SpeedSlider.Value
                end
            until not Toggles.SpeedToggle.Value or Library.Unloaded
        end)
    else
        Script.Functions.Alert("Speed Disabled", 3)
        if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
            lplr.Character.Humanoid.WalkSpeed = 31
            Script.Temp.OldSpeed = nil
        end
    end
end)    

local controlModule

Toggles.Fly:OnChanged(function(value)
    local rootPart = Script.Functions.GetRootPart()
    if not rootPart then return end

    local humanoid = Script.Functions.GetHumanoid()
    if humanoid then
        humanoid.PlatformStand = value
    end

    local flyBody = Script.Temp.FlyBody or Instance.new("BodyVelocity")
    flyBody.Velocity = Vector3.zero
    flyBody.MaxForce = Vector3.one * 9e9
    Script.Temp.FlyBody = flyBody

    Script.Temp.FlyBody.Parent = value and rootPart or nil

    if value then
        controlModule = controlModule or Script.Functions.SafeRequire(lplr:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
        Script.Connections["Fly"] = RunService.RenderStepped:Connect(function()
            local moveVector = controlModule:GetMoveVector()
            local velocity = -((camera.CFrame.LookVector * moveVector.Z) - (camera.CFrame.RightVector * moveVector.X)) * Options.FlySpeed.Value

            Script.Temp.FlyBody.Velocity = velocity
        end)
    else
        if Script.Connections["Fly"] then
            Script.Connections["Fly"]:Disconnect()
        end
    end
end)

function Script.Functions.SpoofFlingVelocity(call)
    if call then
        local spoofedValue = Vector3.new(0, 0, 0)
        local root = Script.Functions.GetRootPart()
        if not root then
            Script.Functions.Alert("No HumanoidRootPart found!", 3)
            return
        end

        if not Script.Temp.OriginalIndex then
            Script.Temp.OriginalIndex = hookmetamethod(game, "__index", function() end)
            hookmetamethod(game, "__index", Script.Temp.OriginalIndex)
        end
        if not Script.Temp.OriginalNewIndex then
            Script.Temp.OriginalNewIndex = hookmetamethod(game, "__newindex", function() end)
            hookmetamethod(game, "__newindex", Script.Temp.OriginalNewIndex)
        end

        local lastVelocity, lastAssemblyLinearVelocity
        local spoofedProps = {
            Velocity = spoofedValue,
            AssemblyLinearVelocity = spoofedValue
        }

        local index, newindex

        index = hookmetamethod(game, "__index", function(self, key)
            if not checkcaller() and typeof(self) == "Instance" and self == root then
                if spoofedProps[key] ~= nil then
                    return spoofedProps[key]
                end
            end
            return Script.Temp.OriginalIndex(self, key)
        end)

        newindex = hookmetamethod(game, "__newindex", function(self, key, value)
            if not checkcaller() and typeof(self) == "Instance" and self == root then
                if spoofedProps[key] ~= nil then
                    if key == "Velocity" then
                        lastVelocity = value
                        return
                    elseif key == "AssemblyLinearVelocity" then
                        lastAssemblyLinearVelocity = value
                        return
                    end
                end
            end
            return Script.Temp.OriginalNewIndex(self, key, value)
        end)

        Script.Temp.SpoofedIndex = index
        Script.Temp.SpoofedNewIndex = newindex
        Script.Temp.LastVelocity = lastVelocity
        Script.Temp.LastAssemblyLinearVelocity = lastAssemblyLinearVelocity

        Script.Functions.Alert("Fling Velocity Spoofing Enabled!", 3)
    else
        if Script.Temp.SpoofedIndex then
            hookmetamethod(game, "__index", Script.Temp.OriginalIndex)
            Script.Temp.SpoofedIndex = nil
        end
        if Script.Temp.SpoofedNewIndex then
            hookmetamethod(game, "__newindex", Script.Temp.OriginalNewIndex)
            Script.Temp.SpoofedNewIndex = nil
        end
        
        local root = Script.Functions.GetRootPart()
        if root then
            if Script.Temp.LastVelocity then 
                root.Velocity = Script.Temp.LastVelocity 
                Script.Temp.LastVelocity = nil
            end
            if Script.Temp.LastAssemblyLinearVelocity then 
                root.AssemblyLinearVelocity = Script.Temp.LastAssemblyLinearVelocity 
                Script.Temp.LastAssemblyLinearVelocity = nil
            end
        end
        
        Script.Functions.Alert("Fling Velocity Spoofing Disabled!", 3)
    end
end

function Script.Functions.FlingCharacterHook(call)
    if call then
        local function PatchFlingAnticheat()
            local char = lplr.Character
            if not char then return end
            local root = Script.Functions.GetRootPart()
            if not root then return end

            local anticheatStates = { "Stun", "Anchor", "RotateDisabled", "CantRun", "InCutscene", "DisableHeadLookAt" }
            if not Script.Temp.FlingAnticheatChildConn then
                Script.Temp.FlingAnticheatChildConn = char.ChildAdded:Connect(function(child)
                    if table.find(anticheatStates, child.Name) then
                        child:Destroy()
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

        local function onChar(char)
            task.wait(1)
            PatchFlingAnticheat()
        end
        Script.Temp.FlingAnticheatCharConn = lplr.CharacterAdded:Connect(onChar)
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

local SecurityGroupBox = Tabs.Main:AddRightGroupbox("Security", "shield") do
    SecurityGroupBox:AddToggle("PatchFlingAnticheat", {
        Text = "Patch Anticheat",
        Default = false
    }):OnChanged(function(call)
        if call and not hookmetamethod then
            Script.Functions.Alert("[Anticheat Patch]: Unsupported executor :(")
        end
        pcall(Script.Functions.SpoofFlingVelocity, call)
        pcall(Script.Functions.FlingCharacterHook, call)
    end)
    SecurityGroupBox:AddToggle("AntiAfk", {
        Text = "Anti AFK",
        Default = true
    })
    Toggles.AntiAfk:OnChanged(function(call)
        if call then
            local VirtualUser = Services.VirtualUser
            Script.Temp.AntiAfkConnection = lplr.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0, 0), camera.CFrame)
                wait(1)
                VirtualUser:Button2Up(Vector2.new(0, 0), camera.CFrame)
            end)
        else
            if not Script.Temp.AntiAfkConnection then return end
            pcall(function()
                Script.Temp.AntiAfkConnection:Disconnect()
            end)
        end
    end)
    SecurityGroupBox:AddToggle("StaffDetector", {
        Text = "Staff Detector",
        Default = true
    })
    Toggles.StaffDetector:OnChanged(function(call)
        if call then
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
    end)
end

local PerformanceGroupBox = Tabs.Misc:AddRightGroupbox("Performance", "gauge") do
    PerformanceGroupBox:AddToggle("LowGFX", {
        Text = "Low GFX",
        Default = false
    }):OnChanged(function(call)
        if Script.Connections.LowGFX_DescendantConn then
            Script.Connections.LowGFX_DescendantConn:Disconnect()
            Script.Connections.LowGFX_DescendantConn = nil
        end
        if call then 
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
    end)
    PerformanceGroupBox:AddToggle("DisableEffects", {
        Text = "Disable Effects",
        Default = false
    })
    Toggles.DisableEffects:OnChanged(function(call)
        if call then
            local Effects = workspace:WaitForChild("Effects", 15)
            if not Effects then return end
            Effects:ClearAllChildren()
            Script.Temp.DisableEffectsConnection = Effects.ChildAdded:Connect(function(child)
                pcall(function()
                    child:Destroy()
                    workspace.Effects:ClearAllChildren()
                end)
            end)
        else
            if Script.Temp.DisableEffectsConnection then
                pcall(function()
                    Script.Temp.DisableEffectsConnection:Disconnect()
                end)
                Script.Temp.DisableEffectsConnection = nil
            end
        end
    end)
    PerformanceGroupBox:AddButton("Clear Effects Cache", function()
        if workspace:FindFirstChild("Effects") then
            workspace.Effects:ClearAllChildren()
        end
    end)
end

local lastCleanupFunction = function() end

function Script.Functions.HandleAutowin()
    if lastCleanupFunction then
        pcall(lastCleanupFunction)
    end

    pcall(function()
        Script.GameState = workspace.Values.CurrentGame.Value
    end)

    if States[Script.GameState] then
        Script.Functions.Alert("[Autowin]: Running on "..tostring(Script.GameState))
        Script.Functions.EffectsNotification("[Autowin]: Running on "..tostring(Script.GameState), 10)
        lastCleanupFunction = States[Script.GameState]()
    else
        Script.Functions.EffectsNotification("[Autowin]: Waiting for the next game...", 10)
        Script.Functions.Alert("[Autowin]: Waiting for the next game...")
    end
end

States = {
    RedLightGreenLight = function()
        local call = true
        if Script.Tasks.AutoWinRLGLTask then
            task.cancel(Script.Tasks.AutoWinRLGLTask)
            Script.Tasks.AutoWinRLGLTask = nil
        end
        Script.Tasks.AutoWinRLGLTask = task.spawn(function()
            repeat
                Script.Functions.WinRLGL()
                task.wait(5)
            until not call or not Toggles.InkGameAutowin.Value or Script.GameState ~= "RedLightGreenLight"
        end)
        if not Toggles.AntiFlingToggle.Value then
            Toggles.AntiFlingToggle:SetValue(true)
        end
        return function()
            call = false
            if Toggles.AntiFlingToggle.Value then
                Toggles.AntiFlingToggle:SetValue(false)
            end
        end
    end,
    Mingle = function()
        if not Toggles.AutoMingleQTE.Value then
            Toggles.AutoMingleQTE:SetValue(true)
        end
        return function()
            if Toggles.AutoMingleQTE.Value then
                Toggles.AutoMingleQTE:SetValue(false)
            end
        end
    end,
    TugOfWar = function()
        if not Toggles.AutoPull.Value then
            Toggles.AutoPull:SetValue(true)
        end

        return function()
            if Toggles.AutoPull.Value then
                Toggles.AutoPull:SetValue(false)
            end
        end
    end,
    GlassBridge = function()
        task.spawn(function()
            Script.Functions.RevealGlassBridge()
        end)
        local call = true
        if Script.Tasks.AutoWinGlassBridgeTask then
            task.cancel(Script.Tasks.AutoWinGlassBridgeTask)
            Script.Tasks.AutoWinGlassBridgeTask = nil
        end
        Script.Tasks.AutoWinGlassBridgeTask = task.spawn(function()
            task.wait(15)
            repeat
                Script.Functions.WinGlassBridge()
                task.wait(3)
            until not call or not Toggles.InkGameAutowin.Value or Library.Unloaded
        end)
        return function()
            call = false
        end
    end,
    HideAndSeek = function()
        if lplr:FindFirstChild("CurrentKeys") then
            Script.Functions.ToggleTPTSP()
        else
            Script.Functions.Alert("[Autowin]: Hide and Seek support for Seekers soon...")
        end
    end,
    LightsOut = Script.Functions.ToggleTPTSP,
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
    end
}

pcall(function()
    Script.GameState = workspace.Values.CurrentGame.Value
end)


Library:GiveSignal(workspace:WaitForChild("Values"):WaitForChild("CurrentGame"):GetPropertyChangedSignal("Value"):Connect(function()
    Script.GameState = workspace.Values.CurrentGame.Value
    if Script.GameState then
        Script.GameState = tostring(Script.GameState)
    end

    if Script.GameState and Toggles.InkGameAutowin.Value then
        Script.Functions.HandleAutowin()
    end
    
    -- OnGameStateChange
    if Script.GameState == "HideAndSeek" then
        for _, meta in pairs(HIDE_AND_SEEK_ESP_META) do
            if Toggles[meta.metaName].Value then
                Script.Functions.HideAndSeekFuncCaller(meta)
            end
        end
        for _, esp in pairs(Script.ESPTable["Player"]) do
            Script.Functions.ApplyHiderSeekerEsp(esp)
        end
    end
    if Script.GameState == "TugOfWar" then
        if Toggles.AutoPull.Value then
            Script.Functions.AutoPull(true)
            Library:GiveSignal(Script.Functions.OnceOnGameChanged(function()
                Script.Functions.AutoPull(false)
            end))
        end
    end
    if Script.GameState == "Mingle" then
        if Toggles.AutoMingleQTE.Value then
            Script.Functions.AutoMingleQTE(true)
        end
    end
    if Script.GameState == "GlassBridge" then
        if Toggles.RevealGlassBridge.Value then
            local bridge = workspace:WaitForChild("GlassBridge", 10)
            if not bridge then
                Script.Functions.Alert("[Glass Bridge]: glass bridge object not found! please retoggle the toggle")
            else
                Script.Functions.RevealGlassBridge()
            end
        end
    end
end))

function Script.Functions.AutoPull(call)
    if Script.Temp.AutoPullTask then
        task.cancel(Script.Temp.AutoPullTask)
        Script.Temp.AutoPullTask = nil
    end
    if not call or Script.GameState ~= "TugOfWar" then return end
    Script.Temp.AutoPullTask = task.spawn(function()
        repeat
            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TemporaryReachedBindable"):FireServer(
                unpack({{PerfectQTE = true}})
            )
            task.wait(Options.AutoPullDelay.Value)
        until not Toggles.AutoPull.Value or Library.Unloaded
        task.cancel(Script.Temp.AutoPullTask)
        Script.Temp.AutoPullTask = nil
    end)
end

Toggles.AutoPull:OnChanged(Script.Functions.AutoPull)

local Useful = Tabs.Other:AddRightGroupbox("Useful Stuff", "star") do
    Useful:AddToggle("AutoSkipDialog", {
        Text = "Auto Skip Dialogue",
        Default = false
    }):OnChanged(function(call)
        if Script.Temp.AutoSkipDialogLoop then
            task.cancel(Script.Temp.AutoSkipDialogLoop)
            Script.Temp.AutoSkipDialogLoop = nil
        end
        if call then
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
    end)

    Useful:AddToggle("FullbrightToggle", {
        Text = "Fullbright",
        Default = false
    }):OnChanged(function(enabled)
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
    end)
end

local AntiDeathGroup = Tabs.Other:AddRightGroupbox("Anti Death", "skull") do
    AntiDeathGroup:AddToggle("AntiDeathToggle", {
        Text = "Anti Death",
        Default = false
    })

    AntiDeathGroup:AddSlider("AntiDeathHealthThreshold", {
        Text = "Health Threshold",
        Default = 30,
        Min = 10,
        Max = 90,
        Rounding = 1
    })
    
    Toggles.AntiDeathToggle:OnChanged(function(call)
        if call then
            Script.Temp.AntiDeathTask = task.spawn(function()
                repeat
                    task.wait()
                    if lplr.Character then
                        local hum = lplr.Character:FindFirstChildOfClass("Humanoid")
                        if not hum then return end
                        if hum.Health <= Options.AntiDeathHealthThreshold.Value then
                            Script.Functions.ToggleTPTSP()
                        else
                            if Toggles.TeleportToSafePlace.Value then
                                Toggles.TeleportToSafePlace:SetValue(false)
                            end
                        end
                    end
                until not Toggles.AntiDeathToggle.Value or Library.Unloaded
            end)    
        else
            if Script.Temp.AntiDeathTask then
                task.cancel(Script.Temp.AntiDeathTask)
                Script.Temp.AntiDeathTask = nil
            end
        end
    end)
end

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "menu") do
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
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
        Default = "RightShift",
        NoUI = false,
        Text = "Menu keybind"
    })
    MenuGroup:AddButton("Unload Script", function() Library:Unload() end)
end
Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({  })

ThemeManager:SetFolder("voidware_linoria")
SaveManager:SetFolder("voidware_linoria/ink_game")

SaveManager:BuildConfigSection(Tabs["UI Settings"])

ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()

local LibraryChangeGroup = Tabs["UI Settings"]:AddRightGroupbox("Library", "info")
LibraryChangeGroup:AddDropdown("LibraryChoice", {
    Text = "Library Choice",
    Values = allowedlibs,
    Default = targetlib
})
Options.LibraryChoice:OnChanged(function(val)
    if val == targetlib then return end
    writefile("Voidware_InkGame_Library_Choice.txt", val)
    Library:Unload()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NSeydulla/VW-Add/main/inkgame.lua", true))()
end)

LibraryChangeGroup:AddButton("Save Settings", function()
    local suc, err = pcall(function()
        local configName = Options.SaveManager_ConfigList and Options.SaveManager_ConfigList.Values and #Options.SaveManager_ConfigList.Values > 0 and Options.SaveManager_ConfigList.Values[1]
        if not configName then return end
        Options.SaveManager_ConfigList:SetValue(configName)
        SaveManager:Save(configName)
    end)
    if suc then
        Script.Functions.Alert("[Save Settings]: Successfully saved your settings ✅")
    else
        Script.Functions.Alert("[Save Settings]: Error saving your profiles :( ❌")
        for i = 1, 10 do
            warn("[SAVING | ERROR]: "..tostring(err))
        end
    end
end)

local approved = false
LibraryChangeGroup:AddButton("Reset Settings", function()
    if approved then
        pcall(function()
            writefile("voidware_linoria/ink_game/settings/default.json", "[]")
        end)
        pcall(function()
            Library:Unload()
        end)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NSeydulla/VW-Add/main/inkgame.lua", true))()
    else
        Script.Functions.Alert("[Save Settings]: Press the button again to reset your settings. This cannot be undone!", 5)
        approved = true
    end
end)

task.spawn(function() pcall(Script.Functions.OnLoad) end)