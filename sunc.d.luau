--!strict
export type AnyFunction = (...any) -> (...any)
export type AnyTable = { [any]: any }
type userdata = typeof(newproxy())

declare checkcaller: () -> boolean
declare clonefunction: <A..., R...>(functionToClone: (A...) -> R...) -> ((A...) -> R...)
declare getfunctionhash: (functionToHash: AnyFunction) -> string
declare hookfunction: <A1..., R1..., A2..., R2...>(functionToHook: (A1...) -> R1..., hook: (A2...) -> R2...) -> ((A1...) -> R1...)
declare hookmetamethod: (object: { any } | userdata, metamethodName: string, hook: AnyFunction) -> (AnyFunction)
declare iscclosure: (func: AnyFunction) -> boolean
declare isexecutorclosure: (func: AnyFunction) -> boolean
declare islclosure: (func: AnyFunction) -> boolean
declare newcclosure: <A..., R...>(functionToWrap: (A...) -> R...) -> ((A...) -> R...)
declare restorefunction: (functionToRestore: AnyFunction) -> ()
declare crypt: {
    base64decode: (data: string) -> string,
    base64encode: (data: string) -> string
}
declare debug: {
    getconstant: (func: AnyFunction | number, index: number) -> number | string | boolean | nil,
    getconstants: (func: AnyFunction | number) -> { number | string | boolean | nil },
    getproto: (func: AnyFunction | number, index: number, activated: boolean?) -> AnyFunction | { AnyFunction },
    getprotos: (func: AnyFunction | number) -> { AnyFunction },
    getstack: (level: number, index: number?) -> any | { any },
    getupvalue: (func: AnyFunction | number, index: number) -> any,
    getupvalues: (func: AnyFunction | number) -> { any },
    setconstant: (func: AnyFunction | number, index: number, value: number | string | boolean | nil) -> (),
    setstack: (level: number, index: number, value: any) -> (),
    setupvalue: (func: AnyFunction | number, index: number, value: any) -> (),
}
declare cleardrawcache: () -> ()
type Drawing = {
    Destroy: () -> ()
}
declare Drawing: {
    new: (type: string) -> Drawing
}
declare getrenderproperty: (drawing: Drawing, property: string) -> any
declare isrenderobj: (object: any) -> boolean
declare setrenderproperty: (drawing: Drawing, property: string, value: any) -> ()
declare getgc:
    ((includeTables: true) -> { { AnyTable } | AnyFunction | userdata }) &
    ((includeTables: false?) -> { AnyFunction })
declare getgenv: () -> { any }
declare getreg: () -> AnyTable
declare getrenv: () -> { any }
type TableFilterOptions = {
    Keys: AnyTable?,
    Values: AnyTable?,
    KeyValuePairs: AnyTable?,
    Metatable: AnyTable?,
}
type FunctionFilterOptions = {
    Name: string?,
    IgnoreExecutor: boolean?,
    Hash: string?,
    Constants: { string }?,
    Upvalues: { any }?
}
declare filtergc: 
    (( filterType: "function", filterOptions: FunctionFilterOptions, returnOne: true) -> AnyFunction? ) &
    ((( filterType: "function", filterOptions: FunctionFilterOptions, returnOne: false?) -> ( AnyFunction | { AnyFunction } ) )) &
    (( filterType: "table", filterOptions: TableFilterOptions, returnOne: true) -> { AnyTable? } ) &
    (( filterType: "table", filterOptions: TableFilterOptions, returnOne: false? ) -> { AnyTable })
declare appendfile: (path: string, contents: string) -> ()
declare delfile: (path: string) -> ()
declare delfolder: (path: string) -> ()
declare getcustomasset: (path: string) -> string
declare isfile: (path: string) -> boolean
declare isfolder: (path: string) -> boolean
declare listfiles: (path: string) -> { string }
declare loadfile: <A...>(path: string) -> ((A...) -> any | nil, string?)
declare makefolder: (path: string) -> ()
declare readfile: (path: string) -> string
declare writefile: (path: string, data: string) -> ()
declare cloneref: <T>(object: T & Instance) -> T
declare compareinstances: (object1: Instance, object2: Instance) -> (boolean)
declare fireclickdetector: (detector: ClickDetector, distance: number?, event: string?) -> ()
declare fireproximityprompt: (prompt: ProximityPrompt) -> ()
declare firetouchinterest: (part1: BasePart, part2: BasePart, toggle: boolean | number) -> ()
declare getcallbackvalue: (object: Instance, property: string) -> (any | nil)
declare gethui: () -> (BasePlayerGui | Folder)
declare getinstances: () -> { Instance }
declare getnilinstances: () -> { Instance }
declare getrawmetatable: (object: { any }) -> AnyTable | nil
declare isreadonly: (table: { any }) -> (boolean)
declare setrawmetatable: <T>(object: T & ({ any } | userdata), metatable: { any }) -> T
declare setreadonly: (table: { any }, state: boolean) -> ()
declare identifyexecutor: () -> (string, string)
type RequestOptions = {
    Url: string,
    Method: "GET" | "POST" | "PUT" | "PATCH" | "DELETE",
    Body: string?,
    Headers: { [string]: string }?,
    Cookies: { [string]: string }?
}

type Response = {
    Body: string,
    StatusCode: number,
    StatusMessage: string,
    Success: boolean,
    Headers: { [string]: string }
}

declare request: (options: RequestOptions) -> Response
declare gethiddenproperty: (instance: Instance, property_name: string) -> (any, boolean)
declare getthreadidentity: () -> number
declare sethiddenproperty: (instance: Instance, property_name: string, property_value: any) -> boolean
declare setscriptable: (instance: Instance, property_name: string, state: boolean) -> boolean | nil
declare setthreadidentity: (id: number) -> ()

declare getcallingscript: () -> BaseScript | ModuleScript | nil
declare getloadedmodules: () -> { ModuleScript }
declare getrunningscripts: () -> { BaseScript | ModuleScript }
declare getscriptbytecode: (script: BaseScript | ModuleScript) -> string | nil
declare getscriptclosure: (script: BaseScript | ModuleScript) -> (AnyFunction | nil)
declare getscripthash: (script: BaseScript | ModuleScript) -> string | nil
declare getscripts: () -> { BaseScript | ModuleScript }
declare getsenv: (script: BaseScript | ModuleScript) -> AnyTable | nil
declare firesignal: (signal: RBXScriptSignal, ...any?) -> ()
type Connection = {
    Enabled: boolean,
    ForeignState: boolean,
    LuaConnection: boolean,
    Function: AnyFunction?,
    Thread: thread?,
}
declare getconnections: (signal: RBXScriptSignal) -> {Connection}
declare replicatesignal: (signal: RBXScriptSignal, ...any?) -> ()
type WebSocket = {
    OnMessage: RBXScriptSignal,
    OnClose: RBXScriptSignal,
    Send: (self: WebSocket, message: string) -> (),
    Close: (self: WebSocket) -> (),
}
declare WebSocket: {
    connect: (url: string) -> WebSocket
}

declare getnamecallmethod: () -> string
declare game: DataModel & {
    HttpGet: (self: DataModel, url: string, synchronous: boolean?) -> string,
    HttpPost: (self: DataModel, url: string, body: string, contentType: string) -> string
}