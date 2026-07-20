script_key="KEY-W6PWJ-V2Z6G-ZFSDE-GGZM5-D2CS4";
local Workspace = game:GetService('Workspace')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')

local type_custom = typeof
if not LPH_OBFUSCATED then
	LPH_JIT = function(...)
		return ...;
	end;
	LPH_JIT_MAX = function(...)
		return ...;
	end;
	LPH_NO_VIRTUALIZE = function(...)
		return ...;
	end;
	LPH_NO_UPVALUES = function(f)
		return (function(...)
			return f(...);
		end);
	end;
	LPH_ENCSTR = function(...)
		return ...;
	end;
	LPH_ENCNUM = function(...)
		return ...;
	end;
	LPH_ENCFUNC = function(func, key1, key2)
		if key1 ~= key2 then return print("LPH_ENCFUNC mismatch") end
		return func
	end
	LPH_CRASH = function()
		return print(debug.traceback());
	end;
    SWG_DiscordUser = "swim"
    SWG_DiscordID = 1337
    SWG_Private = true
    SWG_Dev = false
    SWG_Version = "dev"
    SWG_Title = 'GHOST_HOOK %s - %s'
    SWG_ShortName = 'dev'
    SWG_FullName = 'GHOST_HOOK dev build'
    SWG_FFA = false
end;
local workspace = cloneref(Workspace)
local Players = cloneref(Players)
local RunService = cloneref(RunService)
local Lighting = cloneref(game:GetService("Lighting"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local HttpService = cloneref(game:GetService("HttpService"))
local GuiInset = cloneref(game:GetService("GuiService")):GetGuiInset()
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local cheat

local _CFramenew = CFrame.new
local _Vector2new = Vector2.new
local _Vector3new = Vector3.new
local _IsDescendantOf = game.IsDescendantOf
local _FindFirstChild = game.FindFirstChild
local _FindFirstChildOfClass = game.FindFirstChildOfClass
local _Raycast = workspace.Raycast
local _IsKeyDown = UserInputService.IsKeyDown
local _WorldToViewportPoint = Camera.WorldToViewportPoint
local _Vector3zeromin = Vector3.zero.Min
local _Vector2zeromin = Vector2.zero.Min
local _Vector3zeromax = Vector3.zero.Max
local _Vector2zeromax = Vector2.zero.Max
local _IsA = game.IsA
local tablecreate = table.create
local mathfloor = math.floor
local mathround = math.round
local tostring = tostring
local unpack = unpack
local getupvalues = debug.getupvalues
local getupvalue = debug.getupvalue
local setupvalue = debug.setupvalue
local getconstants = debug.getconstants
local getconstant = debug.getconstant
local setconstant = debug.setconstant
local getstack = debug.getstack
local setstack = debug.setstack
local getinfo = debug.getinfo
local rawget = rawget

local function ghostKeyNotify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = tostring(title or "GHOST_HOOK Key"),
            Text = tostring(text or ""),
            Duration = tonumber(duration) or 3,
        })
    end)
end

local function ghostKeySave(value, path)
    if not writefile or type(path) ~= "string" then return false end
    local ok = pcall(function()
        writefile(path, tostring(value))
    end)
    return ok
end

local function ghostKeyLoad(path)
    if not isfile or not readfile or type(path) ~= "string" or not isfile(path) then
        return nil
    end

    local ok, value = pcall(readfile, path)
    if ok then
        return value
    end
    return nil
end

local KEY_SERVER_VALIDATE_URL = "https://web-eight-mu-4k76n8qoag.vercel.app/api/validate-key"

local function getGhostProvidedKey()
    local env = getgenv and getgenv() or nil
    return (env and (env.Key or env.script_key))
        or rawget(_G, "script_key")
        or (shared and shared.script_key)
        or rawget(_G, "Key")
        or script_key
end

local function getGhostDeviceId()
    if syn and syn.crypt and syn.crypt.hwid then
        local ok, value = pcall(syn.crypt.hwid)
        if ok and value then
            return tostring(value)
        end
    end

    local clientId = nil
    pcall(function()
        clientId = game:GetService("RbxAnalyticsService"):GetClientId()
    end)

    local executor = "executor"
    pcall(function()
        if identifyexecutor then
            executor = tostring(identifyexecutor())
        elseif getexecutorname then
            executor = tostring(getexecutorname())
        end
    end)

    if clientId and tostring(clientId) ~= "" then
        return executor .. "-" .. tostring(clientId)
    end

    local savedId = ghostKeyLoad("GhostKeyDevice")
    if savedId and tostring(savedId) ~= "" then
        return tostring(savedId)
    end

    savedId = executor .. "-" .. tostring(math.random(100000, 999999)) .. "-" .. tostring(os.time())
    ghostKeySave(savedId, "GhostKeyDevice")
    return savedId
end

local function ghostHttpRequest(requestData)
    local requester = (syn and syn.request) or http_request or request or (http and http.request)
    if requester then
        return requester(requestData)
    end

    return HttpService:RequestAsync(requestData)
end

local function validateGhostKey()
    local providedKey = getGhostProvidedKey()
    if not providedKey or tostring(providedKey) == "" then
        return false, "Missing key"
    end

    providedKey = tostring(providedKey)
    local env = getgenv and getgenv() or nil
    if env then
        env.Key = providedKey
    end

    local deviceId = getGhostDeviceId()
    local body = HttpService:JSONEncode({
        key = providedKey,
        deviceId = deviceId,
        hwid = deviceId,
        userId = LocalPlayer and tostring(LocalPlayer.UserId) or nil,
    })

    for attempt = 1, 3 do
        local ok, response = pcall(ghostHttpRequest, {
            Url = KEY_SERVER_VALIDATE_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
            },
            Body = body,
        })

        if ok and response then
            local responseBody = response.Body or response.body or ""
            local decodedOk, decoded = pcall(function()
                return HttpService:JSONDecode(responseBody)
            end)

            if decodedOk and decoded then
                if decoded.success == true then
                    return true, decoded.message or "Key validated", decoded
                end

                return false, decoded.message or decoded.error or "Key validation failed"
            end

            return false, "Invalid response from key server"
        end

        if attempt < 3 then
            task.wait(1)
        end
    end

    return false, "Could not reach key server"
end

local ghostKeyOk, ghostKeyMessage, ghostKeyInfo = validateGhostKey()
if not ghostKeyOk then
    ghostKeyNotify("GHOST_HOOK Key", tostring(ghostKeyMessage), 5)
    return
end

ghostKeyNotify("GHOST_HOOK Key", tostring(ghostKeyMessage), 2.5)

local function ghostParseIsoUnix(value)
    if type(value) ~= "string" or value == "" then
        return nil
    end

    if DateTime and DateTime.fromIsoDate then
        local ok, parsed = pcall(DateTime.fromIsoDate, value)
        if ok and parsed then
            return parsed.UnixTimestamp
        end
    end

    local year, month, day, hour, minute, second = value:match("^(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)")
    if not year then
        return nil
    end

    return os.time({
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day),
        hour = tonumber(hour),
        min = tonumber(minute),
        sec = tonumber(second),
    })
end

local ghostKeyExpiresAtUnix = ghostKeyInfo and ghostParseIsoUnix(ghostKeyInfo.expiresAt or ghostKeyInfo.expires_at) or nil
local ghostKeyServerOffset = 0
do
    local serverUnix = ghostKeyInfo and ghostParseIsoUnix(ghostKeyInfo.serverTime or ghostKeyInfo.server_time) or nil
    if serverUnix then
        ghostKeyServerOffset = serverUnix - os.time()
    end
end

local function ghostFormatKeyTimeLeft()
    if not ghostKeyExpiresAtUnix then
        return ""
    end

    local secondsLeft = ghostKeyExpiresAtUnix - (os.time() + ghostKeyServerOffset)
    if secondsLeft <= 0 then
        return "Expired"
    end

    local minutesLeft = math.ceil(secondsLeft / 60)
    local hoursLeft = math.ceil(secondsLeft / 3600)
    local daysLeft = math.ceil(secondsLeft / 86400)

    if minutesLeft < 60 then
        return "Active " .. tostring(minutesLeft) .. "m"
    end
    if hoursLeft < 48 then
        return "Active " .. tostring(hoursLeft) .. "h"
    end
    return "Active " .. tostring(daysLeft) .. "d"
end

local function ghostGetKeyTimerText()
    local status = ghostFormatKeyTimeLeft()
    if status == "" or status == "Active" then
        return ""
    end
    return status:gsub("^Active%s*", "")
end

local function ghostFindMenuBase()
    if cheat and cheat.instances then
        for instance in pairs(cheat.instances) do
            if typeof(instance) == "Instance" and instance.Parent then
                if instance.Name == "Base" and instance:IsA("GuiObject") then
                    return instance
                end

                local base = instance:FindFirstChild("Base", true)
                if base and base:IsA("GuiObject") then
                    return base
                end
            end
        end
    end

    local roots = {}
    pcall(function()
        table.insert(roots, game:GetService("CoreGui"))
    end)
    pcall(function()
        if LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui") then
            table.insert(roots, LocalPlayer:FindFirstChildOfClass("PlayerGui"))
        end
    end)

    for _, root in ipairs(roots) do
        local base = root and root:FindFirstChild("Base", true)
        if base and base:IsA("GuiObject") then
            return base
        end
    end
end

local function ghostCreateKeyStatusOverlay(timerText, expired)
    timerText = tostring(timerText or "")

    local base = ghostFindMenuBase()
    if not base then
        return false
    end

    local existing = base:FindFirstChild("GhostHookKeyStatus")
    if existing then
        existing:Destroy()
    end

    local frame = cheat.utility.track_instance(Instance.new("Frame"))
    frame.Name = "GhostHookKeyStatus"
    frame.AnchorPoint = Vector2.new(1, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(1, -10, 0, 23)
    frame.Size = UDim2.fromOffset(132, 20)
    frame.ZIndex = 1000
    frame.Parent = base

    local dot = Instance.new("Frame")
    dot.Name = "Dot"
    dot.AnchorPoint = Vector2.new(0, 0.5)
    dot.BackgroundColor3 = expired and Color3.fromRGB(255, 65, 65) or Color3.fromRGB(32, 255, 65)
    dot.BorderSizePixel = 0
    dot.Position = UDim2.new(0, 0, 0.5, 0)
    dot.Size = UDim2.fromOffset(8, 8)
    dot.ZIndex = 1001
    dot.Parent = frame

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot

    local active = Instance.new("TextLabel")
    active.Name = "ActiveText"
    active.BackgroundTransparency = 1
    active.BorderSizePixel = 0
    active.Font = Enum.Font.GothamMedium
    active.Position = UDim2.new(0, 14, 0, 0)
    active.Size = UDim2.fromOffset(44, 20)
    active.Text = expired and "Expired" or "Active"
    active.TextColor3 = Color3.fromRGB(255, 255, 255)
    active.TextSize = 14
    active.TextXAlignment = Enum.TextXAlignment.Left
    active.TextYAlignment = Enum.TextYAlignment.Center
    active.ZIndex = 1001
    active.Parent = frame

    local timer = Instance.new("TextLabel")
    timer.Name = "TimerText"
    timer.BackgroundTransparency = 1
    timer.BorderSizePixel = 0
    timer.Font = Enum.Font.GothamMedium
    timer.Position = UDim2.new(0, expired and 62 or 58, 0, 0)
    timer.Size = UDim2.new(1, expired and -62 or -58, 1, 0)
    timer.Text = expired and "" or timerText
    timer.TextColor3 = Color3.fromRGB(255, 255, 255)
    timer.TextSize = 14
    timer.TextXAlignment = Enum.TextXAlignment.Left
    timer.TextYAlignment = Enum.TextYAlignment.Center
    timer.ZIndex = 1001
    timer.Parent = frame

    return true
end

local function getfile(name)
    local repo = "https://raw.githubusercontent.com/kristerstomasuns-hub/essentials/main/"
    local success, content = pcall(request, {Url = repo..name, Method = "GET"})
    if success then
        if content.StatusCode == 200 then
            return content.Body
        else
            return print("getfile returned error code: " .. tostring(content.StatusCode))
        end
    else
        return print("getfile pcall error: " .. tostring(content))
    end
end
local function isGhostHookfile(file)
    return isfile("GHOST_HOOK/new/files/"..file)
end
local function readGhostHookfile(file)
    if not isGhostHookfile(file) then return false end
    local success, returns = pcall(readfile, "GHOST_HOOK/new/files/"..file)
    if success then return returns else return print(returns) end
end
local function loadGhostHookfile(file)
    if not isGhostHookfile(file) then return false end
    local success, returns = pcall(loadstring, readGhostHookfile(file))
    if success then return returns else return print(returns) end
end
local function getGhostHookasset(file)
    if isGhostHookfile(file) then return false end
    local success, returns = pcall(getcustomasset, "GHOST_HOOK/new/files/"..file)
    if success then return returns else return print(returns) end
end
do
    if not isfolder("GHOST_HOOK") then makefolder("GHOST_HOOK") end
    if not isfolder("GHOST_HOOK/new") then makefolder("GHOST_HOOK/new") end
    if not isfolder("GHOST_HOOK/new/files") then makefolder("GHOST_HOOK/new/files") end
    local function getfiles(force, list)
        for _, file in list do
            if (force or not force and not isGhostHookfile(file)) then
                writefile("GHOST_HOOK/new/files/"..file, getfile(file))
            end
        end
    end
    local gotassets = getfile("assets.json")
    if not gotassets then return end
    local assets = HttpService:JSONDecode(gotassets)
    local localassets = readGhostHookfile("assets.json")
    if localassets then
        localassets = HttpService:JSONDecode(localassets)
        if localassets.version ~= assets.version then
            writefile("GHOST_HOOK/new/files/assets.json", gotassets)
            getfiles(true, assets.list)
        end
    else
        writefile("GHOST_HOOK/new/files/assets.json", gotassets)
    end
    getfiles(false, assets.list)
end
cheat = {
    Library = nil,
    Toggles = nil,
    Options = nil,
    ThemeManager = nil,
    SaveManager = nil,
    connections = {
        heartbeats = {},
        renderstepped = {},
        generic = {}
    },
    drawings = {},
    instances = {},
    hooks = {},
    unloaded = false,
    loading_active = false,
    loading_finished = false,
    ui_ready = false,
    keybind_indicator_enabled = false,
    hitlogs_enabled = false,
    hitlogs_y = 500,
    hitlogs_size = 14,
    hitlogs_font = 2,
    hitlogs_valid_color = Color3.fromRGB(150, 255, 150),
    hitlogs_invalid_color = Color3.fromRGB(255, 150, 150),
    hitlogs = { pending = {}, active = {} }
}
local tipanel_settings = {
    bgcolor = Color3.fromRGB(15, 15, 15),
    bordercolor = Color3.fromRGB(45, 45, 45),
    accentcolor = Color3.fromRGB(120, 110, 180),
    glowcolor = Color3.fromRGB(120, 110, 180),
    bgtrans = 0.9,
}
local function getTerrainDecoration(default)
    local terrain = _FindFirstChildOfClass(workspace, "Terrain")
    if not terrain then return default end

    if gethiddenproperty then
        local ok, value = pcall(gethiddenproperty, terrain, "Decoration")
        if ok and value ~= nil then
            return value
        end
    end

    local ok, value = pcall(function()
        return terrain.Decoration
    end)
    if ok and value ~= nil then
        return value
    end

    return default
end
local function setTerrainDecoration(value)
    local terrain = _FindFirstChildOfClass(workspace, "Terrain")
    if not terrain then return false end

    if sethiddenproperty then
        local ok = pcall(sethiddenproperty, terrain, "Decoration", value)
        if ok then
            return true
        end
    end

    local ok = pcall(function()
        terrain.Decoration = value
    end)
    return ok
end
cheat.original_state = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows,
    FieldOfView = Camera.FieldOfView,
    CameraType = Camera.CameraType,
    CameraSubject = Camera.CameraSubject,
    MouseBehavior = UserInputService.MouseBehavior,
    CameraMode = LocalPlayer.CameraMode,
    CameraMinZoomDistance = LocalPlayer.CameraMinZoomDistance,
    CameraMaxZoomDistance = LocalPlayer.CameraMaxZoomDistance,
    TerrainDecoration = getTerrainDecoration(true),
}
local ui = {}
cheat.utility = {} do
    cheat.utility.new_heartbeat = function(func)
        local obj = {}
        cheat.connections.heartbeats[func] = func
        function obj:Disconnect()
            if func then
                cheat.connections.heartbeats[func] = nil
                func = nil
            end
        end
        return obj
    end
    cheat.utility.new_renderstepped = function(func)
        local obj = {}
        cheat.connections.renderstepped[func] = func
        function obj:Disconnect()
            if func then
                cheat.connections.renderstepped[func] = nil
                func = nil
            end
        end
        return obj
    end
    cheat.utility.track_connection = function(connection_object)
        if connection_object then
            cheat.connections.generic[connection_object] = connection_object
        end
        return connection_object
    end
    cheat.utility.track_instance = function(instance)
        if instance then
            cheat.instances[instance] = instance
        end
        return instance
    end
    cheat.utility.safe_destroy = function(object)
        if not object then return end
        pcall(function()
            if typeof(object) == "Instance" then
                object:Destroy()
            elseif object.Remove then
                object:Remove()
            elseif object.Destroy then
                object:Destroy()
            end
        end)
    end
    
    local vischeck_params = RaycastParams.new()
    vischeck_params.FilterType = Enum.RaycastFilterType.Exclude
    vischeck_params.CollisionGroup = "WeaponRay"
    vischeck_params.IgnoreWater = true
    cheat._visibility_cache = cheat._visibility_cache or setmetatable({}, { __mode = "k" })

    cheat.utility.is_visible = function(cframe, target, target_part)
        if not (target and target_part and cframe) then return false end
        if cheat.freecam_enabled and cheat.Toggles.freecam_vis_original and cheat.Toggles.freecam_vis_original.Value then
            local my_char = LocalPlayer.Character
            local my_head = my_char and (my_char:FindFirstChild("Head") or my_char:FindFirstChild("CollisionPilot", true) or my_char:FindFirstChild("Mi24_Prop_M", true))
            if my_head then
                cframe = my_head.CFrame
            end
        end
        local origin = cframe.p
        local part_pos = target_part.Position
        local cached = cheat._visibility_cache[target_part]
        local now = os.clock()
        if cached
            and cached.target == target
            and (now - cached.t) <= 0.08
            and (cached.origin - origin).Magnitude <= 2
            and (cached.pos - part_pos).Magnitude <= 2 then
            return cached.visible
        end
        local char = LocalPlayer.Character
        if char ~= cheat.utility._last_vis_char then
            cheat.utility._last_vis_char = char
            vischeck_params.FilterDescendantsInstances = { Workspace.NoCollision, Camera, char }
        end
        local castresults = Workspace:Raycast(origin, part_pos - origin, vischeck_params)
        local visible = false
        if not castresults then
            visible = true
        elseif castresults.Instance then
            visible = castresults.Instance == target_part or castresults.Instance:IsDescendantOf(target)
        end
        cheat._visibility_cache[target_part] = {
            t = now,
            target = target,
            origin = origin,
            pos = part_pos,
            visible = visible
        }
        return visible
    end

    cheat.utility.clear_visibility_cache = function()
        for part in pairs(cheat._visibility_cache) do
            cheat._visibility_cache[part] = nil
        end
    end

    cheat.utility.is_visible_uncached = function(cframe, target, target_part)
        if not (target and target_part and cframe) then return false end
        local char = LocalPlayer.Character
        if char ~= cheat.utility._last_vis_char then
            cheat.utility._last_vis_char = char
            vischeck_params.FilterDescendantsInstances = { Workspace.NoCollision, Camera, char }
        end
        local castresults = Workspace:Raycast(cframe.p, target_part.Position - cframe.p, vischeck_params)
        if not castresults then return true end
        if castresults and castresults.Instance then
            if target_part and castresults.Instance == target_part then return true end
            return castresults.Instance:IsDescendantOf(target)
        end
        return false
    end
    
    cheat.utility.spawn_kill_effect = function(pos)
        local part = Instance.new("Part")
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 1
        part.Position = pos
        part.Parent = workspace.Terrain
        
        local emit = Instance.new("ParticleEmitter")
        emit.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        emit.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1.5), NumberSequenceKeypoint.new(1, 0)})
        emit.Color = ColorSequence.new(Color3.new(1, 1, 1))
        emit.LightEmission = 1
        emit.LightInfluence = 0
        emit.ZOffset = 1
        emit.Lifetime = NumberRange.new(1, 2)
        emit.Rate = 0
        emit.Speed = NumberRange.new(15, 40)
        emit.SpreadAngle = Vector2.new(360, 360)
        emit.Drag = 2
        emit.Parent = part
        
        local amount = cheat.Options.killeffect_amount and cheat.Options.killeffect_amount.Value or 100
        emit:Emit(amount)
        
        game:GetService("Debris"):AddItem(part, 3)
    end
    
    cheat.utility.world_to_screen = function(world)
        local screen, inBounds = Camera:WorldToViewportPoint(world)
        return Vector2.new(screen.X, screen.Y), inBounds, screen.Z
    end
    cheat.utility.new_drawing = function(drawobj, args)
        local obj = Drawing.new(drawobj)
        for i, v in pairs(args) do
            obj[i] = v
        end
        cheat.drawings[obj] = obj
        return obj
    end
    cheat.utility.new_hook = function(f, newf, usecclosure) LPH_NO_VIRTUALIZE(function()
        if usecclosure then
            local old; old = hookfunction(f, newcclosure(function(...)
                return newf(old, ...)
            end))
            cheat.hooks[f] = old
            return old
        else
            local old; old = hookfunction(f, function(...)
                return newf(old, ...)
            end)
            cheat.hooks[f] = old
            return old
        end
    end)() end
    cheat.utility.restore_player_control = function()
        pcall(function() RunService:UnbindFromRenderStep("AADesyncRestore") end)
        pcall(function() RunService:UnbindFromRenderStep("TPKillAutoLook") end)
        pcall(function() UserInputService.MouseBehavior = cheat.original_state.MouseBehavior or Enum.MouseBehavior.Default end)
        pcall(function()
            Camera.CameraType = cheat.original_state.CameraType or Enum.CameraType.Custom
            local current_humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if current_humanoid then
                Camera.CameraSubject = current_humanoid
            elseif cheat.original_state.CameraSubject then
                Camera.CameraSubject = cheat.original_state.CameraSubject
            end
        end)
        pcall(function()
            LocalPlayer.ReplicationFocus = nil
            LocalPlayer.CameraMode = cheat.original_state.CameraMode or Enum.CameraMode.Classic
            LocalPlayer.CameraMinZoomDistance = cheat.original_state.CameraMinZoomDistance or 0.5
            LocalPlayer.CameraMaxZoomDistance = cheat.original_state.CameraMaxZoomDistance or 128
        end)

        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hum then
            pcall(function()
                hum.AutoRotate = true
                hum.PlatformStand = false
                hum.Sit = false
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                if hum.WalkSpeed <= 0 or hum.WalkSpeed > 24 then
                    hum.WalkSpeed = 18
                end
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end)
        end
        if hrp then
            pcall(function()
                if cheat.real_CFrame then
                    hrp.CFrame = cheat.real_CFrame
                end
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end)
        end
        cheat.real_CFrame = nil
        cheat.desync_active = false
        cheat.freecam_enabled = false
        pcall(function()
            for _, container in ipairs({workspace, workspace.Terrain}) do
                local focus = container:FindFirstChild("FreecamFocus")
                if focus then focus:Destroy() end
                local ghost = container:FindFirstChild("FreecamGhost_ESP_IGNORE")
                if ghost then ghost:Destroy() end
            end
            local platform = workspace:FindFirstChild("TPKillPlatform")
            if platform then platform:Destroy() end
        end)
        pcall(function()
            if cheat.utility.restore_viewmodel then
                cheat.utility.restore_viewmodel()
            end
        end)
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local head = char and char:FindFirstChild("Head")
            local hrp2 = char and char:FindFirstChild("HumanoidRootPart")
            if hum then
                Camera.CameraType = Enum.CameraType.Custom
                Camera.CameraSubject = hum
            end
            if head then
                Camera.CFrame = CFrame.new(head.Position + Vector3.new(0, 1.5, 0), head.Position + head.CFrame.LookVector * 8)
            elseif hrp2 then
                Camera.CFrame = hrp2.CFrame * CFrame.new(0, 2, 8)
            end
        end)
    end
    local connection; connection = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(delta)
        for _, func in pairs(cheat.connections.heartbeats) do
            func(delta)
        end
    end))
    local connection1; connection1 = RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function(delta)
        for _, func in pairs(cheat.connections.renderstepped) do
            func(delta)
        end
    end))
    cheat.utility.unload = function()
        if cheat.unloaded then return end
        cheat.unloaded = true
        for _, toggle in pairs(cheat.Toggles or {}) do
            if toggle and toggle.SetValue then
                pcall(function() toggle:SetValue(false) end)
            end
        end
        cheat.utility.restore_player_control()
        pcall(function()
            if cheat.EspLibrary and cheat.EspLibrary.__loaded and cheat.EspLibrary.unload then
                cheat.EspLibrary.unload()
            end
        end)
        pcall(function() connection:Disconnect() end)
        pcall(function() connection1:Disconnect() end)
        for key, _ in pairs(cheat.connections.heartbeats) do
            cheat.connections.heartbeats[key] = nil
        end
        for key, _ in pairs(cheat.connections.renderstepped) do
            cheat.connections.renderstepped[key] = nil
        end
        for key, conn in pairs(cheat.connections.generic) do
            pcall(function() conn:Disconnect() end)
            cheat.connections.generic[key] = nil
        end
        for _, drawing in pairs(cheat.drawings) do
            cheat.utility.safe_destroy(drawing)
            cheat.drawings[_] = nil
        end
        for instance, _ in pairs(cheat.instances) do
            cheat.utility.safe_destroy(instance)
            cheat.instances[instance] = nil
        end
        pcall(function()
            if cheat.Library and cheat.Library._ghostMenu then
                if cheat.Library._ghostMenu.SetOpen then
                    cheat.Library._ghostMenu.SetOpen(false)
                end
                if cheat.Library._ghostMenu.gui then
                    cheat.Library._ghostMenu.gui:Destroy()
                elseif cheat.Library._ghostMenu.GetGui then
                    local gui = cheat.Library._ghostMenu:GetGui()
                    if gui then gui:Destroy() end
                end
            end
        end)
        -- Zero all globals flags BEFORE restoring camera/lighting so that the
        -- __newindex metamethod hook (which is never removed from the game metatable)
        -- no longer swallows Roblox's own Camera.FieldOfView / Lighting writes.
        -- Leaving globals.fov_enabled=true after unload causes the hook to silently
        -- eat every Camera.FieldOfView write from Roblox's CameraController, which
        -- breaks movement input processing (can look but can't walk).
        pcall(function()
            if globals then
                globals.fov_enabled = false
                globals.zoom_enabled = false
                globals.EnableTime = false
                globals.noshadows = false
                globals.gradientenabled = false
            end
        end)
        pcall(function()
            if cheat.original_state then
                Lighting.Ambient = cheat.original_state.Ambient
                Lighting.OutdoorAmbient = cheat.original_state.OutdoorAmbient
                Lighting.ClockTime = cheat.original_state.ClockTime
                Lighting.GlobalShadows = cheat.original_state.GlobalShadows
                Camera.FieldOfView = cheat.original_state.FieldOfView
                setTerrainDecoration(cheat.original_state.TerrainDecoration)
            end
        end)
        cheat.utility.restore_player_control()
        for hooked, original in pairs(cheat.hooks) do
            if type(original) == "function" then
                pcall(function() hookfunction(hooked, clonefunction(original)) end)
            else
                pcall(function() hookmetamethod(original["instance"], original["metamethod"], clonefunction(original["func"])) end)
            end
        end
        -- Final restore after hook cleanup, in case any hook restoration
        -- triggered side-effects that locked movement again.
        cheat.utility.restore_player_control()
        if getgenv then
            getgenv().Toggles = nil
            getgenv().Options = nil
        end
        _G.Injected = false
        _G.InjectedGui = false
    end
    cheat.utility.create_loading_screen = function()
        cheat.loading_active = true
        cheat.loading_finished = false
        if cheat.Library and cheat.Library.SetOpen then
            pcall(function()
                cheat.Library:SetOpen(false)
            end)
        end

        local loading_z = 100000
        local screen_size = Camera.ViewportSize
        local panel_size = _Vector2new(350, 100)
        local panel_pos = (screen_size / 2) - (panel_size / 2)
        local objects = {}
        local function draw(type, args)
            local obj = cheat.utility.new_drawing(type, args)
            table.insert(objects, obj)
            return obj
        end
        local bg = draw("Square", {
            Size = panel_size, Position = panel_pos, Color = Color3.fromRGB(10, 10, 10),
            Filled = true, Transparency = 0.95, Visible = true, ZIndex = loading_z + 10
        })
        for i = 1, 8 do
            draw("Square", {
                Size = panel_size + _Vector2new(i*2, i*2), Position = panel_pos - _Vector2new(i, i),
                Color = tipanel_settings.glowcolor, Thickness = 1, Filled = false,
                Transparency = 0.2 - (i * 0.02), Visible = true, ZIndex = loading_z + 9
            })
        end
        local bar_bg = draw("Square", {
            Size = _Vector2new(panel_size.X - 60, 6), Position = panel_pos + _Vector2new(30, 65),
            Color = Color3.fromRGB(25, 25, 25), Filled = true, Visible = true, ZIndex = loading_z + 11
        })
        local bar = draw("Square", {
            Size = _Vector2new(0, 6), Position = panel_pos + _Vector2new(30, 65),
            Color = tipanel_settings.accentcolor, Filled = true, Visible = true, ZIndex = loading_z + 12
        })
        local bar_glows = {}
        for i = 1, 6 do
            bar_glows[i] = draw("Square", {
                Size = _Vector2new(0, 6) + _Vector2new(i*2, i*2), Position = bar.Position - _Vector2new(i, i),
                Color = tipanel_settings.glowcolor, Thickness = 1, Filled = false,
                Transparency = 0.3 - (i * 0.04), Visible = true, ZIndex = loading_z + 11
            })
        end
        local text = draw("Text", {
            Text = "INITIALIZING GHOST_HOOK", Size = 16, Center = true,
            Position = panel_pos + _Vector2new(panel_size.X / 2, 25),
            Color = Color3.new(1, 1, 1), Font = Drawing.Fonts.Plex, Outline = true,
            Visible = true, ZIndex = loading_z + 13
        })
        local status_text = draw("Text", {
            Text = "Bypassing anticheat...", Size = 13, Center = true,
            Position = panel_pos + _Vector2new(panel_size.X / 2, 45),
            Color = Color3.fromRGB(200, 200, 200), Font = Drawing.Fonts.Plex, Outline = true,
            Visible = true, ZIndex = loading_z + 13
        })
        local statuses = {
            "Bypassing anticheat...", "Loading core modules...", "Initializing combat engine...", 
            "Fetching latest config...", "Connecting to server...", "Optimizing performance...", 
            "Setting up visual environment...", "Securing connection...", "Cleaning memory caches...",
            "Ready to play!"
        }
        local start = tick()
        local last_status = 0
        while true do
            local elapsed = tick() - start
            local progress = math.clamp(elapsed / 5, 0, 1)
            local bar_width = (panel_size.X - 60) * progress
            bar.Size = _Vector2new(bar_width, 6)
            for i = 1, 6 do
                if bar_glows[i] then
                    bar_glows[i].Size = _Vector2new(bar_width, 6) + _Vector2new(i*2, i*2)
                end
            end
            text.Transparency = 0.7 + (math.sin(tick() * 5) * 0.3)
            
            if tick() - last_status > 0.6 then
                last_status = tick()
                status_text.Text = statuses[math.random(1, #statuses-1)]
            end
            if progress > 0.95 then
                status_text.Text = cheat.ui_ready and "Ready to play!" or "Finalizing interface..."
            end
            if progress >= 1 and cheat.ui_ready then
                break
            end
            task.wait()
        end
        for _, v in objects do v:Remove() end
        cheat.loading_active = false
        cheat.loading_finished = true
        if cheat.ui_ready and cheat.Library and not cheat.unloaded then
            if cheat.Library.SetOpen then
                cheat.Library:SetOpen(true)
            else
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.RightShift, false, game)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.RightShift, false, game)
            end
        end
    end
end
task.spawn(cheat.utility.create_loading_screen)

local function loadGhostHookUiStack()
    local GHOST_LIBRARY_URL = "https://raw.githubusercontent.com/kristerstomasuns-hub/essentials/main/test%20lib?v=autoloadfix-20260719"
    local Toggles = {}
    local Options = {}

    local function notify(title, text, duration)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = tostring(title or "GHOST_HOOK"),
                Text = tostring(text or ""),
                Duration = tonumber(duration) or 3,
            })
        end)
    end

    local function ensureFolder(path)
        if isfolder and makefolder and type(path) == "string" and path ~= "" and not isfolder(path) then
            makefolder(path)
        end
    end

    local function serializeValue(value)
        if typeof(value) == "Color3" then
            return { __type = "Color3", R = value.R, G = value.G, B = value.B }
        elseif type(value) == "table" then
            local copy = {}
            for key, child in pairs(value) do
                copy[key] = serializeValue(child)
            end
            return copy
        end
        return value
    end

    local function deserializeValue(value)
        if type(value) ~= "table" then
            return value
        end
        if value.__type == "Color3" or (value.R ~= nil and value.G ~= nil and value.B ~= nil) then
            return Color3.new(tonumber(value.R) or 0, tonumber(value.G) or 0, tonumber(value.B) or 0)
        end
        local copy = {}
        for key, child in pairs(value) do
            copy[key] = deserializeValue(child)
        end
        return copy
    end

    local function selectedDefault(values, default)
        if type(values) ~= "table" then
            return default
        end
        if type(default) == "number" then
            return values[default] or values[1]
        end
        return default or values[1]
    end

    local function makeValueObject(rawElement, valueKind, initialValue, flag, callback)
        local object = {
            Value = initialValue,
            _raw = rawElement,
            _kind = valueKind,
            _flag = flag,
            Text = flag,
            _callbacks = {},
        }

        if callback then
            table.insert(object._callbacks, callback)
        end

        local function fire(value)
            object.Value = value
            for _, cb in ipairs(object._callbacks) do
                pcall(cb, value)
            end
        end

        function object:OnChanged(cb)
            if cb then
                table.insert(self._callbacks, cb)
            end
            return self
        end

        function object:SetValue(value, skipCallback)
            self.Value = value
            if rawElement and rawElement.set_value then
                if valueKind == "Toggle" then
                    rawElement:set_value({ Toggle = value and true or false }, true)
                elseif valueKind == "Slider" then
                    rawElement:set_value({ Slider = tonumber(value) or 0 }, true)
                elseif valueKind == "Dropdown" then
                    rawElement:set_value({ Dropdown = value }, true)
                elseif valueKind == "Combo" then
                    rawElement:set_value({ Combo = type(value) == "table" and value or {} }, true)
                elseif valueKind == "Text" then
                    rawElement:set_value({ Text = tostring(value or "") }, true)
                elseif valueKind == "Color" then
                    rawElement:set_value({ Color = value }, true)
                else
                    rawElement:set_value(value, true)
                end
            end
            if not skipCallback then
                fire(self.Value)
            end
            return self
        end

        function object:SetValues(values)
            self.Values = values or {}
            if rawElement then
                pcall(function()
                    if rawElement.ClearOptions then
                        rawElement:ClearOptions()
                    end
                    if rawElement.InsertOptions then
                        rawElement:InsertOptions(self.Values)
                    end
                end)
            end
            return self
        end

        function object:SetVisible(state)
            if rawElement and rawElement.set_visible then
                rawElement:set_visible(state and true or false)
            end
            return self
        end

        function object:AddColorPicker(colorFlag, config)
            config = config or {}
            local colorValue = config.Default or Color3.new(1, 1, 1)
            local transparency = config.Transparency
            if transparency == nil then
                transparency = config.Alpha
            end
            if transparency == nil then
                transparency = 0
            end
            local colorObject

            if rawElement and rawElement.add_color then
                local rawColor = rawElement:add_color({
                    Color = colorValue,
                    Transparency = transparency,
                }, transparency ~= nil, function(value)
                    colorObject.Value = value.Color
                    colorObject.Transparency = value.Transparency or 0
                    if config.Callback then
                        pcall(config.Callback, colorObject.Value, colorObject.Transparency)
                    end
                end)

                colorObject = makeValueObject(rawColor, "Color", colorValue, colorFlag, config.Callback)
                colorObject.Transparency = transparency
            else
                colorObject = makeValueObject(nil, "Color", colorValue, colorFlag, config.Callback)
                colorObject.Transparency = transparency
            end

            Options[colorFlag] = colorObject
            return self
        end

        function object:AddKeyPicker(keyFlag, config)
            config = config or {}
            local defaultMode = "Hold"
            local keyValue = {
                Key = config.Default or "None",
                Type = defaultMode,
                Active = false,
            }
            local keyObject

            if rawElement and rawElement.add_keybind then
                local rawKey = rawElement:add_keybind({
                    Key = config.Default or "None",
                    Type = defaultMode,
                }, function(value)
                    keyObject.Value = value
                    keyObject.Active = value.Type == "Always" or value.Active == true
                    keyObject.State = keyObject.Active
                    keyObject.Key = value.Key or keyObject.Key
                    keyObject.Mode = value.Type or value.Mode or keyObject.Mode
                    if config.Callback then
                        pcall(config.Callback, keyObject.Active, value)
                    end
                end)
                keyObject = makeValueObject(rawKey, "Keybind", keyValue, keyFlag)
                pcall(function()
                    rawKey:set_value({
                        Key = config.Default or "None",
                        Type = defaultMode,
                        Active = false,
                    }, true)
                end)
            else
                keyObject = makeValueObject(nil, "Keybind", keyValue, keyFlag)
            end

            keyObject.Text = config.Text or keyFlag
            keyObject.Key = keyValue.Key
            keyObject.Mode = keyValue.Type
            keyObject.State = keyValue.Type == "Always" or keyValue.Active
            local baseKeySetValue = keyObject.SetValue
            function keyObject:SetValue(value)
                baseKeySetValue(self, value)
                if type(value) == "table" then
                    self.Key = value.Key or value.key or self.Key
                    self.Mode = value.Type or value.type or value.Mode or value.mode or self.Mode
                    local active = value.Active
                    if active == nil then
                        active = value.active
                    end
                    self.Active = self.Mode == "Always" or active == true
                    self.State = self.Active
                elseif type(value) == "string" then
                    if value == "Hold" or value == "Toggle" or value == "Always" then
                        self.Mode = value
                    else
                        self.Key = value
                    end
                    self.Active = self.Mode == "Always"
                    self.State = self.Active
                end
                if config.Callback then
                    pcall(config.Callback, self.State, self.Value)
                end
                return self
            end
            Options[keyFlag] = keyObject
            return self
        end

        function object:AddButton(text, cb)
            if cb then
                pcall(cb)
            end
            return self
        end

        if flag then
            if valueKind == "Toggle" then
                Toggles[flag] = object
            else
                Options[flag] = object
            end
        end

        return object, fire
    end

    local function loadGhostLibrary()
        local maclibLoaderPatch = [==[
local function patchMacLibSource(macSource)
	macSource = macSource:gsub("RunService%.RenderStepped:Connect%(UpdateOrientation%)", "if acrylicBlur then RunService.RenderStepped:Connect(UpdateOrientation) end")
	macSource = macSource:gsub("colorC%.BackgroundTransparency = ColorpickerFunctions%.Alpha or 0", "colorC.BackgroundTransparency = 0")
	macSource = macSource:gsub("colorC%.BackgroundTransparency = isAlpha and %(1 %- ColorpickerFunctions%.Alpha%) or 0", "colorC.BackgroundTransparency = 0")
	macSource = macSource:gsub("colorC%.BackgroundTransparency = alphaToPreviewTransparency%(ColorpickerFunctions%.Alpha%)", "colorC.BackgroundTransparency = 0")
	macSource = macSource:gsub("colorC%.BackgroundTransparency = alpha", "colorC.BackgroundTransparency = 0")
	macSource = macSource:gsub("color1%.BackgroundTransparency = isAlpha and ColorpickerFunctions%.Alpha or 0", "color1.BackgroundTransparency = 0")
	macSource = macSource:gsub("color1%.BackgroundTransparency = isAlpha and alphaToPreviewTransparency%(ColorpickerFunctions%.Alpha%) or 0", "color1.BackgroundTransparency = 0")
	macSource = macSource:gsub("color1%.BackgroundTransparency = alphaToPreviewTransparency%(ColorpickerFunctions%.Alpha%)", "color1.BackgroundTransparency = 0")
	macSource = macSource:gsub("colour%.BackgroundTransparency = clampInput%(modifierInputs%.Alpha%.Text, 0, 1%)", "colour.BackgroundTransparency = 0")
	macSource = macSource:gsub("colour%.BackgroundTransparency = isAlpha and ColorpickerFunctions%.Alpha or 0", "colour.BackgroundTransparency = 0")
	macSource = macSource:gsub("colour%.BackgroundTransparency = isAlpha and alphaToPreviewTransparency%(ColorpickerFunctions%.Alpha%) or 0", "colour.BackgroundTransparency = 0")
	macSource = macSource:gsub("colour%.BackgroundTransparency = alphaToPreviewTransparency%(ColorpickerFunctions%.Alpha%)", "colour.BackgroundTransparency = 0")
	macSource = macSource:gsub("ColorpickerFunctions%.Alpha = %(cX / width%)", "ColorpickerFunctions.Alpha = 1 - (cX / width)")
	macSource = macSource:gsub("local cX = ColorpickerFunctions%.Alpha %* width", "local cX = (1 - ColorpickerFunctions.Alpha) * width")
	macSource = macSource:gsub("local cX = math%.clamp%(alpha or 0, 0, 1%) %* width", "local cX = (1 - ColorpickerFunctions.Alpha) * width")
	macSource = macSource:gsub("modifierInputs%.Alpha%.Text = isAlpha and %(1 %- ColorpickerFunctions%.Alpha%) or 0", "modifierInputs.Alpha.Text = isAlpha and ColorpickerFunctions.Alpha or 0")
	macSource = macSource:gsub("information%.Size = UDim2%.new%(1, 0, 0, 63%)", "information.Size = UDim2.new(1, 0, 0, 74)")
	macSource = macSource:gsub("divider%.Parent = sidebar", "divider.Visible = false\n\tdivider.Parent = sidebar")
	macSource = macSource:gsub("divider2%.Parent = information", "divider2.Visible = false\n\tdivider2.Parent = information")
	macSource = macSource:gsub("sidebarGroup%.Position = UDim2%.fromOffset%(0, 63%)", "sidebarGroup.Position = UDim2.fromOffset(0, 74)")
	macSource = macSource:gsub("sidebarGroup%.Size = UDim2%.new%(1, 0, 1, %-63%)", "sidebarGroup.Size = UDim2.new(1, 0, 1, -74)")
	macSource = macSource:gsub("userInfo%.Size = UDim2%.new%(1, 0, 0, 107%)", "userInfo.Size = UDim2.new(1, 0, 0, 76)")
	macSource = macSource:gsub("informationGroup%.Parent = userInfo", "informationGroup.Visible = false\n\tinformationGroup.Parent = userInfo")
	macSource = macSource:gsub("userInfoUIPadding%.Parent = userInfo", "userInfoUIPadding.Parent = userInfo\n\n\ttitleFrame.Parent = userInfo\n\ttitleFrame.Position = UDim2.new(0, 18, 0, 14)\n\ttitleFrame.Size = UDim2.new(1, -36, 0, 46)\n\ttitle.TextSize = 14\n\tsubtitle.TextSize = 10")
	macSource = macSource:gsub("ghostLogo%.AnchorPoint = Vector2%.new%(0, 1%)", "ghostLogo.AnchorPoint = Vector2.new(0, 0)")
	macSource = macSource:gsub("ghostLogo%.Position = UDim2%.new%(0, 4, 1, %-12%)", "ghostLogo.Position = UDim2.new(0, 0, 0, -10)")
	macSource = macSource:gsub("ghostLogo%.Size = UDim2%.new%(1, %-6, 0, 104%)", "ghostLogo.Size = UDim2.new(1, -8, 1, 14)")
	macSource = macSource:gsub("ghostLogo%.Visible = false", "ghostLogo.Visible = true")
	macSource = macSource:gsub("ghostLogo%.Parent = userInfo", "ghostLogo.Parent = informationHolder")
	macSource = macSource:gsub("ghostSkull%.Position = UDim2%.new%(0, 0, 1, %-45%)", "ghostSkull.Position = UDim2.new(0, 0, 0.5, 0)")
	macSource = macSource:gsub("ghostSkull%.Size = UDim2%.fromOffset%(90, 90%)", "ghostSkull.Size = UDim2.fromOffset(88, 88)")
	macSource = macSource:gsub("ghostWordmark%.Position = UDim2%.new%(0, 68, 1, %-146%)", "ghostWordmark.Position = UDim2.fromOffset(68, -50)")
	macSource = macSource:gsub("ghostWordmark%.Size = UDim2%.fromOffset%(225, 225%)", "ghostWordmark.Size = UDim2.fromOffset(222, 222)")
	macSource = macSource:gsub("ghostLuaL%.Position = UDim2%.new%(0, 68, 1, %-146%)", "ghostLuaL.Position = UDim2.fromOffset(68, -50)")
	macSource = macSource:gsub("ghostLuaL%.Size = UDim2%.fromOffset%(225, 225%)", "ghostLuaL.Size = UDim2.fromOffset(222, 222)")
	macSource = macSource:gsub("ghostLua%.Position = UDim2%.new%(0, 68, 1, %-146%)", "ghostLua.Position = UDim2.fromOffset(68, -50)")
	macSource = macSource:gsub("ghostLua%.Size = UDim2%.fromOffset%(225, 225%)", "ghostLua.Size = UDim2.fromOffset(222, 222)")
	macSource = macSource:gsub("tabSwitchers%.Size = UDim2%.new%(1, 0, 1, %-107%)", "tabSwitchers.Size = UDim2.new(1, 0, 1, -80)")
	macSource = macSource:gsub("tabSwitcherUIStroke%.Color = Color3%.fromRGB%(255, 255, 255%)", "tabSwitcherUIStroke.Color = Color3.fromRGB(0, 45, 255)")
	macSource = macSource:gsub("tabSwitcherUIStroke%.Transparency = 1", "tabSwitcherUIStroke.Thickness = 1\n\t\t\ttabSwitcherUIStroke.Transparency = 1")
	macSource = macSource:gsub("Transparency = %(i == tabSwitcher and 0%.95 or 1%)", "Transparency = (i == tabSwitcher and 0.3 or 1)")
	macSource = macSource:gsub("tabSwitchersScrollingFrame%.BackgroundTransparency = 0", "tabSwitchersScrollingFrame.BackgroundTransparency = 1")
	macSource = macSource:gsub("tabSwitchersScrollingFrame%.Size = UDim2%.fromScale%(1, 1%)", "tabSwitchersScrollingFrame.Size = UDim2.fromScale(1, 1)\n\ttabSwitchersScrollingFrame.ZIndex = 2", 1)
	macSource = macSource:gsub("BackgroundTransparency = %(i == tabSwitcher and 0 or 1%)", "BackgroundTransparency = (i == tabSwitcher and 0.5 or 1)")

	if not macSource:find('Name = "TabSwitchersBackground"', 1, true) then
		local tabBackgroundSource = [[
	local themeAccentLineTop = Instance.new("Frame")
	themeAccentLineTop.Name = "ThemeAccentLineTop"
	themeAccentLineTop.BackgroundColor3 = Color3.fromRGB(0, 45, 255)
	themeAccentLineTop.BackgroundTransparency = 0.1
	themeAccentLineTop.BorderSizePixel = 0
	themeAccentLineTop.Position = UDim2.new(0, 0, 0, 74)
	themeAccentLineTop.Size = UDim2.new(1, 0, 0, 1)
	themeAccentLineTop.Visible = false
	themeAccentLineTop.ZIndex = 20
	themeAccentLineTop.Parent = sidebar

	local themeAccentLineRight = Instance.new("Frame")
	themeAccentLineRight.Name = "ThemeAccentLineRight"
	themeAccentLineRight.BackgroundColor3 = Color3.fromRGB(0, 45, 255)
	themeAccentLineRight.BackgroundTransparency = 0.3
	themeAccentLineRight.BorderSizePixel = 0
	themeAccentLineRight.Position = UDim2.new(1, -1, 0, 74)
	themeAccentLineRight.Size = UDim2.new(0, 1, 1, -74)
	themeAccentLineRight.ZIndex = 20
	themeAccentLineRight.Parent = sidebar

	local tabSwitchersBackground = Instance.new("ImageLabel")
	tabSwitchersBackground.Name = "TabSwitchersBackground"
	tabSwitchersBackground.Image = "rbxassetid://87437911629397"
	tabSwitchersBackground.ImageTransparency = 0.58
	tabSwitchersBackground.ScaleType = Enum.ScaleType.Fit
	tabSwitchersBackground.BackgroundTransparency = 1
	tabSwitchersBackground.BorderSizePixel = 0
	tabSwitchersBackground.AnchorPoint = Vector2.new(0.5, 0.5)
	tabSwitchersBackground.Position = UDim2.fromScale(0.63, 0.42)
	tabSwitchersBackground.Size = UDim2.new(0.78, 0, 0.88, 0)
	tabSwitchersBackground.ZIndex = 0
	tabSwitchersBackground.Active = false
	tabSwitchersBackground.Parent = tabSwitchers

	local themeAccentLineBottom = Instance.new("Frame")
	themeAccentLineBottom.Name = "ThemeAccentLineBottom"
	themeAccentLineBottom.BackgroundColor3 = Color3.fromRGB(0, 45, 255)
	themeAccentLineBottom.BackgroundTransparency = 1
	themeAccentLineBottom.BorderSizePixel = 0
	themeAccentLineBottom.Position = UDim2.new(0, 0, 1, -1)
	themeAccentLineBottom.Size = UDim2.new(1, 0, 0, 1)
	themeAccentLineBottom.Visible = false
	themeAccentLineBottom.ZIndex = 20
	themeAccentLineBottom.Parent = tabSwitchers]]
		macSource = macSource:gsub("tabSwitchers%.Size = UDim2%.new%(1, 0, 1, %-80%)[\r\n]", "tabSwitchers.Size = UDim2.new(1, 0, 1, -80)\n\n" .. tabBackgroundSource .. "\n\n", 1)
	end

	local alphaTextReady = macSource:find('Name = "AlphaText"', 1, true) ~= nil
	if not alphaTextReady then
		local alphaTextSource = [[
					local colorAlphaText = Instance.new("TextLabel")
					colorAlphaText.Name = "AlphaText"
					colorAlphaText.AnchorPoint = Vector2.new(0.5, 0.5)
					colorAlphaText.BackgroundTransparency = 1
					colorAlphaText.BorderSizePixel = 0
					colorAlphaText.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
					colorAlphaText.Position = UDim2.fromScale(0.5, 0.5)
					colorAlphaText.Size = UDim2.fromScale(1, 1)
					colorAlphaText.Text = ""
					colorAlphaText.TextColor3 = Color3.fromRGB(255, 255, 255)
					colorAlphaText.TextSize = 9
					colorAlphaText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
					colorAlphaText.TextStrokeTransparency = 0.35
					colorAlphaText.TextXAlignment = Enum.TextXAlignment.Center
					colorAlphaText.TextYAlignment = Enum.TextYAlignment.Center
					colorAlphaText.ZIndex = 7
					colorAlphaText.Parent = colorCbg]]
		local count
		macSource, count = macSource:gsub("colorC%.Parent = colorCbg", "colorC.Parent = colorCbg\n\n" .. alphaTextSource, 1)
		alphaTextReady = count > 0
	end

	local helperSource = [[
					local function formatAlphaLabel(alpha)
						local value = math.clamp(tonumber(alpha) or 0, 0, 1)
						if value == 0 or value == 1 then
							return tostring(value)
						end
						return string.format("%.2f", value):gsub("0+$", ""):gsub("%.$", "")
					end

					local function updateAlphaPreviewText()
						colorAlphaText.Visible = isAlpha
						colorAlphaText.Text = isAlpha and formatAlphaLabel(ColorpickerFunctions.Alpha) or ""
					end]]
	if alphaTextReady and not macSource:find("formatAlphaLabel", 1, true) then
		macSource = macSource:gsub("local function update%(%)[\r\n]", helperSource .. "\n\n					local function update()\n", 1)
	end
	if alphaTextReady and macSource:find("updateAlphaPreviewText", 1, true) then
		macSource = macSource:gsub("update%(%)[\r\n](%s*end)", "update()\n						updateAlphaPreviewText()\n%1")
		macSource = macSource:gsub("(UpdateRingFromHSV%(hue, saturation, value%)[\r\n])", "%1						updateAlphaPreviewText()\n")
	end
	return macSource
end

local macSource = game:HttpGet(MACLIB_URL)
macSource = patchMacLibSource(macSource)
return loadstring(macSource)()
]==]
        local source
        pcall(function()
            source = game:HttpGet(GHOST_LIBRARY_URL, true)
        end)

        if source and source ~= "" then
            source = source:gsub('Subtitle%s*=%s*"[^"]*"', 'Subtitle = "GHOST_HOOK wrapper"', 1)
            source = source:gsub('AcrylicBlur%s*=%s*true', 'AcrylicBlur = false')
            source = source:gsub('object%.Name == "SliderFrame"%) then', 'object.Name == "SliderFrame" or object.Name:match("^ThemeAccentLine")) then')
            source = source:gsub('object%.Name == "ToggleUIStroke" or object%.Name == "ColorPickerOutline"', 'object.Name == "ColorPickerOutline" or object.Name == "TabSwitcherUIStroke"')
            source = source:gsub(
                'return%s+loadstring%(%s*game:HttpGet%(%s*MACLIB_URL%s*%)%s*%)%(%s*%)',
                maclibLoaderPatch
            )
            pcall(function()
                writefile("GHOST_HOOK/new/files/library_main.lua", source)
            end)
            local ok, loaded = pcall(function()
                return loadstring(source)()
            end)
            if ok and type(loaded) == "table" then
                return loaded
            end
        end

        local localSource = readGhostHookfile("library_main.lua")
        if localSource then
            localSource = localSource:gsub('Subtitle%s*=%s*"[^"]*"', 'Subtitle = "GHOST_HOOK wrapper"', 1)
            localSource = localSource:gsub('AcrylicBlur%s*=%s*true', 'AcrylicBlur = false')
            localSource = localSource:gsub('object%.Name == "SliderFrame"%) then', 'object.Name == "SliderFrame" or object.Name:match("^ThemeAccentLine")) then')
            localSource = localSource:gsub('object%.Name == "ToggleUIStroke" or object%.Name == "ColorPickerOutline"', 'object.Name == "ColorPickerOutline" or object.Name == "TabSwitcherUIStroke"')
            localSource = localSource:gsub(
                'return%s+loadstring%(%s*game:HttpGet%(%s*MACLIB_URL%s*%)%s*%)%(%s*%)',
                maclibLoaderPatch
            )
            local localChunk = loadstring(localSource)
            local ok, loaded, loadedToggles, loadedOptions = pcall(localChunk)
            if ok and type(loaded) == "table" then
                return loaded, loadedToggles, loadedOptions
            end
        end
    end

    local ghostLibrary, loadedToggles, loadedOptions = loadGhostLibrary()

    if type(ghostLibrary) == "table" and type(ghostLibrary.CreateWindow) == "function" then
        Toggles = type(loadedToggles) == "table" and loadedToggles or Toggles
        Options = type(loadedOptions) == "table" and loadedOptions or Options
        local themeChunk = loadGhostHookfile("library_theme.lua")
        local saveChunk = loadGhostHookfile("library_save.lua")
        local _, themeManager = pcall(function()
            return themeChunk and themeChunk()
        end)
        local _, saveManager = pcall(function()
            return saveChunk and saveChunk()
        end)
        return ghostLibrary, Toggles, Options, themeManager or {}, saveManager or {}
    end

    if type(ghostLibrary) ~= "table" or type(ghostLibrary.new) ~= "function" then
        error("GHOST_HOOK failed to load Ghost-compatible library_main.lua")
    end

    local Library = {
        Toggles = Toggles,
        Options = Options,
        KeybindFrame = { Visible = false },
    }

    local ghostTabIcons = {
        Combat = "rbxassetid://109366020496537",
        Visuals = "rbxassetid://119385181967075",
        Movement = "rbxassetid://139044864852433",
        Player = "rbxassetid://98375642144966",
        World = "rbxassetid://137174378463882",
        Misc = "rbxassetid://130943404476007",
        Settings = "rbxassetid://130507927595367",
    }

    local function normalizeTabArgs(name, icon)
        if type(name) == "table" then
            icon = name.Icon or name.Image or name.icon or name.image or icon
            name = name.Name or name.Title or name.name or name.title
        end

        name = tostring(name or "Tab")
        icon = icon or ghostTabIcons[name]
        return name, icon
    end

    local function wrapSector(sector)
        local group = {}

        function group:AddToggle(flag, config)
            config = config or {}
            local text = config.Text or flag
            local object
            local raw = sector.element("Toggle", text, {
                default = { Toggle = config.Default and true or false },
            }, function(value)
                object.Value = value.Toggle and true or false
                if config.Callback then
                    pcall(config.Callback, object.Value)
                end
                for _, cb in ipairs(object._callbacks) do
                    if cb ~= config.Callback then
                        pcall(cb, object.Value)
                    end
                end
            end, nil, flag)

            object = makeValueObject(raw, "Toggle", config.Default and true or false, flag, config.Callback)
            return object
        end

        function group:AddSlider(flag, config)
            config = config or {}
            local rounding = tonumber(config.Rounding) or 0
            local scale = rounding > 0 and (10 ^ rounding) or 1
            local min = tonumber(config.Min) or 0
            local max = tonumber(config.Max) or 100
            local default = tonumber(config.Default) or min
            local object

            local raw = sector.element("Slider", config.Text or flag, {
                default = {
                    min = min * scale,
                    max = max * scale,
                    default = default * scale,
                },
            }, function(value)
                object.Value = (tonumber(value.Slider) or 0) / scale
                if config.Callback then
                    pcall(config.Callback, object.Value)
                end
                for _, cb in ipairs(object._callbacks) do
                    if cb ~= config.Callback then
                        pcall(cb, object.Value)
                    end
                end
            end, nil, flag)

            object = makeValueObject(raw, "Slider", default, flag, config.Callback)
            local baseSetValue = object.SetValue
            function object:SetValue(value, skipCallback)
                value = tonumber(value) or min
                self.Value = value
                if raw and raw.set_value then
                    raw:set_value({ Slider = value * scale }, true)
                end
                if not skipCallback then
                    for _, cb in ipairs(self._callbacks) do
                        pcall(cb, self.Value)
                    end
                end
                return self
            end
            object._baseSetValue = baseSetValue
            return object
        end

        function group:AddDropdown(flag, config)
            config = config or {}
            local values = config.Values or config.Options or {}
            local isMulti = config.Multi and true or false
            local default = isMulti and (type(config.Default) == "table" and config.Default or {}) or selectedDefault(values, config.Default)
            local elementType = isMulti and "Combo" or "Dropdown"
            local object

            local raw = sector.element(elementType, config.Text or flag, {
                options = values,
                default = isMulti and { Combo = default } or { Dropdown = default },
            }, function(value)
                object.Value = isMulti and (value.Combo or {}) or value.Dropdown
                if config.Callback then
                    pcall(config.Callback, object.Value)
                end
                for _, cb in ipairs(object._callbacks) do
                    if cb ~= config.Callback then
                        pcall(cb, object.Value)
                    end
                end
            end, nil, flag)

            object = makeValueObject(raw, isMulti and "Combo" or "Dropdown", default, flag, config.Callback)
            object.Values = values
            return object
        end

        function group:AddInput(flag, config)
            config = config or {}
            local default = config.Default or ""
            local object
            local raw = sector.element("TextBox", config.Text or flag, {
                default = { Text = default },
                clearTextOnFocus = config.ClearTextOnFocus == true,
            }, function(value)
                if type(value) == "table" then
                    object.Value = value.Text or value.Value or value.value or ""
                else
                    object.Value = tostring(value or "")
                end
                if config.Callback then
                    pcall(config.Callback, object.Value)
                end
                for _, cb in ipairs(object._callbacks) do
                    if cb ~= config.Callback then
                        pcall(cb, object.Value)
                    end
                end
            end, nil, flag)

            object = makeValueObject(raw, "Text", default, flag, config.Callback)
            function object:GetInput()
                if raw and raw.GetInput then
                    return raw:GetInput()
                elseif raw and raw.get_value then
                    local rawValue = raw:get_value()
                    if type(rawValue) == "table" then
                        return rawValue.Text or rawValue.Value or rawValue.value or self.Value
                    end
                    return rawValue
                end
                return self.Value
            end
            return object
        end

        function group:AddKeybind(flag, config)
            config = config or {}
            local default = config.Default or config.default or "None"
            local object
            local raw = sector.element("Keybind", config.Text or flag, {
                default = default,
            }, function(value)
                object.Value = value
                object.Key = value.Key or object.Key
                object.Mode = value.Type or object.Mode
                object.State = value.Active and true or false
                if config.Callback then
                    pcall(config.Callback, value)
                end
                for _, cb in ipairs(object._callbacks) do
                    if cb ~= config.Callback then
                        pcall(cb, value)
                    end
                end
            end, nil, flag)

            object = makeValueObject(raw, "Keybind", { Key = default, Type = "Hold", Active = false }, flag, config.Callback)
            object.Text = config.Text or flag
            object.Key = default
            object.Mode = "Hold"
            object.State = false
            return object
        end

        function group:AddButton(text, callback)
            local button = {}
            sector.element("Button", text, {}, function()
                if callback then
                    pcall(callback)
                end
            end)
            function button:AddButton(nextText, nextCallback)
                return group:AddButton(nextText, nextCallback)
            end
            return button
        end

        function group:AddLabel(text)
            local label = { Text = tostring(text or "") }
            sector.element("Label", label.Text, {}, function() end)
            function label:SetText(newText)
                self.Text = tostring(newText or "")
                return self
            end
            return label
        end

        function group:AddDivider()
            if sector.create_line then
                sector.create_line()
            end
            return self
        end

        function group:AddDependencyBox()
            local dep = wrapSector(sector)
            function dep:SetupDependencies()
                return self
            end
            return dep
        end

        function group:SetupDependencies()
            return self
        end

        return group
    end

    local function wrapTab(oldTab)
        local tab = {
            _old = oldTab,
            _tabboxCount = 0,
            _groupboxCount = 0,
        }

        local function makeSection(prefix)
            tab._tabboxCount = tab._tabboxCount + 1
            return oldTab.new_section(prefix .. " " .. tostring(tab._tabboxCount))
        end

        local function addTabbox(side)
            local section = makeSection(side .. " Tabbox")
            return {
                AddTab = function(_, name)
                    return wrapSector(section.new_sector(name or "Tab", side))
                end,
            }
        end

        local function addGroupbox(side, name)
            tab._groupboxCount = tab._groupboxCount + 1
            local section = oldTab.new_section(name or (side .. " Groupbox " .. tostring(tab._groupboxCount)))
            return wrapSector(section.new_sector(name or "Groupbox", side))
        end

        function tab:AddLeftTabbox()
            return addTabbox("Left")
        end

        function tab:AddRightTabbox()
            return addTabbox("Right")
        end

        function tab:AddLeftGroupbox(name)
            return addGroupbox("Left", name)
        end

        function tab:AddRightGroupbox(name)
            return addGroupbox("Right", name)
        end

        return tab
    end

    function Library:CreateWindow(config)
        config = config or {}
        local menu = ghostLibrary.new(config.Title or "GHOST_HOOK", "GHOST_HOOK/")
        self._ghostMenu = menu
        self.Opened = menu.IsOpen and menu.IsOpen() or true
        if menu.SetOpen and not menu._ghostHookOpenWrapped then
            local originalSetOpen = menu.SetOpen
            menu.SetOpen = function(state)
                self.Opened = state and true or false
                return originalSetOpen(state)
            end
            menu._ghostHookOpenWrapped = true
        end
        if menu.gui then
            cheat.utility.track_instance(menu.gui)
        elseif menu.GetGui then
            pcall(function()
                local gui = menu:GetGui()
                if gui then cheat.utility.track_instance(gui) end
            end)
        end
        if config.AutoShow == false or cheat.loading_active then
            self:SetOpen(false)
        end
        self._window = {
            _menu = menu,
            AddTab = function(_, name, icon)
                local tabName, tabIcon = normalizeTabArgs(name, icon)
                return wrapTab(menu.new_tab(tabIcon, tabName))
            end,
            SetStatusText = function(_, text, color)
                if menu.SetStatusText then
                    menu:SetStatusText(text, color)
                end
            end,
        }
        return self._window
    end

    function Library:SetOpen(state)
        self.Opened = state and true or false
        if self._ghostMenu and self._ghostMenu.SetOpen then
            pcall(function()
                self._ghostMenu.SetOpen(self.Opened)
            end)
        elseif self._ghostMenu and self._ghostMenu.gui then
            self._ghostMenu.gui.Enabled = self.Opened
        end
    end

    function Library:SetToggleKey(key)
        if self._ghostMenu and self._ghostMenu.SetMenuKeybind then
            return self._ghostMenu.SetMenuKeybind(key)
        end
        return false
    end

    function Library:Notify(title, text, duration)
        if self._ghostMenu and self._ghostMenu.window and self._ghostMenu.window.Notify then
            pcall(function()
                self._ghostMenu.window:Notify({
                    Title = tostring(title or "GHOST_HOOK"),
                    Description = tostring(text or ""),
                    Lifetime = tonumber(duration) or 3,
                })
            end)
        end
        notify(title, text, duration)
    end

    local function makeSaveManager()
        local manager = {
            Folder = "GHOST_HOOK",
            Ignore = {},
            Library = Library,
            Options = Options,
            Toggles = Toggles,
        }

        function manager:SetOptionsTEMP(newOptions, newToggles)
            self.Options = newOptions or self.Options
            self.Toggles = newToggles or self.Toggles
        end

        function manager:SetLibrary(lib)
            self.Library = lib
        end

        local function cleanConfigName(name)
            name = tostring(name or "Default")
            name = name:gsub("%.json$", ""):gsub("%.txt$", "")
            name = name:gsub("^%s+", ""):gsub("%s+$", "")
            return name ~= "" and name or "Default"
        end

        local function getGhostMenu(self)
            return self.Library and self.Library._ghostMenu
        end

        function manager:IgnoreThemeSettings() end

        function manager:SetFolder(folder)
            self.Folder = folder or self.Folder
            ensureFolder(self.Folder)
            ensureFolder(self.Folder .. "/settings")
        end

        function manager:RefreshConfigList()
            ensureFolder(self.Folder)
            ensureFolder(self.Folder .. "/settings")
            local out = {}
            local seen = {}
            local function add(name)
                name = cleanConfigName(name)
                if name ~= "" and not seen[name] then
                    seen[name] = true
                    table.insert(out, name)
                end
            end
            if listfiles then
                for _, file in ipairs(listfiles(self.Folder .. "/settings")) do
                    local name = tostring(file):match("([^/\\]+)%.json$")
                    if name then
                        add(name)
                    end
                end
                for _, file in ipairs(listfiles(self.Folder)) do
                    local name = tostring(file):match("([^/\\]+)%.json$")
                    if name and name ~= "settings" then
                        add(name)
                    end
                end
            end
            local ghostMenu = getGhostMenu(self)
            if ghostMenu and ghostMenu.cfg_location and listfiles then
                pcall(function()
                    for _, file in ipairs(listfiles(ghostMenu.cfg_location)) do
                        local name = tostring(file):match("([^/\\]+)%.json$")
                        if name then
                            add(name)
                        end
                    end
                end)
            end
            return out
        end

        function manager:Save(name)
            name = cleanConfigName(name)
            local ghostMenu = getGhostMenu(self)
            if ghostMenu and type(ghostMenu.save_cfg) == "function" then
                local ok, resultOrErr = ghostMenu.save_cfg(name)
                if ok then
                    return true, resultOrErr
                end
            end

            if type(name) ~= "string" or name:gsub("%s+", "") == "" then
                return false, "invalid config name"
            end
            ensureFolder(self.Folder)
            ensureFolder(self.Folder .. "/settings")
            local data = { Toggles = {}, Options = {} }
            for flag, object in pairs(self.Toggles or {}) do
                data.Toggles[flag] = serializeValue(object.Value)
            end
            for flag, object in pairs(self.Options or {}) do
                data.Options[flag] = serializeValue(object.Value)
            end
            local ok, encoded = pcall(function()
                return HttpService:JSONEncode(data)
            end)
            if not ok then
                return false, encoded
            end
            writefile(self.Folder .. "/settings/" .. name .. ".json", encoded)
            return true
        end

        function manager:Load(name)
            name = cleanConfigName(name)
            local ghostMenu = getGhostMenu(self)
            if ghostMenu and type(ghostMenu.load_cfg) == "function" then
                local ok, resultOrErr = ghostMenu.load_cfg(name)
                if ok then
                    return true, resultOrErr
                elseif tostring(resultOrErr) ~= "config not found" then
                    return false, resultOrErr
                end
            end

            if type(name) ~= "string" or name == "" then
                return false, "invalid config name"
            end
            local path = self.Folder .. "/settings/" .. name .. ".json"
            if not isfile or not isfile(path) then
                return false, "config not found"
            end
            local ok, decoded = pcall(function()
                return HttpService:JSONDecode(readfile(path))
            end)
            if not ok or type(decoded) ~= "table" then
                return false, decoded
            end
            for flag, value in pairs(decoded.Toggles or {}) do
                if self.Toggles[flag] and self.Toggles[flag].SetValue then
                    self.Toggles[flag]:SetValue(deserializeValue(value))
                end
            end
            for flag, value in pairs(decoded.Options or {}) do
                if self.Options[flag] and self.Options[flag].SetValue then
                    self.Options[flag]:SetValue(deserializeValue(value))
                end
            end
            return true
        end

        function manager:Delete(name)
            name = cleanConfigName(name)
            if name == "Default" then
                return false, "default config cannot be deleted"
            end
            if type(name) ~= "string" or name == "" then
                return false, "invalid config name"
            end

            if not delfile then
                return false, "delfile unavailable"
            end

            local paths = {
                self.Folder .. "/settings/" .. name .. ".json",
                self.Folder .. "/" .. name .. ".txt",
                self.Folder .. name .. ".txt",
            }
            local deleted = false
            for _, path in ipairs(paths) do
                if isfile and isfile(path) then
                    local ok, err = pcall(delfile, path)
                    if not ok then
                        return false, err
                    end
                    deleted = true
                end
            end
            if not deleted then
                return false, "config not found"
            end
            return true
        end

        function manager:LoadAutoloadConfig()
            local path = self.Folder .. "/settings/autoload.txt"
            local name
            if isfile and isfile("AutoLoadConfig") then
                name = readfile("AutoLoadConfig")
            elseif isfile and isfile(path) then
                name = readfile(path)
            end
            if name then
                local normalized_name = cleanConfigName(name)
                if normalized_name == "Default" then
                    self:Save("Default")
                    name = "Default"
                else
                    name = normalized_name
                end
                local ok, err = self:Load(name)
                if not ok and self.Library and self.Library.Notify then
                    self.Library:Notify("Config", "Failed to load autoload config: " .. tostring(err))
                end
            end
        end

        manager:SetFolder(manager.Folder)
        return manager
    end

    local function makeThemeManager()
        local manager = {
            Folder = "GHOST_HOOK",
            Library = Library,
            Options = Options,
            Toggles = Toggles,
        }

        function manager:SetOptionsTEMP(newOptions, newToggles)
            self.Options = newOptions or self.Options
            self.Toggles = newToggles or self.Toggles
        end

        function manager:SetLibrary(lib)
            self.Library = lib
        end

        function manager:SetFolder(folder)
            self.Folder = folder or self.Folder
            ensureFolder(self.Folder)
            ensureFolder(self.Folder .. "/themes")
        end

        function manager:ApplyTheme() end
        function manager:LoadDefault() end
        function manager:SaveDefault() end

        manager:SetFolder(manager.Folder)
        return manager
    end

    return Library, Toggles, Options, makeThemeManager(), makeSaveManager()
end

cheat.Library, cheat.Toggles, cheat.Options, cheat.ThemeManager, cheat.SaveManager = loadGhostHookUiStack()
Toggles = cheat.Toggles
Options = cheat.Options
if getgenv then
    getgenv().Toggles = cheat.Toggles
    getgenv().Options = cheat.Options
end
ui = {
    window = cheat.Library:CreateWindow({
        Title="GHOST_HOOK | Project Delta |",
    Center=true,AutoShow=false,TabPadding=8})
}
task.spawn(function()
    local timerText = ghostGetKeyTimerText()
    local expired = ghostFormatKeyTimeLeft() == "Expired"

    for _ = 1, 40 do
        if ghostCreateKeyStatusOverlay(timerText, expired) then
            break
        end
        task.wait(0.05)
    end
end)
if cheat.Library and cheat.Library.SetOpen then
    cheat.Library:SetOpen(false)
end
local globals = {
    fov_enabled = false,
    zoom_enabled = false,
    EnableTime = false,
    Time = 12,
    noshadows = false,
    gradientenabled = false,
}
ui.tabs = {
    combat = ui.window:AddTab('Combat'),
    visuals = ui.window:AddTab('Visuals'),
    movement = ui.window:AddTab('Movement'),
    player = ui.window:AddTab('Player'),
    world = ui.window:AddTab('World'),
    misc = ui.window:AddTab('Misc'),
    settings = ui.window:AddTab('Settings'),
}
ui.box = {
    -- Combat tab
    aimbot = ui.tabs.combat:AddLeftTabbox(),
    mods = ui.tabs.combat:AddRightTabbox(),

    -- Visuals tab
    esp = ui.tabs.visuals:AddLeftTabbox(),
    object_esp = ui.tabs.visuals:AddRightTabbox(),

    -- Movement tab
    move = ui.tabs.movement:AddLeftTabbox(),
    move_extra = ui.tabs.movement:AddRightTabbox(),

    -- Player tab
    player = ui.tabs.player:AddLeftTabbox(),
    player_extra = ui.tabs.player:AddRightTabbox(),

    -- World tab
    world = ui.tabs.world:AddLeftTabbox(),
    world_effects = ui.tabs.world:AddRightTabbox(),

    -- Misc tab
    antiaim = ui.tabs.misc:AddLeftTabbox(),
    misc = ui.tabs.misc:AddRightTabbox(),

    -- Settings tab
    config = ui.tabs.settings:AddLeftGroupbox('Config'),
    client = ui.tabs.settings:AddLeftGroupbox('Client'),
    crosshair = ui.tabs.settings:AddLeftTabbox(),
    script = ui.tabs.settings:AddRightGroupbox('Script Control'),
    themes = ui.tabs.settings:AddRightGroupbox('Themes'),
    keybinds = ui.tabs.settings:AddRightGroupbox('Key Binds'),
    detection = ui.tabs.settings:AddRightGroupbox('Detection'),
    npc = ui.tabs.settings:AddRightGroupbox('Npc'),
}
local player_viewmodel_tab = ui.box.player:AddTab("ViewModel")
local player_anti_aim_tab = ui.box.player:AddTab("Anti Aim")
local player_camera_tab = ui.box.player_extra:AddTab("Camera")
local player_fake_lag_tab = ui.box.player_extra:AddTab("Fake Lag")
local world_radar_tab = ui.box.world_effects:AddTab("Radar")
local world_thirdperson_tab = ui.box.world_effects:AddTab("Third Person")
local world_performance_tab = ui.box.world_effects:AddTab("Performance")
local world_inventory_tab = ui.box.world_effects:AddTab("Inventory / Finder")
local world_freecam_tab = ui.box.world:AddTab("Freecam")
local custom_sound_tab = ui.box.misc:AddTab("Custom Hit/Shoot Sounds")
local settings_skinchanger_box = ui.tabs.settings:AddRightGroupbox('Skin Changer')
local function keybind_allows(key_flag)
    local option = cheat.Options and cheat.Options[key_flag]
    if not option then return true end

    local value = option.Value
    local key = option.Key
    local mode = option.Mode
    local active = option.State
    if type(value) == "table" then
        key = value.Key or key
        mode = value.Type or value.Mode or mode
        active = value.Active ~= nil and value.Active or active
    end

    key = tostring(key or "None")
    if key == "" or key == "None" or key == "NONE" then
        return true
    end

    return mode == "Always" or active == true
end

local function keybind_is_always(key_flag)
    local option = cheat.Options and cheat.Options[key_flag]
    if not option then return false end

    local value = option.Value
    local mode = option.Mode
    if type(value) == "table" then
        mode = value.Type or value.Mode or mode
    end

    return mode == "Always"
end

local function feature_active(enabled, key_flag, allow_always_without_toggle)
    local master_enabled = enabled or (allow_always_without_toggle and keybind_is_always(key_flag))
    return master_enabled and keybind_allows(key_flag)
end

cheat.utility.create_keybind_indicator = function()
    if cheat.keybind_indicator then return cheat.keybind_indicator end

    local indicator = {
        max_rows = 16,
        pos = _Vector2new(30, 40),
        width = 235,
        height = 24,
        dragging = false,
        dragoffset = _Vector2new(0, 0),
    }
    indicator.bg = cheat.utility.new_drawing("Square", {
        Visible = false,
        Filled = true,
        Color = Color3.fromRGB(0, 0, 0),
        Transparency = 0.72,
        ZIndex = 200,
    })
    indicator.border = cheat.utility.new_drawing("Square", {
        Visible = false,
        Filled = false,
        Color = Color3.fromRGB(75, 75, 75),
        Thickness = 1,
        Transparency = 1,
        ZIndex = 201,
    })
    indicator.title = cheat.utility.new_drawing("Text", {
        Visible = false,
        Text = "Keybinds",
        Size = 15,
        Font = Drawing.Fonts.Monospace,
        Color = Color3.fromRGB(255, 255, 255),
        Outline = true,
        ZIndex = 202,
    })
    indicator.rows = {}
    for i = 1, indicator.max_rows do
        indicator.rows[i] = cheat.utility.new_drawing("Text", {
            Visible = false,
            Text = "",
            Size = 14,
            Font = Drawing.Fonts.Monospace,
            Color = Color3.fromRGB(210, 210, 210),
            Outline = true,
            ZIndex = 202,
        })
    end

    local function format_keybind_key(key)
        key = tostring(key or "None")
        key = key:gsub("^Enum%.KeyCode%.", "")
        key = key:gsub("^Enum%.UserInputType%.", "")
        key = key:gsub("^MouseButton(%d+)$", "MB%1")
        return key
    end

    cheat.utility.new_renderstepped(function()
        local visible = cheat.keybind_indicator_enabled and not cheat.unloaded
        if not visible then
            if indicator.bg.Visible then indicator.bg.Visible = false end
            if indicator.border.Visible then indicator.border.Visible = false end
            if indicator.title.Visible then indicator.title.Visible = false end
            for i = 1, indicator.max_rows do
                if indicator.rows[i].Visible then
                    indicator.rows[i].Visible = false
                end
            end
            indicator.dragging = false
            return
        end

        local entries = {}
        local widest = 0
        for flag, option in pairs(cheat.Options or {}) do
            if option and option._kind == "Keybind" then
                local value = option.Value
                local key = option.Key
                local mode = option.Mode
                local active = option.State
                if type(value) == "table" then
                    key = value.Key or key
                    mode = value.Type or mode
                    active = value.Active ~= nil and value.Active or active
                end
                if mode == "Always" then
                    active = true
                end
                key = tostring(key or "None")
                if key ~= "" and key ~= "None" and key ~= "NONE" then
                    local label = option.Text or option._flag or flag
                    local formatted_key = format_keybind_key(key)
                    local state_text = active and "on" or tostring(mode or "Hold")
                    local text = tostring(label) .. " [" .. formatted_key .. "] - " .. state_text
                    widest = math.max(widest, #text)
                    table.insert(entries, {
                        text = text,
                        active = active and true or false,
                    })
                end
            end
        end
        table.sort(entries, function(a, b) return a.text < b.text end)

        local count = math.min(#entries, indicator.max_rows)
        local row_height = 16
        local height = 24 + (count * row_height)
        local width = math.max(indicator.width, 16 + (widest * 8))
        indicator.height = height

        if visible and cheat.Library.Opened then
            local mousepos = _Vector2new(Mouse.X, Mouse.Y + GuiInset.Y)
            local in_bounds = mousepos.X >= indicator.pos.X
                and mousepos.X <= indicator.pos.X + width
                and mousepos.Y >= indicator.pos.Y
                and mousepos.Y <= indicator.pos.Y + height
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                if in_bounds or indicator.dragging then
                    if not indicator.dragging then
                        indicator.dragging = true
                        indicator.dragoffset = indicator.pos - mousepos
                    end
                    indicator.pos = mousepos + indicator.dragoffset
                end
            else
                indicator.dragging = false
            end
        else
            indicator.dragging = false
        end

        indicator.bg.Visible = visible
        indicator.border.Visible = visible
        indicator.title.Visible = visible
        indicator.bg.Position = indicator.pos
        indicator.bg.Size = _Vector2new(width, height)
        indicator.border.Position = indicator.pos
        indicator.border.Size = _Vector2new(width, height)
        indicator.title.Position = indicator.pos + _Vector2new(8, 4)
        for i = 1, indicator.max_rows do
            local row = indicator.rows[i]
            local entry = entries[i]
            row.Visible = visible and entry ~= nil
            if entry then
                row.Text = entry.text
                row.Color = entry.active and Color3.fromRGB(150, 255, 150) or Color3.fromRGB(210, 210, 210)
                row.Position = indicator.pos + _Vector2new(8, 20 + (i - 1) * row_height)
            end
        end
    end)

    cheat.keybind_indicator = indicator
    return indicator
end
cheat.EspLibrary = {} LPH_NO_VIRTUALIZE(function()
    local esp_table = {}
    local workspace = cloneref(Workspace)
    local rservice = cloneref(RunService)
    local plrs = cloneref(Players)
    local lplr = plrs.LocalPlayer
    local success, coregui = pcall(game.GetService, game, "CoreGui")
    local container = cheat.utility.track_instance(Instance.new("Folder", (success and coregui:FindFirstChild("RobloxGui")) or lplr:WaitForChild("PlayerGui")))
    esp_table = {
        __loaded = false,
        main_settings = {
            textSize = 15,
            textFont = Drawing.Fonts.Monospace,
            distancelimit = false,
            maxdistance = 5000,
            fadetime = 1,
            infiniterange = false
        },
        main_object_settings = {
            textSize = 15,
            textFont = Drawing.Fonts.Monospace,
            distancelimit = false,
            maxdistance = 200,
            useteamcolor = false,
            teamcheck = false,
            sleepcheck = false,
            allowed = {}
        },
        settings = {
            enemy = {
                enabled = false,
                box = false,
                box_fill = false,
                realname = false,
                displayname = false,
                health = false,
                dist = false,
                weapon = false,
                skeleton = false,
                box_outline = false,
                realname_outline = false,
                displayname_outline = false,
                health_outline = false,
                dist_outline = false,
                weapon_outline = false,
                box_color = { Color3.new(1, 1, 1), 1 },
                box_fill_color = { Color3.new(1, 0, 0), 0.5 },
                realname_color = { Color3.new(1, 1, 1), 1 },
                displayname_color = { Color3.new(1, 1, 1), 1 },
                health_color = { Color3.new(1, 1, 1), 1 },
                dist_color = { Color3.new(1, 1, 1), 1 },
                weapon_color = { Color3.new(1, 1, 1), 1 },
                skeleton_color = { Color3.new(1, 1, 1), 1 },
                box_outline_color = { Color3.new(), 1 },
                realname_outline_color = Color3.new(),
                displayname_outline_color = Color3.new(),
                health_color_top = Color3.new(0, 1, 0),
                health_color_bottom = Color3.new(1, 0, 0),
                health_thickness = 2,
                health_glow_size = 5,
                dist_outline_color = Color3.new(),
                weapon_outline_color = Color3.new(),
                box_outline_vis = false,
                realname_outline_vis = false,
                displayname_outline_vis = false,
                dist_outline_vis = false,
                weapon_outline_vis = false,
                box_outline_vis_color = { Color3.new(), 1 },
                realname_outline_vis_color = Color3.new(),
                displayname_outline_vis_color = Color3.new(),
                dist_outline_vis_color = Color3.new(),
                weapon_outline_vis_color = Color3.new(),
                chams = false,
                chams_visible_only = false,
                chams_hidden = true,
                chams_visible = false,
                cham_color = Color3.fromRGB(255, 255, 255),
                cham_transparency = 0.5,
                chams_fill_color = { Color3.new(1, 1, 1), 0.5 },
                chams_visible_color = { Color3.new(1, 1, 1), 0.5 },
                chams_hidden_color = { Color3.new(1, 1, 1), 0.5 },
                high_kd_marker = false,
                high_kd_outline_color = Color3.fromRGB(255, 0, 0),
                high_kd_chams_transparency = 0.15,
            },
            corpse = {
                enabled = false,
                name = true,
                distance = false,
                color = Color3.fromRGB(0, 255, 0),
                outline = false,
                outline_color = Color3.new()
            }
        }
    }
    local loaded_plrs = {}
    local camera = workspace.CurrentCamera
    local viewportsize = camera.ViewportSize
    local VERTICES = {
        _Vector3new(-1, -1, -1),
        _Vector3new(-1, 1, -1),
        _Vector3new(-1, 1, 1),
        _Vector3new(-1, -1, 1),
        _Vector3new(1, -1, -1),
        _Vector3new(1, 1, -1),
        _Vector3new(1, 1, 1),
        _Vector3new(1, -1, 1)
    }
    local skeleton_order = {
        ["LeftFoot"] = "LeftLowerLeg",
        ["LeftLowerLeg"] = "LeftUpperLeg",
        ["LeftUpperLeg"] = "LowerTorso",
        ["RightFoot"] = "RightLowerLeg",
        ["RightLowerLeg"] = "RightUpperLeg",
        ["RightUpperLeg"] = "LowerTorso",
        ["LeftHand"] = "LeftLowerArm",
        ["LeftLowerArm"] = "LeftUpperArm",
        ["LeftUpperArm"] = "UpperTorso",
        ["RightHand"] = "RightLowerArm",
        ["RightLowerArm"] = "RightUpperArm",
        ["RightUpperArm"] = "UpperTorso",
        ["LowerTorso"] = "UpperTorso",
        ["UpperTorso"] = "Head"
    }
    local esp = {}
    esp.create_obj = function(type, args)
        local obj = Drawing.new(type)
        for i, v in args do
            obj[i] = v
        end
        return obj
    end
    local function isBodyPart(name)
        return name == "Head" or name:find("Torso") or name:find("Leg") or name:find("Arm") or name:find("Mi24") or name:find("Prop_") or name:find("Hull") or name:find("BTR") or name:find("Pilot")
    end
    local function getBoundingBox(parts)
        local min, max
        for i = 1, #parts do
            local part = parts[i]
            local cframe, size = part.CFrame, part.Size
            min = _Vector3zeromin(min or cframe.Position, (cframe - size * 0.5).Position)
            max = _Vector3zeromax(max or cframe.Position, (cframe + size * 0.5).Position)
        end
        local center = (min + max) * 0.5
        local front = _Vector3new(center.X, center.Y, max.Z)
        return _CFramenew(center, front), max - min
    end
    local function worldToScreen(world)
        local screen, inBounds = _WorldToViewportPoint(camera, world)
        return _Vector2new(screen.X, screen.Y), inBounds, screen.Z
    end
    local function calculateCorners(cframe, size)
        local corners = table.create(#VERTICES)
        for i = 1, #VERTICES do
            corners[i] = worldToScreen((cframe + size * 0.5 * VERTICES[i]).Position)
        end
        local min = _Vector2zeromin(camera.ViewportSize, unpack(corners))
        local max = _Vector2zeromax(Vector2.zero, unpack(corners))
        return {
            corners = corners,
            topLeft = _Vector2new(mathfloor(min.X), mathfloor(min.Y)),
            topRight = _Vector2new(mathfloor(max.X), mathfloor(min.Y)),
            bottomLeft = _Vector2new(mathfloor(min.X), mathfloor(max.Y)),
            bottomRight = _Vector2new(mathfloor(max.X), mathfloor(max.Y))
        }
    end
    local get_mainpart = function(model, modelname)
        if modelname == "corpse" then
            return _FindFirstChild(model, "UpperTorso")
        end
    end
    local identify_model = function(model, modelname)
        if not model then return false, false end
        if modelname == "corpse" and _FindFirstChildOfClass(model, "Humanoid") then
            return model.Name.."'s corpse"
        end
        return false, false
    end
    local ghost_chams_template = Instance.new("Highlight")
    local function remove_ghost_player_chams(character)
        if not character then return end
        local visible = character:FindFirstChild("HighlightVisible")
        local hidden = character:FindFirstChild("HighlightHidden")
        if visible then visible:Destroy() end
        if hidden then hidden:Destroy() end
    end
    function esp_table.update_player_chams(player, enabled)
        if not player then return end
        if typeof(player) ~= "Instance" then return end

        local character
        if player:IsA("Player") then
            if player == lplr then return end
            character = player.Character
        elseif player:IsA("Model") then
            if player.Name == "MI24V" then return end
            local dropped = workspace:FindFirstChild("DroppedItems")
            if dropped and player:IsDescendantOf(dropped) then
                remove_ghost_player_chams(player)
                return
            end
            character = player
        else
            return
        end
        if not character then return end

        local settings = esp_table.settings.enemy
        if not (enabled and settings.enabled and settings.chams) then
            remove_ghost_player_chams(character)
            return
        end

        local plr_state = loaded_plrs[player]
        local high_kd_chams = settings.high_kd_marker and plr_state and plr_state._kd_is_cheater
        local cham_color = high_kd_chams and settings.high_kd_outline_color or settings.cham_color or (settings.chams_hidden_color and settings.chams_hidden_color[1]) or Color3.new(1, 1, 1)
        local cham_transparency = settings.cham_transparency
        if cham_transparency == nil then
            cham_transparency = 0.5
        end
        if high_kd_chams then
            cham_transparency = settings.high_kd_chams_transparency or cham_transparency
        end

        local visible = character:FindFirstChild("HighlightVisible")
        if settings.chams_visible then
            if not visible then
                visible = ghost_chams_template:Clone()
                visible.Name = "HighlightVisible"
                visible.Parent = character
            end
            visible.FillColor = cham_color
            visible.OutlineColor = cham_color
            visible.FillTransparency = cham_transparency
            visible.OutlineTransparency = 0
            visible.DepthMode = Enum.HighlightDepthMode.Occluded
        elseif visible then
            visible:Destroy()
        end

        local hidden = character:FindFirstChild("HighlightHidden")
        if settings.chams_hidden then
            if not hidden then
                hidden = ghost_chams_template:Clone()
                hidden.Name = "HighlightHidden"
                hidden.Parent = character
            end
            hidden.FillColor = cham_color
            hidden.OutlineColor = cham_color
            hidden.FillTransparency = cham_transparency
            hidden.OutlineTransparency = 0
            hidden.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        elseif hidden then
            hidden:Destroy()
        end
    end
    local function create_esp(player, isnpc)
        if not player then return end
        if player.ClassName == "Model" then isnpc = true end
        loaded_plrs[player] = {
            obj = {
                box_fill = esp.create_obj("Square", { Filled = true, Visible = false }),
                box_outline = esp.create_obj("Square", { Filled = false, Thickness = 3, Visible = false, ZIndex = -1 }),
                box = esp.create_obj("Square", { Filled = false, Thickness = 1, Visible = false }),
                realname = esp.create_obj("Text", { Center = true, Visible = false, Text = player.Name }),
                displayname = esp.create_obj("Text", { Center = true, Visible = false, Text = isnpc and "" or player.Name == player.DisplayName and "" or player.DisplayName }),
                healthtext = esp.create_obj("Text", { Center = false, Visible = false }),
                health_bar_cap_top = esp.create_obj("Circle", { Visible = false, Filled = true, ZIndex = 2 }),
                health_bar_cap_bottom = esp.create_obj("Circle", { Visible = false, Filled = true, ZIndex = 2 }),
                dist = esp.create_obj("Text", { Center = true, Visible = false }),
                weapon = esp.create_obj("Text", { Center = true, Visible = false }),
            },
            plr_instance = player
        }
        for required, _ in next, skeleton_order do
            loaded_plrs[player].obj["skeleton_" .. required] = esp.create_obj("Line", { Visible = false })
        end
        for i = 1, 10 do
            loaded_plrs[player].obj["health_bar_" .. i] = esp.create_obj("Line", { Visible = false, Thickness = 2, ZIndex = 2 })
        end
        for i = 1, 6 do
            loaded_plrs[player].obj["health_bar_glow_" .. i] = esp.create_obj("Line", { Visible = false, ZIndex = 1 })
            loaded_plrs[player].obj["health_bar_glow_cap_top_" .. i] = esp.create_obj("Circle", { Visible = false, Filled = true, ZIndex = 1 })
            loaded_plrs[player].obj["health_bar_glow_cap_bottom_" .. i] = esp.create_obj("Circle", { Visible = false, Filled = true, ZIndex = 1 })
        end
        local plr = loaded_plrs[player]
        local obj = plr.obj
        local esp = plr.esp
        local box = obj.box
        local box_outline = obj.box_outline
        local box_fill = obj.box_fill
        local healthtext = obj.healthtext
        local realname = obj.realname
        local displayname = obj.displayname
        local dist = obj.dist
        local weapon = obj.weapon
        local settings = esp_table.settings.enemy
        local main_settings = esp_table.main_settings
        local character = isnpc and player or not isnpc and player.Character
        local head = character and _FindFirstChild(character, "Head")
        local humanoid = character and _FindFirstChildOfClass(character, "Humanoid")
        local setvis_cache = false
        local fadetime = main_settings.fadetime
        local fadethread
        function plr:forceupdate()
            fadetime = main_settings.fadetime
            esp_table.update_player_chams(player, settings.enabled and settings.chams)
            box.Color = settings.box_color[1]
            box_outline.Color = settings.box_outline_color[1]
            box_fill.Color = settings.box_fill_color[1]
            realname.Size = main_settings.textSize
            realname.Font = main_settings.textFont
            realname.Color = settings.realname_color[1]
            realname.Outline = settings.realname_outline
            realname.OutlineColor = settings.realname_outline_color
            displayname.Size = main_settings.textSize
            displayname.Font = main_settings.textFont
            displayname.Color = settings.displayname_color[1]
            displayname.Outline = settings.displayname_outline
            displayname.OutlineColor = settings.displayname_outline_color
            dist.Size = main_settings.textSize
            dist.Font = main_settings.textFont
            dist.Color = settings.dist_color[1]
            dist.Outline = settings.dist_outline
            dist.OutlineColor = settings.dist_outline_color
            weapon.Size = main_settings.textSize
            weapon.Font = main_settings.textFont
            weapon.Color = settings.weapon_color[1]
            weapon.Outline = settings.weapon_outline
            weapon.OutlineColor = settings.weapon_outline_color
            for required, _ in next, skeleton_order do
                local skeletonobj = obj["skeleton_" .. required]
                if skeletonobj then
                    skeletonobj.Color = settings.skeleton_color[1]
                end
            end
            box.Transparency = settings.box_color[2]
            box_outline.Transparency = settings.box_outline_color[2]
            box_fill.Transparency = settings.box_fill_color[2]
            realname.Transparency = settings.realname_color[2]
            displayname.Transparency = settings.displayname_color[2]
            dist.Transparency = settings.dist_color[2]
            weapon.Transparency = settings.weapon_color[2]
            for required, _ in next, skeleton_order do
                obj["skeleton_" .. required].Transparency = settings.skeleton_color[2]
            end

            for i = 1, 10 do
                if obj["health_bar_"..i] then
                    obj["health_bar_"..i].Thickness = settings.health_thickness
                end
            end
            if setvis_cache then
                esp_table.update_player_chams(player, true)
                box.Visible = false
                box_outline.Visible = false
                box_fill.Visible = false
                realname.Visible = settings.realname
                displayname.Visible = settings.displayname
                obj.health_bar_cap_top.Visible = settings.health
                obj.health_bar_cap_bottom.Visible = settings.health
                for i = 1, 6 do
                    if obj["health_bar_glow_"..i] then 
                        obj["health_bar_glow_"..i].Visible = settings.health
                        obj["health_bar_glow_cap_top_"..i].Visible = settings.health
                        obj["health_bar_glow_cap_bottom_"..i].Visible = settings.health
                    end
                end
                for i = 1, 10 do
                    if obj["health_bar_"..i] then
                        obj["health_bar_"..i].Visible = settings.health
                    end
                end
                dist.Visible = settings.dist
                weapon.Visible = settings.weapon
                for required, _ in next, skeleton_order do
                    local skeletonobj = obj["skeleton_" .. required]
                    if (skeletonobj) then
                        skeletonobj.Visible = settings.skeleton
                    end
                end
            end
        end
        function plr:togglevis(bool, fade)
            if setvis_cache ~= bool then
                setvis_cache = bool
                if not bool then
                        for _, v in obj do v.Visible = false end
                else
                    esp_table.update_player_chams(player, true)
                    box.Visible = false
                    box_outline.Visible = false
                    box_fill.Visible = false
                    realname.Visible = settings.realname
                    displayname.Visible = settings.displayname
                    healthtext.Visible = false -- disabled for neon bar
                    obj.health_bar_cap_top.Visible = settings.health
                    obj.health_bar_cap_bottom.Visible = settings.health
                    for i = 1, 6 do
                        if obj["health_bar_glow_"..i] then 
                            obj["health_bar_glow_"..i].Visible = settings.health
                            obj["health_bar_glow_cap_top_"..i].Visible = settings.health
                            obj["health_bar_glow_cap_bottom_"..i].Visible = settings.health
                        end
                    end
                    for i = 1, 10 do
                        obj["health_bar_"..i].Visible = settings.health
                    end
                    dist.Visible = settings.dist
                    weapon.Visible = settings.weapon
                    for required, _ in next, skeleton_order do
                        local skeletonobj = obj["skeleton_" .. required]
                        if (skeletonobj) then
                            skeletonobj.Visible = settings.skeleton
                        end
                    end
                end
            end
        end
        plr.connection = cheat.utility.new_renderstepped(function(delta)
            local plr = loaded_plrs[player]
            if not settings.enabled then
                esp_table.update_player_chams(player, false)
                return plr:togglevis(false)
            end
            character = isnpc and player or not isnpc and player.Character
            humanoid = character and _FindFirstChildOfClass(character, "Humanoid")
            head = character and _FindFirstChild(character, "Head")
            
            local is_heli = isnpc and (character.Name == "MI24V" or character.Name == "BTR80")
            if is_heli then
                local pilots = _FindFirstChild(character, "Pilots")
                head = character:FindFirstChild("CollisionPilot", true) or character:FindFirstChild("Mi24_Prop_M", true)
                humanoid = humanoid or { Health = character:GetAttribute("Health") or 1000, MaxHealth = 1000, Parent = character }
            end

            local dropped_folder = workspace:FindFirstChild("DroppedItems")
            if dropped_folder and character and character:IsDescendantOf(dropped_folder) then
                esp_table.update_player_chams(player, false)
                return plr:togglevis(false)
            end
            
            if not (character and head and humanoid and character.Parent and (head.Parent or is_heli) and (humanoid.Parent or is_heli)) then
                esp_table.update_player_chams(player, false)
                if main_settings.infiniterange and not isnpc then
                    local res = (function()
                        local rp_plr = _FindFirstChild(ReplicatedStorage.Players, player.Name)
                        local plrstatus = rp_plr and _FindFirstChild(rp_plr, "Status")
                        local worldpos = plrstatus and _FindFirstChild(plrstatus, "UAC") and _FindFirstChild(plrstatus, "UAC"):GetAttribute("LastVerifiedPos")
                        local screenpos, onscreen = typeof(worldpos) == "Vector3" and worldToScreen(worldpos)
                        if not (onscreen) then return false end
                        realname.Position = screenpos
                        realname.Text = player.Name .. " ["..mathround((worldpos - camera.CFrame.p).Magnitude / 3).."]"
                        return true
                    end)();
                    plr:togglevis(false)
                    realname.Visible = res
                    return
                else
                    realname.Visible = false
                    return plr:togglevis(false)
                end
            end
            local _, onScreen = _WorldToViewportPoint(camera, head.Position)
            if not onScreen then
                esp_table.update_player_chams(player, true)
                return plr:togglevis(false)
            end
            local humanoid_distance = (camera.CFrame.p - head.Position).Magnitude
            if main_settings.distancelimit and humanoid_distance > main_settings.maxdistance then
                esp_table.update_player_chams(player, true)
                return plr:togglevis(false)
            end
            local frame_now = os.clock()
            local update_interval = settings.skeleton and (1 / 30) or (humanoid_distance < 300 and (1 / 45) or humanoid_distance < 900 and (1 / 24) or (1 / 15))
            if plr._next_esp_update and frame_now < plr._next_esp_update then
                return
            end
            plr._next_esp_update = frame_now + update_interval
            local humanoid_health = humanoid.Health
            
            if plr.last_health and humanoid_health < plr.last_health then
                local hitmarker_recent = cheat.utility.last_hitmarker_tick and (tick() - cheat.utility.last_hitmarker_tick < 0.25)
                if hitmarker_recent and cheat.Toggles.killeffect and cheat.Toggles.killeffect.Value then
                    cheat.utility.spawn_kill_effect(head.Position)
                end
            end
            plr.last_health = humanoid_health
            
            if humanoid_health <= 0 then
                if not plr.was_dead then
                    plr.was_dead = true
                end
                esp_table.update_player_chams(player, false)
                return plr:togglevis(false)
            else
                plr.was_dead = false
            end
            local humanoid_max_health = humanoid.MaxHealth
            local corners do
                if plr.last_character ~= character then
                    if plr.last_character then
                        remove_ghost_player_chams(plr.last_character)
                    end
                    plr.last_character = character
                    plr.body_parts = {}
                    plr._skel_parts = nil
                    remove_ghost_player_chams(character)
                    local check_descendants = isnpc and (character.Name == "MI24V" or character.Name == "BTR80")
                    local parts_to_check = check_descendants and character:GetDescendants() or character:GetChildren()
                    for _, part in parts_to_check do
                        if _IsA(part, "BasePart") and isBodyPart(part.Name) then
                            plr.body_parts[#plr.body_parts + 1] = part
                        end
                    end
                end
                local cache = plr.body_parts
                if not cache or #cache <= 0 then
                    esp_table.update_player_chams(player, false)
                    return plr:togglevis(false)
                end
                corners = calculateCorners(getBoundingBox(cache))
            end
            plr:togglevis(true)
            
            local is_vis = false
            if settings.box_outline_vis or settings.realname_outline_vis or settings.displayname_outline_vis or settings.dist_outline_vis or settings.weapon_outline_vis then
                if not plr.last_vis_check or (os.clock() - plr.last_vis_check) > 0.15 then
                    plr.last_vis_check = os.clock()
                    plr.is_vis_cached = cheat.utility.is_visible(camera.CFrame, character, head)
                end
                is_vis = plr.is_vis_cached or false
            end
            do
                local is_cheater = false
                if not isnpc and settings.high_kd_marker then
                    if not plr._kd_cached_time or (os.clock() - plr._kd_cached_time) > 2 then
                        plr._kd_cached_time = os.clock()
                        local pfolder = ReplicatedStorage:FindFirstChild("Players") and ReplicatedStorage.Players:FindFirstChild(player.Name)
                        local stats_obj = pfolder and (pfolder:FindFirstChild("WipeStatistics", true) or pfolder:FindFirstChild("Statistics", true))
                        if stats_obj then
                            local kills = stats_obj:GetAttribute("Kills") or 0
                            local deaths = stats_obj:GetAttribute("Deaths") or 0
                            local ratio = kills / math.max(1, deaths)
                            plr._kd_is_cheater = ratio > 5
                        else
                            plr._kd_is_cheater = false
                        end
                    end
                    is_cheater = plr._kd_is_cheater or false
                end

                local pos = corners.topLeft
                local size = corners.bottomRight - corners.topLeft
                box.Position = pos
                box.Size = size
                local drawingFix = getgenv().DrawingFix
                if drawingFix then
                    box_outline.Position = pos - _Vector2new(1, 1)
                    box_outline.Size = size + _Vector2new(2, 2)
                else
                    box_outline.Position = pos
                    box_outline.Size = size
                end
                box_fill.Position = pos
                box_fill.Size = size
                if settings.box_outline_vis and is_vis then
                    box_outline.Color = settings.box_outline_vis_color[1]
                    box_outline.Transparency = settings.box_outline_vis_color[2]
                else
                    box_outline.Color = settings.box_outline_color[1]
                    box_outline.Transparency = settings.box_outline_color[2]
                end
            end
            do
                local min_healthbar_height = 5
                local healthbar_top_y = corners.topLeft.Y
                if (corners.bottomLeft.Y - corners.topLeft.Y) < min_healthbar_height then
                    healthbar_top_y = corners.bottomLeft.Y - min_healthbar_height
                end
                local top_text_y = math.min(corners.topLeft.Y, healthbar_top_y)
                
                local pos = _Vector2new((corners.topLeft.X + corners.topRight.X) * 0.5, top_text_y) - Vector2.yAxis
                realname.Position = pos - (Vector2.yAxis * realname.TextBounds.Y) - _Vector2new(0, 2)
                displayname.Position = pos - Vector2.yAxis * displayname.TextBounds.Y - (realname.Visible and Vector2.yAxis * realname.TextBounds.Y or Vector2.zero)
                
                local name_str = player.Name
                if not isnpc and settings.high_kd_marker and loaded_plrs[player]._kd_is_cheater then
                    name_str = "[CHEATER] " .. name_str
                end
                realname.Text = name_str
                
                if settings.realname_outline_vis and is_vis then
                    realname.OutlineColor = settings.realname_outline_vis_color
                else
                    realname.OutlineColor = settings.realname_outline_color
                end
                if settings.displayname_outline_vis and is_vis then
                    displayname.OutlineColor = settings.displayname_outline_vis_color
                else
                    displayname.OutlineColor = settings.displayname_outline_color
                end
            end
            do
                local pos = (corners.bottomLeft + corners.bottomRight) * 0.5
                dist.Text = mathround(humanoid_distance / 3) .. " meters"
                dist.Position = pos
                if not plr._gun_cache_time or (os.clock() - plr._gun_cache_time) > 0.5 then
                    plr._gun_cache_time = os.clock()
                    plr._gun_cache_text = isnpc and "" or esp_table.get_gun(player)
                end
                weapon.Text = plr._gun_cache_text or ""
                weapon.Position = pos + (dist.Visible and Vector2.yAxis * dist.TextBounds.Y - _Vector2new(0, 2) or Vector2.zero)
                
                if settings.dist_outline_vis and is_vis then
                    dist.OutlineColor = settings.dist_outline_vis_color
                else
                    dist.OutlineColor = settings.dist_outline_color
                end
                if settings.weapon_outline_vis and is_vis then
                    weapon.OutlineColor = settings.weapon_outline_vis_color
                else
                    weapon.OutlineColor = settings.weapon_outline_color
                end
            end
            -- Neon Gradient Health Bar
            healthtext.Visible = false
            local h_percent = math.clamp(humanoid_health / humanoid_max_health, 0, 1)
            local bar_start = corners.bottomLeft - _Vector2new(6, 0)
            local bar_end = corners.topLeft - _Vector2new(6, 0)
            
            local min_healthbar_height = 5
            if (bar_start.Y - bar_end.Y) < min_healthbar_height then
                bar_end = bar_start - _Vector2new(0, min_healthbar_height)
            end
            
            local glow_color = settings.health_color_top:Lerp(settings.health_color_bottom, 0.5)
            
            for i = 1, 6 do
                local glow = obj["health_bar_glow_"..i]
                local cap_top = obj["health_bar_glow_cap_top_"..i]
                local cap_bottom = obj["health_bar_glow_cap_bottom_"..i]
                
                if settings.health and h_percent > 0 then
                    local th = (i / 6) * settings.health_glow_size
                    local tr = 0.3 - (i * 0.04)
                    
                    glow.Visible = true
                    glow.From = bar_start
                    glow.To = bar_start:Lerp(bar_end, h_percent)
                    glow.Color = glow_color
                    glow.Thickness = th
                    glow.Transparency = tr
                    
                    cap_top.Visible = true
                    cap_top.Position = bar_start:Lerp(bar_end, h_percent)
                    cap_top.Color = glow_color
                    cap_top.Radius = th / 2
                    cap_top.Transparency = tr
                    
                    cap_bottom.Visible = true
                    cap_bottom.Position = bar_start
                    cap_bottom.Color = glow_color
                    cap_bottom.Radius = th / 2
                    cap_bottom.Transparency = tr
                else
                    glow.Visible = false
                    cap_top.Visible = false
                    cap_bottom.Visible = false
                end
            end
            
            if settings.health and h_percent > 0 then
                obj.health_bar_cap_top.Visible = true
                obj.health_bar_cap_top.Position = bar_start:Lerp(bar_end, h_percent)
                obj.health_bar_cap_top.Color = settings.health_color_top:Lerp(settings.health_color_bottom, 1 - h_percent)
                obj.health_bar_cap_top.Radius = settings.health_thickness / 2

                obj.health_bar_cap_bottom.Visible = true
                obj.health_bar_cap_bottom.Position = bar_start
                obj.health_bar_cap_bottom.Color = settings.health_color_bottom
                obj.health_bar_cap_bottom.Radius = settings.health_thickness / 2
            else
                obj.health_bar_cap_top.Visible = false
                obj.health_bar_cap_bottom.Visible = false
            end
            
            for i = 1, 10 do
                local seg_line = obj["health_bar_"..i]
                if settings.health and i <= math.ceil(h_percent * 10) then
                    seg_line.Visible = true
                    local seg_start = bar_start:Lerp(bar_end, (i - 1) / 10)
                    local seg_end = bar_start:Lerp(bar_end, i / 10)
                    if i == math.ceil(h_percent * 10) then
                        seg_end = bar_start:Lerp(bar_end, h_percent)
                    end
                    seg_line.From = seg_start
                    seg_line.To = seg_end
                    local col_percent = 1 - (i / 10)
                    seg_line.Color = settings.health_color_top:Lerp(settings.health_color_bottom, col_percent)
                else
                    seg_line.Visible = false
                end
            end
            if settings.skeleton then
                if not plr._skel_parts then
                    plr._skel_parts = {}
                    for _, part in next, character:GetChildren() do
                        local parent_name = skeleton_order[part.Name]
                        if parent_name then
                            local parent_instance = _FindFirstChild(character, parent_name)
                            local line = obj["skeleton_" .. part.Name]
                            if parent_instance and line then
                                plr._skel_parts[#plr._skel_parts + 1] = { part = part, parent = parent_instance, line = line }
                            end
                        end
                    end
                end
                for i = 1, #plr._skel_parts do
                    local entry = plr._skel_parts[i]
                    if entry.part.Parent and entry.parent.Parent then
                        local part_position = _WorldToViewportPoint(camera, entry.part.Position)
                        local parent_part_position = _WorldToViewportPoint(camera, entry.parent.Position)
                        entry.line.From = _Vector2new(part_position.X, part_position.Y)
                        entry.line.To = _Vector2new(parent_part_position.X, parent_part_position.Y)
                    end
                end
            end
            esp_table.update_player_chams(player, true)
        end)
        plr:forceupdate()
    end
    local function create_object_esp(model, modelname)
        if not model then return end
        local espname = identify_model(model, modelname)
        if not (espname) then return end
        loaded_plrs[model] = {
            obj = {
                name = esp.create_obj("Text", { Center = true, Visible = false, Text = espname }),
            }
        }
        local plr = loaded_plrs[model]
        local obj = plr.obj
        local realname = obj.name
        
        local main_settings = esp_table.main_settings
        local enemy_settings = esp_table.settings.enemy
        local corpse_settings = esp_table.settings.corpse
        
        local setvis_cache = false
        function plr:forceupdate()
            realname.Size = main_settings.textSize
            realname.Font = main_settings.textFont
            realname.Color = corpse_settings.color
            realname.Outline = corpse_settings.outline
            realname.OutlineColor = corpse_settings.outline_color
            realname.Transparency = 1
        end
        function plr:togglevis(bool)
            if setvis_cache ~= bool then
                for _, v in obj do v.Visible = bool end
                setvis_cache = bool
            end
        end
        plr.connection = cheat.utility.new_heartbeat(function(delta)
            local plr = loaded_plrs[model]
            if not corpse_settings.enabled then
                return plr:togglevis(false)
            end
            
            local mainpart = get_mainpart(model, modelname)
            local worldPos = mainpart and mainpart.Position or model:GetPivot().Position
            local position, onscreen = worldToScreen(worldPos)
            if not onscreen then
                return plr:togglevis(false)
            end
            local now = os.clock()
            if plr._next_object_esp_update and now < plr._next_object_esp_update then
                return
            end
            local object_distance = (Camera.CFrame.p - worldPos).Magnitude
            plr._next_object_esp_update = now + (object_distance < 300 and 0.05 or object_distance < 900 and 0.1 or 0.2)
            
            local str = ""
            if corpse_settings.name then str = espname end
            if corpse_settings.distance then
                local dist = math.floor(object_distance / 4)
                if str ~= "" then str = str .. " [" .. dist .. "m]" else str = "[" .. dist .. "m]" end
            end
            
            if str == "" then
                return plr:togglevis(false)
            end
            
            realname.Text = str
            realname.Position = position
            plr:togglevis(true)
        end)
        plr:forceupdate()
    end
    local function destroy_esp(player)
        if not loaded_plrs[player] then return end
        loaded_plrs[player].connection:Disconnect()
        for i,v in loaded_plrs[player].obj do
            v:Remove()
        end
        esp_table.update_player_chams(player, false)
        loaded_plrs[player] = nil
    end
    function esp_table.load()
        assert(not esp_table.__loaded, "[ESP] already loaded");
        local shortcut = function(is_obj, remove, name)
            return function(model)(remove and destroy_esp or (is_obj and create_object_esp or create_esp))(model, is_obj and name or nil) end;
        end
        for i, v in next, plrs:GetPlayers() do
            if v ~= lplr then create_esp(v) end
        end
        for _, folder in next, workspace.AiZones:GetChildren() do
            for _, npc in next, folder:GetChildren() do
                create_esp(npc, true)
            end
        end
        for _, item in next, workspace.DroppedItems:GetChildren() do
            create_object_esp(item, "corpse")
        end
        esp_table.objectAdded = {
            plrs.PlayerAdded:Connect(shortcut(false, false)),
            workspace.DroppedItems.ChildAdded:Connect(shortcut(true, false, "corpse"))
        };
        esp_table.objectRemoving = {
            plrs.PlayerRemoving:Connect(shortcut(false, true)),
            workspace.DroppedItems.ChildRemoved:Connect(shortcut(true, true, "corpse"))
        };
        for _, __no in pairs(workspace.AiZones:GetChildren()) do
            esp_table.objectAdded[#esp_table.objectAdded + 1] = __no.ChildAdded:Connect(shortcut(false, false))
            esp_table.objectRemoving[#esp_table.objectRemoving + 1] = __no.ChildRemoved:Connect(shortcut(false, true))
        end
        esp_table.__loaded = true;
    end
    function esp_table.unload()
        assert(esp_table.__loaded, "[ESP] not loaded yet");
        for player, _ in next, loaded_plrs do
            destroy_esp(player)
        end
        for _, connection in next, esp_table.objectAdded do
            connection:Disconnect()
        end
        for _, connection in next, esp_table.objectRemoving do
            connection:Disconnect()
        end
        esp_table.__loaded = false;
    end
    function esp_table.get_gun(player)
        local Player = _FindFirstChild(ReplicatedStorage.Players, player.Name);
        if Player and _FindFirstChild(Player, "Status") and _FindFirstChild(Player.Status, "GameplayVariables") and _FindFirstChild(Player.Status.GameplayVariables, "EquippedTool") and Player.Status.GameplayVariables.EquippedTool.Value then
            local Equipped = Player.Status.GameplayVariables.EquippedTool.Value;
            return tostring(Equipped);
        end;
        return "None";
    end
    local forceupdate_queued = false
    function esp_table.icaca()
        if forceupdate_queued then
            return
        end

        forceupdate_queued = true
        task.defer(function()
            forceupdate_queued = false
            local processed = 0
            for _, v in loaded_plrs do
                if v and v.forceupdate then
                    pcall(function()
                        v:forceupdate()
                    end)
                    processed = processed + 1
                    if processed % 25 == 0 then
                        task.wait()
                    end
                end
            end
        end)
    end
    cheat.EspLibrary = esp_table
end)()
local is_visible = cheat.utility.is_visible
cheat._pos_vis_params = cheat._pos_vis_params or RaycastParams.new()
cheat._pos_vis_params.FilterType = Enum.RaycastFilterType.Exclude
cheat._pos_vis_params.CollisionGroup = "WeaponRay"
cheat._pos_vis_params.IgnoreWater = true
cheat._pos_vis_filter = cheat._pos_vis_filter or table.create(3)
local function is_pos_visible(posfrom, posto, target)
    if not (posfrom and posto and target) then return false end
    for i = #cheat._pos_vis_filter, 1, -1 do
        cheat._pos_vis_filter[i] = nil
    end
    local nocollision = workspace:FindFirstChild("NoCollision")
    if nocollision then cheat._pos_vis_filter[#cheat._pos_vis_filter + 1] = nocollision end
    cheat._pos_vis_filter[#cheat._pos_vis_filter + 1] = Camera
    if LocalPlayer.Character then cheat._pos_vis_filter[#cheat._pos_vis_filter + 1] = LocalPlayer.Character end
    cheat._pos_vis_params.FilterDescendantsInstances = cheat._pos_vis_filter
    local castresults = _Raycast(workspace, posfrom, posto - posfrom, cheat._pos_vis_params)
    return not (castresults and castresults.Instance) or _IsDescendantOf(castresults.Instance, target)
end
local function predict_velocity(Origin, Destination, DestinationVelocity, ProjectileSpeed)
    local Distance = (Destination - Origin).Magnitude;
    local TimeToHit = (Distance / ProjectileSpeed);
    local Predicted = Destination + DestinationVelocity * TimeToHit;
    local Delta = (Predicted - Origin).Magnitude / ProjectileSpeed;
    TimeToHit = TimeToHit + (Delta / ProjectileSpeed);
    local Actual = Destination + DestinationVelocity * TimeToHit;
    return Actual;
end;
local function predict_drop(Origin, Destination, ProjectileSpeed, ProjectileDrop)
    if ProjectileDrop == 0 then return 0 end
    local Distance = (Destination - Origin).Magnitude;
    local TimeToHit = (Distance / ProjectileSpeed);
    TimeToHit = TimeToHit + (Distance / ProjectileSpeed);
    local DropTime = ProjectileDrop * TimeToHit ^ 2;
    if tostring(DropTime):find("nan") or (Distance <= 100) then
        return 0 
    end;
    return DropTime;
end;
local target_trigger_params = RaycastParams.new()
target_trigger_params.FilterType = Enum.RaycastFilterType.Exclude
target_trigger_params.IgnoreWater = true
cheat._target_scan_candidates = cheat._target_scan_candidates or table.create(32)
local function get_closest_target(usefov, fov_size, aimpart, npc, is_rage, rage_dist, target_heli, target_players, require_triggerable, allow_manip, manip_origin)
    local ermm_part, isnpc = nil, false
    local maximum_distance = is_rage and rage_dist or (usefov and fov_size or math.huge)
    local mousepos = _Vector2new(Mouse.X, Mouse.Y)
    local camera = Camera
    local camera_cframe = camera.CFrame
    local camera_pos = camera_cframe.p
    local needs_visibility_ray = require_triggerable or is_rage
    local max_visibility_checks = require_triggerable and 8 or 10
    for i = #cheat._target_scan_candidates, 1, -1 do
        cheat._target_scan_candidates[i] = nil
    end
    
    local function is_triggerable(parent, part)
        if is_visible(camera_cframe, parent, part) then return true end
        if allow_manip and manip_origin then
            local noc = workspace:FindFirstChild("NoCollision")
            if noc then target_trigger_params.FilterDescendantsInstances = {LocalPlayer.Character, Camera, noc}
            else target_trigger_params.FilterDescendantsInstances = {LocalPlayer.Character, Camera} end
            local res = workspace:Raycast(manip_origin, part.Position - manip_origin, target_trigger_params)
            if not res or (res.Instance and res.Instance:IsDescendantOf(parent)) then return true end
        end
        return false
    end

    local function consider_candidate(parent, part, candidate_isnpc)
        local position, onscreen = _WorldToViewportPoint(camera, part.Position)
        if usefov and not onscreen and not is_rage then return end
        local distance = is_rage and ((camera_pos - part.Position).Magnitude / 3) or (_Vector2new(position.X, position.Y - GuiInset.Y) - mousepos).Magnitude
        if (is_rage or (usefov and onscreen or not usefov)) and distance <= maximum_distance then
            if needs_visibility_ray then
                cheat._target_scan_candidates[#cheat._target_scan_candidates + 1] = {
                    part = part,
                    parent = parent,
                    distance = distance,
                    isnpc = candidate_isnpc
                }
            else
                ermm_part = part
                maximum_distance = distance
                isnpc = candidate_isnpc
            end
        end
    end

    LPH_NO_VIRTUALIZE(function()
        if npc then
            for _, __no in pairs(workspace.AiZones:GetChildren()) do for _, npcs in pairs(__no:GetChildren()) do
                local part = _FindFirstChild(npcs, aimpart)
                
                local is_heli = false
                if target_heli and (npcs.Name == "MI24V" or npcs.Name == "BTR80") then
                    is_heli = true
                    part = npcs:FindFirstChild("CollisionPilot", true) or npcs:FindFirstChild("Mi24_Prop_M", true)
                end
                
                if not is_heli and (npcs.Name == "MI24V" or npcs.Name == "BTR80") then continue end

                local humanoid = _FindFirstChildOfClass(npcs, "Humanoid")
                if part and (is_heli or (humanoid and humanoid.Health > 0)) then
                    if (camera_pos - part.Position).Magnitude < 2500 then
                        consider_candidate(npcs, part, true)
                    end
                end
            end end
        end
        if target_players then
            for _, plr in Players:GetPlayers() do
                local character = plr.Character
                if plr ~= LocalPlayer and character then
                    local part = _FindFirstChild(character, aimpart)
                    local humanoid = _FindFirstChildOfClass(character, "Humanoid")
                    if part and humanoid and humanoid.Health > 0 then
                        consider_candidate(character, part, false)
                    end
                end
            end
        end
    end)()
    if needs_visibility_ray and #cheat._target_scan_candidates > 0 then
        table.sort(cheat._target_scan_candidates, function(a, b)
            return a.distance < b.distance
        end)
        local checked = 0
        for i = 1, #cheat._target_scan_candidates do
            local candidate = cheat._target_scan_candidates[i]
            checked = checked + 1
            if require_triggerable then
                if is_triggerable(candidate.parent, candidate.part) then
                    ermm_part = candidate.part
                    isnpc = candidate.isnpc
                    break
                end
            elseif is_visible(camera_cframe, candidate.parent, candidate.part) then
                ermm_part = candidate.part
                isnpc = candidate.isnpc
                break
            end
            if checked >= max_visibility_checks then
                break
            end
        end
    end
    return ermm_part, isnpc
end
local function make_beam(Origin, Position, Color, Thickness)
    local part1, part2 = Instance.new("Part", workspace.NoCollision), Instance.new("Part", workspace.NoCollision)
    part1.Position = Origin; part2.Position = Position;
    part1.Transparency = 1; part2.Transparency = 1;
    part1.CanCollide = false; part2.CanCollide = false;
    part1.Size = Vector3.zero; part2.Size = Vector3.zero;
    part1.Anchored = true; part2.Anchored = true;
    local OriginAttachment = Instance.new("Attachment", part1)
    local PositionAttachment = Instance.new("Attachment", part2)
    local Beam = Instance.new("Beam", workspace.NoCollision)
    Beam.Name = "Beam"
    Beam.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,Color),
        ColorSequenceKeypoint.new(1,Color)
    };
    Beam.LightEmission = 1
    Beam.LightInfluence = 1
    Beam.TextureMode = Enum.TextureMode.Static
    Beam.TextureSpeed = 0
    Beam.Texture = "http://www.roblox.com/asset/?id=446111271"
    Beam.Transparency = NumberSequence.new(0)
    Beam.Attachment0 = OriginAttachment
    Beam.Attachment1 = PositionAttachment
    Beam.FaceCamera = true
    Beam.Segments = 1
    Beam.Width0 = Thickness or 0.25
    Beam.Width1 = Thickness or 0.25
    return Beam, part1, part2
end

local function create_advanced_tracer(Origin, Position, Color1, Color2, Thickness)
    local part1, part2 = Instance.new("Part", workspace.NoCollision), Instance.new("Part", workspace.NoCollision)
    part1.Position = Origin; part2.Position = Position;
    part1.Transparency = 1; part2.Transparency = 1;
    part1.CanCollide = false; part2.CanCollide = false;
    part1.Size = Vector3.zero; part2.Size = Vector3.zero;
    part1.Anchored = true; part2.Anchored = true;
    local OriginAttachment = Instance.new("Attachment", part1)
    local PositionAttachment = Instance.new("Attachment", part2)
    local colorSeq = ColorSequence.new{ColorSequenceKeypoint.new(0,Color1), ColorSequenceKeypoint.new(0.3,Color2), ColorSequenceKeypoint.new(1,Color2)}
    local CoreBeam = Instance.new("Beam", workspace.NoCollision)
    CoreBeam.Name = "CoreBeam"
    CoreBeam.Color = colorSeq
    CoreBeam.Width0 = Thickness
    CoreBeam.Width1 = Thickness
    CoreBeam.Texture = ""
    CoreBeam.TextureSpeed = 0
    CoreBeam.LightEmission = 1
    CoreBeam.LightInfluence = 0
    CoreBeam.TextureMode = Enum.TextureMode.Stretch
    CoreBeam.Attachment0 = OriginAttachment
    CoreBeam.Attachment1 = PositionAttachment
    CoreBeam.FaceCamera = true
    CoreBeam.Segments = 1
    CoreBeam.Transparency = NumberSequence.new(0)
    local PulseBeam = Instance.new("Beam", workspace.NoCollision)
    PulseBeam.Name = "PulseBeam"
    PulseBeam.Color = colorSeq
    PulseBeam.Width0 = Thickness * 0.5
    PulseBeam.Width1 = Thickness * 0.5
    PulseBeam.Texture = "rbxassetid://446111271"
    PulseBeam.TextureSpeed = 0
    PulseBeam.LightEmission = 1
    PulseBeam.LightInfluence = 0
    PulseBeam.TextureMode = Enum.TextureMode.Stretch
    PulseBeam.Attachment0 = OriginAttachment
    PulseBeam.Attachment1 = PositionAttachment
    PulseBeam.FaceCamera = true
    PulseBeam.Segments = 1
    PulseBeam.Transparency = NumberSequence.new(0)
    return {CoreBeam, PulseBeam}, part1, part2
end

local silent_aim = {
    enabled = false,
    triggerbot = false,
    target_players = true,
    target_ai = false,
    target_npc = false,
    target_heli = false,
    testwallbang = false,
    part = "Head",
    random_part = false,
    fov = false,
    fov_show = false,
    fov_color = Color3.new(1, 1, 1),
    fov_outline = false,
    fov_outline_color = Color3.new(0, 0, 0),
    fov_size = 100,
    fov_glow_intensity = 1,
    indicator = false,
    indicator_text = "",
    nospread = false,
    instant = false,
    corner_shoot = false,
    corner_shoot_dist = 5,
    crosshair_status = false,
    status_bar_width = 100,
    status_bar_height = 6,
    status_bar_offset = 32,
    manipulated = false,
    manipulated_origin = nil,
    target_part = nil, is_npc = false, isvisible = false,
    instantreload = false,
    tracer = false,
    tracer_style = "Tracer 1",
    tracer_color = Color3.new(1, 1, 1),
    tracer_color2 = Color3.new(0, 0.5, 1),
    tracer_thickness = 0.5,
    tracer_lifetime = 1,
    tipanel_x = 20,
    tipanel_y = 350,
    target_line = false,
    rage_bot = false,
    rage_max_dist = 500,
    lift_hitboxes = false,
    lift_hitboxes_height = 2,
    target_chams = false,
    target_chams_color = Color3.fromRGB(255, 60, 60),
    target_chams_transparency = 0.25,
}
cheat.utility.fast_namecall_needed = function()
    return (cheat.hitlogs_enabled == true)
        or (cheat.freecam_enabled == true)
        or silent_aim.nospread
        or silent_aim.triggerbot
        or silent_aim.silentaim
        or silent_aim.rage_bot
        or silent_aim.instant
        or silent_aim.corner_shoot
        or silent_aim.target_part ~= nil
        or (cheat._gun_sounds_volume and cheat._gun_sounds_volume() < 100)
        or (cheat._hitmarker_sounds_volume and cheat._hitmarker_sounds_volume() < 100)
end
local function silent_aim_active()
    return feature_active(silent_aim.enabled, 'silentaim_bind')
end

local function rage_bot_active()
    return feature_active(silent_aim.rage_bot, 'ragebot_bind')
end

local function triggerbot_active()
    return feature_active(silent_aim.triggerbot, 'triggerbot_bind')
end

local function lift_hitboxes_active()
    return feature_active(silent_aim.lift_hitboxes, 'lifthitboxes_bind')
end

do
    local ignorelist=require(ReplicatedStorage.Modules.UniversalTables).ReturnTable("GlobalIgnoreListProjectile")
    local function get_local_weapon()
        local Player = ReplicatedStorage.Players:FindFirstChild(LocalPlayer.Name)
        if Player and Player:FindFirstChild("Status") and Player.Status:FindFirstChild("GameplayVariables") and Player.Status.GameplayVariables:FindFirstChild("EquippedTool") and Player.Status.GameplayVariables.EquippedTool.Value then
            local Equipped = Player.Status.GameplayVariables.EquippedTool.Value
            return Equipped.Name
        end
        return "None"
    end
    local shoot_debounce = tick()
    local rpplrs = ReplicatedStorage.Players
    local bulletmodule = require(ReplicatedStorage.Modules.FPS.Bullet)
    local CreateBullet = require(ReplicatedStorage.Modules.FPS.Bullet).CreateBullet
    local ProjectileInflict = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ProjectileInflict")
    local FireProjectile = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("FireProjectile")
    function cheat.shoot_weapon(speedmult)
        local weapon = get_local_weapon()
        local rpinv = rpplrs[LocalPlayer.Name] and rpplrs[LocalPlayer.Name].Inventory
        local aimpart = Camera and _FindFirstChild(Camera, "ViewModel") and _FindFirstChild(Camera.ViewModel, "AimPart")
        local inv_weapon = rpinv and _FindFirstChild(rpinv, weapon)
        local charweapon = LocalPlayer.Character and _FindFirstChild(LocalPlayer.Character, weapon)
        local magazine = inv_weapon and _FindFirstChild(inv_weapon, "Attachments") and _FindFirstChild(inv_weapon.Attachments, "Magazine") and inv_weapon.Attachments.Magazine:FindFirstChildOfClass("StringValue")
        local loadedammo = magazine and magazine.ItemProperties:FindFirstChild("LoadedAmmo") and magazine.ItemProperties.LoadedAmmo:FindFirstChildOfClass("Folder")
        if weapon ~= "None" and rpinv and aimpart and inv_weapon and _FindFirstChild(inv_weapon, "SettingsModule") and charweapon and loadedammo then
            local weapon_settings = require(_FindFirstChild(inv_weapon, "SettingsModule"))
            if rawget(weapon_settings, "FireRate") and shoot_debounce <= tick() then
                local bullet_type = loadedammo:GetAttribute("AmmoType")
                CreateBullet(bulletmodule, inv_weapon, LocalPlayer.Character:FindFirstChild(weapon),
                Camera:FindFirstChild("ViewModel"), "Idle", bullet_type, 0, 1, Camera.ViewModel:FindFirstChild("AimPart"))
                shoot_debounce = tick() + (rawget(weapon_settings, "FireRate") * speedmult)
            end
        end
    end
    function cheat.shoot_weapon_packet(isvis, speedmult, prediction, hitscan, hitscanwalls)
        local weapon = get_local_weapon()
        local rpinv = _FindFirstChild(rpplrs, LocalPlayer.Name) and rpplrs[LocalPlayer.Name].Inventory
        local inv_weapon = rpinv and weapon and _FindFirstChild(rpinv, weapon)
        local aimpart = Camera and _FindFirstChild(Camera, "ViewModel") and _FindFirstChild(Camera.ViewModel, "AimPart")
        if inv_weapon and _FindFirstChild(inv_weapon, "SettingsModule") then
            local weapon_settings = require(_FindFirstChild(inv_weapon, "SettingsModule"))
            if rawget(weapon_settings, "FireRate") and shoot_debounce <= tick() then
                local real_orig = Camera.CFrame.p
                if silent_aim.corner_shoot and silent_aim.manipulated_origin then
                    real_orig = silent_aim.manipulated_origin
                elseif cheat.freecam_enabled then
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("Head") then real_orig = char.Head.Position end
                end
                
                local dist = silent_aim.target_part and (silent_aim.target_part.Position - real_orig).Magnitude or 0
                autoshootdelay = tick() - (dist / 1000)
                local rnd = math.random(-10000, 10000)
                if silent_aim then silent_aim._exact_fire_tick = tick() end
                
                local as_dir = silent_aim.target_part and (silent_aim.target_part.Position - real_orig).Unit or Vector3.new(0, 1, 0)
                if FireProjectile:InvokeServer(as_dir, rnd, autoshootdelay) then
                    ProjectileInflict:FireServer(
                        silent_aim.target_part,
                        silent_aim.target_part.CFrame:ToObjectSpace(CFrame.new(0, 0.0001, 0)),
                        rnd,
                        tick()
                    )
                    if silent_aim.tracer then
                        local t_orig = real_orig
                        if not (silent_aim.corner_shoot and silent_aim.manipulated_origin) and not cheat.freecam_enabled then
                            t_orig = aimpart and aimpart.Position or Camera.CFrame.p
                        end
                        local drawing, deleteme, deleteme1 = make_beam(t_orig, silent_aim.target_part.Position, silent_aim.autoshootcolor)
                        local wtf = -1
                        local conn; conn = cheat.utility.new_renderstepped(function(delta)
                            wtf = wtf + delta
                            drawing.Transparency = NumberSequence.new(math.clamp(wtf, 0, 1))
                            if wtf >= 1 then
                                drawing:Destroy()
                                deleteme:Destroy()
                                deleteme1:Destroy()
                                conn:Disconnect()
                            end
                        end)
                    end
                end
                shoot_debounce = tick() + (rawget(weapon_settings, "FireRate") * speedmult)
            end
        end
    end
end
do
    local norecoil, nobob = false, false
    local instantreload, forceauto, instantaim = false, false, false
    local autoshoot, packetautoshoot, packetpred, packetscan, packetthruscan, shootspeed = false, false, false, false, false, 1
    local target_part, is_npc, isvisible;
    local instant_equip = false
    local rapid_fire = false
    local rapid_fire_delay = 0.1
    local function fire_rate_to_delay(rate)
        return 0.6 - math.clamp(rate, 0.1, 0.5)
    end
    local unlock_firemodes = false
    local salobox = ui.box.aimbot:AddTab('Aimbot')
    local triggerbotbox = ui.box.aimbot:AddTab('Trigger Bot')
    local gunmodbox = ui.box.mods:AddTab('Gun Mods')
    local fovbox = ui.box.mods:AddTab('FOV')
    local statusbarbox = ui.box.mods:AddTab('Status Bar')
    local aim_miscbox = ui.box.misc:AddTab('Aim Misc')
    ui.gunmodbox = gunmodbox
    local got_that = false
    local hooked_springs = setmetatable({}, { __mode = "k" })
    local hooked_spring_creates = setmetatable({}, { __mode = "k" })
    local hooked_spring_instances = setmetatable({}, { __mode = "k" })
    cheat.utility.get_bullet_tracer_color = function(secondary)
        local option = cheat.Options and cheat.Options[secondary and "silentaim_tracer_color2" or "silentaim_tracer_color"]
        local value = option and (option.Value or option.Color)
        if type(value) == "table" then
            value = value.Color or value.Value
        end
        if typeof(value) == "Color3" then
            if secondary then
                silent_aim.tracer_color2 = value
            else
                silent_aim.tracer_color = value
            end
            return value
        end

        value = secondary and silent_aim.tracer_color2 or silent_aim.tracer_color
        if type(value) == "table" then
            value = value.Color or value.Value
        end
        if typeof(value) == "Color3" then
            return value
        end

        return secondary and Color3.new(0, 0.5, 1) or Color3.new(1, 1, 1)
    end
    cheat.utility.draw_regular_bullet_tracer = function(args)
        if not silent_aim.tracer then return end
        local aimpart
        for _, v in args do
            if typeof(v) == "Instance" and v.Name == "AimPart" then
                aimpart = v
                break
            end
        end
        if not aimpart then return end

        local t_orig = aimpart.Position
        local t_end = Mouse and Mouse.Hit and Mouse.Hit.Position or (t_orig + aimpart.CFrame.LookVector * 10000)
        if silent_aim.tracer_style == "Tracer 2" then
            local beams, d1, d2 = create_advanced_tracer(t_orig, t_end, cheat.utility.get_bullet_tracer_color(false), cheat.utility.get_bullet_tracer_color(true), silent_aim.tracer_thickness)
            local lifetime, t = silent_aim.tracer_lifetime, 0
            local conn; conn = cheat.utility.new_renderstepped(function(delta)
                t = t + delta
                local trans = math.clamp((t / lifetime) ^ 2, 0, 1)
                local pulse = (math.sin(t * 20) + 1) / 2
                for _, b in pairs(beams) do
                    b.Transparency = NumberSequence.new(trans)
                    if b.Name == "PulseBeam" then
                        b.Width0 = silent_aim.tracer_thickness * (0.5 + pulse)
                        b.Width1 = silent_aim.tracer_thickness * (0.5 + pulse)
                    end
                end
                if t >= lifetime then
                    for _, b in pairs(beams) do b:Destroy() end
                    d1:Destroy(); d2:Destroy(); conn:Disconnect()
                end
            end)
            return
        end

        local drawing, deleteme, deleteme1 = make_beam(t_orig, t_end, cheat.utility.get_bullet_tracer_color(false), silent_aim.tracer_thickness)
        local wtf = -1
        local conn; conn = cheat.utility.new_renderstepped(function(delta)
            wtf = wtf + delta
            drawing.Transparency = NumberSequence.new(math.clamp(wtf, 0, 1))
            if wtf >= 1 then
                drawing:Destroy()
                deleteme:Destroy()
                deleteme1:Destroy()
                conn:Disconnect()
            end
        end)
    end
    repeat LPH_JIT_MAX(function()
        for i, gc in next, getgc(true) do
            if type(gc) == "table" then
                if type(rawget(gc, "shove")) == "function" and type(rawget(gc, "update")) == "function" and not hooked_springs[gc] then
                    hooked_springs[gc] = true
                    local shove, update = gc.shove, gc.update
                    pcall(function()
                        gc.shove = function(...)
                            if norecoil then
                                return nil
                            end
                            local ok, result = pcall(shove, ...)
                            if ok then
                                return result
                            end
                            return nil
                        end
                        gc.update = function(...)
                            if nobob then
                                return Vector3.zero
                            end
                            local ok, result = pcall(update, ...)
                            if ok then
                                return result
                            end
                            return Vector3.zero
                        end
                    end)
                end
                if type(rawget(gc, "create")) == "function" and getinfo(gc.create).short_src == "ReplicatedStorage.Modules.SpringV2" and not hooked_spring_creates[gc] then
                    hooked_spring_creates[gc] = true
                    local old_create = (gc.create)
                    cheat.utility.new_hook(old_create, function(old, ...)
                        local create = type(old) == "function" and old or old_create
                        local returns = create(...)
                        if type(returns) ~= "table" or hooked_spring_instances[returns] then
                            return returns
                        end

                        hooked_spring_instances[returns] = true
                        local shove, update = returns.shove, returns.update
                        if type(shove) == "function" then
                            pcall(function()
                                returns.shove = function(...)
                                    if norecoil then
                                        return nil
                                    end
                                    local ok, result = pcall(shove, ...)
                                    if ok then
                                        return result
                                    end
                                    return nil
                                end
                            end)
                        end
                        if type(update) == "function" then
                            pcall(function()
                                returns.update = function(...)
                                    if nobob then
                                        return Vector3.zero
                                    end
                                    local ok, result = pcall(update, ...)
                                    if ok then
                                        return result
                                    end
                                    return Vector3.zero
                                end
                            end)
                        end
                        return returns
                    end, true)
                end
                if rawget(gc, "CreateBullet") then
                    local old_bullet = gc.CreateBullet
                    cheat.utility.new_hook(old_bullet, LPH_JIT_MAX(function(old, self, ...)
                        local args = { ... };
                        local argCount = select("#", ...);
                        local aim_active = silent_aim_active() or rage_bot_active()
                        if not aim_active then
                            cheat.utility.draw_regular_bullet_tracer(args)
                        end
                        if aim_active then
                            local loadedammo, aimpart_index do
                                for i, v in args do
                                    if typeof(v) == "Instance" and v.Name == "AimPart" then
                                        aimpart_index = i
                                    end
                                    if type(v) == "string" then
                                        local tmp = _FindFirstChild(ReplicatedStorage.AmmoTypes, v)
                                        if tmp then loadedammo = tmp end
                                    end
                                end
                            end
                            if not (loadedammo and aimpart_index) then
                                return old(self, unpack(args, 1, argCount))
                            end
                            if silent_aim.tracer then
                                if silent_aim.tracer_style == "Tracer 2" then
                                    local t_orig = silent_aim.manipulated_origin or args[aimpart_index].Position
                                    local beams, d1, d2 = create_advanced_tracer(t_orig, silent_aim.target_part and silent_aim.target_part.Position or args[aimpart_index].CFrame.LookVector * 10000, cheat.utility.get_bullet_tracer_color(false), cheat.utility.get_bullet_tracer_color(true), silent_aim.tracer_thickness)
                                    local lifetime = silent_aim.tracer_lifetime
                                    local t = 0
                                    local conn; conn = cheat.utility.new_renderstepped(function(delta)
                                        t = t + delta
                                        local trans = math.clamp((t / lifetime) ^ 2, 0, 1)
                                        local pulse = (math.sin(t * 20) + 1) / 2
                                        for _, b in pairs(beams) do 
                                            b.Transparency = NumberSequence.new(trans) 
                                            if b.Name == "PulseBeam" then
                                                b.Width0 = silent_aim.tracer_thickness * (0.5 + pulse)
                                                b.Width1 = silent_aim.tracer_thickness * (0.5 + pulse)
                                            end
                                        end
                                        if t >= lifetime then
                                            for _, b in pairs(beams) do b:Destroy() end
                                            d1:Destroy(); d2:Destroy(); conn:Disconnect()
                                        end
                                    end)
                                elseif silent_aim.tracer_style == "Beam" then
                                    local t_orig = silent_aim.manipulated_origin or args[aimpart_index].Position
                                    local t_end = silent_aim.target_part and silent_aim.target_part.Position or args[aimpart_index].CFrame.LookVector * 10000
                                    
                                    local StartPart = Instance.new("Part", workspace.NoCollision)
                                    local EndPart = Instance.new("Part", workspace.NoCollision)
                                    StartPart.Transparency = 1
                                    StartPart.Size = Vector3.new(0.05, 0.05, 0.05)
                                    StartPart.Anchored = true
                                    StartPart.CanCollide = false
                                    StartPart.Position = t_orig
                                    
                                    EndPart.Transparency = 1
                                    EndPart.Size = Vector3.new(0.05, 0.05, 0.05)
                                    EndPart.Anchored = true
                                    EndPart.CanCollide = false
                                    EndPart.Position = t_end
                                    
                                    local StartAttachment = Instance.new("Attachment", StartPart)
                                    local EndAttachment = Instance.new("Attachment", EndPart)
                                    
                                    local Beam = Instance.new("Beam", workspace.NoCollision)
                                    Beam.Color = ColorSequence.new(cheat.utility.get_bullet_tracer_color(false))
                                    Beam.Enabled = true
                                    Beam.FaceCamera = true
                                    Beam.Attachment0 = StartAttachment
                                    Beam.Attachment1 = EndAttachment
                                    Beam.Width0 = silent_aim.tracer_thickness * 2
                                    Beam.Width1 = silent_aim.tracer_thickness * 2
                                    Beam.LightEmission = 1
                                    Beam.LightInfluence = 0
                                    Beam.Texture = "rbxassetid://446111271"
                                    Beam.TextureLength = 14
                                    Beam.TextureSpeed = 12
                                    Beam.TextureMode = Enum.TextureMode.Wrap
                                    
                                    task.spawn(function()
                                        task.wait(0.2)
                                        local SpeedTween = TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
                                        local CreatedTween = game:GetService("TweenService"):Create(Beam, SpeedTween, { TextureSpeed = 2 })
                                        CreatedTween:Play()
                                    end)
                                    
                                    task.delay(silent_aim.tracer_lifetime, function()
                                        local Tween = game:GetService("TweenService"):Create(Beam, TweenInfo.new(1), {
                                            Width0 = 0,
                                            Width1 = 0,
                                            TextureSpeed = 0,
                                        })
                                        Tween:Play()
                                        Tween.Completed:Wait()
                                        Beam:Destroy()
                                        StartPart:Destroy()
                                        EndPart:Destroy()
                                    end)
                                else
                                    local real_orig = Camera.CFrame.p
                                    if silent_aim.corner_shoot and silent_aim.manipulated_origin then
                                        real_orig = silent_aim.manipulated_origin
                                    elseif cheat.freecam_enabled then
                                        local char = LocalPlayer.Character
                                        if char and char:FindFirstChild("Head") then real_orig = char.Head.Position end
                                    end
                                    local t_orig = real_orig
                                    if not (silent_aim.corner_shoot and silent_aim.manipulated_origin) and not cheat.freecam_enabled then
                                        t_orig = args[aimpart_index].Position
                                    end
                                    local drawing, deleteme, deleteme1 = make_beam(t_orig, silent_aim.target_part and silent_aim.target_part.Position or args[aimpart_index].CFrame.LookVector * 10000, cheat.utility.get_bullet_tracer_color(false), silent_aim.tracer_thickness)
                                    local wtf = -1
                                    local conn; conn = cheat.utility.new_renderstepped(function(delta)
                                        wtf = wtf + delta
                                        drawing.Transparency = NumberSequence.new(math.clamp(wtf, 0, 1))
                                        if wtf >= 1 then
                                            drawing:Destroy()
                                            deleteme:Destroy()
                                            deleteme1:Destroy()
                                            conn:Disconnect()
                                        end
                                    end)
                                end
                            end
                            if silent_aim.instant then
                                return old(self, unpack(args, 1, argCount))
                            end
                            if not silent_aim.target_part or silent_aim.instant then
                                return old(self, unpack(args, 1, argCount))
                            end
                            local ProjectileSpeed = loadedammo:GetAttribute("MuzzleVelocity")
                            local Destination = silent_aim.target_part.Position
                            if lift_hitboxes_active() then
                                local lift_h = silent_aim.lift_hitboxes_height or 2
                                Destination = Destination + Vector3.new(0, lift_h, 0)
                            end
                            local DestinationVelocity = silent_aim.target_part.Velocity
                            local Origin = Camera.CFrame.p
                            local real_aimpart = args[aimpart_index]
                            local old_cf = real_aimpart.CFrame
                            real_aimpart.CFrame = _CFramenew(real_aimpart.Position, Destination)
                            local ret = old(self, unpack(args, 1, argCount))
                            real_aimpart.CFrame = old_cf
                            return ret
                        else
                            return old(self, ...)
                        end
                    end), true)
                end
                if rawget(gc, "updateClient") then
                    local old_update = gc.updateClient
                    cheat.utility.new_hook(old_update, LPH_JIT_MAX(function(old, ...)
                        local args = {...};
                        local argCount = select("#", ...);
                        if instantaim then
                            args[1].AimInSpeed = 0
                            args[1].AimOutSpeed = 0
                        end;
                        if forceauto then
                            args[1].FireMode = "Auto"
                        end
                        if unlock_firemodes and rawget(args[1], "FireModes") then
                            args[1].FireModes = {
                                "Auto",
                                "Semi"
                            }
                        end
                        if rapid_fire then
                            args[1].FireRate = rapid_fire_delay
                        end
                        return old(unpack(args, 1, argCount))
                    end), true)
                    got_that = true
                end
            end
        end
    end)() if not got_that then print("didnt get that") task.wait(1) end until got_that
    
    gunmodbox:AddToggle('gunmods_rapidfire', {Text = 'Fire Rate',Default = false,Callback = function(first)
        rapid_fire = first
    end})
    gunmodbox:AddSlider('gunmods_rapidfire_delay', {Text = 'Fire Rate', Default = 0.5, Min = 0.1, Max = 0.5, Rounding = 3, Callback = function(v)
        rapid_fire_delay = fire_rate_to_delay(v)
    end})
    
    gunmodbox:AddToggle('gunmods_norecoil', {Text = 'No Recoil',Default = false,Callback = function(first)
        norecoil = first
    end})

    gunmodbox:AddToggle('gunmods_nospread', {Text = 'No Spread',Default = false,Callback = function(first)
        silent_aim.nospread = first
    end})
    gunmodbox:AddToggle('gunmods_nobob', {Text = 'No Gun Bob',Default = false,Callback = function(first)
        nobob = first
    end})
    gunmodbox:AddToggle('gunmods_instantaim', {Text = 'Instant Aim',Default = false,Callback = function(first)
        instantaim = first
    end})
    gunmodbox:AddToggle('gunmods_unlockfiremodes', {Text = 'Unlock Firemodes',Default = false,Callback = function(first)
        unlock_firemodes = first
    end})
    salobox:AddToggle('silentaim_enabled', {Text = 'Silent Aim',Default = false,Callback = function(first)
        silent_aim.enabled = first
    end}):AddKeyPicker('silentaim_bind', {Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'Silent Aim', NoUI = false})
    salobox:AddDropdown('silentaim_hitreg', {Values = {'Head','FaceHitBox','HeadTopHitbox','UpperTorso','LowerTorso','HumanoidRootPart','LeftFoot','LeftLowerLeg','LeftUpperLeg','LeftHand','LeftLowerArm','LeftUpperArm','RightFoot','RightLowerLeg','RightUpperLeg','RightHand','RightLowerArm','RightUpperArm'},Default = 1,Multi = false,Text = 'Aim Part',Tooltip = 'select part',Callback = function(Value)
        silent_aim.part = Value
    end})
    salobox:AddToggle('ragebot_enabled', {Text = 'Rage Bot',Default = false,Callback = function(first)
        silent_aim.rage_bot = first
    end}):AddKeyPicker('ragebot_bind', {Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'Rage Bot', NoUI = false})
    salobox:AddSlider('ragebot_max_dist', {Text = 'Rage Max Distance', Default = 500, Min = 1, Max = 2500, Rounding = 0, Callback = function(v)
        silent_aim.rage_max_dist = v
    end})
    salobox:AddToggle('silentaim_target_players', {Text = 'Target Players',Default = false,Callback = function(first)
        silent_aim.target_players = first
    end})
    salobox:AddToggle('silentaim_npcaim', {Text = 'Target AI',Default = false,Callback = function(first)
        silent_aim.target_npc = first
    end})
    salobox:AddToggle('silentaim_heliaim', {Text = 'Target Helicopters',Default = false,Callback = function(first)
        silent_aim.target_heli = first
    end})
    salobox:AddToggle('silentaim_tracer', {Text = 'Bullet Tracer',Default = false,Callback = function(Value)
        silent_aim.tracer = Value
    end}):AddColorPicker('silentaim_tracer_color',{Default = Color3.new(1, 1, 1),Title = 'Tracer Color',Transparency = 0,Callback = function(Value)
        if type(Value) == "table" then Value = Value.Color or Value.Value end
        if typeof(Value) == "Color3" then silent_aim.tracer_color = Value end
    end}):AddColorPicker('silentaim_tracer_color2',{Default = Color3.new(0, 0.5, 1),Title = 'Tracer Pulse Color',Transparency = 0,Callback = function(Value)
        if type(Value) == "table" then Value = Value.Color or Value.Value end
        if typeof(Value) == "Color3" then silent_aim.tracer_color2 = Value end
    end})
    salobox:AddDropdown('silentaim_tracer_style', {Values = {'Tracer 1', 'Tracer 2', 'Beam'}, Default = 1, Multi = false, Text = 'Tracer Style', Callback = function(v) silent_aim.tracer_style = v end})
    salobox:AddSlider('tracer_thickness', { Text = 'Tracer Thickness', Default = 0.5, Min = 0.1, Max = 10, Rounding = 1, Compact = true, Callback = function(v) silent_aim.tracer_thickness = v end })
    salobox:AddSlider('tracer_lifetime', { Text = 'Tracer Lifetime', Default = 1, Min = 0.1, Max = 5, Rounding = 1, Compact = true, Callback = function(v) silent_aim.tracer_lifetime = v end })
    gunmodbox:AddToggle('silentaim_instant', {Text = 'Instant Hit',Default = false,Callback = function(first)
        silent_aim.instant = first
    end})
    salobox:AddToggle('silentaim_wallbang', {Text = 'Wallbang',Default = false,Callback = function(first)
        silent_aim.testwallbang = first
        if first then
            silent_aim.isvisible = true
        end
    end})
    
    salobox:AddToggle('silentaim_corner', {Text = 'Corner Shoot',Default = false,Callback = function(first)
        silent_aim.corner_shoot = first
    end})
    salobox:AddSlider('silentaim_corner_dist', {Text = 'Corner Shoot Distance', Default = 5, Min = 5, Max = 15, Rounding = 0, Callback = function(v)
        silent_aim.corner_shoot_dist = v
    end})
    
    statusbarbox:AddToggle('silentaim_crosshairstat', {Text = 'Crosshair Status Bar',Default = false,Callback = function(first)
        silent_aim.crosshair_status = first
    end})
    statusbarbox:AddSlider('silentaim_status_width', {Text = 'Status Bar Width', Default = 100, Min = 10, Max = 300, Rounding = 0, Callback = function(v)
        silent_aim.status_bar_width = v
    end})
    statusbarbox:AddSlider('silentaim_status_height', {Text = 'Status Bar Height', Default = 6, Min = 1, Max = 50, Rounding = 0, Callback = function(v)
        silent_aim.status_bar_height = v
    end})
    statusbarbox:AddSlider('silentaim_status_offset', {Text = 'Status Bar Offset', Default = 32, Min = -100, Max = 200, Rounding = 0, Callback = function(v)
        silent_aim.status_bar_offset = v
    end})
    
    local resolve_desync = false
    local resolve_desync_tab = player_anti_aim_tab
    resolve_desync_tab:AddToggle('resolve_desync', {Text = 'Resolve Desync', Default = false, Callback = function(v)
        resolve_desync = v
    end}):AddKeyPicker('resolve_desync_bind', {Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'Resolve Desync'})
    
    local hitbox_adjust_was_active = false
    cheat.utility.new_renderstepped(function()
        local resolve_desync_active = feature_active(resolve_desync, 'resolve_desync_bind')
        local lift_active = lift_hitboxes_active()
        if not resolve_desync_active and not lift_active then
            if not hitbox_adjust_was_active then
                return
            end
            hitbox_adjust_was_active = false
        else
            hitbox_adjust_was_active = true
        end

        local rep_players = ReplicatedStorage:FindFirstChild("Players")
        if not rep_players then return end
        -- We loop over all players to handle either desync resolution or hitbox lifting (physically shifting the character models up by 2 studs)
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local character = player.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if root then
                    -- Resolve desync location / lift hitboxes without accumulating offsets
                    local p_folder = rep_players:FindFirstChild(player.Name)
                    local status = p_folder and p_folder:FindFirstChild("Status")
                    local uac = status and status:FindFirstChild("UAC")
                    local lastpos = uac and uac:GetAttribute("LastVerifiedPos")
                    
                    if resolve_desync_active and lastpos and typeof(lastpos) == "Vector3" then
                        local base_cf = (root.CFrame - root.Position) + lastpos
                        if lift_active then
                            local lift_h = silent_aim.lift_hitboxes_height or 2
                            root.CFrame = base_cf + Vector3.new(0, lift_h, 0)
                        else
                            root.CFrame = base_cf
                        end
                    else
                        -- Fallback for when LastVerifiedPos is not available or resolver is off (keeps baseline in sync)
                        local current_cf = root.CFrame
                        local last_lifted = root:GetAttribute("LastLiftedCFrame")
                        local base_cf = current_cf
                        
                        if last_lifted and typeof(last_lifted) == "CFrame" then
                            local last_h = root:GetAttribute("LastLiftedHeight") or 2
                            -- If the current Y matches our previously lifted Y closely, we preserve the new horizontal movement (X, Z) 
                            -- from Roblox's replication engine but strip our vertical lift to find the true baseline.
                            if math.abs(current_cf.Position.Y - last_lifted.Position.Y) < 0.05 then
                                base_cf = current_cf - Vector3.new(0, last_h, 0)
                            end
                        end
                        
                        if lift_active then
                            local lift_h = silent_aim.lift_hitboxes_height or 2
                            local new_cf = base_cf + Vector3.new(0, lift_h, 0)
                            root.CFrame = new_cf
                            root:SetAttribute("LastLiftedCFrame", new_cf)
                            root:SetAttribute("LastLiftedHeight", lift_h)
                        else
                            root.CFrame = base_cf
                            root:SetAttribute("LastLiftedCFrame", nil)
                            root:SetAttribute("LastLiftedHeight", nil)
                        end
                    end
                end
            end
        end
    end)
    salobox:AddToggle('silentaim_random_part', {Text = 'Random Hit Part', Default = false, Callback = function(Value)
        silent_aim.random_part = Value
    end})
    aim_miscbox:AddToggle('silentaim_lifthitbox', {Text = 'Lift Hitboxes', Default = false, Callback = function(Value)
        silent_aim.lift_hitboxes = Value
    end}):AddKeyPicker('lifthitboxes_bind', {Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'Lift Hitboxes', NoUI = false})
    aim_miscbox:AddSlider('silentaim_lifthitbox_height', {Text = 'Lift Height', Default = 2, Min = 1, Max = 10, Rounding = 1, Callback = function(v)
        silent_aim.lift_hitboxes_height = v
    end})
    aim_miscbox:AddToggle('silentaim_target_chams', {Text = 'Target Chams', Default = false, Callback = function(Value)
        silent_aim.target_chams = Value
    end}):AddColorPicker('silentaim_target_chams_color', {Default = Color3.fromRGB(255, 60, 60), Title = 'Target Chams Color', Transparency = 0.25, Callback = function(Value, Alpha)
        silent_aim.target_chams_color = Value
        silent_aim.target_chams_transparency = Alpha or silent_aim.target_chams_transparency
    end})
    local silentaim_target_chams_transparency = aim_miscbox:AddSlider('silentaim_target_chams_transparency', {Text = 'Target Chams Transparency', Default = 25, Min = 1, Max = 100, Rounding = 0, Callback = function(v)
        silent_aim.target_chams_transparency = math.clamp(v / 100, 0, 1)
    end})
    silentaim_target_chams_transparency:SetVisible(false)
    
    local tbot_tab = triggerbotbox
    tbot_tab:AddToggle('triggerbot_enabled', {Text = 'Triggerbot', Default = false, Callback = function(v) silent_aim.triggerbot = v end}):AddKeyPicker('triggerbot_bind', {Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'Triggerbot', NoUI = false})
    tbot_tab:AddToggle('triggerbot_manip', {Text = 'Shoot on Manipulated', Default = false, Callback = function(v) silent_aim.triggerbot_manipulation = v end})
    local peek_kill_enabled = false
    local peek_kill_speed = 350
    local function peek_kill_key_active()
        local option = cheat.Options and cheat.Options.peek_kill_bind
        if not option then return false end
        local value = option.Value
        local key = option.Key
        local mode = option.Mode
        local active = option.State
        if type(value) == "table" then
            key = value.Key or key
            mode = value.Type or value.Mode or mode
            active = value.Active ~= nil and value.Active or active
        end
        key = tostring(key or "None")
        if key == "" or key == "None" or key == "NONE" then
            return false
        end
        return mode == "Always" or active == true
    end
    local function apply_peek_kill()
        if not (peek_kill_enabled and peek_kill_key_active()) then return end
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local current_velocity = hrp.AssemblyLinearVelocity or hrp.Velocity
        local next_velocity = Vector3.new(current_velocity.X, peek_kill_speed + math.random(-15, 15), current_velocity.Z)
        pcall(function()
            hrp.AssemblyLinearVelocity = next_velocity
        end)
        pcall(function()
            hrp.Velocity = next_velocity
        end)
    end
    tbot_tab:AddToggle('peek_kill_enabled', {Text = 'Peek Kill', Default = false, Callback = function(v)
        peek_kill_enabled = v
        apply_peek_kill()
    end}):AddKeyPicker('peek_kill_bind', {Default = 'None', SyncToggleState = false, Mode = 'Hold', Text = 'Peek Kill', NoUI = false, Callback = function(active)
        if active then
            apply_peek_kill()
        end
    end})
    tbot_tab:AddSlider('peek_kill_speed', {Text = 'Peek Kill Speed', Default = 350, Min = 50, Max = 1000, Rounding = 0, Callback = function(v)
        peek_kill_speed = v
    end})
    cheat.utility.new_heartbeat(function()
        apply_peek_kill()
    end)
    fovbox:AddToggle('silentaim_fov', {Text = 'Use FOV',Default = false,Callback = function(Value)
        silent_aim.fov = Value
    end})
    gunmodbox:AddToggle('instant_equip', {Text = 'Instant Equip', Default = false, Callback = function(v)
        instant_equip = v
    end})
    -- Instant equip: hook camera for ViewModel equip animation
    cheat.utility.track_connection(Camera.ChildAdded:Connect(function(child)
        if not instant_equip then return end
        if child.Name == LocalPlayer.Name then return end
        if not child:IsA("Model") then return end
        task.spawn(function()
            local iters = 0
            while child.Parent and iters < 500 do
                iters = iters + 1
                local hum = child:FindFirstChild("Humanoid")
                if hum and hum.Animator then
                    for _, track in ipairs(hum.Animator:GetPlayingAnimationTracks()) do
                        if track.Animation.Name == "Equip" then
                            pcall(function()
                                track:AdjustSpeed(15)
                                track.TimePosition = track.Length - 0.01
                            end)
                            return
                        end
                    end
                end
                task.wait(0.001)
            end
        end)
    end))
    local Depbox1 = fovbox:AddDependencyBox();
    Depbox1:AddToggle('silentaim_fov_show', {Text = 'Show FOV',Default = false,Callback = function(Value)
        silent_aim.fov_show = Value
    end}):AddColorPicker('silentaim_fov_color',{Default = Color3.new(1, 1, 1),Title = 'FOV Color',Transparency = 0,Callback = function(Value)
        silent_aim.fov_color = Value
    end})
    Depbox1:AddToggle('silentaim_fov_outline', {Text = 'FOV Outline',Default = false,Callback = function(Value)
        silent_aim.fov_outline = Value
    end})
    Depbox1:AddSlider('silentaim_fov_size',{Text = 'FOV Radius',Default = 100,Min = 10,Max = 1000,Rounding = 0,Compact = true,Callback = function(State)
        silent_aim.fov_size = State
    end})
    Depbox1:AddSlider('silentaim_fov_glow_intensity',{Text = 'FOV Glow Intensity',Default = 1,Min = 0.1,Max = 10,Rounding = 1,Compact = true,Callback = function(v)
        silent_aim.fov_glow_intensity = v
    end})
    Depbox1:SetupDependencies({
        { cheat.Toggles.silentaim_fov, true }
    });
    local CircleInline = cheat.utility.new_drawing("Circle", {
        Transparency = 1,
        Thickness = 1,
        ZIndex = 2,
        Visible = false,
    })
    local StatusBarBg = cheat.utility.new_drawing("Square", {
        Filled = true,
        Color = Color3.new(0, 0, 0),
        ZIndex = 2,
        Visible = false,
    })

    local StatusBarFill = cheat.utility.new_drawing("Square", {
        Filled = true,
        ZIndex = 3,
        Visible = false,
    })
    local fov_glow = {}
    for i = 1, 20 do
        fov_glow[i] = cheat.utility.new_drawing("Circle", {
            Thickness = 1,
            ZIndex = 1,
            Visible = false
        })
    end
    local target_chams_highlight = cheat.utility.track_instance(Instance.new("Highlight"))
    target_chams_highlight.Name = "GhostHookTargetHighlight"
    target_chams_highlight.Enabled = false
    target_chams_highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    target_chams_highlight.Parent = game:GetService("CoreGui")
    cheat.utility.new_renderstepped(LPH_NO_VIRTUALIZE(function()
        local pos = (_Vector2new(Mouse.X, Mouse.Y + GuiInset.Y))
        CircleInline.Position = pos
        CircleInline.Radius = silent_aim.fov_size
        CircleInline.Color = silent_aim.fov_color
        CircleInline.Visible = silent_aim.fov and silent_aim.fov_show
        
        local glow_visible = silent_aim.fov and silent_aim.fov_show and silent_aim.fov_outline
        local intensity = silent_aim.fov_glow_intensity
        local thickness = 1 + (intensity * 0.5)
        for i = 1, 10 do
            -- Outer layers
            local out_circle = fov_glow[i]
            out_circle.Position = pos
            out_circle.Radius = silent_aim.fov_size + (i * (intensity * 0.5))
            out_circle.Color = silent_aim.fov_color
            out_circle.Transparency = (0.2 - (i * 0.02))
            out_circle.Thickness = thickness
            out_circle.Visible = glow_visible
            
            -- Inner layers
            local in_circle = fov_glow[i+10]
            in_circle.Position = pos
            in_circle.Radius = math.max(0, silent_aim.fov_size - (i * (intensity * 0.5)))
            in_circle.Color = silent_aim.fov_color
            in_circle.Transparency = (0.2 - (i * 0.02))
            in_circle.Thickness = thickness
            in_circle.Visible = glow_visible
        end
        
        if silent_aim.crosshair_status and silent_aim.target_part then
            local barWidth = silent_aim.status_bar_width or 100
            local barHeight = silent_aim.status_bar_height or 6
            local barOffset = silent_aim.status_bar_offset or 32
            
            -- TP Kill bar standard position starts at screen center Y + 20 and has height 6.
            -- We place our status bar below it dynamically.
            local viewport = Camera.ViewportSize
            local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
            local barPos = center + Vector2.new(-barWidth / 2, 20 + 6 + barOffset)
            
            local ratio = 1
            local barColor = Color3.new(0, 0, 0)
            
            if silent_aim.isvisible then
                ratio = 1
                barColor = Color3.new(0, 1, 0)
            elseif silent_aim.manipulated and silent_aim.manipulated_origin then
                local camera = workspace.CurrentCamera
                local dist = 0
                if camera then
                    dist = (silent_aim.manipulated_origin - camera.CFrame.Position).Magnitude
                end
                if dist <= 5 then
                    ratio = 1
                    barColor = Color3.new(0, 1, 0)
                else
                    local t = math.clamp((dist - 5) / 10, 0, 1)
                    ratio = 1 - t
                    barColor = Color3.new(t, 1, 0)
                end
            else
                ratio = 1
                barColor = Color3.new(0, 0, 0)
            end
            
            StatusBarBg.Position = barPos - Vector2.new(1, 1)
            StatusBarBg.Size = Vector2.new(barWidth + 2, barHeight + 2)
            StatusBarBg.Color = Color3.fromRGB(20, 20, 20)
            StatusBarBg.Visible = true
            
            StatusBarFill.Position = barPos
            StatusBarFill.Size = Vector2.new(barWidth * ratio, barHeight)
            StatusBarFill.Color = barColor
            StatusBarFill.Visible = true
        else
            StatusBarBg.Visible = false
            StatusBarFill.Visible = false
        end

        local target_model = silent_aim.target_part and silent_aim.target_part.Parent
        if silent_aim.target_chams and target_model then
            target_chams_highlight.Enabled = true
            target_chams_highlight.Adornee = target_model
            target_chams_highlight.FillColor = silent_aim.target_chams_color
            target_chams_highlight.OutlineColor = silent_aim.target_chams_color
            target_chams_highlight.FillTransparency = silent_aim.target_chams_transparency
            target_chams_highlight.OutlineTransparency = 0.05
        else
            target_chams_highlight.Enabled = false
            target_chams_highlight.Adornee = nil
        end
    end))
    local random_part_timer = tick()
    local available_random_parts = {"Head", "UpperTorso", "LowerTorso", "LeftUpperLeg", "RightUpperLeg", "LeftLowerArm", "RightLowerArm"}
    local target_scan_interval = 1 / 30
    local last_target_scan = 0
    local corner_search_interval = 0.12
    local last_corner_search = 0
    local corner_params = RaycastParams.new()
    corner_params.FilterType = Enum.RaycastFilterType.Exclude
    corner_params.IgnoreWater = true
    local corner_directions = table.create(5)

    local function target_part_alive(part)
        if not part or not part.Parent then return false end
        local humanoid = part.Parent:FindFirstChildOfClass("Humanoid")
        return not humanoid or humanoid.Health > 0
    end
    
    cheat.utility.new_heartbeat(LPH_NO_VIRTUALIZE(function()
        local now = tick()
        if silent_aim.random_part and now - random_part_timer > (1 / 50) then
            random_part_timer = now
            silent_aim.part = available_random_parts[math.random(1, #available_random_parts)]
        end
        
        local indtxt = ""
        local rage_active = rage_bot_active()
        local trigger_active = triggerbot_active()
        local tp_tbot = cheat.Toggles and cheat.Toggles.tpkill_enabled and feature_active(cheat.Toggles.tpkill_enabled.Value, 'tpkill_key') and cheat.Toggles.tpkill_autotbot and cheat.Toggles.tpkill_autotbot.Value
        local needs_target = silent_aim_active()
            or rage_active
            or trigger_active
            or tp_tbot
            or autoshoot
            or silent_aim.target_chams
            or silent_aim.crosshair_status
            or silent_aim.indicator
            or silent_aim.target_line

        if not needs_target then
            silent_aim.target_part = nil
            silent_aim.is_npc = false
            silent_aim.isvisible = false
            silent_aim.manipulated = false
            silent_aim.manipulated_origin = nil
            silent_aim.indicator_text = ""
            if silent_aim._trigger_held then
                silent_aim._trigger_held = false
                if mouse1release then mouse1release() end
            end
            return
        end

        local active_target_interval = (rage_active or trigger_active or tp_tbot or autoshoot or silent_aim_active()) and target_scan_interval or 0.08
        if now - last_target_scan >= active_target_interval or not target_part_alive(silent_aim.target_part) then
            last_target_scan = now
            silent_aim.target_part, silent_aim.is_npc = get_closest_target(silent_aim.fov, silent_aim.fov_size, silent_aim.part, silent_aim.target_npc, rage_active, silent_aim.rage_max_dist, silent_aim.target_heli, silent_aim.target_players);
        end
        
        silent_aim.manipulated = false
        local old_origin = silent_aim.manipulated_origin
        silent_aim.manipulated_origin = nil
        if silent_aim.target_part then
            local tp_active = cheat.Toggles and cheat.Toggles.tpkill_enabled and feature_active(cheat.Toggles.tpkill_enabled.Value, 'tpkill_key')
            if silent_aim.corner_shoot and not tp_active then
                local hitpart = silent_aim.target_part
                local camera = workspace.CurrentCamera
                if camera then
                    local base_pos = camera.CFrame.Position
                    local target_pos = hitpart.Position
                    if lift_hitboxes_active() then
                        local lift_h = silent_aim.lift_hitboxes_height or 2
                        target_pos = target_pos + Vector3.new(0, lift_h, 0)
                    end
                    local nocollision = workspace:FindFirstChild("NoCollision")
                    if nocollision then
                        corner_params.FilterDescendantsInstances = {LocalPlayer.Character, camera, nocollision}
                    else
                        corner_params.FilterDescendantsInstances = {LocalPlayer.Character, camera}
                    end
                    
                    local res = workspace:Raycast(base_pos, target_pos - base_pos, corner_params)
                    if not res or (res.Instance and res.Instance:IsDescendantOf(hitpart.Parent)) then
                        silent_aim.isvisible = true
                    else
                        silent_aim.isvisible = false
                        local found_origin = nil
                        local max_dist = math.min(15, silent_aim.corner_shoot_dist)

                        if old_origin and (old_origin - base_pos).Magnitude <= (max_dist + 3) then
                            local to_old = workspace:Raycast(base_pos, old_origin - base_pos, corner_params)
                            if not to_old then
                                local old_res = workspace:Raycast(old_origin, target_pos - old_origin, corner_params)
                                if not old_res or (old_res.Instance and old_res.Instance:IsDescendantOf(hitpart.Parent)) then
                                    found_origin = old_origin
                                end
                            end
                        end
                        
                        if not found_origin and (now - last_corner_search) >= corner_search_interval then
                            last_corner_search = now
                            local right = camera.CFrame.RightVector
                            local up = camera.CFrame.UpVector
                            corner_directions[1] = right
                            corner_directions[2] = -right
                            corner_directions[3] = up
                            corner_directions[4] = (right + up).Unit
                            corner_directions[5] = (-right + up).Unit
                            
                            for d = 1, max_dist, 1 do
                                for i = 1, 5 do
                                    local dir = corner_directions[i]
                                local offset = dir * d
                                local origin = base_pos + offset
                                local to_origin_res = workspace:Raycast(base_pos, offset, corner_params)
                                if not to_origin_res then
                                    local res = workspace:Raycast(origin, target_pos - origin, corner_params)
                                    if not res or (res.Instance and res.Instance:IsDescendantOf(hitpart.Parent)) then
                                        local buffered_offset = dir * (d + 1.5)
                                        local buffered_origin = base_pos + buffered_offset
                                        local b_to_orig = workspace:Raycast(base_pos, buffered_offset, corner_params)
                                        if not b_to_orig then
                                            local b_res = workspace:Raycast(buffered_origin, target_pos - buffered_origin, corner_params)
                                            if not b_res or (b_res.Instance and b_res.Instance:IsDescendantOf(hitpart.Parent)) then
                                                found_origin = buffered_origin
                                                break
                                            end
                                        end
                                        
                                        if not found_origin then
                                            found_origin = origin
                                            break
                                        end
                                    end
                                end
                            end
                            if found_origin then break end
                            end
                        end
                        
                        if found_origin then
                            silent_aim.manipulated = true
                            silent_aim.manipulated_origin = found_origin
                        else
                            silent_aim.manipulated_origin = nil
                        end
                    end
                end
            else
                silent_aim.isvisible = is_visible(Camera.CFrame, silent_aim.target_part.Parent, silent_aim.target_part) or false
            end
        else
            silent_aim.isvisible = false
        end

        if silent_aim.target_part then
            indtxt = indtxt..(silent_aim.target_part.Parent.Name)
            if silent_aim.isvisible then
                indtxt = indtxt.." (visible)"
            end
            if silent_aim.is_npc then
                indtxt = indtxt.." (ai)"
            end
        else
            indtxt = ""
        end
        silent_aim.indicator_text = indtxt
        if autoshoot then
            cheat.shoot_weapon_packet(silent_aim.isvisible, shootspeed, packetpred, packetscan, packetthruscan)
        end
        
        local triggerable = silent_aim.isvisible
        if silent_aim.triggerbot_manipulation and silent_aim.manipulated_origin ~= nil then
            triggerable = true
        end
        
        if trigger_active and not triggerable then
            local alt_part, alt_npc = get_closest_target(silent_aim.fov, silent_aim.fov_size, silent_aim.part, silent_aim.target_npc, false, 0, silent_aim.target_heli, silent_aim.target_players, true, silent_aim.triggerbot_manipulation, silent_aim.manipulated_origin)
            if alt_part then
                silent_aim.target_part = alt_part
                silent_aim.is_npc = alt_npc
                triggerable = true
            end
        end

        if (trigger_active or rage_active or tp_tbot) and silent_aim.target_part and triggerable then
            if not silent_aim._trigger_held then
                silent_aim._trigger_held = true
                if mouse1press then mouse1press() end
            end
        else
            if silent_aim._trigger_held then
                silent_aim._trigger_held = false
                if mouse1release then mouse1release() end
            end
        end
    end))
end
local esp_master_enabled = false
local refresh_object_esp = nil

do
    local espb = ui.box.esp:AddTab("Player ESP")
    local es = cheat.EspLibrary.settings.enemy
    local infinite_range_enabled = false

    local function any_player_esp_enabled()
        return esp_master_enabled and (
            infinite_range_enabled
            or es.realname
            or es.displayname
            or es.health
            or es.dist
            or es.weapon
            or es.skeleton
            or es.chams
            or es.high_kd_marker
        )
    end

    local function refresh_player_esp()
        es.box = false
        es.box_fill = false
        es.box_outline = false
        es.box_outline_vis = false
        es.enabled = any_player_esp_enabled()
        cheat.EspLibrary.icaca()
    end

    espb:AddToggle('espswitch',{ Text = 'ESP Master Switch', Default = false, Callback = function(c)
        esp_master_enabled = c
        refresh_player_esp()
        if refresh_object_esp then
            refresh_object_esp()
        end
    end})
    espb:AddDropdown('espfont',{ Values = { 'UI', 'System', 'Plex', 'Monospace' }, Default = 4, Multi = false, Text = 'ESP Font', Callback = function(a)
        local font_map = {
            UI = Drawing.Fonts.UI,
            System = Drawing.Fonts.System,
            Plex = Drawing.Fonts.Plex,
            Monospace = Drawing.Fonts.Monospace,
        }
        cheat.EspLibrary.main_settings.textFont = font_map[a] or Drawing.Fonts.Monospace
        cheat.EspLibrary.icaca()
    end})
    espb:AddSlider('espfontsize', { Text = 'ESP Font Size', Default = 13, Min = 1, Max = 30, Rounding = 0, Compact = true, Callback = function(b)
        cheat.EspLibrary.main_settings.textSize = b
        cheat.EspLibrary.icaca()
    end})
    espb:AddToggle('espdistancelimit',{ Text = 'Max Distance Limit', Default = false, Callback = function(c)
        cheat.EspLibrary.main_settings.distancelimit = c
        cheat.EspLibrary.icaca()
    end})
    espb:AddSlider('espmaxdistance', { Text = 'Max ESP Distance', Default = 5000, Min = 100, Max = 5000, Rounding = 0, Compact = true, Callback = function(v)
        cheat.EspLibrary.main_settings.maxdistance = v
    end})
    espb:AddToggle('espinfinite',{ Text = 'Infinite Range', Default = false, Callback = function(c)
        infinite_range_enabled = c
        cheat.EspLibrary.main_settings.infiniterange = c
        refresh_player_esp()
    end})

    espb:AddToggle('esprealname',{ Text = 'Name ESP', Default = false, Callback = function(c)
        es.realname = c
        refresh_player_esp()
    end}):AddColorPicker('esprealnamecolor',{ Default = Color3.new(1, 1, 1), Title = 'Name Color', Transparency = 1, Callback = function(a, alpha)
        es.realname_color[1] = a
        es.realname_color[2] = alpha or es.realname_color[2]
        cheat.EspLibrary.icaca()
    end})
    local esprealnameopacity = espb:AddSlider('esprealnameopacity', { Text = 'Name Opacity', Default = 100, Min = 1, Max = 100, Rounding = 0, Compact = true, Callback = function(v)
        es.realname_color[2] = v / 100
        cheat.EspLibrary.icaca()
    end})
    esprealnameopacity:SetVisible(false)
    local esprealnameoutline = espb:AddToggle('esprealnameoutline',{ Text = 'Name Outline', Default = false, Callback = function(c)
        es.realname_outline = c
        cheat.EspLibrary.icaca()
    end}):AddColorPicker('esprealnameoutlinecolor',{ Default = Color3.new(), Title = 'Name Outline Color', Transparency = 0, Callback = function(a)
        es.realname_outline_color = a
        cheat.EspLibrary.icaca()
    end})
    esprealnameoutline:SetVisible(false)
    local esprealnameoutlinevis = espb:AddToggle('esprealnameoutlinevis',{ Text = 'Name Outline Visible Color', Default = false, Callback = function(c)
        es.realname_outline_vis = c
        cheat.EspLibrary.icaca()
    end}):AddColorPicker('esprealnameoutlineviscolor',{ Default = Color3.new(), Title = 'Visible Name Outline Color', Transparency = 0, Callback = function(a)
        es.realname_outline_vis_color = a
        cheat.EspLibrary.icaca()
    end})
    esprealnameoutlinevis:SetVisible(false)

    espb:AddToggle('espdisplayname',{ Text = 'Display Name ESP', Default = false, Callback = function(c)
        es.displayname = c
        refresh_player_esp()
    end}):AddColorPicker('espdisplaynamecolor',{ Default = Color3.new(1, 1, 1), Title = 'Display Name Color', Transparency = 1, Callback = function(a, alpha)
        es.displayname_color[1] = a
        es.displayname_color[2] = alpha or es.displayname_color[2]
        cheat.EspLibrary.icaca()
    end})
    local espdisplaynameopacity = espb:AddSlider('espdisplaynameopacity', { Text = 'Display Name Opacity', Default = 100, Min = 1, Max = 100, Rounding = 0, Compact = true, Callback = function(v)
        es.displayname_color[2] = v / 100
        cheat.EspLibrary.icaca()
    end})
    espdisplaynameopacity:SetVisible(false)
    local espdisplaynameoutline = espb:AddToggle('espdisplaynameoutline',{ Text = 'Display Name Outline', Default = false, Callback = function(c)
        es.displayname_outline = c
        cheat.EspLibrary.icaca()
    end}):AddColorPicker('espdisplaynameoutlinecolor',{ Default = Color3.new(), Title = 'Display Name Outline Color', Transparency = 0, Callback = function(a)
        es.displayname_outline_color = a
        cheat.EspLibrary.icaca()
    end})
    espdisplaynameoutline:SetVisible(false)
    local espdisplaynameoutlinevis = espb:AddToggle('espdisplaynameoutlinevis',{ Text = 'Display Name Outline Visible Color', Default = false, Callback = function(c)
        es.displayname_outline_vis = c
        cheat.EspLibrary.icaca()
    end}):AddColorPicker('espdisplaynameoutlineviscolor',{ Default = Color3.new(), Title = 'Visible Display Name Outline Color', Transparency = 0, Callback = function(a)
        es.displayname_outline_vis_color = a
        cheat.EspLibrary.icaca()
    end})
    espdisplaynameoutlinevis:SetVisible(false)

    espb:AddToggle('esphealth', { Text = 'Health ESP', Default = false, Callback = function(c)
        es.health = c
        refresh_player_esp()
    end}):AddColorPicker('esphealthcolortop',{ Default = Color3.new(0, 1, 0), Title = 'Health Color Top', Transparency = 0, Callback = function(a)
        es.health_color_top = a
        cheat.EspLibrary.icaca()
    end}):AddColorPicker('esphealthcolorbottom',{ Default = Color3.new(1, 0, 0), Title = 'Health Color Bottom', Transparency = 0, Callback = function(a)
        es.health_color_bottom = a
        cheat.EspLibrary.icaca()
    end})
    espb:AddSlider('esphealththickness', { Text = 'Health Bar Thickness', Default = 2, Min = 1, Max = 10, Rounding = 1, Compact = true, Callback = function(v)
        es.health_thickness = v
        cheat.EspLibrary.icaca()
    end})
    espb:AddSlider('esphealthglowsize', { Text = 'Health Glow Size', Default = 5, Min = 1, Max = 20, Rounding = 1, Compact = true, Callback = function(v)
        es.health_glow_size = v
        cheat.EspLibrary.icaca()
    end})

    espb:AddToggle('espdistance',{ Text = 'Distance ESP', Default = false, Callback = function(c)
        es.dist = c
        refresh_player_esp()
    end}):AddColorPicker('espdistancecolor',{ Default = Color3.new(1, 1, 1), Title = 'Distance Color', Transparency = 1, Callback = function(a, alpha)
        es.dist_color[1] = a
        es.dist_color[2] = alpha or es.dist_color[2]
        cheat.EspLibrary.icaca()
    end})
    local espdistanceopacity = espb:AddSlider('espdistanceopacity', { Text = 'Distance Opacity', Default = 100, Min = 1, Max = 100, Rounding = 0, Compact = true, Callback = function(v)
        es.dist_color[2] = v / 100
        cheat.EspLibrary.icaca()
    end})
    espdistanceopacity:SetVisible(false)
    local espdistanceoutline = espb:AddToggle('espdistanceoutline',{ Text = 'Distance Outline', Default = false, Callback = function(c)
        es.dist_outline = c
        cheat.EspLibrary.icaca()
    end}):AddColorPicker('espdistanceoutlinecolor',{ Default = Color3.new(), Title = 'Distance Outline Color', Transparency = 0, Callback = function(a)
        es.dist_outline_color = a
        cheat.EspLibrary.icaca()
    end})
    espdistanceoutline:SetVisible(false)
    local espdistanceoutlinevis = espb:AddToggle('espdistanceoutlinevis',{ Text = 'Distance Outline Visible Color', Default = false, Callback = function(c)
        es.dist_outline_vis = c
        cheat.EspLibrary.icaca()
    end}):AddColorPicker('espdistanceoutlineviscolor',{ Default = Color3.new(), Title = 'Visible Distance Outline Color', Transparency = 0, Callback = function(a)
        es.dist_outline_vis_color = a
        cheat.EspLibrary.icaca()
    end})
    espdistanceoutlinevis:SetVisible(false)

    espb:AddToggle('espweapon', { Text = 'Weapon ESP', Default = false, Callback = function(c)
        es.weapon = c
        refresh_player_esp()
    end}):AddColorPicker('espweaponcolor',{ Default = Color3.new(1, 1, 1), Title = 'Weapon Color', Transparency = 1, Callback = function(a, alpha)
        es.weapon_color[1] = a
        es.weapon_color[2] = alpha or es.weapon_color[2]
        cheat.EspLibrary.icaca()
    end})
    local espweaponopacity = espb:AddSlider('espweaponopacity', { Text = 'Weapon Opacity', Default = 100, Min = 1, Max = 100, Rounding = 0, Compact = true, Callback = function(v)
        es.weapon_color[2] = v / 100
        cheat.EspLibrary.icaca()
    end})
    espweaponopacity:SetVisible(false)
    local espweaponoutline = espb:AddToggle('espweaponoutline',{ Text = 'Weapon Outline', Default = false, Callback = function(c)
        es.weapon_outline = c
        cheat.EspLibrary.icaca()
    end}):AddColorPicker('espweaponoutlinecolor',{ Default = Color3.new(), Title = 'Weapon Outline Color', Transparency = 0, Callback = function(a)
        es.weapon_outline_color = a
        cheat.EspLibrary.icaca()
    end})
    espweaponoutline:SetVisible(false)
    local espweaponoutlinevis = espb:AddToggle('espweaponoutlinevis',{ Text = 'Weapon Outline Visible Color', Default = false, Callback = function(c)
        es.weapon_outline_vis = c
        cheat.EspLibrary.icaca()
    end}):AddColorPicker('espweaponoutlineviscolor',{ Default = Color3.new(), Title = 'Visible Weapon Outline Color', Transparency = 0, Callback = function(a)
        es.weapon_outline_vis_color = a
        cheat.EspLibrary.icaca()
    end})
    espweaponoutlinevis:SetVisible(false)

    espb:AddToggle('espskeleton',{ Text = 'Skeleton ESP', Default = false, Callback = function(c)
        es.skeleton = c
        refresh_player_esp()
    end}):AddColorPicker('espskeletoncolor',{ Default = Color3.new(1, 1, 1), Title = 'Skeleton Color', Transparency = 1, Callback = function(a, alpha)
        es.skeleton_color[1] = a
        es.skeleton_color[2] = alpha or es.skeleton_color[2]
        cheat.EspLibrary.icaca()
    end})
    local espskeletonopacity = espb:AddSlider('espskeletonopacity', { Text = 'Skeleton Opacity', Default = 100, Min = 1, Max = 100, Rounding = 0, Compact = true, Callback = function(v)
        es.skeleton_color[2] = v / 100
        cheat.EspLibrary.icaca()
    end})
    espskeletonopacity:SetVisible(false)

    espb:AddToggle('espchams', { Text = 'Chams', Default = false, Callback = function(c)
        es.chams = c; refresh_player_esp()
    end}):AddColorPicker('espchamscolor',{ Default = Color3.new(1, 1, 1), Title = 'Chams Color', Transparency = 0.5, Callback = function(a, alpha)
        es.cham_color = a
        es.cham_transparency = alpha or es.cham_transparency
        es.chams_hidden_color[1] = a
        es.chams_visible_color[1] = a
        es.chams_fill_color[1] = a
        es.chams_hidden_color[2] = es.cham_transparency
        es.chams_visible_color[2] = es.cham_transparency
        es.chams_fill_color[2] = es.cham_transparency
        cheat.EspLibrary.icaca()
    end})
    espb:AddDropdown('espchams_mode', { Text = 'Chams Mode', Default = 'Always Show Chams', Values = { 'Always Show Chams', 'Only When Visible Show Chams' }, Callback = function(v)
        if v == 'Always Show Chams' then
            es.chams_hidden = true
            es.chams_visible = false
        else
            es.chams_hidden = false
            es.chams_visible = true
        end
        es.chams_visible_only = es.chams_visible
        cheat.EspLibrary.icaca()
    end})
    local espchamstransparency = espb:AddSlider('espchamstransparency', { Text = 'Chams Transparency', Default = 50, Min = 0, Max = 100, Rounding = 0, Compact = true, Callback = function(v)
        es.cham_transparency = v / 100
        es.chams_hidden_color[2] = es.cham_transparency
        es.chams_visible_color[2] = es.cham_transparency
        es.chams_fill_color[2] = es.cham_transparency
        cheat.EspLibrary.icaca()
    end})
    espchamstransparency:SetVisible(false)
    espb:AddToggle('esp_high_kd_marker', { Text = 'Highlight High KD (>5)', Default = false, Callback = function(c)
        es.high_kd_marker = c; refresh_player_esp()
    end}):AddColorPicker('esphighkdcolor', { Default = Color3.fromRGB(255, 0, 0), Title = 'High KD Chams Color', Transparency = 0.15, Callback = function(a, alpha)
        es.high_kd_outline_color = a
        es.high_kd_chams_transparency = alpha or es.high_kd_chams_transparency
        cheat.EspLibrary.icaca()
    end})
    local esphighkdtransparency = espb:AddSlider('esphighkdtransparency', { Text = 'High KD Chams Transparency', Default = 15, Min = 0, Max = 100, Rounding = 0, Compact = true, Callback = function(v)
        es.high_kd_chams_transparency = math.clamp(v / 100, 0, 1)
        cheat.EspLibrary.icaca()
    end})
    esphighkdtransparency:SetVisible(false)
    refresh_player_esp()
end
do
    local object_tab = ui.box.object_esp:AddTab("Object ESP")
    local OBJECT_BILLBOARD_NAME = "GhostHookObjectESP"
    local OBJECT_HIGHLIGHT_NAME = "GhostHookObjectHighlight"
    local container_values = {
        "SupplyDropEDF",
        "SupplyDropMilitary",
        "MilitaryCrate",
        "SmallMilitaryBox",
        "LargeMilitaryBox",
        "LargeABPOPABox",
        "Safe",
        "CashRegister",
        "GrenadeCrate",
        "HiddenCache",
        "KGBBag",
        "Toolbox",
        "SportBag",
        "SmallShippingCrate",
        "LargeShippingCrate",
        "FilingCabinet",
        "Fridge",
        "MedBag",
        "SatchelBag",
    }
    local object_esp = {
        dropped = false,
        dropped_color = Color3.fromRGB(255, 100, 0),
        dropped_size = 11,
        corpse = false,
        corpse_color = Color3.fromRGB(0, 255, 0),
        corpse_size = 11,
        container = false,
        container_color = Color3.fromRGB(0, 255, 255),
        container_size = 11,
        container_whitelist = {},
        exit = false,
        exit_color = Color3.fromRGB(255, 0, 255),
        exit_size = 11,
        quest = false,
        quest_color = Color3.fromRGB(45, 150, 99),
        quest_size = 11,
        vehicle = false,
        vehicle_color = Color3.fromRGB(95, 25, 21),
        vehicle_size = 11,
        ai_highlight = false,
        ai_highlight_color = Color3.fromRGB(255, 0, 0),
        ai_highlight_transparency = 0.5,
        ai_name = false,
        ai_name_color = Color3.fromRGB(255, 255, 0),
        ai_name_size = 11,
    }

    for _, name in ipairs(container_values) do
        object_esp.container_whitelist[name] = true
    end

    local function get_adornee(object)
        if not object then return nil end
        if object:IsA("BasePart") then
            return object
        end
        if object:IsA("Model") then
            return object.PrimaryPart or object:FindFirstChild("HumanoidRootPart") or object:FindFirstChild("Head") or object:FindFirstChildWhichIsA("BasePart", true)
        end
        return object:FindFirstChildWhichIsA("BasePart", true)
    end

    local function remove_billboard(object)
        if not object then return end
        local old = object:FindFirstChild(OBJECT_BILLBOARD_NAME)
        if old then
            old:Destroy()
        end
    end

    local function make_billboard(object, text, color, size, offset)
        if not object then return end
        local adornee = get_adornee(object)
        if not adornee then return end
        remove_billboard(object)

        local gui = Instance.new("BillboardGui")
        gui.Name = OBJECT_BILLBOARD_NAME
        gui.Adornee = adornee
        gui.AlwaysOnTop = true
        gui.Size = UDim2.new(0, 220, 0, 32)
        gui.StudsOffset = offset or Vector3.new(0, 2, 0)
        gui.Parent = object

        local label = Instance.new("TextLabel")
        label.Name = "Text"
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Font = Enum.Font.SourceSansBold
        label.Text = tostring(text or "")
        label.TextColor3 = color
        label.TextSize = size
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.Parent = gui

        return gui, label
    end

    local function get_amount(object)
        local props = object and object:FindFirstChild("ItemProperties")
        if props then
            return props:GetAttribute("Amount") or 1
        end
        return 1
    end

    local function is_corpse(object)
        return object and object:FindFirstChildOfClass("Humanoid") ~= nil
    end

    local function apply_dropped_object(object)
        if not object or object:IsA("BillboardGui") then return end
        if not esp_master_enabled then
            remove_billboard(object)
            return
        end
        if is_corpse(object) then
            if object_esp.corpse then
                local color = object.Name == LocalPlayer.Name and Color3.fromRGB(255, 102, 0) or object_esp.corpse_color
                make_billboard(object, object.Name .. " | Corpse", color, object_esp.corpse_size, Vector3.new(0, 2, 0))
            else
                remove_billboard(object)
            end
        elseif object_esp.dropped then
            make_billboard(object, object.Name .. " " .. tostring(get_amount(object)) .. "X | Item", object_esp.dropped_color, object_esp.dropped_size, Vector3.new(0, 1.5, 0))
        else
            remove_billboard(object)
        end
    end

    local function refresh_dropped()
        local dropped = workspace:FindFirstChild("DroppedItems")
        if not dropped then return end
        for _, object in ipairs(dropped:GetChildren()) do
            apply_dropped_object(object)
        end
    end

    local function walk_container(root, callback)
        if not root then return end
        for _, child in ipairs(root:GetChildren()) do
            if child:IsA("Folder") then
                walk_container(child, callback)
            else
                callback(child)
            end
        end
    end

    local function apply_container(object)
        if not object or object:IsA("BillboardGui") then return end
        if not esp_master_enabled then
            remove_billboard(object)
            return
        end
        if object_esp.container and object_esp.container_whitelist[object.Name] then
            make_billboard(object, object.Name .. " | Container", object_esp.container_color, object_esp.container_size, Vector3.new(0, 2, 0))
        else
            remove_billboard(object)
        end
    end

    local function refresh_containers()
        local containers = workspace:FindFirstChild("Containers")
        if not containers then return end
        walk_container(containers, apply_container)
    end

    local function get_exit_folder()
        local no_collision = workspace:FindFirstChild("NoCollision")
        return no_collision and no_collision:FindFirstChild("ExitLocations")
    end

    local function apply_exit(object)
        if not object or object:IsA("BillboardGui") then return end
        if not esp_master_enabled then
            remove_billboard(object)
            return
        end
        if object_esp.exit then
            make_billboard(object, object.Name .. " | Extract 0 Studs", object_esp.exit_color, object_esp.exit_size, Vector3.new(0, 2, 0))
        else
            remove_billboard(object)
        end
    end

    local function refresh_exits()
        local exits = get_exit_folder()
        if not exits then return end
        for _, object in ipairs(exits:GetChildren()) do
            apply_exit(object)
        end
    end

    local function apply_quest(object)
        if not object or object:IsA("BillboardGui") then return end
        if not esp_master_enabled then
            remove_billboard(object)
            return
        end
        if object_esp.quest and object:GetAttribute("Hidden") == false then
            make_billboard(object, object.Name .. " | Quest", object_esp.quest_color, object_esp.quest_size, Vector3.new(0, 2, 0))
        else
            remove_billboard(object)
        end
    end

    local function refresh_quests()
        local quests = workspace:FindFirstChild("QuestItems")
        if not quests then return end
        for _, object in ipairs(quests:GetChildren()) do
            apply_quest(object)
        end
    end

    local function apply_vehicle(object)
        if not object or object:IsA("BillboardGui") then return end
        if not esp_master_enabled then
            remove_billboard(object)
            return
        end
        if object_esp.vehicle then
            make_billboard(object, object.Name .. " | Vehicle", object_esp.vehicle_color, object_esp.vehicle_size, Vector3.new(0, 3, 0))
        else
            remove_billboard(object)
        end
    end

    local function refresh_vehicles()
        local vehicles = workspace:FindFirstChild("Vehicles")
        if not vehicles then return end
        for _, object in ipairs(vehicles:GetChildren()) do
            apply_vehicle(object)
        end
    end

    local function remove_ai_highlight(model)
        local old = model and model:FindFirstChild(OBJECT_HIGHLIGHT_NAME)
        if old then
            old:Destroy()
        end
    end

    local function apply_ai(model)
        if not (model and model:IsA("Model")) then return end
        if not esp_master_enabled then
            remove_billboard(model)
            remove_ai_highlight(model)
            return
        end
        local humanoid = model:FindFirstChildOfClass("Humanoid")
        if not (humanoid and humanoid.Health > 0) then
            remove_billboard(model)
            remove_ai_highlight(model)
            return
        end

        if object_esp.ai_name then
            make_billboard(model, model.Name .. " | NPC", object_esp.ai_name_color, object_esp.ai_name_size, Vector3.new(0, 1.75, 0))
        else
            remove_billboard(model)
        end

        if object_esp.ai_highlight then
            local hl = model:FindFirstChild(OBJECT_HIGHLIGHT_NAME)
            if not hl then
                hl = Instance.new("Highlight")
                hl.Name = OBJECT_HIGHLIGHT_NAME
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = model
            end
            hl.FillColor = object_esp.ai_highlight_color
            hl.OutlineColor = object_esp.ai_highlight_color
            hl.FillTransparency = object_esp.ai_highlight_transparency
            hl.OutlineTransparency = math.clamp(object_esp.ai_highlight_transparency * 0.5, 0, 1)
        else
            remove_ai_highlight(model)
        end
    end

    local function refresh_ai()
        local zones = workspace:FindFirstChild("AiZones")
        if not zones then return end
        for _, zone in ipairs(zones:GetChildren()) do
            for _, model in ipairs(zone:GetChildren()) do
                apply_ai(model)
            end
        end
    end

    local function refresh_all_objects()
        refresh_dropped()
        refresh_containers()
        refresh_exits()
        refresh_quests()
        refresh_vehicles()
        refresh_ai()
    end
    refresh_object_esp = refresh_all_objects

    object_tab:AddToggle('object_dropped_esp', { Text = 'Dropped Items ESP', Default = false, Callback = function(v)
        object_esp.dropped = v
        refresh_dropped()
    end}):AddColorPicker('object_dropped_color', { Default = object_esp.dropped_color, Title = 'Dropped Item Color', Transparency = 0, Callback = function(v)
        object_esp.dropped_color = v
        refresh_dropped()
    end})
    object_tab:AddSlider('object_dropped_size', { Text = 'Dropped Item Text Size', Default = 11, Min = 1, Max = 20, Rounding = 0, Compact = true, Callback = function(v)
        object_esp.dropped_size = v
        refresh_dropped()
    end})

    object_tab:AddToggle('object_corpse_esp', { Text = 'Corpse ESP', Default = false, Callback = function(v)
        object_esp.corpse = v
        refresh_dropped()
    end}):AddColorPicker('object_corpse_color', { Default = object_esp.corpse_color, Title = 'Corpse Color', Transparency = 0, Callback = function(v)
        object_esp.corpse_color = v
        refresh_dropped()
    end})
    object_tab:AddSlider('object_corpse_size', { Text = 'Corpse Text Size', Default = 11, Min = 1, Max = 20, Rounding = 0, Compact = true, Callback = function(v)
        object_esp.corpse_size = v
        refresh_dropped()
    end})

    object_tab:AddToggle('object_container_esp', { Text = 'Container ESP', Default = false, Callback = function(v)
        object_esp.container = v
        refresh_containers()
    end}):AddColorPicker('object_container_color', { Default = object_esp.container_color, Title = 'Container Color', Transparency = 0, Callback = function(v)
        object_esp.container_color = v
        refresh_containers()
    end})
    object_tab:AddDropdown('object_container_whitelist', { Text = 'Container Whitelist', Default = container_values, Values = container_values, Multi = true, Callback = function(values)
        object_esp.container_whitelist = {}
        for _, name in ipairs(values or {}) do
            object_esp.container_whitelist[name] = true
        end
        refresh_containers()
    end})
    object_tab:AddSlider('object_container_size', { Text = 'Container Text Size', Default = 11, Min = 1, Max = 20, Rounding = 0, Compact = true, Callback = function(v)
        object_esp.container_size = v
        refresh_containers()
    end})

    object_tab:AddToggle('object_exit_esp', { Text = 'Exit ESP', Default = false, Callback = function(v)
        object_esp.exit = v
        refresh_exits()
    end}):AddColorPicker('object_exit_color', { Default = object_esp.exit_color, Title = 'Exit Color', Transparency = 0, Callback = function(v)
        object_esp.exit_color = v
        refresh_exits()
    end})
    object_tab:AddSlider('object_exit_size', { Text = 'Exit Text Size', Default = 11, Min = 1, Max = 20, Rounding = 0, Compact = true, Callback = function(v)
        object_esp.exit_size = v
        refresh_exits()
    end})

    object_tab:AddToggle('object_quest_esp', { Text = 'Quest Item ESP', Default = false, Callback = function(v)
        object_esp.quest = v
        refresh_quests()
    end}):AddColorPicker('object_quest_color', { Default = object_esp.quest_color, Title = 'Quest Item Color', Transparency = 0, Callback = function(v)
        object_esp.quest_color = v
        refresh_quests()
    end})
    object_tab:AddSlider('object_quest_size', { Text = 'Quest Item Text Size', Default = 11, Min = 1, Max = 20, Rounding = 0, Compact = true, Callback = function(v)
        object_esp.quest_size = v
        refresh_quests()
    end})

    object_tab:AddToggle('object_vehicle_esp', { Text = 'Vehicle ESP', Default = false, Callback = function(v)
        object_esp.vehicle = v
        refresh_vehicles()
    end}):AddColorPicker('object_vehicle_color', { Default = object_esp.vehicle_color, Title = 'Vehicle Color', Transparency = 0, Callback = function(v)
        object_esp.vehicle_color = v
        refresh_vehicles()
    end})
    object_tab:AddSlider('object_vehicle_size', { Text = 'Vehicle Text Size', Default = 11, Min = 1, Max = 20, Rounding = 0, Compact = true, Callback = function(v)
        object_esp.vehicle_size = v
        refresh_vehicles()
    end})

    object_tab:AddToggle('object_ai_chams', { Text = 'AI Chams ESP', Default = false, Callback = function(v)
        object_esp.ai_highlight = v
        refresh_ai()
    end}):AddColorPicker('object_ai_chams_color', { Default = object_esp.ai_highlight_color, Title = 'AI Chams Color', Transparency = 0.5, Callback = function(v, alpha)
        object_esp.ai_highlight_color = v
        object_esp.ai_highlight_transparency = alpha or object_esp.ai_highlight_transparency
        refresh_ai()
    end})
    local object_ai_chams_transparency = object_tab:AddSlider('object_ai_chams_transparency', { Text = 'AI Chams Transparency', Default = 50, Min = 0, Max = 100, Rounding = 0, Compact = true, Callback = function(v)
        object_esp.ai_highlight_transparency = math.clamp(v / 100, 0, 1)
        refresh_ai()
    end})
    object_ai_chams_transparency:SetVisible(false)
    object_tab:AddToggle('object_ai_nametag', { Text = 'AI Nametag ESP', Default = false, Callback = function(v)
        object_esp.ai_name = v
        refresh_ai()
    end}):AddColorPicker('object_ai_nametag_color', { Default = object_esp.ai_name_color, Title = 'AI Nametag Color', Transparency = 0, Callback = function(v)
        object_esp.ai_name_color = v
        refresh_ai()
    end})
    object_tab:AddSlider('object_ai_size', { Text = 'AI ESP Text Size', Default = 11, Min = 1, Max = 20, Rounding = 0, Compact = true, Callback = function(v)
        object_esp.ai_name_size = v
        refresh_ai()
    end})

    local dropped = workspace:FindFirstChild("DroppedItems")
    if dropped then
        cheat.utility.track_connection(dropped.ChildAdded:Connect(function(object)
            task.defer(apply_dropped_object, object)
        end))
    end

    local containers = workspace:FindFirstChild("Containers")
    if containers then
        cheat.utility.track_connection(containers.DescendantAdded:Connect(function(object)
            task.defer(function()
                if object and not object:IsA("Folder") then
                    apply_container(object)
                end
            end)
        end))
    end

    local exits = get_exit_folder()
    if exits then
        cheat.utility.track_connection(exits.ChildAdded:Connect(function(object)
            task.defer(apply_exit, object)
        end))
    end

    local quests = workspace:FindFirstChild("QuestItems")
    if quests then
        cheat.utility.track_connection(quests.ChildAdded:Connect(function(object)
            task.defer(apply_quest, object)
        end))
    end

    local vehicles = workspace:FindFirstChild("Vehicles")
    if vehicles then
        cheat.utility.track_connection(vehicles.ChildAdded:Connect(function(object)
            task.defer(apply_vehicle, object)
        end))
    end

    local zones = workspace:FindFirstChild("AiZones")
    if zones then
        for _, zone in ipairs(zones:GetChildren()) do
            cheat.utility.track_connection(zone.ChildAdded:Connect(function(object)
                task.defer(apply_ai, object)
            end))
        end
        cheat.utility.track_connection(zones.ChildAdded:Connect(function(zone)
            task.defer(function()
                if zone then
                    cheat.utility.track_connection(zone.ChildAdded:Connect(function(object)
                        task.defer(apply_ai, object)
                    end))
                end
            end)
        end))
    end

    cheat.utility.new_renderstepped(function()
        if not (esp_master_enabled and object_esp.exit) then return end
        local exits_folder = get_exit_folder()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not (exits_folder and root) then return end
        for _, exit in ipairs(exits_folder:GetChildren()) do
            local gui = exit:FindFirstChild(OBJECT_BILLBOARD_NAME)
            local label = gui and gui:FindFirstChild("Text")
            local adornee = get_adornee(exit)
            if label and adornee then
                label.Text = exit.Name .. " | Extract " .. tostring(math.floor((root.Position - adornee.Position).Magnitude)) .. " Studs"
                label.TextColor3 = object_esp.exit_color
                label.TextSize = object_esp.exit_size
            end
        end
    end)

    refresh_all_objects()
end
do
    local cursor = {
        Enabled = false,
        CustomPos = false,
        Position = _Vector2new(0, 0),
        Speed = 5,
        Radius = 25,
        Color = Color3.fromRGB(180, 50, 255),
        Thickness = 1.7,
        Outline = false,
        Resize = false,
        Dot = false,
        Gap = 10,
        TheGap = false,
        Font = Drawing.Fonts.Monospace,
        Text = {
            Logo = false,
            LogoColor = Color3.new(1, 1, 1),
            Name = false,
            NameColor = Color3.new(1, 1, 1),
            LogoFadingOffset = 0,
        }
    }
    local CrosshairTab = ui.box.crosshair:AddTab("Crosshair")
    cursor.rainbow = false
    cursor.sussy = false
    CrosshairTab:AddToggle('crosshairenable', {Text = 'Enable Crosshair',Default = false,Callback = function(first)
        cursor.Enabled = first
    end}):AddColorPicker('crosshaircolor', {Default = Color3.new(1, 1, 1),Title = 'Crosshair Color',Transparency = 0,Callback = function(Value)
        cursor.Color = Value
    end})
    CrosshairTab:AddSlider('crosshairspeed', {Text = 'Speed',Default = 3,Min = 0.1,Max = 15,Rounding = 1,Compact = true}):OnChanged(function(State)
        cursor.Speed = State / 10
    end)
    CrosshairTab:AddSlider('crosshairradius', {Text = 'Radius',Default = 25,Min = 0.1,Max = 100,Rounding = 1,Compact = true,}):OnChanged(function(State)
        cursor.Radius = State
    end)
    CrosshairTab:AddSlider('crosshairthickness', {Text = 'Thickness',Default = 1.5,Min = 0.1,Max = 10,Rounding = 1,Compact = true,}):OnChanged(function(State)
        cursor.Thickness = State
    end)
    CrosshairTab:AddSlider('crosshairgapsize', {Text = 'Gap',Default = 5,Min = 1,Max = 50,Rounding = 1,Compact = true,}):OnChanged(function(State)
        cursor.Gap = State
    end)
    CrosshairTab:AddToggle('crosshairenabledot', {Text = 'Dot',Default = false,Callback = function(first)
        cursor.Dot = first
    end})
    CrosshairTab:AddToggle('crosshairenablenazi', {Text = 'Special Mode',Default = false,Callback = function(first)
        cursor.sussy = first
        end})
        CrosshairTab:AddToggle('crosshairenablefaggot', {Text = 'Rainbow',Default = false,Callback = function(first)
        cursor.rainbow = first
    end})
    local lines = {}
    local outline = cheat.utility.new_drawing("Square", {
        Visible = true,
        Size = _Vector2new(4, 4),
        Color = Color3.fromRGB(0, 0, 0),
        Filled = true,
        ZIndex = 1,
        Transparency = 1
    })
    local dot = cheat.utility.new_drawing("Square", {
        Visible = true,
        Size = _Vector2new(2, 2),
        Color = cursor.Color,
        Filled = true,
        ZIndex = 2,
        Transparency = 1
    })
    local logotext = cheat.utility.new_drawing("Text", {
        Visible = false,
        Font = cursor.Font,
        Size = 13,
        Color = Color3.fromRGB(138, 128, 255),
        ZIndex = 3,
        Transparency = 1,
        Text = "GHOST_HOOK",
        Center = true,
        Outline = true,
    })
    local target_line = cheat.utility.new_drawing("Line", {
        Visible = false,
        Thickness = 1,
        Color = Color3.new(1, 1, 1),
        Transparency = 1,
        ZIndex = 5
    })
    local tipanel = {}
    tipanel.pos = _Vector2new(20, 350)
    tipanel.width = 250
    tipanel.height = 100
    tipanel.dragging = false
    tipanel.dragoffset = Vector2.zero
    local avatar_cache = {}
    tipanel.bg = cheat.utility.new_drawing("Square", {
        Visible = false, Filled = true,
        Color = tipanel_settings.bgcolor,
        Size = _Vector2new(tipanel.width, tipanel.height),
        Position = tipanel.pos,
        Transparency = tipanel_settings.bgtrans, ZIndex = 10,
    })
    tipanel.border = cheat.utility.new_drawing("Square", {
        Visible = false, Filled = false,
        Color = tipanel_settings.bordercolor,
        Size = _Vector2new(tipanel.width, tipanel.height),
        Position = tipanel.pos,
        Thickness = 1, Transparency = 1, ZIndex = 11,
    })
    tipanel.glow = {}
    for i = 1, 6 do
        tipanel.glow[i] = cheat.utility.new_drawing("Square", {
            Visible = false, Filled = false,
            Color = tipanel_settings.glowcolor,
            Thickness = i,
            Transparency = 0.2 - (i * 0.03),
            ZIndex = 9,
        })
    end
    tipanel.avatar = cheat.utility.new_drawing("Image", {
        Visible = false,
        Size = _Vector2new(80, 80),
        Position = tipanel.pos + _Vector2new(8, 8),
        ZIndex = 12,
    })
    tipanel.avatar_border = cheat.utility.new_drawing("Square", {
        Visible = false, Filled = false,
        Color = Color3.fromRGB(60, 60, 60),
        Size = _Vector2new(82, 82),
        Position = tipanel.pos + _Vector2new(7, 7),
        Thickness = 1, Transparency = 1, ZIndex = 11,
    })
    local label_color = Color3.fromRGB(120, 110, 180)
    local function create_label(text)
        local l = cheat.utility.new_drawing("Text", {
            Visible = false, Font = Drawing.Fonts.Plex, Size = 13,
            Color = tipanel_settings.accentcolor, Text = text, ZIndex = 12, Outline = true
        })
        local v = cheat.utility.new_drawing("Text", {
            Visible = false, Font = Drawing.Fonts.Plex, Size = 13,
            Color = Color3.new(1, 1, 1), Text = "", ZIndex = 12, Outline = true
        })
        return l, v
    end
    tipanel.labels = {}
    tipanel.values = {}
    local rows = {"user", "k / d", "vis"}
    for i, row in ipairs(rows) do
        local l, v = create_label(row)
        tipanel.labels[row] = l
        tipanel.values[row] = v
    end
    tipanel.hours = cheat.utility.new_drawing("Text", {
        Visible = false, Font = Drawing.Fonts.Plex, Size = 13,
        Color = Color3.new(1, 1, 1), Text = "0h", ZIndex = 12, Outline = true, Center = true
    })
    tipanel.hpbg = cheat.utility.new_drawing("Square", {
        Visible = false, Filled = true,
        Color = Color3.fromRGB(30, 30, 30),
        Size = _Vector2new(145, 12),
        ZIndex = 11, Transparency = 1
    })
    tipanel.hpfill = cheat.utility.new_drawing("Square", {
        Visible = false, Filled = true,
        Color = Color3.fromRGB(180, 160, 220),
        Size = _Vector2new(0, 12),
        ZIndex = 12, Transparency = 1
    })
    tipanel.hptext = cheat.utility.new_drawing("Text", {
        Visible = false, Font = Drawing.Fonts.Plex, Size = 11,
        Color = Color3.new(1, 1, 1), Text = "100/100", ZIndex = 13, Outline = true
    })

    local tpw_gui = cheat.utility.track_instance(Instance.new("ScreenGui", game:GetService("CoreGui")))
    tpw_gui.Name = "TipanelWeapons"
    tpw_gui.DisplayOrder = 1000
    tpw_gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    tpw_gui.IgnoreGuiInset = true

    local tipanel_weapons = {}
    local tipanel_attachments = {}
    
    for i = 1, 3 do
        local wp = Instance.new("ImageLabel", tpw_gui)
        wp.Visible = false
        wp.BackgroundTransparency = 0
        wp.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        wp.Size = UDim2.new(0, 50, 0, 50)
        wp.BorderSizePixel = 1
        wp.BorderColor3 = Color3.fromRGB(15, 15, 15)
        tipanel_weapons[i] = wp
        
        for j = 1, 4 do
            local att = Instance.new("ImageLabel", tpw_gui)
            att.Visible = false
            att.BackgroundTransparency = 0
            att.BackgroundColor3 = Color3.fromRGB(155, 30, 30)
            att.Size = UDim2.new(0, 16, 0, 18)
            att.ZIndex = 2
            tipanel_attachments[(i-1)*4 + j] = att
        end
    end
    for i = 1, 4 do
        local line_outline = cheat.utility.new_drawing("Line", {
            Visible = true,
            From = _Vector2new(200, 500),
            To = _Vector2new(200, 500),
            Color = Color3.fromRGB(0, 0, 0),
            Thickness = cursor.Thickness + 2.5,
            ZIndex = 1,
            Transparency = 1
        })
        local line = cheat.utility.new_drawing("Line", {
            Visible = true,
            From = _Vector2new(200, 500),
            To = _Vector2new(200, 500),
            Color = cursor.Color,
            Thickness = cursor.Thickness,
            ZIndex = 2,
            Transparency = 1
        })
        local naziline = cheat.utility.new_drawing("Line", {
            Visible = true,
            From = _Vector2new(200, 500),
            To = _Vector2new(200, 500),
            Color = cursor.Color,
            Thickness = cursor.Thickness,
            ZIndex = 2,
            Transparency = 1
        })
        lines[i] = { line, line_outline, naziline }
    end
    local angle = 0
    local transp = 0
    local reverse = false
    local function setreverse(value)
        if reverse ~= value then
            reverse = value
        end
    end
    local pos, rainbow, rotationdegree, color = Vector2.zero, 0, 0, Color3.new()
    local math_cos, math_atan, math_pi, math_sin = math.cos, math.atan, math.pi, math.sin
    local function DEG2RAD(x) return x * math_pi / 180 end
    local function RAD2DEG(x) return x * 180 / math_pi end
    cheat.utility.new_renderstepped(LPH_NO_VIRTUALIZE(function(delta)
        local target = silent_aim.target_part and silent_aim.target_part.Parent
        local info_visible = silent_aim.indicator and target ~= nil
        local target_line_visible = silent_aim.target_line and silent_aim.target_part ~= nil
        local mousepos = _Vector2new(Mouse.X, Mouse.Y + GuiInset.Y)
        tipanel.bg.Visible = info_visible
        tipanel.border.Visible = info_visible
        for _, g in ipairs(tipanel.glow) do g.Visible = info_visible end
        tipanel.avatar.Visible = info_visible
        tipanel.hours.Visible = info_visible
        tipanel.avatar_border.Visible = info_visible
        for _, l in pairs(tipanel.labels) do l.Visible = info_visible end
        for _, v in pairs(tipanel.values) do v.Visible = info_visible end
        tipanel.hpbg.Visible = info_visible
        tipanel.hpfill.Visible = info_visible
        tipanel.hptext.Visible = info_visible
        target_line.Visible = false
        
        if not info_visible then
            for i = 1, 3 do tipanel_weapons[i].Visible = false end
            for i = 1, 12 do tipanel_attachments[i].Visible = false end
        end
        if info_visible then
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and cheat.Library.Opened then
                if (mousepos - tipanel.pos).Magnitude < 50 or tipanel.dragging then
                    if not tipanel.dragging then
                        tipanel.dragging = true
                        tipanel.dragoffset = tipanel.pos - mousepos
                    end
                    tipanel.pos = mousepos + tipanel.dragoffset
                    silent_aim.tipanel_x = tipanel.pos.X
                    silent_aim.tipanel_y = tipanel.pos.Y
                end
            else
                tipanel.dragging = false
                tipanel.pos = _Vector2new(silent_aim.tipanel_x, silent_aim.tipanel_y)
            end
            local p = tipanel.pos
            tipanel.bg.Position = p
            tipanel.border.Position = p
            tipanel.bg.Color = tipanel_settings.bgcolor
            tipanel.bg.Transparency = tipanel_settings.bgtrans
            tipanel.border.Color = tipanel_settings.bordercolor
            for i, g in ipairs(tipanel.glow) do
                g.Position = p - _Vector2new(i, i)
                g.Size = tipanel.bg.Size + _Vector2new(i*2, i*2)
                g.Color = tipanel_settings.glowcolor
            end
            tipanel.avatar.Position = p + _Vector2new(8, 8)
            tipanel.avatar_border.Position = p + _Vector2new(7, 7)
            tipanel.hours.Position = p + _Vector2new(48, 92)
            local lx, rx = p.X + 100, p.X + 240
            local y_spacing = 20
            local rows = {"user", "k / d", "vis"}
            for i, row in ipairs(rows) do
                local y = p.Y + 10 + (i-1) * y_spacing
                tipanel.labels[row].Position = _Vector2new(lx, y)
                tipanel.labels[row].Color = tipanel_settings.accentcolor
                tipanel.values[row].Position = _Vector2new(rx - tipanel.values[row].TextBounds.X, y)
            end
            tipanel.hpbg.Position = p + _Vector2new(95, 75)
            tipanel.hpfill.Position = p + _Vector2new(95, 75)
            tipanel.hptext.Position = p + _Vector2new(170 - tipanel.hptext.TextBounds.X/2, 75)
            
            local player = Players:GetPlayerFromCharacter(target)
            local hum = target:FindFirstChildOfClass("Humanoid")
            local weapon = cheat.EspLibrary.get_gun(player or target)
            local k_d, action = "0.00 (0/0)", "None"
            
            if player then
                -- Deep search for stats
                local function find_stat(name)
                    local pfolder = _FindFirstChild(ReplicatedStorage.Players, player.Name)
                    local found = pfolder and pfolder:FindFirstChild(name, true)
                    if found then
                        if found:IsA("AttributeValue") or found:IsA("ValueBase") then return found.Value end
                        return found
                    end
                    -- Check player object too
                    local pstat = player:FindFirstChild(name, true)
                    if pstat then return pstat end
                    return nil
                end

                local stats_obj = find_stat("WipeStatistics") or find_stat("Statistics")
                local h_stat = find_stat("Statistics")
                local hours = h_stat and h_stat:GetAttribute("TimePlayed") or 0
                tipanel.hours.Text = math.floor(hours / 3600) .. "h"

                if stats_obj then
                    local kills = stats_obj:GetAttribute("Kills") or 0
                    local deaths = stats_obj:GetAttribute("Deaths") or 0
                    local ratio = kills / math.max(1, deaths)
                    local kd_val = (ratio % 1 == 0) and string.format("%d", ratio) or string.format("%.1f", ratio)
                    k_d = string.format("%skd(%d/%d)", kd_val, kills, deaths)
                end
                
                local is_vis = false
                if cheat.utility.is_visible then
                    is_vis = cheat.utility.is_visible(Camera.CFrame, target, silent_aim.target_part)
                end
                tipanel.values["vis"].Text = is_vis and "Visible" or "Hidden"
                tipanel.values["vis"].Color = is_vis and Color3.fromRGB(150, 255, 150) or Color3.fromRGB(255, 150, 150)

                action = (target:GetAttribute("Action")) or "None"
                if tipanel.avatar_id ~= player.UserId then
                    tipanel.avatar_id = player.UserId
                    if avatar_cache[player.UserId] then
                        tipanel.avatar.Data = avatar_cache[player.UserId]
                    else
                        task.spawn(function()
                            local thumbUrl = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150&format=png", player.UserId)
                            local success, data = pcall(function() return game:HttpGet(thumbUrl) end)
                            if success and data and #data > 100 then 
                                tipanel.avatar.Data = data 
                                avatar_cache[player.UserId] = data
                            else
                                local cdnUrl = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="..player.UserId.."&size=150x150&format=Png&isCircular=false"
                                local s2, d2 = pcall(function() return game:HttpGet(cdnUrl) end)
                                if s2 and d2 then
                                    local link = d2:match('"imageUrl":"(.-)"')
                                    if link then
                                        local s3, d3 = pcall(function() return game:HttpGet(link) end)
                                        if s3 then 
                                            tipanel.avatar.Data = d3 
                                            avatar_cache[player.UserId] = d3
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
            end
            
            tipanel.values["user"].Text = player and player.Name or target.Name
            tipanel.values["k / d"].Text = k_d
            
            -- Setup weapon icons above info box
            for i = 1, 3 do tipanel_weapons[i].Visible = false end
            for i = 1, 12 do tipanel_attachments[i].Visible = false end
            
            if player then
                local inv = target and target:FindFirstChild("Inventory")
                if not inv then
                    local rp = ReplicatedStorage:FindFirstChild("Players")
                    local rpp = rp and rp:FindFirstChild(player.Name)
                    inv = rpp and rpp:FindFirstChild("Inventory")
                end
                
                if inv then
                    local ItemsList = ReplicatedStorage:FindFirstChild("ItemsList")
                    if ItemsList then
                        local weapons = {}
                        for _, slot_item in pairs(inv:GetChildren()) do
                            if #weapons >= 3 then break end
                            local slot_attr = slot_item:GetAttribute("Slot")
                            if slot_attr and not string.find(slot_attr, "Clothing") and slot_item:FindFirstChild("Attachments") then
                                table.insert(weapons, slot_item)
                            end
                        end
                        
                        local num_weps = #weapons
                        local total_width = (num_weps * 50) + math.max(0, num_weps - 1) * 5
                        local start_x = p.X + (tipanel.width / 2) - (total_width / 2)
                        local wy = p.Y - 65
                        
                        local a_idx = 0
                        for w_idx, slot_item in ipairs(weapons) do
                            local item_ref = ItemsList:FindFirstChild(slot_item.Name)
                            if item_ref and item_ref:FindFirstChild("ItemProperties") and item_ref.ItemProperties:FindFirstChild("ItemIcon") then
                                local img = tipanel_weapons[w_idx]
                                img.Image = item_ref.ItemProperties.ItemIcon.Image
                                img.Visible = true
                                
                                local wx = start_x + (w_idx - 1) * 55
                                img.Position = UDim2.new(0, wx, 0, wy)
                                
                                for _, att in pairs(slot_item.Attachments:GetChildren()) do
                                    local att_slot = att:GetAttribute("Slot")
                                    local att_ref = ItemsList:FindFirstChild(att.Name)
                                    local s_i = nil
                                    if att_slot == "Magazine" then s_i = 1
                                    elseif att_slot == "Sight" then s_i = 2
                                    elseif att_slot == "Muzzle" then s_i = 3
                                    elseif att_slot == "Extra" then s_i = 4 end
                                    
                                    if s_i and att_ref and att_ref:FindFirstChild("ItemProperties") and att_ref.ItemProperties:FindFirstChild("ItemIcon") then
                                        local a_img = tipanel_attachments[a_idx + s_i]
                                        a_img.Image = att_ref.ItemProperties.ItemIcon.Image
                                        a_img.Visible = true
                                        local attachment_width = 16
                                        local attachment_gap = 2
                                        local attachment_group_width = (attachment_width * 4) + (attachment_gap * 3)
                                        local attachment_x = wx + ((50 - attachment_group_width) / 2) + ((s_i - 1) * (attachment_width + attachment_gap))
                                        a_img.Position = UDim2.new(0, attachment_x, 0, wy + 32)
                                    end
                                end
                            end
                            a_idx = a_idx + 4
                        end
                    end
                end
            end
            
            if hum then
                local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                tipanel.hpfill.Size = _Vector2new(145 * pct, 12)
                tipanel.hptext.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
            end
        end
        if target_line_visible then
            local head_pos, on_screen = _WorldToViewportPoint(Camera, silent_aim.target_part.Position)
            if on_screen then
                target_line.From = mousepos
                target_line.To = _Vector2new(head_pos.X, head_pos.Y)
                target_line.Visible = true
            end
        end
        if cursor.Enabled then
            rainbow = rainbow + (delta * 0.5)
            if rainbow > 1.0 then rainbow = 0.0 end
            color = Color3.fromHSV(rainbow, 1, 1)
            if cursor.CustomPos then pos = cursor.Position else pos = _Vector2new(
                Mouse.X,
                Mouse.Y + GuiInset.Y) end
            if cursor.rainbow then color = Color3.fromHSV(rainbow, 1, 1) else color = cursor.Color end
            if transp <= 1.5 + cursor.Text.LogoFadingOffset and not reverse then
                transp = transp + ((cursor.Speed * 10) * delta)
                if transp >= 1.5 + cursor.Text.LogoFadingOffset then setreverse(true) end
            elseif reverse then
                transp = transp - ((cursor.Speed * 10) * delta)
                if transp <= 0 - cursor.Text.LogoFadingOffset then setreverse(false) end
            end
            logotext.Position = _Vector2new(pos.X, (pos + _Vector2new(0, cursor.Radius + 5)).Y)
            logotext.Transparency = transp
            logotext.Visible = cursor.Text.Logo
            logotext.Color = cursor.Text.LogoColor
            logotext.Font = cursor.Font
            if cursor.sussy then
                local frametime = delta
                local a = cursor.Radius - 10
                local gamma = math_atan(a / a)
                if rotationdegree >= 90 then rotationdegree = 0 end
                for i = 1, 4 do
                    local p_0 = (a * math_sin(DEG2RAD(rotationdegree + (i * 90))))
                    local p_1 = (a * math_cos(DEG2RAD(rotationdegree + (i * 90))))
                    local p_2 = ((a / math_cos(gamma)) * math_sin(DEG2RAD(rotationdegree + (i * 90) + RAD2DEG(gamma))))
                    local p_3 = ((a / math_cos(gamma)) * math_cos(DEG2RAD(rotationdegree + (i * 90) + RAD2DEG(gamma))))
                    lines[i][1].From = _Vector2new(pos.X, pos.Y)
                    lines[i][1].To = _Vector2new(pos.X + p_0, pos.Y - p_1)
                    lines[i][1].Color = color
                    lines[i][1].Thickness = cursor.Thickness
                    lines[i][1].Visible = true
                    lines[i][3].From = _Vector2new(pos.X + p_0, pos.Y - p_1)
                    lines[i][3].To = _Vector2new(pos.X + p_2, pos.Y - p_3)
                    lines[i][3].Color = color
                    lines[i][3].Thickness = cursor.Thickness
                    lines[i][3].Visible = true
                end
                rotationdegree = rotationdegree + ((cursor.Speed * frametime) * 1000)
            else
                angle = angle + ((cursor.Speed * 10) * delta)
                if angle >= 90 then
                    angle = 0
                end
                dot.Visible = cursor.Dot
                dot.Color = color
                dot.Position = _Vector2new(pos.X - 1, pos.Y - 1)
                outline.Visible = cursor.Outline and cursor.Dot
                outline.Position = _Vector2new(pos.X - 2, pos.Y - 2)
                for index, line in pairs(lines) do
                    index = index
                    local x, y = {}, {}
                    local x1, y1 = {}, {}
                    if cursor.Resize then
                        x = { pos.X +
                        (math_cos(angle + (index * (math.pi / 2))) * (cursor.Radius + ((cursor.Radius * math_sin(angle)) / 9))),
                            pos.X +
                            (math_cos(angle + (index * (math.pi / 2))) * ((cursor.Radius - 20) - (cursor.TheGap and (((cursor.Radius - 20) * math_cos(angle)) / 4) or (((cursor.Radius - 20) * math_cos(angle)) - 4)))) }
                        y = { pos.Y +
                        (math_sin(angle + (index * (math.pi / 2))) * (cursor.Radius + ((cursor.Radius * math_sin(angle)) / 9))),
                            pos.Y +
                            (math_sin(angle + (index * (math.pi / 2))) * ((cursor.Radius - 20) - (cursor.TheGap and (((cursor.Radius - 20) * math_cos(angle)) / 4) or (((cursor.Radius - 20) * math_cos(angle)) - 4)))) }
                        x1 = { pos.X + (math_cos(angle + (index * (math.pi / 2))) * (cursor.Radius + 1)), pos
                        .X +
                        (math_cos(angle + (index * (math.pi / 2))) * ((cursor.Radius - 20 + 1) - (cursor.TheGap and ((cursor.Radius - 20 + 1) / cursor.Gap) or ((cursor.Radius - 20 + 1) - cursor.Gap)))) }
                        y1 = { pos.Y + (math_sin(angle + (index * (math.pi / 2))) * (cursor.Radius + 1)), pos
                        .Y +
                        (math_sin(angle + (index * (math.pi / 2))) * ((cursor.Radius - 20 + 1) - (cursor.TheGap and ((cursor.Radius - 20 + 1) / cursor.Gap) or ((cursor.Radius - 20 + 1) - cursor.Gap)))) }
                    else
                        x = { pos.X + (math_cos(angle + (index * (math.pi / 2))) * (cursor.Radius)), pos.X +
                        (math_cos(angle + (index * (math.pi / 2))) * ((cursor.Radius - 20) - (cursor.TheGap and ((cursor.Radius - 20) / cursor.Gap) or ((cursor.Radius - 20) - cursor.Gap)))) }
                        y = { pos.Y + (math_sin(angle + (index * (math.pi / 2))) * (cursor.Radius)), pos.Y +
                        (math_sin(angle + (index * (math.pi / 2))) * ((cursor.Radius - 20) - (cursor.TheGap and ((cursor.Radius - 20) / cursor.Gap) or ((cursor.Radius - 20) - cursor.Gap)))) }
                        x1 = { pos.X + (math_cos(angle + (index * (math.pi / 2))) * (cursor.Radius + 1)), pos
                        .X +
                        (math_cos(angle + (index * (math.pi / 2))) * ((cursor.Radius - 20 + 1) - (cursor.TheGap and ((cursor.Radius - 20 + 1) / cursor.Gap) or ((cursor.Radius - 20 + 1) - cursor.Gap)))) }
                        y1 = { pos.Y + (math_sin(angle + (index * (math.pi / 2))) * (cursor.Radius + 1)), pos
                        .Y +
                        (math_sin(angle + (index * (math.pi / 2))) * ((cursor.Radius - 20 + 1) - (cursor.TheGap and ((cursor.Radius - 20 + 1) / cursor.Gap) or ((cursor.Radius - 20 + 1) - cursor.Gap)))) }
                    end
                    line[1].Visible = true
                    line[1].Color = color
                    line[1].From = _Vector2new(x[2], y[2])
                    line[1].To = _Vector2new(x[1], y[1])
                    line[1].Thickness = cursor.Thickness
                    line[2].Visible = cursor.Outline
                    line[2].From = _Vector2new(x1[2], y1[2])
                    line[2].To = _Vector2new(x1[1], y1[1])
                    line[2].Thickness = cursor.Thickness + 2.5
                    line[3].Visible = false
                end
            end
        else
            dot.Visible = false
            outline.Visible = false
            logotext.Visible = false

            for index, line in pairs(lines) do
                line[1].Visible = false
                line[2].Visible = false
                line[3].Visible = false
            end
        end
    end))
end
do
    -- Radar system (ported from ghost)
    local radarKillFunction = nil
    local radarDrawObjects = {}

    local function rememberRadarDrawingObject(object)
        if object then
            table.insert(radarDrawObjects, object)
        end
        return object
    end

    local function cleanupPlayerRadar()
        if radarKillFunction then
            pcall(radarKillFunction)
        end

        local globalRadarKill = _G.RadarKill
        if globalRadarKill and globalRadarKill ~= radarKillFunction then
            pcall(globalRadarKill)
        end

        for _, object in ipairs(radarDrawObjects) do
            pcall(function()
                object.Visible = false
                if object.Remove then
                    object:Remove()
                end
            end)
        end

        radarKillFunction = nil
        radarDrawObjects = {}
        _G.RadarKill = nil
        if _G.GhostRadarRememberDrawing == rememberRadarDrawingObject then
            _G.GhostRadarRememberDrawing = nil
        end
    end

    local function setPlayerRadarEnabled(enabled)
        if enabled then
            cleanupPlayerRadar()

            _G.RadarSettings = {
                RADAR_LINES = true,
                RADAR_LINE_DISTANCE = 50,
                RADAR_SCALE = 1,
                RADAR_RADIUS = 125,
                RADAR_ROTATION = true,
                SMOOTH_ROT = true,
                SMOOTH_ROT_AMNT = 30,
                CARDINAL_DISPLAY = true,
                DISPLAY_OFFSCREEN = true,
                DISPLAY_TEAMMATES = true,
                DISPLAY_TEAM_COLORS = true,
                DISPLAY_FRIEND_COLORS = true,
                DISPLAY_RGB_COLORS = false,
                MARKER_SCALE_BASE = 1.25,
                MARKER_SCALE_MAX = 1.25,
                MARKER_SCALE_MIN = 0.75,
                MARKER_FALLOFF = true,
                MARKER_FALLOFF_AMNT = 125,
                OFFSCREEN_TRANSPARENCY = 0.3,
                USE_FALLBACK = false,
                USE_QUADS = true,
                USE_TEAM_COLORS = false,
                VISIBLITY_CHECK = false,
                RADAR_THEME = {
                    Outline = Color3.fromRGB(35, 35, 45),
                    Background = Color3.fromRGB(25, 25, 35),
                    DragHandle = Color3.fromRGB(50, 50, 255),
                    Cardinal_Lines = Color3.fromRGB(110, 110, 120),
                    Distance_Lines = Color3.fromRGB(65, 65, 75),
                    Generic_Marker = Color3.fromRGB(255, 25, 115),
                    Local_Marker = Color3.fromRGB(115, 25, 255),
                    Team_Marker = Color3.fromRGB(25, 115, 255),
                    Friend_Marker = Color3.fromRGB(25, 255, 115),
                },
            }

            local radarSource = nil
            local fetched, fetchErr = pcall(function()
                radarSource = game:HttpGet("https://raw.githubusercontent.com/kristerstomasuns-hub/essentials/main/radar?v=autoloadfix-20260719", true)
            end)
            if not fetched or not radarSource or radarSource == "" then
                cleanupPlayerRadar()
                notify("Radar", "Failed to load radar: " .. tostring(fetchErr or "empty source"), 4)
                return
            end

            _G.GhostRadarRememberDrawing = rememberRadarDrawingObject
            radarSource = radarSource:gsub(
                "local obj = Drawing%.new%(objectClass%)",
                "local obj = Drawing.new(objectClass)\n    if _G.GhostRadarRememberDrawing then pcall(_G.GhostRadarRememberDrawing, obj) end"
            )
            radarSource = radarSource:gsub(
                "local notif = Drawing%.new%('Text'%)",
                "local notif = Drawing.new('Text')\n    if _G.GhostRadarRememberDrawing then pcall(_G.GhostRadarRememberDrawing, notif) end"
            )

            local ok, err = pcall(function()
                loadstring(radarSource)()
            end)

            if not ok then
                cleanupPlayerRadar()
                notify("Radar", "Failed to load radar: " .. tostring(err), 4)
                return
            end

            radarKillFunction = _G.RadarKill
        else
            cleanupPlayerRadar()
        end
    end

    local WorldTab = ui.box.world:AddTab("Environment")
    local gradientcolor1 = Color3.fromRGB(90, 90, 90)
    local gradientcolor2 = Color3.fromRGB(150, 150, 150)
    local oldgradient1 = Lighting.Ambient
    local oldgradient2 = Lighting.OutdoorAmbient
    local oldTime = mathround(Lighting.ClockTime)
    local nofog = false
    local visuals_BloomInstance = Lighting:FindFirstChildOfClass("BloomEffect")
    local visuals_BloomIntensity = 0
    local visuals_BloomSize = 17
    local visuals_BloomThreshold = 0.9
    local visuals_BloomEnabled = false
    WorldTab:AddToggle('enabletimechanger', {Text = 'Time Changer',Default = false,Callback = function(first)
        globals.EnableTime = first
    end})
    WorldTab:AddSlider('timechanger',{ Text = 'Time', Default = math.max(1, oldTime), Min = 1, Max = 24, Rounding = 1, Compact = false }):OnChanged(function(State)
        globals.Time = State
    end)
    WorldTab:AddToggle('ambientswitch', {Text = 'Ambient Changer',Default = false,Callback = function(first)
        globals.gradientenabled = first
    end}):AddColorPicker('ambientcolor', {Default = Color3.new(1, 1, 1),Title = 'Ambient Color 1',Transparency = 0,Callback = function(Value)
        gradientcolor1 = Value
    end}):AddColorPicker('ambientcolor1',{Default = Color3.new(1, 1, 1),Title = 'Ambient Color 2',Transparency = 0,Callback = function(Value)
        gradientcolor2 = Value
    end})
    WorldTab:AddToggle('fogswitch', {
        Text = 'No Fog',
        Default = false,
        Callback = function(first)
            nofog = first
        end
    })
    local xray_enabled = false
    local xray_active = false
    local xray_original_transparency = setmetatable({}, { __mode = "k" })
    local function is_xray_part(part)
        if not (part and part:IsA("BasePart")) then return false end
        local parent = part.Parent
        if parent and parent:FindFirstChildOfClass("Humanoid") then return false end
        local character = LocalPlayer.Character
        if character and part:IsDescendantOf(character) then return false end
        return true
    end
    local function set_xray_transparency(active)
        active = active and true or false
        if xray_active == active then return end
        xray_active = active

        if active then
            local origin = Camera.CFrame.Position
            for _, object in ipairs(workspace:GetDescendants()) do
                if is_xray_part(object) and (origin - object.Position).Magnitude <= 500 and object.Transparency == 0 then
                    xray_original_transparency[object] = object.Transparency
                    object.Transparency = 0.5
                end
            end
        else
            for part, original in pairs(xray_original_transparency) do
                if part and part.Parent and part.Transparency == 0.5 then
                    part.Transparency = original
                end
                xray_original_transparency[part] = nil
            end
        end
    end
    local function xray_key_active()
        local option = cheat.Options and cheat.Options.xray_bind
        if not option then return false end
        local value = option.Value
        local key = option.Key
        local mode = option.Mode
        local active = option.State
        if type(value) == "table" then
            key = value.Key or key
            mode = value.Type or value.Mode or mode
            active = value.Active ~= nil and value.Active or active
        end
        key = tostring(key or "None")
        if key == "" or key == "None" or key == "NONE" then
            return false
        end
        return mode == "Always" or active == true
    end
    WorldTab:AddToggle('xray_enabled', {Text = 'Xray', Default = false, Callback = function(v)
        xray_enabled = v
        set_xray_transparency(xray_enabled and xray_key_active())
    end}):AddKeyPicker('xray_bind', {Default = 'None', SyncToggleState = false, Mode = 'Hold', Text = 'Xray', NoUI = false, Callback = function()
        set_xray_transparency(xray_enabled and xray_key_active())
    end})
    cheat.utility.track_connection(workspace.DescendantAdded:Connect(function(object)
        if not (xray_enabled and xray_active and is_xray_part(object)) then return end
        task.defer(function()
            if xray_enabled and xray_active and is_xray_part(object) and object.Transparency == 0 and (Camera.CFrame.Position - object.Position).Magnitude <= 500 then
                xray_original_transparency[object] = object.Transparency
                object.Transparency = 0.5
            end
        end)
    end))
    local no_landmines = false
    local landmine_connections = {}
    local landmine_workspace_connection = nil
    local landmine_aizones_connection = nil
    local landmine_folder_names = {
        Landmines = true,
        Claymores = true,
        OutpostLandmines = true,
        BridgeClaymores = true,
        HeliCrashClaymores = true,
        ShipWreckClaymores = true,
    }
    local function is_landmine_object(object)
        return object and object:IsA("Model") and (object.Name == "PMN2" or object.Name == "MON50")
    end
    local function remove_landmine(object)
        if is_landmine_object(object) then
            pcall(function()
                object:Destroy()
            end)
        end
    end
    local function remove_landmine_later(object)
        if not is_landmine_object(object) then return end
        task.delay(2.5, function()
            if no_landmines then
                remove_landmine(object)
            end
        end)
    end
    local function watch_landmine_folder(folder)
        if not folder or landmine_connections[folder] then return end
        for _, object in ipairs(folder:GetChildren()) do
            remove_landmine(object)
        end
        landmine_connections[folder] = cheat.utility.track_connection(folder.ChildAdded:Connect(function(object)
            if no_landmines then
                remove_landmine_later(object)
            end
        end))
    end
    local function refresh_landmines()
        local ai_zones = workspace:FindFirstChild("AiZones")
        if not ai_zones then return end
        if not landmine_aizones_connection then
            landmine_aizones_connection = cheat.utility.track_connection(ai_zones.ChildAdded:Connect(function(child)
                if not no_landmines then return end
                if landmine_folder_names[child.Name] then
                    watch_landmine_folder(child)
                else
                    remove_landmine_later(child)
                end
            end))
        end
        for folder_name, _ in pairs(landmine_folder_names) do
            watch_landmine_folder(ai_zones:FindFirstChild(folder_name))
        end
    end
    WorldTab:AddToggle('no_landmines', {Text = 'No Landmines', Default = false, Callback = function(v)
        no_landmines = v
        if v then
            for _, object in ipairs(workspace:GetDescendants()) do
                remove_landmine(object)
            end
            refresh_landmines()
            if not landmine_workspace_connection then
                landmine_workspace_connection = cheat.utility.track_connection(workspace.DescendantAdded:Connect(function(object)
                    if no_landmines and is_landmine_object(object) then
                        remove_landmine_later(object)
                    end
                end))
            end
        else
            if landmine_workspace_connection then
                pcall(function() landmine_workspace_connection:Disconnect() end)
                landmine_workspace_connection = nil
            end
            if landmine_aizones_connection then
                pcall(function() landmine_aizones_connection:Disconnect() end)
                landmine_aizones_connection = nil
            end
            for folder, connection in pairs(landmine_connections) do
                pcall(function() connection:Disconnect() end)
                landmine_connections[folder] = nil
            end
        end
    end})
    WorldTab:AddToggle('grassswitch', {
        Text = 'No Grass',
        Default = false,
        Callback = function(first)
            setTerrainDecoration(not first)
        end
    })
    local muzzle_color = Color3.fromRGB(255, 100, 0)
    local last_star_emit = 0
    local last_landmine_refresh = 0
    local star_texture = "rbxassetid://12555502283" -- Star texture
    local muzzle_tab = ui.gunmodbox or WorldTab
    muzzle_tab:AddToggle('custommuzzleflash', {
        Text = 'Custom Muzzle Flash',
        Default = false,
        Callback = function(first)
        end
    }):AddColorPicker('muzzleflashcolor', { Default = Color3.fromRGB(255, 100, 0), Title = 'Muzzle Flash Color', Callback = function(Value)
        muzzle_color = Value
    end})
    WorldTab:AddToggle('shadowswitch', {
        Text = 'No Shadows',
        Default = false,
        Callback = function(first)
            globals.noshadows = first
        end
    })
    local leafs_enabled = false
    local function apply_no_leafs()
        local zones = workspace:FindFirstChild("SpawnerZones")
        if not zones then return end
        local foliage = zones:FindFirstChild("Foliage")
        if not foliage then return end
        for _, v in pairs(foliage:GetDescendants()) do
            if v:FindFirstChildOfClass("SurfaceAppearance") then
                v.Transparency = leafs_enabled and 1 or 0
            end
        end
    end
    WorldTab:AddToggle('no_leafs', {Text = 'No Leafs', Default = false, Callback = function(v)
        leafs_enabled = v
        apply_no_leafs()
        if v then
            task.spawn(function()
                while leafs_enabled do
                    task.wait(10)
                    apply_no_leafs()
                end
            end)
        end
    end})
    WorldTab:AddToggle('noscreenfx', { Text = 'No Screen Effects', Default = false })
    world_radar_tab:AddToggle('radar_enabled', {Text = 'Radar', Default = false, Callback = function(v)
        setPlayerRadarEnabled(v)
    end})
    local last_custom_muzzle_refresh = 0
    local custom_muzzle_active = false
    cheat.utility.new_heartbeat(function()
        local now = tick()
        local custom_muzzle_enabled = cheat.Toggles.custommuzzleflash and cheat.Toggles.custommuzzleflash.Value
        if not (nofog or no_landmines or globals.noshadows or globals.gradientenabled or globals.EnableTime or custom_muzzle_enabled) then
            return
        end
        local char = LocalPlayer.Character
        if nofog and Lighting:FindFirstChildOfClass("Atmosphere") then
            Lighting:FindFirstChildOfClass("Atmosphere").Haze = 0
            Lighting:FindFirstChildOfClass("Atmosphere").Density = 0
        end
        if no_landmines and now - last_landmine_refresh > 1 then
            last_landmine_refresh = now
            refresh_landmines()
        end
        if Lighting.GlobalShadows ~= (not globals.noshadows) then Lighting.GlobalShadows = not globals.noshadows end
        if globals.gradientenabled then
            if Lighting.Ambient ~= gradientcolor1 then Lighting.Ambient = gradientcolor1 end
            if Lighting.OutdoorAmbient ~= gradientcolor2 then Lighting.OutdoorAmbient = gradientcolor2 end
        end
        if globals.EnableTime and Lighting.ClockTime ~= globals.Time then Lighting.ClockTime = globals.Time end
        if custom_muzzle_enabled then
            if now - last_custom_muzzle_refresh > 0.05 then
                last_custom_muzzle_refresh = now
                custom_muzzle_active = false
            for _, v in ipairs(Camera:GetDescendants()) do
                if v:IsA("Light") or (v:IsA("BasePart") and (v.Name:find("Flash") or v.Name:find("Muzzle") or v.Name:find("Smoke"))) or v:IsA("ParticleEmitter") then
                    local is_muzzle_part = v.Name:find("Flash") or v.Name:find("Muzzle") or v.Name:find("Smoke")
                    if (v:IsA("Light") and v.Enabled) or (v:IsA("ParticleEmitter") and v.Enabled) or (v:IsA("BasePart") and v.Transparency < 0.9 and is_muzzle_part) then
                        custom_muzzle_active = true
                    end
                    
                    if v:IsA("Light") then
                        v.Color = muzzle_color
                        v.Brightness = 25
                        v.Range = 25
                    elseif v:IsA("ParticleEmitter") then
                        v.Color = ColorSequence.new(muzzle_color)
                        -- Removed transparency override to keep it natural
                    elseif v:IsA("BasePart") then
                        v.Color = muzzle_color
                        if not v.Name:find("Smoke") then
                            v.Transparency = 0 -- Keep fire visible, but let smoke animate
                        end
                        local sa = v:FindFirstChildOfClass("SurfaceAppearance") or v:FindFirstChildOfClass("Texture")
                        if sa then sa:Destroy() end
                    end
                end
            end
            
                if char then
                    for _, v in ipairs(char:GetDescendants()) do
                        if v:IsA("Light") or (v:IsA("BasePart") and (v.Name:find("Flash") or v.Name:find("Muzzle") or v.Name:find("Smoke"))) or v:IsA("ParticleEmitter") then
                            if v:IsA("Light") then
                                v.Color = muzzle_color
                                v.Brightness = 25
                            elseif v:IsA("ParticleEmitter") then
                                v.Color = ColorSequence.new(muzzle_color)
                            elseif v:IsA("BasePart") then
                                v.Color = muzzle_color
                                v.Transparency = 0
                                local sa = v:FindFirstChildOfClass("SurfaceAppearance") or v:FindFirstChildOfClass("Texture")
                                if sa then sa:Destroy() end
                            end
                        end
                    end
                end
            end
            
            if custom_muzzle_active and tick() - last_star_emit > 0.04 then
                last_star_emit = tick()
                local vm = _FindFirstChildOfClass(Camera, "Model")
                local item = vm and _FindFirstChild(vm, "Item")
                local muzzle = (item and (_FindFirstChild(item, "Muzzle") or _FindFirstChild(item, "AimPart"))) or (vm and _FindFirstChild(vm, "AimPart")) or Camera
                
                if muzzle then
                    task.spawn(function()
                        local att = Instance.new("Attachment")
                        if muzzle:IsA("Camera") then
                            att.Parent = workspace.Terrain
                            att.WorldPosition = Camera.CFrame.p + (Camera.CFrame.LookVector * 2.5)
                        else
                            att.Parent = muzzle
                        end
                        
                        local emitter = Instance.new("ParticleEmitter")
                        emitter.Texture = star_texture
                        emitter.Color = ColorSequence.new(muzzle_color)
                        emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 0)})
                        emitter.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
                        emitter.Lifetime = NumberRange.new(0.3, 0.5)
                        emitter.Speed = NumberRange.new(15, 35)
                        emitter.SpreadAngle = Vector2.new(60, 60)
                        emitter.ZOffset = 1
                        emitter.Rate = 0
                        emitter.Parent = att
                        emitter:Emit(8)
                        task.wait(0.6)
                        emitter:Destroy()
                        att:Destroy()
                    end)
                end
            end
        else
            custom_muzzle_active = false
        end
    end)
end
do
    local othervisuals = player_camera_tab
    local function get_gameplay_fov()
        local player_folder = ReplicatedStorage:FindFirstChild("Players")
        local local_folder = player_folder and player_folder:FindFirstChild(LocalPlayer.Name)
        local settings = local_folder and local_folder:FindFirstChild("Settings")
        local gameplay = settings and settings:FindFirstChild("GameplaySettings")
        local attr = gameplay and gameplay:GetAttribute("DefaultFOV")
        return tonumber(attr) or tonumber(Camera.FieldOfView) or 90
    end

    local default_fov = math.clamp(get_gameplay_fov(), 1, 120)
    local zoom_enabled, zoom_size = false, 10
    local fov_enabled, fov_size = false, default_fov

    local function set_gameplay_fov(value)
        value = math.clamp(tonumber(value) or default_fov, 1, 120)
        local player_folder = ReplicatedStorage:FindFirstChild("Players")
        local local_folder = player_folder and player_folder:FindFirstChild(LocalPlayer.Name)
        local settings = local_folder and local_folder:FindFirstChild("Settings")
        local gameplay = settings and settings:FindFirstChild("GameplaySettings")
        if gameplay then
            gameplay:SetAttribute("DefaultFOV", value)
        end
        Camera.FieldOfView = value
    end

    local function current_zoom_active()
        return feature_active(zoom_enabled, 'zoom_bind', true)
    end

    local function apply_camera_fov()
        local is_zoomed = current_zoom_active()
        globals.zoom_enabled = is_zoomed
        globals.fov_enabled = fov_enabled or is_zoomed
        if is_zoomed then
            set_gameplay_fov(zoom_size)
        elseif fov_enabled then
            set_gameplay_fov(fov_size)
        end
    end

    othervisuals:AddToggle('fov_enabled', {Text = 'FOV Changer',Default = false,Callback = function(first)
        fov_enabled = first
        if not first and not current_zoom_active() then
            globals.fov_enabled = false
            set_gameplay_fov(default_fov)
            return
        end
        apply_camera_fov()
    end})
    local zoom_toggle = othervisuals:AddToggle('zoom_enabled', {Text = 'Zoom',Default = false,Callback = function(first)
        zoom_enabled = first
        apply_camera_fov()
    end})
    local zoom_picker = zoom_toggle:AddKeyPicker('zoom_bind', {Default = 'None',SyncToggleState = true,Mode = 'Toggle',Text = 'Zoom',NoUI = false})
    cheat.utility.new_renderstepped(function()
        if fov_enabled or zoom_enabled then
            apply_camera_fov()
        end
    end)
    othervisuals:AddSlider('zoom_size', { Text = 'Zoom FOV', Default = 10, Min = 1, Max = 90, Rounding = 0, Compact = true, Callback = function(value)
        zoom_size = value
        apply_camera_fov()
    end})
    othervisuals:AddSlider('fov_size', { Text = 'FOV Size', Default = default_fov, Min = 1, Max = 120, Rounding = 0, Compact = true, Callback = function(value)
        fov_size = value
        apply_camera_fov()
    end})
    ui.gunmodbox:AddToggle('nomuzzleflash', { Text = 'Remove Muzzle Flash', Default = false });
    othervisuals:AddToggle('killeffect', { Text = 'Hit / Kill Effect (Stars)', Default = false });
    othervisuals:AddSlider('killeffect_amount', { Text = 'Hit Effect Stars Amount', Default = 100, Min = 50, Max = 200, Rounding = 0, Compact = true });

    local hitlogs_tab = ui.box.misc:AddTab('Hit Logs')
    local hitlogstog = hitlogs_tab:AddToggle('hitlogs_enabled', { Text = 'Hit Logs', Default = false, Callback = function(v) cheat.hitlogs_enabled = v end })
    hitlogstog:AddColorPicker('hitlogs_valid_color', { Default = cheat.hitlogs_valid_color, Title = 'Valid Hit Color', Transparency = 0, Callback = function(c) cheat.hitlogs_valid_color = c end })
    hitlogstog:AddColorPicker('hitlogs_invalid_color', { Default = cheat.hitlogs_invalid_color, Title = 'Invalid Hit Color', Transparency = 0, Callback = function(c) cheat.hitlogs_invalid_color = c end })
    hitlogs_tab:AddDropdown('hitlogs_font', { Text = 'Hit Logs Font', Default = 2, Values = {'UI', 'System', 'Plex', 'Monospace'}, Callback = function(v)
        local fmap = {["UI"]=0, ["System"]=1, ["Plex"]=2, ["Monospace"]=3}
        cheat.hitlogs_font = fmap[v] or 2
    end})
    hitlogs_tab:AddSlider('hitlogs_size', { Text = 'Hit Logs Text Size', Default = 14, Min = 10, Max = 30, Rounding = 0, Compact = true, Callback = function(v) cheat.hitlogs_size = v end })
    hitlogs_tab:AddSlider('hitlogs_y', { Text = 'Hit Logs Y Position', Default = 500, Min = 1, Max = 1500, Rounding = 0, Compact = true, Callback = function(v) cheat.hitlogs_y = v end })

    local vmchams
    local vmpos
    
    local function safe_lower_text(value)
        local ok, lowered = pcall(function()
            return tostring(value or ""):lower()
        end)
        return ok and lowered or ""
    end

    local function has_muzzle_keyword(text)
        text = safe_lower_text(text)
        return text:find("flash", 1, true)
            or text:find("muzzle", 1, true)
            or text:find("aimpart", 1, true)
            or text:find("smoke", 1, true)
            or text:find("spark", 1, true)
    end

    local function remove_muzzle(v)
        if not (cheat.Toggles.nomuzzleflash and cheat.Toggles.nomuzzleflash.Value) then return end

        local ok, is_target = pcall(function()
            return v:IsA("ParticleEmitter") or v:IsA("Light") or v:IsA("Beam")
        end)
        if not (ok and is_target) then return end

        local parent = v.Parent
        if not (has_muzzle_keyword(v.Name) or has_muzzle_keyword(parent and parent.Name)) then return end

        pcall(function()
            v.Enabled = false
            if v:IsA("ParticleEmitter") then
                v:Clear()
                v.Transparency = NumberSequence.new(1)
            end
        end)
    end
    
    cheat.utility.track_connection(workspace.CurrentCamera.DescendantAdded:Connect(remove_muzzle))
    local last_nomuzzle_scan = 0
    cheat.utility.new_heartbeat(function()
        if cheat.Toggles.nomuzzleflash and cheat.Toggles.nomuzzleflash.Value then
            if tick() - last_nomuzzle_scan < 0.25 then return end
            last_nomuzzle_scan = tick()
            for _, v in workspace.CurrentCamera:GetDescendants() do
                remove_muzzle(v)
            end
        end
    end)
    local inv_tab = world_inventory_tab
    local inventory_checker = {
        enabled = false,
        active = false,
        full = false,
        corpse = false,
        value = false,
        target = false,
        title_color = Color3.fromRGB(255, 255, 255),
    }
    inv_tab:AddToggle('inventorychecker', { Text = 'Inventory Checker', Default = false, Callback = function(v)
        inventory_checker.enabled = v
    end}):AddKeyPicker('inventorychecker_bind', {Default = 'None', SyncToggleState = false, Mode = 'Hold', Text = 'Inventory Checker', NoUI = false, Callback = function(active)
        inventory_checker.active = active
    end})
    inv_tab:AddDropdown('inventorychecker_toggles', { Text = 'Inventory Check Toggles', Default = {}, Values = { 'Inventory Check Corpses', 'Show Full Inventory', 'Show Inventory Value' }, Multi = true, Callback = function(values)
        inventory_checker.full = false
        inventory_checker.corpse = false
        inventory_checker.value = false
        for _, value in ipairs(values or {}) do
            if value == 'Inventory Check Corpses' then
                inventory_checker.corpse = true
            elseif value == 'Show Full Inventory' then
                inventory_checker.full = true
            elseif value == 'Show Inventory Value' then
                inventory_checker.value = true
            end
        end
    end})
    inv_tab:AddToggle('inventorychecker_target', { Text = 'Show Inventory Check Target', Default = false, Callback = function(v)
        inventory_checker.target = v
    end}):AddColorPicker('inventorychecker_target_color', { Default = inventory_checker.title_color, Title = 'Target Text Color', Transparency = 0, Callback = function(v)
        inventory_checker.title_color = v
    end})

    local legacy_inventory_toggle = inv_tab:AddToggle('inventoryviewer', { Text = 'Inventory Viewer', Default = false })
    legacy_inventory_toggle:SetVisible(false)
    local legacy_inventory_full = inv_tab:AddToggle('inventoryviewer_full', { Text = 'Show Full Inventory', Default = false }); legacy_inventory_full:SetVisible(false)
    local legacy_inventory_value = inv_tab:AddToggle('inventoryviewer_value', { Text = 'Show Inventory Value', Default = false }); legacy_inventory_value:SetVisible(false)
    local legacy_inventory_corpse = inv_tab:AddToggle('inventoryviewer_corpse', { Text = 'Check Corpse Inventory', Default = false }); legacy_inventory_corpse:SetVisible(false)
    local legacy_inventory_drag = inv_tab:AddToggle('inventoryviewer_drag', { Text = 'Enable Dragging', Default = false }); legacy_inventory_drag:SetVisible(false)
    local legacy_inventory_x = inv_tab:AddSlider('inventoryviewer_x', { Text = 'X Position', Default = math.max(20, Camera.ViewportSize.X - 430), Min = 1, Max = 2000, Rounding = 0, Compact = true }); legacy_inventory_x:SetVisible(false)
    local legacy_inventory_y = inv_tab:AddSlider('inventoryviewer_y', { Text = 'Y Position', Default = 200, Min = 1, Max = 2000, Rounding = 0, Compact = true }); legacy_inventory_y:SetVisible(false)
    local legacy_inventory_scale = inv_tab:AddSlider('inventoryviewer_scale', { Text = 'Icon Scale', Default = 1, Min = 0.5, Max = 2, Rounding = 2, Compact = true }); legacy_inventory_scale:SetVisible(false)
    local legacy_inventory_spacing = inv_tab:AddSlider('inventoryviewer_spacing', { Text = 'Spacing', Default = 1, Min = 0.5, Max = 2, Rounding = 2, Compact = true }); legacy_inventory_spacing:SetVisible(false)
    local legacy_inventory_delay = inv_tab:AddSlider('inventoryviewer_d', { Text = 'Refresh Delay', Default = 0.1, Min = 0.05, Max = 2, Rounding = 2, Compact = true }); legacy_inventory_delay:SetVisible(false)
    local custom_colors = inv_tab:AddToggle('inv_custom_colors', { Text = 'Custom Colors', Default = false }); custom_colors:SetVisible(false)
    
    custom_colors:AddColorPicker('inv_bg_color', { Default = Color3.fromRGB(15, 15, 15), Title = 'Background' })
    custom_colors:AddColorPicker('inv_border_color', { Default = Color3.fromRGB(45, 45, 45), Title = 'Border' })
    custom_colors:AddColorPicker('inv_accent_color', { Default = Color3.fromRGB(120, 110, 180), Title = 'Accent' })
    custom_colors:AddColorPicker('inv_glow_color', { Default = Color3.fromRGB(120, 110, 180), Title = 'Glow' })
    
    local legacy_inv_glow = inv_tab:AddSlider('inv_glow_intensity', { Text = 'Glow Intensity', Default = 1, Min = 1, Max = 10, Rounding = 1, Compact = true }); legacy_inv_glow:SetVisible(false)

    local item_finder_items = {}
    local item_finder_item_set = {}
    local function add_item_finder_item(name)
        if type(name) == "string" and name ~= "" and not item_finder_item_set[name] then
            item_finder_item_set[name] = true
            table.insert(item_finder_items, name)
        end
    end
    for _, name in ipairs({"TFZ98S", "R700", "M4", "AsVal", "PKM", "FlareGun", "SPSh44", "Gold", "GoldWatch", "RepairKit"}) do
        add_item_finder_item(name)
    end
    pcall(function()
        local ItemsList = ReplicatedStorage:FindFirstChild("ItemsList")
        if ItemsList then
            for _, item in pairs(ItemsList:GetChildren()) do
                local is_melee = false
                local props = item:FindFirstChild("ItemProperties")
                if props and props:GetAttribute("ItemType") == "Melee" then
                    is_melee = true
                end
                if item.Name ~= "Lighter" and not is_melee then
                    add_item_finder_item(item.Name)
                end
            end
        end
    end)
    table.sort(item_finder_items, function(a, b) return string.lower(a) < string.lower(b) end)
    local inv_finder_cache = {}
    local inv_finder_notified = {}
    local inv_finder_last_scan = 0
    local inv_item_finder = inv_tab:AddDropdown('inv_item_finder', { Text = 'Item Whitelist', Default = {}, Values = item_finder_items, Multi = true, Callback = function()
        inv_finder_cache = {}
        inv_finder_notified = {}
        inv_finder_last_scan = 0
    end})
    local finder_toggle = inv_tab:AddToggle('inv_finder_enabled', { Text = 'Item Finder', Default = false, Callback = function(enabled)
        inv_finder_cache = {}
        inv_finder_notified = {}
        inv_finder_last_scan = 0
        if enabled and cheat.Library and cheat.Library.Notify then
            cheat.Library:Notify('Item Finder', 'Preview Of Item Finder', 1.5)
        end
    end})
    local inv_finder_glow_size = 5
    local inv_finder_glow_color = Color3.fromRGB(120, 110, 180)
    local legacy_finder_glow = inv_tab:AddSlider('inv_finder_glow_size', {Text = 'Neon Glow Size', Default = 5, Min = 1, Max = 15, Rounding = 0, Callback = function(v)
        inv_finder_glow_size = v
    end}); legacy_finder_glow:SetVisible(false)
    finder_toggle:AddColorPicker('inv_finder_glow_color', {Default = inv_finder_glow_color, Title = 'Neon Glow Color', Transparency = 0, Callback = function(v)
        inv_finder_glow_color = v
    end})
    
    local legacy_finder_x = inv_tab:AddSlider('inv_finder_x', { Text = 'Finder X Position', Default = math.max(1, math.floor(workspace.CurrentCamera.ViewportSize.X - 250)), Min = 1, Max = 3000, Rounding = 0, Compact = true }); legacy_finder_x:SetVisible(false)
    local legacy_finder_y = inv_tab:AddSlider('inv_finder_y', { Text = 'Finder Y Position', Default = 50, Min = 1, Max = 3000, Rounding = 0, Compact = true }); legacy_finder_y:SetVisible(false)

    local inv_finder_panel = {}
    inv_finder_panel.pos = _Vector2new(cheat.Options.inv_finder_x.Value, cheat.Options.inv_finder_y.Value)
    inv_finder_panel.width = 200
    inv_finder_panel.dragging = false
    inv_finder_panel.dragoffset = _Vector2new(0,0)
    
    inv_finder_panel.bg = cheat.utility.new_drawing("Square", { Visible = false, Filled = true, Color = Color3.fromRGB(20, 20, 20), ZIndex = 100 })
    inv_finder_panel.border = cheat.utility.new_drawing("Square", { Visible = false, Filled = false, Color = Color3.fromRGB(45, 45, 45), Thickness = 1, ZIndex = 101 })
    inv_finder_panel.title = cheat.utility.new_drawing("Text", { Visible = false, Text = "Item Finder", Size = 16, Center = true, Color = Color3.new(1,1,1), Outline = true, ZIndex = 102 })
    
    inv_finder_panel.glow = {}
    for i = 1, 6 do
        inv_finder_panel.glow[i] = cheat.utility.new_drawing("Square", { Visible = false, Filled = false, Thickness = 1, ZIndex = 99 })
    end
    
    inv_finder_panel.labels = {}
    for i = 1, 30 do
        inv_finder_panel.labels[i] = cheat.utility.new_drawing("Text", { Visible = false, Text = "", Size = 14, Center = true, Color = Color3.fromRGB(200, 200, 200), Outline = true, ZIndex = 102 })
    end
    local inv_finder_scan_interval = 0.5

    local function build_item_finder_lookup(values)
        local lookup = {}
        if type(values) ~= "table" then
            return lookup
        end

        for key, selected in pairs(values) do
            local name
            if type(key) == "number" then
                name = selected
                selected = true
            else
                name = key
            end

            if selected and type(name) == "string" and name ~= "" then
                lookup[name] = true
                if name == "Gold" then
                    lookup.Gold50g = true
                end
            end
        end

        return lookup
    end

    cheat.utility.new_heartbeat(LPH_NO_VIRTUALIZE(function(delta)
        local enabled = cheat.Toggles.inv_finder_enabled and cheat.Toggles.inv_finder_enabled.Value
        if not enabled then
            inv_finder_panel.bg.Visible = false
            inv_finder_panel.border.Visible = false
            inv_finder_panel.title.Visible = false
            for i = 1, 6 do inv_finder_panel.glow[i].Visible = false end
            for i = 1, 30 do inv_finder_panel.labels[i].Visible = false end
            return
        end
        
        if tick() - inv_finder_last_scan >= inv_finder_scan_interval then
            inv_finder_last_scan = tick()
            local selected_items = cheat.Options.inv_item_finder and cheat.Options.inv_item_finder.Value or {}
            local selected_lookup = build_item_finder_lookup(selected_items)
            local found_players = {}
            local rep_players = ReplicatedStorage:FindFirstChild("Players")
            if rep_players and next(selected_lookup) ~= nil then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        local p_folder = rep_players:FindFirstChild(player.Name)
                        local p_inv = p_folder and p_folder:FindFirstChild("Inventory")
                        if p_inv then
                            local found_for_player = {}
                            local function check_item(item)
                                if selected_lookup[item.Name] and not found_for_player[item.Name] then
                                    found_for_player[item.Name] = true
                                    table.insert(found_players, player.Name .. " (" .. item.Name .. ")")
                                    local notify_key = player.Name .. ":" .. item.Name
                                    if not inv_finder_notified[notify_key] then
                                        inv_finder_notified[notify_key] = true
                                        if cheat.Library and cheat.Library.Notify then
                                            cheat.Library:Notify("Item | Finder", "Player: " .. player.Name .. " Has an: " .. item.Name, 5)
                                        end
                                    end
                                end
                                local sub_inv = item:FindFirstChild("Inventory")
                                if sub_inv then
                                    for _, sub_item in ipairs(sub_inv:GetChildren()) do
                                        check_item(sub_item)
                                    end
                                end
                                local atts = item:FindFirstChild("Attachments")
                                if atts then
                                    for _, att in ipairs(atts:GetChildren()) do
                                        check_item(att)
                                    end
                                end
                            end
                            for _, item in ipairs(p_inv:GetChildren()) do
                                check_item(item)
                            end
                        end
                    end
                end
            end
            inv_finder_cache = found_players
        end
        local found_players = inv_finder_cache
        
        if #found_players > 0 then
            inv_finder_panel.bg.Visible = true
            inv_finder_panel.border.Visible = true
            inv_finder_panel.title.Visible = true
            
            local max_display = math.min(#found_players, 30)
            local h = 45 + (max_display * 16)
            local p = inv_finder_panel.pos
            local size = _Vector2new(inv_finder_panel.width, h)
            
            local mousepos = _Vector2new(Mouse.X, Mouse.Y + GuiInset.Y)
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                local in_bounds = mousepos.X >= p.X and mousepos.X <= p.X + size.X and mousepos.Y >= p.Y and mousepos.Y <= p.Y + size.Y
                if in_bounds or inv_finder_panel.dragging then
                    if not inv_finder_panel.dragging then
                        inv_finder_panel.dragging = true
                        inv_finder_panel.dragoffset = p - mousepos
                    end
                    inv_finder_panel.pos = mousepos + inv_finder_panel.dragoffset
                    p = inv_finder_panel.pos
                    
                    if cheat.Options.inv_finder_x and cheat.Options.inv_finder_y then
                        cheat.Options.inv_finder_x:SetValue(p.X)
                        cheat.Options.inv_finder_y:SetValue(p.Y)
                    end
                end
            else
                inv_finder_panel.dragging = false
            end
            
            inv_finder_panel.bg.Position = p
            inv_finder_panel.bg.Size = size
            inv_finder_panel.border.Position = p
            inv_finder_panel.border.Size = size
            inv_finder_panel.title.Position = p + _Vector2new(inv_finder_panel.width / 2, 5)
            
            local g_color = inv_finder_glow_color
            local g_size = inv_finder_glow_size
            for i = 1, 6 do
                local th = (i / 6) * g_size
                inv_finder_panel.glow[i].Visible = true
                inv_finder_panel.glow[i].Color = g_color
                inv_finder_panel.glow[i].Thickness = math.max(1, th)
                inv_finder_panel.glow[i].Transparency = 0.3 - (i * 0.04)
                inv_finder_panel.glow[i].Size = size + _Vector2new(th*2, th*2)
                inv_finder_panel.glow[i].Position = p - _Vector2new(th, th)
            end
            
            for i = 1, 30 do
                if i <= max_display then
                    inv_finder_panel.labels[i].Visible = true
                    inv_finder_panel.labels[i].Text = found_players[i]
                    inv_finder_panel.labels[i].Position = p + _Vector2new(inv_finder_panel.width / 2, 25 + (i * 15))
                else
                    inv_finder_panel.labels[i].Visible = false
                end
            end
        else
            inv_finder_panel.bg.Visible = false
            inv_finder_panel.border.Visible = false
            inv_finder_panel.title.Visible = false
            for i = 1, 6 do inv_finder_panel.glow[i].Visible = false end
            for i = 1, 30 do inv_finder_panel.labels[i].Visible = false end
        end
    end))

    player_viewmodel_tab:AddToggle('viewmodel_changer', { Text = 'ViewModel Changer', Default = false, Callback = function()
        local vm = _FindFirstChildOfClass(Camera, "Model")
        if vm then
            task.defer(function()
                vmpos(vm)
            end)
        end
    end})
    player_viewmodel_tab:AddLabel("Viewmodel Offset");
    player_viewmodel_tab:AddSlider('viewmodel_x', { Text = 'X', Default = 0, Min = -5, Max = 5, Rounding = 2, Compact = true });
    player_viewmodel_tab:AddSlider('viewmodel_y', { Text = 'Y', Default = 0, Min = -5, Max = 5, Rounding = 2, Compact = true });
    player_viewmodel_tab:AddSlider('viewmodel_z', { Text = 'Z', Default = 0, Min = -5, Max = 5, Rounding = 2, Compact = true });
    cheat._arm_chams_transparency = cheat._arm_chams_transparency or 0
    cheat._body_chams_transparency = cheat._body_chams_transparency or 0
    cheat._gun_chams_transparency = cheat._gun_chams_transparency or 0
    player_viewmodel_tab:AddToggle("ac", { Text = "Arm Chams", Default = false }):AddColorPicker('acc', { Default = Color3.new(1, 1, 1), Title = 'Arm Chams Color', Transparency = 0, Callback = function(_, alpha)
        cheat._arm_chams_transparency = alpha or cheat._arm_chams_transparency
        vmchams(true)
    end });
    player_viewmodel_tab:AddToggle("bc", { Text = "Body Chams", Default = false }):AddColorPicker('bcc', { Default = Color3.new(1, 1, 1), Title = 'Body Chams Color', Transparency = 0, Callback = function(_, alpha)
        cheat._body_chams_transparency = alpha or cheat._body_chams_transparency
    end });
    player_viewmodel_tab:AddToggle("noarms", { Text = "Remove Arms (Viewmodel)", Default = false, Callback = function(v)
        vmchams(true)
    end });
    player_viewmodel_tab:AddToggle("gm", { Text = "Gun Chams", Default = false }):AddColorPicker('gcc', { Default = Color3.new(1, 1, 1), Title = 'Gun Chams Color', Transparency = 0, Callback = function(_, alpha)
        cheat._gun_chams_transparency = alpha or cheat._gun_chams_transparency
        vmchams(true)
    end });
    player_viewmodel_tab:AddDropdown("acm", { Text = "Arm Chams Material", Default = "SmoothPlastic", Values = { "SmoothPlastic", "ForceField", "Neon", "Plastic", "Glass" } });
    player_viewmodel_tab:AddDropdown("bcm", { Text = "Body Chams Material", Default = "SmoothPlastic", Values = { "SmoothPlastic", "ForceField", "Neon", "Plastic", "Glass" } });
    player_viewmodel_tab:AddDropdown("gcm", { Text = "Gun Chams Material", Default = "SmoothPlastic", Values = { "SmoothPlastic", "ForceField", "Neon", "Plastic", "Glass" } });
    player_viewmodel_tab:AddSlider('arm_chams_transparency', { Text = 'Arm Chams Transparency', Default = 0, Min = 0, Max = 100, Rounding = 0, Compact = true, Callback = function(v)
        cheat._arm_chams_transparency = math.clamp(v / 100, 0, 1)
        vmchams(true)
    end}):SetVisible(false)
    player_viewmodel_tab:AddSlider('body_chams_transparency', { Text = 'Body Chams Transparency', Default = 0, Min = 0, Max = 100, Rounding = 0, Compact = true, Callback = function(v)
        cheat._body_chams_transparency = math.clamp(v / 100, 0, 1)
    end}):SetVisible(false)
    player_viewmodel_tab:AddSlider('gun_chams_transparency', { Text = 'Gun Chams Transparency', Default = 0, Min = 0, Max = 100, Rounding = 0, Compact = true, Callback = function(v)
        cheat._gun_chams_transparency = math.clamp(v / 100, 0, 1)
        vmchams(true)
    end}):SetVisible(false)

    local performance_tab = world_performance_tab
    local force_render_enabled = false
    performance_tab:AddToggle('force_render', { Text = 'Force Render All Players (3k Max)', Default = false, Callback = function(v)
        force_render_enabled = v
    end}):AddKeyPicker('force_render_bind', {Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'Force Render'})

    local extreme_potato_mode = false
    performance_tab:AddToggle('extreme_potato_mode', { Text = 'Extreme Potato Mode', Default = false, Callback = function(v)
        extreme_potato_mode = v
        if v then
            pcall(function()
                setTerrainDecoration(false)
                workspace.Terrain.WaterWaveSize = 0
                workspace.Terrain.WaterWaveSpeed = 0
                workspace.Terrain.WaterReflectance = 0
                workspace.Terrain.WaterTransparency = 0
                game:GetService("Lighting").GlobalShadows = false
                game:GetService("Lighting").FogEnd = 9e9
                for _, obj in pairs(game:GetService("Lighting"):GetChildren()) do
                    if obj:IsA("PostEffect") or obj:IsA("Atmosphere") or obj:IsA("Sky") or obj:IsA("Clouds") then
                        obj.Enabled = false
                    end
                end
            end)
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not (obj.Parent and obj.Parent:FindFirstChild("Humanoid")) then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                    obj.CastShadow = false
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = 1
                end
            end
        end
    end});

    cheat.utility.track_connection(workspace.DescendantAdded:Connect(function(obj)
        if extreme_potato_mode then
            if obj:IsA("BasePart") and not (obj.Parent and obj.Parent:FindFirstChild("Humanoid")) then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.CastShadow = false
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            end
        end
    end))

    task.spawn(function()
        local last_requested = {}
        while task.wait(0.5) do
            if feature_active(force_render_enabled, 'force_render_bind') then
                local rp_players = ReplicatedStorage:FindFirstChild("Players")
                local my_char = LocalPlayer.Character
                local my_pos = my_char and my_char:FindFirstChild("HumanoidRootPart") and my_char.HumanoidRootPart.Position
                
                if rp_players and my_pos then
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and (not p.Character or not p.Character:FindFirstChild("HumanoidRootPart")) then
                            local rp_plr = rp_players:FindFirstChild(p.Name)
                            local status = rp_plr and rp_plr:FindFirstChild("Status")
                            local uac = status and status:FindFirstChild("UAC")
                            local pos = uac and uac:GetAttribute("LastVerifiedPos")
                            
                            if pos and typeof(pos) == "Vector3" then
                                local dist = (pos - my_pos).Magnitude
                                if dist <= 12000 then -- 12000 studs ~ 3360 meters
                                    local now = tick()
                                    if not last_requested[p] or (now - last_requested[p] > 1.5) then
                                        last_requested[p] = now
                                        task.spawn(function()
                                            pcall(function()
                                                LocalPlayer:RequestStreamAroundAsync(pos, 0.5)
                                            end)
                                        end)
                                        task.wait(0.2)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    local r52_0 = cheat.utility.track_instance(Instance.new("ScreenGui", game:GetService("CoreGui")))
    r52_0.Name = "EliteInventory"
    r52_0.Enabled = false
    r52_0.DisplayOrder = 999

    local MainFrame = Instance.new("Frame", r52_0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(13, 17, 23)
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.fromRGB(40, 50, 70)
    MainFrame.Size = UDim2.new(0, 410, 0, 800)
    MainFrame.Position = UDim2.new(0, math.max(20, Camera.ViewportSize.X - 430), 0, 200)

    local MainScale = Instance.new("UIScale", MainFrame)
    MainScale.Name = "MainScale"

    local TopHeader = Instance.new("TextLabel", MainFrame)
    TopHeader.BackgroundTransparency = 1
    TopHeader.Position = UDim2.new(0, 15, 0, 15)
    TopHeader.Size = UDim2.new(1, -30, 0, 20)
    TopHeader.Font = Enum.Font.Arcade
    TopHeader.TextSize = 18
    TopHeader.TextColor3 = Color3.fromRGB(220, 230, 255)
    TopHeader.TextXAlignment = Enum.TextXAlignment.Left
    TopHeader.Text = "INVENTORY VIEWER"

    local TargetNameHeader = Instance.new("TextLabel", MainFrame)
    TargetNameHeader.BackgroundTransparency = 1
    TargetNameHeader.Position = UDim2.new(0, 15, 0, 40)
    TargetNameHeader.Size = UDim2.new(1, -30, 0, 20)
    TargetNameHeader.Font = Enum.Font.Arcade
    TargetNameHeader.TextSize = 16
    TargetNameHeader.TextColor3 = Color3.fromRGB(150, 160, 180)
    TargetNameHeader.TextXAlignment = Enum.TextXAlignment.Left
    TargetNameHeader.Text = ""

    local Divider = Instance.new("Frame", MainFrame)
    Divider.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
    Divider.BorderSizePixel = 0
    Divider.Position = UDim2.new(0, 15, 0, 70)
    Divider.Size = UDim2.new(1, -30, 0, 2)

    local SubHeader = Instance.new("TextLabel", MainFrame)
    SubHeader.BackgroundTransparency = 1
    SubHeader.Position = UDim2.new(0, 15, 0, 80)
    SubHeader.Size = UDim2.new(1, -30, 0, 20)
    SubHeader.Font = Enum.Font.Arcade
    SubHeader.TextSize = 16
    SubHeader.TextColor3 = Color3.fromRGB(220, 230, 255)
    SubHeader.TextXAlignment = Enum.TextXAlignment.Left
    SubHeader.Text = "ITEMS"

    local GridContainer = Instance.new("ScrollingFrame", MainFrame)
    GridContainer.BackgroundTransparency = 1
    GridContainer.Position = UDim2.new(0, 15, 0, 110)
    GridContainer.Size = UDim2.new(1, -30, 1, -120)
    GridContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    GridContainer.ScrollBarThickness = 4
    GridContainer.BorderSizePixel = 0
    
    local GridLayout = Instance.new("UIGridLayout", GridContainer)
    GridLayout.CellSize = UDim2.new(0, 88, 0, 88)
    GridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
    GridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local is_dragging = false
    local drag_offset = Vector2.new(0, 0)
    
    cheat.utility.track_connection(MainFrame.InputBegan:Connect(function(input)
        if cheat.Toggles.inventoryviewer_drag.Value and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            is_dragging = true
            drag_offset = input.Position - Vector3.new(MainFrame.AbsolutePosition.X, MainFrame.AbsolutePosition.Y, 0)
        end
    end))
    
    cheat.utility.track_connection(game:GetService("UserInputService").InputChanged:Connect(function(input)
        if is_dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local new_pos = input.Position - drag_offset
            cheat.Options.inventoryviewer_x:SetValue(new_pos.X)
            cheat.Options.inventoryviewer_y:SetValue(new_pos.Y)
        end
    end))
    
    cheat.utility.track_connection(game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            is_dragging = false
        end
    end))

    local inventory = {}
    function inventory:refresh() end
    local LastTargetInventory = nil
    
    local function formatMoney(amount)
        local formatted = tostring(amount)
        while true do  
            formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
            if (k==0) then break end
        end
        return formatted
    end

    function inventory:update(__obj)
        if not __obj then 
            r52_0.Enabled = false
            return 
        end
        r52_0.Enabled = false
        MainFrame.Position = UDim2.new(0, cheat.Options.inventoryviewer_x.Value, 0, cheat.Options.inventoryviewer_y.Value)
        local scale_obj = MainFrame:FindFirstChild("MainScale")
        if scale_obj then scale_obj.Scale = cheat.Options.inventoryviewer_scale.Value end
        
        local inv = __obj:FindFirstChild("Inventory")
        if not inv then
            local rp = ReplicatedStorage:FindFirstChild("Players")
            local rpp = rp and rp:FindFirstChild(__obj.Name)
            inv = rpp and rpp:FindFirstChild("Inventory")
        end

        if inv or not (LastTargetInventory == __obj) then
            local existing_cards = {}
            for _, child in pairs(GridContainer:GetChildren()) do
                if child:IsA("Frame") then 
                    child.Visible = false
                    table.insert(existing_cards, child) 
                end
            end
            
            local ItemsList = ReplicatedStorage:FindFirstChild("ItemsList")
            local itemCount = 0
            local val = 0
            
            if inv and ItemsList then
                local function process_item(item_folder, hidden)
                    local n = string.lower(item_folder.Name)
                    if n:find("dagr") or n:find("keychain") or n:find("map") or n:find("lighter") or n:find("radio") or n:find("compass") or n:find("pathfinder") or n:find("dv%-2") or n:find("dv2") then return end
                    
                    local item_ref = ItemsList:FindFirstChild(item_folder.Name)
                    if item_ref and item_ref:FindFirstChild("ItemProperties") and item_ref:FindFirstChild("ItemProperties"):FindFirstChild("ItemIcon") then
                        local itype = item_ref.ItemProperties:GetAttribute("ItemType")
                        if itype == "Melee" or itype == "MeleeWeapon" then return end
                        
                        if item_folder.Name ~= "Rubles" then
                            local price = item_ref.ItemProperties:GetAttribute("Price") or 1
                            if price >= 10 then
                                local itype = item_ref.ItemProperties:GetAttribute("ItemType")
                                if itype == "Extra" then price = price * 0.4
                                elseif itype == "Ammo" then price = price * (item_folder:GetAttribute("Amount") or 1) * 0.7
                                elseif itype == "Clothing" then price = price * 0.35
                                elseif itype == "Medical" then price = price * 0.75
                                elseif itype == "Barter" then price = price * 0.4 end
                            end
                            val = val + price
                        else
                            val = val + (item_folder:GetAttribute("Amount") or 1)
                        end
                        
                        if hidden then return end
                        
                        itemCount = itemCount + 1
                        
                        local card = existing_cards[itemCount]
                        if not card then
                            card = Instance.new("Frame", GridContainer)
                            card.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
                            card.BorderSizePixel = 1
                            card.BorderColor3 = Color3.fromRGB(40, 50, 70)
                            
                            local icon = Instance.new("ImageLabel", card)
                            icon.BackgroundTransparency = 1
                            icon.Size = UDim2.new(0.8, 0, 0.8, 0)
                            icon.Position = UDim2.new(0.1, 0, 0.05, 0)
                            icon.ScaleType = Enum.ScaleType.Fit
                            
                            local label = Instance.new("TextLabel", card)
                            label.BackgroundTransparency = 1
                            label.Position = UDim2.new(0, 5, 1, -15)
                            label.Size = UDim2.new(1, -10, 0, 15)
                            label.Font = Enum.Font.Arcade
                            label.TextSize = 12
                            label.TextColor3 = Color3.fromRGB(220, 230, 255)
                            label.TextXAlignment = Enum.TextXAlignment.Left
                        end
                        
                        card.LayoutOrder = itemCount
                        card.Visible = true
                        card:FindFirstChildOfClass("ImageLabel").Image = item_ref.ItemProperties.ItemIcon.Image
                        
                        local itemName = item_folder.Name:upper()
                        if #itemName > 12 then itemName = itemName:sub(1, 10) .. "..." end
                        card:FindFirstChildOfClass("TextLabel").Text = itemName
                    end
                end

                for _, slot in pairs(inv:GetChildren()) do
                    process_item(slot, false)
                    local slot_attr = slot:GetAttribute("Slot")
                    if slot_attr and slot_attr:find("Clothing") and slot:FindFirstChild("Inventory") then
                        if cheat.Toggles.inventoryviewer_full.Value then
                            for _, sub_item in pairs(slot.Inventory:GetChildren()) do
                                process_item(sub_item, false)
                            end
                        end
                    elseif slot:FindFirstChild("Attachments") then
                        for _, att in pairs(slot.Attachments:GetChildren()) do
                            process_item(att, true)
                        end
                    end
                end
            end
            
            val = math.floor(val)
            TopHeader.Text = "INVENTORY VIEWER - " .. itemCount .. " ITEMS" .. (cheat.Toggles.inventoryviewer_value.Value and (", $" .. formatMoney(val)) or "")
            TargetNameHeader.Text = __obj.Name:upper()
            SubHeader.Text = "ITEMS (" .. itemCount .. ")"
            
            local rows = math.ceil(itemCount / 4)
            GridContainer.CanvasSize = UDim2.new(0, 0, 0, rows * 96)
            MainFrame.Size = UDim2.new(0, 410, 0, math.clamp(130 + rows * 96, 300, 900))
        end
        LastTargetInventory = __obj
    end
    local ghost_inventory_gui = cheat.utility.track_instance(Instance.new("ScreenGui", game:GetService("CoreGui")))
    ghost_inventory_gui.Name = "GhostHookInventoryChecker"
    ghost_inventory_gui.ResetOnSpawn = false
    ghost_inventory_gui.IgnoreGuiInset = true
    ghost_inventory_gui.DisplayOrder = 1001

    local inventoryViewerTitle = Instance.new("TextLabel", ghost_inventory_gui)
    inventoryViewerTitle.Size = UDim2.new(0.28, 0, 0, 24)
    inventoryViewerTitle.Position = UDim2.new(0.5, 0, 0, 54)
    inventoryViewerTitle.AnchorPoint = Vector2.new(0.5, 0.5)
    inventoryViewerTitle.BackgroundTransparency = 1
    inventoryViewerTitle.TextColor3 = inventory_checker.title_color
    inventoryViewerTitle.Font = Enum.Font.GothamSemibold
    inventoryViewerTitle.Visible = false
    inventoryViewerTitle.TextScaled = true

    local equippedItemIcons = {}
    local attachmentIcons = {}
    local fullInventoryIcons = {}
    local fullInventoryCounts = {}
    local blank_icon = "rbxassetid://12459616555"
    local fullInventoryGrid = {
        pos = nil,
        dragging = false,
        drag_offset = Vector2.zero,
        width = (6 * 35 + 5 * 6),
        height = (9 * 35 + 8 * 5),
        y = 170,
    }

    local function make_inv_icon(size, bg, transparency)
        local icon = Instance.new("ImageLabel", ghost_inventory_gui)
        icon.Visible = false
        icon.Size = UDim2.new(0, size.X, 0, size.Y)
        icon.BackgroundTransparency = transparency
        icon.BackgroundColor3 = bg
        icon.BorderSizePixel = 0
        icon.ScaleType = Enum.ScaleType.Fit
        icon.Image = blank_icon
        local corner = Instance.new("UICorner", icon)
        corner.CornerRadius = UDim.new(0, 8)
        return icon
    end

    for i = 1, 12 do
        equippedItemIcons[i] = make_inv_icon(Vector2.new(60, 60), Color3.fromRGB(30, 30, 30), 0.25)
        attachmentIcons[i] = make_inv_icon(Vector2.new(16, 18), Color3.fromRGB(155, 30, 30), 0.2)
        attachmentIcons[i].ZIndex = 2
    end
    for i = 1, 54 do
        fullInventoryIcons[i] = make_inv_icon(Vector2.new(35, 35), Color3.fromRGB(0, 0, 0), 0.35)
        local count = Instance.new("TextLabel", ghost_inventory_gui)
        count.Visible = false
        count.Text = ""
        count.TextScaled = true
        count.Size = UDim2.new(0, 24, 0, 15)
        count.BackgroundTransparency = 1
        count.TextColor3 = Color3.fromRGB(255, 255, 255)
        count.Font = Enum.Font.GothamSemibold
        count.ZIndex = 3
        fullInventoryCounts[i] = count
    end

    local fullInventoryDragFrame = Instance.new("Frame", ghost_inventory_gui)
    fullInventoryDragFrame.Visible = false
    fullInventoryDragFrame.Active = true
    fullInventoryDragFrame.BackgroundTransparency = 1
    fullInventoryDragFrame.BorderSizePixel = 0
    fullInventoryDragFrame.ZIndex = 1

    local function beginFullInventoryDrag(input)
        if not (inventory_checker.full and fullInventoryDragFrame.Visible) then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            fullInventoryGrid.dragging = true
            fullInventoryGrid.drag_offset = _Vector2new(input.Position.X, input.Position.Y) - fullInventoryGrid.pos
        end
    end

    cheat.utility.track_connection(fullInventoryDragFrame.InputBegan:Connect(beginFullInventoryDrag))
    for i = 1, 54 do
        fullInventoryIcons[i].Active = true
        fullInventoryCounts[i].Active = true
        cheat.utility.track_connection(fullInventoryIcons[i].InputBegan:Connect(beginFullInventoryDrag))
        cheat.utility.track_connection(fullInventoryCounts[i].InputBegan:Connect(beginFullInventoryDrag))
    end

    cheat.utility.track_connection(UserInputService.InputChanged:Connect(function(input)
        if not fullInventoryGrid.dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            fullInventoryGrid.pos = _Vector2new(input.Position.X, input.Position.Y) - fullInventoryGrid.drag_offset
        end
    end))

    cheat.utility.track_connection(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            fullInventoryGrid.dragging = false
        end
    end))

    local function positionInventoryViewer()
        local viewport = Camera.ViewportSize
        local base_x = (viewport.X - (12 * 60 + 11 * 12)) / 2
        for i = 1, 12 do
            local x = base_x + (i - 1) * 72
            equippedItemIcons[i].Position = UDim2.new(0, x, 0, 82)
            local weapon_index = math.floor((i - 1) / 4) + 1
            local attachment_index = ((i - 1) % 4) + 1
            local weapon_x = base_x + (weapon_index - 1) * 72
            local attachment_width = 16
            local attachment_gap = 2
            local attachment_group_width = (attachment_width * 4) + (attachment_gap * 3)
            local attachment_x = weapon_x + ((60 - attachment_group_width) / 2) + ((attachment_index - 1) * (attachment_width + attachment_gap))
            attachmentIcons[i].Position = UDim2.new(0, attachment_x, 0, 138)
            if weapon_index == 1 then
                attachmentIcons[i].BackgroundColor3 = Color3.fromRGB(155, 20, 30)
            elseif weapon_index == 2 then
                attachmentIcons[i].BackgroundColor3 = Color3.fromRGB(30, 50, 155)
            else
                attachmentIcons[i].BackgroundColor3 = Color3.fromRGB(50, 155, 30)
            end
        end

        if not fullInventoryGrid.pos then
            fullInventoryGrid.pos = _Vector2new(math.max(12, viewport.X - fullInventoryGrid.width - 24), fullInventoryGrid.y)
        end
        local max_x = math.max(0, viewport.X - fullInventoryGrid.width - 4)
        local max_y = math.max(0, viewport.Y - fullInventoryGrid.height - 4)
        fullInventoryGrid.pos = _Vector2new(
            math.clamp(fullInventoryGrid.pos.X, 0, max_x),
            math.clamp(fullInventoryGrid.pos.Y, 0, max_y)
        )
        fullInventoryDragFrame.Position = UDim2.new(0, fullInventoryGrid.pos.X, 0, fullInventoryGrid.pos.Y)
        fullInventoryDragFrame.Size = UDim2.new(0, fullInventoryGrid.width, 0, fullInventoryGrid.height)

        for i = 1, 54 do
            local col = (i - 1) % 6
            local row = math.floor((i - 1) / 6)
            local x = fullInventoryGrid.pos.X + col * 41
            local y = fullInventoryGrid.pos.Y + row * 40
            fullInventoryIcons[i].Position = UDim2.new(0, x, 0, y)
            fullInventoryCounts[i].Position = UDim2.new(0, x + 13, 0, y + 23)
        end
    end

    local inventoryViewerCache = {
        LastVisibility = false,
        LastVisibleFull = false,
        LastTargetInventory = nil,
        LastTargetValueName = nil,
        LastTargetValue = 0,
        CurrentTarget = nil,
        LastTargetSearch = 0,
        LastRender = 0,
        LastFullState = nil,
    }

    local function setInventoryVisibility(visible)
        local show_full = visible and inventory_checker.full
        if inventoryViewerCache.LastVisibility == visible and inventoryViewerCache.LastVisibleFull == show_full then return end
        inventoryViewerCache.LastVisibility = visible
        inventoryViewerCache.LastVisibleFull = show_full
        for i = 1, 12 do
            equippedItemIcons[i].Visible = visible
            attachmentIcons[i].Visible = visible
        end
        for i = 1, 54 do
            fullInventoryIcons[i].Visible = show_full
            fullInventoryCounts[i].Visible = show_full
        end
        fullInventoryDragFrame.Visible = show_full
    end

    local function getInventoryContainer(target)
        if not target then return nil end
        if target:IsA("Player") then
            local folder = ReplicatedStorage:FindFirstChild("Players")
            local player_folder = folder and folder:FindFirstChild(target.Name)
            return player_folder and player_folder:FindFirstChild("Inventory")
        end
        if target:IsA("Model") and target:FindFirstChildOfClass("Humanoid") and target:FindFirstChild("Inventory") then
            return target.Inventory
        end
        local folder = ReplicatedStorage:FindFirstChild("Players")
        local player_folder = folder and folder:FindFirstChild(target.Name)
        return player_folder and player_folder:FindFirstChild("Inventory")
    end

    local function getItemIcon(item_name)
        local ItemsList = ReplicatedStorage:FindFirstChild("ItemsList")
        local ref = ItemsList and ItemsList:FindFirstChild(item_name)
        local props = ref and ref:FindFirstChild("ItemProperties")
        local icon = props and props:FindFirstChild("ItemIcon")
        return icon and icon.Image or blank_icon
    end

    local function renderInventoryViewer(target)
        local inv = getInventoryContainer(target)
        if not inv then return false end
        for i = 1, 12 do
            equippedItemIcons[i].Image = blank_icon
            attachmentIcons[i].Image = blank_icon
        end
        for i = 1, 54 do
            fullInventoryIcons[i].Image = blank_icon
            fullInventoryCounts[i].Text = ""
        end

        local clothing_index = 4
        local weapon_index = 1
        local attach_base = 0
        for _, item in pairs(inv:GetChildren()) do
            local slot = item:GetAttribute("Slot")
            if slot and slot:find("Clothing") then
                if clothing_index <= 12 then
                    equippedItemIcons[clothing_index].Image = getItemIcon(item.Name)
                    clothing_index = clothing_index + 1
                end
            elseif item:FindFirstChild("Attachments") then
                if weapon_index <= 3 then
                    equippedItemIcons[weapon_index].Image = getItemIcon(item.Name)
                    for _, attachment in pairs(item.Attachments:GetChildren()) do
                        local attachment_slot = attachment:GetAttribute("Slot")
                        local attachment_index
                        if attachment_slot == "Magazine" then attachment_index = 1
                        elseif attachment_slot == "Sight" then attachment_index = 2
                        elseif attachment_slot == "Muzzle" then attachment_index = 3
                        elseif attachment_slot == "Extra" then attachment_index = 4 end
                        if attachment_index and attachmentIcons[attach_base + attachment_index] then
                            attachmentIcons[attach_base + attachment_index].Image = getItemIcon(attachment.Name)
                        end
                    end
                    weapon_index = weapon_index + 1
                    attach_base = attach_base + 4
                end
            end
        end

        if inventory_checker.full then
            local index = 1
            for _, slot in pairs(inv:GetChildren()) do
                local slot_inv = slot:FindFirstChild("Inventory")
                if slot_inv and slot.Name ~= "KeyChain" then
                    for _, item in pairs(slot_inv:GetChildren()) do
                        if index > 54 then break end
                        local amount = item:GetAttribute("Amount") or 1
                        fullInventoryIcons[index].Image = getItemIcon(item.Name)
                        fullInventoryCounts[index].Text = amount >= 1000 and (math.floor(amount / 1000) .. "K") or ("x" .. amount)
                        index = index + 1
                    end
                end
                if index > 54 then break end
            end
        end
        inventoryViewerCache.LastTargetInventory = target
        return true
    end

    local function estimateInventoryValue(target)
        if inventoryViewerCache.LastTargetValueName == target.Name then
            return inventoryViewerCache.LastTargetValue
        end
        local inv = getInventoryContainer(target)
        local ItemsList = ReplicatedStorage:FindFirstChild("ItemsList")
        local total = 0
        if inv and ItemsList then
            for _, slot in pairs(inv:GetChildren()) do
                local slot_inv = slot:FindFirstChild("Inventory")
                if slot_inv then
                    for _, item in pairs(slot_inv:GetChildren()) do
                        local ref = ItemsList:FindFirstChild(item.Name)
                        local props = ref and ref:FindFirstChild("ItemProperties")
                        if props then
                            if item.Name == "Rubles" then
                                total = total + (item:GetAttribute("Amount") or 1)
                            else
                                local price = props:GetAttribute("Price") or 1
                                if price >= 10 then
                                    local item_type = props:GetAttribute("ItemType")
                                    if item_type == "Extra" then price = price * 0.4
                                    elseif item_type == "Ammo" then price = price * (item:GetAttribute("Amount") or 1) * 0.7
                                    elseif item_type == "Clothing" then price = price * 0.35
                                    elseif item_type == "Medical" then price = price * 0.75
                                    elseif item_type == "Barter" then price = price * 0.4 end
                                end
                                total = total + price
                            end
                        end
                    end
                end
            end
        end
        inventoryViewerCache.LastTargetValueName = target.Name
        inventoryViewerCache.LastTargetValue = math.floor(total)
        return inventoryViewerCache.LastTargetValue
    end

    local function findInventoryCheckTarget()
        if silent_aim.target_part and silent_aim.target_part.Parent then
            local player = Players:GetPlayerFromCharacter(silent_aim.target_part.Parent)
            if player then return player end
        end
        local best, best_dist = nil, math.huge
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        for _, player in ipairs(Players:GetPlayers()) do
            local char = player.Character
            local head = char and char:FindFirstChild("Head")
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if player ~= LocalPlayer and head and humanoid and humanoid.Health > 0 then
                local screen, onscreen = Camera:WorldToViewportPoint(head.Position)
                if onscreen and screen.Z > 0 then
                    local dist = (Vector2.new(screen.X, screen.Y) - center).Magnitude
                    if dist < best_dist then
                        best = player
                        best_dist = dist
                    end
                end
            end
        end
        if inventory_checker.corpse then
            local dropped = workspace:FindFirstChild("DroppedItems")
            if dropped then
                for _, corpse in ipairs(dropped:GetChildren()) do
                    local head = corpse:FindFirstChild("Head")
                    if corpse:FindFirstChildOfClass("Humanoid") and head and not corpse:FindFirstChild("AttackedBy") then
                        local screen, onscreen = Camera:WorldToViewportPoint(head.Position)
                        if onscreen and screen.Z > 0 then
                            local dist = (Vector2.new(screen.X, screen.Y) - center).Magnitude
                            if dist < best_dist then
                                best = corpse
                                best_dist = dist
                            end
                        end
                    end
                end
            end
        end
        return best
    end

    local function updateGhostInventoryViewer()
        if not feature_active(inventory_checker.enabled, 'inventorychecker_bind') then
            setInventoryVisibility(false)
            inventoryViewerTitle.Visible = false
            return
        end
        positionInventoryViewer()
        local now = tick()
        local cached_target = inventoryViewerCache.CurrentTarget
        local target_missing = not cached_target or (cached_target:IsA("Model") and not cached_target.Parent)
        if now - inventoryViewerCache.LastTargetSearch > 0.08 or target_missing then
            inventoryViewerCache.LastTargetSearch = now
            inventoryViewerCache.CurrentTarget = findInventoryCheckTarget()
        end
        local target = inventoryViewerCache.CurrentTarget
        local needs_render = target ~= inventoryViewerCache.LastTargetInventory
            or inventoryViewerCache.LastFullState ~= inventory_checker.full
            or now - inventoryViewerCache.LastRender > 0.12

        if not target or (needs_render and not renderInventoryViewer(target)) then
            setInventoryVisibility(false)
            inventoryViewerTitle.Visible = false
            return
        end
        if needs_render then
            inventoryViewerCache.LastRender = now
            inventoryViewerCache.LastFullState = inventory_checker.full
        end
        setInventoryVisibility(true)
        if inventory_checker.target or inventory_checker.value then
            local kind = target:IsA("Model") and " | Corpse " or " | Inventory "
            if inventory_checker.target and inventory_checker.value then
                inventoryViewerTitle.Text = "Viewing " .. target.Name .. kind .. "| $" .. formatMoney(estimateInventoryValue(target))
            elseif inventory_checker.target then
                inventoryViewerTitle.Text = "Viewing " .. target.Name .. kind
            else
                inventoryViewerTitle.Text = "$" .. formatMoney(estimateInventoryValue(target))
            end
            inventoryViewerTitle.TextColor3 = inventory_checker.title_color
            inventoryViewerTitle.Visible = true
        else
            inventoryViewerTitle.Visible = false
        end
    end
    vmpos = function(vm)
        if not vm then return end
        local hrp = vm:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local changer_enabled = Toggles.viewmodel_changer and Toggles.viewmodel_changer.Value
        local vec = changer_enabled and Vector3.new(cheat.Options.viewmodel_x.Value, cheat.Options.viewmodel_y.Value, cheat.Options.viewmodel_z.Value) or Vector3.zero
        local function apply_joint(name)
            local joint = hrp:FindFirstChild(name)
            if joint and joint:IsA("Motor6D") then
                local orig = joint:GetAttribute("OriginalC0")
                if not orig then
                    orig = joint.C0
                    joint:SetAttribute("OriginalC0", orig)
                end
                joint.C0 = orig + vec
            end
        end
        apply_joint("LeftUpperArm")
        apply_joint("RightUpperArm")
        apply_joint("ItemRoot")
        apply_joint("Motor6D")
    end
    cheat.utility.restore_viewmodel = function()
        local vm = _FindFirstChildOfClass(Camera, "Model")
        if not vm then return end
        local hrp = vm:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for _, name in ipairs({"LeftUpperArm", "RightUpperArm", "ItemRoot", "Motor6D"}) do
            local joint = hrp:FindFirstChild(name)
            if joint and joint:IsA("Motor6D") then
                local orig = joint:GetAttribute("OriginalC0")
                if orig then
                    joint.C0 = orig
                end
            end
        end
    end
    cheat._last_vm_item = cheat._last_vm_item or nil
    cheat._last_vm_update = cheat._last_vm_update or 0
    cheat._is_chamming = false
    local function is_arm_cham_part(part)
        local name = tostring(part and part.Name or ""):lower():gsub("[%s_%-]", "")
        return name == "lefthand"
            or name == "righthand"
            or name == "leftarm"
            or name == "rightarm"
            or name == "leftupperarm"
            or name == "rightupperarm"
            or name == "leftlowerarm"
            or name == "rightlowerarm"
            or name:match("^left.*hand$")
            or name:match("^right.*hand$")
            or name:match("^left.*arm$")
            or name:match("^right.*arm$")
    end
    vmchams = function(force) LPH_JIT_MAX(function()
        if cheat._is_chamming then return end
        local vm = _FindFirstChildOfClass(Camera, "Model")
        if not vm then return end
        local ItemView = _FindFirstChild(vm, "Item")
        if not force and ItemView == cheat._last_vm_item and tick() - cheat._last_vm_update < 0.5 then return end
        cheat._last_vm_item = ItemView
        cheat._last_vm_update = tick()
        cheat._is_chamming = true
        task.spawn(function()
            if not vm.Parent then cheat._is_chamming = false return end
            local guncolor = cheat.Options.gcc.Value
            local gunmaterial = cheat.Options.gcm.Value
            local armcolor = cheat.Options.acc.Value
            local armmaterial = cheat.Options.acm.Value
            if ItemView and Toggles.gm.Value then
                for _, v in pairs(ItemView:GetDescendants()) do
                    if (v:IsA("MeshPart") or v:IsA("BasePart")) and v.Transparency < 1 and v.Name ~= "Muzzle" and v.Name ~= "SightMark" and v.Name ~= "AimPart" and v.Name ~= "SmokePart" and v.Name ~= "FirePoint" and v.Name ~= "Flash" and v.Name ~= "Flame" then
                        v.Material = Enum.Material[gunmaterial]
                        v.Color = guncolor
                        v.Transparency = cheat._gun_chams_transparency
                        local sa = v:FindFirstChildOfClass("SurfaceAppearance")
                        if sa then sa:Destroy() end
                    end
                end
            end
            if Toggles.noarms.Value then
                for _, vm_item in pairs(vm:GetChildren()) do
                    if vm_item:IsA("MeshPart") then
                        if vm_item.Name:find("Hand") or vm_item.Name:find("Arm") then
                            vm_item.Transparency = 1
                        end
                    elseif vm_item:IsA("Model") and (_FindFirstChild(vm_item, "LL") or _FindFirstChild(vm_item, "LH")) then
                        for _, shirt_item in pairs(vm_item:GetChildren()) do
                            shirt_item.Transparency = 1
                        end
                    end
                end
            else
                -- Restore normal transparency if noarms is off
                for _, vm_item in pairs(vm:GetChildren()) do
                    if vm_item:IsA("MeshPart") then
                        if vm_item.Name:find("Hand") or vm_item.Name:find("Arm") then
                            vm_item.Transparency = 0
                        end
                    elseif vm_item:IsA("Model") and (_FindFirstChild(vm_item, "LL") or _FindFirstChild(vm_item, "LH")) then
                        for _, shirt_item in pairs(vm_item:GetChildren()) do
                            shirt_item.Transparency = 0
                        end
                    end
                end
            end
            if Toggles.ac.Value and not Toggles.noarms.Value then
                for _, vm_item in pairs(vm:GetChildren()) do
                if vm_item:IsA("MeshPart") then
                    if vm_item.Name:find("Hand") or vm_item.Name:find("Arm") then
                            vm_item.Material = Enum.Material[armmaterial]
                            vm_item.Color = armcolor
                            vm_item.Transparency = cheat._arm_chams_transparency
                        end
                    elseif vm_item:IsA("Model") and (_FindFirstChild(vm_item, "LL") or _FindFirstChild(vm_item, "LH")) then
                        for _, shirt_item in pairs(vm_item:GetChildren()) do
                            local sa = shirt_item:FindFirstChildOfClass("SurfaceAppearance")
                            if sa then sa:Destroy() end
                            shirt_item.Material = Enum.Material[armmaterial]
                            shirt_item.Color = armcolor
                            shirt_item.Transparency = cheat._arm_chams_transparency
                        end
                    end
                end
            end
            cheat._is_chamming = false
        end)
    end)() end
    cheat.utility.track_connection(Camera.ChildAdded:Connect(function(child)
        local viewmodel_enabled = (Toggles.viewmodel_changer and Toggles.viewmodel_changer.Value) or Toggles.gm.Value or Toggles.ac.Value or Toggles.noarms.Value
        if not viewmodel_enabled then return end
        task.spawn(function()
            if child:IsA("Model") then
                child:WaitForChild("HumanoidRootPart", 1)
                task.wait()
                vmpos(child)
            end
        end)
        if child:IsA("Model") then
            vmchams(true)
        end
    end))
    cheat.utility.track_connection(Camera.DescendantAdded:Connect(function()
        if Toggles.gm.Value or Toggles.ac.Value or Toggles.noarms.Value then
            vmchams()
        end
    end))
    cheat._last_character_chams_update = cheat._last_character_chams_update or 0
    cheat.utility.new_heartbeat(function()
        local character_chams_enabled = Toggles.gm.Value or Toggles.ac.Value or Toggles.bc.Value or Toggles.noarms.Value
        local viewmodel_enabled = (Toggles.viewmodel_changer and Toggles.viewmodel_changer.Value) or character_chams_enabled
        if not viewmodel_enabled then
            return
        end

        local vm = _FindFirstChildOfClass(Camera, "Model")
        if vm then vmpos(vm) end
        
        local char = LocalPlayer.Character
        if char and character_chams_enabled and tick() - cheat._last_character_chams_update > 0.2 then
            cheat._last_character_chams_update = tick()
            local guncolor = cheat.Options.gcc.Value
            local gunmaterial = cheat.Options.gcm.Value
            local armcolor = cheat.Options.acc.Value
            local armmaterial = cheat.Options.acm.Value
            local bodycolor = cheat.Options.bcc.Value
            local bodymaterial = cheat.Options.bcm.Value
            for _, v in pairs(char:GetChildren()) do
                if Toggles.bc.Value and v:IsA("Shirt") then
                    v.ShirtTemplate = ""
                elseif Toggles.bc.Value and v:IsA("Pants") then
                    v.PantsTemplate = ""
                elseif Toggles.bc.Value and v:IsA("ShirtGraphic") then
                    v.Graphic = ""
                end
            end
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("MeshPart") then
                    local is_weapon = v:FindFirstAncestor("Item") or v:FindFirstAncestor("Weapon") or v.Name:find("Gun") or v.Name:find("Handle")
                    if Toggles.gm.Value and is_weapon then
                        if v.Color ~= guncolor or v.Material ~= Enum.Material[gunmaterial] or (v:IsA("MeshPart") and v.TextureID ~= "") then
                            v.Material = Enum.Material[gunmaterial]
                            v.Color = guncolor
                            v.Transparency = cheat._gun_chams_transparency
                            if v:IsA("MeshPart") then v.TextureID = "" end
                            local sa = v:FindFirstChildOfClass("SurfaceAppearance")
                            if sa then sa:Destroy() end
                        end
                    elseif Toggles.ac.Value and is_arm_cham_part(v) then
                        if v.Color ~= armcolor or v.Material ~= Enum.Material[armmaterial] or (v:IsA("MeshPart") and v.TextureID ~= "") then
                            v.Material = Enum.Material[armmaterial]
                            v.Color = armcolor
                            v.Transparency = cheat._arm_chams_transparency
                            if v:IsA("MeshPart") then v.TextureID = "" end
                            local sa = v:FindFirstChildOfClass("SurfaceAppearance")
                            if sa then sa:Destroy() end
                        end
                    elseif Toggles.bc.Value and not is_arm_cham_part(v) then
                        if v.Color ~= bodycolor or v.Material ~= Enum.Material[bodymaterial] or (v:IsA("MeshPart") and v.TextureID ~= "") then
                            v.Material = Enum.Material[bodymaterial]
                            v.Color = bodycolor
                            v.Transparency = cheat._body_chams_transparency
                            if v:IsA("MeshPart") then v.TextureID = "" end
                            local sa = v:FindFirstChildOfClass("SurfaceAppearance")
                            if sa then sa:Destroy() end
                        end
                    end
                end
            end
        end
        if character_chams_enabled then
            vmchams()
        end
    end)
    cheat._screen_effect_original_visible = cheat._screen_effect_original_visible or {}
    cheat._last_screen_effects_lookup = 0
    cheat.utility.apply_no_screen_effects = function(enabled)
        local effects = LocalPlayer.PlayerGui
            and _FindFirstChild(LocalPlayer.PlayerGui, "NoInsetGui")
            and _FindFirstChild(_FindFirstChild(LocalPlayer.PlayerGui, "NoInsetGui"), "MainFrame")
            and _FindFirstChild(_FindFirstChild(_FindFirstChild(LocalPlayer.PlayerGui, "NoInsetGui"), "MainFrame"), "ScreenEffects")
        cheat._cached_screen_effects = effects

        if effects then
            if enabled then
                for _, name in ipairs({"Visor", "HelmetMask", "Mask", "Flashbang"}) do
                    local child = effects:FindFirstChild(name)
                    if child then
                        if cheat._screen_effect_original_visible[child] == nil then
                            cheat._screen_effect_original_visible[child] = child.Visible
                        end
                        child.Visible = false
                    end
                end
                effects.Visible = false
            else
                effects.Visible = true
                for child, was_visible in pairs(cheat._screen_effect_original_visible) do
                    if child and child.Parent then
                        child.Visible = was_visible
                    end
                    cheat._screen_effect_original_visible[child] = nil
                end
            end
        end

        local blur = Lighting:FindFirstChild("InventoryBlur")
        if blur and blur:IsA("BlurEffect") then
            cheat._inventory_blur_original_size = cheat._inventory_blur_original_size or blur.Size
            blur.Size = enabled and 0 or cheat._inventory_blur_original_size
        end

        local static_lcd = Camera:FindFirstChild("ViewModel")
            and Camera.ViewModel:FindFirstChild("Item")
            and Camera.ViewModel.Item:FindFirstChild("Attachments")
            and Camera.ViewModel.Item.Attachments:FindFirstChild("Sight")
            and Camera.ViewModel.Item.Attachments.Sight:FindFirstChild("Reapir")
            and Camera.ViewModel.Item.Attachments.Sight.Reapir:FindFirstChild("Reticle")
            and Camera.ViewModel.Item.Attachments.Sight.Reapir.Reticle:FindFirstChild("PrismScopeGui")
            and Camera.ViewModel.Item.Attachments.Sight.Reapir.Reticle.PrismScopeGui:FindFirstChild("Sight")
            and Camera.ViewModel.Item.Attachments.Sight.Reapir.Reticle.PrismScopeGui.Sight:FindFirstChild("StaticLCD")
        if static_lcd then
            static_lcd.Visible = not enabled
        end
    end

    cheat._noscreenfx_last = false
    cheat.utility.new_renderstepped(LPH_JIT_MAX(function()
        local noscreen_enabled = cheat.Toggles.noscreenfx and cheat.Toggles.noscreenfx.Value
        if noscreen_enabled or cheat._noscreenfx_last then
            if tick() - cheat._last_screen_effects_lookup > 0.25 or not (cheat._cached_screen_effects and cheat._cached_screen_effects.Parent) then
                cheat._last_screen_effects_lookup = tick()
                cheat.utility.apply_no_screen_effects(noscreen_enabled)
            elseif cheat.Toggles.noscreenfx then
                cheat.utility.apply_no_screen_effects(noscreen_enabled)
            end
            cheat._noscreenfx_last = noscreen_enabled
        end
        if inventory_checker.enabled or inventoryViewerTitle.Visible then
            updateGhostInventoryViewer()
        end
    end))
end
do
    local mvb = ui.box.move:AddTab('Character')
    local speed_enabled, speed = false, 55
    local omni_sprint = false
    local tp_enabled, tp_dist = false, 10
    local jesus_enabled = false
    local water_part = nil
    local thirdperson_locked_mouse = false
    local thirdperson_was_active = false
    local function thirdperson_key_active()
        local option = cheat.Options and cheat.Options.thirdperson_bind
        if not option then return false end
        local value = option.Value
        local key = option.Key
        local mode = option.Mode
        local active = option.State
        if type(value) == "table" then
            key = value.Key or key
            mode = value.Type or value.Mode or mode
            active = value.Active ~= nil and value.Active or active
        end
        key = tostring(key or "None")
        if key == "" or key == "None" or key == "NONE" then
            return false
        end
        return mode == "Always" or active == true
    end
    local function thirdperson_active()
        return (tp_enabled or thirdperson_key_active()) and true or false
    end
    mvb:AddToggle('omni_sprint', {Text = 'Omni Sprint', Default = false, Callback = function(first)
        omni_sprint = first
    end})
    mvb:AddToggle('speedhack_enabled', {Text = 'Speed Hack',Default = false,Callback = function(first)
        speed_enabled = first
    end}):AddKeyPicker('speedhack_bind', {Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'Speed Hack', NoUI = false})
    mvb:AddSlider('speedhack_speed',{ Text = 'Speed', Default = 18.2, Min = 10, Max = 22, Rounding = 1, Suffix = "sps", Compact = false }):OnChanged(function(State)
        speed = State
    end)
    world_thirdperson_tab:AddToggle('thirdperson_enabled', {Text = 'Third Person', Default = false, Callback = function(first)
        tp_enabled = first
        if not first then
            if not thirdperson_key_active() then
                LocalPlayer.CameraMaxZoomDistance = cheat.original_state.CameraMaxZoomDistance or 128
                LocalPlayer.CameraMinZoomDistance = cheat.original_state.CameraMinZoomDistance or 0.5
                LocalPlayer.CameraMode = cheat.original_state.CameraMode or Enum.CameraMode.Classic
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                thirdperson_locked_mouse = false
            end
        end
    end}):AddKeyPicker('thirdperson_bind', {Default = 'None', SyncToggleState = false, Mode = 'Toggle', Text = 'Third Person', NoUI = false, Callback = function()
        if not thirdperson_active() then
            LocalPlayer.CameraMaxZoomDistance = cheat.original_state.CameraMaxZoomDistance or 128
            LocalPlayer.CameraMinZoomDistance = cheat.original_state.CameraMinZoomDistance or 0.5
            LocalPlayer.CameraMode = cheat.original_state.CameraMode or Enum.CameraMode.Classic
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            thirdperson_locked_mouse = false
        end
    end})
    world_thirdperson_tab:AddSlider('thirdperson_distance', {Text = 'Third Person Distance', Default = 10, Min = 1, Max = 50, Rounding = 1, Callback = function(state)
        tp_dist = state
    end})
    mvb:AddToggle('jesus_walk_water', {Text = 'Walk on Water (Jesus)', Default = false, Callback = function(first)
        jesus_enabled = first
    end})
    cheat.utility.new_renderstepped(LPH_NO_VIRTUALIZE(function(delta)
        local character = LocalPlayer.Character
        local humanoid = character and _FindFirstChildOfClass(character, "Humanoid")
        local hrp = character and _FindFirstChild(character, "HumanoidRootPart")
        if humanoid then
            if feature_active(speed_enabled, 'speedhack_bind') then
                humanoid.WalkSpeed = speed
            elseif omni_sprint and humanoid.MoveDirection.Magnitude > 0 then
                local playergui = LocalPlayer.PlayerGui
                if playergui and playergui:FindFirstChild("MainGui") then
                    humanoid.WalkSpeed = 18
                end
            end
        end
        local thirdperson_is_active = thirdperson_active()
        if thirdperson_is_active then
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            LocalPlayer.CameraMaxZoomDistance = tp_dist
            LocalPlayer.CameraMinZoomDistance = tp_dist
            Camera.CameraType = Enum.CameraType.Custom
            if humanoid then
                Camera.CameraSubject = humanoid
            end
            if not cheat.Library.Opened then
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                thirdperson_locked_mouse = true
                if hrp then
                    local look = Camera.CFrame.LookVector
                    hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + _Vector3new(look.X, 0, look.Z))
                end
            end
        elseif thirdperson_was_active then
            LocalPlayer.CameraMaxZoomDistance = cheat.original_state.CameraMaxZoomDistance or 128
            LocalPlayer.CameraMinZoomDistance = cheat.original_state.CameraMinZoomDistance or 0.5
            LocalPlayer.CameraMode = cheat.original_state.CameraMode or Enum.CameraMode.Classic
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            thirdperson_locked_mouse = false
        end
        thirdperson_was_active = thirdperson_is_active
        
        -- Walk on water / Jesus logic
        if jesus_enabled and hrp then
            local RAY = Ray.new(hrp.Position, Vector3.new(0, -10, 0))
            local _, Position, _, Material = workspace:FindPartOnRayWithWhitelist(RAY, { workspace.Terrain })

            if Material and Material == Enum.Material.Water then
                if not water_part then
                    local parent = workspace:FindFirstChild("NoCollision") or workspace
                    water_part = Instance.new("Part", parent)
                    water_part.Transparency = 1
                    water_part.Size = Vector3.new(10, 1, 10)
                    water_part.CanCollide = true
                    water_part.Anchored = true
                else
                    water_part.Position = Position
                end
            else
                if water_part then
                    water_part:Destroy()
                    water_part = nil
                end
            end
        else
            if water_part then
                water_part:Destroy()
                water_part = nil
            end
        end
    end))
    local misctab = ui.box.misc:AddTab('Misc')
    misctab:AddToggle('silentaim_indicator', {Text = 'Target Info Panel',Default = false,Callback = function(first)
        silent_aim.indicator = first
    end}):AddColorPicker('tipanel_bgcolor', {Default = tipanel_settings.bgcolor,Title = 'Panel BG Color',Transparency = 0.1,Callback = function(Value)
        tipanel_settings.bgcolor = Value
    end}):AddColorPicker('tipanel_bordercolor', {Default = tipanel_settings.bordercolor,Title = 'Panel Border Color',Callback = function(Value)
        tipanel_settings.bordercolor = Value
    end}):AddColorPicker('tipanel_accentcolor', {Default = tipanel_settings.accentcolor,Title = 'Panel Accent Color',Callback = function(Value)
        tipanel_settings.accentcolor = Value
    end}):AddColorPicker('tipanel_glowcolor', {Default = tipanel_settings.glowcolor,Title = 'Panel Glow Color',Callback = function(Value)
        tipanel_settings.glowcolor = Value
    end})
    misctab:AddSlider('tipanel_transparency', { Text = 'Panel Transparency', Default = 90, Min = 1, Max = 100, Rounding = 0, Suffix = "%", Compact = true, Callback = function(v)
        tipanel_settings.bgtrans = v / 100
    end})
    misctab:AddToggle('silentaim_targetline', {Text = 'Target Line',Default = false,Callback = function(first)
        silent_aim.target_line = first
    end})
    misctab:AddSlider('tipanel_x', { Text = 'Panel X', Default = 20, Min = 1, Max = 2000, Rounding = 0, Compact = true, Callback = function(v)
        silent_aim.tipanel_x = v
    end})
    misctab:AddSlider('tipanel_y', { Text = 'Panel Y', Default = 350, Min = 1, Max = 1200, Rounding = 0, Compact = true, Callback = function(v)
        silent_aim.tipanel_y = v
    end})
    misctab:AddButton('Reset Panel Position', function()
        silent_aim.tipanel_x = 20
        silent_aim.tipanel_y = 350
        if cheat.Options.tipanel_x then cheat.Options.tipanel_x:SetValue(20) end
        if cheat.Options.tipanel_y then cheat.Options.tipanel_y:SetValue(350) end
    end)
    local hit_sounds = {
        ["never lose"] = "rbxassetid://6607204501",
        ["rust"] = "rbxassetid://4764109000",
        ["gamesense"] = "rbxassetid://4817809188",
        ["fatalety"] = "rbxassetid://94204395881101",
        ["fahhhh"] = "rbxassetid://134512042804789",
        ["csgo kill"] = "rbxassetid://7269900245",
        ["csgo headshot"] = "rbxassetid://6937353691",
        ["minecraft bow"] = "rbxassetid://1053296915",
        ["fortnite headshot"] = "rbxassetid://2513174484",
        ["arsenal headshot"] = "rbxassetid://8522515167",
        ["fallen headshot"] = "rbxassetid://988593556",
        ["mogged"] = "rbxassetid://130607335183129",
        ["moan"] = "rbxassetid://7606020137",
        ["mommy asmr"] = "rbxassetid://111500468013640"
    }
    local custom_hitsound_enabled = false
    local custom_hitsound_id = "rbxassetid://6607204501"
    local custom_hitsound_volume = 1

    custom_sound_tab:AddToggle('custom_hitsound_enable', {Text = 'Custom Hit Sound', Default = false, Callback = function(c)
        custom_hitsound_enabled = c
    end})
    custom_sound_tab:AddDropdown('custom_hitsound_select', {Text = 'Hit Sound', Default = 1, Values = {'never lose', 'rust', 'gamesense', 'fatalety', 'fahhhh', 'csgo kill', 'csgo headshot', 'minecraft bow', 'fortnite headshot', 'arsenal headshot', 'fallen headshot', 'mogged', 'moan', 'mommy asmr'}, Callback = function(v)
        custom_hitsound_id = hit_sounds[v]
    end})
    custom_sound_tab:AddSlider('custom_hitsound_vol', {Text = 'Hit Sound Volume', Default = 100, Min = 1, Max = 500, Rounding = 0, Callback = function(v)
        custom_hitsound_volume = v / 100
    end})
    custom_sound_tab:AddButton('Test Hit Sound', function()
        local sound = Instance.new("Sound")
        sound.SoundId = custom_hitsound_id
        sound.Volume = custom_hitsound_volume
        if custom_hitsound_id == "rbxassetid://7606020137" then
            sound.TimePosition = 2
            task.delay(0.9, function() if sound and sound.Parent then sound:Stop() end end)
        end
        sound.Parent = game:GetService("SoundService")
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 5)
    end)
    
    local custom_gunsound_enabled = false
    local custom_gunsound_id = "rbxassetid://3060494212"
    local custom_gunsound_volume = 1
    
    local gun_sounds = {
        ["minecraft bow"] = "rbxassetid://3442683707",
        ["oof"] = "rbxassetid://3060494212",
        ["fart"] = "rbxassetid://3068648094",
        ["hee hee"] = "rbxassetid://3048623108",
        ["this is sparta"] = "rbxassetid://130781067",
        ["godzilla"] = "rbxassetid://130783046",
        ["roger that"] = "rbxassetid://135308704",
        ["fallen pkm"] = "rbxassetid://4803858563"
    }

    custom_sound_tab:AddToggle('custom_gunsound_enable', {Text = 'Custom Gun Sound', Default = false, Callback = function(c)
        custom_gunsound_enabled = c
    end})
    custom_sound_tab:AddDropdown('custom_gunsound_select', {Text = 'Gun Sound', Default = 1, Values = {'minecraft bow', 'oof', 'fart', 'hee hee', 'this is sparta', 'godzilla', 'roger that', 'fallen pkm'}, Callback = function(v)
        custom_gunsound_id = gun_sounds[v]
    end})
    custom_sound_tab:AddSlider('custom_gunsound_vol', {Text = 'Gun Sound Volume', Default = 100, Min = 1, Max = 500, Rounding = 0, Callback = function(v)
        custom_gunsound_volume = v / 100
    end})
    custom_sound_tab:AddButton('Test Gun Sound', function()
        local sound = Instance.new("Sound")
        sound.SoundId = custom_gunsound_id
        sound.Volume = custom_gunsound_volume
        if custom_gunsound_id == "rbxassetid://7606020137" then
            sound.TimePosition = 2
            task.delay(0.9, function() if sound and sound.Parent then sound:Stop() end end)
        end
        sound.Parent = game:GetService("SoundService")
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 5)
    end)

    local gun_sounds_volume = 100
    local hitmarker_sounds_volume = 100

    local gun_sound_names = {
        ["FireSound"] = true,
        ["FireFarSound"] = true,
        ["FireSoundSupressed"] = true,
    }

    local function sound_features_active()
        return custom_hitsound_enabled
            or custom_gunsound_enabled
            or cheat.hitlogs_enabled
            or gun_sounds_volume < 100
            or hitmarker_sounds_volume < 100
    end

    -- the 4 impact sounds we intercept for custom hitsound
    local hitsound_ids = {
        ["rbxassetid://4585382589"] = true,
        ["rbxassetid://4585351098"] = true,
        ["rbxassetid://4585382046"] = true,
        ["rbxassetid://4585364605"] = true,
    }

    -- all hitmarker sounds (for the volume slider)
    local hitmarker_sound_ids = {
        ["rbxassetid://4585382589"] = true,
        ["rbxassetid://4585351098"] = true,
        ["rbxassetid://4585382046"] = true,
        ["rbxassetid://4585364605"] = true,
        ["rbxassetid://9120454415"] = true,
        ["rbxassetid://4504226333"] = true,
        ["rbxassetid://6668102812"] = true,
        ["rbxassetid://9119166195"] = true,
        ["rbxassetid://4581728529"] = true,
    }

    local function check_sound_volume(sound)
        if not sound_features_active() then return end
        if not sound:IsA("Sound") then return end
        local soundid = sound.SoundId
        local is_impact = hitsound_ids[soundid]
        local is_hit = hitmarker_sound_ids[soundid]
        local is_gun = gun_sound_names[sound.Name]
        
        if is_hit then
            cheat.utility.last_hitmarker_tick = tick()
            if not is_impact and cheat.hitlogs_enabled and #cheat.hitlogs.pending > 0 then
                local valid_shot = table.remove(cheat.hitlogs.pending, 1)
                local str = string.format("%s hit %s on %dm", valid_shot.name, valid_shot.part, valid_shot.dist)
                
                local bg = cheat.utility.new_drawing("Square", {
                    Size = _Vector2new(0, 0), Position = _Vector2new(-300, cheat.hitlogs_y),
                    Color = Color3.fromRGB(20, 20, 20), Filled = true, Transparency = 1,
                    Visible = true, ZIndex = 98
                })
                local line = cheat.utility.new_drawing("Square", {
                    Size = _Vector2new(3, 0), Position = _Vector2new(-300, cheat.hitlogs_y),
                    Color = cheat.hitlogs_valid_color, Filled = true, Transparency = 1,
                    Visible = true, ZIndex = 99
                })
                local text = cheat.utility.new_drawing("Text", {
                    Text = str, Size = cheat.hitlogs_size, Font = cheat.hitlogs_font,
                    Center = false, Outline = true, Color = Color3.new(1, 1, 1),
                    Position = _Vector2new(-300, cheat.hitlogs_y), Visible = true, ZIndex = 100
                })
                table.insert(cheat.hitlogs.active, 1, {
                    drawing = text, bg = bg, line = line, str = str, spawn_tick = os.clock(),
                    target_y = cheat.hitlogs_y, current_x = -300
                })
            end
        end

        -- If custom hitsound intercepts it, we do NOT want this volume scaler touching it.
        if custom_hitsound_enabled and is_impact then
            return -- Ignore impact sounds from the volume scaler if custom hitsound is taking them over
        end
        
        -- If custom gunsound intercepts it, we do NOT want this volume scaler touching it.
        if custom_gunsound_enabled and is_gun then
            sound.SoundId = custom_gunsound_id
            sound.Volume = custom_gunsound_volume
            if custom_gunsound_id == "rbxassetid://7606020137" then
                sound.TimePosition = 2
                task.delay(0.9, function() if sound and sound.Parent then sound:Stop() end end)
            end
            return
        end

        -- volume scaling for gun and hitmarker sounds
        if is_hit or is_gun then
            if not sound:GetAttribute("OriginalVolume") then
                sound:SetAttribute("OriginalVolume", sound.Volume)
            end
            local vol = is_hit and hitmarker_sounds_volume or gun_sounds_volume
            sound.Volume = sound:GetAttribute("OriginalVolume") * (vol / 100)
            cheat.utility.track_connection(sound:GetPropertyChangedSignal("Volume"):Connect(function()
                local orig_vol = sound:GetAttribute("OriginalVolume")
                if not orig_vol then return end
                
                local new_vol = sound.Volume
                local current_target_vol = is_hit and hitmarker_sounds_volume or gun_sounds_volume
                local expected_vol = orig_vol * (current_target_vol / 100)
                if math.abs(new_vol - expected_vol) > 0.01 then
                    sound:SetAttribute("OriginalVolume", new_vol)
                    sound.Volume = new_vol * (current_target_vol / 100)
                end
            end))
        end
    end

    cheat.utility.track_connection(game.DescendantAdded:Connect(function(child)
        if sound_features_active() then
            check_sound_volume(child)
        end
    end))

    custom_sound_tab:AddSlider('gun_sounds_volume', {Text = 'Gun Sounds Volume', Default = 100, Min = 1, Max = 100, Rounding = 0, Callback = function(v)
        gun_sounds_volume = v
        if v < 100 then
            for _, child in ipairs(game:GetDescendants()) do
                if child:IsA("Sound") and gun_sound_names[child.Name] then
                    check_sound_volume(child)
                end
            end
        end
    end})
    custom_sound_tab:AddSlider('hitmarker_sounds_volume', {Text = 'Hitmarker Sounds Volume', Default = 100, Min = 1, Max = 100, Rounding = 0, Callback = function(v)
        hitmarker_sounds_volume = v
    end})
    
    local skins_tab = settings_skinchanger_box
    local skinchanger_enabled = false
    local unlock_all_skins_enabled = false
    skins_tab:AddToggle('skinchanger_enabled', { Text = 'Skin Changer', Default = false, Callback = function(v)
        skinchanger_enabled = v
    end})
    skins_tab:AddToggle('unlock_all_skins', { Text = 'Unlock All Skins (Client)', Default = false, Callback = function(v)
        unlock_all_skins_enabled = v
    end})
    
    task.spawn(function()
        pcall(function()
            local fl = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("FunctionLibraryExtension"))
            if fl and fl.UpdateSkin then
                local old_UpdateSkin = fl.UpdateSkin
                fl.UpdateSkin = function(self, p140, p141, p142)
                    if p140 and typeof(p140) == "Instance" and p140:IsA("ObjectValue") then
                        local forced = p140:GetAttribute("Skin")
                        if forced ~= nil then
                            p142 = (forced == "" and nil or forced)
                        end
                    end
                    return old_UpdateSkin(self, p140, p141, p142)
                end
                
                if fl.FindDeepAncestor then
                    fl.FindDeepAncestor = function(self, p92, p93, p94)
                        local v95 = 0
                        if not p92 or typeof(p92) ~= "Instance" then return p92 end
                        while p92 and p92.Parent and p92.Parent.ClassName == p93 do
                            if p92.Parent.Parent and p92.Parent.Parent.Parent and p92.Parent.Parent.Parent.Name == "Attachments" then
                                p92 = p92.Parent.Parent.Parent
                            else
                                p92 = p92.Parent
                            end
                            v95 = v95 + 1
                            if p94 and typeof(p94) == "table" and p94.SearchForInteraction then
                                if p92:GetAttribute(p94.SearchForInteraction) then break end
                            end
                            if v95 > 10 or p92:FindFirstChild("DeepAncestorBreak") or p92:FindFirstChild("Moving") then
                                break
                            end
                        end
                        return p92
                    end
                end
            end
        end)
    end)
    
    task.spawn(function()
        local rep = ReplicatedStorage
        while task.wait(2) do
            if skinchanger_enabled or unlock_all_skins_enabled then
                pcall(function()
                    local p_purchases = rep:FindFirstChild("Players") and rep.Players:FindFirstChild(LocalPlayer.Name) and rep.Players[LocalPlayer.Name]:FindFirstChild("Status") and rep.Players[LocalPlayer.Name].Status:FindFirstChild("Purchases")
                    if p_purchases then
                        if not p_purchases:FindFirstChild("Skins") then
                            local s = Instance.new("Folder")
                            s.Name = "Skins"
                            s.Parent = p_purchases
                        end
                        local p_skins = p_purchases.Skins

                        local function unlock_from(folder_name)
                            local f = rep:FindFirstChild(folder_name)
                            if f then
                                for _, weapon_skins in pairs(f:GetChildren()) do
                                    local p_weapon = p_skins:FindFirstChild(weapon_skins.Name)
                                    if not p_weapon then
                                        p_weapon = Instance.new("Folder")
                                        p_weapon.Name = weapon_skins.Name
                                        p_weapon.Parent = p_skins
                                    end
                                    for _, skin in pairs(weapon_skins:GetChildren()) do
                                        if not p_weapon:FindFirstChild(skin.Name) then
                                            local mock = Instance.new("Folder")
                                            mock.Name = skin.Name
                                            mock.Parent = p_weapon
                                        end
                                    end
                                end
                            end
                        end
                        unlock_from("skins")
                        unlock_from("skin packs")
                        unlock_from("Skin Packs")
                        unlock_from("Skins")
                    end
                end)
            end
        end
    end)
    
    task.spawn(function()
        local rep = ReplicatedStorage
        while task.wait(0.1) do
            pcall(function()
                if not skinchanger_enabled then
                    task.wait(0.4)
                    return
                end

                local weapon_name = get_local_weapon()
                if not weapon_name or weapon_name == "None" then
                    return
                end

                local p_inv = rep:FindFirstChild("Players") and rep.Players:FindFirstChild(LocalPlayer.Name) and rep.Players[LocalPlayer.Name]:FindFirstChild("Inventory")
                if not p_inv then return end

                local target_item
                for _, item in ipairs(p_inv:GetChildren()) do
                    if item:IsA("ObjectValue") and item.Value and item.Value.Name == weapon_name then
                        target_item = item
                        break
                    end
                end
                if not target_item then return end

                local forced_skin = target_item:GetAttribute("SpoofedSkin")
                if forced_skin == nil then
                    if target_item:GetAttribute("Skin") ~= nil then
                        target_item:SetAttribute("Skin", nil)
                    end
                    return
                end

                local target_skin = (forced_skin == "" and nil or forced_skin)
                if target_item:GetAttribute("Skin") ~= target_skin then
                    target_item:SetAttribute("Skin", target_skin)
                end

                if target_skin then
                    local fl = require(rep:WaitForChild("Modules"):WaitForChild("FunctionLibraryExtension"))
                    local function paint_model(parent)
                        if not parent then return end
                        local w_model = parent:FindFirstChild(weapon_name)
                        if w_model and w_model:IsA("Model") and w_model:GetAttribute("SpoofSkinApplied") ~= target_skin then
                            pcall(function()
                                fl:UpdateSkin(target_item, w_model, target_skin)
                                w_model:SetAttribute("SpoofSkinApplied", target_skin)
                            end)
                        end
                    end

                    paint_model(LocalPlayer.Character)
                    local cam = workspace.CurrentCamera
                    if cam then
                        for _, child in ipairs(cam:GetChildren()) do
                            if child:GetAttribute("Temp") or child.Name == LocalPlayer.Name then
                                paint_model(child)
                            end
                        end
                    end
                end
            end)
        end
    end)
    local player_gui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
    cheat.utility.track_connection(player_gui.ChildAdded:Connect(function(child)
        if child.Name == "MainGui" then
            cheat.utility.track_connection(child.ChildAdded:Connect(function(sound)
                if sound:IsA("Sound") and custom_hitsound_enabled then
                    if sound.SoundId == "rbxassetid://4585382589" or sound.SoundId == "rbxassetid://4585351098" or sound.SoundId == "rbxassetid://4585382046" or sound.SoundId == "rbxassetid://4585364605" then
                        sound.SoundId = custom_hitsound_id
                        sound.Volume = custom_hitsound_volume
                        if custom_hitsound_id == "rbxassetid://7606020137" then
                            sound.TimePosition = 2
                            task.delay(0.9, function() if sound and sound.Parent then sound:Stop() end end)
                        end
                    end
                end
            end))
        end
    end))

    local main_gui = player_gui:FindFirstChild("MainGui")
    if main_gui then
        cheat.utility.track_connection(main_gui.ChildAdded:Connect(function(sound)
            if sound:IsA("Sound") and custom_hitsound_enabled then
                if sound.SoundId == "rbxassetid://4585382589" or sound.SoundId == "rbxassetid://4585351098" or sound.SoundId == "rbxassetid://4585382046" or sound.SoundId == "rbxassetid://4585364605" then
                    sound.SoundId = custom_hitsound_id
                    sound.Volume = custom_hitsound_volume
                    if custom_hitsound_id == "rbxassetid://7606020137" then
                        sound.TimePosition = 2
                        task.delay(0.9, function() if sound and sound.Parent then sound:Stop() end end)
                    end
                end
            end
        end))
    end
end
do
    local fmvb = ui.box.move:AddTab('Flyhack')
    local fly_enabled, fly_speed, fly_yspeed = false, 10, 10
    fmvb:AddToggle('flyhack_enabled', {Text = 'Flyhack',Default = false,Callback = function(first)
        fly_enabled = first
    end}):AddKeyPicker('flyhack_bind', {Default = 'None',SyncToggleState = true,Mode = 'Toggle',Text = 'Flyhack',NoUI = false})
    fmvb:AddSlider('flyhack_speed',{ Text = 'Fly Speed', Default = 10, Min = 1, Max = 50, Rounding = 0, Suffix = "sps", Compact = false }):OnChanged(function(State)
        fly_speed = State
    end)
    fmvb:AddSlider('flyhack_y_speed',{ Text = 'Vertical Speed', Default = 10, Min = 1, Max = 50, Rounding = 0, Suffix = "sps", Compact = false }):OnChanged(function(State)
        fly_yspeed = State
    end)
    cheat.utility.new_heartbeat(LPH_JIT_MAX(function(delta)
        local character = LocalPlayer.Character
        local hrp = character and _FindFirstChild(character, "HumanoidRootPart")
        if feature_active(fly_enabled, 'flyhack_bind') and hrp then
            local cameralook = Camera.CFrame.LookVector
            cameralook = _Vector3new(cameralook.X, 0, cameralook.Z)
            local direction = Vector3.zero
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.W) and direction + cameralook or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.S) and direction - cameralook or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.D) and direction + _Vector3new(- cameralook.Z, 0, cameralook.X) or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.A) and direction + _Vector3new(cameralook.Z, 0, - cameralook.X) or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.Space) and direction + Vector3.yAxis or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.LeftControl) and direction - Vector3.yAxis or direction;
            if direction ~= Vector3.zero then
                direction = direction.Unit
            end
            local current_cf = hrp.CFrame
            if cheat.real_CFrame then current_cf = cheat.real_CFrame end
            local new_cf = current_cf + _Vector3new(1, 0, 1) * (direction * delta * fly_speed) + Vector3.yAxis * (direction * delta * fly_yspeed)
            hrp.CFrame = new_cf
            if cheat.real_CFrame then cheat.real_CFrame = new_cf end
            for _, part in character:GetDescendants() do
                if part:IsA("BasePart") then part.AssemblyLinearVelocity = Vector3.zero end
            end
        end
    end))
end
do
    cheat.utility.new_heartbeat(LPH_JIT_MAX(function(delta)
        local character = LocalPlayer.Character
        local hrp = character and _FindFirstChild(character, "HumanoidRootPart")
        if enabled and hrp then
            local cameralook = Camera.CFrame.LookVector
            cameralook = _Vector3new(cameralook.X, 0, cameralook.Z)
            local direction = Vector3.zero
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.W) and direction + cameralook or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.S) and direction - cameralook or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.D) and direction + _Vector3new(- cameralook.Z, 0, cameralook.X) or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.A) and direction + _Vector3new(cameralook.Z, 0, - cameralook.X) or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.Space) and direction + Vector3.yAxis or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.LeftControl) and direction - Vector3.yAxis or direction;
            if direction ~= Vector3.zero then
                direction = direction.Unit
            end
            local current_cf = hrp.CFrame
            if cheat.real_CFrame then current_cf = cheat.real_CFrame end
            local new_cf = current_cf + _Vector3new(1, 0, 1) * (direction * delta * speed) + Vector3.yAxis * (direction * delta * yspeed)
            hrp.CFrame = new_cf
            if cheat.real_CFrame then cheat.real_CFrame = new_cf end
            for _, part in character:GetDescendants() do
                if part:IsA("BasePart") then part.AssemblyLinearVelocity = Vector3.zero end
            end
        end
    end))
end

do
    local game_TweenService = game:GetService("TweenService")
    local _firing_rapidly = false
    cheat.is_dead_or_respawning = false
    cheat.last_fly_or_tp_time = 0
    cheat.is_flying_or_tp = function()
        if not cheat.Toggles then return false end
        local tp_active = cheat.Toggles.tpkill_enabled and feature_active(cheat.Toggles.tpkill_enabled.Value, 'tpkill_key')
        local fly_active = cheat.Toggles.flyhack_enabled and feature_active(cheat.Toggles.flyhack_enabled.Value, 'flyhack_bind')
        if tp_active or fly_active then
            cheat.last_fly_or_tp_time = tick()
            cheat.real_CFrame = nil
            return true
        elseif cheat.last_fly_or_tp_time > 0 and (tick() - cheat.last_fly_or_tp_time < 1.2) then
            cheat.real_CFrame = nil
            return true
        end
        return false
    end
    
    local __index; __index = hookmetamethod(game, "__index", newcclosure(LPH_NO_VIRTUALIZE(function(self, k)
        if checkcaller() then return __index(self, k) end
        
        if k == "Trail" and typeof(self) == "Instance" and self.Name == "VisualTracer" then
            local real_trail = self:FindFirstChild("Trail")
            if real_trail then return real_trail end
            return Instance.new("Trail")
        end
        
        if k == "Handle" and typeof(self) == "Instance" and self:IsA("Accessory") then
            local handle = self:FindFirstChild("Handle")
            if handle then return handle end
            local dummy = Instance.new("Part")
            dummy.Name = "Handle"
            dummy.Transparency = 1
            return dummy
        end
        
        if (k == "CFrame" or k == "Position") and cheat.desync_active and cheat.real_CFrame and not cheat.is_dead_or_respawning and not cheat.is_flying_or_tp() then
            local char = LocalPlayer.Character
            if char and typeof(self) == "Instance" and self == char:FindFirstChild("HumanoidRootPart") then
                if k == "CFrame" then return cheat.real_CFrame end
                if k == "Position" then return cheat.real_CFrame.Position end
            end
        end
        return __index(self, k)
    end)))
    local __newindex; __newindex = hookmetamethod(game, "__newindex", newcclosure(LPH_NO_VIRTUALIZE(function(self, k, v)
        if checkcaller() then return __newindex(self, k, v) end
        if self == Lighting then
            if k == "ClockTime" and globals.EnableTime then return end
            if k == "GlobalShadows" and globals.noshadows then return end
            if k == "Ambient" and globals.gradientenabled then return end
            if k == "OutdoorAmbient" and globals.gradientenabled then return end
            if k == "ExposureCompensation" or k == "Brightness" then return end
        end
        if self == Camera then
            if k == "FieldOfView" and (globals.fov_enabled or globals.zoom_enabled) then
                return
            end
        end
        return __newindex(self, k, v)
    end)))
    local __namecall; __namecall = hookmetamethod(game, "__namecall", newcclosure(LPH_NO_VIRTUALIZE(function(self,...)
        if checkcaller() then return __namecall(self, ...) end
        local method = getnamecallmethod()
        if method == "Raycast" then
            if not (cheat.freecam_enabled or (silent_aim and silent_aim.target_part and silent_aim_active())) then
                return __namecall(self, ...)
            end
        elseif method == "GetAttribute" then
            if not (silent_aim and (silent_aim.nospread or silent_aim_active())) then
                return __namecall(self, ...)
            end
        elseif method == "Play" then
            if not ((cheat._gun_sounds_volume and cheat._gun_sounds_volume() < 100) or (cheat._hitmarker_sounds_volume and cheat._hitmarker_sounds_volume() < 100)) then
                return __namecall(self, ...)
            end
        elseif method == "InvokeServer" or method == "invokeServer" or method == "FireServer" or method == "fireServer" then
            if not cheat.utility.fast_namecall_needed() and not skinchanger_enabled then
                return __namecall(self, ...)
            end
        elseif method == "Create" then
            if not (self == game_TweenService and (globals.fov_enabled or globals.zoom_enabled)) then
                return __namecall(self, ...)
            end
        else
            return __namecall(self, ...)
        end

        local args = {...}
        local argCount = select("#", ...)
        local methodstr = tostring(method)

        if methodstr == "InvokeServer" or methodstr == "invokeServer" or methodstr == "FireServer" or methodstr == "fireServer" then
            local success, rname = pcall(function() return self.Name end)
            if success and rname == "ChangeSkin" then
                local weaponObj = args[1]
                local skinName = args[2]
                if weaponObj then
                    if tostring(skinName) == "Default" then
                        pcall(function() weaponObj:SetAttribute("SpoofedSkin", "") end)
                    else
                        pcall(function() weaponObj:SetAttribute("SpoofedSkin", tostring(skinName)) end)
                    end
                    return true
                end
            end
            if success and rname == "ProjectileInflict" then
                if cheat.hitlogs_enabled and args[1] and typeof(args[1]) == "Instance" then
                    local target_part = args[1]
                    local target_char = target_part.Parent
                    local target_name = target_char and target_char.Name or "Unknown"
                    local hum = target_char and target_char:FindFirstChild("Humanoid")
                    if target_name ~= "Unknown" and hum and Camera then
                        local dist = math.floor((target_part.Position - Camera.CFrame.p).Magnitude / 2.8) -- roughly studs to meters
                        table.insert(cheat.hitlogs.pending, {
                            name = target_name,
                            part = target_part.Name,
                            dist = dist,
                            tick = os.clock()
                        })
                    end
                end
            end
        end
        if self == game_TweenService and method == "Create" and args[1] == Camera and rawget(args[3], "FieldOfView") and (globals.fov_enabled or globals.zoom_enabled) then
            args[3] = {}
            setnamecallmethod(methodstr)
            return __namecall(self, unpack(args, 1, argCount))
        end
        if method == "Play" and typeof(self) == "Instance" and self.ClassName == "Sound" then
            local sname = self.Name
            local gun_vol = cheat._gun_sounds_volume and cheat._gun_sounds_volume() or 100
            if gun_vol < 100 then
                if sname == "FireSound" or sname == "FireFarSound" or sname == "FireSoundSupressed" then
                    if gun_vol == 0 then return end
                    if not self:GetAttribute("OriginalVolume") then
                        self:SetAttribute("OriginalVolume", self.Volume)
                    end
                    self.Volume = self:GetAttribute("OriginalVolume") * (gun_vol / 100)
                end
            end
            local hit_vol = cheat._hitmarker_sounds_volume and cheat._hitmarker_sounds_volume() or 100
            if hit_vol < 100 then
                if sname == "Helmet" or sname == "BodyArmor" or sname == "Bodyshot" or sname == "Headshot" or sname == "Kill" or sname == "BarbedWire" or sname == "Vehicle" or sname == "Burn" or self.SoundId == "rbxassetid://4581728529" then
                    if hit_vol == 0 then return end
                    if not self:GetAttribute("OriginalVolume") then
                        self:SetAttribute("OriginalVolume", self.Volume)
                    end
                    self.Volume = self:GetAttribute("OriginalVolume") * (hit_vol / 100)
                end
            end
        end
        if method == "GetAttribute" then
            local attribute = args[1]
            if silent_aim.nospread and attribute == "AccuracyDeviation" then
                return 0
            end
            if silent_aim_active() then
                if attribute == "ProjectileDrop" then
                    return 0
                end
                if attribute == "Drag" then
                    return 0
                end
            end
        end
        if method == "InvokeServer" and self.Name == "FireProjectile" then
            if silent_aim then silent_aim._exact_fire_tick = tick() end
            local is_empty = false
            local weapon_name = get_local_weapon and get_local_weapon() or "None"
            if weapon_name ~= "None" then
                local rpplrs = ReplicatedStorage:FindFirstChild("Players")
                local rpinv = rpplrs and rpplrs:FindFirstChild(LocalPlayer.Name) and rpplrs[LocalPlayer.Name]:FindFirstChild("Inventory")
                local inv_weapon = rpinv and rpinv:FindFirstChild(weapon_name)
                if inv_weapon and inv_weapon:FindFirstChild("SettingsModule") then
                    local magazine = _FindFirstChild(inv_weapon, "Attachments") and _FindFirstChild(inv_weapon.Attachments, "Magazine") and inv_weapon.Attachments.Magazine:FindFirstChildOfClass("StringValue")
                    local loadedammo = magazine and magazine:FindFirstChild("ItemProperties") and magazine.ItemProperties:FindFirstChild("LoadedAmmo")
                    local ammo_count = 0
                    if loadedammo then
                        if loadedammo:IsA("Folder") then
                            ammo_count = #loadedammo:GetChildren()
                        else
                            ammo_count = loadedammo:GetAttribute("LoadedAmmo") or loadedammo:GetAttribute("Ammo") or 0
                        end
                    end
                    if not magazine or ammo_count <= 0 then
                        is_empty = true
                    end
                end
            end
            if is_empty then
                return
            end
            
            local real_orig = Camera.CFrame.p
            local origin_spoofed = false
            
            if silent_aim.corner_shoot and silent_aim.manipulated_origin then
                real_orig = silent_aim.manipulated_origin
                origin_spoofed = true
            elseif cheat.freecam_enabled then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Head") then
                    real_orig = char.Head.Position
                    origin_spoofed = true
                end
            end
            
            if origin_spoofed and silent_aim_active() and silent_aim.target_part then
                args[1] = (silent_aim.target_part.Position - real_orig).Unit
            elseif origin_spoofed and cheat.freecam_enabled then
                local hit_pos = Mouse.Hit.Position
                args[1] = (hit_pos - real_orig).Unit
            end
            
            if not _firing_rapidly and silent_aim_active() and silent_aim.instant and silent_aim.target_part then
                local dist = (silent_aim.target_part.Position - real_orig).Magnitude
                args[3] = tick() - (dist / 1000)
            end
            setnamecallmethod(methodstr)
            return __namecall(self, unpack(args, 1, argCount))
        end
        if method == "Raycast" then
            local origin = args[1]
            if typeof(origin) == "Vector3" then
                if cheat.freecam_enabled then
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("Head") then
                        origin = char.Head.Position
                        args[1] = origin
                    end
                end
                
                if silent_aim_active() and silent_aim.target_part then
                    local hitpart = silent_aim.target_part
                    if hitpart and hitpart.Parent then
                        if silent_aim.corner_shoot and silent_aim.manipulated_origin then
                            origin = silent_aim.manipulated_origin
                            args[1] = origin
                        end
                        
                        local direction = hitpart.Position - origin
                        args[2] = direction
                        return {
                            Instance = hitpart,
                            Position = hitpart.Position,
                            Normal = direction.Unit * -1,
                            Material = hitpart.Material,
                            Distance = direction.Magnitude
                        }
                    end
                end
            end
        end
        -- hit sound is handled via MainGui.ChildAdded, not here
        setnamecallmethod(methodstr)
        return __namecall(self, unpack(args, 1, argCount))
    end)))

end
-- Script controls are added in the Settings tab after the config/theme managers initialize.

-- ─── ANTI-AIM TAB ────────────────────────────────────────────────────────────
do
    local aa = player_anti_aim_tab

    local aa_enabled = false
    local aa_mode = "Reverse"
    local aa_yaw_offset = 0

    aa:AddToggle('aa_enabled', {Text = 'Anti Aim', Default = false, Callback = function(v)
        aa_enabled = v
        if not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.AutoRotate = true
            cheat.real_CFrame = nil
            cheat.desync_active = false
        end
    end}):AddKeyPicker('aa_bind', {Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'Anti Aim', NoUI = false})
    
    aa:AddDropdown('aa_mode', {Text = 'Anti Aim Mode', Default = 1, Values = {"Reverse", "Spin", "Random", "FlatRandom", "None"}, Callback = function(v)
        aa_mode = v
    end})

    aa:AddSlider('aa_yaw_offset', {Text = 'Yaw Offset', Default = 0, Min = -360, Max = 360, Rounding = 0, Callback = function(v)
        aa_yaw_offset = v
    end})

    local aa_pitch_value = 0
    aa:AddSlider('aa_pitch_value', {Text = 'Pitch Override', Default = 0, Min = -250, Max = 250, Rounding = 0, Callback = function(v)
        aa_pitch_value = v
    end})

    local fake_lag_enabled = false
    local fake_lag_interval = 0.4
    player_fake_lag_tab:AddToggle('fake_lag_enabled', {Text = 'Fake Lag Desync', Default = false, Callback = function(v)
        fake_lag_enabled = v
    end}):AddKeyPicker('fake_lag_bind', {Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'Fake Lag Desync', NoUI = false})
    player_fake_lag_tab:AddSlider('fake_lag_interval', {Text = 'Fake Lag Interval', Default = 0.4, Min = 0.1, Max = 0.7, Rounding = 1, Callback = function(v)
        fake_lag_interval = v
    end})
    
    local visualize_server_pos = false
    local visualize_color = Color3.fromRGB(255, 50, 50)
    player_fake_lag_tab:AddToggle('visualize_server_pos', {Text = 'Visualize Server Position', Default = false, Callback = function(v)
        visualize_server_pos = v
    end}):AddColorPicker('visualize_color', {Text = 'Visualizer Color', Default = Color3.fromRGB(255, 50, 50), Callback = function(v)
        visualize_color = v
    end})

    local visualize_transparency = 0
    player_fake_lag_tab:AddSlider('visualize_transparency', {Text = 'Visualizer Transparency', Default = 1, Min = 1, Max = 100, Rounding = 0, Callback = function(v)
        visualize_transparency = v / 100
    end})

    local aa_custom_offset = false
    player_fake_lag_tab:AddToggle('aa_custom_offset', {Text = 'Custom Position Offset', Default = false, Callback = function(v)
        aa_custom_offset = v
    end})
    
    local aa_custom_offset_radius = 5
    player_fake_lag_tab:AddSlider('aa_custom_offset_radius', {Text = 'Offset Radius', Default = 5, Min = 1, Max = 5, Rounding = 1, Callback = function(v)
        aa_custom_offset_radius = v
    end})

    -- UG Resolver (hold X)
    local ug_resolver_enabled = false
    local ug_resolver_holding = false
    local ug_resolver_depth = 30
    player_fake_lag_tab:AddToggle('ug_resolver', {Text = 'UG Resolver (Hold X)', Default = false, Callback = function(v)
        ug_resolver_enabled = v
        if not v then ug_resolver_holding = false end
    end})
    player_fake_lag_tab:AddSlider('ug_resolver_depth', {Text = 'UG Resolver Depth', Default = 30, Min = 5, Max = 100, Rounding = 0, Callback = function(v)
        ug_resolver_depth = v
    end})

    local function UGRESOLVER()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        -- Store the current velocity to prevent momentum building up (which triggers fall damage on return)
        local originalCF = hrp.CFrame
        local originalVel = hrp.AssemblyLinearVelocity
        
        hrp.CFrame = originalCF * CFrame.new(0, -ug_resolver_depth, 0)
        hrp.AssemblyLinearVelocity = Vector3.zero
        
        task.delay(0.10, function()
            if hrp and hrp.Parent then
                hrp.CFrame = originalCF
                -- Kill any downward velocity that built up while underground
                hrp.AssemblyLinearVelocity = Vector3.new(originalVel.X, 0, originalVel.Z)
            end
        end)
    end

    -- Desync State
    cheat.real_CFrame = nil
    local current_jitter_offset = Vector3.zero
    local target_jitter_offset = Vector3.zero
    local fake_lag_CFrame = nil
    local last_fake_lag_time = 0
    local server_pos_cham = nil
    cheat.desync_active = false

    local function restore_antiaim_rotation()
        cheat.desync_active = false
        cheat.real_CFrame = nil
        fake_lag_CFrame = nil

        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                hum.AutoRotate = true
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            end)
        end
    end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health <= 0 then
        cheat.is_dead_or_respawning = true
    end
    
    cheat.utility.track_connection(LocalPlayer.CharacterAdded:Connect(function()
        cheat.is_dead_or_respawning = true
        task.delay(0.5, function()
            cheat.is_dead_or_respawning = false
        end)
    end))

    -- Restore CFrame before physics so local client acts completely normal physically
    cheat.utility.track_connection(RunService.Stepped:Connect(function()
        local aa_active = feature_active(aa_enabled, 'aa_bind')
        local fake_lag_active = feature_active(fake_lag_enabled, 'fake_lag_bind')
        if (not aa_active and not fake_lag_active) or cheat.is_dead_or_respawning then
            restore_antiaim_rotation()
            return
        end
        if cheat.is_flying_or_tp() then
            restore_antiaim_rotation()
            return
        end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and cheat.real_CFrame then
            local linVel = hrp.AssemblyLinearVelocity
            local angVel = hrp.AssemblyAngularVelocity
            hrp.CFrame = cheat.real_CFrame
            hrp.AssemblyLinearVelocity = linVel
            hrp.AssemblyAngularVelocity = angVel
        end
    end))

    -- Restore CFrame before camera so no visual stutter
    RunService:BindToRenderStep("AADesyncRestore", 0, function()
        local aa_active = feature_active(aa_enabled, 'aa_bind')
        local fake_lag_active = feature_active(fake_lag_enabled, 'fake_lag_bind')
        if (not aa_active and not fake_lag_active) or cheat.is_dead_or_respawning then
            restore_antiaim_rotation()
            return
        end
        if cheat.is_flying_or_tp() then
            restore_antiaim_rotation()
            return
        end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and cheat.real_CFrame then
            local linVel = hrp.AssemblyLinearVelocity
            local angVel = hrp.AssemblyAngularVelocity
            hrp.CFrame = cheat.real_CFrame
            hrp.AssemblyLinearVelocity = linVel
            hrp.AssemblyAngularVelocity = angVel
        end
    end)

    -- Heartbeat: Anti-Aim (Look Direction Spoof)
    cheat.utility.new_heartbeat(function()
        local aa_active = feature_active(aa_enabled, 'aa_bind')
        local fake_lag_active = feature_active(fake_lag_enabled, 'fake_lag_bind')
        if (not aa_active and not fake_lag_active) or cheat.is_dead_or_respawning then
            restore_antiaim_rotation()
            return
        end
        if cheat.is_flying_or_tp() then
            restore_antiaim_rotation()
            return
        end
        cheat.desync_active = true

        local char = LocalPlayer.Character
        if not char then return end
        
        local hum = char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        if hum.Health <= 0 then
            cheat.is_dead_or_respawning = true
            fake_lag_CFrame = nil
            return
        end

        pcall(function()
            if aa_active then
                hum.AutoRotate = false
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            else
                hum.AutoRotate = true
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            end
            
            -- Save real CFrame so physics and camera act normal
            cheat.real_CFrame = hrp.CFrame
            
            -- Fake lag logic
            if fake_lag_active then
                if tick() - last_fake_lag_time >= fake_lag_interval then
                    last_fake_lag_time = tick()
                    fake_lag_CFrame = hrp.CFrame
                    
                    if visualize_server_pos then
                        task.spawn(function()
                            local oldArchivable = char.Archivable
                            char.Archivable = true
                            local ghost = char:Clone()
                            char.Archivable = oldArchivable
                            
                            if ghost then
                                ghost.Name = "FakeLagGhost_ESP_IGNORE"
                                for _, v in pairs(ghost:GetDescendants()) do
                                    if v:IsA("BasePart") then
                                        v.Material = Enum.Material.ForceField
                                        v.Color = visualize_color
                                        v.CanCollide = false
                                        v.CanTouch = false
                                        v.CanQuery = false
                                        v.Massless = true
                                        v.Anchored = true
                                        v.Transparency = visualize_transparency
                                    elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("Clothing") or v:IsA("Accessory") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("SurfaceAppearance") then
                                        v:Destroy()
                                    end
                                end
                                
                                local ghostHrp = ghost:FindFirstChild("HumanoidRootPart")
                                local humanoid = ghost:FindFirstChildOfClass("Humanoid")
                                if humanoid then
                                    humanoid:Destroy()
                                end
                                
                                ghost.Parent = workspace.Terrain
                                if ghostHrp then
                                    ghost:PivotTo(fake_lag_CFrame)
                                end
                                
                                local fadeTime = 0.5
                                local TweenService = game:GetService("TweenService")
                                local tweenInfo = TweenInfo.new(fadeTime, Enum.EasingStyle.Linear)
                                for _, v in pairs(ghost:GetDescendants()) do
                                    if v:IsA("BasePart") then
                                        local tween = TweenService:Create(v, tweenInfo, {Transparency = 1})
                                        tween:Play()
                                    end
                                end
                                
                                task.delay(fadeTime, function()
                                    if ghost then ghost:Destroy() end
                                end)
                            end
                        end)
                    end
                end
            else
                fake_lag_CFrame = nil
            end

            -- Base reverse calculation
            local Angle = -math.atan2(
                workspace.CurrentCamera.CFrame.LookVector.Z,
                workspace.CurrentCamera.CFrame.LookVector.X
            ) + math.rad(-90)
            
            if aa_mode == "Random" then
                Angle = -math.atan2(
                    workspace.CurrentCamera.CFrame.LookVector.Z,
                    workspace.CurrentCamera.CFrame.LookVector.X
                ) + math.rad(90) + math.rad(math.random(-120, 120))
            elseif aa_mode == "FlatRandom" then
                Angle = math.rad(math.random(0, 360))
            elseif aa_mode == "Spin" then
                Angle = -math.atan2(
                    workspace.CurrentCamera.CFrame.LookVector.Z,
                    workspace.CurrentCamera.CFrame.LookVector.X
                ) + tick() * 100 % 360
            elseif aa_mode == "Reverse" then
                Angle = -math.atan2(
                    workspace.CurrentCamera.CFrame.LookVector.Z,
                    workspace.CurrentCamera.CFrame.LookVector.X
                ) + math.rad(90) -- Look backward
            elseif aa_mode == "None" then
                Angle = -math.atan2(
                    workspace.CurrentCamera.CFrame.LookVector.Z,
                    workspace.CurrentCamera.CFrame.LookVector.X
                ) + math.rad(-90)
            end

            local Offset = math.rad(aa_yaw_offset)
            local Angled = CFrame.new(hrp.Position) * CFrame.Angles(0, Angle + Offset, 0)
            
            -- Target-based reverse if silent aim has a target
            if (aa_mode == "Reverse" or aa_mode == "Random") and silent_aim and silent_aim.target_part then
                local additional_offset = 0
                if aa_mode == "Random" then
                    additional_offset = math.rad(math.random(-120, 120))
                end
                Angled = CFrame.new(hrp.Position, silent_aim.target_part.Position) * CFrame.Angles(0, math.rad(180) + Offset + additional_offset, 0)
            end

            -- Position Jitter (Interpolated for anti-cheat bypass)
            local pos_offset = Vector3.new(0, 0.2, 0) -- 0.2 studs above ground
            if aa_custom_offset then
                local rx = (math.random() - 0.5) * 2
                local ry = (math.random() - 0.5) * 2
                local rz = (math.random() - 0.5) * 2
                local rand_dir = Vector3.new(rx, ry, rz)
                if rand_dir.Magnitude > 0 then
                    local dist = math.random() * aa_custom_offset_radius
                    local proposed_target = rand_dir.Unit * dist
                    
                    local rayParams = RaycastParams.new()
                    rayParams.FilterDescendantsInstances = {char, workspace.CurrentCamera}
                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                    rayParams.IgnoreWater = true
                    
                    local rayResult = workspace:Raycast(hrp.Position, proposed_target, rayParams)
                    if rayResult then
                        local safe_dist = math.max(0, (rayResult.Position - hrp.Position).Magnitude - 0.5)
                        pos_offset = pos_offset + (rand_dir.Unit * safe_dist)
                    else
                        pos_offset = pos_offset + proposed_target
                    end
                end
            end

            local recently_shot = silent_aim and silent_aim._exact_fire_tick and (tick() - silent_aim._exact_fire_tick < 0.05)

            -- Apply spoofed CFrame for network replication ONLY
            local spoof_pos
            if recently_shot and silent_aim and silent_aim.manipulated_origin then
                local manip_offset = silent_aim.manipulated_origin - workspace.CurrentCamera.CFrame.Position
                spoof_pos = hrp.Position + manip_offset
            elseif fake_lag_active and fake_lag_CFrame then
                spoof_pos = fake_lag_CFrame.Position + pos_offset
            else
                spoof_pos = hrp.Position + pos_offset
            end
            
            if recently_shot and silent_aim and silent_aim.manipulated_origin then
                hrp.CFrame = CFrame.new(spoof_pos) * CFrame.Angles(0, select(2, hrp.CFrame:ToOrientation()), 0)
            elseif aa_active then
                local X, Y, Z = Angled:ToOrientation()
                if aa_mode == "FlatRandom" then
                    hrp.CFrame = CFrame.new(spoof_pos) * CFrame.Angles(0, Y, 0) * CFrame.Angles(math.rad(90), 0, 0)
                else
                    hrp.CFrame = CFrame.new(spoof_pos) * CFrame.Angles(0, Y, 0)
                end
            elseif fake_lag_active and fake_lag_CFrame then
                hrp.CFrame = fake_lag_CFrame
            elseif fake_lag_active then
                hrp.CFrame = CFrame.new(spoof_pos) * CFrame.Angles(0, select(2, hrp.CFrame:ToOrientation()), 0)
            end

            -- Removed block cham logic

            -- Fire original look direction tilt
            local pitch_to_send = aa_pitch_value
            if aa_mode == "FlatRandom" then
                pitch_to_send = 250
            end
            if aa_active then
                ReplicatedStorage.Remotes.UpdateTilt:FireServer(pitch_to_send)
            end
        end)
    end)

    -- Input handlers for UG Resolver (X)
    cheat.utility.track_connection(UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.X and ug_resolver_enabled then
            ug_resolver_holding = true
            task.spawn(function()
                while ug_resolver_holding and ug_resolver_enabled do
                    UGRESOLVER()
                    task.wait(0.12)
                end
            end)
        end
    end))
    
    cheat.utility.track_connection(UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.X then
            ug_resolver_holding = false
        end
    end))
end

-- ─── COMBAT EXTRAS ───────────────────────────────────────────────────────────
do
    local combat_extras = ui.box.move_extra:AddTab('TP Kill')

    local tpkill_enabled = false
    local tpkill_height = 200
    local tpkill_start_time = 0
    local tpkill_original_cf = nil
    local current_tp_target = nil
    local fake_platform = nil
    local tpkill_master_enabled = false

    local function setTPKillActive(v)
        v = v and true or false
        if tpkill_enabled == v then return end

        tpkill_enabled = v
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if v then
            -- Use silent aim target if available AT ACTIVATION
            local target_part = silent_aim and silent_aim.target_part
            if target_part then
                current_tp_target = target_part
                tpkill_original_cf = hrp.CFrame
                tpkill_start_time = tick()
                
                -- Create invisible fake platform for the client to stand on so the server thinks we are grounded
                fake_platform = Instance.new("Part")
                fake_platform.Size = Vector3.new(10, 1, 10)
                fake_platform.Anchored = true
                fake_platform.CanCollide = true
                fake_platform.Transparency = 1
                fake_platform.Name = "TPKillPlatform"
                fake_platform.Parent = workspace
                
                -- Teleport once, preserving our current rotation so the camera doesn't glitch
                local new_pos = current_tp_target.Position + Vector3.new(0, tpkill_height, 0)
                hrp.CFrame = CFrame.new(new_pos) * hrp.CFrame.Rotation
                
                cheat.Library:Notify("TP Kill", "Teleported above targeted enemy")
            else
                -- No target found, disable
                current_tp_target = nil
                cheat.Toggles.tpkill_enabled:SetValue(false)
                cheat.Library:Notify("TP Kill", "No silent aim target found in FOV")
            end
        else
            -- Restore original position
            if tpkill_original_cf and hrp then
                -- Teleport 2 studs up to prevent clipping into the floor
                hrp.CFrame = tpkill_original_cf + Vector3.new(0, 2, 0)
                if cheat.real_CFrame then cheat.real_CFrame = hrp.CFrame end
                tpkill_original_cf = nil
                current_tp_target = nil
                cheat.Library:Notify("TP Kill", "Returned to original position")
                
                -- Destroy fake platform
                if fake_platform then
                    fake_platform:Destroy()
                    fake_platform = nil
                end
                
                -- Force Landed state to completely prevent any pending fall damage
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Landed)
                end
            end
        end
    end

    combat_extras:AddToggle('tpkill_enabled', {Text = 'TP Kill', Default = false, Callback = function(v)
        tpkill_master_enabled = v
        setTPKillActive(feature_active(tpkill_master_enabled, 'tpkill_key'))
    end}):AddKeyPicker('tpkill_key', {Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'TP Kill', NoUI = false, Callback = function()
        setTPKillActive(feature_active(tpkill_master_enabled, 'tpkill_key'))
    end})

    combat_extras:AddSlider('tpkill_height', {Text = 'Height Offset', Default = 200, Min = 5, Max = 300, Rounding = 0, Callback = function(v)
        tpkill_height = v
        
        -- Dynamically adjust height if we change the slider while active
        if tpkill_enabled then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and current_tp_target and current_tp_target.Parent then
                local new_pos = current_tp_target.Position + Vector3.new(0, tpkill_height, 0)
                hrp.CFrame = CFrame.new(new_pos) * hrp.CFrame.Rotation
            end
        end
    end})

    local tpkill_autolook = false
    combat_extras:AddToggle('tpkill_autolook', {Text = 'Auto Look at Target', Default = false, Callback = function(v)
        tpkill_autolook = v
    end})
    
    local tpkill_autotbot = false
    combat_extras:AddToggle('tpkill_autotbot', {Text = 'Auto Triggerbot', Default = false, Callback = function(v)
        tpkill_autotbot = v
    end})
    
    -- Auto Look processing
    RunService:BindToRenderStep("TPKillAutoLook", 201, function()
        if tpkill_enabled and current_tp_target and current_tp_target.Parent then
            if tpkill_autolook then
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, current_tp_target.Position)
            end
        end
    end)

    -- Heartbeat for TP Kill logic (Fly Bypass)
    cheat.utility.new_heartbeat(function(delta)
        local now = tick()
        if not tpkill_enabled then return end
        
        -- Automatic timeout check (5 seconds)
        if now - tpkill_start_time >= 5 then
            cheat.Toggles.tpkill_enabled:SetValue(false)
            return
        end

        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if current_tp_target and current_tp_target.Parent then
            -- Continuously force position to fight anti-cheat rubberbanding, but allow rotation so they can aim
            local frozen_pos = current_tp_target.Position + Vector3.new(0, tpkill_height, 0)
            hrp.CFrame = CFrame.new(frozen_pos) * hrp.CFrame.Rotation
            
            -- Track platform exactly below the player's feet (about 3.5 studs below HRP)
            if fake_platform then
                fake_platform.CFrame = CFrame.new(frozen_pos - Vector3.new(0, 3.5, 0))
            end
        end
    end)
end

-- ─── MISC EXTRAS: Bunny Hop + No Fall Damage (misc tab) ──────────────────────
do
    local misctab_mv = ui.box.move_extra:AddTab('Movement Extras')

    -- Bunny Hop
    local bunnyhop_enabled = false
    local bunnyhop_active = false
    local last_jump_time = 0
    local bunnyhop_power = 22
    misctab_mv:AddToggle('bunnyhop_enabled', {Text = 'Bunny Hop', Default = false, Callback = function(v)
        bunnyhop_enabled = v
    end}):AddKeyPicker('bunnyhop_key', {Default = 'None', Mode = 'Hold', Text = 'Bunny Hop', NoUI = false, Callback = function(v)
        bunnyhop_active = v
    end})
    misctab_mv:AddSlider('bunnyhop_power', {Text = 'Jump Power', Default = 22, Min = 1, Max = 28, Rounding = 0, Callback = function(v)
        bunnyhop_power = v
    end})

    -- No Fall Damage
    local no_fall = false
    misctab_mv:AddToggle('no_fall', {Text = 'No Fall Damage', Default = false, Callback = function(v)
        no_fall = v
    end})

    -- Bunny hop heartbeat
    cheat.utility.new_heartbeat(function(delta)
        if not feature_active(bunnyhop_enabled, 'bunnyhop_key') then return end
        local now = tick()
        if now - last_jump_time < 0.5 then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if hum and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.new(0, bunnyhop_power, 0)
                last_jump_time = now
            end
        end
    end)

    -- No fall damage heartbeat
    cheat.utility.new_heartbeat(function(delta)
        if not no_fall then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hum and hrp then
            if hum:GetState() == Enum.HumanoidStateType.Freefall then
                if hrp.AssemblyLinearVelocity.Y < -12.5 then
                    hum:ChangeState(Enum.HumanoidStateType.Landed)
                end
            end
        end
    end)
end

-- ─── MOD DETECTOR (in misc tab) ──────────────────────────────────────────────
do
    local misctab2 = ui.box.detection
    local mod_detector = false
    local cheat_detector = false
    local mod_warnings = {}
    local mod_alerted = {}
    local cheater_alerted = {}

    misctab2:AddToggle('mod_detector', {Text = 'Mod Detector', Default = false, Callback = function(v)
        mod_detector = v
        if v then cheat.Library:Notify('Mod Detector', 'Mod Detector enabled') end
    end})
    misctab2:AddToggle('cheat_detector', {Text = 'Cheater Detector (Requires Mod Detector)', Default = false, Callback = function(v)
        cheat_detector = v
        if v then cheat.Library:Notify('Cheater Detector', 'Cheater Detector enabled') end
    end})

    local function check_cheater(plr)
        if plr == LocalPlayer then return end
        if not cheat_detector then return end
        if cheater_alerted[plr.Name] then return end
        local rs_plr = ReplicatedStorage:FindFirstChild("Players") and
            ReplicatedStorage.Players:FindFirstChild(plr.Name)
        if not rs_plr then return end
        local status = rs_plr:FindFirstChild("Status")
        if not status then return end
        local journey = status:FindFirstChild("Journey")
        if not journey then return end
        local wipe = journey:FindFirstChild("WipeStatistics")
        if not wipe then return end
        local deaths = wipe:GetAttribute("Deaths") or 0
        if deaths == 0 then deaths = 1 end
        local kills = wipe:GetAttribute("Kills") or 0
        if kills == 0 then kills = 1 end
        local kdr = math.floor(kills / deaths * 10) / 10
        if kills >= 15 and kdr >= 5 then
            cheater_alerted[plr.Name] = true
            cheat.Library:Notify('Cheater Detector (KDR: '..kdr..')', plr.Name..' suspected cheater!')
        end
        local report = (ReplicatedStorage:FindFirstChild("ReportList"))
        if report then
            local entry = report:FindFirstChild("MostWanted") and report.MostWanted:FindFirstChild(plr.Name)
                or report:FindFirstChild("Recent") and report.Recent:FindFirstChild(plr.Name)
            if entry then
                local flags = entry:GetAttribute("TotalFlags") or 0
                local hsr = entry:GetAttribute("HSR") or 0
                local age = entry:GetAttribute("Age") or 0
                if kills >= 15 and hsr >= 95 then
                    cheater_alerted[plr.Name] = true
                    cheat.Library:Notify('Cheater Detector (B)', plr.Name..' suspected cheater!')
                end
                if flags >= 75 and age <= 50 then
                    cheater_alerted[plr.Name] = true
                    cheat.Library:Notify('Cheater Detector (C)', plr.Name..' suspected cheater!')
                end
            end
        end
    end

    local function run_mod_detector()
        if not mod_detector then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                check_cheater(plr)
                if plr.Character then
                    -- Method A: high premium level = likely mod/admin
                    if not mod_warnings[plr.Name] then mod_warnings[plr.Name] = 0 end
                    if mod_warnings[plr.Name] < 5 and not mod_alerted[plr.Name] then
                        local rs_plr = ReplicatedStorage:FindFirstChild("Players") and
                            ReplicatedStorage.Players:FindFirstChild(plr.Name)
                        if rs_plr then
                            local status = rs_plr:FindFirstChild("Status")
                            if status and status:FindFirstChild("GameplayVariables") and
                                status.GameplayVariables:GetAttribute("PremiumLevel") and
                                status.GameplayVariables:GetAttribute("PremiumLevel") >= 4 then
                                mod_warnings[plr.Name] = mod_warnings[plr.Name] + 1
                                cheat.Library:Notify('Mod Detector (A)', 'Mod detected: '..plr.Name)
                            end
                        end
                        -- Method B: invisible body parts
                        for _, part in pairs(plr.Character:GetChildren()) do
                            local bodyParts = {Head=true,LeftFoot=true,LeftHand=true,LeftLowerArm=true,
                                LeftLowerLeg=true,LeftUpperArm=true,LeftUpperLeg=true,LowerTorso=true,
                                RightFoot=true,RightHand=true,RightLowerArm=true,RightUpperArm=true,
                                RightUpperLeg=true,UpperTorso=true}
                            if bodyParts[part.Name] and part:IsA("BasePart") and part.Transparency >= 1 then
                                mod_warnings[plr.Name] = mod_warnings[plr.Name] + 1
                                cheat.Library:Notify('Mod Detector (B)', 'Mod detected (invis): '..plr.Name)
                                mod_alerted[plr.Name] = true
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    -- Run mod detector every 3 seconds
    task.spawn(function()
        while true do
            task.wait(3)
            pcall(run_mod_detector)
        end
    end)
end

-- ─── FREECAM ─────────────────────────────────────────────────────────────
do
    local freecam_tab = world_freecam_tab
    cheat.freecam_enabled = false
    local freecam_show_distance = false
    local freecam_speed = 50
    local freecam_cf = nil
    local freecam_part = nil
    local freecam_ghost = nil
    local freecam_ghost_label = nil
    local pitch, yaw = 0, 0
    local freecam_master_enabled = false
    
    freecam_tab:AddToggle('freecam_show_distance', {Text = 'Show Distance ESP', Default = false, Callback = function(v)
        freecam_show_distance = v
    end})
    
    freecam_tab:AddToggle('freecam_vis_original', {Text = 'Vis Check From Real Character', Default = false})
    
    local function setFreecamActive(v)
        v = v and true or false
        if cheat.freecam_enabled == v then return end

        cheat.freecam_enabled = v
        if v then
            freecam_cf = workspace.CurrentCamera.CFrame
            pitch, yaw = freecam_cf:ToOrientation()
            workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
            
            if not freecam_part then
                freecam_part = Instance.new("Part")
                freecam_part.Anchored = true
                freecam_part.CanCollide = false
                freecam_part.Transparency = 1
                freecam_part.Name = "FreecamFocus"
                freecam_part.Parent = workspace.Terrain
            end
            pcall(function() LocalPlayer.ReplicationFocus = freecam_part end)
            
            local char = LocalPlayer.Character
            if char then
                local oldArchivable = char.Archivable
                char.Archivable = true
                freecam_ghost = char:Clone()
                char.Archivable = oldArchivable
                
                if freecam_ghost then
                    freecam_ghost.Name = "FreecamGhost_ESP_IGNORE"
                    
                    local hl = Instance.new("Highlight")
                    local es_enemy = cheat.EspLibrary.settings.enemy
                    local ghost_cham_color = es_enemy.cham_color or Color3.new(1, 1, 1)
                    local ghost_cham_transparency = es_enemy.cham_transparency or 0.5
                    hl.FillColor = ghost_cham_color
                    hl.OutlineColor = ghost_cham_color
                    hl.FillTransparency = ghost_cham_transparency
                    hl.OutlineTransparency = math.clamp(ghost_cham_transparency * 0.5, 0, 1)
                    hl.DepthMode = es_enemy.chams_visible and not es_enemy.chams_hidden and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = freecam_ghost
                    
                    for _, desc in pairs(freecam_ghost:GetDescendants()) do
                        if desc:IsA("BasePart") then
                            desc.Material = Enum.Material.Neon
                            desc.Color = ghost_cham_color
                            desc.Transparency = ghost_cham_transparency
                            local sa = desc:FindFirstChildOfClass("SurfaceAppearance")
                            if sa then sa:Destroy() end
                            
                            desc.CanCollide = false
                            desc.CanTouch = false
                            desc.CanQuery = false
                            desc.Massless = true
                            desc.Anchored = true
                        elseif desc:IsA("Decal") or desc:IsA("Texture") or desc:IsA("Clothing") or desc:IsA("Accessory") or desc:IsA("Script") or desc:IsA("LocalScript") then
                            desc:Destroy()
                        end
                    end
                    
                    local humanoid = freecam_ghost:FindFirstChildOfClass("Humanoid")
                    if humanoid then humanoid:Destroy() end
                    
                    local hrp = freecam_ghost:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local text = cheat.utility.new_drawing("Text", {
                            Center = true,
                            Font = cheat.EspLibrary.main_settings.textFont,
                            Color = cheat.EspLibrary.settings.corpse.color or Color3.fromRGB(255, 255, 255),
                            Outline = true,
                            Size = cheat.EspLibrary.main_settings.textSize,
                            Visible = false,
                        })
                        freecam_ghost_label = text
                    end
                    
                    freecam_ghost.Parent = workspace.Terrain
                    local real_hrp = char:FindFirstChild("HumanoidRootPart")
                    if real_hrp then
                        freecam_ghost:PivotTo(real_hrp.CFrame)
                    end
                end
            end
        else
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            pcall(function() LocalPlayer.ReplicationFocus = nil end)
            if freecam_part then freecam_part:Destroy(); freecam_part = nil end
            if freecam_ghost_label then freecam_ghost_label:Remove(); freecam_ghost_label = nil end
            if freecam_ghost then freecam_ghost:Destroy(); freecam_ghost = nil end
        end
    end
    
    freecam_tab:AddToggle('freecam_enabled', {Text = 'Freecam', Default = false, Callback = function(v)
        freecam_master_enabled = v
        setFreecamActive(feature_active(freecam_master_enabled, 'freecam_bind'))
    end}):AddKeyPicker('freecam_bind', {Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'Freecam', NoUI = false, Callback = function()
        setFreecamActive(feature_active(freecam_master_enabled, 'freecam_bind'))
    end})
    
    freecam_tab:AddSlider('freecam_speed', {Text = 'Freecam Speed', Default = 50, Min = 10, Max = 575, Rounding = 0, Callback = function(v)
        freecam_speed = v
    end})
    
    local last_stream_req = 0
    cheat.utility.track_connection(RunService.RenderStepped:Connect(function(dt)
        if cheat.freecam_enabled then
            local cam = workspace.CurrentCamera
            
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
                local delta = UserInputService:GetMouseDelta()
                pitch = math.clamp(pitch - delta.Y * 0.005, -math.pi/2 + 0.01, math.pi/2 - 0.01)
                yaw = yaw - delta.X * 0.005
            else
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            end
            
            local moveVector = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Vector3.new(0, 0, 1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector + Vector3.new(0, 0, -1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector + Vector3.new(-1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Vector3.new(1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) or UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVector = moveVector + Vector3.new(0, -1, 0) end
            
            freecam_cf = CFrame.new(freecam_cf.Position) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0)
            
            if moveVector.Magnitude > 0 then
                moveVector = moveVector.Unit
                freecam_cf = freecam_cf + (freecam_cf.RightVector * moveVector.X + freecam_cf.UpVector * moveVector.Y + freecam_cf.LookVector * moveVector.Z) * (freecam_speed * dt)
            end
            
            cam.CFrame = freecam_cf
            if freecam_part then
                freecam_part.CFrame = freecam_cf
                pcall(function() LocalPlayer.ReplicationFocus = freecam_part end)
                if tick() - last_stream_req > 1 then
                    last_stream_req = tick()
                    task.spawn(function()
                        pcall(function() LocalPlayer:RequestStreamAroundAsync(freecam_cf.Position) end)
                    end)
                end
            end
            
            if freecam_ghost_label then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and freecam_show_distance then
                    local dist = math.floor((hrp.Position - freecam_cf.Position).Magnitude)
                    freecam_ghost_label.Text = "[" .. dist .. "m]"
                    freecam_ghost_label.Font = cheat.EspLibrary.main_settings.textFont
                    freecam_ghost_label.Size = cheat.EspLibrary.main_settings.textSize
                    
                    local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        freecam_ghost_label.Position = Vector2.new(pos.X, pos.Y)
                        freecam_ghost_label.Visible = true
                    else
                        freecam_ghost_label.Visible = false
                    end
                else
                    freecam_ghost_label.Visible = false
                end
            end
            
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
                end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:Move(Vector3.zero, false)
                end
            end
        end
    end))
end

cheat.utility.new_renderstepped(function()
    if not cheat.hitlogs_enabled then
        for _, log in ipairs(cheat.hitlogs.active) do
            if log.drawing then log.drawing:Remove() end
            if log.bg then log.bg:Remove() end
            if log.line then log.line:Remove() end
        end
        cheat.hitlogs.active = {}
        cheat.hitlogs.pending = {}
        return
    end

    local current_time = os.clock()
    for i = #cheat.hitlogs.pending, 1, -1 do
        local pending = cheat.hitlogs.pending[i]
        if current_time - pending.tick > 0.4 then
            local str = string.format("%s hit %s on %dm", pending.name, pending.part, pending.dist)
            
            local bg = cheat.utility.new_drawing("Square", {
                Size = _Vector2new(0, 0), Position = _Vector2new(-300, cheat.hitlogs_y),
                Color = Color3.fromRGB(20, 20, 20), Filled = true, Transparency = 1,
                Visible = true, ZIndex = 98
            })
            local line = cheat.utility.new_drawing("Square", {
                Size = _Vector2new(3, 0), Position = _Vector2new(-300, cheat.hitlogs_y),
                Color = cheat.hitlogs_invalid_color, Filled = true, Transparency = 1,
                Visible = true, ZIndex = 99
            })
            local text = cheat.utility.new_drawing("Text", {
                Text = str, Size = cheat.hitlogs_size, Font = cheat.hitlogs_font,
                Center = false, Outline = true, Color = Color3.new(1, 1, 1),
                Position = _Vector2new(-300, cheat.hitlogs_y), Visible = true, ZIndex = 100
            })
            table.insert(cheat.hitlogs.active, 1, {
                drawing = text, bg = bg, line = line, str = str, spawn_tick = current_time,
                target_y = cheat.hitlogs_y, current_x = -300
            })
            table.remove(cheat.hitlogs.pending, i)
        end
    end

    local base_y = cheat.hitlogs_y
    for i = #cheat.hitlogs.active, 1, -1 do
        local log = cheat.hitlogs.active[i]
        local age = current_time - log.spawn_tick
        if age > 5 then
            if log.drawing then log.drawing:Remove() end
            if log.bg then log.bg:Remove() end
            if log.line then log.line:Remove() end
            table.remove(cheat.hitlogs.active, i)
        else
            if log.current_x < 20 then
                log.current_x = log.current_x + (20 - log.current_x) * 0.15
            end
            
            local text_bounds = log.drawing.TextBounds
            local box_height = text_bounds.Y + 8
            local box_width = text_bounds.X + 16
            
            log.target_y = base_y + ((i - 1) * (box_height + 4))
            local current_y = log.drawing.Position.Y
            local new_y = current_y + (log.target_y - current_y) * 0.2
            local alpha = 1
            if age > 4 then alpha = 1 - (age - 4) end
            
            log.drawing.Position = _Vector2new(log.current_x + 8, new_y + 4)
            log.drawing.Transparency = alpha
            log.drawing.Size = cheat.hitlogs_size
            log.drawing.Font = cheat.hitlogs_font
            
            log.bg.Position = _Vector2new(log.current_x, new_y)
            log.bg.Size = _Vector2new(box_width, box_height)
            log.bg.Transparency = alpha
            
            log.line.Position = _Vector2new(log.current_x, new_y)
            log.line.Size = _Vector2new(3, box_height)
            log.line.Transparency = alpha
        end
    end
end)

cheat.ThemeManager:SetOptionsTEMP(cheat.Options, cheat.Toggles)
cheat.SaveManager:SetOptionsTEMP(cheat.Options, cheat.Toggles)
cheat.ThemeManager:SetLibrary(cheat.Library)
cheat.SaveManager:SetLibrary(cheat.Library)
cheat.SaveManager:IgnoreThemeSettings()
cheat.ThemeManager:SetFolder('GHOST_HOOK')
cheat.SaveManager:SetFolder('GHOST_HOOK')
local settings_config_name = "Default"
local function normalize_config_name(name)
    name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
    return name ~= "" and name or "Default"
end
local function write_autoload_config(name)
    if writefile then
        local normalized = normalize_config_name(name)
        writefile(cheat.SaveManager.Folder .. "/settings/autoload.txt", normalized)
        writefile("AutoLoadConfig", normalized)
    end
end
local function get_settings_config_names()
    local names = {"Default"}
    local seen = {Default = true}
    if cheat.SaveManager and cheat.SaveManager.RefreshConfigList then
        for _, name in ipairs(cheat.SaveManager:RefreshConfigList() or {}) do
            local normalized = normalize_config_name(name)
            if not seen[normalized] then
                seen[normalized] = true
                table.insert(names, normalized)
            end
        end
    end
    table.sort(names, function(a, b)
        if a == "Default" then return true end
        if b == "Default" then return false end
        return a:lower() < b:lower()
    end)
    return names
end
local settings_config_dropdown_name = "Default"
local settings_config_dropdown = ui.box.config:AddDropdown('SaveManager_ConfigDropdown', {
    Text = 'Select Config',
    Default = settings_config_dropdown_name,
    Values = get_settings_config_names(),
    Callback = function(value)
        settings_config_dropdown_name = normalize_config_name(value)
    end,
})
local settings_config_input = ui.box.config:AddInput('SaveManager_ConfigName', {
    Text = 'Enter Config Name',
    Default = settings_config_name,
    ClearTextOnFocus = true,
    Callback = function(value)
        local raw_value = tostring(value or "")
        if raw_value:gsub("%s+", "") == "" then
            return
        end
        settings_config_name = normalize_config_name(raw_value)
    end,
})
local function get_settings_config_action_name()
    settings_config_name = normalize_config_name(settings_config_name)
    return settings_config_name
end
local function get_settings_config_dropdown_name()
    return normalize_config_name(settings_config_dropdown_name)
end
local function refresh_settings_config_dropdown()
    local names = get_settings_config_names()
    local selected = normalize_config_name(settings_config_dropdown_name)
    local found = false
    for _, name in ipairs(names) do
        if name == selected then
            found = true
            break
        end
    end
    if not found and selected ~= "Default" then
        table.insert(names, selected)
        table.sort(names, function(a, b)
            if a == "Default" then return true end
            if b == "Default" then return false end
            return a:lower() < b:lower()
        end)
        found = true
    end
    if not found then
        selected = "Default"
    end
    settings_config_dropdown_name = selected
    if settings_config_dropdown and settings_config_dropdown.SetValues then
        settings_config_dropdown:SetValues(names)
    end
    if settings_config_dropdown and settings_config_dropdown.SetValue then
        settings_config_dropdown:SetValue(settings_config_dropdown_name, true)
    end
end
ui.box.config:AddButton('Refresh Config List', function()
    refresh_settings_config_dropdown()
    cheat.Library:Notify('GHOST_HOOK | Configs', 'Config List Refreshed', 3)
end)
ui.box.config:AddButton('Save Config', function()
    settings_config_name = get_settings_config_action_name()
    write_autoload_config(settings_config_name)
    local ok, err = cheat.SaveManager:Save(settings_config_name)
    if ok then
        settings_config_dropdown_name = settings_config_name
        refresh_settings_config_dropdown()
        cheat.Library:Notify('GHOST_HOOK | Configs', 'Config Named: ' .. settings_config_name .. ' Was Saved', 5)
    else
        cheat.Library:Notify('GHOST_HOOK | Configs', 'Failed To Save Config: ' .. tostring(err), 5)
    end
end)
ui.box.config:AddButton('Load Config', function()
    local loading = get_settings_config_dropdown_name()
    write_autoload_config(loading)
    local ok, err = cheat.SaveManager:Load(loading)
    if ok then
        cheat.Library:Notify('GHOST_HOOK | Configs', 'Config Named: ' .. loading .. ' Was Loaded', 5)
    else
        cheat.Library:Notify('GHOST_HOOK | Configs', 'Failed To Load Config: ' .. tostring(err), 5)
    end
end)
ui.box.config:AddButton('<font color="#ff4b4b">Delete Config</font>', function()
    local deleting = get_settings_config_dropdown_name()
    local ok, err = cheat.SaveManager:Delete(deleting)
    if ok then
        settings_config_dropdown_name = "Default"
        local loaded_default, default_err = cheat.SaveManager:Load(settings_config_dropdown_name)
        if loaded_default then
            write_autoload_config(settings_config_dropdown_name)
        end
        refresh_settings_config_dropdown()
        if loaded_default then
            cheat.Library:Notify('GHOST_HOOK | Configs', 'Config Named: ' .. deleting .. ' Was Deleted, Loaded Default', 5)
        else
            cheat.Library:Notify('GHOST_HOOK | Configs', 'Config Deleted, Failed To Load Default: ' .. tostring(default_err), 5)
        end
    else
        cheat.Library:Notify('GHOST_HOOK | Configs', 'Failed To Delete Config: ' .. tostring(err), 5)
    end
end)
ui.box.script:AddButton('Unload - Will Lag Once', function()
    task.defer(function()
        cheat.utility.unload()
    end)
end)

local settings_selected_npc = 'Mihkel'
ui.box.npc:AddDropdown('settings_npc_select', {
    Text = 'NPC - Only In Lobby',
    Default = 'Mihkel',
    Values = {'Mihkel', 'Seryozha', 'Tarmo', 'Nurse', 'Blaze', 'Boss', 'Designer', 'Anna'},
    Callback = function(value)
        settings_selected_npc = value
    end,
})
local function find_lobby_npc(name)
    local target_name = tostring(name or ""):lower()
    local direct = workspace:FindFirstChild(name)
    if direct then
        return direct
    end

    for _, object in ipairs(workspace:GetDescendants()) do
        if object.Name:lower() == target_name and (object:IsA("Model") or object:IsA("Folder")) then
            return object
        end
    end
end

local function get_npc_root(npc)
    if not npc then return nil end
    return npc:FindFirstChild("HumanoidRootPart", true)
        or npc:FindFirstChild("RootPart", true)
        or npc.PrimaryPart
        or npc:FindFirstChildWhichIsA("BasePart", true)
end

ui.box.npc:AddButton('Teleport Npc To You', function()
    local npc = find_lobby_npc(settings_selected_npc)
    local npc_root = get_npc_root(npc)
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild('HumanoidRootPart')
    if npc_root and root then
        if npc and npc:IsA("Model") then
            npc:PivotTo(root.CFrame)
        else
            npc_root.CFrame = root.CFrame
        end
    elseif cheat.Library and cheat.Library.Notify then
        cheat.Library:Notify('NPC', tostring(settings_selected_npc) .. ' NPC or player root not found', 3)
    end
end)

ui.box.themes:AddToggle('ThemeManager_CustomTheme', {
    Text = 'Custom Theme (Beta)',
    Default = false,
    Callback = function(value)
        if cheat.Library and cheat.Library._ghostMenu and cheat.Library._ghostMenu.SetThemeAccent then
            cheat.Library._ghostMenu.SetThemeAccent(value, cheat.Options.ThemeManager_CustomThemeColor and cheat.Options.ThemeManager_CustomThemeColor.Value or Color3.fromRGB(129, 210, 255))
        end
    end
}):AddColorPicker('ThemeManager_CustomThemeColor', {
    Default = Color3.fromRGB(129, 210, 255),
    Title = 'Accent Color',
    Callback = function(color)
        if cheat.Library and cheat.Library._ghostMenu and cheat.Library._ghostMenu.SetThemeAccent then
            cheat.Library._ghostMenu.SetThemeAccent(cheat.Toggles.ThemeManager_CustomTheme and cheat.Toggles.ThemeManager_CustomTheme.Value, color)
        end
    end
})

local function get_player_gui()
    return LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
end

local hide_server_info_connection
ui.box.client:AddToggle('client_hide_server_info', {
    Text = 'Hide Server Information',
    Default = false,
    Callback = function(value)
        local player_gui = get_player_gui()
        local function apply(gui)
            local frame = gui and gui:FindFirstChild('Frame')
            local server_info = frame and frame:FindFirstChild('serverInfo')
            if server_info then
                server_info.Visible = not value
            end
        end

        apply(player_gui and player_gui:FindFirstChild('ServerInfo'))
        if value and not hide_server_info_connection then
            hide_server_info_connection = cheat.utility.track_connection(player_gui.ChildAdded:Connect(function(child)
                if child.Name == 'ServerInfo' then
                    task.defer(function()
                        apply(child)
                    end)
                end
            end))
        elseif not value and hide_server_info_connection then
            hide_server_info_connection:Disconnect()
            cheat.connections.generic[hide_server_info_connection] = nil
            hide_server_info_connection = nil
        end
    end,
})

local hide_name_chat_connection
local hide_name_chat_wait_connection
local function scrub_chat_name(chat_gui, hide)
    local main_frame = chat_gui and chat_gui:FindFirstChild('MainFrame')
    local chat_box = main_frame and main_frame:FindFirstChild('ChatBox')
    local chat_window = chat_box and chat_box:FindFirstChild('ChatWindow')
    if not chat_window then return nil end

    local function scrub_label(label)
        if label:IsA('TextLabel') and label:FindFirstChild('Message') then
            local message = label.Message
            if hide and message.Text:find(LocalPlayer.Name) then
                message.Text = message.Text:gsub(LocalPlayer.Name, 'Hidden')
            elseif not hide and message.Text:find('Hidden') then
                message.Text = message.Text:gsub('Hidden', LocalPlayer.Name)
            end
        end
    end

    for _, child in pairs(chat_window:GetChildren()) do
        scrub_label(child)
    end

    return chat_window, scrub_label
end

ui.box.client:AddToggle('client_hide_name_chat', {
    Text = 'Hide Name In Chat',
    Default = false,
    Callback = function(value)
        local player_gui = get_player_gui()
        if hide_name_chat_connection then
            hide_name_chat_connection:Disconnect()
            cheat.connections.generic[hide_name_chat_connection] = nil
            hide_name_chat_connection = nil
        end
        if hide_name_chat_wait_connection then
            hide_name_chat_wait_connection:Disconnect()
            cheat.connections.generic[hide_name_chat_wait_connection] = nil
            hide_name_chat_wait_connection = nil
        end

        local function attach(chat_gui)
            local chat_window, scrub_label = scrub_chat_name(chat_gui, value)
            if value and chat_window and scrub_label then
                hide_name_chat_connection = cheat.utility.track_connection(chat_window.ChildAdded:Connect(function(child)
                    if cheat.Toggles.client_hide_name_chat and cheat.Toggles.client_hide_name_chat.Value then
                        task.defer(function()
                            scrub_label(child)
                        end)
                    end
                end))
            end
        end

        local chat_gui = player_gui and player_gui:FindFirstChild('ChatV3')
        if chat_gui then
            attach(chat_gui)
        elseif value and player_gui then
            hide_name_chat_wait_connection = cheat.utility.track_connection(player_gui.ChildAdded:Connect(function(child)
                if child.Name == 'ChatV3' and cheat.Toggles.client_hide_name_chat and cheat.Toggles.client_hide_name_chat.Value then
                    attach(child)
                    if hide_name_chat_wait_connection then
                        hide_name_chat_wait_connection:Disconnect()
                        cheat.connections.generic[hide_name_chat_wait_connection] = nil
                        hide_name_chat_wait_connection = nil
                    end
                end
            end))
        end
    end,
})
ui.box.client:AddButton('Rejoin server', function()
    local job_id = game.JobId
    local place_id = game.PlaceId
    if job_id and place_id and job_id ~= "" then
        game:GetService('TeleportService'):TeleportToPlaceInstance(place_id, job_id, LocalPlayer)
    end
end)

ui.box.keybinds:AddToggle('keybindshoww', {
    Text = 'KeyBind Indicator',
    Default = false,
    Callback = function(first)
        cheat.keybind_indicator_enabled = first and true or false
        if cheat.Library and cheat.Library.KeybindFrame then
            cheat.Library.KeybindFrame.Visible = cheat.keybind_indicator_enabled
        end
        cheat.utility.create_keybind_indicator()
    end
})
ui.box.keybinds:AddKeybind('menu_toggle_key', {
    Text = 'Toggle Menu Key',
    Default = 'RightControl',
    Callback = function(value)
        if cheat.Library and cheat.Library.SetToggleKey then
            cheat.Library:SetToggleKey(value)
        end
    end
})

local has_pinreta_autoload = isfile and isfile(cheat.SaveManager.Folder .. "/settings/autoload.txt")
local has_ghost_autoload = isfile and isfile("AutoLoadConfig")
if isfile and not has_pinreta_autoload and not has_ghost_autoload then
    local ok, err = cheat.SaveManager:Save('Default')
    if ok then
        write_autoload_config('Default')
    elseif cheat.Library and cheat.Library.Notify then
        cheat.Library:Notify('GHOST_HOOK | Configs', 'Failed To Create Default Config: ' .. tostring(err), 5)
    end
end
cheat.SaveManager:LoadAutoloadConfig()
cheat.EspLibrary.load()
cheat.ui_ready = true
if cheat.loading_finished and cheat.Library and cheat.Library.SetOpen and not cheat.unloaded then
    cheat.Library:SetOpen(true)
end
task.spawn(function()
    for _, v in getconnections(game.ReplicatedStorage.Remotes.NotificationMessage.OnClientEvent) do
        if not v.Function then return end
        for i=1,5 do task.spawn(function()v.Function("WELCOME TO GHOST_HOOK!!!!!", 5, i)end) task.wait(1) end
    end
end)
