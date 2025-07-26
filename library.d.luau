--!strict
export type ObsidianOption = {
    Value: string | number | Color3,
    SetValues: (self: ObsidianOption, Values: { string }) -> (),
    SetValue: (self: ObsidianOption, Value: string?) -> (),
}

export type ObsidianToggle = {
    AddKeyPicker: (
        self: ObsidianToggle,
        Idx: string,
        Info: {
            Mode: string,
            Default: string,
            Text: string,
            SyncToggleState: boolean,
        }
    ) -> (),
    AddColorPicker: (
        self: ObsidianToggle,
        Idx: string,
        Info: {
            Default: Color3,
            Callback: ((Value: Color3) -> ())?,
        }
    ) -> (),
    Value: boolean,
    SetValue: (self: ObsidianToggle, Value: boolean) -> (),
    Callback: (Value: boolean) -> (),
}

export type ObsidianLabel = {
    AddKeyPicker: (
        self: ObsidianLabel,
        Idx: string,
        Info: {
            Default: string,
            Text: string,
            NoUI: boolean?,
        }
    ) -> ObsidianOption,
    AddColorPicker: (
        self: ObsidianLabel,
        Idx: string,
        Info: {
            Default: Color3,
            Callback: ((Value: Color3) -> ())?,
        }
    ) -> ObsidianOption,
}

export type ObsidianToggleInfo = {
    Text: string,
    Default: boolean,
    Callback: ((Value: boolean) -> ())?,
    Disabled: boolean?,
}

export type ObsidianSliderInfo = {
    Text: string,
    Default: number,
    Min: number,
    Max: number,
    Rounding: number,
    Disabled: boolean?,
}

export type ObsidianDropdownInfo = {
    Text: string,
    Values: { string },
    AllowNull: boolean,
}

export type ObsidianGroupBox = {
    AddToggle: (self: ObsidianGroupBox, Name: string, Info: ObsidianToggleInfo) -> ObsidianToggle,
    AddButton: (self: ObsidianGroupBox, Name: string, Callback: () -> ()) -> (),
    AddSlider: (self: ObsidianGroupBox, Name: string, Info: ObsidianSliderInfo) -> ObsidianOption,
    AddDropdown: (self: ObsidianGroupBox, Name: string, Info: ObsidianDropdownInfo) -> ObsidianOption,
    AddLabel: (self: ObsidianGroupBox, Name: string) -> ObsidianLabel,
}

export type ObsidianTab = {
    AddLeftGroupbox: (self: ObsidianTab, Name: string, IconName: string?) -> ObsidianGroupBox,
    AddRightGroupbox: (self: ObsidianTab, Name: string, IconName: string?) -> ObsidianGroupBox,
}

export type ObsidianWindow = {
    AddTab: (self: ObsidianWindow, Name: string, Icon: string?, Description: string?) -> ObsidianTab,
}

export type Obsidian = {
    Unload: (self: Obsidian) -> (),
    OnUnload: (self: Obsidian, () -> ()) -> (),
    CreateWindow: (
        self: Obsidian,
        {
            Title: string,
            Footer: string,
            Center: boolean,
            AutoShow: boolean,
            Resizable: boolean,
            ShowCustomCursor: boolean,
            TabPadding: number,
            MenuFadeTime: number,
        }
    ) -> ObsidianWindow,
    Toggles: { [string]: ObsidianToggle },
    Options: { [string]: ObsidianOption },
    Unloaded: boolean,
    GiveSignal: (self: Obsidian, Signal: RBXScriptConnection) -> (),
    _signals: { any: RBXScriptConnection },
    ToggleKeybind: any,
    KeybindFrame: {
        Visible: boolean,
    },
    ShowCustomCursor: boolean,
    Notify: (self: Obsidian, message: string, time_obj: number) -> (),
}
