local function notify(r0_268, r1_268, r2_268)
  -- line: [0, 0] id: 268
  game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = r0_268,
    Text = r1_268,
    Duration = r2_268,
  })
end
function Save(r0_24, r1_24)
  -- line: [0, 0] id: 24
  if typeof(r0_24) == "UDim2" then
    local r2_24 = r0_24.X.Scale .. "," .. r0_24.X.Offset .. "," .. r0_24.Y.Scale .. "," .. r0_24.Y.Offset
    if not r1_24:match("%.txt$") then
      r1_24 = r1_24 .. ".txt"
    end
    writefile(r1_24, r2_24)
  else
    writefile(r1_24, tostring(r0_24))
  end
end
notify("GHOST_HOOK 1/5", "Main Script Is Loading...", 5)
local keyCipherMap = {
  a = "$512@",
  b = "*8#74",
  c = "#9$63",
  d = "/2$34",
  e = "%7!86",
  f = "@1$45",
  g = "!67#8",
  h = "&90!1",
  i = "~4$32",
  j = "+7#89",
  k = "|2@10",
  l = "^5$43",
  m = "=87#6",
  n = "(32!1)",
  o = "[6$54]",
  p = "]98@7[",
  q = "$1#23",
  r = "#4$56",
  s = "%7#89",
  t = "+2$34",
  u = "&5$67",
  v = "@8$90",
  w = "^32#1",
  x = "~65$4",
  y = "[9#87]",
  z = "$43@2",
  A = "!12#5",
  B = "$67#8",
  C = "#9$01",
  D = "%4#32",
  E = "~78$9",
  F = "&21@0",
  G = "^5$43",
  H = "@87#6",
  I = "!3$21",
  J = "+6#54",
  K = "=9$87",
  L = "[1$23]",
  M = "$4#56",
  N = "&7$89",
  O = "#2$34",
  P = "%5$67",
  Q = "~8$90",
  R = "$3#21",
  S = "^6$54",
  T = "#9$87",
  U = "&4$32",
  V = "+7$65",
  W = "[8$76]",
  X = "~1$23",
  Y = "[2#34]",
  Z = "!3$45",
  ["0"] = "+6$78",
  ["1"] = "/9$01",
  ["2"] = "^4#32",
  ["3"] = "|7$89",
  ["4"] = "#2@10",
  ["5"] = "~5$43",
  ["6"] = "-8$76",
  ["7"] = "=3#21",
  ["8"] = "%6$54",
  ["9"] = "*9$87",
  ["!"] = "$/1#25",
  ["@"] = "+$2#15",
  ["#"] = "^8$76",
  ["$"] = "*+4$32",
  ["%"] = "-5#43",
  ["^"] = "|=2$34",
  ["&"] = "~9$87",
  ["*"] = "#|6$78",
  ["("] = "><3$21",
  [")"] = "[9$87]",
}
function Load(r0_291, r1_291)
  -- line: [0, 0] id: 291
  if not isfile(r1_291) then
    return nil
  end
  if r0_291 == "UDim2" then
    local r3_291, r4_291, r5_291, r6_291 = string.match(readfile(r1_291), "([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)")
    if r3_291 and r5_291 then
      return UDim2.new(tonumber(r3_291), tonumber(r4_291), tonumber(r5_291), tonumber(r6_291))
    end
    return nil
  end
  return readfile(r1_291)
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

  local savedId = nil
  pcall(function()
    savedId = Load("Text", "GhostKeyDevice")
  end)
  if savedId and tostring(savedId) ~= "" then
    return tostring(savedId)
  end

  savedId = executor .. "-" .. tostring(math.random(100000, 999999)) .. "-" .. tostring(os.time())
  pcall(function()
    Save(savedId, "GhostKeyDevice")
  end)
  return savedId
end

local function ghostHttpRequest(requestData)
  local requester = (syn and syn.request) or http_request or request or (http and http.request)
  if requester then
    return requester(requestData)
  end

  return game:GetService("HttpService"):RequestAsync(requestData)
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

  local httpService = game:GetService("HttpService")
  local player = game:GetService("Players").LocalPlayer
  local deviceId = getGhostDeviceId()
  local body = httpService:JSONEncode({
    key = providedKey,
    deviceId = deviceId,
    hwid = deviceId,
    userId = player and tostring(player.UserId) or nil,
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
        return httpService:JSONDecode(responseBody)
      end)

      if decodedOk and decoded then
        if decoded.success == true then
          return true, decoded.message or "Key validated"
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

local ghostKeyOk, ghostKeyMessage = validateGhostKey()
if not ghostKeyOk then
  notify("GHOST_HOOK Key", tostring(ghostKeyMessage), 5)
  return
end

notify("GHOST_HOOK Key", tostring(ghostKeyMessage), 2.5)

local GHOST_CACHE_FOLDER = "GhostHookCache"
local GHOST_DEPENDENCIES = {
  Keybinds = {
    path = GHOST_CACHE_FOLDER .. "/keybinds.lua",
    url = "https://raw.githubusercontent.com/kristerstomasuns-hub/essentials/main/Keybinds?v=configfix-20260719",
  },
  Library = {
    path = GHOST_CACHE_FOLDER .. "/library.lua",
    url = "https://raw.githubusercontent.com/kristerstomasuns-hub/essentials/main/test%20lib?v=configfix-20260719",
  },
}

local function ensureGhostCacheFolder()
  if makefolder then
    pcall(function()
      if not isfolder or not isfolder(GHOST_CACHE_FOLDER) then
        makefolder(GHOST_CACHE_FOLDER)
      end
    end)
  end
end

local function readGhostDependencySource(dependency)
  if isfile and readfile and dependency.path and isfile(dependency.path) then
    local ok, source = pcall(readfile, dependency.path)
    if ok and source and source ~= "" then
      return source
    end
  end

  local source = game:HttpGet(dependency.url, true)
  if source and source ~= "" and writefile then
    ensureGhostCacheFolder()
    pcall(writefile, dependency.path, source)
  end
  return source
end

local function loadGhostDependency(name)
  local dependency = GHOST_DEPENDENCIES[name]
  if not dependency then
    return nil
  end

  if isfile and readfile and dependency.path and isfile(dependency.path) then
    local ok, source = pcall(readfile, dependency.path)
    if ok and source and source ~= "" then
      local chunk = loadstring(source)
      if chunk then
        local runOk, result = pcall(chunk)
        if runOk and result then
          return result
        end
      end
    end
  end

  local source = game:HttpGet(dependency.url, true)
  if source and source ~= "" and writefile then
    ensureGhostCacheFolder()
    pcall(writefile, dependency.path, source)
  end
  return loadstring(source)()
end

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
      radarSource = game:HttpGet("https://raw.githubusercontent.com/kristerstomasuns-hub/essentials/main/radar?v=configfix-20260719", true)
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

task.spawn(function()
  for _, dependency in pairs(GHOST_DEPENDENCIES) do
    pcall(readGhostDependencySource, dependency)
  end
end)


local function espcuh()
    --[[
  if not _G.InjectedGui then
    return 
  end]]
  local notify = game:GetService("RunService")
  local keyCipherMap = game:GetService("Workspace")
  local mainHeartbeatConnection = game:GetService("Players")
  local unusedConnectionOrState = game:GetService("ReplicatedStorage")
  local CoreGui = mainHeartbeatConnection.LocalPlayer
  local RunService = keyCipherMap.CurrentCamera
  local UserInputService = {}
  local Players = {
    TeamCheck = false,
    WallCheck = false,
    Enabled = false,
    MenuOverride = false,
    ShowBox = false,
    BoxType = "2D",
    ShowName = false,
    ShowHealth = false,
    ShowDistance = false,
    ShowSkeletons = false,
    ActiveGun = false,
    StudsToMeters = false,
    MaxDistance = 5000,
    CharSize = Vector2.new(4, 6),
    SkeletonThickness = 2,
    BoxOutlineColor = Color3.new(0, 0, 0),
    BoxColor = Color3.new(1, 1, 1),
    NameColor = Color3.new(1, 1, 1),
    HealthOutlineColor = Color3.new(0, 0, 0),
    HealthHighColor = Color3.new(0, 1, 0),
    HealthLowColor = Color3.new(1, 0, 0),
    DistanceColor = Color3.new(1, 1, 1),
    SkeletonsColor = Color3.new(1, 1, 1),
    ActiveGunColor = Color3.new(10, 15, 30),
    Moderators = {},
    Cheaters = {},
    Special = {},
    EspConnections = {},
    Disconnect = function(r0_7)
      -- line: [0, 0] id: 7
      for r4_7, r5_7 in pairs(r0_7.EspConnections or {}) do
        r5_7:Disconnect()
      end
    end,
  }
  local localPlayer = {
    {
      "Head",
      "UpperTorso"
    },
    {
      "UpperTorso",
      "LowerTorso"
    },
    {
      "UpperTorso",
      "LeftUpperArm"
    },
    {
      "UpperTorso",
      "RightUpperArm"
    },
    {
      "LeftUpperArm",
      "LeftLowerArm"
    },
    {
      "RightUpperArm",
      "RightLowerArm"
    },
    {
      "LeftLowerArm",
      "LeftHand"
    },
    {
      "RightLowerArm",
      "RightHand"
    },
    {
      "LowerTorso",
      "LeftUpperLeg"
    },
    {
      "LowerTorso",
      "RightUpperLeg"
    },
    {
      "LeftUpperLeg",
      "LeftLowerLeg"
    },
    {
      "RightUpperLeg",
      "RightLowerLeg"
    },
    {
      "LeftLowerLeg",
      "LeftFoot"
    },
    {
      "RightLowerLeg",
      "RightFoot"
    }
  }
  local function camera(r0_4, r1_4)
    -- line: [0, 0] id: 4
    local r2_4 = Drawing.new(r0_4)
    for r6_4, r7_4 in pairs(r1_4) do
      r2_4[r6_4] = r7_4
    end
    return r2_4
  end
  local function mouse(r0_8)
    -- line: [0, 0] id: 8
    UserInputService[r0_8] = {
      BoxOutline = camera("Square", {
        Color = Players.BoxOutlineColor,
        Thickness = 3,
        Filled = false,
      }),
      Box = camera("Square", {
        Color = Players.BoxColor,
        Thickness = 1,
        Filled = false,
      }),
      Name = camera("Text", {
        Color = Players.NameColor,
        Outline = true,
        Center = true,
        Size = 13,
      }),
      HealthOutline = camera("Line", {
        Thickness = 3,
        Color = Players.HealthOutlineColor,
      }),
      Health = camera("Line", {
        Thickness = 1,
      }),
      Distance = camera("Text", {
        Color = Players.DistanceColor,
        Size = 12,
        Outline = true,
        Center = true,
      }),
      ActiveGun = camera("Text", {
        Color = Players.ActiveGunColor,
        Size = 12,
        Outline = true,
        Center = true,
      }),
      BoxLines = {},
      SkeletonLines = {},
    }
  end
  local function ReplicatedStorage()
    -- line: [0, 0] id: 3
    unusedConnectionOrState = game:GetService("ReplicatedStorage")
    for r3_3, r4_3 in pairs(UserInputService) do
      local r5_3 = r3_3.Character
      if r5_3 and (not Players.TeamCheck or CoreGui.Team and r3_3.Team ~= CoreGui.Team) then
        local r6_3 = r5_3:FindFirstChild("HumanoidRootPart")
        if r6_3 then
          local r7_3, r8_3 = RunService:WorldToViewportPoint(r6_3.Position)
          if r8_3 then
            local r9_3 = (RunService:WorldToViewportPoint(r6_3.Position - Vector3.new(0, 3, 0)).Y - RunService:WorldToViewportPoint(r6_3.Position + Vector3.new(0, 2.6, 0)).Y) / 2
            local r10_3 = Vector2.new(math.floor(r9_3 * 1.8), math.floor(r9_3 * 1.9))
            local r11_3 = Vector2.new(math.floor(r7_3.X - r10_3.X / 2), math.floor(r7_3.Y - r9_3 * 1.6 / 2))
            local r12_3 = r5_3:FindFirstChild("Humanoid")
            local r13_3 = nil	-- notice: implicit variable refs by block#[21]
            if r12_3 then
              r13_3 = r12_3.Health / r12_3.MaxHealth
              if not r13_3 then
                --::label_100::
                r13_3 = 0
              end
            else
              --goto label_100	-- block#9 is visited secondly
            end
            local r14_3 = (RunService.CFrame.Position - r6_3.Position).Magnitude
            if Players.StudsToMeters then
              r14_3 = math.floor(r14_3 / 4) .. " Meters" or math.floor(r14_3) .. " Studs"
            else
              --goto label_119	-- block#12 is visited secondly
            end
            local r15_3 = "None"
            local r16_3 = unusedConnectionOrState:FindFirstChild("Players")
            if r16_3 then
              local r17_3 = r16_3:FindFirstChild(r3_3.Name)
              if r17_3 and r17_3:FindFirstChild("Status") and r17_3.Status:FindFirstChild("GameplayVariables") then
                r15_3 = r17_3.Status.GameplayVariables.EquippedTool.Value or "None"
              end
            end
            local r17_3 = true
            if Players.MaxDistance <= (RunService.CFrame.Position - r6_3.Position).Magnitude then
              r17_3 = false
            end
            r4_3.Data = {
              HRP2D = r7_3,
              BoxSize = r10_3,
              BoxPos = r11_3,
              OnScreen = r17_3,
              HealthPercentage = r13_3,
              Distance = r14_3,
              Weapon = r15_3,
            }
            if Players.ShowSkeletons and #r4_3.SkeletonLines == 0 then
              for r21_3, r22_3 in ipairs(localPlayer) do
                local r23_3 = r22_3[1]
                local r24_3 = r22_3[2]
                if r5_3:FindFirstChild(r23_3) and r5_3:FindFirstChild(r24_3) then
                  table.insert(r4_3.SkeletonLines, {
                    camera("Line", {
                      Thickness = Players.SkeletonThickness,
                      Color = Players.SkeletonsColor,
                      Transparency = 1,
                    }),
                    r23_3,
                    r24_3
                  })
                end
              end
            end
            for r21_3 = #r4_3.SkeletonLines, 1, -1 do
              local r22_3 = r4_3.SkeletonLines[r21_3]
              local r23_3 = r22_3[1]
              local r26_3 = r5_3:FindFirstChild(r22_3[2])
              local r27_3 = r5_3:FindFirstChild(r22_3[3])
              if r26_3 and r27_3 then
                local r28_3 = RunService:WorldToViewportPoint(r26_3.Position)
                local r29_3 = RunService:WorldToViewportPoint(r27_3.Position)
                r23_3.From = Vector2.new(r28_3.X, r28_3.Y)
                r23_3.To = Vector2.new(r29_3.X, r29_3.Y)
                r23_3.Visible = Players.ShowSkeletons and Players.Enabled and not Players.MenuOverride
              else
                r23_3:Remove()
                table.remove(r4_3.SkeletonLines, r21_3)
              end
            end
          else
            r4_3.Data = {
              OnScreen = false,
            }
          end
        else
          r4_3.Data = {
            OnScreen = false,
          }
        end
      else
        r4_3.Data = {
          OnScreen = false,
        }
      end
    end
  end
  local function serverListFolder()
    -- line: [0, 0] id: 6
    mainHeartbeatConnection = game:GetService("Players")
    for r3_6, r4_6 in pairs(UserInputService) do
      local r5_6 = r4_6.Data
      if r5_6 and r5_6.OnScreen and Players.Enabled and not Players.MenuOverride then
        local r6_6 = r5_6.BoxPos
        local r7_6 = r5_6.BoxSize
        if Players.ShowBox then
          r4_6.Box.Size = r7_6
          r4_6.Box.Position = r6_6
          r4_6.Box.Color = Players.BoxColor
          r4_6.Box.Visible = true
          r4_6.BoxOutline.Size = r7_6
          r4_6.BoxOutline.Position = r6_6
          r4_6.BoxOutline.Color = Players.BoxOutlineColor
          r4_6.BoxOutline.Visible = true
        else
          r4_6.Box.Visible = false
          r4_6.BoxOutline.Visible = false
        end
        if Players.ShowHealth then
          local r8_6 = r5_6.HealthPercentage
          r4_6.HealthOutline.From = Vector2.new(r6_6.X - 6, r6_6.Y + r7_6.Y)
          r4_6.HealthOutline.To = Vector2.new(r4_6.HealthOutline.From.X, r4_6.HealthOutline.From.Y - r7_6.Y)
          r4_6.Health.From = Vector2.new(r6_6.X - 5, r6_6.Y + r7_6.Y)
          r4_6.Health.To = Vector2.new(r4_6.Health.From.X, r4_6.Health.From.Y - r8_6 * r7_6.Y)
          r4_6.Health.Color = Players.HealthLowColor:Lerp(Players.HealthHighColor, r8_6)
          r4_6.HealthOutline.Visible = true
          r4_6.Health.Visible = true
        else
          r4_6.HealthOutline.Visible = false
          r4_6.Health.Visible = false
        end
        if Players.ShowDistance then
          r4_6.Distance.Text = r5_6.Distance
          r4_6.Distance.Color = Players.DistanceColor
          r4_6.Distance.Position = Vector2.new(r6_6.X + r7_6.X / 2, r6_6.Y + r7_6.Y + 5)
          r4_6.Distance.Visible = true
        else
          r4_6.Distance.Visible = false
        end
        if Players.ActiveGun then
          r4_6.ActiveGun.Text = tostring(r5_6.Weapon)
          r4_6.ActiveGun.Color = Players.ActiveGunColor
          r4_6.ActiveGun.Position = Vector2.new(r6_6.X + r7_6.X / 2, r6_6.Y + r7_6.Y + 15)
          r4_6.ActiveGun.Visible = true
        else
          r4_6.ActiveGun.Visible = false
        end
        if Players.ShowName then
          r4_6.Name.Text = string.lower(r3_6.Name)
          r4_6.Name.Visible = true
          if Players.Special[r3_6.Name] then
            r4_6.Name.Text = string.lower(r3_6.Name .. " | Special")
            r4_6.Name.Color = Color3.new(0, 0, 1)
          elseif Players.Cheaters[r3_6.Name] then
            r4_6.Name.Text = string.lower(r3_6.Name .. " | Cheater")
            r4_6.Name.Color = Color3.new(1, 0, 0)
          elseif Players.Moderators[r3_6.Name] then
            r4_6.Name.Text = string.lower(r3_6.Name .. " | Moderator")
            r4_6.Name.Color = Color3.new(1, 0.6, 0)
          else
            r4_6.Name.Color = Players.NameColor
          end
          r4_6.Name.Position = Vector2.new(r7_6.X / 2 + r6_6.X, r6_6.Y - 16)
        else
          r4_6.Name.Visible = false
        end
        for r11_6, r12_6 in ipairs(r4_6.SkeletonLines) do
          r12_6[1].Visible = Players.ShowSkeletons and Players.Enabled and not Players.MenuOverride
        end
      else
        for r9_6, r10_6 in pairs(r4_6) do
          if typeof(r10_6) ~= "table" or r10_6.Remove ~= nil then
            r10_6.Visible = false
          end
        end
        for r9_6, r10_6 in ipairs(r4_6.SkeletonLines) do
          r10_6[1]:Remove()
        end
        r4_6.SkeletonLines = {}
        for r9_6, r10_6 in ipairs(r4_6.BoxLines) do
          r10_6:Remove()
        end
        r4_6.BoxLines = {}
      end
    end
  end
  for clientUuid, caesarShiftString in ipairs(mainHeartbeatConnection:GetPlayers()) do
    if caesarShiftString ~= CoreGui then
      mouse(caesarShiftString)
    end
  end
  mainHeartbeatConnection.PlayerAdded:Connect(function(r0_5)
    -- line: [0, 0] id: 5
    if r0_5 ~= CoreGui then
      mouse(r0_5)
    end
  end)
  Players.EspConnections.HeartBeat = notify.Heartbeat:Connect(ReplicatedStorage)
  Players.EspConnections.RenderStepped = notify.RenderStepped:Connect(serverListFolder)
  Players.EspConnections.RemoveEsp = mainHeartbeatConnection.PlayerRemoving:Connect(function(r0_1)
    -- line: [0, 0] id: 1
    local r1_1 = UserInputService[r0_1]
    if not r1_1 then
      return 
    end
    local function r2_1(r0_2)
      -- line: [0, 0] id: 2
      if r0_2 and (typeof(r0_2) == "userdata" or typeof(r0_2) == "table") and r0_2.Remove then
        r0_2:Remove()
      end
    end
    r2_1(r1_1.Box)
    r2_1(r1_1.BoxOutline)
    r2_1(r1_1.Name)
    r2_1(r1_1.Health)
    r2_1(r1_1.HealthOutline)
    r2_1(r1_1.Distance)
    r2_1(r1_1.ActiveGun)
    for r6_1, r7_1 in ipairs(r1_1.SkeletonLines) do
      r2_1(r7_1[1])
    end
    r1_1.SkeletonLines = {}
    for r6_1, r7_1 in ipairs(r1_1.BoxLines) do
      r2_1(r7_1)
    end
    r1_1.BoxLines = {}
    UserInputService[r0_1] = nil
  end)
  return Players
end


local mainHeartbeatConnection = nil
local unusedConnectionOrState = nil
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local camera = game.Workspace.Camera
local mouse = localPlayer:GetMouse()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local serverListFolder = ReplicatedStorage:FindFirstChild("Servers")
local itemsList = ReplicatedStorage:FindFirstChild("ItemsList")
local tamperFlag = false
local function generateUuid()
  -- line: [0, 0] id: 264
  local function r0_264()
    -- line: [0, 0] id: 265
    return string.char(math.random(65, 90)) .. string.char(math.random(65, 90)) .. string.char(math.random(65, 90)) .. string.char(math.random(65, 90)) .. string.char(math.random(65, 90))
  end
  return r0_264() .. "-" .. r0_264()
end
local clientUuid = Load("Text", "Config") and nil
if not clientUuid then
  clientUuid = generateUuid()
  Save(clientUuid, "Config")
  clientUuid = clientUuid .. " - First Time Loading Script"
end
local function caesarShiftString(r0_281, r1_281)
  -- line: [0, 0] id: 281
  local r2_281 = {}
  local r3_281 = 7
  for r7_281 = 1, #r0_281, 1 do
    local r8_281 = string.byte(r0_281, r7_281)
    if 65 <= r8_281 and r8_281 <= 90 then
      local r9_281 = 65
      table.insert(r2_281, string.char((r8_281 - r9_281 + r3_281) % 26 + r9_281))
    elseif 97 <= r8_281 and r8_281 <= 122 then
      local r9_281 = 97
      table.insert(r2_281, string.char((r8_281 - r9_281 + r3_281) % 26 + r9_281))
    else
      table.insert(r2_281, string.char(r8_281))
    end
  end
  return table.concat(r2_281)
end
local function isBossAlive(r0_51, r1_51, r2_51)
  -- line: [0, 0] id: 51
  local r3_51 = game.Workspace:FindFirstChild("AiZones")
  if not r3_51 then
    return false
  end
  local r4_51 = r3_51:FindFirstChild(r0_51)
  if not r4_51 then
    return false
  end
  local r5_51 = r4_51:FindFirstChild(r1_51)
  if not r5_51 or not r5_51:IsA("Model") then
    return false
  end
  local r6_51 = r5_51:FindFirstChild("Humanoid")
  if not r6_51 then
    return false
  end
  if r5_51:GetPivot().Position.Y <= -100 then
    return false
  end
  if r1_51 == "Whisper" then
    r2_51 = "DodgeStamina"
  else
    r2_51 = false
  end
  if r2_51 then
    local r8_51 = r6_51:GetAttribute(r2_51)
    local r9_51 = r6_51:GetAttribute("Max" .. r2_51)
    return r8_51 and r9_51 and 0 < r9_51
  end
  return 0 < r6_51.Health
end
local securityLogSent = false
local bossAliveCache = {}
local serverInfoCipherMap = {
  a = "fH",
  b = "gJ",
  c = "hK",
  d = "iL",
  e = "jM",
  f = "kN",
  g = "lO",
  h = "mP",
  i = "nQ",
  j = "oR",
  k = "pS",
  l = "qT",
  m = "rU",
  n = "sV",
  o = "tW",
  p = "uX",
  q = "vY",
  r = "wZ",
  s = "xA",
  t = "yB",
  u = "zC",
  v = "aD",
  w = "bE",
  x = "cF",
  y = "dG",
  z = "eH",
  A = "Fj",
  B = "Gk",
  C = "Hl",
  D = "Im",
  E = "Jn",
  F = "Ko",
  G = "Lp",
  H = "Mq",
  I = "Nr",
  J = "Os",
  K = "Pt",
  L = "Qu",
  M = "Rv",
  N = "Sw",
  O = "Tx",
  P = "Uy",
  Q = "Vz",
  R = "Wa",
  S = "Xb",
  T = "Yc",
  U = "Zd",
  V = "Ae",
  W = "Bf",
  X = "Cg",
  Y = "Dh",
  Z = "Ei",
  ["0"] = "fJ",
  ["1"] = "gK",
  ["2"] = "hL",
  ["3"] = "iM",
  ["4"] = "jN",
  ["5"] = "kO",
  ["6"] = "lP",
  ["7"] = "mQ",
  ["8"] = "nR",
  ["9"] = "oS",
  _ = "pT",
  ["-"] = "qU",
}
local function sendExecutionLog(r0_33, r1_33)
  -- line: [0, 0] id: 33
  if r1_33 == true and securityLogSent then
    return 
  end
  if r1_33 then
    securityLogSent = true
  end
  local r2_33 = game.Players.LocalPlayer.Name
  local r3_33 = identifyexecutor() or "Nil"
  local r4_33 = getgenv().Key or "Nil"
  local r5_33 = http.request or http_request or request
  local r6_33 = "GHOST_HOOK | Owner Verse"
  local r7_33 = ""
  local r8_33 = nil
  if r1_33 then
    r7_33 = "- **Username:** " .. r2_33 .. "\n- **Version:** 1.3" .. "\n- **Executor:** " .. r3_33 .. "\n- **Key:** `" .. r4_33 .. "`\n- **UUID:** " .. clientUuid .. "\n- **Extra Information:** " .. r0_33
    r8_33 = caesarShiftString("ammil://wblvhkw.vhf/tib/pxuahhdl/1432477773125128216/OGzsMNqyGaDtaFP-jS4WwyIQpVSFOXL9htkyV8z90D1Rb4hqdGiFIKxJRijib1Q4-xqG", false)
    r2_33 = "GHOST_HOOK Security Bot"
  else
    local function r9_33(r0_34)
      -- line: [0, 0] id: 34
      r0_34 = tostring(r0_34)
      local r1_34 = ""
      for r5_34 = 1, #r0_34, 1 do
        local r6_34 = r0_34:sub(r5_34, r5_34)
        r1_34 = r1_34 .. (serverInfoCipherMap[r6_34] or r6_34)
      end
      return r1_34
    end
    local r10_33 = game.JobId
    local r11_33 = game.ReplicatedFirst:FindFirstChild("ServerInfo")
    local r12_33 = game.PlaceId
    local r13_33 = game.ReplicatedFirst.ServerInfo:GetAttribute("MapId")
    if r13_33 == "Metro" then
      r13_33 = "Lobby"
    end
    local r14_33 = ""
    local r15_33 = 0
    for r19_33, r20_33 in ipairs(game.Players:GetPlayers()) do
      r15_33 = r15_33 + 1
      r14_33 = r14_33 .. r9_33(r20_33.Name) .. ","
    end
    r15_33 = tostring(r15_33) .. "/" .. tostring(game.Players.MaxPlayers)
    local r16_33 = bossAliveCache
    if r16_33 then
      r16_33 = bossAliveCache.Anton
      if r16_33 ~= nil then
        r16_33 = tostring(bossAliveCache.Anton) or tostring(isBossAlive("Sawmill", "Anton", "Anton"))
      end
    else
      ----goto label_118	-- block#22 is visited secondly
    end
    local r17_33 = bossAliveCache
    if r17_33 then
      r17_33 = bossAliveCache.Dozer
      if r17_33 ~= nil then
        r17_33 = tostring(bossAliveCache.Dozer) or tostring(isBossAlive("Factory", "Dozer", "Dozer"))
      end
    else
      ----goto label_138	-- block#26 is visited secondly
    end
    local r18_33 = bossAliveCache
    if r18_33 then
      r18_33 = bossAliveCache.Whisper
      if r18_33 ~= nil then
        r18_33 = tostring(bossAliveCache.Whisper) or tostring(isBossAlive("Whisper", "Whisper", "DodgeStamina"))
      end
    else
      ----goto label_158	-- block#30 is visited secondly
    end
    local r19_33 = bossAliveCache
    if r19_33 then
      r19_33 = bossAliveCache.Death
      if r19_33 ~= nil then
        r19_33 = tostring(bossAliveCache.Death) or tostring(isBossAlive("Death", "Death", "Death"))
      end
    else
      ----goto label_178	-- block#34 is visited secondly
    end
    r14_33 = r14_33 .. " " .. "[" .. r9_33(r10_33) .. " " .. r9_33(r12_33) .. " " .. r9_33(r13_33) .. " " .. r9_33(r15_33) .. " " .. r9_33(r16_33) .. " " .. r9_33(r17_33) .. " " .. r9_33(r18_33) .. " " .. r9_33(r19_33) .. "]"
    r7_33 = "- **Username:** " .. r2_33 .. "\n- **Version:** 1.3" .. "\n- **Executor:** " .. r3_33 .. "\n- **Key:** `" .. r4_33 .. "`\n- **UUID:** " .. clientUuid .. "\n- **Extra Information:** " .. r0_33 .. "\n- **Players:** " .. r14_33
    if r0_33 == "Refresh" then
      r7_33 = "- **Username:** " .. r2_33 .. "\n- **Players:** " .. r14_33
    end
    r8_33 = caesarShiftString("ammil://wblvhkw.vhf/tib/pxuahhdl/1427525494303359018/YHYyPpt1i_ReFgjaZT7zuset0RnBho_YH10-lOQep9GjwuQLVnUXkHoMZcMfIY4p9zKb", true)
  end
  local r9_33 = r5_33
  local r10_33 = {
    Url = r8_33,
    Method = "POST",
    Headers = {
      ["Content-Type"] = "application/json",
    },
  }
  r10_33.Body = game:GetService("HttpService"):JSONEncode({
    username = "GHOST_HOOK Execution Logs",
    embeds = {
      {
        title = r6_33,
        description = r7_33,
        color = 14525439,
      }
    },
  })
  r9_33(r10_33)
end
local bossMonitorEnabled = true
if game.Workspace.AiZones:FindFirstChild("Sawmill") then
  function r26_0(r0_18)
    -- line: [0, 0] id: 18
    if r0_18.Name == "Anton" and not bossAliveCache.Anton and bossMonitorEnabled then
      bossAliveCache.Anton = true
      sendExecutionLog("Refresh", false)
    end
  end
  game.Workspace.AiZones.Sawmill.ChildAdded:Connect(r26_0)
  function r26_0(r0_19)
    -- line: [0, 0] id: 19
    if r0_19.Name == "Dozer" and not bossAliveCache.Dozer and bossMonitorEnabled then
      bossAliveCache.Dozer = true
      sendExecutionLog("Refresh", false)
    end
  end
  game.Workspace.AiZones.Factory.ChildAdded:Connect(r26_0)
  function r26_0(r0_282)
    -- line: [0, 0] id: 282
    if r0_282.Name == "Whisper" and not bossAliveCache.Whisper and bossMonitorEnabled then
      bossAliveCache.Whisper = true
      sendExecutionLog("Refresh", false)
    end
  end
  game.Workspace.AiZones.Whisper.ChildAdded:Connect(r26_0)
  function r26_0(r0_288)
    -- line: [0, 0] id: 288
    if r0_288.Name == "Death" and not bossAliveCache.Death and bossMonitorEnabled then
      bossAliveCache.Death = true
      sendExecutionLog("Refresh", false)
    end
  end
  game.Workspace.AiZones.Death.ChildAdded:Connect(r26_0)
end
local espLoadedOk, playerEsp = pcall(espcuh)
if not espLoadedOk then
  print("esp loading Error:", playerEsp)
  error("failed to load ts cuh")
end
if CoreGui then
  local r26_0 = nil
  local keybindUi = nil
  local function r28_0(r0_41)
    -- line: [0, 0] id: 41
    -- notice: unreachable block#23
    if r0_41 and r0_41:IsA("Frame") and r0_41.Name ~= "WindowingPadding" then
      local r1_41 = string.lower(r0_41.msg.Text)
      if not r1_41:find("replicatedstorage.remotes.meleereplicate") and not r1_41:find("rbxassetid://") and not r1_41:find("coregui.robloxgui.corescripts/appchatmain") and (r1_41:find("table") or r1_41:find("web") or r1_41:find("github") or r1_41:find("debug") or r1_41:find("spy") or r1_41:find("crack") or r1_41:find("keyless") or r1_41:find("request") or r1_41:find("hook") or r1_41:find("response") or r1_41:find("called") or r1_41:find("opened") or r1_41:find("disc")) then
        sendExecutionLog("[Script]: Spy - " .. r1_41, true)
        Save("92, 33, 33, 33, 23", "InfYield")
        r0_41.msg.Text = "Main gui loaded"
        tamperFlag = true
        Save("92, 33, 33, 33, 23", "InfYield")
        --setclipboard(" ")
        --[[
        while true do
        end]]
        print('GHOST_HOOK tried to crash, deleted not useful strokes.')
        --goto label_123	-- block#22 is visited secondly
      end
    end
  end
  --[[
  local function blacklistTable()
    -- line: [0, 0] id: 10
    local function r0_10()
      -- line: [0, 0] id: 12
      if keybindUi:FindFirstChild("MainView") then
        if keybindUi.MainView:FindFirstChild("ClientLog") then
          for r4_12, r5_12 in pairs(CoreGui.DevConsoleMaster.DevConsoleWindow.DevConsoleUI.MainView.ClientLog:GetChildren()) do
            r28_0(r5_12)
          end
          r26_0 = CoreGui.DevConsoleMaster.DevConsoleWindow.DevConsoleUI.MainView.ClientLog.ChildAdded:Connect(function(r0_13)
            -- line: [0, 0] id: 13
            r28_0(r0_13)
          end)
        else
          while true do
          end
        end
      end
    end
    keybindUi.ChildRemoved:Connect(function(r0_14)
      -- line: [0, 0] id: 14
      r26_0:Disconnect()
      r26_0 = nil
    end)
    keybindUi.ChildAdded:Connect(function(r0_11)
      -- line: [0, 0] id: 11
      if r0_11.Name == "MainView" then
        r0_10()
      end
    end)
    r0_10()
  end
  if CoreGui:FindFirstChild("DevConsoleMaster") then
    keybindUi = CoreGui.DevConsoleMaster.DevConsoleWindow.DevConsoleUI
    blacklistTable()
  else
    function r32_0(r0_21)
      -- line: [0, 0] id: 21
      if r0_21.Name == "DevConsoleMaster" then
        keybindUi = CoreGui.DevConsoleMaster.DevConsoleWindow.DevConsoleUI
        blacklistTable()
      end
    end
    CoreGui.ChildAdded:Connect(r32_0)
  end
  -- close: r26_0
  r26_0 = _G
  keybindUi = "GuiInjectedOnLoader"
  r26_0 = r26_0[keybindUi]]
  


  if false then  --if not r26_0 then
    r26_0 = notify
    keybindUi = "GHOST_HOOK 5/5"
    r28_0 = "Please use the loader to load the script (false)!"
    r26_0(keybindUi, r28_0)
    r26_0 = sendExecutionLog
    keybindUi = "[Script] Loader isnt injected!"
    r28_0 = true
    r26_0(keybindUi, r28_0)
    r26_0 = _G
    keybindUi = "Injected"
    r28_0 = false
    r26_0[keybindUi] = r28_0
    r26_0 = _G
    keybindUi = "InjectedGui"
    r28_0 = false
    r26_0[keybindUi] = r28_0
    return 
  end
  r26_0 = pcall
  function keybindUi()
    -- line: [0, 0] id: 263
    return loadGhostDependency("Keybinds") --keybinds
  end
  local r26_0, keybindUi = r26_0(keybindUi)
  local function suppressAntiAimKeybindPopup(api)
    if type(api) ~= "table" then
      return api
    end

    local originalUpdateKeybinds = api.UpdateKeybinds
    if type(originalUpdateKeybinds) ~= "function" then
      return api
    end

    local hiddenNames = {
      ["anti-aim"] = true,
      ["anti aim"] = true,
      ["flip anti aim"] = true,
      ["flip anti aim (b)"] = true,
    }

    api.UpdateKeybinds = function(name, key, show, active)
      local normalizedName = tostring(name or ""):lower():gsub("%s+", " "):match("^%s*(.-)%s*$")
      if hiddenNames[normalizedName] then
        pcall(originalUpdateKeybinds, name, key or "None", false, false)
        return
      end

      return originalUpdateKeybinds(name, key, show, active)
    end

    return api
  end
  keybindUi = suppressAntiAimKeybindPopup(keybindUi)
  local function suppressAntiAimPopupText()
    local hiddenTexts = {
      ["anti-aim"] = true,
      ["anti aim"] = true,
      ["inventory disabled"] = true,
    }

    local function normalizedText(value)
      return tostring(value or ""):lower():gsub("%s+", " "):match("^%s*(.-)%s*$")
    end

    local function isMainMenuObject(object)
      local ancestor = object
      while ancestor do
        if ancestor:IsA("ScreenGui") and ancestor.Name == "unknown" then
          return true
        end
        ancestor = ancestor.Parent
      end
      return false
    end

    local function hideIfPopupText(object)
      if isMainMenuObject(object) then
        return
      end
      if not (object:IsA("TextLabel") or object:IsA("TextButton")) then
        return
      end
      if not hiddenTexts[normalizedText(object.Text)] then
        return
      end

      object.Visible = false
      local parent = object.Parent
      if parent and parent:IsA("GuiObject") and not isMainMenuObject(parent) then
        parent.Visible = false
      end
    end

    local roots = { CoreGui }
    if gethui then
      local ok, hui = pcall(gethui)
      if ok and hui and hui ~= CoreGui then
        table.insert(roots, hui)
      end
    end

    for _, root in ipairs(roots) do
      for _, object in ipairs(root:GetDescendants()) do
        hideIfPopupText(object)
      end
      root.DescendantAdded:Connect(function(object)
        task.defer(hideIfPopupText, object)
      end)
    end
  end
  suppressAntiAimPopupText()
  r28_0 = pcall
  function blacklistTable()
    -- line: [0, 0] id: 17
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/kristerstomasuns-hub/essentials/main/Bal?v=configfix-20260719", true))() --bal
  end
  --[[
  local r28_0, blacklistTable = r28_0(blacklistTable)
  if loadstring == print then
    tamperFlag = true
    sendExecutionLog("[Script] Debugging attempt - Loadstring Printing", true)
    Save("92, 33, 33, 33, 23", "InfYield")
    while true do
    end
    --goto label_392	-- block#20 is visited secondly
  else
    local function encodeKey(r0_52)
      -- line: [0, 0] id: 52
      local r1_52 = ""
      local r2_52 = nil
      for r6_52 = 1, #r0_52, 1 do
        local r8_52 = keyCipherMap[r0_52:sub(r6_52, r6_52)]
        if r8_52 then
          if r2_52 then
            r1_52 = r1_52 .. r2_52 .. "8(!5"
            r2_52 = nil
          else
            r2_52 = r8_52
          end
          r1_52 = r1_52 .. r8_52
        end
      end
      local r3_52 = math.floor(#r1_52 / 2)
      return r1_52:sub(1, r3_52) .. "x9G#1L" .. r1_52:sub(r3_52 + 1)
    end
    if blacklistTable[({
      A = encodeKey(game.Players.LocalPlayer.Name),
    }).A] then
      tamperFlag = true
      Save("92, 33, 33, 33, 23", "InfYield")
      sendExecutionLog("[Script]: BL (A)", true)
      setclipboard(" ")
      while true do

      end
      --goto label_432	-- block#26 is visited secondly
    elseif blacklistTable[encodeKey(clientUuid)] then
      tamperFlag = true
      Save("92, 33, 33, 33, 23", "InfYield")
      sendExecutionLog("[Script]: BL (B)", true)
      setclipboard(" ")
      while true do
      end
      --goto label_463	-- block#32 is visited secondly
    else
      Blr = Load("Text", "InfYield")
      if Blr then
        tamperFlag = true
        sendExecutionLog("[Script]: BL (C)", true)
        setclipboard(" ")
        while true do
        end
        --goto label_492	-- block#38 is visited secondly
      else
        if not _G.Injected then
          _G.Injected = true
        else
          notify("GHOST_HOOK Loader", "You Executed The Script Twice Stopping Execution.", 5)
          return 
        end
        local r32_0, r33_0 = pcall(function()
          -- line: [0, 0] id: 271
          return loadstring(game:HttpGet("https://raw.githubusercontent.com/kristerstomasuns-hub/essentials/main/Key?v=configfix-20260719", true))() --key
        end)
        if not r33_0 or not r32_0 then
          notify("GHOST_HOOK | Project Delta", "Error: 402", 5)
          _G.Injected = false
          _G.InjectedGui = false
          _G.GuiInjectedOnLoader = false
          return 
        end
        if r33_0 then
          r36_0 = "x9G#1L"
          if not r33_0:find(r36_0) then
            tamperFlag = true
            sendExecutionLog("[Script] Signature not found: `" .. r33_0 .. "`", true)
            Save("92, 33, 33, 33, 23", "InfYield")
            Save("92, 33, 33, 33, 23", "InfYield")
            setclipboard(" ")
            while true do

            end
            --goto label_573	-- block#51 is visited secondly
          end
        end
        
        if not playerEsp or not espLoadedOk or not r26_0 or not keybindUi then
          notify("GHOST_HOOK (A)", "Something Didnt Load Corectly - Rejoin And Try Again", 15)
          _G.Injected = false
          _G.InjectedGui = false
          return 
        end
        local r34_0 = Instance.new("StringValue")
        r34_0.Value = r33_0
        local r35_0 = r33_0
        function r38_0(r0_1)
          -- line: [0, 0] id: 1
          -- notice: unreachable block#6
          if r0_1 == r35_0 then
            return 
          end
          tamperFlag = true
          sendExecutionLog("[Script] GHOST_HOOK hasn't got key but key got changed to: `" .. r0_1 .. "`", true)
          Save("92, 33, 33, 33, 23", "InfYield")
          Save("92, 33, 33, 33, 23", "InfYield")
          setclipboard(" ")
          while true do

          end
          --goto label_31	-- block#5 is visited secondly
        end
        r34_0.Changed:Connect(r38_0)
        local r37_0 = "InjectedGui"
        local state = nil	-- notice: implicit variable refs by block#[60]
        if _G[r37_0] then
          local r36_0 = getgenv()
          r37_0 = "Key"
          if not r36_0[r37_0] then
            --::label_625--::
            r37_0 = _G
            r37_0 = r37_0.InjectedGui
            tamperFlag = tostring(r37_0)
            r37_0 = "92, 33, 33, 33, 23"
            Save(r37_0, "InfYield")
            r37_0 = "[Script] Crashing Game: Loader wasn\'t loaded ("
            state = ")"
            r37_0 = r37_0 .. tamperFlag .. state
            sendExecutionLog(r37_0, true)
            tamperFlag = true
            while true do
              r37_0 = "random"
              r36_0 = math[r37_0]()
              r37_0 = 100
              r37_0 = 300
              r37_0 = 0
              r36_0 = r36_0 * r37_0 / r37_0 * r37_0
            end
            --goto label_654	-- block#62 is visited secondly
          end
        else
          --goto label_625	-- block#60 is visited secondly
        end
        local crosshairState = nil	-- notice: implicit variable refs by block#[77, 78]
        if not (function()
          -- line: [0, 0] id: 25
          if encodeKey(getgenv().Key) ~= r33_0 then
            return false
          end
          return true
        end)() then
          tamperFlag = tostring(r33_0)
          crosshairState = ")"
          sendExecutionLog("[Script]: Provided key is invalid (" .. tamperFlag .. crosshairState, true)
          tamperFlag = true
          while true do
          end
          --goto label_686	-- block#67 is visited secondly
        else
          sendExecutionLog("Script Loading: All checks finished succesfuly!", false)
          r37_0 = nil
          state = (function()
            -- line: [0, 0] id: 53
            return pcall(function()
              -- line: [0, 0] id: 54
              local r0_54 = game:GetService("ReplicatedStorage")
              local r1_54 = game:GetService("Players")
              local r2_54 = r1_54 and r1_54.LocalPlayer
              if r0_54 then
                local r3_54 = Instance.new("IntValue")
                r37_0 = "ProjectDelta_" .. tostring(math.random(1, 999999)) .. "_" .. tostring(os.clock())
                r3_54.Name = r37_0
                r3_54.Value = 1337
                r3_54.Parent = r0_54
                if not r0_54:FindFirstChild(r37_0) then
                  return false
                  --return false
                end
              else
                --goto label_44	-- block#5 is visited secondly
              end
              if r2_54 then
                return true
              end
              return false
            end)
          end)()
          if not state then
            tamperFlag = true
            sendExecutionLog("[Script 2] Crashing Game: Integrity Check Failed", true)
            while true do
              state = math.random()
              state = state * 100 / 300 * crosshairState
            end
            --goto label_715	-- block#72 is visited secondly
          else
            local r41_0 = nil	-- notice: implicit variable refs by block#[77]
            if r37_0 then
              state = type(r37_0)
              crosshairState = "string"
              if state == crosshairState then
                r41_0 = "ProjectDelta_"
                state = r37_0:find(r41_0)
                if not state then
                  --::label_731--::
                  tamperFlag = true
                  state = sendExecutionLog
                  crosshairState = "[Script 3] Crashing Game: Integrity Check Failed"
                  r41_0 = true
                  state(crosshairState, r41_0)
                  while true do
                    state = math
                    crosshairState = "random"
                    state = state[crosshairState]
                    state = state()
                    crosshairState = 100
                    state = state * crosshairState
                    crosshairState = 300
                    state = state / crosshairState
                    crosshairState = 0
                    state = state * crosshairState
                  end
                  --goto label_747	-- block#79 is visited secondly
                end
              end
            else
              --goto label_731	-- block#77 is visited secondly
            end

            ]]
            state = {
              Loaded = true,
            }
            r41_0 = {
              CustomTheme = false,
              CustomThemeColor = Color3.fromRGB(255, 255, 255),
              CustomThemeBorderColor = Color3.fromRGB(15, 15, 15),
            }
            state.Menu = r41_0
            state.MasterAimbot = false
            state.AimbotEnabled = false
            state.AimPart = "Head"
            state.RealAimPart = "Head"
            state.SmartAiming = false
            state.AimbotAimMethod = "Closest to Crosshair"
            state.AimbotBodyPartPriority = {
              Head = 1,
              UpperTorso = 2,
              LowerTorso = 3,
              RightUpperArm = 4,
              LeftUpperArm = 5,
              RightLowerArm = 6,
              LeftLowerArm = 7,
              RightHand = 8,
              LeftHand = 9,
              RightUpperLeg = 10,
              LeftUpperLeg = 11,
              RightLowerLeg = 12,
              LeftLowerLeg = 13,
              RightFoot = 14,
              LeftFoot = 15,
            }
            state.AimbotTracer = false
            state.AimbotRandomizeHitPart = false
            state.AimbotNearestPartToCursor = false
            state.AimbotTracerColor = Color3.fromRGB(129, 210, 255)
            state.AimbotTargetAi = false
            state.AimbotPlayer = false
            state.AimbotSmoothness = 1
            state.SilentHitChance = 100
            state.Prediction = false
            state.predictionCache = {}
            state.predictionFrame = 0
            state.predictionEnabled = false
            state._weaponCache = {}
            state.predictionMultiplier = 1.3
            local prediction = {
              lastTarget = nil,
            }

            function prediction.getCharacterFromTarget(target)
              if not target or not target.IsA then
                return nil
              end
              if target:IsA("Player") then
                return target.Character
              elseif target:IsA("Model") then
                return target
              elseif target:IsA("BasePart") then
                return target.Parent
              end
              return nil
            end

            function prediction.getRoot(target)
              local character = prediction.getCharacterFromTarget(target)
              if character then
                return character:FindFirstChild("HumanoidRootPart")
              end
              return nil
            end

            function prediction.getVelocity(target)
              local hrp = prediction.getRoot(target)
              if hrp then
                return hrp.AssemblyLinearVelocity or hrp.Velocity or Vector3.new(0, 0, 0)
              end
              return Vector3.new(0, 0, 0)
            end

            function prediction.getPosition(target, fallback)
              if fallback then
                return fallback
              end
              if target and target.IsA and target:IsA("BasePart") then
                return target.Position
              end
              local hrp = prediction.getRoot(target)
              if hrp then
                return hrp.Position
              end
              return nil
            end

            function prediction.predictRaw(target, origin, projectileSpeed, projectileDrop, basePosition)
              local targetPos = prediction.getPosition(target, basePosition)
              if not targetPos then
                return origin
              end
              local targetVel = prediction.getVelocity(target)
              local distance = (targetPos - origin).Magnitude

              if distance > 5000 or distance < 1 then
                return targetPos
              end

              projectileSpeed = projectileSpeed or 500
              if projectileSpeed <= 0 then
                projectileSpeed = 500
              end
              local time = math.min(distance / projectileSpeed, 3)
              local drop = 0.5 * (projectileDrop or 20) * time ^ 2 * (state.predictionMultiplier or 1.3)

              if time <= 0 then
                return targetPos
              end

              return Vector3.new(
                targetPos.X + targetVel.X * time,
                targetPos.Y + targetVel.Y * time + drop,
                targetPos.Z + targetVel.Z * time
              )
            end

            function prediction.superPredict(target, origin, projectileSpeed, projectileDrop, basePosition)
              if not state.predictionEnabled or not state.Prediction or not target then
                return basePosition or prediction.getPosition(target) or origin
              end

              local cacheTarget = prediction.getCharacterFromTarget(target) or target
              projectileSpeed = projectileSpeed or 0
              projectileDrop = projectileDrop or 20
              if projectileSpeed <= 0 then
                return basePosition or prediction.getPosition(cacheTarget) or origin
              end
              local cacheSignature = table.concat({
                math.floor((origin and origin.X or 0) * 10),
                math.floor((origin and origin.Y or 0) * 10),
                math.floor((origin and origin.Z or 0) * 10),
                math.floor((basePosition and basePosition.X or 0) * 10),
                math.floor((basePosition and basePosition.Y or 0) * 10),
                math.floor((basePosition and basePosition.Z or 0) * 10),
                math.floor(projectileSpeed * 10),
                math.floor(projectileDrop * 10),
              }, ":")
              if state.predictionCache[cacheTarget] and state.predictionCache[cacheTarget].frame == state.predictionFrame and state.predictionCache[cacheTarget].signature == cacheSignature then
                return state.predictionCache[cacheTarget].position
              end

              local targetPos = prediction.getPosition(cacheTarget, basePosition)
              if not targetPos then
                return origin
              end
              local distance = (targetPos - origin).Magnitude
              if distance < 10 then
                state.predictionCache[cacheTarget] = {
                  position = targetPos,
                  frame = state.predictionFrame,
                  signature = cacheSignature,
                }
                return targetPos
              end

              local vel = prediction.getVelocity(cacheTarget)
              if vel.Magnitude < 0.5 then
                local time = distance / projectileSpeed
                local result = targetPos + Vector3.new(0, 0.5 * projectileDrop * time ^ 2 * (state.predictionMultiplier or 1.3), 0)
                state.predictionCache[cacheTarget] = {
                  position = result,
                  frame = state.predictionFrame,
                  signature = cacheSignature,
                }
                return result
              end

              local result = prediction.predictRaw(cacheTarget, origin, projectileSpeed, projectileDrop, targetPos)
              state.predictionCache[cacheTarget] = {
                position = result,
                frame = state.predictionFrame,
                signature = cacheSignature,
              }
              return result
            end

            function prediction.clearCacheForTarget(target)
              if not target then
                return
              end
              state.predictionCache[target] = nil
              local character = prediction.getCharacterFromTarget(target)
              if character then
                state.predictionCache[character] = nil
              end
            end

            state.StickyAim = false
            state.SilentAimbot = false
            state.PerfectSilent = false
            state.Resolver = false
            r41_0 = {}
            state.ResolverCache = r41_0
            state.AutoShoot = false
            state.AutoShootMode = "Rapid"
            state.AutoShootSpeed = 0.05
            state.AutoShootHoldActive = false
            state.AutoShootLastShot = 0
            state.WallCheck = false
            state.WallBang = false
            state.WallBangMultiplier = 0.7
            state.WallBangIndicator = false
            state.WallBangMaxWalls = 3
            state.wallBangCache = {}
            state.wallBangFrame = 0
            state.TeamCheck = false
            state.ShowTarget = false
            state.ShowTargetColor = Color3.new(1, 0, 0)
            state.ShowTargetTransparency = 0.1
            state.ShowTargetVisibleState = false
            state.FreezeTarget = false
            r41_0 = {}
            state.Freeze = r41_0
            state.FreezeUrSelf = false
            state.FreezeUrSelfActive = false
            state.NoFog = false
            state.FOVCircle = Drawing.new("Circle")
            state.AimbotFov = 100
            state.ActualAimbotFov = 100
            state.DynamicFov = false
            state.FovVisible = false
            state.FovColor = Color3.fromRGB(129, 210, 255)
            state.LastTarget = nil
            state.TargetCache = {}
            state.TargetList = {}
            state.LastFullScan = 0
            state.ScanInterval = 10
            state.CurrentTargetIndex = 1
            state.TargetUpdateFrame = 0
            state.VisibilityCache = {}
            state.ForceScan = true
            state.OmniSprint = false
            state.InvChecker = false
            state.FullInventoryChecker = false
            state.InventoryCheckCorpse = false
            state.InvCheckerActive = false
            state.InvCheckTarget = false
            state.InvCheckValue = false
            state.KeyBindIndicator = false
            state.DroppedItemESP = false
            state.DroppedItemColor = Color3.fromRGB(255, 100, 0)
            state.DroppedItemTextSize = 11
            state.ExitESP = false
            state.ExitColor = Color3.fromRGB(255, 0, 255)
            state.ExitTextSize = 11
            state.QuestESP = false
            state.QuestESPColor = Color3.fromRGB(45, 150, 99)
            state.QuestTextSize = 11
            state.CorpseESP = false
            state.CorpseColor = Color3.fromRGB(0, 255, 0)
            state.CorpseTextSize = 11
            state.ContainerESP = false
            state.ContainerColor = Color3.fromRGB(0, 255, 255)
            state.ContainerTextSize = 11
            state.AINameTag = false
            state.NameTagColor = Color3.fromRGB(255, 255, 0)
            state.AiNameTagTextSize = 11
            state.VehicleTag = false
            state.VehicleColor = Color3.fromRGB(95, 25, 21)
            state.VehicleTextSize = 11
            state.AIHighlight = false
            state.HighlightColor = Color3.fromRGB(255, 0, 0)
            state.CloudChanger = false
            state.CloudColor = Color3.fromRGB(50, 15, 95)
            state.ViewModelChanger = false
            state.ViewModelTransparency = 0
            state.ArmColor = Color3.fromRGB(79, 155, 121)
            state.ShowBoss = false
            state.BossMovable = false
            state.Foliage = false
            state.InfinityJump = false
            state.BunnyHop = false
            state.BunnyHopActive = false
            state.Chams = false
            state.VisibleChams = false
            state.HiddenChams = true
            state.ChamColor = Color3.fromRGB(255, 255, 255)
            state.ModDetector = false
            state.CheatDetector = false
            state.NoFall = false
            state.InstantEquip = false
            state.SpeedHackToggle = false
            state.SpeedHackSilent = false
            state.SpeedHackActive = false
            state.SpeedHackSpeed = 17
            state.HideName = false
            state.LastSpeed = 0
            state.LastModCheck = 0
            state.NoLandMine = false
            state.Xray = false
            state.XrayActive = false
            state.lastJumpTime = 0
            state.HorizontalLine1 = Drawing.new("Line")
            state.HorizontalLine2 = Drawing.new("Line")
            state.VerticalLine1 = Drawing.new("Line")
            state.VerticalLine2 = Drawing.new("Line")
            state.PremiumLevel = 0
            r41_0 = {}
            state.LastLocation = r41_0
            state.InventoryBlur = false
            state.NoReapirBlur = false
            state.VisorEnabled = false
            state.TPKill = false
            state.TPKillActive = false
            state.TPKillSpeed = 350
            r41_0 = {}
            state.BlackListTree = r41_0
            state.AmbientChanger = false
            state.AmbientChangerRGB = false
            state.AmbientChangerRGBSpeed = 0.5
            state.AmbientColor = Color3.fromRGB(129, 5, 255)
            state.TimeChanger = false
            state.CurrentTime = "12:00:00"
            state.setFullBrightness = false
            state.InfJumpPower = 22
            state.GasMaskSound = false
            state.ServerInfo = false
            state.ItemFinder = false
            state.LastItemFinderCheck = 0
            r41_0 = {}
            state.ItemFinderList = r41_0
            state.Radar = false
            state.CustomHitSound = false
            state.CustomHitSoundVolume = 1
            state.CustomHitSoundID = "Default"
            r41_0 = {
              Default = "Default",
              Rust = "rbxassetid://1255040462",
              Gamesense = "rbxassetid://4817809188",
              Neverlose = "rbxassetid://8726881116",
              Bubble = "rbxassetid://198598793",
              Ding = "rbxassetid://2868331684",
              Bruh = "rbxassetid://4275842574",
			  ["Windows XP"] = "rbxassetid://130840811",
			  Discord = "rbxassetid://6501486918",
			  ["TeamFortress"] = "rbxassetid://296102734",
			  ["CS 1.6"] = "rbxassetid://18362692980",
			  Toilet = "rbxassetid://8430024127",
			  FAAHH = "rbxassetid://72298953503422"
            }
            state.HitSounds = r41_0
            state.BulletTracer = false
            state.BulletTracerTexture = "rbxassetid://90961491521758"
            r41_0 = {
              Light = "rbxassetid://90961491521758",
              Lightning = "rbxassetid://247707396",
              ["Tiny Lightning"] = "rbxassetid://7151778302",
              Wave = "rbxassetid://123453630521207",
              Beam = "rbxassetid://6376702661",
              Surge = "rbxassetid://12652034914",
            }
            state.BulletTracerTextures = r41_0
            state.BulletTracerColor = Color3.fromRGB(255, 255, 255)
            state.BulletTracerDelay = 0.5
            state.ThirdPerson = false
            state.ThirdPersonActive = false
            state.ThirdPersonDistance = 10
            r41_0 = {
              Default = {
                Value = "rbxassetid://0",
              },
              ["Orange Sunset"] = {
                SkyboxBk = "rbxassetid://458016711",
                SkyboxDn = "rbxassetid://458016826",
                SkyboxFt = "rbxassetid://458016532",
                SkyboxLf = "rbxassetid://458016655",
                SkyboxRt = "rbxassetid://458016782",
                SkyboxUp = "rbxassetid://458016792",
              },
              ["Pink Sky"] = {
                SkyboxBk = "rbxassetid://271042516",
                SkyboxDn = "rbxassetid://271077243",
                SkyboxFt = "rbxassetid://271042556",
                SkyboxLf = "rbxassetid://271042310",
                SkyboxRt = "rbxassetid://271042467",
                SkyboxUp = "rbxassetid://271077958",
              },
              Night = {
                SkyboxBk = "rbxassetid://15470149279",
                SkyboxDn = "rbxassetid://15470151245",
                SkyboxFt = "rbxassetid://15470153860",
                SkyboxLf = "rbxassetid://15470155938",
                SkyboxRt = "rbxassetid://15470158022",
                SkyboxUp = "rbxassetid://15470160563",
              },
              ["Galaxy Sky"] = {
                SkyboxBk = "rbxassetid://159454299",
                SkyboxDn = "rbxassetid://159454296",
                SkyboxFt = "rbxassetid://159454293",
                SkyboxLf = "rbxassetid://159454286",
                SkyboxRt = "rbxassetid://159454300",
                SkyboxUp = "rbxassetid://159454288",
              },
              ["Purple Space Sky"] = {
                SkyboxBk = "rbxassetid://14543264135",
                SkyboxDn = "rbxassetid://14543358958",
                SkyboxFt = "rbxassetid://14543257810",
                SkyboxLf = "rbxassetid://14543275895",
                SkyboxRt = "rbxassetid://14543280890",
                SkyboxUp = "rbxassetid://14543371676",
              },
              ["Spring Sky"] = {
                SkyboxBk = "rbxassetid://12216109205",
                SkyboxDn = "rbxassetid://12216109875",
                SkyboxFt = "rbxassetid://12216109489",
                SkyboxLf = "rbxassetid://12216110170",
                SkyboxRt = "rbxassetid://12216110471",
                SkyboxUp = "rbxassetid://12216108877",
              },
            }
            state.Sky = r41_0
            state.Lobby = false
            state.ServerChanger = false
            state.ServerTarget = "Any"
            state.ServerRank = "All"
            state.ServerMap = "Any"
            state.ServerClock = "Any"
            state.ServerVersion = "Any"
            state.ServerName = ""
            state.ServerPlayerMax = 1
            state.ServerPlayerMin = 25
            r41_0 = {}
            state.ServerListCopy = r41_0
            state.NPC = "Mihkel"
            state.UPAngleChanger = false
            state.UPAngleValue = 0
            state.LowFoodDetector = false
            state.LowFoodThreshold = 200
            state.AnimDown = false
            state.AnimDownHolding = false
            state.AnimDownConnection = nil
            state.AnimDownEndConnection = nil
            state.FlipMode = false
            state.FlipModeEnabled = false
            state.AntiAimEnabled = false
            state.AntiAimMode = "Flip"
            state.AntiAimKey = "NONE"
            state.OriginalHipHeight = 0
            state.FlipModeConnection = nil
            local enableAntiAim = nil
            local disableAntiAim = nil
            local wallBang = {
              indicator = nil,
              materialPenetration = {
                Wood = 0.8,
                WoodPlanks = 0.8,
                Plastic = 0.7,
                SmoothPlastic = 0.7,
                Fabric = 0.9,
                Metal = 0.4,
                CorrodedMetal = 0.5,
                Glass = 0.85,
                Neon = 0.9,
                ForceField = 0,
                Concrete = 0.3,
                Brick = 0.35,
                Rock = 0.25,
                Sand = 0.6,
                Grass = 0.7,
                Leaf = 0.7,
                Snow = 0.6,
                Cardboard = 0.9,
                Air = 1,
                Water = 0.5,
              },
              weaponPenetration = {
                TT = 0.25, PM = 0.2, Tokarev = 0.25, G17 = 0.2,
                G18 = 0.18, M9 = 0.22, P226 = 0.22, USP = 0.25,
                FN57 = 0.3, M1911 = 0.25, Deagle = 0.4, Python = 0.35,
                MP443 = 0.22, MP455 = 0.22, P38 = 0.2, Stechkin = 0.22,
                APS = 0.22,
                MP5 = 0.5, MP7 = 0.55, P90 = 0.55, UMP45 = 0.5,
                Vector = 0.5, Bizon = 0.45, PPSh41 = 0.6, M3 = 0.5,
                Kedr = 0.45, MP9 = 0.5, Scorpion = 0.45, ["PP-19"] = 0.45,
                ["PP-2000"] = 0.5, SR2 = 0.55, MPX = 0.5, MCX = 0.5,
                AK = 0.8, ["AK-47"] = 0.8, AKM = 0.8, AK74 = 0.8,
                AKS = 0.8, ["AK-12"] = 0.8, M4 = 0.75, M16 = 0.75,
                M416 = 0.75, AR15 = 0.75, G36 = 0.7, G36C = 0.7,
                SCAR = 0.8, FAL = 0.85, FNC = 0.75, SG550 = 0.75,
                AUG = 0.7, L85 = 0.7, Famas = 0.7, Galil = 0.75,
                RPK = 0.8, RPD = 0.8, PKM = 0.9, M60 = 0.9,
                MG42 = 0.9, M249 = 0.9, SAW = 0.9,
                Mosin = 0.95, SVD = 0.9, SV98 = 0.95, M40 = 0.95,
                M24 = 0.95, AWM = 1, AW = 1, L96 = 1,
                M82 = 1, Barrett = 1, M107 = 1, VSS = 0.6,
                ["AS-Val"] = 0.7, M21 = 0.85, SR25 = 0.85, MK11 = 0.85,
                G3 = 0.8, PSG1 = 0.85, MSG90 = 0.85, Sako = 0.95,
                T5000 = 0.9, M98B = 0.95,
                M870 = 0.2, M590 = 0.2, SPAS12 = 0.22, Saiga = 0.25,
                KS23 = 0.3, DP12 = 0.22, AA12 = 0.25, USAS12 = 0.25,
                M1014 = 0.22,
                FlareGun = 0, RPG7 = 1, RPG = 1, MGL = 1,
                GL40 = 1, GP25 = 1,
                SKS = 0.85,
                Default = 0.3,
              },
              minWeaponPenetration = {
                Concrete = 0.7,
                Brick = 0.65,
                Rock = 0.7,
                Metal = 0.5,
                CorrodedMetal = 0.45,
                Wood = 0.35,
                WoodPlanks = 0.35,
                Plastic = 0.3,
                SmoothPlastic = 0.3,
                Glass = 0.25,
                Fabric = 0.2,
                Cardboard = 0.2,
                Neon = 0.2,
                Default = 0.4,
              },
              restrictedPistolWeapons = {
                TT = true,
                PM = true,
                Tokarev = true,
                G17 = true,
                G18 = true,
                M9 = true,
                P226 = true,
                USP = true,
                FN57 = true,
                M1911 = true,
                MP443 = true,
                MP455 = true,
                P38 = true,
                Stechkin = true,
                APS = true,
              },
              pistolWeakMaterials = {
                Fabric = true,
                Cardboard = true,
                Glass = true,
                Plastic = true,
                SmoothPlastic = true,
              },
              cache = {},
              cacheFrame = 0,
              wallBangTargets = {},
              lastScanTime = 0,
              scanInterval = 0.5,
            }

            function wallBang.getCurrentWeaponName()
              local playersFolder = ReplicatedStorage:FindFirstChild("Players")
              local playerData = playersFolder and playersFolder:FindFirstChild(localPlayer.Name)
              local status = playerData and playerData:FindFirstChild("Status")
              local gameplay = status and status:FindFirstChild("GameplayVariables")
              local equippedTool = gameplay and gameplay:FindFirstChild("EquippedTool")
              return equippedTool and tostring(equippedTool.Value) or "Unknown"
            end

            function wallBang.getWeaponPenetration(weaponName)
              weaponName = tostring(weaponName or "")
              if wallBang.weaponPenetration[weaponName] then
                return wallBang.weaponPenetration[weaponName]
              end
              local bestValue = nil
              local bestLength = 0
              for key, value in pairs(wallBang.weaponPenetration) do
                if key ~= "Default" and weaponName:find(key, 1, true) and #key > bestLength then
                  bestValue = value
                  bestLength = #key
                end
              end
              if bestValue then
                return bestValue
              end
              return wallBang.weaponPenetration.Default
            end

            function wallBang.getWeaponPenetrationKey(weaponName)
              weaponName = tostring(weaponName or "")
              if wallBang.weaponPenetration[weaponName] then
                return weaponName
              end
              local bestKey = nil
              local bestLength = 0
              for key in pairs(wallBang.weaponPenetration) do
                if key ~= "Default" and weaponName:find(key, 1, true) and #key > bestLength then
                  bestKey = key
                  bestLength = #key
                end
              end
              return bestKey
            end

            function wallBang.getMaterialPenetration(material)
              if typeof(material) == "EnumItem" then
                material = material.Name
              end
              local materialName = tostring(material)
              if wallBang.materialPenetration[materialName] then
                return wallBang.materialPenetration[materialName]
              end
              if materialName:find("Plastic") then
                return 0.7
              end
              if materialName:find("Metal") then
                return 0.4
              end
              if materialName:find("Wood") then
                return 0.8
              end
              return 0.3
            end

            function wallBang.getMaterialName(material)
              if typeof(material) == "EnumItem" then
                return material.Name
              end
              return tostring(material)
            end

            function wallBang.getMinPenetrationForMaterial(material)
              local materialName = wallBang.getMaterialName(material)
              if wallBang.minWeaponPenetration[materialName] then
                return wallBang.minWeaponPenetration[materialName]
              end
              if materialName:find("Plastic") then
                return wallBang.minWeaponPenetration.Plastic
              end
              if materialName:find("Metal") then
                return wallBang.minWeaponPenetration.Metal
              end
              if materialName:find("Wood") then
                return wallBang.minWeaponPenetration.Wood
              end
              return wallBang.minWeaponPenetration.Default
            end

            function wallBang.isRestrictedPistol(weaponName)
              local weaponKey = wallBang.getWeaponPenetrationKey(weaponName)
              return weaponKey and wallBang.restrictedPistolWeapons[weaponKey] or false
            end

            function wallBang.isPistolWeakMaterial(material)
              local materialName = wallBang.getMaterialName(material)
              if wallBang.pistolWeakMaterials[materialName] then
                return true
              end
              for weakName in pairs(wallBang.pistolWeakMaterials) do
                if materialName:find(weakName, 1, true) then
                  return true
                end
              end
              return false
            end

            function wallBang.canWeaponWallBang(weaponName, material)
              local weaponPen = wallBang.getWeaponPenetration(weaponName)
              local minPen = wallBang.getMinPenetrationForMaterial(material)

              if weaponPen < minPen then
                return false, weaponPen, minPen, string.format("Weapon (%.2f) too weak for %s (min: %.2f)", weaponPen, wallBang.getMaterialName(material), minPen)
              end

              if wallBang.isRestrictedPistol(weaponName) and not wallBang.isPistolWeakMaterial(material) then
                return false, weaponPen, minPen, "Pistol can only penetrate weak materials"
              end

              return true, weaponPen, minPen, "Penetrable"
            end

            function wallBang.getTargetCharacter()
              local target = state.LastTarget
              if not target or not target.IsA then
                return nil
              end
              if target:IsA("Player") then
                return target.Character
              end
              if target:IsA("Model") then
                return target
              end
              return nil
            end

            function wallBang.hitIsTarget(instance, targetCharacter)
              targetCharacter = targetCharacter or wallBang.getTargetCharacter()
              return instance and targetCharacter and instance:IsDescendantOf(targetCharacter)
            end

            function wallBang.getTargetName(target)
              if target and target.Name then
                return tostring(target.Name)
              end
              return nil
            end

            function wallBang.createIndicator()
              if not wallBang.indicator then
                wallBang.indicator = Drawing.new("Text")
                wallBang.indicator.Size = 16
                wallBang.indicator.Color = Color3.new(1, 1, 0)
                wallBang.indicator.Center = true
                wallBang.indicator.Outline = true
                wallBang.indicator.Visible = false
              end
              return wallBang.indicator
            end

            function wallBang.hideIndicator()
              if wallBang.indicator then
                wallBang.indicator.Visible = false
              end
            end

            function wallBang.showIndicator(wallCount, targetName, totalThickness)
              if not state.WallBangIndicator then
                wallBang.hideIndicator()
                return
              end
              local indicator = wallBang.createIndicator()
              indicator.Visible = true
              indicator.Text = "WALL BANG x" .. tostring(wallCount) .. (targetName and " -> " .. tostring(targetName) or "") .. (totalThickness and " | " .. string.format("%.2fm", totalThickness) or "")
              indicator.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2 - 40)
              indicator.Color = Color3.new(1, 0.8, 0)
            end

            function wallBang.calculateWallThickness(instance, direction, hitPosition)
              if not instance or not instance.IsA then
                return 0.3
              end

              if instance:IsA("BasePart") then
                local size = instance.Size
                local cf = instance.CFrame
                local localDirection = cf:VectorToObjectSpace(direction)
                local x = math.abs(localDirection.X) > 0.001 and size.X / math.abs(localDirection.X) or math.huge
                local y = math.abs(localDirection.Y) > 0.001 and size.Y / math.abs(localDirection.Y) or math.huge
                local z = math.abs(localDirection.Z) > 0.001 and size.Z / math.abs(localDirection.Z) or math.huge
                local thickness = math.min(x, y, z)

                if thickness == math.huge or thickness ~= thickness then
                  thickness = math.max(size.X, size.Y, size.Z)
                end

                return math.max(0.1, math.min(thickness, 8))
              end

              return 0.3
            end

            function wallBang.analyzeRaycastPath(origin, targetPos, weaponName, targetCharacter)
              local delta = targetPos - origin
              local distance = delta.Magnitude

              if distance <= 0 then
                local emptyObjects = {}
                emptyObjects.totalThickness = 0
                emptyObjects.weaponPen = 0
                emptyObjects.weaponName = tostring(weaponName or "Unknown")
                return {
                  canPenetrate = true,
                  wallCount = 0,
                  damageReduction = 0,
                  objects = emptyObjects,
                  totalThickness = 0,
                  weaponPen = 0,
                  weaponName = tostring(weaponName or "Unknown"),
                }
              end
              if distance > 5000 then
                local emptyObjects = {}
                emptyObjects.totalThickness = 0
                emptyObjects.weaponPen = 0
                emptyObjects.weaponName = tostring(weaponName or "Unknown")
                return {
                  canPenetrate = true,
                  wallCount = 0,
                  damageReduction = 0,
                  objects = emptyObjects,
                  totalThickness = 0,
                  weaponPen = 0,
                  weaponName = tostring(weaponName or "Unknown"),
                }
              end

              local direction = delta.Unit
              local params = RaycastParams.new()
              local filter = { localPlayer.Character }
              params.FilterType = Enum.RaycastFilterType.Exclude
              params.FilterDescendantsInstances = filter
              params.IgnoreWater = true

              local weaponPen = wallBang.getWeaponPenetration(weaponName)
              local totalWalls = 0
              local damageReduction = 0
              local totalThickness = 0
              local objects = {}
              local currentPos = origin
              local remainingDist = distance
              local maxWalls = state.WallBangMaxWalls or 3

              while remainingDist > 0.1 and totalWalls < maxWalls do
                local hit = workspace:Raycast(currentPos + direction * 0.1, direction * remainingDist, params)
                if not hit then
                  break
                end

                if wallBang.hitIsTarget(hit.Instance, targetCharacter) then
                  break
                end

                local matPen = wallBang.getMaterialPenetration(hit.Material)
                local matName = wallBang.getMaterialName(hit.Material)
                local weaponCanBang, _, minPen, weaponReason = wallBang.canWeaponWallBang(weaponName, hit.Material)
                local penChance = 0
                if weaponPen > 0 and matPen > 0 then
                  penChance = weaponPen / (weaponPen + matPen)
                end

                local thickness = wallBang.calculateWallThickness(hit.Instance, direction, hit.Position)
                local thicknessFactor = math.max(0.1, 1 - (thickness / 10))
                local finalPenChance = penChance * thicknessFactor
                local canPenThis = false
                local reason = weaponReason
                if weaponPen <= 0 then
                  reason = "Weapon has no penetration"
                elseif matPen <= 0 then
                  reason = "Material is impenetrable (" .. matName .. ")"
                elseif not weaponCanBang then
                  reason = weaponReason
                elseif finalPenChance < 0.2 then
                  reason = string.format("Too thick (%.2fm) for weapon", thickness)
                else
                  canPenThis = true
                  reason = "Penetrable"
                end
                table.insert(objects, {
                  instance = hit.Instance,
                  material = matName,
                  materialPenetration = matPen,
                  minPenRequired = minPen,
                  distance = (hit.Position - currentPos).Magnitude,
                  position = hit.Position,
                  thickness = thickness,
                  weaponPen = weaponPen,
                  penetrationChance = penChance,
                  thicknessFactor = thicknessFactor,
                  finalPenChance = finalPenChance,
                  canPenetrate = canPenThis,
                  reason = reason,
                  normal = hit.Normal,
                  isTarget = false,
                })

                if not canPenThis then
                  objects.totalThickness = totalThickness + thickness
                  objects.weaponPen = weaponPen
                  objects.weaponName = tostring(weaponName or "Unknown")
                  objects.reason = reason
                  return {
                    canPenetrate = false,
                    wallCount = totalWalls + 1,
                    damageReduction = 1,
                    objects = objects,
                    walls = objects,
                    totalThickness = totalThickness + thickness,
                    weaponPen = weaponPen,
                    weaponName = tostring(weaponName or "Unknown"),
                    reason = reason,
                  }
                end

                local reduction = (1 - finalPenChance) * 0.5
                damageReduction = damageReduction + reduction
                totalThickness = totalThickness + thickness
                totalWalls = totalWalls + 1

                local hitDistance = (hit.Position - currentPos).Magnitude
                table.insert(filter, hit.Instance)
                params.FilterDescendantsInstances = filter
                currentPos = hit.Position + direction * (thickness + 0.1)
                remainingDist = remainingDist - hitDistance - thickness - 0.1

                if (currentPos - targetPos).Magnitude < 0.5 then
                  break
                end
              end

              if totalWalls >= maxWalls and remainingDist > 0.1 then
                local overflowHit = workspace:Raycast(currentPos + direction * 0.1, direction * remainingDist, params)
                if overflowHit and not wallBang.hitIsTarget(overflowHit.Instance, targetCharacter) then
                  local matPen = wallBang.getMaterialPenetration(overflowHit.Material)
                  local matName = wallBang.getMaterialName(overflowHit.Material)
                  local _, _, minPen = wallBang.canWeaponWallBang(weaponName, overflowHit.Material)
                  local penChance = 0
                  if weaponPen > 0 and matPen > 0 then
                    penChance = weaponPen / (weaponPen + matPen)
                  end
                  local thickness = wallBang.calculateWallThickness(overflowHit.Instance, direction, overflowHit.Position)
                  local thicknessFactor = math.max(0.1, 1 - (thickness / 10))
                  local finalPenChance = penChance * thicknessFactor
                  table.insert(objects, {
                    instance = overflowHit.Instance,
                    material = matName,
                    materialPenetration = matPen,
                    minPenRequired = minPen,
                    distance = (overflowHit.Position - currentPos).Magnitude,
                    position = overflowHit.Position,
                    thickness = thickness,
                    weaponPen = weaponPen,
                    penetrationChance = penChance,
                    thicknessFactor = thicknessFactor,
                    finalPenChance = finalPenChance,
                    canPenetrate = false,
                    reason = "Too many walls in path",
                    normal = overflowHit.Normal,
                    isTarget = false,
                    exceededWallLimit = true,
                  })
                  objects.totalThickness = totalThickness + thickness
                  objects.weaponPen = weaponPen
                  objects.weaponName = tostring(weaponName or "Unknown")
                  objects.reason = "Too many walls in path"
                  return {
                    canPenetrate = false,
                    wallCount = totalWalls,
                    damageReduction = 1,
                    objects = objects,
                    walls = objects,
                    totalThickness = totalThickness + thickness,
                    weaponPen = weaponPen,
                    weaponName = tostring(weaponName or "Unknown"),
                    reason = "Too many walls in path",
                  }
                end
              end

              damageReduction = damageReduction * (1 - (state.WallBangMultiplier or 0.7))
              damageReduction = math.max(0, math.min(damageReduction, 0.9))
              objects.totalThickness = totalThickness
              objects.weaponPen = weaponPen
              objects.weaponName = tostring(weaponName or "Unknown")
              return {
                canPenetrate = true,
                wallCount = totalWalls,
                damageReduction = damageReduction,
                objects = objects,
                walls = objects,
                totalThickness = totalThickness,
                weaponPen = weaponPen,
                weaponName = tostring(weaponName or "Unknown"),
              }
            end

            function wallBang.canPenetrate(origin, targetPos, weaponName, targetCharacter)
              local result = wallBang.analyzeRaycastPath(origin, targetPos, weaponName, targetCharacter)
              local penetrations = {}
              for _, object in ipairs(result.objects or {}) do
                table.insert(penetrations, object.materialPenetration or 0)
              end
              return result.canPenetrate, result.wallCount, penetrations
            end

            function wallBang.check(origin, targetPos, targetCharacter)
              if not state.WallBang then
                return true, 0, 0, {}
              end

              local frame = state.wallBangFrame or 0
              local weaponName = wallBang.getCurrentWeaponName()
              local cacheKey = table.concat({
                tostring(weaponName or "Unknown"),
                math.floor(origin.X * 10),
                math.floor(origin.Y * 10),
                math.floor(origin.Z * 10),
                math.floor(targetPos.X * 10),
                math.floor(targetPos.Y * 10),
                math.floor(targetPos.Z * 10),
                tostring(targetCharacter or wallBang.getTargetCharacter() or ""),
              }, ":")
              local cached = wallBang.cache[cacheKey]
              if cached and cached.frame == frame then
                return cached.canPen, cached.wallCount, cached.damageReduction, cached.objects
              end

              local result = wallBang.analyzeRaycastPath(origin, targetPos, weaponName, targetCharacter)
              if not result.canPenetrate then
                wallBang.hideIndicator()
                wallBang.cache[cacheKey] = {
                  canPen = false,
                  wallCount = result.wallCount,
                  damageReduction = 1,
                  objects = result.objects,
                  frame = frame,
                }
                return false, result.wallCount, 1, result.objects
              end

              wallBang.cache[cacheKey] = {
                canPen = true,
                wallCount = result.wallCount,
                damageReduction = result.damageReduction,
                objects = result.objects,
                frame = frame,
              }
              return true, result.wallCount, result.damageReduction, result.objects
            end
            state.MenuCrosshairEnabled = false
            state.MenuCrosshairSize = 10
            state.MenuCrosshairColor = Color3.new(1, 1, 1)
            crosshairState = game.ReplicatedFirst:FindFirstChild("ServerInfo")
            if crosshairState then
              crosshairState = game.ReplicatedFirst:FindFirstChild("ServerInfo")
              skinChangerState = "GameMode"
              crosshairState = crosshairState:GetAttribute(skinChangerState)
              r41_0 = "Lobby"
              if crosshairState == r41_0 then
                crosshairState = "Lobby"
                r41_0 = true
                state[crosshairState] = r41_0
              end
            end
            crosshairState = state.Lobby
            if crosshairState then
              crosshairState = ipairs
              for detectSuspiciousPlayer, r44_0 in crosshairState(serverListFolder:GetChildren()) do
                table.insert(state.ServerListCopy, r44_0)
              end
            end
            crosshairState = {
              Size = 10,
              Gap = 5,
              Color = Color3.new(1, 1, 1),
              Thickness = 3,
              Visible = false,
              Transparency = 1,
              Rotation = 0,
              RotateSpeed = 1,
              RotateAuto = false,
              RGB = false,
            }
            r41_0 = {
              MilitaryCrate = false,
              SmallMilitaryBox = false,
              LargeMilitaryBox = false,
              LargeABPOPABox = false,
              Safe = false,
              CashRegister = false,
              GrenadeCrate = false,
              HiddenCache = false,
              KGBBag = false,
              Toolbox = false,
              SportBag = false,
              SmallShippingCrate = false,
              LargeShippingCrate = false,
              FilingCabinet = false,
              Fridge = false,
              MedBag = false,
              SatchelBag = false,
              SupplyDropMilitary = false,
            }
            local skinChangerState = {
              SkinChanger = false,
              Skin = "Anton",
              ItemRoot = true,
              Stock = true,
              Front = true,
              Sight = true,
              Magazine = true,
              Handle = true,
              Muzzle = true,
              Extra = true,
            }
            local function detectSuspiciousPlayer(r0_297)
              -- line: [0, 0] id: 297
              if r0_297 == localPlayer then
                return 
              end
              if state.CheatDetector and not playerEsp.Cheaters[r0_297.Name] then
                local r1_297 = game.ReplicatedStorage.Players:FindFirstChild(r0_297.Name)
                if r1_297 then
                  local r2_297 = r1_297:FindFirstChild("Status")
                  if r2_297 then
                    r2_297 = r2_297:FindFirstChild("Journey")
                    if r2_297 then
                      r2_297 = r2_297:FindFirstChild("WipeStatistics")
                      if r2_297 then
                        local r3_297 = r2_297:GetAttribute("Deaths") or 0
                        if r3_297 == 0 then
                          r3_297 = 1
                        end
                        local r4_297 = r2_297:GetAttribute("Kills") or 0
                        if r4_297 == 0 then
                          r4_297 = 1
                        end
                        local r5_297 = math.floor(r4_297 / r3_297 * 10) / 10
                        local r6_297 = game.ReplicatedStorage.ReportList.MostWanted:FindFirstChild(r0_297.Name) or game.ReplicatedStorage.ReportList.Recent:FindFirstChild(r0_297.Name)
                        if r6_297 then
                          local r7_297 = r6_297:GetAttribute("TotalFlags") or 0
                          local r8_297 = r6_297:GetAttribute("HSR") or 0
                          local r9_297 = r6_297:GetAttribute("Age") or 0
                          if 15 <= r4_297 and 95 <= r8_297 then
                            playerEsp.Cheaters[r0_297.Name] = true
                            notify("Cheat | Detector (B) (KDR: " .. r5_297 .. ")", "Player: " .. r0_297.Name .. " Has been suspected for Cheating!", 5)
                          end
                          if 75 <= r7_297 and r9_297 <= 50 then
                            playerEsp.Cheaters[r0_297.Name] = true
                            notify("Cheat | Detector (C) (KDR: " .. r5_297 .. ")", "Player: " .. r0_297.Name .. " Has been suspected for Cheating!", 5)
                          end
                        end
                        if 15 <= r4_297 and r5_297 and 5 <= r5_297 then
                          playerEsp.Cheaters[r0_297.Name] = true
                          notify("Cheat | Detector (A) (KDR: " .. r5_297 .. ")", "Player: " .. r0_297.Name .. " Has been suspected for Cheating!", 5)
                        end
                      end
                    end
                  end
                end
              end
            end
            local r44_0 = {}
            local r45_0 = {}
            local function scanForModerators()
              -- line: [0, 0] id: 296
              if state.ModDetector then
                for r3_296, r4_296 in ipairs(game.Players:GetPlayers()) do
                  detectSuspiciousPlayer(r4_296)
                  if r4_296.Character then
                    if not r44_0[r4_296.Name] then
                      r44_0[r4_296.Name] = 1
                    end
                    if r44_0[r4_296.Name] < 5 and not r45_0[r4_296.Name] then
                      local r6_296 = game.ReplicatedStorage.Players:FindFirstChild(r4_296.Name):FindFirstChild("Status")
                      if r6_296 and r6_296:FindFirstChild("GameplayVariables") and 4 <= r6_296.GameplayVariables:GetAttribute("PremiumLevel") then
                        if not playerEsp.Moderators[r4_296.Name] then
                          playerEsp.Moderators[r4_296.Name] = true
                        end
                        r44_0[r4_296.Name] = r44_0[r4_296.Name] + 1
                        notify("Mod Detector (A)", "Mod Has Been Detected With Username: " .. r4_296.Name)
                        notify("Mod Detector (A)", "Mod Has Been Detected With Username: " .. r4_296.Name)
                        notify("Mod Detector (A)", "Mod Has Been Detected With Username: " .. r4_296.Name)
                        print("Mod Detector (Prem) Has Suspected " .. r4_296.Name .. " To Be An Administrator Warnings: " .. r44_0[r4_296.Name])
                      end
                    end
                    if r44_0[r4_296.Name] < 5 then
                      for r8_296, r9_296 in pairs(r4_296.Character:GetChildren()) do
                        if (r9_296.Name == "Head" or r9_296.Name == "LeftFoot" or r9_296.Name == "LeftHand" or r9_296.Name == "LeftLowerArm" or r9_296.Name == "LeftLowerLeg" or r9_296.Name == "LeftUpperArm" or r9_296.Name == "LeftUpperLeg" or r9_296.Name == "LowerTorso" or r9_296.Name == "RightFoot" or r9_296.Name == "RightHand" or r9_296.Name == "RightLowerArm" or r9_296.Name == "RightUpperArm" or r9_296.Name == "RightUpperLeg" or r9_296.Name == "UpperTorso") and 1 <= r9_296.Transparency then
                          if not playerEsp.Moderators[r4_296.Name] then
                            playerEsp.Moderators[r4_296.Name] = true
                          end
                          r44_0[r4_296.Name] = r44_0[r4_296.Name] + 1
                          notify("Mod Detector (B)", "Mod Has Been Detected With Username: " .. r4_296.Name)
                          notify("Mod Detector (B)", "Mod Has Been Detected With Username: " .. r4_296.Name)
                          notify("Mod Detector (B)", "Mod Has Been Detected With Username: " .. r4_296.Name)
                          print("Mod Detector (Invis) Has Suspected " .. r4_296.Name .. " To Be An Administrator Warnings: " .. r44_0[r4_296.Name])
                          return 
                        end
                      end
                    end
                    r45_0[r4_296.Name] = true
                  end
                end
              end
            end
            local function doBunnyHopJump()
              -- line: [0, 0] id: 35
              local r0_35 = tick()
              if r0_35 - state.lastJumpTime >= 0.5 then
                local r1_35 = localPlayer.Character
                if r1_35 then
                  local r2_35 = r1_35:FindFirstChild("Humanoid")
                  if r2_35 and r2_35:GetState() ~= Enum.HumanoidStateType.Freefall then
                    local r3_35 = r1_35:FindFirstChild("HumanoidRootPart")
                    if r3_35 then
                      r3_35.Velocity = Vector3.new(0, 24, 0)
                      state.lastJumpTime = r0_35
                    end
                  end
                end
              end
            end
            local r48_0 = {}
            local function findSkinTexture(r0_283)
              -- line: [0, 0] id: 283
              for r4_283, r5_283 in pairs(game.ReplicatedStorage.Skins:GetChildren()) do
                local r6_283 = r5_283:FindFirstChild(r0_283)
                if r6_283 then
                  return r6_283.Textures.Base
                end
              end
              return None
            end

            local function applyWeaponSkin(r0_269)
              -- line: [0, 0] id: 269
              local r1_269 = findSkinTexture(r0_269)
              local r2_269 = camera:FindFirstChild("ViewModel")
              if r1_269 and r2_269 then
                local r3_269 = r2_269:FindFirstChild("Item")
                if r3_269 then
                  local r4_269 = skinChangerState.ItemRoot
                  if r4_269 then
                    r4_269 = pairs
                    for r7_269, r8_269 in r4_269(r3_269:GetChildren()) do
                      local r9_269 = r8_269:FindFirstChild("SurfaceAppearance")
                      if r9_269 then
                        r9_269:Destroy()
                        r1_269:Clone().Parent = r8_269
                      end
                    end
                  end
                  function r4_269(r0_270)
                    -- line: [0, 0] id: 270
                    for r4_270, r5_270 in pairs(r0_270:GetChildren()) do
                      local r6_270 = r5_270:FindFirstChild("SurfaceAppearance")
                      if r6_270 then
                        r6_270:Destroy()
                        r1_269:Clone().Parent = r5_270
                      else
                        r4_269(r5_270)
                      end
                    end
                  end
                  local r5_269 = r3_269:FindFirstChild("Attachments")
                  if r5_269 then
                    for r9_269, r10_269 in pairs(r5_269:GetChildren()) do
                      if skinChangerState[r10_269.Name] then
                        r4_269(r10_269)
                      end
                    end
                  end
                  -- close: r4_269
                end
              end
            end
            local menuVisualOverrideActive = false
            local fovMenuBypassActive = false
            local crosshairMenuBypassActive = false
            local function isFovEffectivelyVisible()
              return state.FovVisible and (not menuVisualOverrideActive or fovMenuBypassActive)
            end
            local function isCrosshairEffectivelyVisible()
              return crosshairState.Visible and (not menuVisualOverrideActive or crosshairMenuBypassActive)
            end
            local function updateCrosshairDrawing()
              -- line: [0, 0] id: 26
              local r1_26 = workspace.CurrentCamera.ViewportSize
              local r2_26 = r1_26.X / 2
              local r3_26 = r1_26.Y / 2
              local r4_26 = Vector2.new(r2_26, r3_26)
              if crosshairState.RGB then
                crosshairState.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
              end
              if crosshairState.RotateAuto then
                crosshairState.Rotation = (crosshairState.Rotation + crosshairState.RotateSpeed) % 360
              else
                crosshairState.Rotation = 0
              end
              local function r5_26(r0_27, r1_27, r2_27)
                -- line: [0, 0] id: 27
                local r3_27 = math.rad(r1_27)
                local r4_27 = math.cos(r3_27)
                local r5_27 = math.sin(r3_27)
                local r6_27 = r2_27.X - r0_27.X
                local r7_27 = r2_27.Y - r0_27.Y
                return Vector2.new(r4_27 * r6_27 - r5_27 * r7_27 + r0_27.X, r5_27 * r6_27 + r4_27 * r7_27 + r0_27.Y)
              end
              local r6_26 = Vector2.new(r2_26 - crosshairState.Size - crosshairState.Gap, r3_26)
              local r7_26 = Vector2.new(r2_26 - crosshairState.Gap, r3_26)
              local r8_26 = Vector2.new(r2_26 + crosshairState.Gap, r3_26)
              local r9_26 = Vector2.new(r2_26 + crosshairState.Size + crosshairState.Gap, r3_26)
              local r10_26 = Vector2.new(r2_26, r3_26 - crosshairState.Size - crosshairState.Gap)
              local r11_26 = Vector2.new(r2_26, r3_26 - crosshairState.Gap)
              local r12_26 = Vector2.new(r2_26, r3_26 + crosshairState.Gap)
              local r13_26 = Vector2.new(r2_26, r3_26 + crosshairState.Size + crosshairState.Gap)
              state.HorizontalLine1.From = r5_26(r4_26, crosshairState.Rotation, r6_26)
              state.HorizontalLine1.To = r5_26(r4_26, crosshairState.Rotation, r7_26)
              state.HorizontalLine2.From = r5_26(r4_26, crosshairState.Rotation, r8_26)
              state.HorizontalLine2.To = r5_26(r4_26, crosshairState.Rotation, r9_26)
              state.VerticalLine1.From = r5_26(r4_26, crosshairState.Rotation, r10_26)
              state.VerticalLine1.To = r5_26(r4_26, crosshairState.Rotation, r11_26)
              state.VerticalLine2.From = r5_26(r4_26, crosshairState.Rotation, r12_26)
              state.VerticalLine2.To = r5_26(r4_26, crosshairState.Rotation, r13_26)
              for r17_26, r18_26 in pairs({
                state.HorizontalLine1,
                state.HorizontalLine2,
                state.VerticalLine1,
                state.VerticalLine2
              }) do
                r18_26.Color = crosshairState.Color
                r18_26.Thickness = crosshairState.Thickness
                r18_26.Visible = isCrosshairEffectivelyVisible()
                local r19_26 = crosshairState.Transparency
                r18_26.Transparency = r19_26
              end
            end
            local menuCrosshairGui = nil
            local menuCrosshairFrame = nil
            local menuCrosshairParts = {}
            local function isMenuVisible()
              local r0_26 = CoreGui:FindFirstChild("unknown")
              if not r0_26 then
                return false
              end
              if r0_26:IsA("ScreenGui") and not r0_26.Enabled then
                return false
              end
              local r2_26 = r0_26:FindFirstChild("Base", true)
              if r2_26 and r2_26:IsA("GuiObject") then
                return r2_26.Visible == true
              end
              local r1_26 = r0_26:FindFirstChild("Main")
              if r1_26 and r1_26:IsA("GuiObject") then
                return r1_26.Visible == true
              end
              return r0_26:IsA("ScreenGui") and r0_26.Enabled == true
            end
            local function createMenuCrosshair()
              if menuCrosshairGui then
                return
              end
              menuCrosshairGui = Instance.new("ScreenGui")
              menuCrosshairGui.Name = "MenuCrosshair"
              menuCrosshairGui.ResetOnSpawn = false
              menuCrosshairGui.IgnoreGuiInset = true
              menuCrosshairGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
              menuCrosshairGui.Enabled = false
              menuCrosshairGui.Parent = CoreGui
              menuCrosshairFrame = Instance.new("Frame")
              menuCrosshairFrame.Name = "CrosshairFrame"
              menuCrosshairFrame.BackgroundTransparency = 1
              menuCrosshairFrame.BorderSizePixel = 0
              menuCrosshairFrame.AnchorPoint = Vector2.new(0.5, 0.5)
              menuCrosshairFrame.Parent = menuCrosshairGui
              local function r0_26(r0_27, r1_27)
                local r2_27 = Instance.new("Frame")
                r2_27.Name = r0_27
                r2_27.BackgroundColor3 = r1_27 or state.MenuCrosshairColor
                r2_27.BorderSizePixel = 0
                r2_27.ZIndex = 9999
                r2_27.Parent = menuCrosshairFrame
                menuCrosshairParts[r0_27] = r2_27
                return r2_27
              end
              r0_26("Top")
              r0_26("Bottom")
              r0_26("Left")
              r0_26("Right")
              r0_26("Dot", Color3.new(1, 0, 0))
            end
            local function updateMenuCrosshairStyle()
              if not menuCrosshairGui then
                return
              end
              local r0_26 = state.MenuCrosshairSize or 10
              local r1_26 = math.max(12, r0_26 * 2 + 8)
              local r2_26 = state.MenuCrosshairColor or Color3.new(1, 1, 1)
              menuCrosshairFrame.Size = UDim2.new(0, r1_26, 0, r1_26)
              menuCrosshairParts.Top.Size = UDim2.new(0, 2, 0, r0_26)
              menuCrosshairParts.Top.Position = UDim2.new(0.5, -1, 0, 0)
              menuCrosshairParts.Bottom.Size = UDim2.new(0, 2, 0, r0_26)
              menuCrosshairParts.Bottom.Position = UDim2.new(0.5, -1, 1, -r0_26)
              menuCrosshairParts.Left.Size = UDim2.new(0, r0_26, 0, 2)
              menuCrosshairParts.Left.Position = UDim2.new(0, 0, 0.5, -1)
              menuCrosshairParts.Right.Size = UDim2.new(0, r0_26, 0, 2)
              menuCrosshairParts.Right.Position = UDim2.new(1, -r0_26, 0.5, -1)
              menuCrosshairParts.Dot.Size = UDim2.new(0, 2, 0, 2)
              menuCrosshairParts.Dot.Position = UDim2.new(0.5, -1, 0.5, -1)
              menuCrosshairParts.Top.BackgroundColor3 = r2_26
              menuCrosshairParts.Bottom.BackgroundColor3 = r2_26
              menuCrosshairParts.Left.BackgroundColor3 = r2_26
              menuCrosshairParts.Right.BackgroundColor3 = r2_26
            end
            local function updateMenuCrosshair()
              local r0_26 = state.MenuCrosshairEnabled and isMenuVisible()
              if not r0_26 then
                if menuCrosshairGui then
                  menuCrosshairGui.Enabled = false
                end
                return
              end
              createMenuCrosshair()
              updateMenuCrosshairStyle()
              local r1_26 = UserInputService:GetMouseLocation()
              menuCrosshairFrame.Position = UDim2.new(0, r1_26.X, 0, r1_26.Y)
              menuCrosshairGui.Enabled = true
            end
            local function destroyMenuCrosshair()
              if menuCrosshairGui then
                menuCrosshairGui:Destroy()
              end
              menuCrosshairGui = nil
              menuCrosshairFrame = nil
              menuCrosshairParts = {}
            end
            state.FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
            state.FOVCircle.Visible = isFovEffectivelyVisible()
            state.FOVCircle.NumSides = 64
            state.FOVCircle.Radius = state.AimbotFov
            state.FOVCircle.Thickness = 3
            state.FOVCircle.Transparency = 0.5
            state.FOVCircle.Color = Color3.fromRGB(129, 210, 255)
            local predictionIndicator = Drawing.new("Text")
            predictionIndicator.Text = "PRED"
            predictionIndicator.Size = 14
            predictionIndicator.Color = Color3.new(0, 1, 0)
            predictionIndicator.Center = true
            predictionIndicator.Outline = true
            predictionIndicator.Visible = false
            local overlayGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
            overlayGui.ResetOnSpawn = false
            overlayGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
            overlayGui.Name = "DontWorry404"
            local warningGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
            warningGui.ResetOnSpawn = false
            warningGui.IgnoreGuiInset = true
            warningGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
            warningGui.Name = "YouShudWorry404"
            local lowFoodWarningFrame = Instance.new("Frame", warningGui)
            lowFoodWarningFrame.Name = "TopLine"
            lowFoodWarningFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            lowFoodWarningFrame.Visible = false
            lowFoodWarningFrame.BorderSizePixel = 0
            lowFoodWarningFrame.Position = UDim2.new(0, 0, 0, 0)
            lowFoodWarningFrame.Size = UDim2.new(1, 0, 0.003, 0)
            lowFoodWarningFrame.ZIndex = 9999
            local aimTargetLabel = nil
            local inventoryViewerTitle = nil
            local billboardTemplate = Instance.new("BillboardGui")
            local billboardTextTemplate = Instance.new("TextLabel", billboardTemplate)
            billboardTemplate.ResetOnSpawn = false
            billboardTemplate.AlwaysOnTop = true
            billboardTemplate.LightInfluence = 0
            billboardTemplate.Size = UDim2.new(1.75, 0, 1.75, 0)
            billboardTextTemplate.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            billboardTextTemplate.Text = ""
            billboardTextTemplate.Size = UDim2.new(0.0001, 0.0001, 0.0001, 0.0001)
            billboardTextTemplate.BorderSizePixel = 4
            billboardTextTemplate.BorderColor3 = Color3.new(255, 255, 255)
            billboardTextTemplate.BorderSizePixel = 0
            billboardTextTemplate.Font = "GothamSemibold"
            billboardTextTemplate.TextSize = 0
            billboardTextTemplate.TextColor3 = Color3.fromRGB(255)
            local highlightTemplate = Instance.new("Highlight")
            highlightTemplate.Name = "Sigma"
            highlightTemplate.Parent = nil
            if overlayGui then
              aimTargetLabel = Instance.new("TextLabel", overlayGui)
              aimTargetLabel.Size = UDim2.new(0.3, 0, 0.015, 0)
              aimTargetLabel.Position = UDim2.new(0.5, 0, 0.535, 0)
              aimTargetLabel.AnchorPoint = Vector2.new(0.5, 0.5)
              aimTargetLabel.BackgroundTransparency = 1
              aimTargetLabel.TextColor3 = Color3.new(1, 0, 0)
              aimTargetLabel.Font = Enum.Font.GothamSemibold
              aimTargetLabel.Visible = false
              aimTargetLabel.TextScaled = true
              inventoryViewerTitle = Instance.new("TextLabel", overlayGui)
              inventoryViewerTitle.Size = UDim2.new(0.19, 0, 0.03, 0)
              inventoryViewerTitle.Position = UDim2.new(0.5, 0, 0.08, 0)
              inventoryViewerTitle.AnchorPoint = Vector2.new(0.5, 0.5)
              inventoryViewerTitle.BackgroundTransparency = 1
              inventoryViewerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
              inventoryViewerTitle.Font = Enum.Font.GothamSemibold
              inventoryViewerTitle.Visible = false
              inventoryViewerTitle.TextScaled = true
            else
              warn("Screengui Not Found")
            end
            local targetChamsCache = {}
            local function getAimbotTargetCharacter(target)
              if not target then
                return nil
              end
              if target:IsA("Player") then
                return target.Character
              end
              if target:IsA("Model") then
                return target
              end
              return nil
            end
            local function RemoveTargetChams(character)
              if not character then
                return
              end
              local targetHighlight = targetChamsCache[character]
              if targetHighlight and targetHighlight.Parent then
                targetHighlight:Destroy()
              end
              targetChamsCache[character] = nil
              local existingHighlight = character:FindFirstChild("AimbotOutlineHighlight")
              if existingHighlight then
                existingHighlight:Destroy()
              end
              existingHighlight = character:FindFirstChild("AimbotTargetHighlight")
              if existingHighlight then
                existingHighlight:Destroy()
              end
              for r4_41, r5_41 in ipairs(character:GetDescendants()) do
                if r5_41.Name == "AimbotTargetPartHighlight" or r5_41.Name == "AimbotTargetPartOutline" or r5_41.Name == "AimbotOutlineHighlight" or r5_41.Name == "TargetedPartGlow" then
                  r5_41:Destroy()
                end
                if r5_41:IsA("BasePart") then
                  r5_41:SetAttribute("IsAimbotTargetPart", false)
                end
              end
              character:SetAttribute("HasAimbotChams", false)
            end
            local function ClearAimbotTargetVisuals()
              local charactersToRemove = {}
              for character in pairs(targetChamsCache) do
                table.insert(charactersToRemove, character)
              end
              for r4_41, r5_41 in ipairs(charactersToRemove) do
                RemoveTargetChams(r5_41)
              end
              targetChamsCache = {}
            end
            local function ApplyTargetChams(target, enabled)
              local character = getAimbotTargetCharacter(target)
              if not character then
                return
              end
              if not enabled or not state.ShowTarget then
                RemoveTargetChams(character)
                return
              end
              local chamColor = state.ShowTargetColor or Color3.new(1, 0, 0)
              local chamTransparency = state.ShowTargetTransparency
              if chamTransparency == nil then
                chamTransparency = 0.1
              end
              local charactersToRemove = {}
              for cachedCharacter in pairs(targetChamsCache) do
                if cachedCharacter ~= character then
                  table.insert(charactersToRemove, cachedCharacter)
                end
              end
              for r4_41, r5_41 in ipairs(charactersToRemove) do
                RemoveTargetChams(r5_41)
              end
              local targetHighlight = targetChamsCache[character]
              if not targetHighlight or not targetHighlight.Parent then
                local existingHighlight = character:FindFirstChild("AimbotTargetHighlight") or character:FindFirstChild("AimbotOutlineHighlight")
                if existingHighlight then
                  existingHighlight:Destroy()
                end
                targetHighlight = Instance.new("Highlight")
                targetHighlight.Name = "AimbotTargetHighlight"
                targetHighlight.Parent = character
                targetHighlight.Enabled = true
                targetHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                targetChamsCache[character] = targetHighlight
                character:SetAttribute("HasAimbotChams", true)
              end
              targetHighlight.FillColor = chamColor
              targetHighlight.OutlineColor = chamColor
              targetHighlight.FillTransparency = chamTransparency
              targetHighlight.OutlineTransparency = 0.05
            end
            local function UpdateAimbotTargetChams()
              if not state.ShowTarget or not state.LastTarget then
                ClearAimbotTargetVisuals()
                return
              end
              local activeCharacter = getAimbotTargetCharacter(state.LastTarget)
              if not activeCharacter or not activeCharacter.Parent then
                ClearAimbotTargetVisuals()
                return
              end
              local charactersToRemove = {}
              for character in pairs(targetChamsCache) do
                if character ~= activeCharacter then
                  table.insert(charactersToRemove, character)
                end
              end
              for r4_41, r5_41 in ipairs(charactersToRemove) do
                RemoveTargetChams(r5_41)
              end
              ApplyTargetChams(state.LastTarget, true)
            end
            local function PatchAimTargetDisplay()
              if aimTargetLabel then
                aimTargetLabel.TextScaled = true
                aimTargetLabel.Font = Enum.Font.GothamBold
                aimTargetLabel.TextStrokeTransparency = 0.2
                aimTargetLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
              end
            end
            PatchAimTargetDisplay()
            local function toggleXrayTransparency(r0_266)
              -- line: [0, 0] id: 266
              local r1_266 = workspace.CurrentCamera.CFrame.Position
              local r2_266 = 500
              for r6_266, r7_266 in ipairs(workspace:GetDescendants()) do
                if r7_266:IsA("BasePart") then
                  local r8_266 = r7_266.Parent
                  if not (r8_266 and r8_266:FindFirstChildOfClass("Humanoid")) and (r1_266 - r7_266.Position).Magnitude <= r2_266 then
                    if r0_266 and r7_266.Transparency == 0 then
                      r7_266.Transparency = 0.5
                    elseif not r0_266 and r7_266.Transparency == 0.5 then
                      r7_266.Transparency = 0
                    end
                  end
                end
              end
            end
            local r61_0 = game:GetService("Lighting")
            function setFullBrightness(r0_309)
              -- line: [0, 0] id: 309
              if r0_309 then
                r61_0.Brightness = 10
                r61_0.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
                r61_0.Ambient = Color3.fromRGB(255, 255, 255)
              else
                r61_0.Brightness = 2
                r61_0.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
                r61_0.Ambient = Color3.fromRGB(128, 128, 128)
              end
            end
            local r62_0 = 0
            local r63_0 = 0
            local r64_0 = 0
            local r65_0 = Vector3.new(0, 0, 0)
            local function offsetViewModelArms(r0_40, r1_40)
              -- line: [0, 0] id: 40
              if not r0_40 then
                return 
              end
              local r2_40 = r0_40:FindFirstChild("HumanoidRootPart")
              local r3_40 = Vector3.new(r62_0, r63_0, r64_0)
              local r4_40 = r3_40
              if r1_40 then
                r4_40 = r3_40 - r65_0
                r65_0 = r3_40
              end
              local r5_40 = r2_40:FindFirstChild("LeftUpperArm")
              local r6_40 = r2_40:FindFirstChild("RightUpperArm")
              local r7_40 = r2_40:FindFirstChild("Motor6D")
              if r5_40 and r6_40 and r7_40 and r4_40 then
                r5_40.C0 = r5_40.C0 + r4_40
                r6_40.C0 = r6_40.C0 + r4_40
                r7_40.C0 = r7_40.C0 + r4_40
              end
            end
            local function applyViewModelArmsStyle(r0_292, r1_292)
              -- line: [0, 0] id: 292
              if r1_292 and r0_292 == "Color" then
                for r5_292, r6_292 in pairs(r1_292:GetChildren()) do
                  if r6_292.Name == "LeftHand" or r6_292.Name == "LeftLowerArm" or r6_292.Name == "LeftUpperArm" or r6_292.Name == "RightHand" or r6_292.Name == "RightLowerArm" or r6_292.Name == "RightUpperArm" then
                    r6_292.Color = state.ArmColor
                  end
                end
              elseif r1_292 and r0_292 == "Transparency" then
                for r5_292, r6_292 in pairs(r1_292:GetChildren()) do
                  if r6_292.Name == "LeftHand" or r6_292.Name == "LeftLowerArm" or r6_292.Name == "LeftUpperArm" or r6_292.Name == "RightHand" or r6_292.Name == "RightLowerArm" or r6_292.Name == "RightUpperArm" then
                    r6_292.Transparency = state.ViewModelTransparency
                  end
                end
              end
            end
            local function cleanViewModel(r0_39)
              -- line: [0, 0] id: 39
              if r0_39 then
                for r4_39, r5_39 in pairs(r0_39:GetChildren()) do
                  if r5_39.Name ~= "Body Colors" and r5_39.Name ~= "Clothing" and r5_39.Name ~= "Humanoid" and r5_39.Name ~= "ZoomAmount" and r5_39.Name ~= "Item" and r5_39.Name ~= "LeftHand" and r5_39.Name ~= "LeftLowerArm" and r5_39.Name ~= "LeftUpperArm" and r5_39.Name ~= "RightHand" and r5_39.Name ~= "RightLowerArm" and r5_39.Name ~= "RightUpperArm" and r5_39.Name ~= "AimPart" and r5_39.Name ~= "AimPartCanted" and r5_39.Name ~= "FakeCamera" and r5_39.Name ~= "HumanoidRootPart" then
                    r5_39:Destroy()
                  end
                end
              end
              applyViewModelArmsStyle("Color", r0_39)
              applyViewModelArmsStyle("Transparency", r0_39)
            end
            local featureConnections = {}
            featureConnections.AimbotTargetPlayerRemoving = Players.PlayerRemoving:Connect(function(player)
              if player.Character then
                RemoveTargetChams(player.Character)
              end
            end)
            featureConnections.AimbotTargetDescendantRemoving = workspace.DescendantRemoving:Connect(function(desc)
              if desc:IsA("Model") then
                RemoveTargetChams(desc)
              end
            end)
            function toggleAiEsp(r0_32)
              -- line: [0, 0] id: 32
              if r0_32.Name == localPlayer.Name then
                return 
              end
              if r0_32:IsA("Model") and state.ViewModelChanger or skinChangerState.SkinChanger or state.InstantEquip then
                local r1_32 = 0
                local r2_32 = nil
                while not r2_32 and r1_32 < 250 do
                  r1_32 = r1_32 + 1
                  r2_32 = camera:FindFirstChild("ViewModel")
                  task.wait(0.01)
                end
                if not r2_32 then
                  return 
                end
                if skinChangerState.SkinChanger then
                  applyWeaponSkin(skinChangerState.Skin)
                end
                if state.ViewModelChanger then
                  offsetViewModelArms(r2_32, false)
                  cleanViewModel(r2_32)
                end
                if state.InstantEquip then
                  local instantEquipStartedAt = tick()
                  while tick() - instantEquipStartedAt < 2.5 do
                    for r6_32, r7_32 in ipairs(r0_32.Humanoid.Animator:GetPlayingAnimationTracks()) do
                      if r7_32.Animation.Name == "Equip" then
                        r7_32:AdjustSpeed(15)
                        r7_32.TimePosition = r7_32.Length - 0.01
                        return 
                      end
                    end
                    task.wait(0.03)
                  end
                end
              end
            end
            featureConnections.Model = game.Workspace.Camera.ChildAdded:Connect(toggleAiEsp)
            notify("GHOST_HOOK 2/5", "Loading Functions", 2.5)
            local function toggleDroppedItemOrCorpseEsp(r0_7)
              -- line: [0, 0] id: 7
              if r0_7 == true then
                for r4_7, r5_7 in pairs(workspace.DroppedItems:GetChildren()) do
                  if not r5_7:FindFirstChild("Humanoid") and not r5_7:FindFirstChild("BillboardGui") and r5_7.Name == "RPG7" then
                    local r6_7 = billboardTemplate:Clone()
                    local r7_7 = billboardTextTemplate:Clone()
                    local r8_7 = r5_7:FindFirstChild("ItemProperties")
                    if r8_7 then
                      r8_7 = r8_7:GetAttribute("Amount") or 1
                    else
                      r8_7 = 1
                    end
                    r7_7.Text = r5_7.Name .. " " .. r8_7 .. "X" .. " | Item"
                    r7_7.TextColor3 = state.DroppedItemColor
                    r7_7.Parent = r6_7
                    r7_7.TextSize = state.DroppedItemTextSize
                    r6_7.Parent = r5_7
                  end
                end
              elseif r0_7 == false then
                for r4_7, r5_7 in pairs(workspace.DroppedItems:GetChildren()) do
                  if not r5_7:FindFirstChild("Humanoid") and r5_7:FindFirstChild("BillboardGui") then
                    r5_7:FindFirstChild("BillboardGui"):Destroy()
                  end
                end
              end
              if r0_7 == "Humanoid" then
                for r4_7, r5_7 in pairs(workspace.DroppedItems:GetChildren()) do
                  if r5_7:FindFirstChild("Humanoid") and not r5_7:FindFirstChild("BillboardGui") then
                    local r6_7 = billboardTemplate:Clone()
                    local r7_7 = billboardTextTemplate:Clone()
                    r7_7.Text = r5_7.Name .. " | Corpse"
                    if r5_7.Name == localPlayer.Name then
                      r7_7.TextColor3 = Color3.fromRGB(255, 102, 0)
                    else
                      r7_7.TextColor3 = state.CorpseColor
                    end
                    r7_7.TextSize = state.CorpseTextSize
                    r7_7.Parent = r6_7
                    r6_7.Parent = r5_7
                  end
                end
              elseif r0_7 == "HumanoidRemove" then
                for r4_7, r5_7 in pairs(workspace.DroppedItems:GetChildren()) do
                  if r5_7:FindFirstChild("Humanoid") and r5_7:FindFirstChild("BillboardGui") then
                    local r6_7 = r5_7:FindFirstChild("BillboardGui")
                    if r6_7 then
                      r6_7:Destroy()
                    end
                  end
                end
              end
            end
            function onDroppedItemAdded(r0_272)
              -- line: [0, 0] id: 272
              if r0_272:IsA("BillboardGui") then
                return 
              end
              if r0_272:FindFirstChild("Highlight") then
                r0_272:FindFirstChild("Highlight"):Destroy()
              end
              local r1_272 = nil
              for r5_272, r6_272 in pairs(game:GetService("Players"):GetPlayers()) do
                if r6_272.Name == r0_272.Name then
                  r1_272 = true
                  break
                else
                  r1_272 = false
                end
              end
              if r0_272:FindFirstChild("Humanoid") then
                r1_272 = true
              end
              if r1_272 == false and not r0_272:FindFirstChild("BillboardGui") and state.DroppedItemESP then
                task.wait(0.05)
                local r3_272 = billboardTemplate:Clone()
                local r4_272 = billboardTextTemplate:Clone()
                local r5_272 = r0_272:FindFirstChild("ItemProperties")
                if r5_272 then
                  r5_272 = r5_272:GetAttribute("Amount") or 1
                else
                  r5_272 = 1
                end
                r4_272.Text = r0_272.Name .. " " .. r5_272 .. "X" .. " | Item"
                r4_272.TextColor3 = state.DroppedItemColor
                r4_272.TextSize = state.DroppedItemTextSize
                r4_272.Parent = r3_272
                r3_272.Parent = r0_272
              elseif r1_272 == true and state.CorpseESP then
                task.wait(0.05)
                local r3_272 = r0_272:FindFirstChild("BillboardGui")
                if r3_272 then
                  r3_272:Destroy()
                end
                local r4_272 = billboardTemplate:Clone()
                local r5_272 = billboardTextTemplate:Clone()
                r5_272.Text = r0_272.Name .. " | Corpse"
                if r0_272.Name == localPlayer.Name then
                  r5_272.TextColor3 = Color3.fromRGB(255, 102, 0)
                else
                  r5_272.TextColor3 = state.CorpseColor
                end
                r5_272.TextSize = state.CorpseTextSize
                r5_272.Parent = r4_272
                r4_272.Parent = r0_272
              end
            end
            featureConnections.DroppedItems = game.Workspace.DroppedItems.ChildAdded:Connect(onDroppedItemAdded)
            local function toggleExitEsp(r0_28)
              -- line: [0, 0] id: 28
              for r4_28, r5_28 in pairs(workspace.NoCollision.ExitLocations:GetChildren()) do
                (function(r0_29)
                  local r1_29 = r5_28:FindFirstChild("ExitLocation")
                  if r0_29 and not r1_29 then
                    local r2_29 = billboardTemplate:Clone()
                    r2_29.Name = "ExitLocation"
                    local r3_29 = billboardTextTemplate:Clone()
                    r3_29.Text = r5_28.Name .. " | Extract 0 Studs"
                    r3_29.TextColor3 = state.ExitColor
                    r3_29.TextSize = state.ExitTextSize
                    r3_29.Parent = r2_29
                    r2_29.Parent = r5_28
                    local r4_29 = nil
                    local r5_29 = false
                    while r5_29 == false do
                      if not r4_29 then
                        r4_29 = workspace.NoCollision.ExitLocations.ChildRemoved:Connect(function(r0_30)
                          -- line: [0, 0] id: 30
                          if r0_30 == r5_28 then
                            r5_29 = true
                          end
                          if not r5_28:FindFirstChild("ExitLocation") then
                            r5_29 = true
                          end
                          if not state.ExitESP then
                            r5_29 = true
                          end
                          if r5_29 and r4_29 then
                            r4_29:Disconnect()
                          end
                        end)
                      end
                      if localPlayer.Character then
                        HumanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                      end
                      if HumanoidRootPart then
                        r3_29.Text = r5_28.Name .. " | Extract " .. math.floor((HumanoidRootPart.Position - r5_28.CFrame.Position).Magnitude) .. " Studs"
                      end
                      task.wait(0.05)
                    end
                    -- close: r2_29
                  elseif not r0_29 and r1_29 then
                    r1_29:Destroy()
                  end
                end)(r0_28)
                -- close: r4_28
              end
            end
            function r75_0(r0_2)
              -- line: [0, 0] id: 2
              if r0_2:IsA("BillboardGui") then
                return 
              end
              if state.ExitESP then
                toggleExitEsp(true)
              end
            end
            featureConnections.Exit = workspace.NoCollision.ExitLocations.ChildAdded:Connect(r75_0)
            local function toggleQuestItemEsp(r0_262)
              -- line: [0, 0] id: 262
              if not workspace:FindFirstChild("QuestItems") then
                return 
              end
              if r0_262 == true then
                for r4_262, r5_262 in pairs(workspace.QuestItems:GetChildren()) do
                  local r6_262 = r5_262:GetAttribute("Hidden")
                  if not r5_262:FindFirstChild("BillboardGui") and r6_262 == false then
                    local r7_262 = billboardTemplate:Clone()
                    local r8_262 = billboardTextTemplate:Clone()
                    r8_262.Text = r5_262.Name .. " | Quest"
                    r8_262.TextColor3 = state.QuestESPColor
                    r8_262.TextSize = state.QuestTextSize
                    r8_262.Parent = r7_262
                    r7_262.Parent = r5_262
                  end
                end
              else
                for r4_262, r5_262 in pairs(workspace.QuestItems:GetChildren()) do
                  local r6_262 = r5_262:FindFirstChild("BillboardGui")
                  if r6_262 then
                    r6_262:Destroy()
                  end
                end
              end
            end
            function r75_0(r0_285)
              -- line: [0, 0] id: 285
              if state.QuestESP and not r0_285:FindFirstChild("BillboardGui") and r0_285:GetAttribute("Hidden") == false then
                local r3_285 = billboardTemplate:Clone()
                local r4_285 = billboardTextTemplate:Clone()
                r4_285.Text = r0_285.Name .. " | Quest"
                r4_285.TextColor3 = state.QuestESPColor
                r4_285.TextSize = state.QuestTextSize
                r4_285.Parent = r3_285
                r3_285.Parent = r0_285
              end
            end
            workspace.QuestItems.ChildAdded:Connect(r75_0)
            function toggleAiEsp(r0_20)
              -- line: [0, 0] id: 20
              if r0_20 == true then
                for r4_20, r5_20 in pairs(workspace.AiZones:GetChildren()) do
                  for r9_20, r10_20 in pairs(r5_20:GetChildren()) do
                    if r10_20:IsA("Model") and r10_20:FindFirstChild("Humanoid") and 0 < r10_20.Humanoid.Health then
                      if state.AINameTag and not r10_20:FindFirstChild("BillboardGui") then
                        local r11_20 = billboardTemplate:Clone()
                        r11_20.StudsOffset = Vector3.new(0, 1.5, 0)
                        local r12_20 = billboardTextTemplate:Clone()
                        r12_20.Text = r10_20.Name .. " | NPC"
                        r12_20.TextColor3 = state.NameTagColor
                        r12_20.TextSize = state.AiNameTagTextSize
                        r12_20.Parent = r11_20
                        r11_20.Parent = r10_20
                      end
                      if state.AIHighlight and not r10_20:FindFirstChild("Highlight") and r10_20:FindFirstChild("Humanoid") and 0 < r10_20.Humanoid.Health then
                        local r11_20 = highlightTemplate:Clone()
                        r11_20.Parent = r10_20
                        r11_20.FillColor = state.HighlightColor
                        r11_20.OutlineColor = state.HighlightColor
                      end
                    end
                  end
                end
              else
                for r4_20, r5_20 in pairs(workspace.AiZones:GetChildren()) do
                  for r9_20, r10_20 in pairs(r5_20:GetChildren()) do
                    if r0_20 == "NameTag" then
                      local r11_20 = r10_20:FindFirstChild("BillboardGui")
                      if r11_20 then
                        r11_20:Destroy()
                      end
                    end
                    if r0_20 == "Highlight" then
                      local r11_20 = r10_20:FindFirstChild("Highlight")
                      if r11_20 then
                        r11_20:Destroy()
                      end
                    end
                  end
                end
              end
            end
            for toggleNoRecoil, r78_0 in pairs(workspace.AiZones:GetChildren()) do
              function toggleScreenEffect(r0_31)
                -- line: [0, 0] id: 31
                if r0_31:IsA("BillboardGui") or r0_31:IsA("Highlight") then
                  return 
                end
                if not r0_31:FindFirstChild("BillboardGui") and state.AINameTag then
                  task.wait(1.5)
                  if r0_31:FindFirstChild("Humanoid") then
                    local r1_31 = billboardTemplate:Clone()
                    r1_31.StudsOffset = Vector3.new(0, 1.75, 0)
                    local r2_31 = billboardTextTemplate:Clone()
                    r2_31.Text = r0_31.Name .. " | NPC"
                    r2_31.TextColor3 = state.NameTagColor
                    r2_31.TextSize = state.AiNameTagTextSize
                    r2_31.Parent = r1_31
                    r1_31.Parent = r0_31
                  end
                end
                if not r0_31:FindFirstChild("Highlight") and state.AIHighlight then
                  task.wait(2.5)
                  if r0_31:FindFirstChild("Humanoid") then
                    local r1_31 = highlightTemplate:Clone()
                    r1_31.Parent = r0_31
                    r1_31.FillColor = state.HighlightColor
                    r1_31.OutlineColor = state.HighlightColor
                  end
                end
              end
              r78_0.ChildAdded:Connect(toggleScreenEffect)
            end
            function onDroppedItemAdded(r0_43)
              -- line: [0, 0] id: 43
              local r1_43 = nil	-- notice: implicit variable refs by block#[1, 5]
              if r0_43 == true then
                function r1_43(r0_45)
                  -- line: [0, 0] id: 45
                  if r0_45:IsA("Folder") then
                    for r4_45, r5_45 in pairs(r0_45:GetChildren()) do
                      if r5_45:IsA("Folder") then
                        r1_43(r5_45)
                      end
                    end
                  elseif not r0_45:FindFirstChild("BillboardGui") and r41_0[r0_45.Name] and state.ContainerESP then
                    local r1_45 = billboardTemplate:Clone()
                    local r2_45 = billboardTextTemplate:Clone()
                    r2_45.Text = r0_45.Name .. " | Container"
                    r2_45.TextSize = state.ContainerTextSize
                    r2_45.TextColor3 = state.ContainerColor
                    r2_45.Parent = r1_45
                    r1_45.Parent = r0_45
                  end
                end
                for r5_43, r6_43 in pairs(workspace.Containers:GetChildren()) do
                  r1_43(r6_43)
                end
                -- close: r1_43
              else
                function r1_43(r0_44)
                  -- line: [0, 0] id: 44
                  if r0_44:IsA("Folder") then
                    for r4_44, r5_44 in pairs(r0_44:GetChildren()) do
                      if r5_44:IsA("Folder") then
                        r1_43(r5_44)
                      end
                    end
                  elseif state.ContainerESP and r0_44:FindFirstChild("BillboardGui") and not r41_0[r0_44.Name] then
                    r0_44:FindFirstChild("BillboardGui"):Destroy()
                  elseif (not state.ContainerESP or r0_43 == "Reload") and r0_44:FindFirstChild("BillboardGui") then
                    r0_44:FindFirstChild("BillboardGui"):Destroy()
                  end
                end
                for r5_43, r6_43 in pairs(workspace.Containers:GetChildren()) do
                  r1_43(r6_43)
                end
                -- close: r1_43
              end
            end
            function r78_0(r0_22)
              -- line: [0, 0] id: 22
              if r0_22:IsA("BillboardGui") then
                return 
              end
              if not r0_22:FindFirstChild("BillboardGui") and r41_0[r0_22.Name] and state.ContainerESP then
                local r1_22 = billboardTemplate:Clone()
                local r2_22 = billboardTextTemplate:Clone()
                r2_22.Text = r0_22.Name .. " | Container"
                r2_22.TextSize = state.ContainerTextSize
                r2_22.TextColor3 = state.ContainerColor
                r2_22.Parent = r1_22
                r1_22.Parent = r0_22
              end
            end
            featureConnections.Container = workspace.Containers.ChildAdded:Connect(r78_0)
            function r75_0(r0_286)
              -- line: [0, 0] id: 286
              if r0_286 == true then
                for r4_286, r5_286 in pairs(workspace.Vehicles:GetChildren()) do
                  if not r5_286:FindFirstChild("BillboardGui") then
                    local r6_286 = billboardTemplate:Clone()
                    local r7_286 = billboardTextTemplate:Clone()
                    r7_286.Text = r5_286.Name .. " | Vehicle"
                    r7_286.TextColor3 = state.VehicleColor
                    r7_286.TextSize = state.VehicleTextSize
                    r7_286.Parent = r6_286
                    r6_286.Parent = r5_286
                  end
                end
              else
                for r4_286, r5_286 in pairs(workspace.Vehicles:GetChildren()) do
                  if r5_286:FindFirstChild("BillboardGui") then
                    local r6_286 = r5_286:FindFirstChild("BillboardGui")
                    if r6_286 then
                      r6_286:Destroy()
                    end
                  end
                end
              end
            end
            function setDefaultFov(r0_290)
              -- line: [0, 0] id: 290
              if r0_290:IsA("BillboardGui") then
                return 
              end
              if not r0_290:FindFirstChild("BillboardGui") and state.VehicleTag then
                task.wait(0.75)
                local r1_290 = billboardTemplate:Clone()
                local r2_290 = billboardTextTemplate:Clone()
                r2_290.Text = r0_290.Name .. " | Vehicle"
                r2_290.TextColor3 = state.VehicleColor
                r2_290.TextSize = state.VehicleTextSize
                r2_290.Parent = r1_290
                r1_290.Parent = ExitBlock
              end
            end
            featureConnections.VehicleCon = workspace.Vehicles.ChildAdded:Connect(setDefaultFov)
            local r76_0 = {}
            local function toggleNoRecoil(r0_267)
              -- line: [0, 0] id: 267
              if r0_267 == true then
                for r4_267, r5_267 in pairs(game.ReplicatedStorage.AmmoTypes:GetChildren()) do
                  if not r76_0[r5_267] then
                    r76_0[r5_267] = r5_267:GetAttribute("RecoilStrength")
                  end
                  r5_267:SetAttribute("RecoilStrength", 0)
                end
              else
                for r4_267, r5_267 in pairs(game.ReplicatedStorage.AmmoTypes:GetChildren()) do
                  if r76_0[r5_267] then
                    r5_267:SetAttribute("RecoilStrength", r76_0[r5_267])
                  end
                end
              end
            end
            local noSpreadOriginals = {}
            function toggleNoSpread(r0_3)
              -- line: [0, 0] id: 3
              local ammoTypes = ReplicatedStorage:FindFirstChild("AmmoTypes")
              if not ammoTypes then
                return
              end

              for _, ammoType in ipairs(ammoTypes:GetChildren()) do
                if ammoType:GetAttribute("AccuracyDeviation") ~= nil then
                  if r0_3 == true then
                    if noSpreadOriginals[ammoType.Name] == nil then
                      noSpreadOriginals[ammoType.Name] = ammoType:GetAttribute("AccuracyDeviation")
                    end
                    ammoType:SetAttribute("AccuracyDeviation", 1)
                  else
                    local original = noSpreadOriginals[ammoType.Name]
                    if original ~= nil then
                      ammoType:SetAttribute("AccuracyDeviation", original)
                    end
                  end
                end
              end
            end
            function setDefaultFov(r0_42)
              -- line: [0, 0] id: 42
              local r1_42 = game.ReplicatedStorage.Players:FindFirstChild(localPlayer.Name)
              if r1_42 and r1_42:FindFirstChild("Settings") then
                local r2_42 = r1_42.Settings.GameplaySettings
                if r0_42 == "Fov" then
                  return 90
                end
                r2_42:SetAttribute("DefaultFOV", r0_42)
              end
            end
            local r80_0 = {}
            local function toggleScreenEffect(r0_308, r1_308)
              -- line: [0, 0] id: 308
              if r0_308 == "Visor" or r0_308 == "GasMask" then
                local r2_308 = localPlayer.PlayerGui:FindFirstChild("NoInsetGui")
                if r2_308 then
                  local r3_308 = r2_308.MainFrame:FindFirstChild("ScreenEffects")
                  if r3_308 and r0_308 == "Visor" and r3_308 then
                    if not r80_0.Visor then
                      r80_0.Visor = r3_308.Visor.Visible
                      r80_0.Mask = r3_308.Mask.Visible
                      r80_0.HelmetMask = r3_308.HelmetMask.Visible
                      r80_0.Flashbang = r3_308.Flashbang.Visible
                    end
                    if r1_308 == true then
                      r3_308.Visor.Visible = false
                      r3_308.HelmetMask.Visible = false
                      r3_308.Mask.Visible = false
                      r3_308.Flashbang.Visible = false
                    elseif r80_0.Visor then
                      r3_308.Visor.Visible = r80_0.Visor
                      r3_308.Mask.Visible = r80_0.Mask
                      r3_308.HelmetMask.Visible = r80_0.HelmetMask
                      r3_308.Flashbang.Visible = r80_0.Flashbang
                    end
                  elseif r3_308 then
                    local r4_308 = r3_308.Mask:FindFirstChild("GP5")
                    if r4_308 then
                      local r5_308 = r4_308.GasMask
                      if r5_308 and r5_308.Playing then
                        r5_308.Playing = false
                      end
                    end
                  end
                end
              elseif r0_308 == "InventoryBlur" then
                local r2_308 = game:FindFirstChild("Lighting")
                if r2_308 and r2_308:FindFirstChild("InventoryBlur") then
                  r2_308.InventoryBlur.Size = 0
                end
              elseif r0_308 == "Reapir" then
                local r2_308 = camera:FindFirstChild("ViewModel")
                if r2_308 and r2_308:FindFirstChild("Item") and r2_308.Item:FindFirstChild("Attachments") and r2_308.Item.Attachments:FindFirstChild("Sight") and r2_308.Item.Attachments.Sight:FindFirstChild("Reapir") and r2_308.Item.Attachments.Sight.Reapir.Reticle:FindFirstChild("PrismScopeGui") then
                  r2_308.Item.Attachments.Sight.Reapir.Reticle.PrismScopeGui.Sight.StaticLCD.Visible = not r1_308
                end
              elseif r0_308 == "Inventory" then
                local r2_308 = localPlayer.PlayerGui:FindFirstChild("MainGui")
                local r3_308 = false
                if r2_308 then
                  local r4_308 = r2_308:FindFirstChild("MainFrame")
                  if r4_308 then
                    return r4_308:FindFirstChild("BackpackFrame").Visible
                  end
                end
                return false
              end
            end
            local r82_0 = Instance.new("Highlight")
            local function togglePlayerChams(r0_15, r1_15)
              -- line: [0, 0] id: 15
              if r0_15 == localPlayer and state.Loaded or r0_15.Name == "MI24V" then
                return 
              end
              local function r2_15(r0_16, r1_16)
                -- line: [0, 0] id: 16
                local r2_16 = r0_16:FindFirstChild("HighlightVisible")
                local r3_16 = r0_16:FindFirstChild("HighlightHidden")
                if r1_16 then
                  if state.VisibleChams and not r2_16 then
                    local r4_16 = r82_0:Clone()
                    r4_16.Name = "HighlightVisible"
                    r4_16.FillColor = state.ChamColor
                    r4_16.OutlineColor = state.ChamColor
                    r4_16.DepthMode = Enum.HighlightDepthMode.Occluded
                    r4_16.Parent = r0_16
                  end
                  if state.HiddenChams and not r3_16 then
                    local r4_16 = r82_0:Clone()
                    r4_16.Name = "HighlightHidden"
                    r4_16.FillColor = state.ChamColor
                    r4_16.OutlineColor = state.ChamColor
                    r4_16.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    r4_16.Parent = r0_16
                  end
                else
                  if r2_16 then
                    r2_16:Destroy()
                  end
                  if r3_16 then
                    r3_16:Destroy()
                  end
                end
              end
              if r0_15.Character then
                r2_15(r0_15.Character, r1_15)
              end
            end
            local espMenuOverrideActive = false
            local espMenuBypassActive = false
            local function isEspEffectivelyEnabled()
              return playerEsp.Enabled and (not espMenuOverrideActive or espMenuBypassActive)
            end
            local function updatePlayerEspMenuOverride()
              playerEsp.MenuOverride = espMenuOverrideActive and not espMenuBypassActive
            end
            local function refreshPlayerChamsForEspState()
              for r4_15, r5_15 in ipairs(Players:GetChildren()) do
                togglePlayerChams(r5_15, false)
                if isEspEffectivelyEnabled() and state.Chams then
                  togglePlayerChams(r5_15, true)
                end
              end
            end
            local function setMenuEspOverride(r0_15)
              r0_15 = r0_15 and true or false
              if espMenuOverrideActive == r0_15 then
                return
              end
              espMenuOverrideActive = r0_15
              if not espMenuOverrideActive then
                espMenuBypassActive = false
              end
              updatePlayerEspMenuOverride()
              refreshPlayerChamsForEspState()
            end
            local r84_0 = {}
            local function spawnBulletTracer(r0_289)
              -- line: [0, 0] id: 289
              if not r0_289 and r0_289 ~= false then
                return  -- Exit if no position provided
              end
              local r2_289 = camera:FindFirstChild("ViewModel")
              local r1_289 = nil	-- notice: implicit variable refs by block#[4, 11, 13, 14]
              if r2_289 then
                local r3_289 = r2_289:FindFirstChild("Item")
                local r4_289 = r3_289:FindFirstChild("Attachments")
                local r5_289 = r3_289.Attachments:FindFirstChild("Front")
                if r5_289 and r5_289:FindFirstChild("Barrel") then
                  r1_289 = r5_289:FindFirstChild("Barrel")
                end
                if not r1_289 and r3_289 and r3_289:FindFirstChild("Attachments") then
                  local r6_289 = r3_289.Attachments:FindFirstChild("Front")
                  if r6_289 then
                    local r7_289 = r6_289:GetChildren()[1]
                    if r7_289 then
                      GunBarrel = r7_289:FindFirstChild("Barrel")
                      if GunBarrel then
                        r1_289 = GunBarrel
                      end
                    end
                  end
                end
              end
              if not r1_289 then
                return 
              end
              local r3_289 = Instance.new("Part")
              r3_289.Anchored = true
              r3_289.CanCollide = false
              r3_289.CanQuery = false
              r3_289.Transparency = 1
              r3_289.Parent = Workspace
              r3_289.Position = r1_289.Position
              r3_289.Name = "BulletStart"
              local r4_289 = Instance.new("Part")
              r4_289.Anchored = true
              r4_289.CanCollide = false
              r4_289.CanQuery = false
              r4_289.Transparency = 1
              r4_289.Parent = Workspace
              r4_289.Position = r1_289.Position
              r4_289.Name = "BulletEnd"
              local r5_289 = nil
              if r0_289 == false then
                r5_289 = workspace:Raycast(r1_289.Position, r1_289.CFrame.LookVector * 3500)
              else
                r5_289 = r0_289
              end
              if r5_289 and r0_289 == false then
                r4_289.Position = r5_289.Position
              else
                r4_289.Position = r5_289
              end
              local r6_289 = Instance.new("Beam")
              local r7_289 = Instance.new("Attachment", r3_289)
              local r8_289 = Instance.new("Attachment", r4_289)
              r7_289.Name = "BulletAttachment"
              r8_289.Name = "BulletAttachment1"
              r6_289.Attachment0 = r7_289
              r6_289.Attachment1 = r8_289
              r6_289.Color = ColorSequence.new(state.BulletTracerColor)
              r6_289.Width0 = 0.3
              r6_289.Width1 = 0.3
              r6_289.Brightness = 0.85
              r6_289.Transparency = NumberSequence.new(0)
              r6_289.LightEmission = 0
              r6_289.LightInfluence = 0
              r6_289.FaceCamera = true
              r6_289.TextureSpeed = 1.5
              r6_289.TextureLength = 1
              r6_289.Texture = state.BulletTracerTexture
              r6_289.Parent = Workspace
              r6_289.Name = "BulletBeam"
              task.wait(state.BulletTracerDelay)
              r6_289:Destroy()
              r3_289:Destroy()
              r4_289:Destroy()
            end
            local r86_0 = {}
            local r87_0 = {}
            local function scanWhitelistedItems()
              -- line: [0, 0] id: 284
              for r3_284, r4_284 in ipairs(Players:GetPlayers()) do
                Target = ReplicatedStorage.Players:FindFirstChild(r4_284.Name)
                if r4_284 ~= localPlayer and Target and not r86_0[r4_284.Name] then
                  if not r87_0[r4_284.Name] then
                    r87_0[r4_284.Name] = {}
                  end
                  if state.ItemFinderList then
                    local r5_284 = Target:FindFirstChild("Inventory")
                    if r5_284 then
                      for r9_284, r10_284 in pairs(r5_284:GetChildren()) do
                        if r10_284:GetAttribute("Slot"):find("Clothing") then
                          local r12_284 = r10_284:FindFirstChild("Inventory")
                          if r12_284 then
                            for r16_284, r17_284 in pairs(r12_284:GetChildren()) do
                              if state.ItemFinderList[r17_284.Name] and not r87_0[r4_284.Name][r17_284.Name] then
                                notify("Item | Finder", "Player: " .. r4_284.Name .. " Has an: " .. r17_284.Name, 5)
                                playerEsp.Special[r4_284.Name] = true
                                r86_0[r4_284.Name] = true
                                r87_0[r4_284.Name][r17_284.Name] = true
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
            local r89_0 = 90
            task.spawn(function()
            -- line: [0, 0] id: 56
              notify("GHOST_HOOK 3/5", "Creating UI", 2.5)
              local function loadUiLibrary()
                if isfile and readfile then
                  for _, path in ipairs({
                    "fucking real deal/library.txt",
                    "library.txt",
                    "ProjectDelta/library.txt",
                  }) do
                    if isfile(path) then
                      local ok, loadedLibrary = pcall(function()
                        local source = readfile(path)
                        return loadstring(source)()
                      end)
                      if ok and loadedLibrary then
                        return loadedLibrary
                      end
                    end
                  end
                end
                return loadGhostDependency("Library") --testlib
              end
              local r1_56 = loadUiLibrary().new("GHOST_HOOK | Project Delta |", "ProjectDelta")
              task.defer(function()
                local menuParent = CoreGui
                if gethui then
                  local ok, hui = pcall(gethui)
                  if ok and hui then
                    menuParent = hui
                  end
                end
                local menuGui = menuParent:FindFirstChild("unknown") or CoreGui:FindFirstChild("unknown")
                local mainFrame = menuGui and menuGui:FindFirstChild("Main")
                local baseFrame = menuGui and menuGui:FindFirstChild("Base", true)
                local tabButtons = mainFrame and mainFrame:FindFirstChild("TabButtons")
                local titleLabel = mainFrame and mainFrame:FindFirstChild("Title")
                local subtitleLabel = menuGui and menuGui:FindFirstChild("Subtitle", true)
                local function applyCompactSidebar()
                  if not baseFrame then
                    return
                  end
                  local sidebar = baseFrame:FindFirstChild("Sidebar")
                  local content = baseFrame:FindFirstChild("Content")
                  local sidebarWidth = 244
                  if sidebar then
                    sidebar.Size = UDim2.new(0, sidebarWidth, 1, 0)
                  end
                  if content then
                    content.Position = UDim2.fromScale(1, 0)
                    content.Size = UDim2.new(0, math.max(0, baseFrame.AbsoluteSize.X - sidebarWidth), 1, 0)
                  end
                  local sidebarGroup = sidebar and sidebar:FindFirstChild("SidebarGroup")
                  if not sidebarGroup then
                    return
                  end
                  local sidebarPadding = sidebarGroup:FindFirstChild("SidebarGroupUIPadding")
                  if sidebarPadding then
                    sidebarPadding.PaddingLeft = UDim.new(0, 6)
                    sidebarPadding.PaddingRight = UDim.new(0, 6)
                  end
                  local tabSwitchers = sidebarGroup:FindFirstChild("TabSwitchers")
                  if tabSwitchers then
                    tabSwitchers.Position = UDim2.new(0, 0, 0, 0)
                    tabSwitchers.Size = UDim2.new(1, 0, 1, -107)
                    for _, item in ipairs(tabSwitchers:GetDescendants()) do
                      if item.Name == "TabSwitcher" and item:IsA("TextButton") then
                        item.AnchorPoint = Vector2.new(0.5, 0)
                        item.Position = UDim2.new(0.5, 0, 0, 0)
                        item.Size = UDim2.new(1, -58, 0, 36)
                        local itemPadding = item:FindFirstChild("TabSwitcherUIPadding")
                        if itemPadding then
                          itemPadding.PaddingLeft = UDim.new(0, 12)
                          itemPadding.PaddingRight = UDim.new(0, 12)
                        end
                        local itemLayout = item:FindFirstChild("TabSwitcherUIListLayout")
                        if itemLayout then
                          itemLayout.Padding = UDim.new(0, 7)
                        end
                        local itemImage = item:FindFirstChild("TabImage")
                        if itemImage then
                          itemImage.Size = UDim2.fromOffset(16, 16)
                        end
                      elseif item.Name == "TabSwitcherName" and item:IsA("TextLabel") then
                        item.TextSize = 15
                      end
                    end
                  end
                  local ghostLogo = sidebarGroup:FindFirstChild("GhostLogo", true)
                  if ghostLogo then
                    ghostLogo.Position = UDim2.new(0, -14, 1, -10)
                    ghostLogo.Size = UDim2.new(1, 26, 0, 100)
                    local skull = ghostLogo:FindFirstChild("Skull")
                    if skull then
                      skull.Position = UDim2.new(0, 0, 1, -45)
                    end
                    for _, logoPart in ipairs({"Wordmark", "LuaL", "Lua"}) do
                      local part = ghostLogo:FindFirstChild(logoPart)
                      if part then
                        part.Position = UDim2.new(0, 58, 1, -146)
                      end
                    end
                  end
                end
                applyCompactSidebar()
                task.delay(0.2, applyCompactSidebar)
                task.delay(1, applyCompactSidebar)
                if subtitleLabel and subtitleLabel:IsA("TextLabel") then
                  subtitleLabel.RichText = true
                  subtitleLabel.Text = "Credits - KT.RK"
                  subtitleLabel.TextColor3 = Color3.fromRGB(133, 0, 255)
                  subtitleLabel.TextTransparency = 0
                end
                if tabButtons then
                  tabButtons.Position = UDim2.new(0, 0, 0, 79)
                  tabButtons.Size = UDim2.new(0, 120, 1, -80)
                end
                if titleLabel then
                  titleLabel.AnchorPoint = Vector2.new(0.5, 0)
                  titleLabel.Position = UDim2.new(0.5, 0, 0, 14)
                  titleLabel.Size = UDim2.new(1, -32, 0, 18)
                  titleLabel.TextXAlignment = Enum.TextXAlignment.Center
                end
                if mainFrame and mainFrame:FindFirstChild("SideBar") then
                  local sideBar = mainFrame.SideBar
                  sideBar.Position = UDim2.new(0, 2, 0, sideBar.Position.Y.Offset)
                end
                if mainFrame then
                  local function createLogo(parent, name, anchor, pos, imageId, size)
                    local logo = parent:FindFirstChild(name)
                    if not logo then
                      logo = Instance.new("ImageLabel")
                      logo.Name = name
                      logo.Parent = parent
                    end
                    logo.BackgroundTransparency = 1
                    logo.BorderSizePixel = 0
                    logo.AnchorPoint = anchor
                    logo.Position = pos
                    logo.Size = size or UDim2.new(0, 120, 0, 120)
                    logo.Image = imageId or "rbxassetid://116883290791010"
                    logo.ScaleType = Enum.ScaleType.Fit
                    logo.ZIndex = 50
                    return logo
                  end

                  createLogo(mainFrame, "CornerLogo", Vector2.new(0, 0), UDim2.new(0, 0, 0, 0), "rbxassetid://116883290791010", UDim2.new(0, 70, 0, 70))
                  createLogo(mainFrame, "CornerLogo2", Vector2.new(0, 0), UDim2.new(0, 70, 0, -50), "rbxassetid://91125138387121", UDim2.new(0, 200, 0, 200))
                  createLogo(mainFrame, "CornerLogo3", Vector2.new(0, 0), UDim2.new(0, 70, 0, -50), "rbxassetid://79446531787618", UDim2.new(0, 200, 0, 200))
                  createLogo(mainFrame, "CornerLogo4", Vector2.new(0, 0), UDim2.new(0, 70, 0, -50), "rbxassetid://103905886855383", UDim2.new(0, 200, 0, 200))
                end
              end)
              local r2_56 = r1_56.new_tab("rbxassetid://109366020496537", "Combat")
              local r3_56 = r1_56.new_tab("rbxassetid://119385181967075", "Visuals")
              local r4_56 = r1_56.new_tab("rbxassetid://139044864852433", "Movement")
              local r5_56 = r1_56.new_tab("rbxassetid://98375642144966", "Player")
              local r6_56 = r1_56.new_tab("rbxassetid://137174378463882", "World")
              local r6b_56 = r1_56.new_tab("rbxassetid://130943404476007", "Misc")
              local r6c_56 = r1_56.new_tab("rbxassetid://130507927595367", "Settings")
              local r7_56 = r2_56.new_section("Aimbot")
              local r9_56 = r6_56.new_section("Environment")
              local r10_56 = r5_56.new_section("Player")
              local r10b_56 = r4_56.new_section("Movement")
              local r8_56 = r3_56.new_section("ESP")
              local r8b_56 = r6b_56.new_section("Visual Tools")
              local r11_56 = r6b_56.new_section("Misc")
              local r12_56 = r6c_56.new_section("Settings")
              local r13_56 = r6b_56.new_section("Server / NPC")
              local r14_56 = r7_56.new_sector("Aimbot", "Left")
              local r15_56 = r7_56.new_sector("Aimbot Toggles", "Right")
              local r16_56 = r7_56.new_sector("Gun Mods", "Left")
              local r20_56 = r9_56.new_sector("Environment", "Left")
              local r20b_56 = r20_56
              local r28_56 = r9_56.new_sector("Cloud Changer", "Right")
              local r29_56 = r9_56.new_sector("Ambient Changer", "Right")
              local r30_56 = r9_56.new_sector("Time Changer", "Left")
              local r21_56 = r12_56.new_sector("Config", "Left")
              local r22_56 = r12_56.new_sector("Script Control", "Right")
              local r23_56 = r10_56.new_sector("Camera", "Right")
              local r24_56 = r10b_56.new_sector("Movement", "Left")
              local r24b_56 = r10b_56.new_sector("Movement Extras", "Right")
              local r25_56 = r10_56.new_sector("ViewModel", "Left")
              local r26_56 = r10_56.new_sector("Anti Aim", "Left")
              local r35_56 = r11_56.new_sector("Detection", "Left")
              local r17_56 = r8_56.new_sector("Player ESP", "Left")
              local r18_56 = r8_56.new_sector("Other ESP", "Right")
              local r19_56 = r11_56.new_sector("Inventory / Finder", "Left")
              local r27_56 = r13_56.new_sector("Boss Information", "Left")
              local aimbotVisualsLeft = r15_56
              local bulletTracerVisuals = r7_56.new_sector("Bullet Tracers", "Left")
              local r31_56 = r8b_56.new_sector("Crosshair", "Left")
              local r39_56 = r8b_56.new_sector("Screen Effects", "Right")
              local r32_56 = r12_56.new_sector("Themes", "Right")
              local r33_56 = r12_56.new_sector("Client", "Left")
              local r34_56 = r13_56.new_sector("NPC", "Right")
              local r36_56 = r10_56.new_sector("Skin Changer", "Right")
              local r37_56 = r11_56.new_sector("Warning Indicators", "Right")
              local r38_56 = r11_56.new_sector("Custom Hit Sound", "Right")
              local r40_56 = r11_56.new_sector("Sounds", "Right")
              local r40b_56 = r11_56.new_sector("Radar", "Left")
              local r41_56 = r12_56.new_sector("Key Binds", "Right")
              local r42_56 = r13_56.new_sector("Server Filter", "Right")
              local r42b_56 = r42_56
              local r43_56 = r42_56
              if not state.Lobby then
                local r44_56 = r42_56.element("Button", "Only Available In Lobby!", false, function(r0_217)
                  -- line: [0, 0] id: 217
                  notify("GHOST_HOOK", "This helps you find servers easier")
                end)
              end
              r14_56.element("Toggle", "Aimbot", false, function(r0_106)
                -- line: [0, 0] id: 106
                state.MasterAimbot = r0_106.Toggle
                keybindUi.UpdateKeybinds("Aimbot", "None", state.MasterAimbot, state.AimbotEnabled)
              end):add_keybind("Hold", function(r0_181)
                -- line: [0, 0] id: 181
                if r0_181.Active and state.MasterAimbot then
                  state.LastTarget = nil
                  state.AimbotEnabled = true
                else
                  state.AimbotEnabled = false
                  state.LastTarget = nil
                end
                keybindUi.UpdateKeybinds("Aimbot", r0_181.Key, state.MasterAimbot, state.AimbotEnabled)
              end)
              local r45_56 = r14_56.element("Toggle", "Target AI", false, function(r0_161)
                -- line: [0, 0] id: 161
                state.AimbotTargetAi = r0_161.Toggle
                state.ForceScan = true
              end)
              local r46_56 = r14_56.element("Toggle", "Target Players", false, function(r0_112)
                -- line: [0, 0] id: 112
                state.AimbotPlayer = r0_112.Toggle
                state.ForceScan = true
              end)
              local r47_56 = r14_56.element("Toggle", "Perfect Silent", false, function(r0_186)
                -- line: [0, 0] id: 186
                state.PerfectSilent = r0_186.Toggle
              end)
              local r48_56 = r14_56.element("Toggle", "Resolver", false, function(r0_229)
                -- line: [0, 0] id: 229
                state.Resolver = r0_229.Toggle
              end)
              local r49_56 = r14_56.element("Dropdown", "Aimbot Mode", {
                options = {
                  "Lock",
                  "Silent"
                },
              }, function(r0_208)
                -- line: [0, 0] id: 208
                if r0_208.Dropdown then
                  state.SilentAimbot = r0_208.Dropdown == "Silent"
                end
              end)
              local r50_56 = r14_56.element("Dropdown", "Aimbot Aim Part", {
                options = {
                  "Head",
                  "Torso",
                  "Left Arm",
                  "Right Arm",
                  "Left Leg",
                  "Right Leg",
                  "Smart Aiming"
                },
              }, function(r0_249)
                -- line: [0, 0] id: 249
                local r1_249 = {
                  Head = "Head",
                  Torso = "UpperTorso",
                  ["Left Arm"] = "LeftUpperArm",
                  ["Right Arm"] = "RightUpperArm",
                  ["Left Leg"] = "LeftUpperLeg",
                  ["Right Leg"] = "RightUpperLeg",
                }
                state.SmartAiming = r0_249.Dropdown == "Smart Aiming"
                state.AimPart = r1_249[r0_249.Dropdown] or "Head"
              end)
              local r50b_56 = r14_56.element("Dropdown", "Aimbot Aim Method", {
                options = {
                  "Closest to Crosshair",
                  "Furthest from Crosshair",
                  "Closest Distance"
                },
              }, function(r0_aimMethod)
                if r0_aimMethod.Dropdown then
                  state.AimbotAimMethod = r0_aimMethod.Dropdown
                  state.ForceScan = true
                end
              end)
              local r51_56 = r14_56.element("Slider", "Aimbot Smoothnes", {
                default = {
                  min = 1,
                  max = 50,
                  default = 1,
                },
              }, function(r0_71)
                -- line: [0, 0] id: 71
                state.AimbotSmoothness = r0_71.Slider
              end)
              local r54_56 = r14_56.element("Slider", "Silent Aim - Hit Chance", {
                default = {
                  min = 0,
                  max = 100,
                  default = 100,
                },
              }, function(r0_108)
                -- line: [0, 0] id: 108
                state.SilentHitChance = r0_108.Slider
              end)
              local r57_56 = r7_56.new_sector("FOV Circle", "Right")
              r57_56.element("Toggle", "Aimbot Tracer", false, function(r0_120)
                -- line: [0, 0] id: 120
                state.AimbotTracer = r0_120.Toggle
              end):add_color({
                Color = Color3.fromRGB(129, 210, 255),
              }, nil, function(r0_81)
                -- line: [0, 0] id: 81
                state.AimbotTracerColor = r0_81.Color
              end)
              r57_56.element("Toggle", "Aimbot Fov", false, function(r0_61)
                -- line: [0, 0] id: 61
                state.FovVisible = r0_61.Toggle
                fovMenuBypassActive = r0_61.Toggle and isMenuVisible()
                state.FOVCircle.Visible = isFovEffectivelyVisible() and 1 <= state.AimbotFov and state.MasterAimbot
              end):add_color({
                Color = Color3.fromRGB(129, 210, 255),
              }, nil, function(r0_164)
                -- line: [0, 0] id: 164
                state.FOVCircle.Color = r0_164.Color
              end)
              r57_56.element("Toggle", "Dynamic Aimbot Fov", false, function(r0_72)
                -- line: [0, 0] id: 72
                state.DynamicFov = r0_72.Toggle
              end)
              local r58_56 = r57_56.element("Slider", "Fov Radius", {
                default = {
                  min = 1,
                  max = 720,
                  default = 100,
                },
              }, function(r0_131)
                -- line: [0, 0] id: 131
                state.AimbotFov = r0_131.Slider
                state.ActualAimbotFov = state.AimbotFov
                state.FOVCircle.Radius = r0_131.Slider
                state.ForceScan = true
              end)
              local r59_56 = r57_56.element("Slider", "Fov Thickness", {
                default = {
                  min = 1,
                  max = 25,
                  default = 3,
                },
              }, function(r0_129)
                -- line: [0, 0] id: 129
                state.FOVCircle.Thickness = r0_129.Slider
              end)
              local r60_56 = r57_56.element("Slider", "Fov Transparency", {
                default = {
                  min = 0,
                  max = 100,
                  default = 50,
                },
              }, function(r0_205)
                -- line: [0, 0] id: 205
                state.FOVCircle.Transparency = r0_205.Slider / 100
              end)
              aimbotVisualsLeft.element("Toggle", "Show Aimbot Target (Chams)", false, function(r0_212)
                -- line: [0, 0] id: 212
                state.ShowTarget = r0_212.Toggle
                if not r0_212.Toggle then
                  ClearAimbotTargetVisuals()
                end
              end):add_color({
                Color = Color3.new(1, 0, 0),
              }, nil, function(r0_173)
                -- line: [0, 0] id: 173
                state.ShowTargetColor = r0_173.Color
                if aimTargetLabel then
                  aimTargetLabel.TextColor3 = state.ShowTargetColor
                end
                if state.ShowTarget and state.LastTarget then
                  ApplyTargetChams(state.LastTarget, true)
                end
              end)
              local r62b_56 = aimbotVisualsLeft.element("Slider", "Chams Transparency", {
                default = {
                  min = 0,
                  max = 100,
                  default = 10,
                },
              }, function(r0_254)
                -- line: [0, 0] id: 254
                state.ShowTargetTransparency = r0_254.Slider / 100
                if state.ShowTarget and state.LastTarget then
                  ApplyTargetChams(state.LastTarget, true)
                end
              end)
              local r63_56 = r15_56.element("Toggle", "Aimbot Prediction", false, function(r0_250)
                -- line: [0, 0] id: 250
                state.Prediction = r0_250.Toggle
                state.predictionEnabled = r0_250.Toggle
                if r0_250.Toggle then
                  state.predictionCache = {}
                end
              end)
              local r64_56 = r15_56.element("Toggle", "Auto Shoot", false, function(r0_107)
                -- line: [0, 0] id: 107
                state.AutoShoot = r0_107.Toggle
                if not r0_107.Toggle then
                  state.AutoShootHoldActive = false
                  mouse1release()
                end
              end)
              local r65_56 = r15_56.element("Dropdown", "Auto Shoot Mode", {
                options = {
                  "Rapid",
                  "Hold"
                },
              }, function(r0_259)
                -- line: [0, 0] id: 259
                state.AutoShootMode = r0_259.Dropdown
                if r0_259.Dropdown == "Hold" then
                  state.AutoShootHoldActive = false
                  mouse1release()
                end
              end)
              local r66_56 = r15_56.element("Slider", "Rapid Fire Speed (ms)", {
                default = {
                  min = 10,
                  max = 500,
                  default = 50,
                },
              }, function(r0_260)
                -- line: [0, 0] id: 260
                state.AutoShootSpeed = r0_260.Slider / 1000
              end)
              local r67_56 = r15_56.element("Toggle", "Freeze Target (Players Only)", false, function(r0_256)
                -- line: [0, 0] id: 256
                state.FreezeTarget = r0_256.Toggle
              end)
              r15_56.element("Toggle", "Wall Check", false, function(r0_248)
                -- line: [0, 0] id: 248
                state.WallCheck = r0_248.Toggle
                state.ForceScan = true
                if not r0_248.Toggle then
                  wallBang.wallBangTargets = {}
                  state._wallBangInfo = nil
                  wallBang.hideIndicator()
                end
              end)
              r15_56.element("Toggle", "Wall Bang", false, function(r0_310)
                state.WallBang = r0_310.Toggle
                if not r0_310.Toggle then
                  wallBang.wallBangTargets = {}
                  state._wallBangInfo = nil
                  wallBang.hideIndicator()
                end
              end)
              r15_56.element("Slider", "Wall Bang Max Walls", {
                default = {
                  min = 1,
                  max = 5,
                  default = 3,
                },
              }, function(r0_311)
                state.WallBangMaxWalls = r0_311.Slider
              end)
              r15_56.element("Slider", "Wall Bang Damage %", {
                default = {
                  min = 0,
                  max = 100,
                  default = 70,
                },
              }, function(r0_312)
                state.WallBangMultiplier = r0_312.Slider / 100
              end)
              r15_56.element("Toggle", "Wall Bang Indicator", false, function(r0_313)
                state.WallBangIndicator = r0_313.Toggle
                if not r0_313.Toggle then
                  wallBang.hideIndicator()
                end
              end)
              local r69_56 = r15_56.element("Toggle", "Team Check", false, function(r0_66)
                -- line: [0, 0] id: 66
                state.TeamCheck = r0_66.Toggle
                state.ForceScan = true
              end)
              local r70_56 = r15_56.element("Toggle", "Sticky Aimbot Target", false, function(r0_230)
                -- line: [0, 0] id: 230
                state.StickyAim = r0_230.Toggle
              end)
              local r71_56 = r16_56.element("Toggle", "No Recoil | Instant Mosin", false, function(r0_228)
                -- line: [0, 0] id: 228
                toggleNoRecoil(r0_228.Toggle)
              end)
              local r72_56 = r16_56.element("Toggle", "No Spread", false, function(r0_114)
                -- line: [0, 0] id: 114
                toggleNoSpread(r0_114.Toggle)
              end)
              local r73_56 = r16_56.element("Toggle", "Instant Equip", false, function(r0_76)
                -- line: [0, 0] id: 76
                state.InstantEquip = r0_76.Toggle
              end)
              bulletTracerVisuals.element("Toggle", "Bullet Tracers", false, function(r0_75)
                -- line: [0, 0] id: 75
                state.BulletTracer = r0_75.Toggle
              end):add_color({
                Color = Color3.fromRGB(255, 255, 255),
              }, nil, function(r0_140)
                -- line: [0, 0] id: 140
                state.BulletTracerColor = r0_140.Color
              end)
              local r74_56 = bulletTracerVisuals.element("Slider", "Bullet Tracer Despawn Delay", {
                default = {
                  min = 5,
                  max = 100,
                  default = 50,
                },
              }, function(r0_73)
                -- line: [0, 0] id: 73
                state.BulletTracerDelay = r0_73.Slider / 100
              end)
              local r75_56 = bulletTracerVisuals.element("Dropdown", "Bullet Tracer Texture", {
                options = {
                  "Light",
                  "Lightning",
                  "Tiny Lightning",
                  "Wave",
                  "Beam",
                  "Surge"
                },
              }, function(r0_177)
                -- line: [0, 0] id: 177
                local r1_177 = state.BulletTracerTextures[r0_177.Dropdown]
                if r1_177 then
                  state.BulletTracerTexture = r1_177
                end
              end)
              local r76_56 = workspace.Camera.DescendantAdded:Connect(function(r0_236)
                -- line: [0, 0] id: 236
                if state.BulletTracer and r0_236.Name == "Smoke" or r0_236.Name == "SmokeLittle" then
                  spawnBulletTracer(false)
                end
              end)
              local r79_56 = r17_56.element("Toggle", "ESP MasterSwitch", false, function(r0_65)
                -- line: [0, 0] id: 65
                playerEsp.Enabled = r0_65.Toggle
                espMenuBypassActive = r0_65.Toggle and isMenuVisible()
                updatePlayerEspMenuOverride()
                refreshPlayerChamsForEspState()
              end)
              local r80_56 = r17_56.element("Slider", "Max ESP Distance", {
                default = {
                  min = 100,
                  max = 5000,
                  default = 5000,
                },
              }, function(r0_105)
                -- line: [0, 0] id: 105
                playerEsp.MaxDistance = r0_105.Slider
              end)
              r17_56.element("Toggle", "NameTag ESP", false, function(r0_67)
                -- line: [0, 0] id: 67
                playerEsp.ShowName = r0_67.Toggle
              end):add_color({
                Color = Color3.fromRGB(255, 255, 255),
              }, nil, function(r0_198)
                -- line: [0, 0] id: 198
                playerEsp.NameColor = r0_198.Color
              end)
              r17_56.element("Toggle", "Health Bar ESP", false, function(r0_167)
                -- line: [0, 0] id: 167
                playerEsp.ShowHealth = r0_167.Toggle
              end):add_color({
                Color = Color3.fromRGB(0, 255, 0),
              }, nil, function(r0_231)
                -- line: [0, 0] id: 231
                playerEsp.HealthHighColor = r0_231.Color
              end)
              r17_56.element("Toggle", "Distance ESP", false, function(r0_59)
                -- line: [0, 0] id: 59
                playerEsp.ShowDistance = r0_59.Toggle
              end):add_color({
                Color = Color3.fromRGB(255, 255, 255),
              }, nil, function(r0_127)
                -- line: [0, 0] id: 127
                playerEsp.DistanceColor = r0_127.Color
              end)
              local r84_56 = r17_56.element("Toggle", "Distance ESP | Studs To Meters", false, function(r0_252)
                -- line: [0, 0] id: 252
                playerEsp.StudsToMeters = r0_252.Toggle
              end)
              r17_56.element("Toggle", "Skeleton ESP", false, function(r0_221)
                -- line: [0, 0] id: 221
                playerEsp.ShowSkeletons = r0_221.Toggle
              end):add_color({
                Color = Color3.fromRGB(255, 255, 255),
              }, nil, function(r0_123)
                -- line: [0, 0] id: 123
                playerEsp.SkeletonsColor = r0_123.Color
              end)
              r17_56.element("Toggle", "Box ESP", false, function(r0_145)
                -- line: [0, 0] id: 145
                playerEsp.ShowBox = r0_145.Toggle
              end):add_color({
                Color = Color3.fromRGB(255, 255, 255),
              }, nil, function(r0_60)
                -- line: [0, 0] id: 60
                playerEsp.BoxColor = r0_60.Color
              end)
              r17_56.element("Toggle", "Active Weapon ESP", false, function(r0_182)
                -- line: [0, 0] id: 182
                playerEsp.ActiveGun = r0_182.Toggle
              end):add_color({
                Color = Color3.fromRGB(255, 255, 255),
              }, nil, function(r0_147)
                -- line: [0, 0] id: 147
                playerEsp.ActiveGunColor = r0_147.Color
              end)
              r17_56.element("Toggle", "Chams", false, function(r0_238)
                -- line: [0, 0] id: 238
                state.Chams = r0_238.Toggle
                for r4_238, r5_238 in ipairs(Players:GetChildren()) do
                  togglePlayerChams(r5_238, false)
                  if isEspEffectivelyEnabled() and state.Chams then
                    togglePlayerChams(r5_238, true)
                  end
                end
              end):add_color({
                Color = Color3.fromRGB(255, 255, 255),
              }, nil, function(r0_170)
                -- line: [0, 0] id: 170
                state.ChamColor = r0_170.Color
                for r4_170, r5_170 in ipairs(Players:GetChildren()) do
                  togglePlayerChams(r5_170, false)
                  if isEspEffectivelyEnabled() and state.Chams then
                    togglePlayerChams(r5_170, true)
                  end
                end
              end)
              local r89_56 = r17_56.element("Dropdown", "Chams Mode", {
                options = {
                  "Always Show Chams",
                  "Only When Visible Show Chams"
                },
              }, function(r0_222)
                -- line: [0, 0] id: 222
                if r0_222.Dropdown == "Always Show Chams" then
                  state.HiddenChams = true
                  state.VisibleChams = false
                else
                  state.HiddenChams = false
                  state.VisibleChams = true
                end
                for r4_222, r5_222 in ipairs(Players:GetChildren()) do
                  togglePlayerChams(r5_222, false)
                  if isEspEffectivelyEnabled() and state.Chams then
                    togglePlayerChams(r5_222, true)
                  end
                end
              end)
              r18_56.element("Toggle", "Dropped Items ESP", false, function(r0_153)
                -- line: [0, 0] id: 153
                state.DroppedItemESP = r0_153.Toggle
                toggleDroppedItemOrCorpseEsp(r0_153.Toggle)
              end):add_color({
                Color = state.DroppedItemColor,
              }, nil, function(r0_116)
                -- line: [0, 0] id: 116
                state.DroppedItemColor = r0_116.Color
                if state.DroppedItemESP then
                  toggleDroppedItemOrCorpseEsp(false)
                  toggleDroppedItemOrCorpseEsp(true)
                end
              end)
              local r91_56 = r18_56.element("Slider", "Dropped Item ESP Text Size", {
                default = {
                  min = 1,
                  max = 20,
                  default = 11,
                },
              }, function(r0_165)
                -- line: [0, 0] id: 165
                state.DroppedItemTextSize = r0_165.Slider
                if state.DroppedItemESP then
                  toggleDroppedItemOrCorpseEsp(false)
                  toggleDroppedItemOrCorpseEsp(true)
                end
              end)
              r18_56.element("Toggle", "Corpse ESP", false, function(r0_62)
                -- line: [0, 0] id: 62
                state.CorpseESP = r0_62.Toggle
                if r0_62.Toggle then
                  toggleDroppedItemOrCorpseEsp("Humanoid")
                else
                  toggleDroppedItemOrCorpseEsp("HumanoidRemove")
                end
              end):add_color({
                Color = state.CorpseColor,
              }, nil, function(r0_242)
                -- line: [0, 0] id: 242
                state.CorpseColor = r0_242.Color
                if state.CorpseESP then
                  toggleDroppedItemOrCorpseEsp("HumanoidRemove")
                  task.wait(0.01)
                  toggleDroppedItemOrCorpseEsp("Humanoid")
                end
              end)
              local r93_56 = r18_56.element("Slider", "Corpse ESP Text Size", {
                default = {
                  min = 1,
                  max = 20,
                  default = 11,
                },
              }, function(r0_79)
                -- line: [0, 0] id: 79
                state.CorpseTextSize = r0_79.Slider
                if state.CorpseESP then
                  Corpse(false)
                  Corpse(true)
                end
              end)
              r18_56.element("Toggle", "Container ESP", false, function(r0_227)
                -- line: [0, 0] id: 227
                state.ContainerESP = r0_227.Toggle
                onDroppedItemAdded(r0_227.Toggle)
              end):add_color({
                Color = state.ContainerColor,
              }, nil, function(r0_135)
                -- line: [0, 0] id: 135
                state.ContainerColor = r0_135.Color
                if state.ContainerESP then
                  onDroppedItemAdded(false)
                  onDroppedItemAdded(true)
                end
              end)
              local r95_56 = r18_56.element("Combo", "Container Whitelist", {
                options = {
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
                  nil
                },
              }, function(r0_219)
                -- line: [0, 0] id: 219
                for r4_219, r5_219 in pairs(r41_0) do
                  r41_0[r4_219] = false
                end
                for r4_219, r5_219 in ipairs(r0_219.Combo) do
                  r41_0[r5_219] = true
                end
                if state.ContainerESP then
                  onDroppedItemAdded(false)
                  onDroppedItemAdded(true)
                else
                  onDroppedItemAdded(false)
                end
              end)
              local r96_56 = r18_56.element("Slider", "Container ESP Text Size", {
                default = {
                  min = 1,
                  max = 20,
                  default = 11,
                },
              }, function(r0_68)
                -- line: [0, 0] id: 68
                state.ContainerTextSize = r0_68.Slider
                if state.ContainerESP then
                  onDroppedItemAdded("Reload")
                  onDroppedItemAdded(true)
                end
              end)
              r18_56.element("Toggle", "Exit ESP", false, function(r0_133)
                -- line: [0, 0] id: 133
                state.ExitESP = r0_133.Toggle
                toggleExitEsp(state.ExitESP)
              end):add_color({
                Color = state.ExitColor,
              }, nil, function(r0_172)
                -- line: [0, 0] id: 172
                state.ExitColor = r0_172.Color
                if state.ExitESP then
                  toggleExitEsp(false)
                  toggleExitEsp(true)
                end
              end)
              local r98_56 = r18_56.element("Slider", "Exit ESP Text Size", {
                default = {
                  min = 1,
                  max = 20,
                  default = 11,
                },
              }, function(r0_213)
                -- line: [0, 0] id: 213
                state.ExitTextSize = r0_213.Slider
                if state.ExitESP then
                  toggleExitEsp(false)
                  toggleExitEsp(true)
                end
              end)
              r18_56.element("Toggle", "Quest Item ESP", false, function(r0_115)
                -- line: [0, 0] id: 115
                state.QuestESP = r0_115.Toggle
                toggleQuestItemEsp(r0_115.Toggle)
              end):add_color({
                Color = state.QuestESPColor,
              }, nil, function(r0_144)
                -- line: [0, 0] id: 144
                state.QuestESPColor = r0_144.Color
                if state.QuestESP then
                  toggleQuestItemEsp(false)
                  toggleQuestItemEsp(true)
                end
              end)
              local r100_56 = r18_56.element("Slider", "Quest Item ESP Text Size", {
                default = {
                  min = 1,
                  max = 20,
                  default = 11,
                },
              }, function(r0_245)
                -- line: [0, 0] id: 245
                state.QuestTextSize = r0_245.Slider
                if state.QuestESP then
                  toggleQuestItemEsp(false)
                  toggleQuestItemEsp(true)
                end
              end)
              r18_56.element("Toggle", "Vehicle ESP", false, function(r0_258)
                -- line: [0, 0] id: 258
                state.VehicleTag = r0_258.Toggle
                r75_0(r0_258.Toggle)
              end):add_color({
                Color = state.VehicleColor,
              }, nil, function(r0_163)
                -- line: [0, 0] id: 163
                state.VehicleColor = r0_163.Color
                if state.VehicleTag then
                  r75_0(false)
                  r75_0(true)
                end
              end)
              local r102_56 = r18_56.element("Slider", "Vehicle ESP Text Size", {
                default = {
                  min = 1,
                  max = 20,
                  default = 11,
                },
              }, function(r0_257)
                -- line: [0, 0] id: 257
                state.VehicleTextSize = r0_257.Slider
                if state.VehicleTag then
                  r75_0(false)
                  r75_0(true)
                end
              end)
              r18_56.element("Toggle", "Ai Chams ESP", false, function(r0_223)
                -- line: [0, 0] id: 223
                state.AIHighlight = r0_223.Toggle
                if state.AIHighlight then
                  toggleAiEsp(true)
                else
                  toggleAiEsp("Highlight")
                end
              end):add_color({
                Color = state.HighlightColor,
              }, nil, function(r0_215)
                -- line: [0, 0] id: 215
                state.HighlightColor = r0_215.Color
                if state.AIHighlight == true then
                  toggleAiEsp("Highlight")
                  toggleAiEsp(true)
                end
              end)
              r18_56.element("Toggle", "Ai Nametag ESP", false, function(r0_148)
                -- line: [0, 0] id: 148
                state.AINameTag = r0_148.Toggle
                if state.AINameTag == true then
                  toggleAiEsp(true)
                else
                  toggleAiEsp("NameTag")
                end
              end):add_color({
                Color = state.NameTagColor,
              }, function(r0_185)
                -- line: [0, 0] id: 185
                state.NameTagColor = r0_185.Color
                if state.AINameTag == true then
                  toggleAiEsp("NameTag")
                  toggleAiEsp(true)
                end
              end)
              local r105_56 = r18_56.element("Slider", "AI ESP Text Size", {
                default = {
                  min = 1,
                  max = 20,
                  default = 11,
                },
              }, function(r0_169)
                -- line: [0, 0] id: 169
                state.AiNameTagTextSize = r0_169.Slider
                if state.AINameTag == true then
                  toggleAiEsp("NameTag")
                  toggleAiEsp(true)
                end
              end)
              r19_56.element("Toggle", "Inventory Checker", false, function(r0_78)
                -- line: [0, 0] id: 78
                state.InvChecker = r0_78.Toggle
                keybindUi.UpdateKeybinds("Inventory Checker", "None", state.InvChecker, state.InvCheckerActive)
              end):add_keybind("Hold", function(r0_128)
                -- line: [0, 0] id: 128
                if state.InvChecker and r0_128.Active then
                  state.InvCheckerActive = true
                else
                  state.InvCheckerActive = false
                end
                keybindUi.UpdateKeybinds("Inventory Checker", r0_128.Key, state.InvChecker, state.InvCheckerActive)
              end)
              local r107_56 = r19_56.element("Combo", "Inventory Check Toggles", {
                options = {
                  "Inventory Check Corpses",
                  "Show Full Inventory",
                  "Show Inventory Value"
                },
              }, function(r0_178)
                -- line: [0, 0] id: 178
                state.FullInventoryChecker = false
                state.InventoryCheckCorpse = false
                state.AIChecker = false
                for r4_178, r5_178 in ipairs(r0_178.Combo) do
                  if r5_178 == "Inventory Check Corpses" then
                    state.InventoryCheckCorpse = true
                  end
                  if r5_178 == "Show Full Inventory" then
                    state.FullInventoryChecker = true
                  end
                  if r5_178 == "Show Inventory Value" then
                    state.InvCheckValue = true
                  end
                end
              end)
              r19_56.element("Toggle", "Show Inventory Check Target", false, function(r0_83)
                -- line: [0, 0] id: 83
                state.InvCheckTarget = r0_83.Toggle
              end):add_color({
                Color = Color3.fromRGB(255, 255, 255),
              }, nil, function(r0_210)
                -- line: [0, 0] id: 210
                inventoryViewerTitle.TextColor3 = r0_210.Color
              end)
              r40b_56.element("Toggle", "Radar", false, function(r0_303)
                state.Radar = r0_303.Toggle
                setPlayerRadarEnabled(r0_303.Toggle)
              end)
              local r109_56 = r27_56.element("Toggle", "Boss Information", false, function(r0_224)
                -- line: [0, 0] id: 224
                state.ShowBoss = r0_224.Toggle
              end)
              local r110_56 = r27_56.element("Toggle", "Movable Boss Information GUI", false, function(r0_168)
                -- line: [0, 0] id: 168
                state.BossMovable = r0_168.Toggle
              end)
              local r111_56 = r35_56.element("Toggle", "Mod Detector", false, function(r0_113)
                -- line: [0, 0] id: 113
                state.ModDetector = r0_113.Toggle
                if r0_113.Toggle then
                  notify("Mod Dectector", "Preview Of Mod Detector", 1.5)
                end
              end)
              local r112_56 = r35_56.element("Toggle", "Cheater Detector - Requires Mod Detector", false, function(r0_192)
                -- line: [0, 0] id: 192
                state.CheatDetector = r0_192.Toggle
                if r0_192.Toggle then
                  notify("Cheater Detector", "Preview Of Cheater Detector", 1.5)
                end
              end)
              local r113_56 = r19_56.element("Toggle", "Item Finder", false, function(r0_188)
                -- line: [0, 0] id: 188
                state.ItemFinder = r0_188.Toggle
                if r0_188.Toggle then
                  scanWhitelistedItems()
                  notify("Item Finder", "Preview Of Item Finder", 1.5)
                end
              end)
              local r114_56 = r19_56.element
              local r115_56 = "Combo"
              local r116_56 = "Item Whitelist"
              r114_56 = r114_56(r115_56, r116_56, {
                options = {
                  "TFZ98S",
                  "R700",
                  "M4",
                  "AsVal",
                  "PKM",
                  "FlareGun",
                  "SPSh44",
                  "Gold",
                  "GoldWatch",
                  "RepairKit"
                },
              }, function(r0_214)
                -- line: [0, 0] id: 214
                state.ItemFinderList = {}
                for r4_214, r5_214 in ipairs(r0_214.Combo) do
                  if r5_214 == "Gold" then
                    state.ItemFinderList.Gold50g = true
                  else
                    state.ItemFinderList[r5_214] = true
                  end
                end
                if state.ItemFinder then
                  scanWhitelistedItems()
                end
              end)
              r115_56 = r20_56.element("Toggle", "No Grass", false, function(r0_220)
                -- line: [0, 0] id: 220
                sethiddenproperty(workspace.Terrain, "Decoration", not r0_220.Toggle)
              end)
              function r116_56()
                -- line: [0, 0] id: 143
                for r4_143, r5_143 in pairs(workspace:FindFirstChild("SpawnerZones").Foliage:GetDescendants()) do
                  if r5_143:FindFirstChildOfClass("SurfaceAppearance") then
                    if state.Foliage == true then
                      r5_143.Transparency = 1
                    else
                      r5_143.Transparency = 0
                    end
                  end
                end
                while state.Foliage do
                  task.wait(10)
                  r116_56()
                end
              end
              local r117_56 = r20_56.element("Toggle", "No Leafs", false, function(r0_197)
                -- line: [0, 0] id: 197
                state.Foliage = r0_197.Toggle
                r116_56()
              end)
              local r118_56 = r20b_56.element("Toggle", "No Clouds", false, function(r0_180)
                -- line: [0, 0] id: 180
                if workspace.Terrain:FindFirstChild("Clouds") then
                  workspace.Terrain.Clouds.Enabled = not r0_180.Toggle
                end
              end)
              r28_56.element("Toggle", "Cloud Changer", false, function(r0_109)
                -- line: [0, 0] id: 109
                state.CloudChanger = r0_109.Toggle
                local r1_109 = game.Workspace.Terrain:FindFirstChild("Clouds")
                if state.CloudChanger and r1_109 then
                  r1_109.Color = state.CloudColor
                end
              end):add_color({
                Color = Color3.fromRGB(50, 15, 95),
              }, nil, function(r0_159)
                -- line: [0, 0] id: 159
                state.CloudColor = r0_159.Color
                if state.CloudChanger and game.Workspace.Terrain:FindFirstChild("Clouds") then
                  game.Workspace.Terrain:FindFirstChild("Clouds").Color = state.CloudColor
                end
              end)
              local r120_56 = 0.25
              local r121_56 = r28_56.element("Slider", "Cloud Transparency", {
                default = {
                  min = 1,
                  max = 100,
                  default = 25,
                },
              }, function(r0_241)
                -- line: [0, 0] id: 241
                r120_56 = r0_241.Slider / 100
                if state.CloudChanger and game.Workspace.Terrain:FindFirstChild("Clouds") then
                  game.Workspace.Terrain:FindFirstChild("Clouds").Density = r0_241.Slider / 100
                end
              end)
              r29_56.element("Toggle", "Ambient Changer", false, function(r0_160)
                -- line: [0, 0] id: 160
                state.AmbientChanger = r0_160.Toggle
                local r1_160 = game.Lighting
                if r0_160.Toggle and r1_160 then
                  r1_160.Ambient = state.AmbientColor
                else
                  r1_160.Ambient = Color3.fromRGB(25, 25, 25)
                end
              end):add_color({
                Color = Color3.fromRGB(129, 5, 255),
              }, nil, function(r0_122)
                -- line: [0, 0] id: 122
                state.AmbientColor = r0_122.Color
                local r1_122 = game.Lighting
                if state.AmbientChanger and r1_122 then
                  r1_122.Ambient = state.AmbientColor
                end
              end)
              local r123_56 = r29_56.element("Toggle", "RGB Ambient", false, function(r0_146)
                -- line: [0, 0] id: 146
                state.AmbientChangerRGB = r0_146.Toggle
              end)
              local r124_56 = r29_56.element("Slider", "Ambient RGB Speed", {
                default = {
                  min = 10,
                  max = 125,
                  default = 50,
                },
              }, function(r0_255)
                -- line: [0, 0] id: 255
                state.AmbientChangerRGBSpeed = r0_255.Slider / 100
              end)
              local r125_56 = r30_56.element("Toggle", "Time Changer", false, function(r0_190)
                -- line: [0, 0] id: 190
                state.TimeChanger = r0_190.Toggle
              end)
              local r126_56 = r30_56.element("Slider", "Time", {
                default = {
                  min = 0,
                  max = 2400,
                  default = 1200,
                },
              }, function(r0_237)
                -- line: [0, 0] id: 237
                state.CurrentTime = r0_237.Slider / 100
                if state.CurrentTime >= 0 then
                  state.CurrentTime = string.format("%02d:%02d:00", math.floor(state.CurrentTime), r0_237.Slider % 100)
                end
              end)
              local r127_56 = r24_56.element("Toggle", "Omni Sprint", false, function(r0_216)
                -- line: [0, 0] id: 216
                state.OmniSprint = r0_216.Toggle
              end)
              r24_56.element("Toggle", "Speed Hack - Risky", false, function(r0_156)
                -- line: [0, 0] id: 156
                state.SpeedHackToggle = r0_156.Toggle
                keybindUi.UpdateKeybinds("Speed Hack", "None", state.SpeedHackToggle, state.SpeedHackActive)
              end):add_keybind("Hold", function(r0_206)
                -- line: [0, 0] id: 206
                if r0_206.Active and state.SpeedHackToggle then
                  state.SpeedHackActive = true
                else
                  state.SpeedHackActive = false
                end
                keybindUi.UpdateKeybinds("Speed Hack", r0_206.Key, state.SpeedHackToggle, state.SpeedHackActive)
              end)
              local r129_56 = r24_56.element("Toggle", "Silent Speed Hack", false, function(r0_117)
                -- line: [0, 0] id: 117
                state.SpeedHackSilent = r0_117.Toggle
              end)
              local r130_56 = r24_56.element("Slider", "Speed Hack Speed", {
                default = {
                  min = 5,
                  max = 17,
                  default = 17,
                },
              }, function(r0_191)
                -- line: [0, 0] id: 191
                state.SpeedHackSpeed = r0_191.Slider / 1.3
              end)
              local r130b_56 = r14_56.element("Toggle", "UG Resolver (C)", false, function(r0_300)
	state.AnimDown = r0_300.Toggle
              end)
              local function updateAntiAimKeybindIndicator()
                keybindUi.UpdateKeybinds("Anti-Aim", state.AntiAimKey or "None", state.FlipMode, state.AntiAimEnabled)
              end
              local function setAntiAimActive(r0_301)
                if r0_301 and not state.FlipMode then
                  r0_301 = false
                end
                if r0_301 then
                  state.AntiAimEnabled = true
                  state.FlipModeEnabled = true
                  if enableAntiAim then
                    enableAntiAim(state.AntiAimMode)
                  end
                else
                  state.AntiAimEnabled = false
                  state.FlipModeEnabled = false
                  if disableAntiAim then
                    disableAntiAim()
                  end
                end
                updateAntiAimKeybindIndicator()
              end
              local function inputMatchesAntiAimBind(r0_302)
                local r1_302 = state.AntiAimKey or "NONE"
                if r1_302 == "NONE" or r1_302 == "None" then
                  return false
                end
                if state.AntiAimKeyType == "UserInputType" then
                  return r0_302.UserInputType and r0_302.UserInputType.Name == r1_302
                end
                return r0_302.UserInputType == Enum.UserInputType.Keyboard and r0_302.KeyCode and r0_302.KeyCode.Name == r1_302
              end
              local r130c_56 = r26_56.element("Toggle", "Anti-Aim", false, function(r0_301)
                state.FlipMode = r0_301.Toggle
                if not r0_301.Toggle then
                  setAntiAimActive(false)
                else
                  updateAntiAimKeybindIndicator()
                end
              end)
              r130c_56:add_keybind("None", function(r0_302)
                state.AntiAimKey = r0_302.Key or "NONE"
                state.AntiAimKeyType = r0_302.KeyType
                updateAntiAimKeybindIndicator()
              end)
              featureConnections.AntiAimInput = UserInputService.InputBegan:Connect(function(r0_302, r1_302)
                if r1_302 or not state.FlipMode or not inputMatchesAntiAimBind(r0_302) then
                  return
                end
                setAntiAimActive(not state.AntiAimEnabled)
              end)
              local r130d_56 = r26_56.element("Dropdown", "Anti-Aim Mode", {
                options = {
                  "Flip",
                  "Yaw",
                  "Roll",
                  "Spin"
                },
              }, function(r0_303)
                state.AntiAimMode = r0_303.Dropdown or "Flip"
                if state.AntiAimEnabled then
                  if disableAntiAim then
                    disableAntiAim()
                  end
                  task.wait(0.05)
                  if enableAntiAim then
                    enableAntiAim(state.AntiAimMode)
                  end
                end
              end)
              local r131_56 = r24b_56.element("Toggle", "Infinity Jump - Risky", false, function(r0_253)
                -- line: [0, 0] id: 253
                state.InfinityJump = r0_253.Toggle
              end)
              r24b_56.element("Toggle", "Bunny Hop", false, function(r0_63)
                -- line: [0, 0] id: 63
                state.BunnyHop = r0_63.Toggle
                keybindUi.UpdateKeybinds("Bunny Hop", "None", state.BunnyHop, state.BunnyHopActive)
              end):add_keybind("Hold", function(r0_149)
                -- line: [0, 0] id: 149
                if state.BunnyHop and r0_149.Active then
                  doBunnyHopJump()
                  state.BunnyHopActive = true
                else
                  state.BunnyHopActive = false
                end
                keybindUi.UpdateKeybinds("Bunny Hop", r0_149.Key, state.BunnyHop, state.BunnyHopActive)
              end)
              r23_56.element("Toggle", "Third Person", false, function(r0_142)
                -- line: [0, 0] id: 142
                state.ThirdPerson = r0_142.Toggle
                keybindUi.UpdateKeybinds("Third Person", "None", state.ThirdPerson, state.ThirdPersonActive)
              end):add_keybind("Hold", function(r0_183)
                -- line: [0, 0] id: 183
                if r0_183.Active and state.ThirdPerson then
                  state.ThirdPersonActive = true
                else
                  state.ThirdPersonActive = false
                end
                keybindUi.UpdateKeybinds("Third Person", r0_183.Key, state.ThirdPerson, state.ThirdPersonActive)
              end)
              local r134_56 = r23_56.element("Slider", "Third Person Distance", {
                default = {
                  min = 1,
                  max = 50,
                  default = 15,
                },
              }, function(r0_234)
                -- line: [0, 0] id: 234
                state.ThirdPersonDistance = r0_234.Slider
              end)
              local r135_56 = r24b_56.element("Toggle", "No Fall Damage", false, function(r0_246)
                -- line: [0, 0] id: 246
                state.NoFall = r0_246.Toggle
              end)
              local r136_56 = r24b_56.element("Slider", "Infinity & Bunny Hop Jump Power", {
                default = {
                  min = 1,
                  max = 28,
                  default = 22,
                },
              }, function(r0_184)
                -- line: [0, 0] id: 184
                state.InfJumpPower = r0_184.Slider
              end)
              local r137_56 = r39_56.element("Toggle", "No Visor + Flashbang", false, function(r0_141)
                -- line: [0, 0] id: 141
                state.VisorEnabled = r0_141.Toggle
                toggleScreenEffect("Visor", r0_141.Toggle)
              end)
              local r138_56 = r39_56.element("Toggle", "No Inventory Blur", false, function(r0_139)
                -- line: [0, 0] id: 139
                state.InventoryBlur = r0_139.Toggle
                local r1_139 = toggleScreenEffect("Inventory", false)
                if r0_139.Toggle == false and r1_139 then
                  local r2_139 = game.Lighting
                  if r2_139 then
                    r2_139.InventoryBlur.Size = 20
                  end
                end
              end)
              local r139_56 = r39_56.element("Toggle", "No Reapir Blur", false, function(r0_74)
                -- line: [0, 0] id: 74
                state.NoReapirBlur = r0_74.Toggle
                toggleScreenEffect("Reapir", state.NoReapirBlur)
              end)
              r24b_56.element("Toggle", "Peek Kill - Bad Thing", false, function(r0_176)
                -- line: [0, 0] id: 176
                state.TPKill = r0_176.Toggle
              end):add_keybind("Hold", function(r0_226)
                -- line: [0, 0] id: 226
                if state.TPKill and r0_226.Active and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                  local r1_226 = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                  r1_226.Velocity = Vector3.new(r1_226.Velocity.X, state.TPKillSpeed + math.random(-15, 15), r1_226.Velocity.Z)
                end
              end)
              local r141_56 = r24b_56.element("Slider", "Peek Kill Speed", {
                default = {
                  min = 50,
                  max = 1000,
                  default = 1050,
                },
              }, function(r0_171)
                -- line: [0, 0] id: 171
                state.TPKillSpeed = r0_171.Slider
              end)
              r24b_56.element("Toggle", "Freeze", false, function(r0_207)
                -- line: [0, 0] id: 207
                state.FreezeUrSelf = r0_207.Toggle
                if not r0_207.Toggle and not state.SpeedHackActive and localPlayer.Character then
                  local r1_207 = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                  if r1_207 then
                    r1_207.Massless = false
                  end
                end
                keybindUi.UpdateKeybinds("Freeze", "None", state.FreezeUrSelf, state.FreezeUrSelfActive)
              end):add_keybind("Hold", function(r0_239)
                -- line: [0, 0] id: 239
                if localPlayer.Character then
                  local r1_239 = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                  if r1_239 and state.FreezeUrSelf and r0_239.Active then
                    r1_239.Massless = true
                    state.FreezeUrSelfActive = true
                  elseif r1_239 then
                    r1_239.Massless = false
                    state.FreezeUrSelfActive = false
                  end
                end
                keybindUi.UpdateKeybinds("Freeze", r0_239.Key, state.FreezeUrSelf, state.FreezeUrSelfActive)
              end)
              local r146_56 = 10
              local r147_56 = false
              local r148_56 = false
              r23_56.element("Toggle", "Zoom", false, function(r0_218)
                -- line: [0, 0] id: 218
                r147_56 = r0_218.Toggle
                if not r147_56 then
                  setDefaultFov(r89_0)
                end
                keybindUi.UpdateKeybinds("Zoom", "None", r147_56, r148_56)
              end):add_keybind("None", function(r0_151)
                -- line: [0, 0] id: 151
                r148_56 = r0_151.Active
                if r0_151.Active and r148_56 and r147_56 and state.Loaded then
                  setDefaultFov(r146_56)
                elseif state.Loaded then
                  setDefaultFov(r89_0)
                end
                keybindUi.UpdateKeybinds("Zoom", r0_151.Key, r147_56, r148_56)
              end)
              local r150_56 = r23_56.element("Slider", "Zoom Fov", {
                default = {
                  min = 1,
                  max = 70,
                  default = 10,
                },
              }, function(r0_152)
                -- line: [0, 0] id: 152
                r146_56 = r0_152.Slider
                if r147_56 and r148_56 then
                  setDefaultFov(r146_56)
                end
              end)
              local r151_56 = r23_56.element("Slider", "Fov Changer", {
                default = {
                  min = 1,
                  max = 120,
                  default = 90,
                },
              }, function(r0_157)
                -- line: [0, 0] id: 157
                r89_0 = r0_157.Slider
                if not r148_56 then
                  setDefaultFov(r89_0)
                end
              end)
              local r152_56 = nil
              local r153_56 = r36_56.element("Toggle", "Skin Changer", false, function(r0_136)
                -- line: [0, 0] id: 136
                skinChangerState.SkinChanger = r0_136.Toggle
                if skinChangerState.SkinChanger then
                  task.spawn(function()
                    -- line: [0, 0] id: 137
                    while not r152_56 do
                      task.wait(0.1)
                    end
                    applyWeaponSkin(skinChangerState.Skin)
                  end)
                end
              end)
              r152_56 = r36_56.element("Dropdown", "Skin", {
                options = {
                  "Anton",
                  "Banana",
                  "SpaceSuit",
                  "Valentine",
                  "Crusader",
                  "Freedom",
                  "Artic",
                  "Nutcracker",
                  "Watergun",
                  "Serpant",
                  "Galaxy",
                  "Hunter",
                  "Permafrost",
                  "Thunder",
                  "GiftWrap",
                  "Shoreline",
                  "Ancient",
                  "AnodizedRed",
                  "DeltaAnime",
                  "PeaceWalker",
                  "Anarchy",
                  "Blackout",
                  "Tan",
                  "TigerStripe",
                  "VOLK",
                  "Woodland",
                  "Pineapple",
                  "Apollo",
                  "Shark",
                  "Devil",
                  "Dialbo",
                  "Freedom",
                  "Melon",
                  "WhiteDeath",
                  nil,
                  nil
                },
              }, function(r0_233)
                -- line: [0, 0] id: 233
                skinChangerState.Skin = r0_233.Dropdown
                if skinChangerState.SkinChanger then
                  applyWeaponSkin(skinChangerState.Skin)
                end
              end)
              local r154_56 = r36_56.element("Combo", "Blacklist Parts", {
                options = {
                  "Stock",
                  "Front",
                  "Sight",
                  "Magazine",
                  "Handle",
                  "Muzzle",
                  "Extra",
                  "ItemRoot"
                },
              }, function(r0_225)
                -- line: [0, 0] id: 225
                for r4_225, r5_225 in pairs(skinChangerState) do
                  if r4_225 ~= "Skin" and r4_225 ~= "SkinChanger" then
                    skinChangerState[r4_225] = true
                  end
                end
                for r4_225, r5_225 in ipairs(r0_225.Combo) do
                  skinChangerState[r5_225] = false
                end
                applyWeaponSkin(skinChangerState.Skin)
              end)
              local r155_56 = r37_56.element("Toggle", "Low Food/Water Indicator", false, function(r0_104)
                -- line: [0, 0] id: 104
                state.LowFoodDetector = r0_104.Toggle
              end)
              local r156_56 = r37_56.element("Slider", "Low Food/Water Indicator Threshold", {
                default = {
                  min = 1,
                  max = 1000,
                  default = 200,
                },
              }, function(r0_187)
                -- line: [0, 0] id: 187
                state.LowFoodThreshold = r0_187.Slider
              end)
              local r157_56 = {}
              local r158_56 = nil
              local r159_56 = r20_56.element("Toggle", "No Landmines", false, function(r0_200)
                -- line: [0, 0] id: 200
                if state.Lobby then
                  return 
                end
                state.NoLandMine = r0_200.Toggle
                if state.NoLandMine then
                  local function r1_200(r0_201)
                    -- line: [0, 0] id: 201
                    for r4_201, r5_201 in pairs(r0_201:GetChildren()) do
                      if r5_201:IsA("Model") and (r5_201.Name == "PMN2" or r5_201.Name == "MON50") then
                        r5_201:Destroy()
                      end
                    end
                    if not r157_56[r0_201] then
                      r157_56[r0_201] = r0_201.ChildAdded:Connect(function(r0_203)
                        -- line: [0, 0] id: 203
                        if r0_203:IsA("Model") and (r0_203.Name == "PMN2" or r0_203.Name == "MON50") and state.NoLandMine then
                          task.wait(2.5)
                          r0_203:Destroy()
                        end
                      end)
                    end
                    if not r158_56 and not workspace.AiZones:FindFirstChild("Landmines") then
                      r158_56 = game.workspace.ChildAdded:Connect(function(r0_202)
                        -- line: [0, 0] id: 202
                        if r0_202 and r0_202:IsA("Model") and state.NoLandMine and r0_202:IsA("Model") and (r0_202.Name == "PMN2" or r0_202.Name == "MON50") then
                          task.wait(2.5)
                          r0_202:Destroy()
                        end
                      end)
                    end
                  end
                  if workspace.AiZones:FindFirstChild("Landmines") then
                    r1_200(workspace.AiZones.Landmines)
                    r1_200(workspace.AiZones.Claymores)
                  else
                    r1_200(workspace.AiZones.OutpostLandmines)
                    r1_200(workspace.AiZones.BridgeClaymores)
                    r1_200(workspace.AiZones.HeliCrashClaymores)
                    r1_200(workspace.AiZones.ShipWreckClaymores)
                  end
                else
                  if r158_56 then
                    r158_56:Disconnect()
                    r158_56 = nil
                  end
                  for r4_200, r5_200 in pairs(r157_56) do
                    if r5_200 then
                      r5_200:Disconnect()
                    end
                  end
                end
              end)
              local r160_56 = r20b_56.element("Toggle", "Full Brightness", false, function(r0_166)
                -- line: [0, 0] id: 166
                state.setFullBrightness = r0_166.Toggle
                if not state.AmbientChanger then
                  setFullBrightness(r0_166.Toggle)
                end
              end)
              local r161_56 = r20b_56.element("Toggle", "No Fog", false, function(r0_119)
                -- line: [0, 0] id: 119
                state.NoFog = r0_119.Toggle
              end)
              r20b_56.element("Toggle", "Xray", false, function(r0_103)
                -- line: [0, 0] id: 103
                state.Xray = r0_103.Toggle
                keybindUi.UpdateKeybinds("Xray", "None", state.Xray, state.XrayActive)
              end):add_keybind("None", function(r0_162)
                -- line: [0, 0] id: 162
                if state.Xray and r0_162.Active then
                  toggleXrayTransparency(r0_162.Active)
                  state.XrayActive = true
                else
                  toggleXrayTransparency(r0_162.Active)
                  state.XrayActive = false
                end
                keybindUi.UpdateKeybinds("Xray", r0_162.Key or "None", state.Xray, state.XrayActive)
              end)
              local r163_56 = r20b_56.element("Dropdown", "Sky", {
                options = {
                  "Default",
                  "Orange Sunset",
                  "Pink Sky",
                  "Night",
                  "Galaxy Sky",
                  "Purple Space Sky",
                  "Spring Sky"
                },
              }, function(r0_174)
                -- line: [0, 0] id: 174
                local r1_174 = game.Lighting:FindFirstChildOfClass("Sky")
                local r2_174 = state.Sky[r0_174.Dropdown]
                if r2_174 then
                  if r2_174.Value then
                    r1_174.SkyboxBk = r2_174.Value
                    r1_174.SkyboxDn = r2_174.Value
                    r1_174.SkyboxFt = r2_174.Value
                    r1_174.SkyboxLf = r2_174.Value
                    r1_174.SkyboxRt = r2_174.Value
                    r1_174.SkyboxUp = r2_174.Value
                  else
                    r1_174.SkyboxBk = r2_174.SkyboxBk
                    r1_174.SkyboxDn = r2_174.SkyboxDn
                    r1_174.SkyboxFt = r2_174.SkyboxFt
                    r1_174.SkyboxLf = r2_174.SkyboxLf
                    r1_174.SkyboxRt = r2_174.SkyboxRt
                    r1_174.SkyboxUp = r2_174.SkyboxUp
                  end
                end
              end)
              r25_56.element("Toggle", "ViewModel Changer", false, function(r0_150)
                -- line: [0, 0] id: 150
                state.ViewModelChanger = r0_150.Toggle
                if r0_150.Toggle == true then
                  local r1_150 = camera:FindFirstChild("ViewModel")
                  if r1_150 then
                    offsetViewModelArms(r1_150, true)
                    cleanViewModel(r1_150)
                  end
                end
              end):add_color({
                Color = Color3.fromRGB(79, 155, 121),
              }, nil, function(r0_111)
                -- line: [0, 0] id: 111
                state.ArmColor = r0_111.Color
                if state.ViewModelChanger then
                  local r1_111 = camera:FindFirstChild("ViewModel")
                  if r1_111 then
                    applyViewModelArmsStyle("Color", r1_111)
                    applyViewModelArmsStyle("Transparency", r1_111)
                  end
                end
              end)
              local r165_56 = r25_56.element("Slider", "Arm Transparency", {
                default = {
                  min = 0,
                  max = 100,
                  default = 0,
                },
              }, function(r0_261)
                -- line: [0, 0] id: 261
                state.ViewModelTransparency = r0_261.Slider / 100
                local r1_261 = camera:FindFirstChild("ViewModel")
                if r1_261 then
                  applyViewModelArmsStyle("Transparency", r1_261)
                end
              end)
              local r166_56 = r25_56.element("Slider", "Arm X Pos", {
                default = {
                  min = 0,
                  max = 290,
                  default = 50,
                },
              }, function(r0_204)
                -- line: [0, 0] id: 204
                r62_0 = r0_204.Slider / 20 - 2.5
                local r1_204 = camera:FindFirstChild("ViewModel")
                if r1_204 then
                  offsetViewModelArms(r1_204, true)
                end
              end)
              local r167_56 = r25_56.element("Slider", "Arm Y Pos", {
                default = {
                  min = 0,
                  max = 290,
                  default = 50,
                },
              }, function(r0_179)
                -- line: [0, 0] id: 179
                r63_0 = r0_179.Slider / 20 - 2.5
                local r1_179 = camera:FindFirstChild("ViewModel")
                if r1_179 then
                  offsetViewModelArms(r1_179, true)
                end
              end)
              local r168_56 = r25_56.element("Slider", "Arm Z Pos", {
                default = {
                  min = 0,
                  max = 290,
                  default = 50,
                },
              }, function(r0_247)
                -- line: [0, 0] id: 247
                r64_0 = r0_247.Slider / 20 - 2.5
                local r1_247 = camera:FindFirstChild("ViewModel")
                if r1_247 then
                  offsetViewModelArms(r1_247, true)
                end
              end)
              local r169_56 = r38_56.element("Toggle", "Custom Hit Sound", false, function(r0_118)
                -- line: [0, 0] id: 118
                state.CustomHitSound = r0_118.Toggle
              end)
              local r170_56 = r38_56.element("Dropdown", "Hit Sound", {
                options = {
                  "Default",
                  "Rust",
                  "Neverlose",
                  "Gamesense",
                  "Bubble",
                  "Ding",
                  "Bruh",
				  "CS 1.6",
				  "Windows XP",
				  "TeamFortress",
				  "Toilet",
				  "FAAHH"
                },
              }, function(r0_102)
                -- line: [0, 0] id: 102
                state.CustomHitSoundID = state.HitSounds[r0_102.Dropdown]
              end)
              local r171_56 = r38_56.element("Slider", "Hit Sound Volume", {
                default = {
                  min = 1,
                  max = 5500,
                  default = 100,
                },
              }, function(r0_211)
                -- line: [0, 0] id: 211
                state.CustomHitSoundVolume = r0_211.Slider / 100
              end)
              local r172_56 = r38_56.element("Button", "Play HitSound", false, function(r0_158)
                -- line: [0, 0] id: 158
                local r1_158 = Instance.new("Sound", workspace)
                if state.CustomHitSoundID == "Default" then
                  r1_158.SoundId = "rbxassetid://4585351098"
                else
                  r1_158.SoundId = state.CustomHitSoundID
                end
                r1_158.Volume = state.CustomHitSoundVolume
                r1_158:Play()
                task.wait(1)
                r1_158:Destroy()
              end)
              localPlayer.PlayerGui.ChildAdded:Connect(function(r0_69)
                -- line: [0, 0] id: 69
                if r0_69.Name == "MainGui" then
                  r0_69.ChildAdded:Connect(function(r0_70)
                    -- line: [0, 0] id: 70
                    if r0_70:IsA("Sound") and state.CustomHitSound and state.CustomHitSoundID ~= "Default" then
                      if r0_70.SoundId == "rbxassetid://4585382589" or r0_70.SoundId == "rbxassetid://4585351098" then
                        r0_70.SoundId = state.CustomHitSoundID
                        r0_70.Volume = state.CustomHitSoundVolume
                      elseif r0_70.SoundId == "rbxassetid://4585382046" or r0_70.SoundId == "rbxassetid://4585364605" then
                        r0_70.SoundId = state.CustomHitSoundID
                        r0_70.Volume = state.CustomHitSoundVolume
                      end
                    end
                  end)
                end
              end)
              r175_56 = "MainGui"
              if localPlayer.PlayerGui:FindFirstChild(r175_56) then
                r175_56 = "MainGui"
                localPlayer.PlayerGui:FindFirstChild(r175_56).ChildAdded:Connect(function(r0_58)
                  -- line: [0, 0] id: 58
                  if r0_58:IsA("Sound") and state.CustomHitSound and state.CustomHitSoundID ~= "Default" then
                    if r0_58.SoundId == "rbxassetid://4585382589" or r0_58.SoundId == "rbxassetid://4585351098" then
                      r0_58.SoundId = state.CustomHitSoundID
                      r0_58.Volume = state.CustomHitSoundVolume
                    elseif r0_58.SoundId == "rbxassetid://4585382046" or r0_58.SoundId == "rbxassetid://4585364605" then
                      r0_58.SoundId = state.CustomHitSoundID
                      r0_58.Volume = state.CustomHitSoundVolume
                    end
                  end
                end)
              end
              r31_56.element("Toggle", "Show Crosshair", false, function(r0_175)
                -- line: [0, 0] id: 175
                crosshairState.Visible = r0_175.Toggle
                crosshairMenuBypassActive = r0_175.Toggle and isMenuVisible()
                updateCrosshairDrawing()
              end):add_color({
                Color = crosshairState.Color,
              }, nil, function(r0_57)
                -- line: [0, 0] id: 57
                crosshairState.Color = r0_57.Color
                state.MenuCrosshairColor = r0_57.Color
                updateMenuCrosshairStyle()
              end)
              r31_56.element("Toggle", "Show Menu Crosshair", false, function(r0_302)
                -- line: [0, 0] id: 302
                state.MenuCrosshairEnabled = r0_302.Toggle
                updateMenuCrosshair()
              end):add_color({
                Color = state.MenuCrosshairColor,
              }, nil, function(r0_303)
                -- line: [0, 0] id: 303
                state.MenuCrosshairColor = r0_303.Color
                updateMenuCrosshairStyle()
              end)
              local r173b_56 = r31_56.element("Slider", "Menu Crosshair Size", {
                default = {
                  min = 5,
                  max = 30,
                  default = 10,
                },
              }, function(r0_304)
                -- line: [0, 0] id: 304
                state.MenuCrosshairSize = r0_304.Slider
                updateMenuCrosshairStyle()
              end)
              local r174_56 = r31_56.element("Toggle", "RGB", false, function(r0_82)
                -- line: [0, 0] id: 82
                crosshairState.RGB = r0_82.Toggle
              end)
              r175_56 = r31_56.element("Toggle", "Crosshair Auto Rotation", false, function(r0_138)
                -- line: [0, 0] id: 138
                crosshairState.RotateAuto = r0_138.Toggle
              end)
              local r176_56 = r31_56.element("Slider", "Crosshair Rotation Speed", {
                default = {
                  min = 1,
                  max = 5,
                  default = 1,
                },
              }, function(r0_235)
                -- line: [0, 0] id: 235
                crosshairState.RotateSpeed = r0_235.Slider
              end)
              local r177_56 = r31_56.element("Slider", "Crosshair Transparency", {
                default = {
                  min = 0,
                  max = 100,
                  default = 100,
                },
              }, function(r0_243)
                -- line: [0, 0] id: 243
                crosshairState.Transparency = r0_243.Slider / 100
              end)
              local r178_56 = r31_56.element("Slider", "Crosshair Length", {
                default = {
                  min = 1,
                  max = 50,
                  default = 10,
                },
              }, function(r0_126)
                -- line: [0, 0] id: 126
                crosshairState.Size = r0_126.Slider
              end)
              local r179_56 = r31_56.element("Slider", "Crosshair Thickness", {
                default = {
                  min = 1,
                  max = 25,
                  default = 3,
                },
              }, function(r0_130)
                -- line: [0, 0] id: 130
                crosshairState.Thickness = r0_130.Slider
              end)
              local r180_56 = r31_56.element("Slider", "Crosshair Gap", {
                default = {
                  min = 1,
                  max = 25,
                  default = 5,
                },
              }, function(r0_125)
                -- line: [0, 0] id: 125
                crosshairState.Gap = r0_125.Slider
              end)
              local function applyCustomTheme()
                if r1_56 and type(r1_56.SetThemeAccent) == "function" then
                  r1_56.SetThemeAccent(state.Menu.CustomTheme, state.Menu.CustomThemeColor)
                  return
                end

                local menuGui = CoreGui:FindFirstChild("unknown")
                local mainFrame = menuGui and menuGui:FindFirstChild("Main")
                if not mainFrame then
                  return
                end

                local color = state.Menu.CustomTheme and state.Menu.CustomThemeColor or Color3.fromRGB(255, 255, 255)
                local borderColor = state.Menu.CustomTheme and state.Menu.CustomThemeColor or Color3.fromRGB(15, 15, 15)
                pcall(function()
                  mainFrame.ImageColor3 = color
                end)
                pcall(function()
                  mainFrame.BorderColor3 = borderColor
                end)
              end
              r32_56.element("Toggle", "Custom Theme (Beta)", false, function(r0_199)
                -- line: [0, 0] id: 199
                state.Menu.CustomTheme = r0_199.Toggle
                applyCustomTheme()
              end):add_color({
                Color = Color3.fromRGB(129, 210, 255),
              }, nil, function(r0_124)
                -- line: [0, 0] id: 124
                state.Menu.CustomThemeColor = r0_124.Color
                applyCustomTheme()
              end)
              local r182_56 = r34_56.element("Dropdown", "NPC - Only In Lobby", {
                options = {
                  "Mihkel",
                  "Seryozha",
                  "Tarmo",
                  "Nurse",
                  "Blaze",
                  "Boss",
                  "Designer",
                  "Anna"
                },
              }, function(r0_132)
                -- line: [0, 0] id: 132
                state.NPC = r0_132.Dropdown
              end)
              local r183_56 = r34_56.element("Button", "Teleport Npc To You", false, function(r0_251)
                -- line: [0, 0] id: 251
                local r1_251 = game.Workspace:FindFirstChild(state.NPC)
                if r1_251 then
                  r1_251.HumanoidRootPart.CFrame = localPlayer.Character.HumanoidRootPart.CFrame
                end
              end)
              local r184_56 = r33_56.element("Toggle", "Hide Server Information", false, function(r0_154)
                -- line: [0, 0] id: 154
                state.ServerInfo = r0_154.Toggle
                local r1_154 = localPlayer.PlayerGui:FindFirstChild("ServerInfo")
                if r1_154 then
                  r1_154:FindFirstChild("Frame").serverInfo.Visible = not r0_154.Toggle
                  return 
                end
                local r2_154 = nil
                r2_154 = localPlayer.PlayerGui.ChildAdded:Connect(function(r0_155)
                  -- line: [0, 0] id: 155
                  if r0_155.Name == "ServerInfo" and state.ServerInfo then
                    r0_155:FindFirstChild("Frame").serverInfo.Visible = not state.ServerInfo
                  end
                end)
              end)
              local r185_56 = nil
              local r186_56 = nil
              local r187_56 = r33_56.element("Toggle", "Hide Name In Chat", false, function(r0_193)
                -- line: [0, 0] id: 193
                state.HideName = r0_193.Toggle
                local r1_193 = localPlayer.PlayerGui:FindFirstChild("ChatV3")
                local r2_193 = r0_193.Toggle
                if r2_193 then
                  r2_193 = r185_56
                  if not r2_193 then
                    r2_193 = state.HideName
                    if r2_193 then
                      function r2_193()
                        -- line: [0, 0] id: 194
                        for r3_194, r4_194 in pairs(r1_193:FindFirstChild("MainFrame").ChatBox.ChatWindow:GetChildren()) do
                          if r4_194:IsA("TextLabel") and r4_194:FindFirstChild("Message") then
                            local r5_194 = r4_194:FindFirstChild("Message")
                            if r5_194.Text:find(localPlayer.Name) then
                              r5_194.Text = r5_194.Text:gsub(localPlayer.Name, "Hidden")
                            end
                          end
                        end
                        r185_56 = r1_193:FindFirstChild("MainFrame").ChatBox.ChatWindow.ChildAdded:Connect(function(r0_195)
                          -- line: [0, 0] id: 195
                          if r0_195:IsA("TextLabel") and r0_195:FindFirstChild("Message") and state.HideName then
                            local r1_195 = r0_195:FindFirstChild("Message")
                            if r1_195.Text:find(localPlayer.Name) then
                              r1_195.Text = r1_195.Text:gsub(localPlayer.Name, "Hidden")
                            end
                          elseif state.HideName then
                            r185_56:Disconnect()
                            r185_56 = nil
                          end
                        end)
                      end
                      if r1_193 then
                        r2_193()
                      else
                        r186_56 = localPlayer.PlayerGui.ChildAdded:Connect(function(r0_196)
                          -- line: [0, 0] id: 196
                          if r0_196.Name == "ChatV3" and state.HideName then
                            r1_193 = r0_196
                            r2_193()
                            r186_56:Disconnect()
                            r186_56 = nil
                          elseif not state.HideName then
                            r186_56:Disconnect()
                            r186_56 = nil
                          end
                        end)
                      end
                      -- close: r2_193
                    end
                  end
                else
                  r2_193 = r185_56
                  if r2_193 then
                    r2_193 = r185_56
                    r2_193:Disconnect()
                    r2_193 = nil
                    r185_56 = r2_193
                    r2_193 = pairs
                    for r5_193, r6_193 in r2_193(r1_193:FindFirstChild("MainFrame").ChatBox.ChatWindow:GetChildren()) do
                      if r6_193:IsA("TextLabel") and r6_193:FindFirstChild("Message") then
                        local r7_193 = r6_193:FindFirstChild("Message")
                        if r7_193.Text:find("Hidden") then
                          r7_193.Text = r7_193.Text:gsub("Hidden", localPlayer.Name)
                        end
                      end
                    end
                  end
                end
              end)
              task.spawn(function()
                -- line: [0, 0] id: 84
                local r0_84 = r40_56.element("Toggle", "Disable Gask Mask Breathing Sound", false, function(r0_88)
                  -- line: [0, 0] id: 88
                  state.GasMaskSound = r0_88.Toggle
                end)
                local r1_84 = r41_56.element("Toggle", "KeyBind Indicator", false, function(r0_85)
                  -- line: [0, 0] id: 85
                  keybindUi.Visible(r0_85.Toggle)
                end)
                r41_56.element("Keybind", "Toggle Menu Key", {
                  default = "RightControl",
                }, function()
                end)
                local r2_84 = state.Lobby
                local r3_84 = nil	-- notice: implicit variable refs by block#[2]
                if r2_84 then
                  function r2_84()
                    -- line: [0, 0] id: 96
                    for r3_96, r4_96 in ipairs(state.ServerListCopy) do
                      if not serverListFolder:FindFirstChild(r4_96.Name) then
                        r4_96:Clone().Parent = serverListFolder
                      end
                    end
                  end
                  serverListFolder.ChildAdded:Connect(function(r0_89)
                    -- line: [0, 0] id: 89
                    if r0_89:GetAttribute("ServerLocation") and state.ServerChanger then
                      local r1_89 = tostring(r0_89:GetAttribute("ServerLocation"))
                      local r2_89 = nil
                      local r3_89 = r0_89:GetAttribute("MapName")
                      local r4_89 = r0_89:GetAttribute("Ver")
                      local r5_89 = tonumber(string.match(r0_89:GetAttribute("TimeOfDay"), "^(%d%d)"))
                      if not r0_89:GetAttribute("Premium") and not r0_89:GetAttribute("Veteran") then
                        r2_89 = "Default"
                      elseif r0_89:GetAttribute("Premium") then
                        r2_89 = "Premium"
                      elseif r0_89:GetAttribute("Veteran") then
                        r2_89 = "Veteran"
                      end
                      if r1_89 and r0_89 then
                        if not state.ServerListCopy[r0_89] then
                          table.insert(state.ServerListCopy, r0_89)
                        end
                        local r6_89 = tonumber(r0_89:GetAttribute("PlayerCount"))
                        local r7_89 = r0_89.Name:lower()
                        local r8_89 = state.ServerName:lower()
                        if state.ServerName and state.ServerName ~= "Default" and 2 < #r8_89 and not r7_89:find(r8_89) or #r8_89 <= 2 and r7_89:sub(1, #r8_89) ~= r8_89 and r7_89:sub(-#r8_89) ~= r8_89 then
                          task.wait(0.5)
                          r0_89:Destroy()
                        elseif state.ServerTarget ~= "Any" and r1_89 ~= state.ServerTarget then
                          task.wait(0.5)
                          r0_89:Destroy()
                        elseif state.ServerRank ~= "All" and r2_89 ~= state.ServerRank then
                          task.wait(0.5)
                          r0_89:Destroy()
                        elseif state.ServerMap ~= "Any" and r3_89 ~= state.ServerMap then
                          task.wait(0.5)
                          r0_89:Destroy()
                        elseif state.ServerVersion ~= "Any" and r4_89 ~= state.ServerVersion and r0_89 then
                          task.wait(0.5)
                          r0_89:Destroy()
                        elseif state.ServerClock ~= "Any" and r0_89 then
                          if state.ServerClock == "Day" and r5_89 < 12 then
                            task.wait(0.5)
                            r0_89:Destroy()
                          elseif r5_89 > 12 then
                            task.wait(0.5)
                            r0_89:Destroy()
                          end
                        elseif r6_89 < state.ServerPlayerMax then
                          task.wait(0.5)
                          r0_89:Destroy()
                        elseif state.ServerPlayerMin < r6_89 and state.ServerPlayerMax <= state.ServerPlayerMin then
                          task.wait(0.5)
                          r0_89:Destroy()
                        end
                      end
                    end
                  end)
                  function r3_84(r0_90)
                    -- line: [0, 0] id: 90
                    local r1_90 = 0
                    local r2_90 = 0
                    r2_84()
                    if state.ServerChanger then
                      for r6_90, r7_90 in pairs(serverListFolder:GetChildren()) do
                        if r0_90 == "ServerLocation" then
                          local r8_90 = tostring(r7_90:GetAttribute("ServerLocation"))
                          local r9_90 = nil
                          local r10_90 = r7_90:GetAttribute("MapName")
                          local r11_90 = r7_90:GetAttribute("Ver")
                          local r12_90 = tonumber(string.match(r7_90:GetAttribute("TimeOfDay"), "^(%d%d)"))
                          if r7_90:GetAttribute("Veteran") then
                            r9_90 = "Veteran"
                          end
                          if not r9_90 then
                            if not r7_90:GetAttribute("Premium") or not r7_90:GetAttribute("Premium") then
                              r9_90 = "Default"
                            elseif r7_90:GetAttribute("Premium") then
                              r9_90 = "Premium"
                            end
                          end
                          if r8_90 and r7_90 then
                            if state.ServerName and state.ServerName ~= "Default" then
                              local r13_90 = r7_90.Name:lower()
                              local r14_90 = state.ServerName:lower()
                              if 2 < #r14_90 and not r13_90:find(r14_90) or #r14_90 <= 2 and r13_90:sub(1, #r14_90) ~= r14_90 and r13_90:sub(-#r14_90) ~= r14_90 then
                                r7_90:Destroy()
                                r1_90 = r1_90 + 1
                              end
                            end
                            if state.ServerTarget ~= "Any" and r8_90 ~= state.ServerTarget then
                              r7_90:Destroy()
                              r1_90 = r1_90 + 1
                            end
                            if state.ServerRank ~= "All" and r9_90 ~= state.ServerRank and r7_90 then
                              r7_90:Destroy()
                              r1_90 = r1_90 + 1
                            end
                            if state.ServerMap ~= "Any" and r10_90 ~= state.ServerMap and r7_90 then
                              r7_90:Destroy()
                              r1_90 = r1_90 + 1
                            end
                            if state.ServerVersion ~= "Any" and r11_90 ~= state.ServerVersion and r7_90 then
                              r7_90:Destroy()
                              r1_90 = r1_90 + 1
                            end
                            if state.ServerClock ~= "Any" and r7_90 and r12_90 and 12 < r12_90 then
                              r7_90:Destroy()
                              r1_90 = r1_90 + 1
                            end
                            local r13_90 = tonumber(r7_90:GetAttribute("PlayerCount"))
                            if r13_90 < state.ServerPlayerMax then
                              r7_90:Destroy()
                              r1_90 = r1_90 + 1
                            end
                            if state.ServerPlayerMin < r13_90 and state.ServerPlayerMax <= state.ServerPlayerMin then
                              r7_90:Destroy()
                              r1_90 = r1_90 + 1
                            end
                          end
                        end
                      end
                    end
                    return r1_90
                    -- warn: not visited block [41]
                    -- block#41:
                    -- r7_90:Destroy()
                    -- r1_90 = r1_90 + 1
                    -- --goto label_185
                  end
                  local r4_84 = r42_56.element("Toggle", "Server List Filter", false, function(r0_93)
                    -- line: [0, 0] id: 93
                    state.ServerChanger = r0_93.Toggle
                    if r0_93.Toggle then
                      r3_84("ServerLocation")
                    else
                      r2_84()
                    end
                  end)
                  local r5_84 = r42_56.element("Dropdown", "Server Region", {
                    options = {
                      "Any",
                      "EU",
                      "NA",
                      "AS"
                    },
                  }, function(r0_97)
                    -- line: [0, 0] id: 97
                    state.ServerTarget = r0_97.Dropdown
                    if state.ServerChanger then
                      r3_84("ServerLocation")
                    end
                  end)
                  local r6_84 = r42_56.element("Dropdown", "Server Level", {
                    options = {
                      "All",
                      "Default",
                      "Veteran",
                      "Premium"
                    },
                  }, function(r0_92)
                    -- line: [0, 0] id: 92
                    state.ServerRank = r0_92.Dropdown
                    if state.ServerChanger then
                      r3_84("ServerLocation")
                    end
                  end)
                  local r7_84 = r42b_56.element("Dropdown", "Server Map", {
                    options = {
                      "Any",
                      "Estonian Border",
                      "City-13"
                    },
                  }, function(r0_91)
                    -- line: [0, 0] id: 91
                    state.ServerMap = r0_91.Dropdown
                    if state.ServerChanger then
                      r3_84("ServerLocation")
                    end
                  end)
                  local r8_84 = r42b_56.element("Dropdown", "Server Version", {
                    options = {
                      "Any",
                      "0.501c",
                      "0.5h",
                      "0.501b"
                    },
                  }, function(r0_87)
                    -- line: [0, 0] id: 87
                    state.ServerVersion = r0_87.Dropdown
                    if state.ServerChanger then
                      r3_84("ServerLocation")
                    end
                  end)
                  local r9_84 = r42b_56.element("TextBox", "Server ID Must Contain", false, function(r0_98)
                    -- line: [0, 0] id: 98
                    state.ServerName = r0_98.Text
                    if state.ServerChanger then
                      r3_84("ServerLocation")
                    end
                  end)
                  local r10_84 = r42b_56.element("Dropdown", "Server Clock", {
                    options = {
                      "Any",
                      "Day",
                      "Night"
                    },
                  }, function(r0_99)
                    -- line: [0, 0] id: 99
                    state.ServerClock = r0_99.Dropdown
                    if state.ServerChanger then
                      r3_84("ServerLocation")
                    end
                  end)
                  local r11_84 = r42b_56.element("Slider", "Minimum Players In Server", {
                    default = {
                      min = 1,
                      max = 25,
                      default = 1,
                    },
                  }, function(r0_86)
                    -- line: [0, 0] id: 86
                    state.ServerPlayerMax = r0_86.Slider
                    if state.ServerChanger then
                      r3_84("ServerLocation")
                    end
                  end)
                  local r12_84 = r42b_56.element("Slider", "Maximum Players In Server", {
                    default = {
                      min = 1,
                      max = 25,
                      default = 25,
                    },
                  }, function(r0_94)
                    -- line: [0, 0] id: 94
                    state.ServerPlayerMin = r0_94.Slider
                    if state.ServerChanger then
                      r3_84("ServerLocation")
                    end
                  end)
                  -- close: r2_84
                end
                r2_84 = r43_56
                r2_84 = r2_84.element
                r3_84 = "Button"
                r2_84 = r2_84(r3_84, "Join random server", false, function(r0_100)
                  -- line: [0, 0] id: 100
                  local r2_100, r3_100 = (function()
                    -- line: [0, 0] id: 101
                    local r0_101 = serverListFolder:GetChildren()
                    if #r0_101 == 0 then
                      return nil
                    end
                    local r1_101 = r0_101[math.random(1, #r0_101)]
                    return r1_101:GetAttribute("PlaceId"), r1_101:GetAttribute("JobId")
                  end)()
                  if r2_100 then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(r2_100, r3_100, localPlayer)
                  else
                    notify("GHOST_HOOK | Servers", "No server has been found to be suitable with your current requirements.", 2.5)
                  end
                end)
                r3_84 = r43_56
                r3_84 = r3_84.element
                r3_84 = r3_84("Button", "Rejoin server", false, function(r0_95)
                  -- line: [0, 0] id: 95
                  local r1_95 = game.JobId
                  local r2_95 = game.PlaceId
                  if r1_95 and r2_95 then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(r2_95, r1_95, localPlayer)
                  end
                end)
              end)
              local r188_56 = r22_56.element("Button", "Unload - Will Lag Once", false, function(r0_244)
                -- line: [0, 0] id: 244
                local r1_244 = CoreGui:FindFirstChild("unknown")
                if not unknown then
                  for r5_244, r6_244 in pairs(CoreGui:GetChildren()) do
                    if r6_244.Name == "unknown" then
                      unknown = r6_244
                    end
                  end
                end
                if overlayGui and unknown then
                  bossMonitorEnabled = false
                  playerEsp.Enabled = false
                  state.Loaded = false
                  state.MasterAimbot = false
                  state.Prediction = false
                  state.predictionEnabled = false
                  state.predictionCache = {}
                  state._weaponCache = {}
                  state.WallBang = false
                  state.WallBangIndicator = false
                  state.wallBangCache = {}
                  state._wallBangInfo = nil
                  wallBang.cache = {}
                  wallBang.cacheFrame = 0
                  wallBang.wallBangTargets = {}
                  wallBang.lastScanTime = 0
                  prediction.lastTarget = nil
                  if predictionIndicator then
                    predictionIndicator.Visible = false
                    if predictionIndicator.Remove then
                      predictionIndicator:Remove()
                    end
                    predictionIndicator = nil
                  end
                  if wallBang.indicator then
                    wallBang.indicator.Visible = false
                    if wallBang.indicator.Remove then
                      wallBang.indicator:Remove()
                    elseif wallBang.indicator.Destroy then
                      wallBang.indicator:Destroy()
                    end
                    wallBang.indicator = nil
                  end
                  state.SpeedHack = false
                  state.LastTarget = nil
                  state.AmbientChanger = false
                  state.TimeChanger = false
                  state.CustomHitSound = false
                  state.Radar = false
                  setPlayerRadarEnabled(false)
                  state.ViewModelChanger = false
                  skinChangerState.SkinChanger = false
                  state.ExitESP = false
                  state.AiNameTag = false
                  state.ContainerESP = false
                  state.VehicleTag = false
                  state.DroppedItemESP = false
                  state.TPKill = false
                  state.InstantEquip = false
                  state.AntiAimEnabled = false
                  state.FlipModeEnabled = false
                  state.FlipMode = false
                  if disableAntiAim then
                    disableAntiAim()
                  end
                  if state.AutoShootHoldActive then
                    state.AutoShootHoldActive = false
                    mouse1release()
                  end
                  toggleNoRecoil(false)
                  toggleNoSpread(false)
                  toggleQuestItemEsp(false)
                  ClearAimbotTargetVisuals()
                  destroyMenuCrosshair()
                  state.Foliage = false
                  r116_56()
                  setDefaultFov("Fov")
                  toggleScreenEffect("Visor", false)
                  toggleScreenEffect("Reapir", false)
                  keybindUi.Disconnect()
                  if state.Xray then
                    toggleXrayTransparency(false)
                  end
                  for r5_244, r6_244 in ipairs(Players:GetChildren()) do
                    togglePlayerChams(r6_244, false)
                  end
                  local r2_244 = game.Lighting:FindFirstChildOfClass("Sky")
                  local r3_244 = state.Sky.Default
                  if r3_244 then
                    r2_244.SkyboxBk = r3_244.Value
                    r2_244.SkyboxDn = r3_244.Value
                    r2_244.SkyboxFt = r3_244.Value
                    r2_244.SkyboxLf = r3_244.Value
                    r2_244.SkyboxRt = r3_244.Value
                    r2_244.SkyboxUp = r3_244.Value
                  end
                  if unusedConnectionOrState then
                    unusedConnectionOrState:Disconnect()
                  end
                  if r158_56 then
                    r158_56:Disconnect()
                  end
                  if mainHeartbeatConnection then
                    mainHeartbeatConnection:Disconnect()
                  end
                  if r76_56 then
                    r76_56:Disconnect()
                  end
                  for r7_244, r8_244 in pairs(featureConnections) do
                    r8_244:Disconnect()
                  end
                  if state.FOVCircle then
                    state.FOVCircle:Destroy()
                  end
                  overlayGui:Destroy()
                  warningGui:Destroy()
                  r1_244:Destroy()
                  if Tracer then
                    Tracer:Destroy()
                  end
                  state.HorizontalLine1:Destroy()
                  state.HorizontalLine2:Destroy()
                  state.VerticalLine1:Destroy()
                  state.VerticalLine2:Destroy()
                  game.Lighting.Brightness = 2
                  game.Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
                  game.Lighting.Ambient = Color3.fromRGB(128, 128, 128)
                  for r7_244, r8_244 in pairs(game.Workspace:GetDescendants()) do
                    local r9_244 = r8_244:FindFirstChild("BillboardGui") or r8_244:FindFirstChild("ExitLocation") or r8_244:FindFirstChild("Highlight")
                    if r9_244 then
                      r9_244:Destroy()
                    end
                    if r8_244:IsA("Highlight") then
                      r8_244:Destroy()
                    end
                  end
                  if state.FreezeUrSelf and localPlayer.Character then
                    state.FreezeUrSelf = false
                    localPlayer.Character.HumanoidRootPart.Massless = false
                  end
                  sethiddenproperty(workspace.Terrain, "Decoration", true)
                  _G.InjectedGui = false
                  _G.Injected = false
                  task.wait(0.01)
                  playerEsp:Disconnect()
                end
              end)
              local r189_56 = "Default"
              local r190_56 = r21_56.element("TextBox", "Enter Config Name", false, function(r0_260)
                -- line: [0, 0] id: 260
                r189_56 = r0_260.Text
                if r0_260.Text == nil then
                  r189_56 = "Default"
                elseif r0_260.Text == "" or r0_260.Text == " " then
                  r189_56 = "Default"
                end
              end)
              local r191_56 = r21_56.element("Button", "Save Config", false, function(r0_110)
                -- line: [0, 0] id: 110
                Save(r189_56, "AutoLoadConfig")
                local success, err = r1_56.save_cfg(r189_56)
                if success then
                  notify("GHOST_HOOK | Configs", "Config Named: " .. r189_56 .. " Was Saved", 5)
                else
                  notify("GHOST_HOOK | Configs", "Failed To Save Config: " .. tostring(err), 5)
                end
              end)
              local r192_56 = r21_56.element("Button", "Load Config", false, function(r0_240)
                -- line: [0, 0] id: 240
                Save(r189_56, "AutoLoadConfig")
                local success, loadedOrErr = r1_56.load_cfg(r189_56)
                if success then
                  notify("GHOST_HOOK | Configs", "Config Named: " .. r189_56 .. " Was Loaded (" .. tostring(loadedOrErr or 0) .. " items)", 5)
                else
                  notify("GHOST_HOOK | Configs", "Failed To Load Config: " .. tostring(loadedOrErr), 5)
                end
              end)
              local function ensureDefaultAutoConfig()
                Save("Default", "AutoLoadConfig")
                local success, err = r1_56.save_cfg("Default")
                if not success then
                  notify("GHOST_HOOK | Configs", "Failed To Create Default Config: " .. tostring(err), 5)
                end
              end
              local r193_56 = Load("Text", "AutoLoadConfig")
              if r193_56 then
                local success, loadedOrErr = r1_56.load_cfg(r193_56)
                if success then
                  notify("GHOST_HOOK | Configs", "Config Named: " .. r193_56 .. " Was Loaded (" .. tostring(loadedOrErr or 0) .. " items)", 5)
                elseif tostring(loadedOrErr) == "config not found" then
                  ensureDefaultAutoConfig()
                else
                  notify("GHOST_HOOK | Configs", "Failed To Load Config: " .. tostring(loadedOrErr), 5)
                end
              else
                ensureDefaultAutoConfig()
              end
              notify("GHOST_HOOK 3.5/4", "Finished Creating UI", 2.5)
            end)
            notify("GHOST_HOOK 4/5", "Almost Done...", 2.5)
            local bossInfoLabels = {}
            local r91_0 = Load("UDim2", "Position.txt") or UDim2.new(0.004277, 0, 0.444444, 0)
            task.spawn(function()
              -- line: [0, 0] id: 298
              -- notice: unreachable block#1
              local r0_298 = Instance.new("Frame", overlayGui)
              r0_298.BackgroundColor3 = Color3.new(1, 1, 1)
              r0_298.Name = "Frame"
              r0_298.Position = r91_0
              r0_298.BorderColor3 = Color3.new(0, 0, 0)
              r0_298.BackgroundTransparency = 1
              r0_298.BorderSizePixel = 0
              r0_298.Size = UDim2.new(0.171062, 0, 0.231481, 0)
              r0_298.Visible = false
              table.insert(bossInfoLabels, r0_298)
              local r1_298 = Instance.new("TextLabel", r0_298)
              r1_298.TextColor3 = Color3.new(0, 0, 0)
              r1_298.BorderColor3 = Color3.new(0.305882, 0.364706, 0.917647)
              r1_298.Text = ""
              r1_298.BorderSizePixel = 1
              r1_298.Font = Enum.Font.SourceSans
              r1_298.Name = "TextLabel"
              r1_298.Position = UDim2.new(0.00011, 0, 0, 0)
              r1_298.BackgroundTransparency = 0
              r1_298.BackgroundColor3 = Color3.new(0.058824, 0.058824, 0.058824)
              r1_298.TextSize = 14
              r1_298.Size = UDim2.new(0.995723, 0, 0.755699, 0)
              local r2_298 = Instance.new("TextLabel", r0_298)
              r2_298.TextColor3 = Color3.new(1, 1, 1)
              r2_298.BorderColor3 = Color3.new(0.305882, 0.364706, 0.917647)
              r2_298.Text = "Boss Information"
              r2_298.BorderSizePixel = 1
              r2_298.Font = Enum.Font.SourceSans
              r2_298.Name = "TextLabel"
              r2_298.Position = UDim2.new(0.004277, 0, 0, 0)
              r2_298.BackgroundTransparency = 0
              r2_298.BackgroundColor3 = Color3.new(0.058824, 0.058824, 0.058824)
              r2_298.TextSize = 14
              r2_298.Size = UDim2.new(0.992602, 0, 0.129032, 0)
              local r3_298 = Instance.new("TextLabel", r0_298)
              r3_298.TextColor3 = Color3.new(1, 1, 1)
              r3_298.BorderColor3 = Color3.new(0.305882, 0.364706, 0.917647)
              r3_298.Text = ""
              r3_298.BorderSizePixel = 1
              r3_298.Font = Enum.Font.SourceSans
              r3_298.Name = "TextLabel"
              r3_298.Position = UDim2.new(0.004277, 0, 0.129033, 0)
              r3_298.BackgroundTransparency = 0
              r3_298.BackgroundColor3 = Color3.new(1, 1, 1)
              r3_298.TextSize = 14
              r3_298.Size = UDim2.new(0.995723, 0, 0.005226, 0)
              local r4_298 = Instance.new("TextLabel", r0_298)
              r4_298.TextColor3 = Color3.new(1, 0, 0)
              r4_298.BorderColor3 = Color3.new(0.305882, 0.364706, 0.917647)
              r4_298.Text = "Boss Not Found"
              r4_298.BorderSizePixel = 1
              r4_298.Font = Enum.Font.SourceSans
              r4_298.Name = "TextLabel"
              r4_298.Position = UDim2.new(0.004277, 0, 0.173333, 0)
              r4_298.BackgroundTransparency = 0
              r4_298.BackgroundColor3 = Color3.new(0.058824, 0.058824, 0.058824)
              r4_298.TextSize = 14
              r4_298.Size = UDim2.new(0.992602, 0, 0.175699, 0)
              table.insert(bossInfoLabels, r4_298)
              local r5_298 = Instance.new("TextLabel", r0_298)
              r5_298.TextColor3 = Color3.new(1, 0, 0)
              r5_298.BorderColor3 = Color3.new(0.305882, 0.364706, 0.917647)
              r5_298.Text = "Boss Not Found"
              r5_298.BorderSizePixel = 1
              r5_298.Font = Enum.Font.SourceSans
              r5_298.Name = "Dozer"
              r5_298.Position = UDim2.new(0.004277, 0, 0.393333, 0)
              r5_298.BackgroundTransparency = 0
              r5_298.BackgroundColor3 = Color3.new(0.058824, 0.058824, 0.058824)
              r5_298.TextSize = 14
              r5_298.Size = UDim2.new(0.991557, 0, 0.162366, 0)
              table.insert(bossInfoLabels, r5_298)
              local r6_298 = Instance.new("TextLabel", r0_298)
              r6_298.TextColor3 = Color3.new(1, 0, 0)
              r6_298.BorderColor3 = Color3.new(0.305882, 0.364706, 0.917647)
              r6_298.Text = "Boss Not Found"
              r6_298.BorderSizePixel = 1
              r6_298.Font = Enum.Font.SourceSans
              r6_298.Name = "Whisper"
              r6_298.Position = UDim2.new(0.004277, 0, 0.595699, 0)
              r6_298.BackgroundTransparency = 0
              r6_298.BackgroundColor3 = Color3.new(0.058824, 0.058824, 0.058824)
              r6_298.TextSize = 14
              r6_298.Size = UDim2.new(0.992602, 0, 0.16, 0)
              table.insert(bossInfoLabels, r6_298)
              local r7_298 = nil
              local r8_298 = nil
              local r9_298 = nil
              local r10_298 = nil
              function EnableDragging(r0_299)
                -- line: [0, 0] id: 299
                r0_299.InputBegan:Connect(function(r0_301)
                  -- line: [0, 0] id: 301
                  if r0_301.UserInputType == Enum.UserInputType.MouseButton1 then
                    r7_298 = true
                    r9_298 = r0_299.Position
                    r10_298 = UserInputService:GetMouseLocation()
                  end
                end)
                r0_299.InputChanged:Connect(function(r0_302)
                  -- line: [0, 0] id: 302
                  if r0_302.UserInputType == Enum.UserInputType.MouseMovement then
                    r8_298 = r0_302
                  end
                end)
                UserInputService.InputChanged:Connect(function(r0_303)
                  -- line: [0, 0] id: 303
                  if r0_303 == r8_298 and r7_298 and state.BossMovable then
                    local r1_303 = UserInputService:GetMouseLocation() - r10_298
                    r0_299.Position = UDim2.new(r9_298.X.Scale, r9_298.X.Offset + r1_303.X, r9_298.Y.Scale, r9_298.Y.Offset + r1_303.Y)
                    r91_0 = r0_299.Position
                    Save(r0_299.Position, "Position")
                  end
                end)
                r0_299.InputEnded:Connect(function(r0_300)
                  -- line: [0, 0] id: 300
                  if r0_300.UserInputType == Enum.UserInputType.MouseButton1 then
                    r7_298 = false
                  end
                end)
              end
              EnableDragging(r0_298)
              -- close: r0_298
            end)
            local equippedItemIcons = {}
            local fullInventoryIcons = {}
            local fullInventoryCounts = {}
            local attachmentIcons = {}
            for chooseAimPart = 1, 12, 1 do
              local isPointInsideAimFov = Instance.new("ImageLabel", overlayGui)
              isPointInsideAimFov.Visible = false
              isPointInsideAimFov.Size = UDim2.new(0, 60, 0, 60)
              isPointInsideAimFov.BackgroundTransparency = 0.25
              isPointInsideAimFov.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
              Instance.new("UICorner", isPointInsideAimFov).CornerRadius = UDim.new(0, 12)
              if chooseAimPart <= 3 then
                isPointInsideAimFov.Position = UDim2.new(0, (overlayGui.AbsoluteSize.X - 135 - 825) / 2 + (chooseAimPart - 1) * 85, 0, 0)
              else
                isPointInsideAimFov.Position = UDim2.new(0, (overlayGui.AbsoluteSize.X - 135 - 800) / 2 + (chooseAimPart - 1) * 80, 0, 0)
              end
              equippedItemIcons[chooseAimPart] = isPointInsideAimFov
            end
            for chooseAimPart = 1, 12, 1 do
              local isPointInsideAimFov = Instance.new("ImageLabel", overlayGui)
              isPointInsideAimFov.Visible = false
              isPointInsideAimFov.Size = UDim2.new(0, 25, 0, 20)
              isPointInsideAimFov.BackgroundTransparency = 0.2
              isPointInsideAimFov.BackgroundColor3 = Color3.fromRGB(155, 30, 30)
              isPointInsideAimFov.ZIndex = 2
              Instance.new("UICorner", isPointInsideAimFov).CornerRadius = UDim.new(0, 9)
              if chooseAimPart <= 4 then
                isPointInsideAimFov.Position = UDim2.new(0, (overlayGui.AbsoluteSize.X - 135 - 850) / 2 + (chooseAimPart - 1) * 21, 0, 55)
                isPointInsideAimFov.BackgroundColor3 = Color3.fromRGB(155, 20, 30)
              elseif chooseAimPart <= 8 then
                isPointInsideAimFov.Position = UDim2.new(0, (overlayGui.AbsoluteSize.X - 135 - 845) / 2 + (chooseAimPart - 1) * 21, 0, 55)
                isPointInsideAimFov.BackgroundColor3 = Color3.fromRGB(30, 50, 155)
              elseif chooseAimPart <= 12 then
                isPointInsideAimFov.Position = UDim2.new(0, (overlayGui.AbsoluteSize.X - 135 - 840) / 2 + (chooseAimPart - 1) * 21, 0, 55)
                isPointInsideAimFov.BackgroundColor3 = Color3.fromRGB(50, 155, 30)
              end
              attachmentIcons[chooseAimPart] = isPointInsideAimFov
            end
            for chooseAimPart = 1, 54, 1 do
              local isPointInsideAimFov = Instance.new("ImageLabel", overlayGui)
              isPointInsideAimFov.Visible = false
              isPointInsideAimFov.Size = UDim2.new(0, 35, 0, 35)
              isPointInsideAimFov.BackgroundTransparency = 0.35
              isPointInsideAimFov.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
              Instance.new("UICorner", isPointInsideAimFov).CornerRadius = UDim.new(0, 12)
              local hasLineOfSight = Instance.new("TextLabel", overlayGui)
              hasLineOfSight.Visible = true
              hasLineOfSight.Text = ""
              hasLineOfSight.TextScaled = true
              hasLineOfSight.Size = UDim2.new(0, 20, 0, 15)
              hasLineOfSight.BackgroundTransparency = 1
              hasLineOfSight.TextColor3 = Color3.fromRGB(255, 255, 255)
              Instance.new("UICorner", hasLineOfSight).CornerRadius = UDim.new(0, 12)
              if chooseAimPart <= 6 then
                isPointInsideAimFov.Position = UDim2.new(0, (overlayGui.AbsoluteSize.X - -900 - 400) / 2 + (chooseAimPart - 1) * 40, 0, 100)
                hasLineOfSight.Position = UDim2.new(0, (overlayGui.AbsoluteSize.X - -918 - 400) / 2 + (chooseAimPart - 1) * 40, 0, 124)
              elseif chooseAimPart <= 12 then
                isPointInsideAimFov.Position = UDim2.new(0, (overlayGui.AbsoluteSize.X - -900 - 400) / 2 + (chooseAimPart - 6 - 1) * 40, 0, 140)
                hasLineOfSight.Position = UDim2.new(0, (overlayGui.AbsoluteSize.X - -918 - 400) / 2 + (chooseAimPart - 6 - 1) * 40, 0, 164)
              elseif chooseAimPart <= 18 then
                isPointInsideAimFov.Position = UDim2.new(0, (overlayGui.AbsoluteSize.X - -900 - 400) / 2 + (chooseAimPart - 12 - 1) * 40, 0, 180)
                hasLineOfSight.Position = UDim2.new(0, (overlayGui.AbsoluteSize.X - -918 - 400) / 2 + (chooseAimPart - 12 - 1) * 40, 0, 204)
              elseif chooseAimPart <= 24 then
                isPointInsideAimFov.Position = UDim2.new(0, (overlayGui.AbsoluteSize.X - -900 - 400) / 2 + (chooseAimPart - 18 - 1) * 40, 0, 220)
                hasLineOfSight.Position = UDim2.new(0, (overlayGui.AbsoluteSize.X - -918 - 400) / 2 + (chooseAimPart - 18 - 1) * 40, 0, 244)
              elseif chooseAimPart <= 30 then
                isPointInsideAimFov.Position = UDim2.new(0, (overlayGui.AbsoluteSize.X - -900 - 400) / 2 + (chooseAimPart - 24 - 1) * 40, 0, 260)
                hasLineOfSight.Position = UDim2.new(0, (overlayGui.AbsoluteSize.X - -918 - 400) / 2 + (chooseAimPart - 24 - 1) * 40, 0, 284)
              elseif chooseAimPart <= 36 then
                isPointInsideAimFov.Position = UDim2.new(0, (overlayGui.AbsoluteSize.X - -900 - 400) / 2 + (chooseAimPart - 30 - 1) * 40, 0, 300)
                hasLineOfSight.Position = UDim2.new(0, (overlayGui.AbsoluteSize.X - -918 - 400) / 2 + (chooseAimPart - 30 - 1) * 40, 0, 324)
              elseif chooseAimPart <= 42 then
                isPointInsideAimFov.Position = UDim2.new(0, (overlayGui.AbsoluteSize.X - -900 - 400) / 2 + (chooseAimPart - 36 - 1) * 40, 0, 340)
                hasLineOfSight.Position = UDim2.new(0, (overlayGui.AbsoluteSize.X - -918 - 400) / 2 + (chooseAimPart - 36 - 1) * 40, 0, 364)
              elseif chooseAimPart <= 48 then
                isPointInsideAimFov.Position = UDim2.new(0, (overlayGui.AbsoluteSize.X - -900 - 400) / 2 + (chooseAimPart - 42 - 1) * 40, 0, 380)
                hasLineOfSight.Position = UDim2.new(0, (overlayGui.AbsoluteSize.X - -918 - 400) / 2 + (chooseAimPart - 42 - 1) * 40, 0, 404)
              elseif chooseAimPart <= 54 then
                isPointInsideAimFov.Position = UDim2.new(0, (overlayGui.AbsoluteSize.X - -900 - 400) / 2 + (chooseAimPart - 48 - 1) * 40, 0, 420)
                hasLineOfSight.Position = UDim2.new(0, (overlayGui.AbsoluteSize.X - -918 - 400) / 2 + (chooseAimPart - 48 - 1) * 40, 0, 424)
              end
              fullInventoryIcons[chooseAimPart] = isPointInsideAimFov
              fullInventoryCounts[chooseAimPart] = hasLineOfSight
            end
            local inventoryViewerCache = {
              LastVisibility = false,
              LastTargetInventory = nil,
              LastTargetClothes = nil,
              LastTargetValueName = nil,
              LastTargetValue = 0,
            }
            function VisibilityToggle(r0_23)
              -- line: [0, 0] id: 23
              local r1_23 = inventoryViewerCache.LastVisibility
              if r0_23 == r1_23 then
                return 
              end
              inventoryViewerCache.LastVisibility = r0_23
              for r4_23 = 1, 12, 1 do
                equippedItemIcons[r4_23].Visible = r0_23
                attachmentIcons[r4_23].Visible = r0_23
              end
              if r0_23 then
                r1_23 = state.FullInventoryChecker or false
              else
                --goto label_24	-- block#7 is visited secondly
              end
              for r5_23 = 1, 54, 1 do
                fullInventoryCounts[r5_23].Visible = r1_23
                fullInventoryIcons[r5_23].Visible = r1_23
              end
            end
            local function renderInventoryViewer(r0_47)
              -- line: [0, 0] id: 47
              if r0_47.Name == localPlayer.Name then
                return 
              end
              local r1_47 = nil
              if r0_47:FindFirstChild("Humanoid") then
                r1_47 = r0_47.Inventory
              else
                r1_47 = game.ReplicatedStorage.Players[r0_47.Name].Inventory
              end
              if r1_47 or not inventoryViewerCache.LastTargetInventory == r0_47 then
                for r5_47 = 1, 12, 1 do
                  equippedItemIcons[r5_47].Image = "rbxassetid://12459616555"
                end
                for r5_47 = 4, 12, 1 do
                  equippedItemIcons[r5_47].Image = "rbxassetid://12459616555"
                end
                for r5_47 = 1, 12, 1 do
                  attachmentIcons[r5_47].Image = "rbxassetid://12459616555"
                end
                local r2_47 = 4
                local r3_47 = 1
                local r4_47 = 0
                for r8_47, r9_47 in pairs(r1_47:GetChildren()) do
                  if r9_47:GetAttribute("Slot"):find("Clothing") then
                    local r11_47 = itemsList:FindFirstChild(r9_47.Name)
                    if r11_47 then
                      equippedItemIcons[r2_47].Image = r11_47.ItemProperties.ItemIcon.Image
                      r2_47 = r2_47 + 1
                    end
                  elseif r9_47:FindFirstChild("Attachments") then
                    local r11_47 = itemsList:FindFirstChild(r9_47.Name)
                    if r11_47 then
                      equippedItemIcons[r3_47].Image = r11_47.ItemProperties.ItemIcon.Image
                      r3_47 = r3_47 + 1
                      for r15_47, r16_47 in pairs(r9_47.Attachments:GetChildren()) do
                        local r17_47 = r16_47:GetAttribute("Slot")
                        local r18_47 = itemsList:FindFirstChild(r16_47.Name)
                        local r19_47 = nil
                        if r17_47 == "Magazine" then
                          r19_47 = 1
                        elseif r17_47 == "Sight" then
                          r19_47 = 2
                        elseif r17_47 == "Muzzle" then
                          r19_47 = 3
                        elseif r17_47 == "Extra" then
                          r19_47 = 4
                        end
                        if r19_47 and r18_47 then
                          attachmentIcons[r19_47 + r4_47].Image = r18_47.ItemProperties.ItemIcon.Image
                        end
                      end
                      r4_47 = r4_47 + 4
                    end
                  end
                end
                if state.FullInventoryChecker then
                  for r8_47 = 1, 54, 1 do
                    fullInventoryIcons[r8_47].Image = "rbxassetid://12459616555"
                    fullInventoryCounts[r8_47].Text = ""
                  end
                  local r5_47 = 1
                  for r9_47, r10_47 in pairs(r1_47:GetChildren()) do
                    local r11_47 = r10_47:FindFirstChild("Inventory")
                    if r11_47 and r10_47.Name ~= "KeyChain" then
                      for r15_47, r16_47 in pairs(r11_47:GetChildren()) do
                        local r17_47 = r16_47:GetAttribute("Amount") or 1
                        fullInventoryIcons[r5_47].Image = itemsList:FindFirstChild(r16_47.Name).ItemProperties.ItemIcon.Image
                        if r17_47 >= 1000 then
                          r17_47 = math.floor(r17_47 / 1000) .. "K"
                        else
                          r17_47 = "x" .. r17_47
                        end
                        fullInventoryCounts[r5_47].Text = r17_47
                        r5_47 = r5_47 + 1
                      end
                    end
                  end
                end
              end
              inventoryViewerCache.LastTargetInventory = r0_47
            end
            local function estimateInventoryValue(r0_8)
              -- line: [0, 0] id: 8
              if inventoryViewerCache.LastTargetValueName == r0_8 then
                return inventoryViewerCache.LastTargetValue
              end
              local r1_8 = nil
              if r0_8:FindFirstChild("Humanoid") then
                r1_8 = r0_8.Inventory
              else
                r1_8 = game.ReplicatedStorage.Players[r0_8.Name].Inventory
              end
              local r2_8 = 0
              if r1_8 then
                for r6_8, r7_8 in pairs(r1_8:GetChildren()) do
                  local r8_8 = r7_8:GetAttribute("Slot")
                  if r8_8 and r8_8:find("Clothing") and r7_8:FindFirstChild("Inventory") then
                    for r13_8, r14_8 in pairs(r7_8:FindFirstChild("Inventory"):GetChildren()) do
                      local r15_8 = itemsList:FindFirstChild(r14_8.Name)
                      if r15_8 then
                        local r16_8 = 0
                        if r14_8.Name ~= "Rubles" then
                          r16_8 = r15_8.ItemProperties:GetAttribute("Price") or 1
                          if r16_8 >= 10 then
                            local r17_8 = r15_8.ItemProperties:GetAttribute("ItemType")
                            if r17_8 == "Extra" then
                              r16_8 = r16_8 * 0.4
                            elseif r17_8 == "Ammo" then
                              r16_8 = r16_8 * r14_8:GetAttribute("Amount") * 0.7
                            elseif r17_8 == "Clothing" then
                              r16_8 = r16_8 * 0.35
                            elseif r17_8 == "Medical" then
                              r16_8 = r16_8 * 0.75
                            elseif r17_8 == "Barter" then
                              r16_8 = r16_8 * 0.4
                            end
                          end
                          r2_8 = r2_8 + r16_8
                        else
                          r2_8 = r2_8 + (r14_8:GetAttribute("Amount") or 1)
                        end
                      end
                    end
                  end
                end
              end
              inventoryViewerCache.LastTargetValueName = r0_8
              inventoryViewerCache.LastTargetValue = math.floor(r2_8)
              return math.floor(r2_8)
            end
            local smartAimBodyParts = {
              { name = "Head", priority = 1 },
              { name = "UpperTorso", priority = 2 },
              { name = "LowerTorso", priority = 3 },
              { name = "RightUpperArm", priority = 4 },
              { name = "LeftUpperArm", priority = 5 },
              { name = "RightLowerArm", priority = 6 },
              { name = "LeftLowerArm", priority = 7 },
              { name = "RightHand", priority = 8 },
              { name = "LeftHand", priority = 9 },
              { name = "RightUpperLeg", priority = 10 },
              { name = "LeftUpperLeg", priority = 11 },
              { name = "RightLowerLeg", priority = 12 },
              { name = "LeftLowerLeg", priority = 13 },
              { name = "RightFoot", priority = 14 },
              { name = "LeftFoot", priority = 15 },
            }

            local function getSmartAimCharacter(target)
              if not target then
                return nil
              end
              if target:IsA("Player") then
                return target.Character
              end
              if target:IsA("Model") then
                return target
              end
              return nil
            end

            local function smartAimRayHitsTarget(hitPart, character, target)
              local current = hitPart
              while current do
                if current == character or current == target then
                  return true
                end
                current = current.Parent
              end
              return false
            end

            local visibilityCache = {}
            local cacheFrameCounter = 0
            local visibilityCacheLifetime = 0.06
            local wallRaycastParams = RaycastParams.new()
            wallRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
            wallRaycastParams.IgnoreWater = true
            state.VisibilityCache = visibilityCache
            state._bestAimPoint = nil
            state._bestAimPart = nil

            local function refreshWallRaycastParams()
              wallRaycastParams.FilterDescendantsInstances = { localPlayer.Character }
              return wallRaycastParams
            end

            local function getVisibilityCacheEntry(target)
              local cached = visibilityCache[target]
              local now = tick()
              if not cached or (cached.expiresAt or 0) <= now then
                cached = {
                  frame = cacheFrameCounter,
                  expiresAt = now + visibilityCacheLifetime,
                  parts = {},
                  anyVisible = nil,
                }
                visibilityCache[target] = cached
              end
              return cached
            end

            local getPartVisibilityPoints

            local function isTargetPointVisible(point, character, target)
              if not state.WallCheck then
                return true
              end
              if not point or not character or not target then
                return false
              end

              local screenPos, onScreen = camera:WorldToViewportPoint(point)
              if not onScreen or screenPos.Z <= 0 then
                return false
              end

              local origin = camera.CFrame.Position + camera.CFrame.LookVector * 0.5
              local direction = point - origin
              local distance = direction.Magnitude
              if distance <= 0 or distance > 5000 then
                return false
              end

              local rayResult = workspace:Raycast(origin, direction.Unit * distance, refreshWallRaycastParams())
              if not rayResult then
                return true
              end
              if smartAimRayHitsTarget(rayResult.Instance, character, target) then
                return true
              end
              return (rayResult.Position - point).Magnitude <= 0.75
            end

            local function isPartVisible(part, target)
              if not state.WallCheck then
                return true
              end
              if not part or not target then
                return false
              end

              local character = getSmartAimCharacter(target)
              if not character then
                return false
              end

              local cached = getVisibilityCacheEntry(target)
              if cached.parts[part] ~= nil then
                return cached.parts[part]
              end

              local visible = false
              for _, point in ipairs(getPartVisibilityPoints(part)) do
                if isTargetPointVisible(point, character, target) then
                  visible = true
                  break
                end
              end

              cached.parts[part] = visible
              return visible
            end

            local function getDirectlyVisiblePart(target, character)
              if not character then
                return nil
              end

              for _, partName in ipairs({ "Head", "UpperTorso", "LowerTorso" }) do
                local part = character:FindFirstChild(partName)
                if part and isPartVisible(part, target) then
                  return part
                end
              end

              for _, partInfo in ipairs(smartAimBodyParts) do
                local part = character:FindFirstChild(partInfo.name)
                if part and isPartVisible(part, target) then
                  return part
                end
              end

              return nil
            end

            getPartVisibilityPoints = function(part)
              if not part then
                return {}
              end
              local basePosition = part.Position
              local size = part.Size
              local xOffset = size and math.min(size.X * 0.35, 0.45) or 0.35
              local yOffset = size and math.min(size.Y * 0.35, 0.45) or 0.35
              return {
                basePosition,
                basePosition + Vector3.new(xOffset, 0, 0),
                basePosition - Vector3.new(xOffset, 0, 0),
                basePosition + Vector3.new(0, yOffset, 0),
                basePosition - Vector3.new(0, yOffset, 0),
              }
            end

            local function getDistanceFromCenter(point)
              if not point then
                return math.huge, nil, false
              end
              local screenPos, onScreen = camera:WorldToViewportPoint(point)
              if not onScreen then
                return math.huge, screenPos, false
              end
              local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
              return (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude, screenPos, true
            end

            local function isSmartAimPointVisible(point, character, target, myHead)
              return isTargetPointVisible(point, character, target)
            end

            local function getBestVisiblePoint(part, character, target, center)
              if not part or not character or not target then
                return nil
              end

              local myHead = localPlayer.Character and localPlayer.Character:FindFirstChild("Head")
              local bestPoint = nil
              local bestDistance = math.huge
              local fovRadius = state.AimbotFov or 100
              center = center or Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

              for _, point in ipairs(getPartVisibilityPoints(part)) do
                local screenPos, onScreen = camera:WorldToViewportPoint(point)
                if onScreen then
                  local distanceFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                  if distanceFromCenter <= fovRadius and isSmartAimPointVisible(point, character, target, myHead) then
                    if distanceFromCenter < bestDistance then
                      bestDistance = distanceFromCenter
                      bestPoint = point
                    end
                  end
                end
              end

              return bestPoint, bestDistance
            end

            local function isPartPartiallyVisible(part, character, target)
              local bestPoint = getBestVisiblePoint(part, character, target)
              return bestPoint ~= nil
            end
            local scoreWallBangCandidate = nil
            local function chooseAimPart()
              -- line: [0, 0] id: 55
              local r1_55 = nil
              local preservedWallBangInfo = state._wallBangInfo
              local preservedWallBangPoint = state._bestAimPoint
              local preservedWallBangPart = state._bestAimPart
              state._bestAimPoint = nil
              state._bestAimPart = nil

              if state.SmartAiming and state.LastTarget then
                local target = state.LastTarget
                local character = getSmartAimCharacter(target)

                if character then
                  local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                  local bestPart = nil
                  local bestPriority = nil
                  local bestDistance = math.huge
                  local bestPoint = nil

                  for _, partInfo in ipairs(smartAimBodyParts) do
                    local part = character:FindFirstChild(partInfo.name)
                    if part then
                      local visiblePoint, crosshairDist = getBestVisiblePoint(part, character, target, center)
                      if visiblePoint then
                        local priority = (state.AimbotBodyPartPriority and state.AimbotBodyPartPriority[partInfo.name]) or partInfo.priority

                        if bestPriority == nil or priority < bestPriority or (priority == bestPriority and crosshairDist < bestDistance) then
                          bestPriority = priority
                          bestDistance = crosshairDist
                          bestPart = partInfo.name
                          bestPoint = visiblePoint
                        end
                      end
                    end
                  end

                  if not bestPart then
                    for _, part in ipairs(character:GetChildren()) do
                      if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        local visiblePoint, crosshairDist = getBestVisiblePoint(part, character, target, center)
                        if visiblePoint and crosshairDist < bestDistance then
                          bestDistance = crosshairDist
                          bestPart = part.Name
                          bestPoint = visiblePoint
                        end
                      end
                    end
                  end

                  if bestPart then
                    state.RealAimPart = bestPart
                    state._bestAimPoint = bestPoint
                    state._bestAimPart = bestPart
                    return
                  end
                end
              end

              if false then
              if state.SmartAiming and state.LastTarget then
                local target = state.LastTarget
                local character = nil

                if target:IsA("Player") then
                  character = target.Character
                elseif target:IsA("Model") then
                  character = target
                end

                if character then
                  local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                  local myHead = localPlayer.Character and localPlayer.Character:FindFirstChild("Head")
                  local bestPart = nil
                  local bestScore = nil
                  local bodyParts = {
                    "Head", "UpperTorso", "LowerTorso",
                    "RightUpperArm", "LeftUpperArm", "RightLowerArm", "LeftLowerArm",
                    "RightHand", "LeftHand",
                    "RightUpperLeg", "LeftUpperLeg", "RightLowerLeg", "LeftLowerLeg",
                    "RightFoot", "LeftFoot"
                  }

                  local function pointHitsTarget(hitPart)
                    local current = hitPart
                    while current do
                      if current == character or current == target then
                        return true
                      end
                      current = current.Parent
                    end
                    return false
                  end

                  local function isPointVisible(point)
                    return isTargetPointVisible(point, character, target)
                  end

                  for _, partName in ipairs(bodyParts) do
                    local part = character:FindFirstChild(partName)
                    if part then
                      local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                      if onScreen then
                        local crosshairDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if crosshairDist <= (state.AimbotFov or 100) and isPointVisible(part.Position) then
                          local priority = (state.AimbotBodyPartPriority and state.AimbotBodyPartPriority[partName]) or 99
                          local score

                          if state.AimbotAimMethod == "Furthest from Crosshair" then
                            score = -crosshairDist + (priority * 0.005)
                          elseif state.AimbotAimMethod == "Closest Distance" then
                            score = myHead and ((part.Position - myHead.Position).Magnitude + (priority * 0.01)) or math.huge
                          else
                            score = crosshairDist + (priority * 0.005)
                          end

                          if bestScore == nil or score < bestScore then
                            bestScore = score
                            bestPart = partName
                          end
                        end
                      end
                    end
                  end

                  if bestPart then
                    state.RealAimPart = bestPart
                    return
                  end
                end
              end
              
              -- Smart Aiming: Find the best visible body part
              if state.SmartAiming and state.LastTarget then
                  local target = state.LastTarget
                  local character = nil
                  
                  if target:IsA("Player") then
                      character = target.Character
                  elseif target:IsA("Model") then
                      character = target
                  end
                  
                  if character then
                      local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                      local bestPart = nil
                      local bestDistance = math.huge
                      local bestPriority = 999
                      local myHead = localPlayer.Character and localPlayer.Character:FindFirstChild("Head")
                      
                      -- Priority: Head > UpperTorso > LowerTorso > Arms > Legs > Hands > Feet
                      local bodyParts = {
                          {name = "Head", priority = 1},
                          {name = "UpperTorso", priority = 2},
                          {name = "LowerTorso", priority = 3},
                          {name = "RightUpperArm", priority = 4},
                          {name = "LeftUpperArm", priority = 5},
                          {name = "RightLowerArm", priority = 6},
                          {name = "LeftLowerArm", priority = 7},
                          {name = "RightHand", priority = 8},
                          {name = "LeftHand", priority = 9},
                          {name = "RightUpperLeg", priority = 10},
                          {name = "LeftUpperLeg", priority = 11},
                          {name = "RightLowerLeg", priority = 12},
                          {name = "LeftLowerLeg", priority = 13},
                          {name = "RightFoot", priority = 14},
                          {name = "LeftFoot", priority = 15}
                      }
                      
                      -- Helper function to check if a point is visible (raycast with wall detection)
                      local function isPointVisible(point)
                          return isTargetPointVisible(point, character, target)
                      end
                      
                      for _, partInfo in ipairs(bodyParts) do
                          local part = character:FindFirstChild(partInfo.name)
                          if part then
                              -- Check if any point around this part is visible
                              local partVisible = false
                              local partScreenPos = nil
                              local partDistance = math.huge
                              
                              for _, pos in ipairs(getPartVisibilityPoints(part)) do
                                  local screenPos, onScreen = camera:WorldToViewportPoint(pos)
                                  if onScreen then
                                      local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                                      if distance <= state.AimbotFov then
                                          if isPointVisible(pos) then
                                              partVisible = true
                                              if distance < partDistance then
                                                  partDistance = distance
                                                  partScreenPos = screenPos
                                              end
                                          end
                                      end
                                  end
                              end
                              
                              if partVisible then
                                  -- Select by priority, then by distance
                                  if partInfo.priority < bestPriority then
                                      bestPriority = partInfo.priority
                                      bestPart = partInfo.name
                                      bestDistance = partDistance
                                  elseif partInfo.priority == bestPriority and partDistance < bestDistance then
                                      bestDistance = partDistance
                                      bestPart = partInfo.name
                                  end
                              end
                          end
                      end
                      
                      if bestPart then
                          state.RealAimPart = bestPart
                          print("🎯 Smart Aiming selected:", bestPart)
                          return
                      end
                  end
              end
              
              end

              -- Fallback
              if state.SmartAiming and state.LastTarget and state.WallBang and state.WallCheck and scoreWallBangCandidate then
                local target = state.LastTarget
                local character = getSmartAimCharacter(target) or getAimbotTargetCharacterForVisibility(target)
                local myHead = localPlayer.Character and localPlayer.Character:FindFirstChild("Head")
                if scoreWallBangCandidate(target, character, nil, myHead) then
                  state.RealAimPart = state._bestAimPart or state.AimPart
                  return
                end
              end

              if state.WallBang and state.WallCheck and state.LastTarget and preservedWallBangInfo and preservedWallBangInfo.target == state.LastTarget then
                state._bestAimPoint = preservedWallBangPoint
                state._bestAimPart = preservedWallBangPart or preservedWallBangInfo.partName
                state.RealAimPart = state._bestAimPart or state.RealAimPart or state.AimPart
                return
              end

              if state.SilentAimbot and state.AimbotRandomizeHitPart then
                  local r0_55 = {
                      "Head", "FaceHitBox", "HeadTopHitBox", "UpperTorso", "LowerTorso",
                      "LeftUpperArm", "LeftLowerArm", "LeftHand",
                      "RightUpperArm", "RightLowerArm", "RightHand",
                      "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
                      "RightUpperLeg", "RightLowerLeg", "RightFoot",
                      "HumanoidRootPart"
                  }
                  state.RealAimPart = r0_55[math.random(#r0_55)]
                  return 
              end
              if not r1_55 then
                  state.RealAimPart = state.AimPart
              end
            end
            local function isPointInsideAimFov(r0_50, r1_50)
              -- line: [0, 0] id: 50
              local r2_50 = state.AimbotFov or 0
              local r3_50 = camera:WorldToViewportPoint(r0_50)
              local r5_50 = (Vector2.new(r3_50.X, r3_50.Y) - Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)).Magnitude
              if r1_50 == "Infinity" then
                r2_50 = 1000
              end
              local r6_50 = math.min(r2_50, math.max(camera.ViewportSize.X, camera.ViewportSize.Y))
              local r7_50 = r3_50.Z
              if r7_50 > 0 then
                r7_50 = r5_50 < r6_50
              else
                --goto label_48	-- block#6 is visited secondly
              end
              return r7_50
            end
            local function findInventoryCheckTarget()
              -- line: [0, 0] id: 48
              local r0_48 = nil	-- notice: implicit variable refs by block#[0, 15]
              local r1_48 = math.huge
              local function r2_48()
                -- line: [0, 0] id: 49
                for r3_49, r4_49 in ipairs(Players:GetPlayers()) do
                  if r4_49 ~= Players.LocalPlayer and r4_49.Character and r4_49.Character:FindFirstChild("Head") and r4_49.Character:FindFirstChild("Head") and r4_49.Character:FindFirstChild("Humanoid") and 0 < r4_49.Character.Humanoid.Health and isPointInsideAimFov(r4_49.Character:FindFirstChild(state.RealAimPart).Position, "Infinity") then
                    local r6_49 = camera:WorldToViewportPoint(r4_49.Character.Head.Position)
                    local r8_49 = (Vector2.new(r6_49.X, r6_49.Y) - Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)).Magnitude
                    if r8_49 < r1_48 then
                      r1_48 = r8_49
                      r0_48 = r4_49
                    end
                  end
                end
              end
              if not state.LastTarget then
                r2_48()
              elseif state.LastTarget:FindFirstChild("Head") then
                r2_48()
              else
                return state.LastTarget
              end
              if state.InventoryCheckCorpse then
                for r6_48, r7_48 in ipairs(game.Workspace.DroppedItems:GetChildren()) do
                  if r7_48 and r7_48:FindFirstChild("Humanoid") and r7_48:FindFirstChild("Head") and not r7_48:FindFirstChild("AttackedBy") and isPointInsideAimFov(r7_48.Head.Position, "Infinity") then
                    local r9_48 = camera:WorldToViewportPoint(r7_48.Head.Position)
                    local r11_48 = (Vector2.new(r9_48.X, r9_48.Y) - Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)).Magnitude
                    if r11_48 < r1_48 then
                      r1_48 = r11_48
                      r0_48 = r7_48
                    end
                  end
                end
              end
              return r0_48
            end
            local function hasLineOfSight(r0_6)
              -- line: [0, 0] id: 6
              local r1_6 = localPlayer.Character.Head.Position + Vector3.new(0, 1, 0)
              local r2_6 = nil
              local r3_6 = nil
              if r0_6:IsA("Model") then
                if r0_6:FindFirstChild(state.RealAimPart) then
                  r3_6 = r0_6:FindFirstChild(state.RealAimPart).Position
                else
                  return false
                end
              end
              if not r3_6 then
                r3_6 = r0_6.Character.HumanoidRootPart.Position
              end
              local r4_6 = workspace:Raycast(r1_6, ((r3_6 - r1_6)).Unit * ((r3_6 - r1_6)).Magnitude, refreshWallRaycastParams())
              if r4_6 and r4_6.Instance.Parent:FindFirstChildOfClass("Humanoid") then
                return true
              end
              return false
            end
            local function isValidAimTarget(r0_37)
              -- line: [0, 0] id: 37
              local r1_37 = false
              if r0_37:IsA("Model") then
                r1_37 = true
              end
              if r1_37 == false and not r0_37.Character then
                return false
              end
              if r1_37 == false and not r0_37.Character:FindFirstChild("Head") then
                return false
              end
              if r1_37 == false and r0_37.Character:FindFirstChild("Humanoid") and r0_37.Character.Humanoid.Health <= 0 then
                return false
              end
              local r2_37 = state.TeamCheck
              if r2_37 and r1_37 == false then
                r2_37 = game.ReplicatedStorage.Players
                local function r3_37(r0_38)
                  -- line: [0, 0] id: 38
                  return r2_37[r0_38.Name].Status.Journey.Clan:GetAttribute("CurrentClan")
                end
                local r4_37 = r3_37(localPlayer)
                if r4_37 then
                  local r5_37 = r3_37(r0_37)
                  if r5_37 and not r4_37 == nil or not r4_37 == "nil" or r5_37 and not r5_37 == nil or not r5_37 == "nil" then
                    if r4_37 == r5_37 then
                      return false
                    end
                    return true
                  end
                end
                -- close: r2_37
              end
              r2_37 = true
              return r2_37
            end
            local r104_0 = LastTargetSwitchTime or 0
            local r105_0 = 0.02
            local function getAimbotTargetCharacterForVisibility(target)
              if not target then
                return nil
              end
              if target:IsA("Player") then
                return target.Character
              end
              if target:IsA("Model") then
                return target
              end
            end

            local function getTargetAimPart(target)
              local character = getSmartAimCharacter(target) or getAimbotTargetCharacterForVisibility(target)
              if not character then
                return nil
              end

              return character:FindFirstChild(state.RealAimPart or state.AimPart) or character:FindFirstChild("Head")
            end

            local function getTargetAimPoint(target)
              local aimPart = getTargetAimPart(target)
              if not aimPart then
                return nil, nil
              end
              if target == state.LastTarget and state._bestAimPoint and (not state._bestAimPart or state._bestAimPart == aimPart.Name) then
                return state._bestAimPoint, aimPart
              end
              return aimPart.Position, aimPart
            end

            local function isTargetPartHit(hitPart, character, target)
              local current = hitPart
              while current do
                if current == character or current == target then
                  return true
                end
                current = current.Parent
              end
              return false
            end

            local function isAnyPartVisible(target)
              local character = getSmartAimCharacter(target) or getAimbotTargetCharacterForVisibility(target)
              if not character then
                return false
              end

              if not state.WallCheck then
                return true
              end

              local cached = getVisibilityCacheEntry(target)
              if cached.anyVisible ~= nil then
                return cached.anyVisible
              end

              if getDirectlyVisiblePart(target, character) then
                cached.anyVisible = true
                return true
              end

              if state.WallBang then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                  local canBang, wallCount, damageReduction, objects = wallBang.check(camera.CFrame.Position, hrp.Position, character)
                  if canBang and wallCount > 0 then
                    state._wallBangInfo = {
                      wallCount = wallCount,
                      damageReduction = damageReduction,
                      objects = objects,
                      totalThickness = objects and objects.totalThickness or 0,
                      target = target,
                      character = character,
                      partName = "HumanoidRootPart",
                    }
                    if state.WallBangIndicator then
                      wallBang.showIndicator(wallCount, wallBang.getTargetName(target), objects and objects.totalThickness)
                    end
                  end
                end
              end

              cached.anyVisible = false
              return false
            end

            local function isAimbotTargetTeammate(target)
              if not state.TeamCheck or not target or target:IsA("Model") then
                return false
              end

              local playersFolder = game.ReplicatedStorage and game.ReplicatedStorage:FindFirstChild("Players")
              local function getClan(player)
                local playerData = playersFolder and playersFolder:FindFirstChild(player.Name)
                local status = playerData and playerData:FindFirstChild("Status")
                local journey = status and status:FindFirstChild("Journey")
                local clan = journey and journey:FindFirstChild("Clan")
                return clan and clan:GetAttribute("CurrentClan")
              end

              local localClan = getClan(localPlayer)
              local targetClan = getClan(target)
              return localClan and targetClan and localClan ~= "nil" and targetClan ~= "nil" and localClan == targetClan
            end

            local function releaseAutoShootHold()
              if state.AutoShootHoldActive then
                state.AutoShootHoldActive = false
                mouse1release()
              end
            end

            local function fireAutoShoot()
              if state.AutoShootMode == "Hold" then
                if not state.AutoShootHoldActive then
                  state.AutoShootHoldActive = true
                  mouse1press()
                end
              else
                local now = tick()
                local delaySeconds = state.AutoShootSpeed or 0.05
                if now - (state.AutoShootLastShot or 0) >= delaySeconds then
                  state.AutoShootLastShot = now
                  mouse1press()
                  task.delay(0.01, function()
                    if not state.AutoShootHoldActive then
                      mouse1release()
                    end
                  end)
                end
              end
            end

            local function getWallBangAutoShootInfo(target, aimPoint)
              if not state.WallBang or not state.WallCheck or not target then
                return nil
              end

              local info = state._wallBangInfo
              if not info or info.target ~= target then
                return nil
              end

              local character = info.character or getSmartAimCharacter(target) or getAimbotTargetCharacterForVisibility(target)
              if not character or not character.Parent then
                return nil
              end

              local shotPoint = aimPoint or state._bestAimPoint
              if not shotPoint then
                local fallbackPart = character:FindFirstChild(info.partName or state.RealAimPart or state.AimPart) or character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
                shotPoint = fallbackPart and fallbackPart.Position or nil
              end
              if not shotPoint then
                return nil
              end

              local canBang, wallCount, damageReduction, objects = wallBang.check(camera.CFrame.Position, shotPoint, character)
              if not canBang or wallCount <= 0 then
                return nil
              end

              info.wallCount = wallCount
              info.damageReduction = damageReduction
              info.objects = objects
              info.totalThickness = objects and objects.totalThickness or 0
              info.character = character
              if state.WallBangIndicator then
                wallBang.showIndicator(wallCount, wallBang.getTargetName(target), info.totalThickness)
              end
              return info
            end

            local function findAutoShootTarget()
              local target = state.LastTarget
              if target then
                local aimPoint, aimPart = getTargetAimPoint(target)
                if aimPart and aimPoint and isPointInsideAimFov(aimPoint, "Normal") and not isAimbotTargetTeammate(target) then
                  if isAnyPartVisible(target) or getWallBangAutoShootInfo(target, aimPoint) then
                    return target
                  end
                end
              end

              if not state.SilentAimbot then
                return nil
              end

              local closestTarget = nil
              local closestDist = math.huge
              local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
              for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character and isAnyPartVisible(player) and not isAimbotTargetTeammate(player) then
                  local character = getSmartAimCharacter(player)
                  if character then
                    local bestPlayerDist = math.huge
                    for _, partInfo in ipairs(smartAimBodyParts) do
                      local part = character:FindFirstChild(partInfo.name)
                      if part then
                        local visiblePoint, dist = getBestVisiblePoint(part, character, player, center)
                        if visiblePoint and dist < bestPlayerDist then
                          bestPlayerDist = dist
                        end
                      end
                    end
                    if bestPlayerDist < closestDist and bestPlayerDist <= (state.AimbotFov or 100) then
                      closestDist = bestPlayerDist
                      closestTarget = player
                    end
                  end
                end
              end

              if closestTarget then
                state.LastTarget = closestTarget
              end
              return closestTarget
            end
            local function isScanTargetValid(target)
              if not target then
                return false
              end

              if target:IsA("Player") then
                return state.AimbotPlayer and target ~= localPlayer and isValidAimTarget(target) and not playerEsp.Moderators[target.Name] and not isAimbotTargetTeammate(target)
              end

              if target:IsA("Model") then
                local humanoid = target:FindFirstChild("Humanoid")
                return state.AimbotTargetAi and humanoid and humanoid.Health > 0
              end

              return false
            end

            function wallBang.scanForWallBangTargets()
              if not state.WallBang or not state.WallCheck or not state.MasterAimbot then
                wallBang.wallBangTargets = {}
                return {}
              end

              local now = tick()
              if now - (wallBang.lastScanTime or 0) < (wallBang.scanInterval or 0.5) then
                return wallBang.wallBangTargets or {}
              end
              wallBang.lastScanTime = now

              local targets = {}
              local origin = camera.CFrame.Position
              local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
              local fovRadius = state.AimbotFov or 100
              local myHead = localPlayer.Character and localPlayer.Character:FindFirstChild("Head")
              local rayParams = RaycastParams.new()
              rayParams.FilterType = Enum.RaycastFilterType.Exclude
              rayParams.FilterDescendantsInstances = { localPlayer.Character }
              rayParams.IgnoreWater = true

              local function considerTarget(scanTarget, returnedTarget)
                if not isScanTargetValid(scanTarget) then
                  return
                end

                local character = getSmartAimCharacter(scanTarget) or getAimbotTargetCharacterForVisibility(scanTarget)
                if not character then
                  return
                end

                local bestScore = nil
                local bestWallCount = 0
                local bestDamageReduction = 0
                local bestPoint = nil
                local bestPartName = nil
                local bestObjects = nil

                for _, partInfo in ipairs(smartAimBodyParts) do
                  local part = character:FindFirstChild(partInfo.name)
                  if part then
                    local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                    if onScreen and screenPos.Z > 0 then
                      local crosshairDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                      if crosshairDist <= fovRadius then
                        local delta = part.Position - origin
                        if delta.Magnitude > 1 and delta.Magnitude <= 5000 then
                          local firstHit = workspace:Raycast(origin, delta.Unit * delta.Magnitude, rayParams)
                          if firstHit and not wallBang.hitIsTarget(firstHit.Instance, character) then
                            local canBang, wallCount, damageReduction, objects = wallBang.check(origin, part.Position, character)
                            if canBang and wallCount > 0 then
                              local score
                              if state.AimbotAimMethod == "Furthest from Crosshair" then
                                score = -crosshairDist
                              elseif state.AimbotAimMethod == "Closest Distance" then
                                score = myHead and (part.Position - myHead.Position).Magnitude or math.huge
                              else
                                score = crosshairDist
                              end
                              score = score + (wallCount * 5) + (((partInfo and partInfo.priority) or 99) * 0.1) + (((objects and objects.totalThickness) or 0) * 2)

                              if bestScore == nil or score < bestScore then
                                bestScore = score
                                bestWallCount = wallCount
                                bestDamageReduction = damageReduction or 0
                                bestPoint = part.Position
                                bestPartName = part.Name
                                bestObjects = objects
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end

                if bestScore ~= nil then
                  table.insert(targets, {
                    target = returnedTarget or scanTarget,
                    scanTarget = scanTarget,
                    character = character,
                    wallCount = bestWallCount,
                    damageReduction = bestDamageReduction,
                    objects = bestObjects,
                    totalThickness = bestObjects and bestObjects.totalThickness or 0,
                    score = bestScore,
                    position = bestPoint,
                    partName = bestPartName,
                    timestamp = now,
                  })
                end
              end

              if state.AimbotPlayer then
                for _, player in ipairs(Players:GetPlayers()) do
                  considerTarget(player)
                end
              end

              if state.AimbotTargetAi and workspace:FindFirstChild("AiZones") then
                for _, zone in pairs(workspace.AiZones:GetChildren()) do
                  for _, ai in pairs(zone:GetChildren()) do
                    if ai:IsA("Model") then
                      local returnedTarget = ai
                      if ai.Name == "MI24V" and ai:FindFirstChild("Pilots") and ai.Pilots:FindFirstChild("Pilot") then
                        returnedTarget = ai.Pilots.Pilot
                      end
                      considerTarget(ai, returnedTarget)
                    end
                  end
                end
              end

              table.sort(targets, function(a, b)
                return (a.score or math.huge) < (b.score or math.huge)
              end)

              wallBang.wallBangTargets = targets
              if #targets > 0 and state.WallBangIndicator then
                local best = targets[1]
                wallBang.showIndicator(best.wallCount, wallBang.getTargetName(best.target), best.totalThickness)
              end

              return targets
            end

            function wallBang.getBestWallBangTarget()
              local targets = wallBang.scanForWallBangTargets()
              if targets then
                for index = #targets, 1, -1 do
                  local targetInfo = targets[index]
                  if not targetInfo or not isScanTargetValid(targetInfo.scanTarget or targetInfo.target) then
                    table.remove(targets, index)
                  end
                end
                if targets[1] then
                  return targets[1]
                end
              end
              return nil
            end

            scoreWallBangCandidate = function(target, character, center, myHead)
              if not state.WallBang or not state.WallCheck or not target or not character then
                return nil
              end

              center = center or Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
              local bestScore = nil
              local bestPartName = nil
              local bestPoint = nil
              local bestWallCount = nil
              local bestDamageReduction = nil
              local bestObjects = nil
              local fovRadius = state.AimbotFov or 100

              for _, partInfo in ipairs(smartAimBodyParts) do
                local part = character:FindFirstChild(partInfo.name)
                if part then
                  local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                  if onScreen and screenPos.Z > 0 then
                    local crosshairDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if crosshairDist <= fovRadius then
                      local canBang, wallCount, damageReduction, objects = wallBang.check(camera.CFrame.Position, part.Position, character)
                      if canBang and wallCount > 0 then
                        local score
                        if state.AimbotAimMethod == "Furthest from Crosshair" then
                          score = -crosshairDist
                        elseif state.AimbotAimMethod == "Closest Distance" then
                          score = myHead and (part.Position - myHead.Position).Magnitude or math.huge
                        else
                          score = crosshairDist
                        end

                        score = score + (((partInfo and partInfo.priority) or 99) * 0.1) + (((objects and objects.totalThickness) or 0) * 2)
                        if bestScore == nil or score < bestScore then
                          bestScore = score
                          bestPartName = part.Name
                          bestPoint = part.Position
                          bestWallCount = wallCount
                          bestDamageReduction = damageReduction
                          bestObjects = objects
                        end
                      end
                    end
                  end
                end
              end

              if bestScore ~= nil and target == state.LastTarget then
                state._bestAimPoint = bestPoint
                state._bestAimPart = bestPartName
                state.RealAimPart = bestPartName or state.RealAimPart
                state._wallBangInfo = {
                  wallCount = bestWallCount,
                  damageReduction = bestDamageReduction,
                  objects = bestObjects,
                  totalThickness = bestObjects and bestObjects.totalThickness or 0,
                  target = target,
                  character = character,
                  partName = bestPartName,
                }
              end

              return bestScore
            end

            local function scoreAimbotScanTarget(target)
              local character = getSmartAimCharacter(target) or getAimbotTargetCharacterForVisibility(target)
              if not character then
                return nil
              end
              local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
              local myHead = localPlayer.Character and localPlayer.Character:FindFirstChild("Head")
              if state.WallCheck then
                local directlyVisible = getDirectlyVisiblePart(target, character) ~= nil
                if not directlyVisible then
                  if state.WallBang then
                    return scoreWallBangCandidate(target, character, center, myHead)
                  end
                  return nil
                end
              end

              local bestScore = nil
              local fovRadius = state.AimbotFov or 100

              for _, partInfo in ipairs(smartAimBodyParts) do
                local part = character:FindFirstChild(partInfo.name)
                if part then
                  local visiblePoint, crosshairDist = getBestVisiblePoint(part, character, target, center)
                  if visiblePoint and crosshairDist <= fovRadius then
                    local score

                    if state.AimbotAimMethod == "Furthest from Crosshair" then
                      score = -crosshairDist
                    elseif state.AimbotAimMethod == "Closest Distance" then
                      score = myHead and (visiblePoint - myHead.Position).Magnitude or math.huge
                    else
                      score = crosshairDist
                    end

                    score = score + (((partInfo and partInfo.priority) or 99) * 0.1)

                    if bestScore == nil or score < bestScore then
                      bestScore = score
                    end
                  end
                end
              end

              return bestScore
            end

            local function getLightweightScore(target)
              local character = getSmartAimCharacter(target) or getAimbotTargetCharacterForVisibility(target)
              if not character then
                return nil
              end
              local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
              local myHead = localPlayer.Character and localPlayer.Character:FindFirstChild("Head")
              if state.WallCheck then
                local directlyVisible = getDirectlyVisiblePart(target, character) ~= nil
                if not directlyVisible then
                  if state.WallBang then
                    return scoreWallBangCandidate(target, character, center, myHead)
                  end
                  return nil
                end
              end

              local bestScore = nil
              local fovRadius = state.AimbotFov or 100

              for _, partInfo in ipairs(smartAimBodyParts) do
                local partName = partInfo.name
                local part = character:FindFirstChild(partName)
                if part then
                  local visiblePoint, crosshairDist = getBestVisiblePoint(part, character, target, center)
                  if visiblePoint and crosshairDist <= fovRadius then
                    local score

                    if state.AimbotAimMethod == "Furthest from Crosshair" then
                      score = -crosshairDist
                    elseif state.AimbotAimMethod == "Closest Distance" then
                      score = myHead and (visiblePoint - myHead.Position).Magnitude or math.huge
                    else
                      score = crosshairDist
                    end

                    local priority = (state.AimbotBodyPartPriority and state.AimbotBodyPartPriority[partName]) or partInfo.priority or 99
                    score = score + (priority * 0.02)

                    if bestScore == nil or score < bestScore then
                      bestScore = score
                    end
                  end
                end
              end

              return bestScore
            end

            local function cacheAimbotScanTarget(targets, scanTarget, returnedTarget)
              if not isScanTargetValid(scanTarget) then
                return
              end

              local score = scoreAimbotScanTarget(scanTarget)
              if score then
                table.insert(targets, {
                  target = returnedTarget or scanTarget,
                  scanTarget = scanTarget,
                  score = score,
                  timestamp = tick(),
                })
              end
            end

            local function performFullTargetScan()
              local targets = {}

              if state.AimbotPlayer then
                for _, player in ipairs(Players:GetPlayers()) do
                  cacheAimbotScanTarget(targets, player)
                end
              end

              if state.AimbotTargetAi and workspace:FindFirstChild("AiZones") then
                for _, zone in pairs(workspace.AiZones:GetChildren()) do
                  for _, ai in pairs(zone:GetChildren()) do
                    if ai:IsA("Model") then
                      local returnedTarget = ai
                      if ai.Name == "MI24V" and ai:FindFirstChild("Pilots") and ai.Pilots:FindFirstChild("Pilot") then
                        returnedTarget = ai.Pilots.Pilot
                      end
                      cacheAimbotScanTarget(targets, ai, returnedTarget)
                    end
                  end
                end
              end

              table.sort(targets, function(a, b)
                return (a.score or math.huge) < (b.score or math.huge)
              end)

              state.TargetCache = targets
              state.TargetList = targets
              state.CurrentTargetIndex = 1
              state.LastFullScan = tick()
              state.ForceScan = false

              if #targets > 0 then
                if state.StickyAim and state.LastTarget and isAnyPartVisible(state.LastTarget) then
                  return #targets
                end

                state.LastTarget = targets[1].target
                r104_0 = state.LastFullScan
              elseif not state.StickyAim then
                state.LastTarget = nil
              end

              return #targets
            end

            local function getBestCachedTarget()
              local bestTarget = nil
              local bestScore = math.huge

              for _, cached in ipairs(state.TargetCache or {}) do
                local scanTarget = cached.scanTarget or cached.target
                if isScanTargetValid(scanTarget) then
                  local score = scoreAimbotScanTarget(scanTarget)
                  if score and score < bestScore then
                    cached.score = score
                    bestScore = score
                    bestTarget = cached.target or scanTarget
                  end
                end
              end

              return bestTarget
            end

            local function getBestLightweightTarget()
              local bestTarget = nil
              local bestScore = math.huge

              local function considerTarget(scanTarget, returnedTarget)
                if not isScanTargetValid(scanTarget) then
                  return
                end

                local score = getLightweightScore(scanTarget)
                if score and score < bestScore then
                  bestScore = score
                  bestTarget = returnedTarget or scanTarget
                end
              end

              for _, cached in ipairs(state.TargetCache or {}) do
                local scanTarget = cached.scanTarget or cached.target
                if isScanTargetValid(scanTarget) then
                  local score = getLightweightScore(scanTarget)
                  if score and score < bestScore then
                    cached.score = score
                    bestScore = score
                    bestTarget = cached.target or scanTarget
                  end
                end
              end

              if state.AimbotPlayer then
                for _, player in ipairs(Players:GetPlayers()) do
                  considerTarget(player)
                end
              end

              if state.AimbotTargetAi and workspace:FindFirstChild("AiZones") then
                for _, zone in pairs(workspace.AiZones:GetChildren()) do
                  for _, ai in pairs(zone:GetChildren()) do
                    if ai:IsA("Model") then
                      local returnedTarget = ai
                      if ai.Name == "MI24V" and ai:FindFirstChild("Pilots") and ai.Pilots:FindFirstChild("Pilot") then
                        returnedTarget = ai.Pilots.Pilot
                      end
                      considerTarget(ai, returnedTarget)
                    end
                  end
                end
              end

              return bestTarget, bestScore
            end

            local function selectAimbotTarget()
              -- line: [0, 0] id: 307
              local now = tick()
              local scanInterval = state.ScanInterval or 10

              local function hasDirectVisibleScanTarget(scanTarget)
                if not isScanTargetValid(scanTarget) then
                  return false
                end
                local character = getSmartAimCharacter(scanTarget) or getAimbotTargetCharacterForVisibility(scanTarget)
                return character and getDirectlyVisiblePart(scanTarget, character) ~= nil
              end

              local function hasAnyDirectVisibleTarget()
                for _, cached in ipairs(state.TargetCache or {}) do
                  if hasDirectVisibleScanTarget(cached.scanTarget or cached.target) then
                    return true
                  end
                end

                if state.AimbotPlayer then
                  for _, player in ipairs(Players:GetPlayers()) do
                    if hasDirectVisibleScanTarget(player) then
                      return true
                    end
                  end
                end

                if state.AimbotTargetAi and workspace:FindFirstChild("AiZones") then
                  for _, zone in pairs(workspace.AiZones:GetChildren()) do
                    for _, ai in pairs(zone:GetChildren()) do
                      if ai:IsA("Model") and hasDirectVisibleScanTarget(ai) then
                        return true
                      end
                    end
                  end
                end

                return false
              end

              if state.WallBang and state.WallCheck then
                local currentTarget = state.LastTarget
                local currentCharacter = currentTarget and (getSmartAimCharacter(currentTarget) or getAimbotTargetCharacterForVisibility(currentTarget))
                local currentDirectVisible = currentCharacter and getDirectlyVisiblePart(currentTarget, currentCharacter) ~= nil
                if not currentDirectVisible and not hasAnyDirectVisibleTarget() then
                  local wallTarget = wallBang.getBestWallBangTarget()
                  if wallTarget then
                    state.LastTarget = wallTarget.target
                    state._bestAimPoint = wallTarget.position
                    state._bestAimPart = wallTarget.partName
                    state.RealAimPart = wallTarget.partName or state.RealAimPart
                    state._wallBangInfo = {
                      wallCount = wallTarget.wallCount,
                      damageReduction = wallTarget.damageReduction,
                      objects = wallTarget.objects,
                      totalThickness = wallTarget.totalThickness or (wallTarget.objects and wallTarget.objects.totalThickness) or 0,
                      target = wallTarget.target,
                      character = wallTarget.character,
                      partName = wallTarget.partName,
                    }
                    r104_0 = now
                    if state.WallBangIndicator then
                      wallBang.showIndicator(wallTarget.wallCount, wallBang.getTargetName(wallTarget.target), wallTarget.totalThickness or (wallTarget.objects and wallTarget.objects.totalThickness))
                    end
                    return
                  end
                end
                if state._wallBangInfo then
                  state._bestAimPoint = nil
                  state._bestAimPart = nil
                end
                state._wallBangInfo = nil
              end

              if state.ForceScan or not state.TargetCache or now - (state.LastFullScan or 0) >= scanInterval then
                performFullTargetScan()
                return
              end

              if state.StickyAim and state.LastTarget and isAnyPartVisible(state.LastTarget) then
                return
              end

              local currentTarget = state.LastTarget
              local currentValid = currentTarget and isScanTargetValid(currentTarget)
              local currentVisible = currentValid and isAnyPartVisible(currentTarget)
              local currentScore = currentVisible and getLightweightScore(currentTarget) or nil

              local bestTarget, bestScore = getBestLightweightTarget()

              if bestTarget then
                if bestTarget == currentTarget and currentVisible then
                  return
                end

                if not currentVisible or not currentScore or bestScore < currentScore then
                  if not currentVisible or now - r104_0 >= r105_0 then
                    state.LastTarget = bestTarget
                    r104_0 = now
                  end
                  return
                end
              end

              if currentVisible then
                return
              end

              local cachedTarget = getBestCachedTarget()
              if cachedTarget then
                state.LastTarget = cachedTarget
                r104_0 = now
                return
              end

              if state.TargetCache and #state.TargetCache == 0 then
                state.LastTarget = nil
                return
              end

              performFullTargetScan()
              do
                return
              end

              local r0_307 = nil
              if state.StickyAim and state.LastTarget then
                  -- Check if any part of the target is still visible
                  if isAnyPartVisible(state.LastTarget) then
                      r0_307 = false
                  else
                      r0_307 = true
                  end
              end
              if r0_307 == false then
                  return 
              end

              local selectedTarget = nil
              local selectedScore = math.huge
              local selectedAt = tick()
              local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
              local myHead = localPlayer.Character and localPlayer.Character:FindFirstChild("Head")

              local function scoreTargetCandidate(target)
                local character = getSmartAimCharacter(target) or getAimbotTargetCharacterForVisibility(target)
                if not character then
                  return nil
                end
                if state.WallCheck then
                  local directlyVisible = getDirectlyVisiblePart(target, character) ~= nil
                  if not directlyVisible then
                    if state.WallBang then
                      return scoreWallBangCandidate(target, character, center, myHead)
                    end
                    return nil
                  end
                end

                local bestScore = nil
                local fovRadius = state.AimbotFov or 100
                for _, partInfo in ipairs(smartAimBodyParts) do
                  local part = character:FindFirstChild(partInfo.name)
                  if part and (not state.WallCheck or isPartVisible(part, target)) then
                    local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                    if onScreen and screenPos.Z > 0 then
                      local crosshairDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                      if crosshairDist <= fovRadius then
                        local score

                        if state.AimbotAimMethod == "Furthest from Crosshair" then
                          score = -crosshairDist
                        elseif state.AimbotAimMethod == "Closest Distance" then
                          score = myHead and (part.Position - myHead.Position).Magnitude or math.huge
                        else
                          score = crosshairDist
                        end

                        score = score + (((partInfo and partInfo.priority) or 99) * 0.1)

                        if bestScore == nil or score < bestScore then
                          bestScore = score
                        end
                      end
                    end
                  end
                end

                return bestScore
              end

              local function considerTarget(target, returnedTarget)
                local score = scoreTargetCandidate(target)
                if score and score < selectedScore then
                  selectedScore = score
                  selectedTarget = returnedTarget or target
                end
              end

              if state.AimbotPlayer then
                for _, player in ipairs(Players:GetPlayers()) do
                  if player ~= localPlayer and isValidAimTarget(player) and not playerEsp.Moderators[player.Name] then
                    considerTarget(player)
                  end
                end
              end

              if state.AimbotTargetAi and workspace:FindFirstChild("AiZones") then
                for _, zone in pairs(workspace.AiZones:GetChildren()) do
                  for _, ai in pairs(zone:GetChildren()) do
                    if ai:IsA("Model") and ai:FindFirstChild("Humanoid") and ai.Humanoid.Health > 0 then
                      local returnedTarget = ai
                      if ai.Name == "MI24V" and ai:FindFirstChild("Pilots") and ai.Pilots:FindFirstChild("Pilot") then
                        returnedTarget = ai.Pilots.Pilot
                      end
                      considerTarget(ai, returnedTarget)
                    end
                  end
                end
              end

              if selectedTarget and (state.LastTarget ~= selectedTarget or r105_0 <= selectedAt - r104_0) then
                state.LastTarget = selectedTarget
                r104_0 = selectedAt
              elseif not selectedTarget then
                state.LastTarget = nil
              end
              do
                return
              end
              
              local r1_307 = nil
              local r2_307 = math.huge
              local r3_307 = tick()
              
              if state.AimbotPlayer then
                  for r11_307, r12_307 in ipairs(Players:GetPlayers()) do
                      if r12_307 ~= localPlayer and isValidAimTarget(r12_307) and not playerEsp.Moderators[r12_307.Name] then
                          -- Check if ANY part of this player is visible
                          if isAnyPartVisible(r12_307) then
                              -- Use the closest visible part for distance calculation
                              local closestPart = nil
                              local closestDist = math.huge
                              local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                              
                              -- Check all body parts to find the closest one to center
                              local bodyPartsToCheck = {
                                  "Head", "UpperTorso", "LowerTorso",
                                  "RightUpperArm", "LeftUpperArm", "RightLowerArm", "LeftLowerArm",
                                  "RightHand", "LeftHand",
                                  "RightUpperLeg", "LeftUpperLeg", "RightLowerLeg", "LeftLowerLeg",
                                  "RightFoot", "LeftFoot"
                              }
                              
                              for _, partName in ipairs(bodyPartsToCheck) do
                                  local part = r12_307.Character:FindFirstChild(partName)
                                  if part then
                                      local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                                      if onScreen then
                                          local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                                          if dist < closestDist and dist <= state.AimbotFov then
                                              closestDist = dist
                                              closestPart = part
                                          end
                                      end
                                  end
                              end
                              
                              if closestPart then
                                  r4_307 = closestPart.Position
                                  r5_307 = camera:WorldToViewportPoint(r4_307)
                                  r6_307 = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                                  r7_307 = (Vector2.new(r5_307.X, r5_307.Y) - r6_307).Magnitude
                                  if r7_307 < r2_307 then
                                      r2_307 = r7_307
                                      r1_307 = r12_307
                                  end
                              end
                          end
                      end
                  end
              end
              
              if state.AimbotTargetAi then
                  for r11_307, r12_307 in pairs(workspace.AiZones:GetChildren()) do
                      for r16_307, r17_307 in pairs(r12_307:GetChildren()) do
                          if r17_307:IsA("Model") and r17_307:FindFirstChild("Humanoid") then
                              if isAnyPartVisible(r17_307) then
                                  local closestPart = nil
                                  local closestDist = math.huge
                                  local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                                  
                                  local bodyPartsToCheck = {
                                      "Head", "UpperTorso", "LowerTorso",
                                      "RightUpperArm", "LeftUpperArm", "RightLowerArm", "LeftLowerArm",
                                      "RightHand", "LeftHand",
                                      "RightUpperLeg", "LeftUpperLeg", "RightLowerLeg", "LeftLowerLeg",
                                      "RightFoot", "LeftFoot"
                                  }
                                  
                                  for _, partName in ipairs(bodyPartsToCheck) do
                                      local part = r17_307:FindFirstChild(partName)
                                      if part then
                                          local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                                          if onScreen then
                                              local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                                              if dist < closestDist and dist <= state.AimbotFov then
                                                  closestDist = dist
                                                  closestPart = part
                                              end
                                          end
                                      end
                                  end
                                  
                                  if closestPart then
                                      r4_307 = closestPart.Position
                                      r5_307 = camera:WorldToViewportPoint(r4_307)
                                      r6_307 = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                                      r7_307 = (Vector2.new(r5_307.X, r5_307.Y) - r6_307).Magnitude
                                      if r7_307 < r2_307 then
                                          r2_307 = r7_307
                                          if r17_307.Name == "MI24V" then
                                              r1_307 = r17_307.Pilots.Pilot
                                          else
                                              r1_307 = r17_307
                                          end
                                      end
                                  end
                              end
                          end
                      end
                  end
              end
              
              if r1_307 and (state.LastTarget ~= r1_307 or r105_0 <= r3_307 - r104_0) then
                  state.LastTarget = r1_307
                  r104_0 = r3_307
              end
              if not r1_307 then
                  state.LastTarget = nil
              end
            end
            local function requestAimbotTargetScan()
              state.ForceScan = true
            end

            Players.PlayerAdded:Connect(function()
              requestAimbotTargetScan()
              task.delay(2, requestAimbotTargetScan)
            end)

            Players.PlayerRemoving:Connect(function(player)
              if state.LastTarget == player then
                state.LastTarget = nil
              end
              requestAimbotTargetScan()
            end)

            local function watchAimbotAiZone(zone)
              if not zone then
                return
              end

              zone.ChildAdded:Connect(function(child)
                if child:IsA("Model") then
                  requestAimbotTargetScan()
                end
              end)

              zone.ChildRemoved:Connect(function(child)
                if state.LastTarget == child then
                  state.LastTarget = nil
                end
                requestAimbotTargetScan()
              end)
            end

            local aimbotAiZones = workspace:FindFirstChild("AiZones")
            if aimbotAiZones then
              for _, zone in pairs(aimbotAiZones:GetChildren()) do
                watchAimbotAiZone(zone)
              end

              aimbotAiZones.ChildAdded:Connect(function(zone)
                watchAimbotAiZone(zone)
                requestAimbotTargetScan()
              end)

              aimbotAiZones.ChildRemoved:Connect(function()
                requestAimbotTargetScan()
              end)
            end
            local r107_0 = game.ReplicatedStorage.Players:FindFirstChild(localPlayer.Name)
            local weaponStatsCache = {
              Mosin = { speed = 850, drop = 5 },
              SVD = { speed = 830, drop = 6 },
              SV98 = { speed = 860, drop = 4 },
              M40 = { speed = 840, drop = 5 },
              M24 = { speed = 850, drop = 4 },
              AWM = { speed = 900, drop = 3 },
              AW = { speed = 890, drop = 3 },
              L96 = { speed = 880, drop = 3 },
              M82 = { speed = 920, drop = 2 },
              Barrett = { speed = 910, drop = 2 },
              M107 = { speed = 900, drop = 2 },
              T5000 = { speed = 820, drop = 6 },
              M98B = { speed = 870, drop = 4 },
              Sako = { speed = 840, drop = 5 },
              SKS = { speed = 750, drop = 8 },
              VSS = { speed = 320, drop = 25 },
              ["AS-Val"] = { speed = 320, drop = 25 },
              M21 = { speed = 780, drop = 7 },
              SR25 = { speed = 790, drop = 7 },
              MK11 = { speed = 780, drop = 7 },
              G3 = { speed = 760, drop = 8 },
              PSG1 = { speed = 780, drop = 7 },
              MSG90 = { speed = 790, drop = 7 },
              AK = { speed = 720, drop = 10 },
              ["AK-47"] = { speed = 720, drop = 10 },
              AKM = { speed = 710, drop = 10 },
              AK74 = { speed = 730, drop = 9 },
              AKS = { speed = 720, drop = 10 },
              ["AK-12"] = { speed = 740, drop = 9 },
              M4 = { speed = 750, drop = 8 },
              M16 = { speed = 760, drop = 8 },
              M416 = { speed = 750, drop = 8 },
              AR15 = { speed = 740, drop = 8 },
              G36 = { speed = 730, drop = 9 },
              G36C = { speed = 720, drop = 9 },
              SCAR = { speed = 740, drop = 8 },
              FAL = { speed = 760, drop = 8 },
              FNC = { speed = 730, drop = 9 },
              SG550 = { speed = 740, drop = 8 },
              AUG = { speed = 730, drop = 9 },
              L85 = { speed = 720, drop = 9 },
              Famas = { speed = 740, drop = 8 },
              Galil = { speed = 720, drop = 9 },
              RPK = { speed = 710, drop = 10 },
              RPD = { speed = 700, drop = 11 },
              PKM = { speed = 730, drop = 9 },
              M60 = { speed = 720, drop = 10 },
              MG42 = { speed = 740, drop = 9 },
              M249 = { speed = 730, drop = 9 },
              SAW = { speed = 730, drop = 9 },
              MP5 = { speed = 500, drop = 18 },
              MP7 = { speed = 520, drop = 17 },
              P90 = { speed = 530, drop = 16 },
              UMP45 = { speed = 490, drop = 19 },
              Vector = { speed = 540, drop = 15 },
              Bizon = { speed = 460, drop = 20 },
              PPSh41 = { speed = 480, drop = 19 },
              M3 = { speed = 450, drop = 22 },
              Kedr = { speed = 470, drop = 20 },
              MP9 = { speed = 510, drop = 17 },
              Scorpion = { speed = 490, drop = 18 },
              ["PP-19"] = { speed = 470, drop = 20 },
              ["PP-2000"] = { speed = 490, drop = 18 },
              SR2 = { speed = 510, drop = 17 },
              MPX = { speed = 520, drop = 16 },
              MCX = { speed = 510, drop = 17 },
              TT = { speed = 400, drop = 28 },
              PM = { speed = 350, drop = 30 },
              Tokarev = { speed = 400, drop = 28 },
              G17 = { speed = 380, drop = 29 },
              G18 = { speed = 380, drop = 29 },
              M9 = { speed = 390, drop = 28 },
              P226 = { speed = 390, drop = 28 },
              USP = { speed = 400, drop = 27 },
              FN57 = { speed = 420, drop = 25 },
              M1911 = { speed = 380, drop = 29 },
              Deagle = { speed = 480, drop = 20 },
              Python = { speed = 450, drop = 22 },
              MP443 = { speed = 380, drop = 29 },
              MP455 = { speed = 380, drop = 29 },
              P38 = { speed = 370, drop = 30 },
              Stechkin = { speed = 390, drop = 28 },
              APS = { speed = 390, drop = 28 },
              M870 = { speed = 350, drop = 32 },
              M590 = { speed = 350, drop = 32 },
              SPAS12 = { speed = 360, drop = 31 },
              Saiga = { speed = 370, drop = 30 },
              KS23 = { speed = 380, drop = 29 },
              DP12 = { speed = 360, drop = 31 },
              AA12 = { speed = 370, drop = 30 },
              USAS12 = { speed = 370, drop = 30 },
              M1014 = { speed = 360, drop = 31 },
              FlareGun = { speed = 100, drop = 50 },
              RPG7 = { speed = 200, drop = 15 },
              RPG = { speed = 200, drop = 15 },
              MGL = { speed = 180, drop = 18 },
              GL40 = { speed = 170, drop = 20 },
              GP25 = { speed = 170, drop = 20 },
            }

            local function copyWeaponStats(stats)
              return {
                speed = stats.speed,
                drop = stats.drop,
              }
            end

            local function getCurrentWeaponName()
              local playersFolder = ReplicatedStorage:FindFirstChild("Players")
              local playerData = playersFolder and playersFolder:FindFirstChild(localPlayer.Name)
              local status = playerData and playerData:FindFirstChild("Status")
              local gameplay = status and status:FindFirstChild("GameplayVariables")
              local equippedTool = gameplay and gameplay:FindFirstChild("EquippedTool")
              if equippedTool and equippedTool.Value then
                return tostring(equippedTool.Value)
              end
              local equipped = gameplay and gameplay:GetAttribute("EquippedTool")
              if equipped then
                return tostring(equipped)
              end
              return "Unknown"
            end

            local function getCachedWeaponStats(weaponName)
              weaponName = tostring(weaponName or "")
              if weaponStatsCache[weaponName] then
                return copyWeaponStats(weaponStatsCache[weaponName])
              end
              local bestStats = nil
              local bestLength = 0
              for key, stats in pairs(weaponStatsCache) do
                if weaponName:find(key, 1, true) and #key > bestLength then
                  bestStats = stats
                  bestLength = #key
                end
              end
              return bestStats and copyWeaponStats(bestStats) or nil
            end

            local function getEquippedAmmoAttribute(r0_287)
              -- line: [0, 0] id: 287
              local status = r107_0 and r107_0:FindFirstChild("Status")
              local gameplay = status and status:FindFirstChild("GameplayVariables")
              local equippedTool = gameplay and gameplay:FindFirstChild("EquippedTool")
              local equippedToolName = equippedTool and equippedTool.Value
              if r107_0 and equippedToolName and r107_0:FindFirstChild("Inventory") then
                local r6_287 = r107_0.Inventory:FindFirstChild(tostring(equippedToolName))
                if r6_287 and r6_287:FindFirstChild("Attachments") then
                  local r7_287 = nil
                  for r11_287, r12_287 in pairs(r6_287.Attachments:GetChildren()) do
                    if r12_287.Name:lower():find("mag") or r12_287.Name:lower():find("rnd") then
                      r7_287 = r12_287:FindFirstChild("LoadedAmmo")
                      if r7_287 then
                        r7_287 = r7_287:GetChildren()[1]
                        break
                      else
                        break
                      end
                    end
                  end
                  if r7_287 then
                    local r8_287 = r7_287:GetAttribute("AmmoType")
                    if r8_287 then
                      local r9_287 = game.ReplicatedStorage.AmmoTypes:FindFirstChild(r8_287)
                      if r9_287 then
                        if r6_287:FindFirstChild("LoadedAmmo") then
                          local r3_287 = r6_287.LoadedAmmo:FindFirstChild("1")
                          if r3_287 then
                            local r4_287 = r3_287:GetAttribute("AmmoType")
                            if r4_287 then
                              local r5_287 = game.ReplicatedStorage.AmmoTypes:FindFirstChild(r4_287)
                              if r5_287 then
                                return r5_287:GetAttribute(r0_287) or 0
                              end
                            end
                          end
                        end
                        return r9_287:GetAttribute(r0_287) or 0
                      end
                    end
                  else
                    --goto label_91	-- block#17 is visited secondly
                  end
                end
              end
              return 0
            end
            local function getWeaponStats(weaponName)
              weaponName = tostring(weaponName or getCurrentWeaponName() or "Unknown")
              state._weaponCache = state._weaponCache or {}
              if state._weaponCache[weaponName] then
                return state._weaponCache[weaponName]
              end

              local speed = getEquippedAmmoAttribute("MuzzleVelocity")
              local drop = getEquippedAmmoAttribute("ProjectileDrop")
              if speed and speed > 0 then
                local stats = {
                  speed = speed,
                  drop = drop or 0,
                }
                state._weaponCache[weaponName] = stats
                return stats
              end

              local ammoTypes = ReplicatedStorage:FindFirstChild("AmmoTypes")
              local bulletType = ammoTypes and ammoTypes:FindFirstChild(weaponName)
              if not bulletType and ammoTypes then
                local bestLength = 0
                for _, ammo in ipairs(ammoTypes:GetChildren()) do
                  if weaponName:find(ammo.Name, 1, true) and #ammo.Name > bestLength then
                    bulletType = ammo
                    bestLength = #ammo.Name
                  end
                end
              end

              if bulletType then
                speed = bulletType:GetAttribute("MuzzleVelocity")
                drop = bulletType:GetAttribute("ProjectileDrop")
                if speed and speed > 0 then
                  local stats = {
                    speed = speed,
                    drop = drop or 12,
                  }
                  state._weaponCache[weaponName] = stats
                  return stats
                end
              end

              local stats = getCachedWeaponStats(weaponName) or {
                speed = 600,
                drop = 12,
              }
              state._weaponCache[weaponName] = stats
              return stats
            end
            local r109_0 = nil
            local function updateAimbot()
              -- line: [0, 0] id: 293
              if state.AimbotEnabled and state.LastTarget then
                local r0_293 = nil
                local r1_293 = nil
                local r2_293 = nil
                local r3_293 = nil
                local weaponStats = getWeaponStats()
                local r4_293 = weaponStats.speed
                local function r5_293(r0_294)
                  -- line: [0, 0] id: 294
                  if not state.AimbotTracer or not r0_294 then
                    if r109_0 then
                      r109_0.Visible = false
                      r109_0.Transparency = 0
                    end
                    return 
                  end
                  if not r109_0 then
                    r109_0 = Drawing.new("Line")
                    r109_0.Thickness = 2
                    r109_0.Color = state.AimbotTracerColor or Color3.fromRGB(129, 210, 255)
                  end
                  local r1_294, r2_294 = workspace.CurrentCamera:WorldToViewportPoint(r0_294.Position)
                  if r2_294 then
                    local viewport = workspace.CurrentCamera.ViewportSize
                    r109_0.Color = state.AimbotTracerColor or Color3.fromRGB(129, 210, 255)
                    r109_0.From = Vector2.new(viewport.X / 2, viewport.Y / 2)
                    r109_0.To = Vector2.new(r1_294.X, r1_294.Y)
                    r109_0.Transparency = 1
                    r109_0.Visible = true
                  else
                    r109_0.Visible = false
                    r109_0.Transparency = 0
                  end
                end
                if state.AimbotNearestPartToCursor and not state.AimbotRandomizeHitPart then
                  local function r6_293(r0_295)
                    -- line: [0, 0] id: 295
                    if r0_295 then
                      local r1_295 = math.huge
                      for r5_295, r6_295 in pairs(r0_295:GetChildren()) do
                        if r6_295:IsA("MeshPart") then
                          local r7_295, r8_295 = camera:WorldToViewportPoint(r6_295.Position)
                          if r8_295 then
                            local r10_295 = (Vector2.new(r7_295.X, r7_295.Y) - Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)).Magnitude
                            if r10_295 < r1_295 then
                              r1_295 = r10_295
                              r2_293 = r6_295
                            end
                          end
                        end
                      end
                    end
                  end
                  if state.LastTarget:IsA("Player") then
                    r6_293(state.LastTarget.Character)
                  elseif not state.LastTarget.Name == "MI24V" then
                    r6_293(state.LastTarget)
                  end
                end
                if not r2_293 then
                  if state.LastTarget:IsA("Player") then
                    r2_293 = state.LastTarget.Character:FindFirstChild(state.RealAimPart) or state.LastTarget.Character:FindFirstChild("Head")
                  else
                    r2_293 = state.LastTarget:FindFirstChild(state.RealAimPart) or state.LastTarget:FindFirstChild("Head")
                  end
                end
                if not r2_293 then
                  r5_293(nil)
                end
                local selectedAimPoint = r2_293 and r2_293.Position or nil
                local usingSampledAimPoint = false
                local wallBangTargetCharacter = nil
                if state.LastTarget and state.LastTarget.IsA then
                  if state.LastTarget:IsA("Player") then
                    wallBangTargetCharacter = state.LastTarget.Character
                  elseif state.LastTarget:IsA("Model") then
                    wallBangTargetCharacter = state.LastTarget
                  end
                end
                if state._wallBangInfo and state._wallBangInfo.target == state.LastTarget and state._wallBangInfo.character then
                  wallBangTargetCharacter = state._wallBangInfo.character
                end
                if r2_293 and state._bestAimPoint and (not state._bestAimPart or state._bestAimPart == r2_293.Name) then
                  selectedAimPoint = state._bestAimPoint
                  usingSampledAimPoint = true
                end
                if r2_293 and state.WallCheck and not isPartVisible(r2_293, state.LastTarget) then
                  local canBangInvisibleTarget = false
                  if state.WallBang then
                    local wallCount = 0
                    local wallObjects = nil
                    local ignoredDamage = nil
                    canBangInvisibleTarget, wallCount, ignoredDamage, wallObjects = wallBang.check(camera.CFrame.Position, selectedAimPoint or r2_293.Position, wallBangTargetCharacter)
                    if canBangInvisibleTarget and wallCount > 0 and state.WallBangIndicator then
                      wallBang.showIndicator(wallCount, wallBang.getTargetName(state.LastTarget), wallObjects and wallObjects.totalThickness)
                    end
                  end
                  if not canBangInvisibleTarget then
                    state.LastTarget = nil
                    r5_293(nil)
                    releaseAutoShootHold()
                    return
                  end
                end
                if state.MasterAimbot and not state.SilentAimbot then
                  local r6_293 = false
                  if state.LastTarget:IsA("Model") then
                    r6_293 = true
                  end
                  if r2_293 then
                    r5_293(r2_293)
                    r0_293 = camera.CFrame.Position
                    r1_293 = selectedAimPoint or r2_293.Position
                    local r8_293 = r1_293
                    if state.Prediction and state.predictionEnabled and r4_293 and 100 < r4_293 then
                      local weaponName = getCurrentWeaponName()
                      local stats = getWeaponStats(weaponName)
                      local speed = stats.speed or r4_293
                      local drop = stats.drop or 20
                      local targetForPrediction = state.LastTarget
                      if state.LastTarget:IsA("Player") then
                        targetForPrediction = state.LastTarget.Character
                      end
                      local predictedPos = prediction.superPredict(targetForPrediction, r0_293, speed or 500, drop or 20, r1_293)
                      if predictedPos then
                        r8_293 = predictedPos
                      else
                        r8_293 = r1_293
                      end
                    end
                    if r8_293 then
                      if state.WallBang then
                        local canBang, wallCount, damageReduction, wallObjects = wallBang.check(r0_293, r1_293, wallBangTargetCharacter)
                        if canBang and wallCount > 0 then
                          wallBang.showIndicator(wallCount, wallBang.getTargetName(state.LastTarget), wallObjects and wallObjects.totalThickness)
                        elseif not canBang then
                          return
                        else
                          wallBang.hideIndicator()
                        end
                      end
                      camera.CFrame = CFrame.new(r0_293, r8_293)
                    end
                  end
                elseif state.MasterAimbot and state.SilentAimbot and r2_293 then
                  r5_293(r2_293)
                  if state.SilentHitChance < math.random() * 100 then
                    return 
                  end
                  if camera:FindFirstChild("ViewModel") then
                    local viewModel = camera:FindFirstChild("ViewModel")
                    local targetPos = selectedAimPoint or r2_293.Position
                    local cameraPos = camera.CFrame.Position
                    local projectileSpeed = r4_293 and r4_293 > 0 and r4_293 or 500
                    local projectileDrop = weaponStats.drop or 0
                    if state.Prediction and state.predictionEnabled and projectileSpeed and 100 < projectileSpeed then
                      local weaponName = getCurrentWeaponName()
                      local stats = getWeaponStats(weaponName)
                      local speed = stats.speed or projectileSpeed
                      local drop = stats.drop or projectileDrop or 20
                      local targetForPrediction = state.LastTarget
                      if state.LastTarget:IsA("Player") then
                        targetForPrediction = state.LastTarget.Character
                      end
                      local predictedPos = prediction.superPredict(targetForPrediction, cameraPos, speed or 500, drop or 20, r2_293.Position)
                      if predictedPos then
                        targetPos = Vector3.new(predictedPos.X, predictedPos.Y, predictedPos.Z)
                      else
                        targetPos = r2_293.Position
                      end
                    end
                    local aimPos = nil
                    if usingSampledAimPoint then
                      aimPos = targetPos - Vector3.new(0, 0.15, 0)
                    elseif state.PerfectSilent then
                      aimPos = targetPos - Vector3.new(0, 0.15, 0)
                    else
                      aimPos = targetPos - Vector3.new(0, 1.75, 0)
                    end

                    if aimPos then
                      if state.WallBang then
                        local canBang, wallCount, damageReduction, wallObjects = wallBang.check(cameraPos, targetPos, wallBangTargetCharacter)
                        if canBang and wallCount > 0 then
                          wallBang.showIndicator(wallCount, wallBang.getTargetName(state.LastTarget), wallObjects and wallObjects.totalThickness)
                        elseif not canBang then
                          return
                        else
                          wallBang.hideIndicator()
                        end
                      end
                      local aimPart = nil
                      if state.PerfectSilent and viewModel:FindFirstChild("Item") and viewModel.Item:FindFirstChild("AttachmentPoints") then
                        aimPart = viewModel.Item.AttachmentPoints:FindFirstChild("Extra")
                      else
                        local item = viewModel:FindFirstChild("Item")
                        local attachments = item and item:FindFirstChild("Attachments")
                        local front = attachments and attachments:FindFirstChild("Front")
                        aimPart = front and front:FindFirstChild("Barrel")
                        if not aimPart and front then
                          aimPart = front:FindFirstChild("Barrel", true)
                        end
                        if not aimPart then
                          aimPart = viewModel:FindFirstChild("HumanoidRootPart")
                        end
                      end
                      if aimPart then
                        aimPart.CFrame = CFrame.new(aimPart.Position, aimPos)
                      end
                    end
                  end
                end
                -- close: r0_293
              end
            end
            local function doBunnyHop()
              -- line: [0, 0] id: 9
              local r0_9 = localPlayer.Character
              if r0_9 and r0_9:FindFirstChild("Humanoid") and r0_9.Humanoid:GetState() == Enum.HumanoidStateType.Landed and r0_9:FindFirstChild("HumanoidRootPart") then
                r0_9.HumanoidRootPart.Velocity = Vector3.new(0, state.InfJumpPower, 0)
              end
            end
            local function applySpeedHackMovement(r0_36, r1_36)
              -- line: [0, 0] id: 36
              local r2_36 = localPlayer.Character
              if r2_36 and r2_36:FindFirstChild("HumanoidRootPart") then
                local r3_36 = r2_36:FindFirstChild("HumanoidRootPart")
                if r0_36 and not state.FreezeUrSelf and state.SpeedHackToggle and state.SpeedHackActive then
                  local r4_36 = nil
                  if not state.SpeedHackSilent then
                    r4_36 = state.SpeedHackSpeed / 100
                  else
                    r4_36 = state.SpeedHackSpeed / 50
                  end
                  if r1_36 == "W" then
                    r3_36.CFrame = r3_36.CFrame + camera.CFrame.LookVector * r4_36
                  elseif r1_36 == "S" then
                    r3_36.CFrame = r3_36.CFrame - camera.CFrame.LookVector * r4_36
                  elseif r1_36 == "A" then
                    r3_36.CFrame = r3_36.CFrame - camera.CFrame.RightVector * r4_36
                  elseif r1_36 == "D" then
                    r3_36.CFrame = r3_36.CFrame + camera.CFrame.RightVector * r4_36
                  end
                end
              end
            end
            local inputConnections = {}
            local function disconnectInputConnections()
              -- line: [0, 0] id: 304
              for r3_304, r4_304 in pairs(inputConnections) do
                if r4_304 then
                  r4_304:Disconnect()
                end
              end
              inputConnections.Began = UserInputService.InputBegan:Connect(function(r0_305, r1_305)
                -- line: [0, 0] id: 305
                if not r1_305 and state.Loaded then
                  local r2_305 = r0_305.KeyCode
                  if (r2_305 == Enum.KeyCode.W or r2_305 == Enum.KeyCode.A or r2_305 == Enum.KeyCode.S or r2_305 == Enum.KeyCode.D or r2_305 == Enum.KeyCode.Q or r2_305 == Enum.KeyCode.E) and not r84_0[r2_305] then
                    r84_0[r2_305] = true
                    while r84_0[r2_305] do
                      applySpeedHackMovement(true, r2_305.Name)
                      task.wait()
                    end
                  end
                  if r2_305 == Enum.KeyCode.Space and state.InfinityJump and localPlayer.Character then
                    local r3_305 = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if r3_305 then
                      r3_305.Velocity = r3_305.Velocity + Vector3.new(0, state.InfJumpPower, 0)
                    end
                  end
                end
              end)
              inputConnections.Ended = UserInputService.InputEnded:Connect(function(r0_306)
                -- line: [0, 0] id: 306
                local r1_306 = r0_306.KeyCode
                if r84_0[r1_306] then
                  r84_0[r1_306] = false
                end
              end)
            end
            function onPlayerAddedForChams(r0_4)
              -- line: [0, 0] id: 4
              r0_4.CharacterAdded:Connect(function(r0_5)
                -- line: [0, 0] id: 5
                if r0_5.Parent ~= r0_4 then
                  if isEspEffectivelyEnabled() and state.Chams and (state.VisibleChams or state.HiddenChams) then
                    task.wait(1.5)
                    togglePlayerChams(r0_4, true)
                  else
                    togglePlayerChams(r0_4, false)
                  end
                else
                  disconnectInputConnections()
                end
              end)
            end
            Players.PlayerAdded:Connect(onPlayerAddedForChams)
            disconnectInputConnections()
            onPlayerAddedForChams = tick()
            r118_0 = nil
            local menuGuiRoot = nil
            function mainHeartbeatUpdate()
              -- line: [0, 0] id: 273
              -- notice: unreachable block#12
              -- notice: unreachable block#4
              -- notice: unreachable block#242
              state.predictionFrame = state.predictionFrame + 1
              if state.predictionFrame > 100000 then
                state.predictionFrame = 1
                state.predictionCache = {}
              end
              state.wallBangFrame = state.wallBangFrame + 1
              wallBang.cacheFrame = state.wallBangFrame
              if state.wallBangFrame > 100000 then
                state.wallBangFrame = 1
                state.wallBangCache = {}
                wallBang.cache = {}
                wallBang.cacheFrame = 0
              end
              if wallBang.indicator and (not state.WallBangIndicator or not state.LastTarget or not state.WallBang) then
                wallBang.indicator.Visible = false
              end
              if not state.WallBang or not state.WallCheck then
                wallBang.wallBangTargets = {}
                wallBang.lastScanTime = 0
              end
              cacheFrameCounter = cacheFrameCounter + 1
              if cacheFrameCounter > 100000 then
                cacheFrameCounter = 1
                visibilityCache = {}
                state.VisibilityCache = visibilityCache
              end
              --r34_0.Value = r33_0
              if false then --not ReplicatedStorage:FindFirstChild(r37_0) then
                return
                --goto label_22	-- block#3 is visited secondly
              else
                if menuGuiRoot then
                  if r118_0 then
                local titleLabel = r118_0:FindFirstChild("Title")
                local titleText = titleLabel and titleLabel.Text or ""
                if not titleLabel or titleText ~= "GHOST_HOOK | Project Delta |KT.RK" then
                  r118_0 = nil
                    end
                  else
                    r118_0 = menuGuiRoot:FindFirstChild("Main")
                  end
                else
                  menuGuiRoot = CoreGui:FindFirstChild("unknown")
                end
                local menuVisible = isMenuVisible()
                setMenuEspOverride(menuVisible)
                menuVisualOverrideActive = menuVisible
                if not menuVisible then
                  fovMenuBypassActive = false
                  crosshairMenuBypassActive = false
                end
                if tamperFlag then
                  local r0_273 = localPlayer:FindFirstChild("Character")
                  if p.Liable then
                    local r1_273 = "player.character"
                  end
                end
                local r0_273 = localPlayer.Character
                local r1_273 = nil
                local r2_273 = nil
                if r0_273 then
                  r1_273 = r0_273:FindFirstChild("HumanoidRootPart")
                  r2_273 = r0_273:FindFirstChild("Humanoid")
                end
                if state.UPAngleChanger and r0_273 then
                  game:GetService("ReplicatedStorage").Remotes.UpdateTilt:FireServer(state.UPAngleValue or 0)
                end
                if state.ViewModelChanger and 0 < state.ViewModelTransparency then
                  local r3_273 = camera:FindFirstChild("ViewModel")
                  if r3_273 then
                    applyViewModelArmsStyle("Transparency", r3_273)
                  end
                end
                local r4_273 = nil	-- notice: implicit variable refs by block#[67]
                if state.NoFall and r0_273 and r2_273 then
                  local r3_273 = r2_273:GetState()
                  r4_273 = Enum.HumanoidStateType.FallingDown
                  if r3_273 ~= r4_273 then
                    r4_273 = Enum.HumanoidStateType.Freefall
                    if r3_273 == r4_273 then
                      --::label_163--::
                      r4_273 = r1_273.AssemblyLinearVelocity.Y
                      if r4_273 < -12.5 then
                        r2_273:ChangeState(Enum.HumanoidStateType.Landed)
                      end
                    end
                  else
                    --goto label_163	-- block#34 is visited secondly
                  end
                end
                local r6_273 = nil	-- notice: implicit variable refs by block#[244]
                local r7_273 = nil	-- notice: implicit variable refs by block#[180, 191, 209, 210, 211, 236, 237, 240, 244, 254, 257, 258, 263, 267, 268]
                local r8_273 = nil	-- notice: implicit variable refs by block#[211, 212, 217, 219, 220, 221, 222, 223, 237, 244, 277, 278, 283, 284, 285, 286, 287, 288, 290, 291, 292, 293, 294, 295, 296]
                if state.LowFoodDetector then
                  local r3_273 = localPlayer.PlayerGui:FindFirstChild("MainGui")
                  if r3_273 then
                    r4_273 = r3_273.MainFrame.BackpackFrame.CharacterFrame.VitalSigns
                    local r5_273 = tonumber(r4_273.Hunger.Number.Text:match("^(.-)/"))
                    r6_273 = tonumber(r4_273.Hydration.Number.Text:match("^(.-)/"))
                    r7_273 = false
                    r8_273 = state.LowFoodThreshold
                    if r5_273 <= r8_273 then
                      r7_273 = true
                      r8_273 = lowFoodWarningFrame
                      r8_273.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    end
                    r8_273 = state.LowFoodThreshold
                    if r6_273 <= r8_273 then
                      r7_273 = true
                      r8_273 = lowFoodWarningFrame
                      r8_273.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
                    end
                    r8_273 = lowFoodWarningFrame.Visible
                    if r8_273 ~= r7_273 then
                      r8_273 = lowFoodWarningFrame
                      r8_273.Visible = r7_273
                    end
                  end
                elseif lowFoodWarningFrame.Visible then
                  lowFoodWarningFrame.Visible = false
                end
                if state.DynamicFov then
                  state.AimbotFov = state.ActualAimbotFov * r89_0 / camera.FieldOfView
                  r6_273 = camera.FieldOfView
                  r4_273 = state.ActualAimbotFov * r89_0 / r6_273
                  state.FOVCircle.Radius = r4_273
                else
                  r4_273 = state.ActualAimbotFov
                  if state.AimbotFov ~= r4_273 then
                    state.AimbotFov = state.ActualAimbotFov
                    r4_273 = state.AimbotFov
                    state.FOVCircle.Radius = r4_273
                  end
                end
                if state.MasterAimbot and state.AimbotEnabled then
                  selectAimbotTarget()
                  chooseAimPart()
                  if state.LastTarget then
                    local aimPoint, aimPart = getTargetAimPoint(state.LastTarget)
                    if not aimPart or not aimPoint or not isPointInsideAimFov(aimPoint, "Normal") then
                      state.LastTarget = nil
                      if r109_0 then
                        r109_0.Visible = false
                        r109_0.Transparency = 0
                      end
                      ClearAimbotTargetVisuals()
                      releaseAutoShootHold()
                    end
                  end
                  if state.LastTarget ~= prediction.lastTarget then
                    prediction.clearCacheForTarget(prediction.lastTarget)
                    prediction.clearCacheForTarget(state.LastTarget)
                    prediction.lastTarget = state.LastTarget
                  end
                  updateAimbot()
                else
                  prediction.clearCacheForTarget(prediction.lastTarget)
                  prediction.lastTarget = nil
                  state.LastTarget = nil
                end
                if state.LastTarget and state.MasterAimbot and state.AimbotEnabled then
                  UpdateAimbotTargetChams()
                  if aimTargetLabel then
                    aimTargetLabel.Visible = false
                  end
                else
                  ClearAimbotTargetVisuals()
                  if r109_0 then
                    r109_0.Visible = false
                    r109_0.Transparency = 0
                  end
                  if aimTargetLabel then
                    aimTargetLabel.Visible = false
                  end
                end
                if predictionIndicator then
                  if state.Prediction and state.AimbotEnabled and state.LastTarget then
                    local weaponName = getCurrentWeaponName()
                    local stats = getWeaponStats(weaponName)
                    predictionIndicator.Visible = true
                    predictionIndicator.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2 - 30)
                    predictionIndicator.Text = string.format("PRED | %s (%.0fm/s)", weaponName, stats.speed or 0)
                    predictionIndicator.Color = Color3.new(0, 1, 0)
                  else
                    predictionIndicator.Visible = false
                  end
                end
                local r11_273 = nil	-- notice: implicit variable refs by block#[277, 285, 286, 287, 289]
                if state.InvChecker and state.InvCheckerActive then
                  local r3_273 = findInventoryCheckTarget()
                  r4_273 = " | Inventory "
                  if r3_273 then
                    renderInventoryViewer(r3_273)
                    VisibilityToggle(true)
                    if r3_273:FindFirstChild("Head") then
                      r4_273 = " | Corpse "
                    end
                    if state.InvCheckTarget or state.InvCheckValue then
                      if state.InvCheckTarget and state.InvCheckValue then
                        local r5_273 = estimateInventoryValue(r3_273)
                        r6_273 = inventoryViewerTitle
                        r8_273 = r3_273.Name
                        r11_273 = r5_273
                        r7_273 = "Viewing " .. r8_273 .. r4_273 .. "| $" .. r11_273
                        r6_273.Text = r7_273
                      elseif state.InvCheckTarget then
                        r7_273 = r3_273.Name
                        r8_273 = r4_273
                        r6_273 = "Viewing " .. r7_273 .. r8_273
                        inventoryViewerTitle.Text = r6_273
                      elseif state.InvCheckValue then
                        local r5_273 = estimateInventoryValue(r3_273)
                        r6_273 = inventoryViewerTitle
                        r8_273 = r5_273
                        r7_273 = "$" .. r8_273
                        r6_273.Text = r7_273
                      end
                      inventoryViewerTitle.Visible = true
                    else
                      inventoryViewerTitle.Visible = false
                    end
                  else
                    VisibilityToggle(false)
                    inventoryViewerTitle.Visible = false
                  end
                else
                  VisibilityToggle(false)
                  inventoryViewerTitle.Visible = false
                end
                if state.ThirdPerson and state.ThirdPersonActive then
                  r4_273 = Enum.CameraMode.LockFirstPerson
                  if localPlayer.CameraMode == r4_273 then
                    localPlayer.CameraMode = "Classic"
                  end
                  localPlayer.CameraMaxZoomDistance = state.ThirdPersonDistance
                  r4_273 = state.ThirdPersonDistance
                  localPlayer.CameraMinZoomDistance = r4_273
                  localPlayer.DevComputerCameraMode = "CameraToggle"
                else
                  r4_273 = Enum.CameraMode.Classic
                  if localPlayer.CameraMode == r4_273 then
                    localPlayer.CameraMode = "LockFirstPerson"
                  end
                end
                if state.TimeChanger and game.Lighting then
                  r4_273 = state.CurrentTime
                  game.Lighting.TimeOfDay = r4_273
                end
                if crosshairState.Visible and 0 < crosshairState.Transparency then
                  updateCrosshairDrawing()
                end
                updateMenuCrosshair()
                if state.BunnyHopActive then
                  doBunnyHop()
                end
                if state.NoFog and game.Lighting.Atmosphere then
                  game.Lighting.Atmosphere.Haze = 0
                  game.Lighting.Atmosphere.Density = 0
                end
                if state.VisorEnabled then
                  toggleScreenEffect("Visor", true)
                end
                if state.GasMaskSound then
                  toggleScreenEffect("GasMask", true)
                end
                if state.InventoryBlur then
                  toggleScreenEffect("InventoryBlur", true)
                end
                if state.NoReapirBlur then
                  toggleScreenEffect("Reapir", true)
                end
                if state.CloudChanger then
                  local r3_273 = game.Workspace.Terrain:FindFirstChild("Clouds")
                  if r3_273 then
                    r4_273 = state.CloudColor or Color3.fromRGB(50, 15, 95)
                    r3_273.Color = r4_273
                    r4_273 = CloudDensity
                    r3_273.Density = r4_273
                  end
                end
                if state.AmbientChanger or state.setFullBrightness then
                  if state.AmbientChanger and game.Lighting then
                    if state.AmbientChangerRGB then
                      local r3_273 = tick()
                      r4_273 = game.Lighting
                      r4_273.Ambient = Color3.fromHSV(r3_273 % 1 / state.AmbientChangerRGBSpeed / 1 / state.AmbientChangerRGBSpeed, 1, 1)
                    else
                      r4_273 = state.AmbientColor
                      game.Lighting.Ambient = r4_273
                    end
                  end
                  if state.setFullBrightness and not state.AmbientChanger then
                    setFullBrightness(state.setFullBrightness)
                  end
                end
                if r2_273 and state.SpeedHackToggle and state.SpeedHackActive and state.SpeedHackSilent then
                  r2_273.WalkSpeed = 0
                  r2_273.JumpPower = 0
                elseif r2_273 and r2_273.JumpPower == 0 and not state.OmniSprint then
                  r2_273.WalkSpeed = 16
                  r2_273.JumpPower = 1
                elseif r2_273 and state.OmniSprint and r0_273 and localPlayer.PlayerGui:FindFirstChild("MainGui") then
                  r2_273.WalkSpeed = 18.2
                end
                if isFovEffectivelyVisible() and 1 <= state.AimbotFov and state.MasterAimbot then
                  state.FOVCircle.Visible = true
                  r4_273 = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                  state.FOVCircle.Position = r4_273
                else
                  state.FOVCircle.Visible = false
                end
                if not state.AutoShoot or not state.AimbotEnabled then
                  if state.AutoShootHoldActive then
                    state.AutoShootHoldActive = false
                    mouse1release()
                  end
                elseif state.AutoShoot and state.AimbotEnabled then
                  local autoShootTarget = findAutoShootTarget()
                  if autoShootTarget then
                    fireAutoShoot()
                  else
                    releaseAutoShootHold()
                  end
                  if false then
                  local r3_273 = mouse.Target
                  r4_273 = r0_273 and r0_273:FindFirstChild("HumanoidRootPart")
                  if not r3_273 or r3_273 == localPlayer.Character then
                    if state.AutoShootHoldActive and state.AutoShootMode == "Hold" then
                      state.AutoShootHoldActive = false
                      mouse1release()
                    end
                  elseif not state.SilentAimbot and r3_273 and r3_273.Parent then
                    r7_273 = "Model"
                    local r5_273 = r3_273:IsA(r7_273)
                    r6_273 = state.LastTarget
                    r7_273 = false
                    r8_273 = state.TeamCheck
                    if r8_273 and not r5_273 then
                      r8_273 = game.ReplicatedStorage.Players
                      local function r9_273(r0_279)
                        -- line: [0, 0] id: 279
                        return r8_273[r0_279.Name].Status.Journey.Clan:GetAttribute("CurrentClan")
                      end
                      local r10_273 = r9_273(localPlayer)
                      if r10_273 then
                        r11_273 = r9_273(r6_273)
                        if r11_273 and r10_273 and r11_273 ~= "nil" and r10_273 ~= "nil" then
                          r7_273 = r10_273 ~= r11_273
                        end
                      end
                      -- close: r8_273
                    end
					local char = localPlayer.Character
					if char then
						local hrp = char:FindFirstChild("HumanoidRootPart")
						if hrp then
							-- 1. Position Spoof
							if state.RandomPos then
								-- берём максимальное отклонение из настроек слайдеров (по модулю)
								local rangeX = math.abs(state.SpoofPosX) + 0.001
								local rangeY = math.abs(state.SpoofPosY) + 0.001
								local rangeZ = math.abs(state.SpoofPosZ) + 0.001
								local randX = math.random(-rangeX * 10, rangeX * 10) / 10
								local randY = math.random(-rangeY * 10, rangeY * 10) / 10
								local randZ = math.random(-rangeZ * 10, rangeZ * 10) / 10
								hrp.CFrame = hrp.CFrame + Vector3.new(randX, randY, randZ)
							elseif state.SpoofPosX ~= 0 or state.SpoofPosY ~= 0 or state.SpoofPosZ ~= 0 then
								-- постоянное смещение (умножаем на dt, чтобы двигаться плавно, а не рывками)
								local dt = tick() - (r122_0_lastTick or tick())
								r122_0_lastTick = tick()
								hrp.CFrame = hrp.CFrame + Vector3.new(
									state.SpoofPosX * dt * 5,
									state.SpoofPosY * dt * 5,
									state.SpoofPosZ * dt * 5
								)
							end

							-- 2. Rotation Spoof
							if state.SpoofRotation then
								if state.RandomRotation then
									local randRotX = math.random(0, 100)
									local randRotY = math.random(0, 100)
									local randRotZ = math.random(0, 100)
									hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(randRotX), math.rad(randRotY), math.rad(randRotZ))
								else
									hrp.CFrame = hrp.CFrame * CFrame.Angles(
										math.rad(state.RotationX),
										math.rad(state.RotationY),
										math.rad(state.RotationZ)
									)
								end
							end

							-- 3. Velocity Spoof
							if state.SpoofVelocity then
								if state.RandomVelocity then
									local randVelX = math.random(-180, 180)
									local randVelY = math.random(-180, 180)
									local randVelZ = math.random(-180, 180)
									hrp.Velocity = Vector3.new(randVelX, randVelY, randVelZ)
								else
									hrp.Velocity = Vector3.new(state.VelocityX, state.VelocityY, state.VelocityZ)
								end
							end

							-- 4. UpAngle Spoof (через Remote, как в оригинале)
							if state.SpoofUpAngle then
								-- используем существующий Remote из игры
								local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
								if remote and remote:FindFirstChild("UpdateTilt") then
									remote.UpdateTilt:FireServer(state.UpAngle)
								end
							end

							-- 5. Animation Spoof (упрощённо: устанавливаем время для всех текущих анимаций)
							if state.AnimationID ~= "" and state.AnimationTimestamp > 0 then
								local humanoid = char:FindFirstChild("Humanoid")
								if humanoid then
									local animator = humanoid:FindFirstChild("Animator")
									if animator then
										for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
											-- попытка подменить ID анимации (не всегда работает)
											-- track.Animation.AnimationId = state.AnimationID
											track.TimePosition = state.AnimationTimestamp
										end
									end
								end
							end
						end
					end
                    if r7_273 or not r5_273 then
                      if r3_273 then
                        r8_273 = Players
                        r8_273 = r8_273.LocalPlayer
                        if r3_273 ~= r8_273 then
                          --::label_941--::
                          r8_273 = nil
                          if r5_273 then
                            r8_273 = r3_273:FindFirstChild("HumanoidRootPart") or r3_273.Parent:FindFirstChild("HumanoidRootPart")
                          else
                            r8_273 = r3_273.Parent:FindFirstChild("HumanoidRootPart") or r3_273:FindFirstChildOfClass("HumanoidRootPart") or r3_273.Character and r3_273.Character:FindFirstChild("HumanoidRootPart")
                          end
                          if r8_273 and r4_273 and (r4_273.Position - r8_273.Position).Magnitude < 500 then
                            if state.AutoShootMode == "Hold" then
                              if not state.AutoShootHoldActive then
                                state.AutoShootHoldActive = true
                                mouse1press()
                              end
                            else
                              local now = tick()
                              local delaySeconds = state.AutoShootSpeed or 0.05
                              if now - (state.AutoShootLastShot or 0) >= delaySeconds then
                                state.AutoShootLastShot = now
                                mouse1press()
                                task.delay(0.01, function()
                                  if not state.AutoShootHoldActive then
                                    mouse1release()
                                  end
                                end)
                              end
                            end
                          elseif state.AutoShootHoldActive and state.AutoShootMode == "Hold" then
                            state.AutoShootHoldActive = false
                            mouse1release()
                          end
                        end
                      end
                    else
                      --goto label_941	-- block#195 is visited secondly
                    end
                  elseif state.SilentAimbot then
                    -- Check if we have a target, if not, find one immediately
                    local r5_273 = state.LastTarget
                    
                    -- If no target or target is invalid, find one NOW
                    if not r5_273 or not r5_273:FindFirstChild("Head") then
                        -- Quick target scan using ANY visible part
                        local closestTarget = nil
                        local closestDist = math.huge
                        local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                        
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= localPlayer and player.Character then
                                if isAnyPartVisible(player) then
                                    local head = player.Character:FindFirstChild("Head")
                                    if head then
                                        local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                                        if onScreen then
                                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                                            if dist < closestDist and dist <= state.AimbotFov then
                                                closestDist = dist
                                                closestTarget = player
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        if closestTarget then
                            r5_273 = closestTarget
                            state.LastTarget = closestTarget
                        end
                    end
                    
                    -- If still no target, skip
                    if not r5_273 then
                        if state.AutoShootHoldActive and state.AutoShootMode == "Hold" then
                          state.AutoShootHoldActive = false
                          mouse1release()
                        end
                        return
                    end
                    
                    -- Now do the rest of the Silent Aim Auto Shoot code
                    r6_273 = false
                    r7_273 = state
                    r7_273 = r7_273.TeamCheck
                    if r7_273 then
                      r7_273 = r5_273:IsA("Model")
                      if not r7_273 then
                        r7_273 = game
                        r7_273 = r7_273.ReplicatedStorage
                        r7_273 = r7_273.Players
                        function r8_273(r0_276)
                          -- line: [0, 0] id: 276
                          return r7_273[r0_276.Name].Status.Journey.Clan:GetAttribute("CurrentClan")
                        end
                        local r9_273 = r8_273(localPlayer)
                        if r9_273 then
                          local r10_273 = r8_273(r5_273)
                          if r10_273 and r9_273 and r10_273 == r9_273 then
                            r6_273 = true
                          end
                        end
                        -- close: r7_273
                      end
                    end
                    
                    -- Check if target is visible (isAnyPartVisible handles WallCheck internally)
                    local targetVisible = isAnyPartVisible(r5_273)
                    
                    -- Check if target is in FOV
                    local inFov = false
                    local targetCharacter = nil
                    
                    if r5_273:IsA("Player") then
                      targetCharacter = r5_273.Character
                    elseif r5_273:IsA("Model") then
                      targetCharacter = r5_273
                    end
                    
                    if targetCharacter then
                      local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                      local bodyPartsToCheck = {
                        "Head", "UpperTorso", "LowerTorso",
                        "RightUpperArm", "LeftUpperArm", "RightLowerArm", "LeftLowerArm",
                        "RightHand", "LeftHand",
                        "RightUpperLeg", "LeftUpperLeg", "RightLowerLeg", "LeftLowerLeg",
                        "RightFoot", "LeftFoot"
                      }
                      
                      for _, partName in ipairs(bodyPartsToCheck) do
                        local part = targetCharacter:FindFirstChild(partName)
                        if part then
                          local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                          if onScreen then
                            local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                            if distance <= state.AimbotFov then
                              inFov = true
                              break
                            end
                          end
                        end
                      end
                    end
                    
                    if targetVisible and not r6_273 and inFov then
                      if state.AutoShootMode == "Hold" then
                        if not state.AutoShootHoldActive then
                          state.AutoShootHoldActive = true
                          mouse1press()
                        end
                      else
                        local now = tick()
                        local delaySeconds = state.AutoShootSpeed or 0.05
                        if now - (state.AutoShootLastShot or 0) >= delaySeconds then
                          state.AutoShootLastShot = now
                          mouse1press()
                          task.delay(0.01, function()
                            if not state.AutoShootHoldActive then
                              mouse1release()
                            end
                          end)
                        end
                      end
                    elseif state.AutoShootHoldActive and state.AutoShootMode == "Hold" then
                      state.AutoShootHoldActive = false
                      mouse1release()
                    end
                  end
                end
                end
                local r3_273 = state.ShowBoss
                if r3_273 then
                  r3_273 = {}
                  r7_273 = 0
                  r3_273.Green = Color3.new(0, 1, r7_273)
                  r7_273 = 0
                  r3_273.Red = Color3.new(1, 0, r7_273)
                  r4_273 = toggleScreenEffect("Inventory", false)
                  local r5_273 = bossInfoLabels[1]
                  if r4_273 then
                    r6_273 = state.BossMovable
                  else
                    r6_273 = true
                  end
                  r5_273.Visible = r6_273
                  function r5_273(r0_275, r1_275, r2_275, r3_275)
                    -- line: [0, 0] id: 275
                    local r4_275 = game.Workspace.AiZones:FindFirstChild(r0_275)
                    local r5_275 = r4_275 and r4_275:FindFirstChild(r1_275)
                    local r6_275 = bossInfoLabels[r2_275]
                    if r5_275 and r5_275:IsA("Model") then
                      local r7_275 = r5_275:FindFirstChild("Humanoid")
                      if r7_275 then
                        local r8_275 = nil
                        if r3_275 then
                          local r9_275 = r7_275:GetAttribute(r3_275)
                          local r10_275 = r7_275:GetAttribute("Max" .. r3_275)
                          if r9_275 and r10_275 and 0 < r10_275 then
                            r8_275 = math.floor(r9_275 / r10_275 * 100)
                          else
                            r8_275 = 0
                          end
                        else
                          r8_275 = math.floor(r7_275.Health)
                        end
                        r6_275.Text = r1_275 .. ": Alive Health: " .. r8_275
                        r6_275.TextColor3 = r3_273.Green
                        return 
                      end
                    end
                    r6_275.Text = r1_275 .. ": Dead"
                    r6_275.TextColor3 = r3_273.Red
                  end
                  r7_273 = "Sawmill"
                  r8_273 = "Anton"
                  r5_273(r7_273, r8_273, 2)
                  r7_273 = "Factory"
                  r8_273 = "Dozer"
                  r5_273(r7_273, r8_273, 3)
                  r7_273 = "Whisper"
                  r8_273 = "Whisper"
                  r5_273(r7_273, r8_273, 4, "DodgeStamina")
                  -- close: r3_273
                else
                  r3_273 = bossInfoLabels
                  r3_273 = r3_273[1]
                  r3_273 = r3_273.Visible
                  if r3_273 then
                    r3_273 = bossInfoLabels
                    r3_273 = r3_273[1]
                    r3_273.Visible = false
                  end
                end
                r3_273 = tick
                r3_273 = r3_273()
                r4_273 = state.ModDetector
                if r4_273 then
                  r4_273 = r3_273 - state.LastModCheck
                  if r4_273 >= 10 then
                    scanForModerators()
                    r4_273 = state
                    r4_273.LastModCheck = r3_273
                  end
                end
                r4_273 = state.ItemFinder
                if r4_273 then
                  r4_273 = r3_273 - state.LastItemFinderCheck
                  if r4_273 >= 25 then
                    scanWhitelistedItems()
                    r4_273 = state
                    r4_273.LastItemFinderCheck = r3_273
                  end
                end
                r4_273 = state.LastTarget
                if r4_273 then
                  r4_273 = false
                  r7_273 = "Head"
                  if state.LastTarget:FindFirstChild(r7_273) then
                    r4_273 = true
                  end
                  if not r4_273 then
                    r7_273 = "HighlightVisible"
                    if not state.LastTarget:FindFirstChild(r7_273) then
                      r7_273 = "HighlightHidden"
                      if not state.LastTarget:FindFirstChild(r7_273) and isEspEffectivelyEnabled() and state.Chams and (state.VisibleChams or state.HiddenChams) then
                        r7_273 = true
                        togglePlayerChams(state.LastTarget, r7_273)
                      end
                    end
                  end
                  if not r4_273 and state.FreezeTarget then
                    r6_273 = state.LastTarget.Name
                    if not state.Freeze[r6_273] then
                      r6_273 = state.LastTarget.Name
                      r7_273 = state
                      r7_273 = r7_273.LastTarget
                      state.Freeze[r6_273] = r7_273
                    end
                    r7_273 = "HumanoidRootPart"
                    if state.LastTarget.Character:FindFirstChild(r7_273) then
                      state.LastTarget.Character.HumanoidRootPart.Anchored = true
                    end
                  elseif not state.FreezeTarget then
                    r6_273 = state.Freeze
                    for r8_273, r9_273 in pairs(r6_273) do
                      if r9_273.Character:FindFirstChild("HumanoidRootPart") then
                        r9_273.Character.HumanoidRootPart.Anchored = false
                      end
                    end
                    r6_273 = {}
                    state.Freeze = r6_273
                  end
                else
                  r4_273 = pairs
                  for r7_273, r8_273 in r4_273(state.Freeze) do
                    r11_273 = "HumanoidRootPart"
                    if r8_273.Character:FindFirstChild(r11_273) then
                      r8_273.Character.HumanoidRootPart.Anchored = false
                    end
                  end
                  r4_273 = state
                  r4_273.Freeze = {}
                end
                r4_273 = state.Resolver
                if r4_273 then
                  r4_273 = pairs
                  for r7_273, r8_273 in r4_273(Players:GetChildren()) do
                    if localPlayer.Name ~= r8_273.Name and r8_273.Character then
                      r11_273 = "HumanoidRootPart"
                      if r8_273.Character:FindFirstChild(r11_273) then
                        r11_273 = r8_273.Name
                        local r9_273 = ReplicatedStorage.Players:FindFirstChild(r11_273)
                        if r9_273 then
                          local r10_273 = r9_273.Status.UAC:GetAttribute("LastVerifiedPos")
                          r11_273 = r8_273.Character
                          r11_273 = r11_273.HumanoidRootPart
                          r11_273 = r11_273.Position
                          r11_273 = r11_273 - r10_273
                          r11_273 = r11_273.Magnitude
                          if not state.ResolverCache[r8_273.Name] then
                            state.ResolverCache[r8_273.Name] = 1
                          end
                          if r11_273 >= 10 then
                            state.ResolverCache[r8_273.Name] = state.ResolverCache[r8_273.Name] + 1
                            if state.ResolverCache[r8_273.Name] == 250 then
                              notify("Cheat | Detector (Missclick or rathack, maybe ur ping)", "Player: " .. r8_273.Name .. " Has been suspected for Cheating!", 5)
                              playerEsp.Cheaters[r8_273.Name] = true
                              r8_273.Character.HumanoidRootPart.CFrame = CFrame.new(r10_273)
                            elseif state.ResolverCache[r8_273.Name] > 250 then
                              r8_273.Character.HumanoidRootPart.CFrame = CFrame.new(r10_273)
                            end
                          elseif not playerEsp.Cheaters[r8_273.Name] and 0 < state.ResolverCache[r8_273.Name] then
                            state.ResolverCache[r8_273.Name] = state.ResolverCache[r8_273.Name] - 1
                          end
                        end
                      end
                    end
                  end
                end
                return 
              end
            end
            mainHeartbeatConnection = RunService.Heartbeat:Connect(mainHeartbeatUpdate)
            getgenv().Key = nil
            notify("GHOST_HOOK 5/5", "Cheat Has Been Loaded Succesfuly.", 2.5)
			local function UGRESOLVER()
			local char = localPlayer.Character
			if not char then return end

			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then return end

			local originalCF = hrp.CFrame
			hrp.CFrame = originalCF * CFrame.new(0, -30, 0)

			task.delay(0.10, function()
				if hrp and hrp.Parent then
					hrp.CFrame = originalCF
				end
			end)
		end

		-- Flip Mode функции
		local function bendLegs(char, enabled)
			local angle = enabled and math.rad(15) or 0
			for _, name in ipairs({"LeftHip", "LeftKnee", "RightHip", "RightKnee"}) do
				local joint = char:FindFirstChild(name, true)
				if joint and joint:IsA("Motor6D") then
					joint.Transform = CFrame.Angles(angle, 0, 0)
				end
			end
		end

		local function rotateArms(char, enabled)
			local angle = enabled and math.rad(90) or 0
			for _, name in ipairs({"LeftShoulder", "RightShoulder"}) do
				local joint = char:FindFirstChild(name, true)
				if joint and joint:IsA("Motor6D") then
					joint.Transform = CFrame.Angles(-angle, 0, 0)
				end
			end
		end

		enableAntiAim = function(mode)
			local char = localPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChild("Humanoid")
			local head = char and char:FindFirstChild("Head")
			mode = mode or state.AntiAimMode or "Flip"
			
			if not (char and hrp and hum and head) then return end

			state.AntiAimEnabled = true
			state.FlipModeEnabled = true
			state.AntiAimMode = mode
			state.OriginalHipHeight = state.OriginalHipHeight ~= 0 and state.OriginalHipHeight or hum.HipHeight

			if state.FlipModeConnection then
				state.FlipModeConnection:Disconnect()
				state.FlipModeConnection = nil
			end

			bendLegs(char, false)
			rotateArms(char, false)

			if mode == "Flip" then
				hum.HipHeight = -2.5
				hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
				hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
				hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

				bendLegs(char, true)
				rotateArms(char, true)

				state.FlipModeConnection = game:GetService("RunService").Stepped:Connect(function()
					if not state.AntiAimEnabled or not char.Parent then
						if state.FlipModeConnection then
							state.FlipModeConnection:Disconnect()
							state.FlipModeConnection = nil
						end
						return
					end

					local camLook = camera.CFrame.LookVector
					local flatLook = Vector3.new(camLook.X, 0, camLook.Z)
					if flatLook.Magnitude < 0.001 then return end
					flatLook = flatLook.Unit

					local yaw = math.atan2(-flatLook.X, -flatLook.Z)
					hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(math.rad(180), 0, 0)
					head.CanCollide = false

					for _, v in pairs(char:GetChildren()) do
						if v:IsA("Accessory") then
							local h = v:FindFirstChild("Handle")
							if h then
								h.CanCollide = false
								h.Massless = true
							end
						elseif v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
							v.CanCollide = false
							v.Massless = true
						end
					end

					local humanoidState = hum:GetState()
					if humanoidState == Enum.HumanoidStateType.FallingDown or humanoidState == Enum.HumanoidStateType.Freefall then
						hum:ChangeState(Enum.HumanoidStateType.Running)
					end
				end)
			elseif mode == "Yaw" then
				hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(180), 0)
			elseif mode == "Roll" then
				hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(90), 0, 0)
			elseif mode == "Spin" then
				state.FlipModeConnection = game:GetService("RunService").Stepped:Connect(function()
					if not state.AntiAimEnabled or not char.Parent then
						if state.FlipModeConnection then
							state.FlipModeConnection:Disconnect()
							state.FlipModeConnection = nil
						end
						return
					end
					hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(5), 0)
				end)
			end

		end

		disableAntiAim = function()
			state.AntiAimEnabled = false
			state.FlipModeEnabled = false
			
			if state.FlipModeConnection then
				state.FlipModeConnection:Disconnect()
				state.FlipModeConnection = nil
			end

			local char = localPlayer.Character
			if not char then return end
			
			local hum = char:FindFirstChild("Humanoid")
			if hum then
				hum.HipHeight = state.OriginalHipHeight ~= 0 and state.OriginalHipHeight or 2
				hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
				hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
				hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
			end

			bendLegs(char, false)
			rotateArms(char, false)

			for _, v in pairs(char:GetChildren()) do
				if v:IsA("BasePart") then
					v.CanCollide = true
					v.Massless = false
				end
			end

		end

		-- Обработчики ввода
		if state.AnimDownConnection then
			state.AnimDownConnection:Disconnect()
		end
		state.AnimDownConnection = UserInputService.InputBegan:Connect(function(input, gp)
			if gp then return end
			
			-- AnimDown
			if input.KeyCode == Enum.KeyCode.C and state.AnimDown then
				state.AnimDownHolding = true
				spawn(function()
					while state.AnimDownHolding and state.AnimDown do
						UGRESOLVER()
						task.wait(0.12)
					end
				end)
			end
		end)

		if state.AnimDownEndConnection then
			state.AnimDownEndConnection:Disconnect()
		end
		state.AnimDownEndConnection = UserInputService.InputEnded:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.C then
				state.AnimDownHolding = false
			end
		end)
			return 
          end
		  notify("GHOST_HOOK", "Have a good time!", 5)
