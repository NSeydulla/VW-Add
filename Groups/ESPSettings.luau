return function(TabGroup, Script, Library)
    local function ChangeTransparency(Value)
        local v = 1
        if Value then
            v = Library.Options.ESPTransparency.Value
        end
        task.delay(0.1, function()
            for _, ESPs in pairs(Script.ESPTable) do
                for _, esp in pairs(ESPs) do
                    for _, highlight in pairs(esp.Highlights) do
                        highlight.Transparency = v
                    end
                end
            end
        end)
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
end
