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
