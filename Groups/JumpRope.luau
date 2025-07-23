return function(TabGroup, Script, Library)
    local Players = Script.Services.Players
    local lplr = Players.LocalPlayer
    local RunService = Script.Services.RunService

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
                if
                    char
                    and workspace:FindFirstChild("JumpRope")
                    and workspace.JumpRope:FindFirstChild("FallColllisionYClient")
                then
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
                Script.Connections.JumpRope_AutoPerfectCon = game:GetService("RunService").RenderStepped
                    :Connect(function()
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
end
