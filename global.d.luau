--!strict
export type ESPArgs = {
    Color: Color3?,
    Object: Instance,
    Offset: Vector3?,
    Text: string?,
    TextParent: Instance?,
    Type: string?
}

export type ESP = {
    Color: Color3,
    Object: Instance,
    Offset: Vector3,
    Text: string,
    TextParent: Instance,
    Type: string,
    Highlights: {},
    Connections: {[any]: RBXScriptConnection},
    SetColor: (Color3) -> (),
    Destroy: () -> (),
    GiveSignal: (RBXScriptConnection) -> ()
}

export type FunctionMap = {
    Alert: (msg: string, time: number?) -> (),
    OnGameStateChange: () -> (),
    OnLoad: () -> (),
    OnUnload: () -> (),
    OnceOnGameChanged: (func: () -> ()) -> RBXScriptConnection,
    SafeRequire: (module: Instance) -> any,
    HandleAutowin: () -> (),
    Alert: (message: string, time: number?) -> (),
    CheckPlayersVisibility: () -> (),
    IsGuard: (model: Model) -> boolean,
    ApplyHiderSeekerESP: (esp: ESP) -> (),
    GetRootPart: () -> Part?,
    SafeTeleport: (x: number, y: number, z: number) -> (),
    SafeTeleportToCFrame: (cframe: CFrame) -> (),
    TeleportToSafe: () -> (),
    ESP: (args: ESPArgs) -> ESP?,
}

type HookMethod = (ScriptName: string, MethodName: string, Args: AnyTable) -> AnyTable?

export type ScriptType = {
    repo: string,
    GameState: string?,
    Connections: {
        OnGameStateChange: RBXScriptConnection?,
        PlayerAdded: RBXScriptConnection?,
        PlayerRemoved: RBXScriptConnection?,
        PlayerCharAdded: { [string]: RBXScriptConnection? },
        GuardCharAdded: { RBXScriptConnection? },
        cameraOverrideConnection: RBXScriptConnection?,
        DalgonaImuneConnDestroyer: RBXScriptConnection?,
        FlingAuraDeathConn: RBXScriptConnection?,
        KeyESPDestroyer: RBXScriptConnection?,
        KeyESPDescendant: RBXScriptConnection?,
        DoorESPDestroyer: RBXScriptConnection?,
        DoorESPDescendant: RBXScriptConnection?,
        EscapeDoorESPDestroyer: RBXScriptConnection?,
        EscapeDoorESPDescendant: RBXScriptConnection?,
        NoInteractDelayConnection: RBXScriptConnection?,
        PromptReachConnection: RBXScriptConnection?,
        JumpRope_AutoSurviveCon: RBXScriptConnection?,
        JumpRope_AutoPerfectCon: RBXScriptConnection?,
        GuardAddedConnection: RBXScriptConnection?,
        AutoMingleConnDestroyer: RBXScriptConnection?,
        RagdollBlockConn: RBXScriptConnection?,
        LowGFX_DescendantConn: RBXScriptConnection?,
        InfiniteJumpConnect: RBXScriptConnection?,
        GuardHitboxConnection: RBXScriptConnection?,
        RLGLInjuredTableRefresh: RBXScriptConnection?,
        RLGLConnDestroyer: RBXScriptConnection?,
        RLGL_Connection: RBXScriptConnection?,
        AntiAfkConnection: RBXScriptConnection?,
        TugOfWarConnDestroyer: RBXScriptConnection?,
    },
    HookMethods: {
        ImmuneDalgona: HookMethod?,
        RLGLGodmode: HookMethod?,
        Anticheat: HookMethod?,
    },
    Tasks: {
        FOVChangeTask: thread?,
        FlingAuraTask: thread?,
        AntiFlingLoop: thread?,
        AutoMingleQTEThread: thread?,
        SpeedToggleTask: thread?,
        NoclipTask: thread?,
        RLGLDropdownRefresh: thread?,
        AutoWinRLGL: thread?,
        AutoWinDalgona: thread?,
        AutoWinDalgona2: thread?,
        AutoPullTask: thread?
    },
	Temp: {[string]: any},
    AutoWin: {[string?]: (()->((()->())?))?},
    OnGame: {[string?]: (()->())?},
    Camera: Camera,
    Functions: FunctionMap,
    ESPTable: {
        Player: { ESP? },
        Guard: { ESP? },
        Door: { ESP? },
        None: { ESP? },
        Key: { ESP? },
        ["Escape Door"]: { ESP? },
    },
    SaveManager: any,
    SaveManager: any
}

declare getgenv: () -> {
    shared: {
        VoidwareLoading: boolean?,
        Voidware_InkGame_Library: Obsidian?
    }
}

declare workspace: Workspace & {
    Values: {
        CurrentGame: {
            Value: string?
        }
    },
}