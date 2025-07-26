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
