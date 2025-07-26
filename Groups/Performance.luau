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
