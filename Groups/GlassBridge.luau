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
