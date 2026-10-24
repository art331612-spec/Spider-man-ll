-- [INIT]
local Players              = game:GetService("Players")
local RunService           = game:GetService("RunService")
local UserInputService     = game:GetService("UserInputService")
local TweenService         = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")
local Workspace            = game:GetService("Workspace")

local LP        = Players.LocalPlayer
local Camera    = Workspace.CurrentCamera
local PlayerGui = LP:WaitForChild("PlayerGui")

local function safe(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then warn("[SpiderWeb] " .. tostring(err)) end
    return ok
end

-- [CONFIG]
local CONFIG = {
    RAYCAST_DIST = 500, ANCHOR_FWD = 90, ANCHOR_UP = 80,
    MAX_ROPE = 900, MIN_ROPE = 80, ANCHOR_DRIFT = 10,
    SWING_BOOST = 55, UP_STEER = 110,
    MAX_SPEED = 500, MAX_SPEED_HARD = 700, AIR_DRAG = 0.06,
    MAX_ABOVE_ANCHOR = 900, ABOVE_CAP_DRAG = 0.5,
    GLIDE_TIME = 4.0, GLIDE_DRAG = 0.05,
    RELEASE_BOOST = 45, RELEASE_KEEP_SPEED = 0.92,
    RADIAL_DAMP = 0.25, PUMP_AT_BOTTOM = 140, PUMP_AT_TOP = 55,
    ANCHOR_LIFT = 0.55, AIR_STEER_GLIDE = 22, AIR_STEER_SWING = 25,
    AIR_STEER_MAX_SPD = 380, AIR_KEY_FORCE = 18,
    WEB_ORIGIN_FWD = 0.5, WEB_ORIGIN_UP = 2.2,
    ZIP_DURATION = 0.35, ZIP_SIDE_ANGLE = 40, ZIP_DIST = 160,
    ZIP_UP = 33, ZIP_FORCE = 520, ZIP_LAUNCH_UP = 33,
    ZIP_UP_BOOST = 8, ZIP_KEEP_SPEED = 0.95,
    ZIP_EXIT_BOOST = 20, ZIP_EXIT_UP = 5,
    ZIP_ORIGIN_FWD = 0.5, ZIP_ORIGIN_UP = 0.6,
    HANG_RAYCAST_UP = 200, HANG_MAX_HEIGHT = 40, HANG_MIN_HEIGHT = 4,
    HANG_AIR_RAISE = 25, HANG_DROP_CEILING = 2.5, HANG_MAX_DROP = 20,
    HANG_RAISE_TIME = 1.0, HANG_DESCEND_TIME = 3.0,
    HANG_POS_RESP = 15, HANG_SAFE_ABOVE = 3,
    WEB_PUSH_DELAY_FAST = 0.4, WEB_PUSH_DELAY_SLOW = 0.6,
    WEB_PUSH_RESTART_COOLDOWN = 0.3, WEB_PUSH_DIST = 15,
    WEB_PUSH_FORCE = 110, WEB_PUSH_UP = 60, WEB_PUSH_MAX_Y = 45,
    WEB_PUSH_MAX_SPEED = 220, WEB_PUSH_BEAM_LIFE = 0.15,
    WEB_PUSH_ORIGIN_UP = 1.0, WEB_PUSH_VISUAL_EXTRA = 4.0,
    WEB_PUSH_IK_REACH = 4.5, WEB_PUSH_IK_SIDE = 0.8,
    WEB_PUSH_IK_WEIGHT = 0.85, WEB_PUSH_IK_SMOOTH = 0.09,
    WEB_PUSH_IK_REACH_TIME = 0.12, WEB_PUSH_IK_HOLD_TIME = 0.06,
    WEB_PUSH_IK_RETURN_TIME = 0.20,
    CLIMB_UP_DIST = 4.0, CLIMB_LIP_DIST = 2.0, CLIMB_LIP_UP = 2.5,
    CLIMB_SIDE_DIST = 3.0, CLIMB_MAX_ATTACH = 2.5, CLIMB_RELEASE_DIST = 4.0,
    CLIMB_SPEED = 18, CLIMB_SIDE_MULT = 0.6,
    CLIMB_WALL_STICK = 4, CLIMB_CEILING_STICK = 8,
    CLIMB_ANIM = "rbxassetid://507765644",
    CLIMB_VAULT_UP = 30, CLIMB_VAULT_FWD = 22, CLIMB_VAULT_CHECK_H = 3.0,
    CLIMB_INVERT_ON_DOWN = false,
    CLIMB_EDGE_LOOKAHEAD = 2.5, CLIMB_EDGE_WALL_REACH = 4.5,
    CLIMB_JUMP_UP = 60, CLIMB_JUMP_BACK = 55, CLIMB_JUMP_SUPPRESS = 0.6,
    BRIDGE_DIST = 120, BRIDGE_WIDTH = 3.0, BRIDGE_THICKNESS = 0.4,
    BRIDGE_MIN_HORIZ = 5, BRIDGE_MAX_Y_DIFF = 20, BRIDGE_WALL_DIST = 8,
    BRIDGE_BEAM_WIDE = 2.4, BRIDGE_BEAM_MID = 1.4, BRIDGE_BEAM_INNER = 0.7,
    BRIDGE_MAX_ACTIVE = 5,
    BRIDGE_HOP_RANGE = 10, BRIDGE_HOP_PRIORITY_RANGE = 11,
    BRIDGE_HOP_SUPPRESS = 3.0, BRIDGE_HOP_MAGNET_RESP = 150,
    BRIDGE_HOP_MAGNET_MAXVEL = 90, BRIDGE_HOP_SWITCH_HEIGHT = 0.5,
    BRIDGE_HOP_MIN_TIME = 0.1, BRIDGE_HOP_SAFETY_TIME = 1.0,
    BRIDGE_WALK_SPEED = 24, BRIDGE_WALK_BACK = 0.75,
    BRIDGE_WALK_EDGE_MARGIN = 2.5, BRIDGE_WALK_HEIGHT = 2.0,
    BRIDGE_DISMOUNT_UP = 80, BRIDGE_DISMOUNT_SIDE = 70,
    BRIDGE_DISMOUNT_SUPPRESS = 1.2,
    BRIDGE_WALL_ATTACH_DIST = 3.0, BRIDGE_WALL_ATTACH_OFFSET = 2.6,
    BRIDGE_WALL_ATTACH_DELAY = 0.6,
    FOV_MIN = 50, FOV_MAX = 120, FOV_DEFAULT = 70,
    ANIM_SPEED = 1.6, WALK_ANIM_ID = "rbxassetid://507777826",
    TRAIL_COLOR = Color3.fromRGB(255, 255, 255),
    TRAIL_LIFETIME = 0.35, TRAIL_MIN_LEN = 0.5, TRAIL_THICKNESS = 0.15,
    ACCENT = Color3.fromRGB(0, 200, 255),
    BG = Color3.fromRGB(18, 18, 24),
    BG2 = Color3.fromRGB(28, 28, 38),
    TEXT = Color3.fromRGB(230, 230, 240),
    DIM = Color3.fromRGB(120, 120, 140),
    WEB_COLOR = Color3.fromRGB(245, 245, 255),
}

local ANIM = {
    SWING = "rbxassetid://97674654492880",
    ZIP   = "rbxassetid://100103306715371",
    HANG  = "rbxassetid://125903067740797",
    CLIMB = CONFIG.CLIMB_ANIM,
}
local WEB_TEXTURE = "rbxassetid://15000399146"

-- [STATE]
local State = {
    enabled = false, holding = false,
    active = false, anchorPos = nil, ropeLength = 0,
    glideActive = false, glideUntil = 0, glideStart = 0,
    zipActive = false, zipUntil = 0, zipStart = 0,
    zipA = nil, zipB = nil, zipMid = nil, zipFwd = nil,
    hangActive = false, hangAnchor = nil, hangHasCeiling = false,
    climbEnabled = false, climbActive = false, climbSuppressUntil = 0,
    webPushEnabled = false, webPushActive = false,
    bridgeHopActive = false, onBridge = false,
    bridgeCol = nil, bridgeAttach = nil, bridgeAlignPos = nil,
    bridgeAlignOrient = nil, bridgeLinearVel = nil,
    bridgeLocalX = 0, bridgeLocalZ = 0, bridgeTopOffset = 0,
    bridgeOldWalkSpeed = 16, bridgeOldJumpPower = 50,
    bridgeOldJumpHeight = 7.2, bridgeOldUseJumpPower = true,
    bridgeWalkConn = nil, bridgeStartTime = 0,
}

local TI_FAST = TweenInfo.new(0.18, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out)
local TI_MED  = TweenInfo.new(0.30, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local function tween(o, p, i)
    local t = TweenService:Create(o, i or TI_FAST, p)
    t:Play()
    return t
end

-- [UI]
local gui = Instance.new("ScreenGui")
gui.Name = "SpiderWebUI_" .. tostring(math.random(1e6))
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = PlayerGui

-- [MENU]
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 320, 0, 220)
main.Position = UDim2.new(0.5, 0, 0, 60)
main.AnchorPoint = Vector2.new(0.5, 0)
main.BackgroundColor3 = CONFIG.BG
main.BorderSizePixel = 0
main.Active = false
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = CONFIG.ACCENT
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.55

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 34)
header.BackgroundTransparency = 1
header.Active = false

local title = Instance.new("TextLabel", header)
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 14, 0, 0)
title.Size = UDim2.new(1, -60, 1, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = CONFIG.TEXT
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "SPIDER WEB"

local dot = Instance.new("Frame", header)
dot.AnchorPoint = Vector2.new(1, 0.5)
dot.Position = UDim2.new(1, -46, 0.5, 0)
dot.Size = UDim2.new(0, 7, 0, 7)
dot.BackgroundColor3 = CONFIG.DIM
dot.BorderSizePixel = 0
Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

local closeBtn = Instance.new("TextButton", header)
closeBtn.AnchorPoint = Vector2.new(1, 0.5)
closeBtn.Position = UDim2.new(1, -10, 0.5, 0)
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.BackgroundColor3 = CONFIG.BG2
closeBtn.BorderSizePixel = 0
closeBtn.Text = "−"
closeBtn.TextColor3 = CONFIG.TEXT
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.AutoButtonColor = false
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
local closeStroke = Instance.new("UIStroke", closeBtn)
closeStroke.Color = CONFIG.ACCENT; closeStroke.Transparency = 0.6; closeStroke.Thickness = 1

local body = Instance.new("Frame", main)
body.Position = UDim2.new(0, 0, 0, 34)
body.Size = UDim2.new(1, 0, 1, -34)
body.BackgroundTransparency = 1

local toggle = Instance.new("TextButton", body)
toggle.AnchorPoint = Vector2.new(0.5, 0)
toggle.Position = UDim2.new(0.5, 0, 0, 4)
toggle.Size = UDim2.new(1, -20, 0, 36)
toggle.BackgroundColor3 = CONFIG.BG2
toggle.BorderSizePixel = 0
toggle.Text = "OFF"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 13
toggle.TextColor3 = CONFIG.DIM
toggle.AutoButtonColor = false
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 10)
local toggleStroke = Instance.new("UIStroke", toggle)
toggleStroke.Color = CONFIG.DIM; toggleStroke.Thickness = 1.5; toggleStroke.Transparency = 0.4

local function makeBtn(txt, x, y, w, h)
    local b = Instance.new("TextButton", body)
    b.AnchorPoint = Vector2.new(0.5, 0)
    b.Position = UDim2.new(0.5, x, 0, y)
    b.Size = UDim2.new(0, w, 0, h)
    b.BackgroundColor3 = CONFIG.BG2
    b.BorderSizePixel = 0
    b.Text = txt
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.TextColor3 = CONFIG.TEXT
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", b)
    s.Color = CONFIG.ACCENT; s.Thickness = 1; s.Transparency = 0.5
    return b, s
end

local hangBtn,    hangBtnStroke    = makeBtn("HANG",        -75, 46, 140, 30)
local climbBtn,   climbBtnStroke   = makeBtn("CLIMB: OFF",   75, 46, 140, 30)
local bridgeBtn,  bridgeBtnStroke  = makeBtn("BRIDGE (0/5)", -75, 80, 140, 30)
local webPushBtn, webPushBtnStroke = makeBtn("WEB PUSH: OFF",75, 80, 140, 30)

local fovLabel = Instance.new("TextLabel", body)
fovLabel.BackgroundTransparency = 1
fovLabel.Position = UDim2.new(0, 12, 0, 116)
fovLabel.Size = UDim2.new(1, -24, 0, 14)
fovLabel.Font = Enum.Font.GothamBold
fovLabel.TextSize = 10
fovLabel.TextColor3 = CONFIG.DIM
fovLabel.TextXAlignment = Enum.TextXAlignment.Left
fovLabel.Text = "FOV 70"

local fovTrack = Instance.new("TextButton", body)
fovTrack.AnchorPoint = Vector2.new(0.5, 0)
fovTrack.Position = UDim2.new(0.5, 0, 0, 134)
fovTrack.Size = UDim2.new(1, -24, 0, 10)
fovTrack.BackgroundColor3 = CONFIG.BG2
fovTrack.BorderSizePixel = 0
fovTrack.Text = ""
fovTrack.AutoButtonColor = false
fovTrack.Active = true
Instance.new("UICorner", fovTrack).CornerRadius = UDim.new(1, 0)
local fovFill = Instance.new("Frame", fovTrack)
fovFill.AnchorPoint = Vector2.new(0, 0.5)
fovFill.Position = UDim2.new(0, 0, 0.5, 0)
fovFill.Size = UDim2.new((CONFIG.FOV_DEFAULT-CONFIG.FOV_MIN)/(CONFIG.FOV_MAX-CONFIG.FOV_MIN), 0, 1, 0)
fovFill.BackgroundColor3 = CONFIG.ACCENT
fovFill.BorderSizePixel = 0
Instance.new("UICorner", fovFill).CornerRadius = UDim.new(1, 0)
local fovKnob = Instance.new("Frame", fovTrack)
fovKnob.AnchorPoint = Vector2.new(0.5, 0.5)
fovKnob.Position = UDim2.new((CONFIG.FOV_DEFAULT-CONFIG.FOV_MIN)/(CONFIG.FOV_MAX-CONFIG.FOV_MIN), 0, 0.5, 0)
fovKnob.Size = UDim2.new(0, 14, 0, 14)
fovKnob.BackgroundColor3 = CONFIG.ACCENT
fovKnob.BorderSizePixel = 0
Instance.new("UICorner", fovKnob).CornerRadius = UDim.new(1, 0)
local fovKnobStroke = Instance.new("UIStroke", fovKnob)
fovKnobStroke.Color = CONFIG.BG; fovKnobStroke.Thickness = 2

local hint = Instance.new("TextLabel", body)
hint.BackgroundTransparency = 1
hint.Position = UDim2.new(0, 12, 0, 152)
hint.Size = UDim2.new(1, -24, 0, 60)
hint.Font = Enum.Font.Gotham
hint.TextSize = 9
hint.TextColor3 = CONFIG.DIM
hint.TextWrapped = true
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.Text = "Ground→ZIP. Air→SWING (или PUSH). Wall: JUMP — мост/отлип.\nНа мосту: JUMP — спрыгнуть. HANG — вис вниз головой."

-- [SEQ]
local SEQ_SOLID = NumberSequence.new({
    NumberSequenceKeypoint.new(0.0, 0.05),
    NumberSequenceKeypoint.new(1.0, 0.05),
})
local SEQ_RAGGED = NumberSequence.new({
    NumberSequenceKeypoint.new(0.00, 0.05),
    NumberSequenceKeypoint.new(0.28, 0.05),
    NumberSequenceKeypoint.new(0.30, 0.55),
    NumberSequenceKeypoint.new(0.34, 0.05),
    NumberSequenceKeypoint.new(0.62, 0.05),
    NumberSequenceKeypoint.new(0.64, 0.70),
    NumberSequenceKeypoint.new(0.66, 0.15),
    NumberSequenceKeypoint.new(0.70, 0.05),
    NumberSequenceKeypoint.new(1.00, 0.05),
})
local SEQ_FAINT = NumberSequence.new({
    NumberSequenceKeypoint.new(0.0, 0.55),
    NumberSequenceKeypoint.new(0.5, 0.75),
    NumberSequenceKeypoint.new(1.0, 0.55),
})

-- [HOSTS]
local anchorPart = Instance.new("Part")
anchorPart.Name = "SpiderWebAnchor"
anchorPart.Anchored = true; anchorPart.CanCollide = false
anchorPart.CanQuery = false; anchorPart.CanTouch = false
anchorPart.Transparency = 1
anchorPart.Size = Vector3.new(0.1, 0.1, 0.1)
anchorPart.Parent = Workspace
local attA = Instance.new("Attachment", anchorPart)
local attB = Instance.new("Attachment", anchorPart)

local zipPartA = Instance.new("Part")
zipPartA.Name = "SpiderWebZipA"
zipPartA.Anchored = true; zipPartA.CanCollide = false
zipPartA.CanQuery = false; zipPartA.CanTouch = false
zipPartA.Transparency = 1
zipPartA.Size = Vector3.new(0.1, 0.1, 0.1)
zipPartA.Parent = Workspace
local attZipA1 = Instance.new("Attachment", zipPartA)
local attZipA2 = Instance.new("Attachment", zipPartA)

local zipPartB = Instance.new("Part")
zipPartB.Name = "SpiderWebZipB"
zipPartB.Anchored = true; zipPartB.CanCollide = false
zipPartB.CanQuery = false; zipPartB.CanTouch = false
zipPartB.Transparency = 1
zipPartB.Size = Vector3.new(0.1, 0.1, 0.1)
zipPartB.Parent = Workspace
local attZipB1 = Instance.new("Attachment", zipPartB)
local attZipB2 = Instance.new("Attachment", zipPartB)

local hangPart = Instance.new("Part")
hangPart.Name = "SpiderHangAnchor"
hangPart.Anchored = true; hangPart.CanCollide = false
hangPart.CanQuery = false; hangPart.CanTouch = false
hangPart.Transparency = 1
hangPart.Size = Vector3.new(0.1, 0.1, 0.1)
hangPart.Parent = Workspace
local attHangTop = Instance.new("Attachment", hangPart)
local attHangLower = nil

local ikHost = Instance.new("Part")
ikHost.Name = "SpiderIKHost"
ikHost.Anchored = true; ikHost.CanCollide = false
ikHost.CanQuery = false; ikHost.CanTouch = false
ikHost.Transparency = 1
ikHost.Size = Vector3.new(0.1, 0.1, 0.1)
ikHost.Parent = Workspace
local ikTargetR = Instance.new("Attachment", ikHost)
local ikTargetL = Instance.new("Attachment", ikHost)

local handHolder = Instance.new("Part")
handHolder.Name = "WebHandHolder"
handHolder.Anchored = true; handHolder.CanCollide = false
handHolder.CanQuery = false; handHolder.CanTouch = false
handHolder.Transparency = 1
handHolder.Size = Vector3.new(0.1, 0.1, 0.1)
handHolder.Parent = Workspace
local handAttR = Instance.new("Attachment", handHolder)
local handAttL = Instance.new("Attachment", handHolder)

-- [BEAMS]
local function makeBeam(width, seq, faceCam, a1, a2, parent)
    local b = Instance.new("Beam")
    b.Color = ColorSequence.new(CONFIG.WEB_COLOR)
    b.LightEmission = 1; b.LightInfluence = 0
    b.FaceCamera = (faceCam ~= false)
    b.Width0 = width; b.Width1 = width * 0.78
    b.Transparency = seq
    b.Texture = WEB_TEXTURE; b.TextureMode = Enum.TextureMode.Wrap
    b.TextureLength = 1; b.TextureSpeed = 0.5; b.Segments = 6
    b.Attachment0 = a1; b.Attachment1 = a2
    b.Enabled = false; b.Parent = parent
    return b
end

local beamMain  = makeBeam(0.92, SEQ_RAGGED, true,  attA, attB, anchorPart)
local beamInner = makeBeam(0.55, SEQ_SOLID,  false, attA, attB, anchorPart)
local beamOuter = makeBeam(1.20, SEQ_FAINT,  true,  attA, attB, anchorPart)
local function setMainBeamsEnabled(s)
    beamMain.Enabled = s; beamInner.Enabled = s; beamOuter.Enabled = s
end

local beamZipA_main  = makeBeam(0.92, SEQ_RAGGED, true,  attZipA1, attZipA2, zipPartA)
local beamZipA_inner = makeBeam(0.55, SEQ_SOLID,  false, attZipA1, attZipA2, zipPartA)
local beamZipB_main  = makeBeam(0.92, SEQ_RAGGED, true,  attZipB1, attZipB2, zipPartB)
local beamZipB_inner = makeBeam(0.55, SEQ_SOLID,  false, attZipB1, attZipB2, zipPartB)
local function setZipBeamsEnabled(s)
    beamZipA_main.Enabled = s; beamZipA_inner.Enabled = s
    beamZipB_main.Enabled = s; beamZipB_inner.Enabled = s
end

local hangBeamMain = Instance.new("Beam")
hangBeamMain.Color = ColorSequence.new(CONFIG.WEB_COLOR)
hangBeamMain.LightEmission = 1; hangBeamMain.LightInfluence = 0
hangBeamMain.FaceCamera = true
hangBeamMain.Width0 = 0.92; hangBeamMain.Width1 = 0.72
hangBeamMain.Transparency = SEQ_RAGGED
hangBeamMain.Texture = WEB_TEXTURE; hangBeamMain.TextureMode = Enum.TextureMode.Wrap
hangBeamMain.TextureLength = 1; hangBeamMain.TextureSpeed = 0.5; hangBeamMain.Segments = 6
hangBeamMain.Attachment0 = attHangTop
hangBeamMain.Enabled = false; hangBeamMain.Parent = hangPart

-- [TRAILS]
local trailAttR0 = Instance.new("Attachment")
local trailAttR1 = Instance.new("Attachment")
local trailAttL0 = Instance.new("Attachment")
local trailAttL1 = Instance.new("Attachment")
trailAttR0.Position = Vector3.new(0,  CONFIG.TRAIL_THICKNESS, 0)
trailAttR1.Position = Vector3.new(0, -CONFIG.TRAIL_THICKNESS, 0)
trailAttL0.Position = Vector3.new(0,  CONFIG.TRAIL_THICKNESS, 0)
trailAttL1.Position = Vector3.new(0, -CONFIG.TRAIL_THICKNESS, 0)

local function makeTrail(a0, a1)
    local t = Instance.new("Trail")
    t.Attachment0 = a0; t.Attachment1 = a1
    t.Color = ColorSequence.new(CONFIG.TRAIL_COLOR)
    t.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 0.0),
        NumberSequenceKeypoint.new(1.0, 1.0),
    })
    t.Lifetime = CONFIG.TRAIL_LIFETIME; t.MinLength = CONFIG.TRAIL_MIN_LEN
    t.LightEmission = 1; t.LightInfluence = 0
    t.FaceCamera = true; t.Enabled = false
    t.Parent = handHolder
    return t
end
local trailR = makeTrail(trailAttR0, trailAttR1)
local trailL = makeTrail(trailAttL0, trailAttL1)

-- [HELPERS]
local function getHRP() local c = LP.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function getHumanoid() local c = LP.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local function isOnGround() local h = getHumanoid(); return h and h.FloorMaterial ~= Enum.Material.Air end
local function horizLook()
    local look = Camera.CFrame.LookVector
    local h = Vector3.new(look.X, 0, look.Z)
    if h.Magnitude < 0.01 then return Vector3.new(0, 0, -1) end
    return h.Unit
end
local function getMoveDirWorld()
    local hum = getHumanoid()
    if hum and hum.MoveDirection.Magnitude > 0.05 then
        local md = Vector3.new(hum.MoveDirection.X, 0, hum.MoveDirection.Z)
        if md.Magnitude > 0.01 then return md.Unit end
    end
    local move = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
    if move.Magnitude > 0.01 then return Vector3.new(move.X, 0, move.Z).Unit end
    return Vector3.zero
end
local function getWebOrigin(hrp)
    if not hrp then return Vector3.zero end
    return (hrp.CFrame * CFrame.new(0, CONFIG.WEB_ORIGIN_UP, -CONFIG.WEB_ORIGIN_FWD)).Position
end
local function getZipOrigin(hrp)
    if not hrp then return Vector3.zero end
    return (hrp.CFrame * CFrame.new(0, CONFIG.ZIP_ORIGIN_UP, -CONFIG.ZIP_ORIGIN_FWD)).Position
end
local function getHand(side)
    local c = LP.Character; if not c then return nil end
    if side == "R" then return c:FindFirstChild("RightHand") or c:FindFirstChild("Right Arm")
    else return c:FindFirstChild("LeftHand") or c:FindFirstChild("Left Arm") end
end
local function getArmRoot(side)
    local c = LP.Character; if not c then return nil end
    if side == "R" then
        return c:FindFirstChild("RightUpperArm") or c:FindFirstChild("Right Arm")
            or c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso")
    else
        return c:FindFirstChild("LeftUpperArm") or c:FindFirstChild("Left Arm")
            or c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso")
    end
end
local function getShoulder(side)
    local c = LP.Character; if not c then return nil end
    if side == "R" then return c:FindFirstChild("RightUpperArm") or c:FindFirstChild("Right Arm")
    else return c:FindFirstChild("LeftUpperArm") or c:FindFirstChild("Left Arm") end
end

-- [ANIMATOR]
local animator = nil
local tracks   = {}

local function getAnimator()
    local hum = getHumanoid(); if not hum then return nil end
    local a = hum:FindFirstChildOfClass("Animator")
    if not a then a = Instance.new("Animator"); a.Parent = hum end
    animator = a; return a
end
local function playAnim(key, fade, looped)
    local a = getAnimator()
    if not a or not ANIM[key] then return nil end
    if tracks[key] then pcall(function() tracks[key]:Stop(0) end); tracks[key] = nil end
    local anim = Instance.new("Animation"); anim.AnimationId = ANIM[key]
    local ok, track = pcall(function() return a:LoadAnimation(anim) end)
    if not ok or not track then return nil end
    track.Priority = Enum.AnimationPriority.Action4
    track.Looped = looped ~= false
    tracks[key] = track
    pcall(function() track:Play(fade or 0.15) end)
    pcall(function() track:AdjustSpeed(CONFIG.ANIM_SPEED) end)
    return track
end
local function stopAnim(key, fade)
    local t = tracks[key]
    if t then pcall(function() t:Stop(fade or 0.15) end); tracks[key] = nil end
end
local function stopAllAnims(fade) for k in pairs(tracks) do stopAnim(k, fade) end end

-- [IK]
local ikR = nil; local ikL = nil
local function clearIK()
    if ikR then pcall(function() ikR:Destroy() end); ikR = nil end
    if ikL then pcall(function() ikL:Destroy() end); ikL = nil end
end
local function makeIK(side, target)
    local c = LP.Character; if not c then return nil end
    local hand, root
    if side == "R" then
        hand = c:FindFirstChild("RightHand") or c:FindFirstChild("Right Arm")
        root = c:FindFirstChild("RightUpperArm") or c:FindFirstChild("Right Arm") or c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso")
    else
        hand = c:FindFirstChild("LeftHand") or c:FindFirstChild("Left Arm")
        root = c:FindFirstChild("LeftUpperArm") or c:FindFirstChild("Left Arm") or c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso")
    end
    if not hand or not root then return nil end
    local hum = getHumanoid(); if not hum then return nil end
    local ik = Instance.new("IKControl")
    ik.Type = Enum.IKControlType.Position
    ik.EndEffector = hand; ik.ChainRoot = root
    ik.Target = target; ik.Weight = 1; ik.SmoothTime = 0.08
    ik.Parent = hum
    return ik
end
local function setIKArms(targetR, targetL)
    clearIK()
    if targetR then ikR = makeIK("R", targetR) end
    if targetL then ikL = makeIK("L", targetL) end
end

-- [HAND ATTACHMENTS]
local function refreshHandAttachments()
    local char = LP.Character
    if not char then handAttR.Parent = handHolder; handAttL.Parent = handHolder; return end
    local rHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
    local lHand = char:FindFirstChild("LeftHand")  or char:FindFirstChild("Left Arm")
    handAttR.Parent = rHand or handHolder
    handAttL.Parent = lHand or handHolder
end
local function detachHandAttachments()
    handAttR.Parent = handHolder; handAttL.Parent = handHolder
end

-- [TRAILS attach]
local function attachTrails()
    local r = getShoulder("R"); local l = getShoulder("L")
    if r and trailAttR0.Parent ~= r then trailAttR0.Parent = r; trailAttR1.Parent = r end
    if l and trailAttL0.Parent ~= l then trailAttL0.Parent = l; trailAttL1.Parent = l end
    trailR.Enabled = true; trailL.Enabled = true
end
local function detachTrails()
    trailR.Enabled = false; trailL.Enabled = false
    trailAttR0.Parent = nil; trailAttR1.Parent = nil
    trailAttL0.Parent = nil; trailAttL1.Parent = nil
end

-- [BODY ALIGN]
local alignObj = nil; local alignAttach = nil
local function stopBodyAlign()
    if alignObj then pcall(function() alignObj:Destroy() end); alignObj = nil end
    if alignAttach then pcall(function() alignAttach:Destroy() end); alignAttach = nil end
    local hum = getHumanoid()
    if hum then
        hum.AutoRotate = true
        if hum.FloorMaterial ~= Enum.Material.Air then
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
        end
    end
end
local function startBodyAlign()
    stopBodyAlign()
    local hrp = getHRP(); if not hrp then return end
    alignAttach = Instance.new("Attachment", hrp)
    alignObj = Instance.new("AlignOrientation")
    alignObj.Mode = Enum.OrientationAlignmentMode.OneAttachment
    alignObj.Attachment0 = alignAttach
    alignObj.MaxTorque = math.huge; alignObj.MaxAngularVelocity = math.huge
    alignObj.Responsiveness = 30; alignObj.RigidityEnabled = false
    alignObj.Parent = hrp
    local hum = getHumanoid(); if hum then hum.AutoRotate = false end
end
local function updateBodyAlign(lookDir, upDir)
    if not alignObj or not alignObj.Parent then return end
    if lookDir.Magnitude < 0.01 then return end
    pcall(function()
        alignObj.CFrame = CFrame.lookAt(Vector3.zero, lookDir.Unit, upDir or Vector3.new(0, 1, 0))
    end)
end

-- [BRIDGE REGISTRY]
local activeBridges = {}
local function updateBridgeBtn()
    bridgeBtn.Text = "BRIDGE (" .. #activeBridges .. "/" .. CONFIG.BRIDGE_MAX_ACTIVE .. ")"
end

-- [FILTERS]
local function filterBase()
    return { LP.Character, anchorPart, zipPartA, zipPartB, ikHost, hangPart, handHolder }
end
local function climbFilter()
    local list = filterBase()
    for _, b in ipairs(activeBridges) do
        if b.col then table.insert(list, b.col) end
        if b.hostA then table.insert(list, b.hostA) end
    end
    return list
end

-- [CLIMB]
local climbVel = nil; local climbAlign = nil; local climbAttach = nil
local climbLastDir = Vector3.new(0, 1, 0)
local climbCurrentNormal = Vector3.new(0, 0, 1)
local climbCurrentKind = "wall"

local function clearClimb()
    if climbVel then pcall(function() climbVel:Destroy() end); climbVel = nil end
    if climbAlign then pcall(function() climbAlign:Destroy() end); climbAlign = nil end
    if climbAttach then pcall(function() climbAttach:Destroy() end); climbAttach = nil end
end
local function buildClimbCFrame(normal, headDir)
    local look = -normal
    if look.Magnitude < 0.01 then look = Vector3.new(0, 0, -1) end
    look = look.Unit
    local up = headDir - look * headDir:Dot(look)
    if up.Magnitude < 0.05 then
        up = Vector3.new(0, 1, 0) - look * look.Y
        if up.Magnitude < 0.05 then up = Vector3.new(0, 0, 1) - look * look.Z end
    end
    up = up.Unit
    return CFrame.lookAt(Vector3.zero, look, up)
end
local function getClimbSurface()
    local hrp = getHRP(); if not hrp then return nil, nil end
    local p = RaycastParams.new()
    p.FilterType = Enum.RaycastFilterType.Exclude
    p.FilterDescendantsInstances = climbFilter()
    p.IgnoreWater = true
    local up = Workspace:Raycast(hrp.Position, Vector3.new(0, CONFIG.CLIMB_UP_DIST, 0), p)
    if up and up.Normal.Y < -0.45 then return up, "ceiling" end
    local look = horizLook()
    if look.Magnitude > 0.01 then
        local lip = Workspace:Raycast(hrp.Position + Vector3.new(0, 1.4, 0),
            look * CONFIG.CLIMB_LIP_DIST + Vector3.new(0, CONFIG.CLIMB_LIP_UP, 0), p)
        if lip and lip.Normal.Y < -0.4 then return lip, "ceiling" end
    end
    local dirs = { look, -look, Camera.CFrame.RightVector, -Camera.CFrame.RightVector }
    local closest, closestDist = nil, math.huge
    for _, d in ipairs(dirs) do
        local flat = Vector3.new(d.X, 0, d.Z)
        if flat.Magnitude > 0.01 then
            local r = Workspace:Raycast(hrp.Position, flat.Unit * CONFIG.CLIMB_SIDE_DIST, p)
            if r and math.abs(r.Normal.Y) < 0.55 then
                local dist = (r.Position - hrp.Position).Magnitude
                if dist < closestDist then closestDist = dist; closest = r end
            end
        end
    end
    if closest then return closest, "wall" end
    return nil, nil
end
local function stopClimb()
    if not State.climbActive then return end
    State.climbActive = false
    stopAnim("CLIMB", 0.15); clearClimb()
    local hum = getHumanoid(); local hrp = getHRP()
    if hum then
        hum.AutoRotate = true; hum.PlatformStand = false
        if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Freefall) end)
    end
    tween(climbBtn, {BackgroundColor3 = CONFIG.BG2, TextColor3 = CONFIG.TEXT}, TI_FAST)
    tween(climbBtnStroke, {Color = CONFIG.ACCENT, Transparency = 0.5}, TI_FAST)
end
local function tryStartClimb()
    if not State.climbEnabled or State.climbActive or State.bridgeHopActive or State.onBridge then return false end
    if State.active or State.zipActive or State.glideActive or State.hangActive then return false end
    if tick() < State.climbSuppressUntil then return false end
    local surface, kind = getClimbSurface()
    if not surface then return false end
    local hrp, hum = getHRP(), getHumanoid()
    if not hrp or not hum then return false end
    if (surface.Position - hrp.Position).Magnitude > CONFIG.CLIMB_MAX_ATTACH then return false end
    State.climbActive = true
    hum.AutoRotate = false; hum.PlatformStand = false
    playAnim("CLIMB", 0.1, true)
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Climbing) end)
    climbAttach = Instance.new("Attachment", hrp)
    climbVel = Instance.new("LinearVelocity")
    climbVel.MaxForce = math.huge
    climbVel.RelativeTo = Enum.ActuatorRelativeTo.World
    climbVel.VectorVelocity = Vector3.zero
    climbVel.Attachment0 = climbAttach
    climbVel.Parent = hrp
    climbAlign = Instance.new("AlignOrientation")
    climbAlign.Mode = Enum.OrientationAlignmentMode.OneAttachment
    climbAlign.MaxTorque = math.huge; climbAlign.Responsiveness = 25
    climbAlign.RigidityEnabled = false
    climbAlign.Attachment0 = climbAttach; climbAlign.Parent = hrp
    climbLastDir = Vector3.new(0, 1, 0)
    climbCurrentNormal = surface.Normal; climbCurrentKind = kind
    climbAlign.CFrame = buildClimbCFrame(surface.Normal, climbLastDir)
    tween(climbBtn, {BackgroundColor3 = Color3.fromRGB(80, 30, 30), TextColor3 = CONFIG.ACCENT}, TI_FAST)
    tween(climbBtnStroke, {Color = CONFIG.ACCENT, Transparency = 0.1}, TI_FAST)
    return true
end
local function findWallBeyondCeilingEdge(hrp, ceilingNormal, movePlanar)
    local p = RaycastParams.new()
    p.FilterType = Enum.RaycastFilterType.Exclude
    p.FilterDescendantsInstances = climbFilter(); p.IgnoreWater = true
    local probeAhead = hrp.Position + movePlanar * CONFIG.CLIMB_EDGE_LOOKAHEAD
    local ceilAhead = Workspace:Raycast(probeAhead, -ceilingNormal * 2, p)
    if ceilAhead then return nil end
    local searches = {
        {origin = probeAhead + Vector3.new(0,0.2,0), dir = movePlanar * CONFIG.CLIMB_EDGE_WALL_REACH},
        {origin = probeAhead - ceilingNormal*1.5,    dir = movePlanar * CONFIG.CLIMB_EDGE_WALL_REACH},
        {origin = hrp.Position + movePlanar*CONFIG.CLIMB_EDGE_LOOKAHEAD + ceilingNormal*0.5, dir = -ceilingNormal*CONFIG.CLIMB_EDGE_WALL_REACH},
    }
    for _, s in ipairs(searches) do
        local hit = Workspace:Raycast(s.origin, s.dir, p)
        if hit and math.abs(hit.Normal.Y) < 0.6 then return hit.Normal end
    end
    return nil
end
local function updateClimb(dt)
    if not State.climbActive then return end
    local hrp, hum = getHRP(), getHumanoid()
    if not hrp or not hum or not climbVel or not climbAlign then stopClimb(); return end
    local move = hum.MoveDirection
    local camFwdH = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
    if camFwdH.Magnitude < 0.01 then camFwdH = Vector3.new(0, 0, -1) end
    camFwdH = camFwdH.Unit
    local camRightH = Vector3.new(Camera.CFrame.RightVector.X, 0, Camera.CFrame.RightVector.Z)
    if camRightH.Magnitude < 0.01 then camRightH = Vector3.new(1, 0, 0) end
    camRightH = camRightH.Unit
    local fwdInput = move:Dot(camFwdH); local sideInput = move:Dot(camRightH)
    local isMoving = math.abs(fwdInput) > 0.08 or math.abs(sideInput) > 0.08
    local surface, kind = getClimbSurface()
    if surface then
        if (surface.Position - hrp.Position).Magnitude > CONFIG.CLIMB_RELEASE_DIST then stopClimb(); return end
        climbCurrentNormal = surface.Normal; climbCurrentKind = kind
    end
    local normal = climbCurrentNormal; local currentKind = climbCurrentKind
    if currentKind == "ceiling" and isMoving and surface then
        local movePlanar = move - normal * move:Dot(normal)
        if movePlanar.Magnitude > 0.05 then
            movePlanar = movePlanar.Unit
            local wallNormal = findWallBeyondCeilingEdge(hrp, normal, movePlanar)
            if wallNormal then
                normal = wallNormal; currentKind = "wall"
                climbCurrentNormal = normal; climbCurrentKind = currentKind
                climbVel.VectorVelocity = -normal * CONFIG.CLIMB_WALL_STICK
                local wallUp = Vector3.new(0, 1, 0) - normal * normal.Y
                if wallUp.Magnitude < 0.1 then wallUp = movePlanar - normal * movePlanar:Dot(normal) end
                if wallUp.Magnitude < 0.05 then wallUp = Vector3.new(0, 1, 0) end
                climbLastDir = wallUp.Unit
                climbAlign.CFrame = buildClimbCFrame(normal, climbLastDir)
                return
            end
        end
    end
    if currentKind == "ceiling" then
        hum.PlatformStand = true
        local ceilFwd = camFwdH - normal * camFwdH:Dot(normal)
        if ceilFwd.Magnitude < 0.05 then ceilFwd = Vector3.new(0, 0, -1) - normal * normal.Z end
        ceilFwd = ceilFwd.Unit
        local ceilRight = camRightH - normal * camRightH:Dot(normal)
        if ceilRight.Magnitude < 0.05 then ceilRight = ceilFwd:Cross(normal) end
        ceilRight = ceilRight.Unit
        local moveVel = Vector3.zero
        if isMoving then
            moveVel = ceilFwd * fwdInput * CONFIG.CLIMB_SPEED + ceilRight * sideInput * CONFIG.CLIMB_SPEED * CONFIG.CLIMB_SIDE_MULT
        end
        climbVel.VectorVelocity = moveVel - normal * CONFIG.CLIMB_CEILING_STICK
        local headDir = ceilFwd
        if isMoving then
            local combined = Vector3.zero
            if math.abs(fwdInput) > 0.08 then combined = combined + ceilFwd * (fwdInput > 0 and 1 or -1) end
            if math.abs(sideInput) > 0.08 then combined = combined + ceilRight * (sideInput > 0 and 1 or -1) end
            if combined.Magnitude > 0.01 then headDir = combined.Unit end
        end
        climbLastDir = headDir
        climbAlign.CFrame = buildClimbCFrame(normal, headDir)
    else
        hum.PlatformStand = false
        local wallUp = Vector3.new(0, 1, 0) - normal * normal.Y
        if wallUp.Magnitude < 0.1 then wallUp = Vector3.new(0, 0, 1) - normal * normal.Z end
        wallUp = wallUp.Unit
        local wallRight = camRightH - normal * camRightH:Dot(normal)
        if wallRight.Magnitude < 0.1 then wallRight = wallUp:Cross(normal) end
        wallRight = wallRight.Unit
        local vel = Vector3.zero
        if isMoving then
            vel = wallUp * fwdInput * CONFIG.CLIMB_SPEED + wallRight * sideInput * CONFIG.CLIMB_SPEED * CONFIG.CLIMB_SIDE_MULT
        end
        vel = vel - normal * CONFIG.CLIMB_WALL_STICK
        climbVel.VectorVelocity = vel
        if isMoving then
            local combined = Vector3.zero
            if math.abs(fwdInput) > 0.08 then
                local sign = CONFIG.CLIMB_INVERT_ON_DOWN and (fwdInput > 0 and 1 or -1) or 1
                combined = combined + wallUp * sign
            end
            if math.abs(sideInput) > 0.08 then combined = combined + wallRight * (sideInput > 0 and 1 or -1) end
            if combined.Magnitude > 0.01 then climbLastDir = combined.Unit end
        end
        climbAlign.CFrame = buildClimbCFrame(normal, climbLastDir)
        local t = tracks["CLIMB"]
        if t then pcall(function() t:AdjustSpeed(isMoving and CONFIG.ANIM_SPEED or 0) end) end
        if fwdInput > 0.3 then
            local cp = RaycastParams.new()
            cp.FilterType = Enum.RaycastFilterType.Exclude
            cp.FilterDescendantsInstances = climbFilter(); cp.IgnoreWater = true
            local headPos = hrp.Position + Vector3.new(0, CONFIG.CLIMB_VAULT_CHECK_H, 0)
            local wallAbove = Workspace:Raycast(headPos, -normal * 3, cp)
            if not wallAbove then
                local vaultDir = -normal
                stopClimb()
                task.defer(function()
                    if hrp and hrp.Parent then
                        hrp.AssemblyLinearVelocity = vaultDir * CONFIG.CLIMB_VAULT_FWD + Vector3.new(0, CONFIG.CLIMB_VAULT_UP, 0)
                    end
                end)
                return
            end
        end
    end
    if hum:GetState() ~= Enum.HumanoidStateType.Climbing then
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Climbing) end)
    end
end
local function jumpOffClimb()
    if not State.climbActive then return false end
    local hrp, hum = getHRP(), getHumanoid()
    if not hrp or not hum then stopClimb(); return false end
    local wallNormal = climbCurrentNormal
    if wallNormal.Magnitude < 0.01 then wallNormal = -horizLook() end
    local backDir = wallNormal.Unit
    stopClimb()
    State.climbSuppressUntil = tick() + CONFIG.CLIMB_JUMP_SUPPRESS
    local jumpVel = backDir * CONFIG.CLIMB_JUMP_BACK + Vector3.new(0, CONFIG.CLIMB_JUMP_UP, 0)
    task.defer(function()
        local h2 = getHumanoid(); local hrp2 = getHRP()
        if h2 and h2.Parent and hrp2 and hrp2.Parent then
            pcall(function() h2:ChangeState(Enum.HumanoidStateType.Freefall) end)
            task.wait()
            if hrp2.Parent then hrp2.AssemblyLinearVelocity = jumpVel end
        end
    end)
    return true
end

-- [BRIDGE create/cleanup]
local function cleanupBridges()
    for i = #activeBridges, 1, -1 do
        local b = activeBridges[i]
        if b.hostA and b.hostA.Parent then pcall(function() b.hostA:Destroy() end) end
        if b.col and b.col.Parent then pcall(function() b.col:Destroy() end) end
        activeBridges[i] = nil
    end
    updateBridgeBtn()
end
local function cleanupOldestBridge()
    if #activeBridges <= CONFIG.BRIDGE_MAX_ACTIVE - 1 then return end
    local b = table.remove(activeBridges, 1)
    if not b then return end
    if b.hostA and b.hostA.Parent then pcall(function() b.hostA:Destroy() end) end
    if b.col and b.col.Parent then pcall(function() b.col:Destroy() end) end
end
local function makeBridgeBeam(attA1, attB1, width, seq, faceCam, parent)
    local b = Instance.new("Beam")
    b.Color = ColorSequence.new(CONFIG.WEB_COLOR)
    b.LightEmission = 1; b.LightInfluence = 0
    b.FaceCamera = faceCam
    b.Width0 = width; b.Width1 = width
    b.Transparency = seq
    b.Texture = WEB_TEXTURE; b.TextureMode = Enum.TextureMode.Wrap
    b.TextureLength = 1; b.TextureSpeed = 0.5; b.Segments = 8
    b.Attachment0 = attA1; b.Attachment1 = attB1
    b.Parent = parent
    return b
end
local function createWebBridge()
    if not State.enabled then return end
    local hrp = getHRP(); if not hrp then return end
    for i = #activeBridges, 1, -1 do
        local b = activeBridges[i]
        if not b.hostA or not b.hostA.Parent then table.remove(activeBridges, i) end
    end
    local p = RaycastParams.new()
    p.FilterType = Enum.RaycastFilterType.Exclude
    local exclude = filterBase()
    for _, b in ipairs(activeBridges) do
        if b.hostA then table.insert(exclude, b.hostA) end
        if b.col then table.insert(exclude, b.col) end
    end
    p.FilterDescendantsInstances = exclude; p.IgnoreWater = true
    local dirToWall = State.climbActive and -climbCurrentNormal or -horizLook()
    local wallHit = Workspace:Raycast(hrp.Position, dirToWall * CONFIG.BRIDGE_WALL_DIST, p)
    local p1 = wallHit and wallHit.Position or hrp.Position
    local camPos = Camera.CFrame.Position; local camLook = Camera.CFrame.LookVector
    local camHit = Workspace:Raycast(camPos, camLook * CONFIG.BRIDGE_DIST, p)
    local p2 = camHit and camHit.Position or (camPos + camLook * CONFIG.BRIDGE_DIST)
    local delta = p2 - p1; local dist = delta.Magnitude
    if dist < CONFIG.BRIDGE_MIN_HORIZ or dist > CONFIG.BRIDGE_DIST then return end
    if math.abs(delta.Y) > CONFIG.BRIDGE_MAX_Y_DIFF then
        p2 = Vector3.new(p2.X, p1.Y, p2.Z); delta = p2 - p1; dist = delta.Magnitude
        if dist < CONFIG.BRIDGE_MIN_HORIZ then return end
    end
    local mid = (p1 + p2) * 0.5
    local look = delta.Unit
    local right = look:Cross(Vector3.yAxis)
    if right.Magnitude < 0.01 then right = Vector3.xAxis end
    right = right.Unit
    local up = right:Cross(look).Unit
    local cframe = CFrame.fromMatrix(mid, right, up)
    local col = Instance.new("Part")
    col.Name = "SpiderWebBridge_Col"; col.Anchored = true
    col.CanCollide = false; col.CanQuery = false; col.CanTouch = false
    col.Transparency = 1; col.Material = Enum.Material.SmoothPlastic
    col.Size = Vector3.new(CONFIG.BRIDGE_WIDTH, CONFIG.BRIDGE_THICKNESS, dist)
    col.CFrame = cframe
    col.TopSurface = Enum.SurfaceType.Smooth; col.BottomSurface = Enum.SurfaceType.Smooth
    col.Parent = Workspace
    local hostA = Instance.new("Part")
    hostA.Name = "SpiderWebBridge_Beam"; hostA.Anchored = true
    hostA.CanCollide = false; hostA.CanQuery = false; hostA.CanTouch = false
    hostA.Transparency = 1; hostA.Size = Vector3.new(0.1, 0.1, 0.1)
    hostA.CFrame = CFrame.new(mid); hostA.Parent = Workspace
    local attA1 = Instance.new("Attachment", hostA); attA1.WorldPosition = p1
    local attA2 = Instance.new("Attachment", hostA); attA2.WorldPosition = p2
    makeBridgeBeam(attA1, attA2, CONFIG.BRIDGE_BEAM_WIDE,  SEQ_FAINT,  true,  hostA)
    makeBridgeBeam(attA1, attA2, CONFIG.BRIDGE_BEAM_MID,   SEQ_RAGGED, true,  hostA)
    makeBridgeBeam(attA1, attA2, CONFIG.BRIDGE_BEAM_INNER, SEQ_SOLID,  false, hostA)
    cleanupOldestBridge()
    local entry = {hostA = hostA, col = col}
    table.insert(activeBridges, entry)
    updateBridgeBtn()
    tween(bridgeBtn, {BackgroundColor3 = Color3.fromRGB(80, 30, 30), TextColor3 = CONFIG.ACCENT}, TI_FAST)
    tween(bridgeBtnStroke, {Color = CONFIG.ACCENT, Transparency = 0.1}, TI_FAST)
    task.delay(0.5, function()
        tween(bridgeBtn, {BackgroundColor3 = CONFIG.BG2, TextColor3 = CONFIG.TEXT}, TI_FAST)
        tween(bridgeBtnStroke, {Color = CONFIG.ACCENT, Transparency = 0.5}, TI_FAST)
    end)
end

-- [BRIDGE WALK]
local bridgeWalkTrack = nil
local function stopBridgeWalk()
    if State.bridgeWalkConn then State.bridgeWalkConn:Disconnect(); State.bridgeWalkConn = nil end
    if State.bridgeAlignPos then pcall(function() State.bridgeAlignPos:Destroy() end); State.bridgeAlignPos = nil end
    if State.bridgeAlignOrient then pcall(function() State.bridgeAlignOrient:Destroy() end); State.bridgeAlignOrient = nil end
    if State.bridgeLinearVel then pcall(function() State.bridgeLinearVel:Destroy() end); State.bridgeLinearVel = nil end
    if State.bridgeAttach then pcall(function() State.bridgeAttach:Destroy() end); State.bridgeAttach = nil end
    if bridgeWalkTrack then pcall(function() bridgeWalkTrack:Stop(0.2) end); bridgeWalkTrack = nil end
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = State.bridgeOldWalkSpeed or 16
        hum.JumpPower = State.bridgeOldJumpPower or 50
        hum.JumpHeight = State.bridgeOldJumpHeight or 7.2
        hum.UseJumpPower = State.bridgeOldUseJumpPower ~= nil and State.bridgeOldUseJumpPower or true
        hum.PlatformStand = false; hum.AutoRotate = true
        pcall(function() hum:Move(Vector3.zero, false) end)
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
    end
    State.onBridge = false; State.bridgeCol = nil
end
local function dismountBridge()
    if not State.onBridge then return false end
    local hrp, hum = getHRP(), getHumanoid()
    if not hrp or not hum then stopBridgeWalk(); return false end
    local camRight = Camera.CFrame.RightVector
    camRight = Vector3.new(camRight.X, 0, camRight.Z)
    if camRight.Magnitude < 0.01 then camRight = Vector3.new(1, 0, 0) end
    camRight = camRight.Unit
    local sideSign = (math.random(0, 1) == 0) and 1 or -1
    local jumpVel = camRight * (CONFIG.BRIDGE_DISMOUNT_SIDE * sideSign) + Vector3.new(0, CONFIG.BRIDGE_DISMOUNT_UP, 0)
    stopBridgeWalk()
    State.climbSuppressUntil = tick() + CONFIG.BRIDGE_DISMOUNT_SUPPRESS
    task.defer(function()
        local h2 = getHumanoid(); local hrp2 = getHRP()
        if h2 and h2.Parent and hrp2 and hrp2.Parent then
            pcall(function() h2:ChangeState(Enum.HumanoidStateType.Freefall) end)
            task.wait()
            if hrp2.Parent then hrp2.AssemblyLinearVelocity = jumpVel end
        end
    end)
    return true
end
local function tryAttachWallFromBridge()
    if not State.onBridge or not State.climbEnabled then return false end
    if tick() - State.bridgeStartTime < CONFIG.BRIDGE_WALL_ATTACH_DELAY then return false end
    local hrp, hum = getHRP(), getHumanoid()
    if not hrp or not hum then return false end
    local look = horizLook(); if look.Magnitude < 0.01 then return false end
    local p = RaycastParams.new()
    p.FilterType = Enum.RaycastFilterType.Exclude
    p.FilterDescendantsInstances = climbFilter(); p.IgnoreWater = true
    local result = Workspace:Raycast(hrp.Position, look * CONFIG.BRIDGE_WALL_ATTACH_DIST, p)
    if not result then return false end
    if math.abs(result.Normal.Y) > 0.55 then return false end
    local wallNormal = result.Normal; local wallPos = result.Position
    stopBridgeWalk()
    local targetPos = wallPos + wallNormal * CONFIG.BRIDGE_WALL_ATTACH_OFFSET
    hrp.CFrame = CFrame.lookAt(
        Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z),
        Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z) - wallNormal,
        Vector3.new(0, 1, 0))
    hrp.AssemblyLinearVelocity = Vector3.zero
    State.climbSuppressUntil = 0
    task.defer(function()
        local h2 = getHumanoid()
        if h2 then h2.PlatformStand = false; pcall(function() h2:ChangeState(Enum.HumanoidStateType.Climbing) end) end
        safe(tryStartClimb)
    end)
    return true
end
local function findBestBridge(maxDist)
    local hrp = getHRP(); if not hrp then return nil end
    local fromPos = hrp.Position
    local bestCol, bestScore = nil, math.huge
    local visP = RaycastParams.new()
    visP.FilterType = Enum.RaycastFilterType.Exclude
    local excludeVis = filterBase()
    for _, b in ipairs(activeBridges) do
        if b.hostA then table.insert(excludeVis, b.hostA) end
        if b.col then table.insert(excludeVis, b.col) end
    end
    visP.FilterDescendantsInstances = excludeVis; visP.IgnoreWater = true
    for _, b in ipairs(activeBridges) do
        if b.col and b.col.Parent then
            local colCF = b.col.CFrame
            local halfL = b.col.Size.Z * 0.5
            local rel = colCF:PointToObjectSpace(fromPos)
            local lz = math.clamp(rel.Z, -halfL + CONFIG.BRIDGE_WALK_EDGE_MARGIN, halfL - CONFIG.BRIDGE_WALK_EDGE_MARGIN)
            local topOffset = b.col.Size.Y * 0.5 + CONFIG.BRIDGE_WALK_HEIGHT
            local targetWorld = (colCF * CFrame.new(0, topOffset, lz)).Position
            local d = (targetWorld - fromPos).Magnitude
            if d < maxDist and d < bestScore then
                local dir = targetWorld - fromPos
                if dir.Magnitude > 0.1 then
                    local vis = Workspace:Raycast(fromPos, dir.Unit * (dir.Magnitude - 0.5), visP)
                    if not vis then bestScore = d; bestCol = b.col end
                end
            end
        end
    end
    return bestCol
end
local function hopToBridge()
    if not State.climbActive or State.bridgeHopActive or State.onBridge then return false end
    local hrp, hum = getHRP(), getHumanoid()
    if not hrp or not hum then return false end
    local col = findBestBridge(CONFIG.BRIDGE_HOP_RANGE)
    if not col then return false end
    local colCF = col.CFrame
    local halfL = col.Size.Z * 0.5; local halfT = col.Size.Y * 0.5
    local topOffset = halfT + CONFIG.BRIDGE_WALK_HEIGHT
    local rel = colCF:PointToObjectSpace(hrp.Position)
    local targetX = 0
    local targetZ = math.clamp(rel.Z, -halfL + CONFIG.BRIDGE_WALK_EDGE_MARGIN, halfL - CONFIG.BRIDGE_WALK_EDGE_MARGIN)
    local target = (colCF * CFrame.new(targetX, topOffset, targetZ)).Position
    State.bridgeHopActive = true
    State.climbSuppressUntil = tick() + CONFIG.BRIDGE_HOP_SUPPRESS
    stopClimb()
    local attach = Instance.new("Attachment", hrp)
    local ao = Instance.new("AlignOrientation", hrp)
    ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
    ao.Attachment0 = attach
    ao.MaxTorque = math.huge; ao.MaxAngularVelocity = math.huge
    ao.Responsiveness = 60; ao.RigidityEnabled = false
    ao.CFrame = CFrame.lookAt(Vector3.zero, colCF.LookVector, colCF.UpVector)
    ao.Parent = hrp
    local ap = Instance.new("AlignPosition", hrp)
    ap.Mode = Enum.PositionAlignmentMode.OneAttachment
    ap.Attachment0 = attach
    ap.MaxForce = math.huge
    ap.MaxVelocity = CONFIG.BRIDGE_HOP_MAGNET_MAXVEL
    ap.Responsiveness = CONFIG.BRIDGE_HOP_MAGNET_RESP
    ap.RigidityEnabled = false; ap.Position = target
    ap.Enabled = true; ap.Parent = hrp
    hum.AutoRotate = false
    local hopStartTime = tick()
    local switched = false
    local monitorConn
    local function switchToWalk()
        if switched then return end
        switched = true
        if monitorConn then monitorConn:Disconnect(); monitorConn = nil end
        State.bridgeHopActive = false; State.onBridge = true; State.bridgeCol = col
        State.bridgeAttach = attach; State.bridgeAlignPos = ap; State.bridgeAlignOrient = ao
        State.bridgeLocalX = targetX; State.bridgeLocalZ = targetZ
        State.bridgeTopOffset = topOffset; State.bridgeStartTime = tick()
        ap.MaxVelocity = math.huge; ap.Responsiveness = 400
        local h2 = getHumanoid()
        if h2 and h2.Parent then
            State.bridgeOldWalkSpeed = h2.WalkSpeed
            State.bridgeOldJumpPower = h2.JumpPower
            State.bridgeOldJumpHeight = h2.JumpHeight
            State.bridgeOldUseJumpPower = h2.UseJumpPower
            h2.PlatformStand = false; h2.AutoRotate = false
            h2.WalkSpeed = CONFIG.BRIDGE_WALK_SPEED
            h2.UseJumpPower = true; h2.JumpPower = 50; h2.JumpHeight = 7.2
            local a = getAnimator()
            if a then
                local anim = Instance.new("Animation"); anim.AnimationId = CONFIG.WALK_ANIM_ID
                local ok, track = pcall(function() return a:LoadAnimation(anim) end)
                if ok and track then
                    track.Priority = Enum.AnimationPriority.Movement
                    track.Looped = true
                    bridgeWalkTrack = track
                    pcall(function() track:Play(0.15) end)
                end
            end
        end
        local bridgeFlat = colCF.LookVector
        bridgeFlat = Vector3.new(bridgeFlat.X, 0, bridgeFlat.Z)
        if bridgeFlat.Magnitude < 0.01 then bridgeFlat = Vector3.new(0, 0, -1) end
        bridgeFlat = bridgeFlat.Unit
        local bridgeUp = colCF.UpVector
        local halfLNow = col.Size.Z * 0.5 - CONFIG.BRIDGE_WALK_EDGE_MARGIN
        State.bridgeWalkConn = RunService.RenderStepped:Connect(function(dt)
            if not State.onBridge or not col.Parent then stopBridgeWalk(); return end
            if not ap or not ap.Parent then stopBridgeWalk(); return end
            if not ao or not ao.Parent then stopBridgeWalk(); return end
            local hh = getHumanoid(); if not hh then stopBridgeWalk(); return end
            if tryAttachWallFromBridge() then return end
            local sign = 0
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then sign = sign + 1 end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then sign = sign - 1 end
            if sign == 0 and hh.MoveDirection.Magnitude > 0.1 then
                local md = Vector3.new(hh.MoveDirection.X, 0, hh.MoveDirection.Z)
                if md.Magnitude > 0.01 then
                    md = md.Unit
                    local dot = md:Dot(bridgeFlat)
                    if math.abs(dot) > 0.3 then sign = dot > 0 and 1 or -1 end
                end
            end
            if sign ~= 0 then
                local spd = CONFIG.BRIDGE_WALK_SPEED
                if sign < 0 then spd = spd * CONFIG.BRIDGE_WALK_BACK end
                State.bridgeLocalZ = State.bridgeLocalZ - sign * spd * dt
                State.bridgeLocalZ = math.clamp(State.bridgeLocalZ, -halfLNow, halfLNow)
                local facing = sign > 0 and bridgeFlat or -bridgeFlat
                ao.CFrame = CFrame.lookAt(Vector3.zero, facing, bridgeUp)
                if bridgeWalkTrack then pcall(function() bridgeWalkTrack:AdjustSpeed(1) end) end
            else
                if bridgeWalkTrack then pcall(function() bridgeWalkTrack:AdjustSpeed(0) end) end
            end
            ap.Position = (col.CFrame * CFrame.new(State.bridgeLocalX, State.bridgeTopOffset, State.bridgeLocalZ)).Position
        end)
    end
    monitorConn = RunService.RenderStepped:Connect(function()
        if switched then if monitorConn then monitorConn:Disconnect(); monitorConn = nil end; return end
        if not hrp or not hrp.Parent or not col or not col.Parent then
            if monitorConn then monitorConn:Disconnect(); monitorConn = nil end; return
        end
        if tick() - hopStartTime < CONFIG.BRIDGE_HOP_MIN_TIME then return end
        local relNow = colCF:PointToObjectSpace(hrp.Position)
        if relNow.Y >= (halfT + CONFIG.BRIDGE_HOP_SWITCH_HEIGHT) then switchToWalk() end
    end)
    task.delay(CONFIG.BRIDGE_HOP_SAFETY_TIME, function()
        if switched then return end
        if not hrp or not hrp.Parent or not col or not col.Parent then
            if ap and ap.Parent then pcall(function() ap:Destroy() end) end
            if ao and ao.Parent then pcall(function() ao:Destroy() end) end
            if attach and attach.Parent then pcall(function() attach:Destroy() end) end
            if monitorConn then monitorConn:Disconnect(); monitorConn = nil end
            State.bridgeHopActive = false
            local h = getHumanoid(); if h then h.AutoRotate = true end
            return
        end
        switchToWalk()
    end)
    return true
end

-- [SWING]
local function findAnchorPoint(fromGround)
    local hrp = getHRP(); if not hrp then return nil end
    local p = RaycastParams.new()
    p.FilterType = Enum.RaycastFilterType.Exclude
    p.FilterDescendantsInstances = climbFilter()
    local h = horizLook()
    local v = hrp.AssemblyLinearVelocity
    local hSpeed = Vector3.new(v.X, 0, v.Z).Magnitude
    local sf = math.clamp(hSpeed / 180, 0, 1.5)
    local origin = hrp.Position + Vector3.new(0, 2, 0)
    local dir = (h * 0.75 + Vector3.new(0, 0.55, 0)).Unit
    local result = Workspace:Raycast(origin, dir * CONFIG.RAYCAST_DIST, p)
    if result then return result.Position + result.Normal * 2 end
    local fwdM, upM
    if fromGround then fwdM = 2.2; upM = 1.8
    else fwdM = 0.9 + sf * 0.9; upM = 0.9 + sf * 0.7 end
    return hrp.Position + h * (CONFIG.ANCHOR_FWD * fwdM) + Vector3.new(0, CONFIG.ANCHOR_UP * upM, 0)
end
local function attachWeb()
    if State.active then return end
    local hrp, hum = getHRP(), getHumanoid()
    if not hrp or not hum then return end
    State.glideActive = false; State.glideUntil = 0
    local target = findAnchorPoint(false)
    if not target then return end
    local delta = target - hrp.Position; local dist = delta.Magnitude
    if dist < CONFIG.MIN_ROPE then return end
    if dist > CONFIG.MAX_ROPE then target = hrp.Position + delta.Unit * CONFIG.MAX_ROPE; dist = CONFIG.MAX_ROPE end
    refreshHandAttachments()
    State.anchorPos = target; State.ropeLength = dist; State.active = true
    attA.WorldPosition = getWebOrigin(hrp)
    attB.WorldPosition = target
    setMainBeamsEnabled(true); setZipBeamsEnabled(false)
    playAnim("SWING", 0.15, true)
    ikTargetR.WorldPosition = State.anchorPos; ikTargetL.WorldPosition = State.anchorPos
    setIKArms(ikTargetR, ikTargetL)
    stopBodyAlign()
    hum.AutoRotate = false
end
local function releaseWeb()
    if not State.active then return end
    local hrp = getHRP()
    local keepVel = hrp and hrp.AssemblyLinearVelocity or Vector3.zero
    State.anchorPos = nil; State.ropeLength = 0; State.active = false
    setMainBeamsEnabled(false); stopBodyAlign(); stopAllAnims(0.2); clearIK()
    local hum = getHumanoid()
    if hum and hum.FloorMaterial == Enum.Material.Air and hrp then
        State.glideActive = true; State.glideStart = tick()
        State.glideUntil = State.glideStart + CONFIG.GLIDE_TIME
        local h = horizLook()
        local boostedVel = keepVel * CONFIG.RELEASE_KEEP_SPEED + h * CONFIG.RELEASE_BOOST
        local spd = boostedVel.Magnitude
        if spd > CONFIG.MAX_SPEED_HARD then boostedVel = boostedVel * (CONFIG.MAX_SPEED_HARD / spd) end
        hrp.AssemblyLinearVelocity = boostedVel
    elseif hrp then
        hrp.AssemblyLinearVelocity = keepVel * CONFIG.RELEASE_KEEP_SPEED
    end
end
local function endGlide()
    State.glideActive = false; State.glideUntil = 0; State.glideStart = 0
    stopBodyAlign(); stopAllAnims(0.2); clearIK()
end

-- [ZIP]
local function startZip()
    local hrp, hum = getHRP(), getHumanoid()
    if not hrp or not hum then return end
    local h = horizLook()
    local right = Vector3.new(-h.Z, 0, h.X)
    local ang = math.rad(CONFIG.ZIP_SIDE_ANGLE)
    local dirL = (h * math.cos(ang) - right * math.sin(ang))
    local dirR = (h * math.cos(ang) + right * math.sin(ang))
    local p = RaycastParams.new()
    p.FilterType = Enum.RaycastFilterType.Exclude
    p.FilterDescendantsInstances = climbFilter()
    local function rayOrVirtual(dir, upBias)
        local origin = hrp.Position + Vector3.new(0, 2, 0)
        local rayDir = (dir + Vector3.new(0, upBias, 0)).Unit
        local r = Workspace:Raycast(origin, rayDir * CONFIG.ZIP_DIST, p)
        if r then return r.Position + r.Normal * 2 end
        return hrp.Position + dir * CONFIG.ZIP_DIST + Vector3.new(0, CONFIG.ZIP_UP, 0)
    end
    local a = rayOrVirtual(dirL, 0.6); local b = rayOrVirtual(dirR, 0.6)
    refreshHandAttachments()
    State.zipA = a; State.zipB = b; State.zipMid = (a + b) * 0.5
    State.zipFwd = h; State.zipActive = true
    State.zipStart = tick(); State.zipUntil = State.zipStart + CONFIG.ZIP_DURATION
    hrp.AssemblyLinearVelocity = Vector3.new(h.X * 35, CONFIG.ZIP_LAUNCH_UP, h.Z * 35)
    zipPartA.Position = a; zipPartB.Position = b
    attZipA1.WorldPosition = getZipOrigin(hrp); attZipA2.WorldPosition = a
    attZipB1.WorldPosition = getZipOrigin(hrp); attZipB2.WorldPosition = b
    setZipBeamsEnabled(true); setMainBeamsEnabled(false)
    playAnim("ZIP", 0.1, false)
    ikTargetR.WorldPosition = b; ikTargetL.WorldPosition = a
    setIKArms(ikTargetR, ikTargetL)
    startBodyAlign(); updateBodyAlign(h, Vector3.new(0, 1, 0))
end
local function endZipToGlide()
    local hrp = getHRP()
    local keepVel = hrp and hrp.AssemblyLinearVelocity or Vector3.zero
    local fwd = State.zipFwd or horizLook()
    State.zipActive = false; State.zipUntil = 0; State.zipStart = 0
    setZipBeamsEnabled(false); setMainBeamsEnabled(false)
    stopAllAnims(0.2); clearIK(); stopBodyAlign()
    local hum = getHumanoid()
    if hum and hum.FloorMaterial == Enum.Material.Air and hrp then
        State.glideActive = true; State.glideStart = tick()
        State.glideUntil = State.glideStart + CONFIG.GLIDE_TIME
        local keptVel = keepVel * CONFIG.ZIP_KEEP_SPEED + fwd * CONFIG.ZIP_EXIT_BOOST + Vector3.new(0, CONFIG.ZIP_EXIT_UP, 0)
        local spd = keptVel.Magnitude
        if spd > CONFIG.MAX_SPEED_HARD then keptVel = keptVel * (CONFIG.MAX_SPEED_HARD / spd) end
        hrp.AssemblyLinearVelocity = keptVel
    end
end

-- [HANG]
local hangAlignPos = nil; local hangBodyAttach = nil
local hangRaiseTween = nil; local hangDescendTween = nil
local function clearHang()
    if hangRaiseTween then pcall(function() hangRaiseTween:Cancel() end); hangRaiseTween = nil end
    if hangDescendTween then pcall(function() hangDescendTween:Cancel() end); hangDescendTween = nil end
    if hangAlignPos then pcall(function() hangAlignPos:Destroy() end); hangAlignPos = nil end
    if hangBodyAttach then pcall(function() hangBodyAttach:Destroy() end); hangBodyAttach = nil end
    if attHangLower then pcall(function() attHangLower:Destroy() end); attHangLower = nil end
    hangBeamMain.Enabled = false
end
local function stopHang()
    if not State.hangActive then return end
    State.hangActive = false; State.hangAnchor = nil; State.hangHasCeiling = false
    stopAnim("HANG", 0.15); clearHang()
    local hum = getHumanoid(); local hrp = getHRP()
    if hum then
        hum.PlatformStand = false; hum.AutoRotate = true
        if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0, -5, 0) end
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Freefall) end)
    end
    tween(hangBtn, {BackgroundColor3 = CONFIG.BG2, TextColor3 = CONFIG.TEXT}, TI_FAST)
    tween(hangBtnStroke, {Color = CONFIG.ACCENT, Transparency = 0.5}, TI_FAST)
end
local function startHang()
    if State.hangActive or State.climbActive or State.onBridge or State.bridgeHopActive then return end
    if State.active or State.zipActive or State.glideActive then return end
    local hrp, hum = getHRP(), getHumanoid()
    if not hrp or not hum then return end
    local p = RaycastParams.new()
    p.FilterType = Enum.RaycastFilterType.Exclude
    p.FilterDescendantsInstances = climbFilter(); p.IgnoreWater = true
    local hit = Workspace:Raycast(hrp.Position, Vector3.new(0, CONFIG.HANG_RAYCAST_UP, 0), p)
    local distToCeiling = hit and (hit.Position.Y - hrp.Position.Y) or math.huge
    local anchorPos, startY, hasCeiling, descendToY
    if hit and distToCeiling > CONFIG.HANG_MIN_HEIGHT and distToCeiling <= CONFIG.HANG_MAX_HEIGHT then
        hasCeiling = true
        anchorPos = hit.Position - Vector3.new(0, 0.15, 0)
        startY = anchorPos.Y - CONFIG.HANG_DROP_CEILING
        local maxDropY = startY - CONFIG.HANG_MAX_DROP
        local safeMinY = hrp.Position.Y + CONFIG.HANG_SAFE_ABOVE
        descendToY = math.max(maxDropY, safeMinY)
    else
        hasCeiling = false
        anchorPos = hrp.Position + Vector3.new(0, CONFIG.HANG_AIR_RAISE, 0)
        startY = hrp.Position.Y; descendToY = nil
    end
    State.hangActive = true; State.hangAnchor = anchorPos; State.hangHasCeiling = hasCeiling
    hangPart.Position = anchorPos; hangPart.CFrame = CFrame.new(anchorPos)
    local char = LP.Character
    local lower = (char and (char:FindFirstChild("LowerTorso") or hrp)) or hrp
    attHangLower = Instance.new("Attachment"); attHangLower.Position = Vector3.new(0, 0.3, 0)
    attHangLower.Parent = lower
    hangBeamMain.Attachment1 = attHangLower; hangBeamMain.Enabled = true
    hum.PlatformStand = true; hum.AutoRotate = false
    hangBodyAttach = Instance.new("Attachment", hrp)
    local curPos = Vector3.new(hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
    hangAlignPos = Instance.new("AlignPosition")
    hangAlignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
    hangAlignPos.Attachment0 = hangBodyAttach
    hangAlignPos.MaxForce = math.huge
    hangAlignPos.Responsiveness = CONFIG.HANG_POS_RESP
    hangAlignPos.Position = curPos
    hangAlignPos.Parent = hrp
    playAnim("HANG", 0.15, true)
    if hasCeiling then
        hangRaiseTween = TweenService:Create(hangAlignPos,
            TweenInfo.new(CONFIG.HANG_RAISE_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            {Position = Vector3.new(hrp.Position.X, startY, hrp.Position.Z)})
        hangRaiseTween:Play()
    end
    if hasCeiling and descendToY and descendToY < startY - 0.5 then
        task.delay(CONFIG.HANG_RAISE_TIME + 0.1, function()
            if not State.hangActive or not hangAlignPos or not hangAlignPos.Parent then return end
            hangDescendTween = TweenService:Create(hangAlignPos,
                TweenInfo.new(CONFIG.HANG_DESCEND_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                {Position = Vector3.new(hrp.Position.X, descendToY, hrp.Position.Z)})
            hangDescendTween:Play()
        end)
    end
    tween(hangBtn, {BackgroundColor3 = Color3.fromRGB(80, 30, 30), TextColor3 = CONFIG.ACCENT}, TI_FAST)
    tween(hangBtnStroke, {Color = CONFIG.ACCENT, Transparency = 0.1}, TI_FAST)
end
-- [WEB PUSH]
local webPushConn = nil
local webPushLastTime = 0
local webPushNextDelay = 0
local webPushNextHand = "L"
local webPushLastPulse = 0

local function spawnPushBeam(hand, targetPos)
    if not hand or not hand.Parent then return end
    local handPos = hand.Position
    local dir = targetPos - handPos
    if dir.Magnitude > 0.01 then dir = dir.Unit else dir = horizLook() end
    local visualPos = targetPos + dir * CONFIG.WEB_PUSH_VISUAL_EXTRA
    local targetPart = Instance.new("Part")
    targetPart.Anchored = true; targetPart.CanCollide = false
    targetPart.CanQuery = false; targetPart.CanTouch = false
    targetPart.Transparency = 1; targetPart.Size = Vector3.new(0.1, 0.1, 0.1)
    targetPart.Position = visualPos; targetPart.Parent = Workspace
    local targetAtt = Instance.new("Attachment", targetPart)
    local handAtt = Instance.new("Attachment", hand)
    local beam = Instance.new("Beam")
    beam.Color = ColorSequence.new(CONFIG.WEB_COLOR)
    beam.LightEmission = 1; beam.LightInfluence = 0
    beam.FaceCamera = true
    beam.Width0 = 0.85; beam.Width1 = 0.65
    beam.Transparency = SEQ_RAGGED
    beam.Texture = WEB_TEXTURE; beam.TextureMode = Enum.TextureMode.Wrap
    beam.TextureLength = 1; beam.TextureSpeed = 0.5; beam.Segments = 6
    beam.Attachment0 = targetAtt; beam.Attachment1 = handAtt
    beam.Parent = targetPart
    task.delay(CONFIG.WEB_PUSH_BEAM_LIFE, function()
        if targetPart then targetPart:Destroy() end
        if handAtt and handAtt.Parent then handAtt:Destroy() end
    end)
end
local function pulseArmIK(side, targetPos)
    local hum = getHumanoid(); if not hum then return end
    local hand = getHand(side); local root = getArmRoot(side)
    if not hand or not root then return end
    local startPos = hand.Position
    local dir = targetPos - startPos
    if dir.Magnitude < 0.5 then dir = horizLook() else dir = dir.Unit end
    local camRight = Camera.CFrame.RightVector
    camRight = Vector3.new(camRight.X, 0, camRight.Z)
    if camRight.Magnitude < 0.01 then camRight = Vector3.new(1, 0, 0) end
    camRight = camRight.Unit
    local sideSign = (side == "R") and 1 or -1
    local reachPos = startPos + dir * CONFIG.WEB_PUSH_IK_REACH + camRight * (CONFIG.WEB_PUSH_IK_SIDE * sideSign) + Vector3.new(0, 0.2, 0)
    local targetAtt = Instance.new("Attachment", ikHost); targetAtt.WorldPosition = startPos
    local ik = Instance.new("IKControl")
    ik.Type = Enum.IKControlType.Position
    ik.EndEffector = hand; ik.ChainRoot = root
    ik.Target = targetAtt; ik.Weight = CONFIG.WEB_PUSH_IK_WEIGHT
    ik.SmoothTime = CONFIG.WEB_PUSH_IK_SMOOTH
    ik.Parent = hum
    TweenService:Create(targetAtt,
        TweenInfo.new(CONFIG.WEB_PUSH_IK_REACH_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {WorldPosition = reachPos}):Play()
    task.delay(CONFIG.WEB_PUSH_IK_REACH_TIME + CONFIG.WEB_PUSH_IK_HOLD_TIME, function()
        if not targetAtt or not targetAtt.Parent then
            if ik and ik.Parent then pcall(function() ik:Destroy() end) end
            return
        end
        TweenService:Create(targetAtt,
            TweenInfo.new(CONFIG.WEB_PUSH_IK_RETURN_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {WorldPosition = startPos}):Play()
        task.delay(CONFIG.WEB_PUSH_IK_RETURN_TIME + 0.02, function()
            if ik and ik.Parent then pcall(function() ik:Destroy() end) end
            if targetAtt and targetAtt.Parent then pcall(function() targetAtt:Destroy() end) end
        end)
    end)
end
local function doWebPushPulse(side)
    local now = tick()
    if now - webPushLastPulse < CONFIG.WEB_PUSH_RESTART_COOLDOWN then return end
    webPushLastPulse = now
    local hrp, hum = getHRP(), getHumanoid()
    if not hrp or not hum then return end
    local flat = horizLook()
    local rayOrigin = hrp.Position + Vector3.new(0, CONFIG.WEB_PUSH_ORIGIN_UP, 0)
    local rayDir = flat * CONFIG.WEB_PUSH_DIST
    local p = RaycastParams.new()
    p.FilterType = Enum.RaycastFilterType.Exclude
    p.FilterDescendantsInstances = climbFilter(); p.IgnoreWater = true
    local hit = Workspace:Raycast(rayOrigin, rayDir, p)
    local targetPos = hit and hit.Position or (rayOrigin + rayDir)
    local hand = getHand(side)
    if hand then spawnPushBeam(hand, targetPos); pulseArmIK(side, targetPos) end
    local vel = hrp.AssemblyLinearVelocity
    local flatVel = Vector3.new(vel.X, 0, vel.Z)
    local flatSpd = flatVel.Magnitude
    if flatSpd < CONFIG.WEB_PUSH_MAX_SPEED then
        local addSpd = math.min(CONFIG.WEB_PUSH_FORCE, CONFIG.WEB_PUSH_MAX_SPEED - flatSpd)
        vel = Vector3.new(vel.X + flat.X * addSpd, vel.Y, vel.Z + flat.Z * addSpd)
    end
    if vel.Y < -5 then vel = Vector3.new(vel.X, 0, vel.Z) end
    local newY = vel.Y + CONFIG.WEB_PUSH_UP
    if newY > CONFIG.WEB_PUSH_MAX_Y then newY = CONFIG.WEB_PUSH_MAX_Y end
    vel = Vector3.new(vel.X, newY, vel.Z)
    local spd = vel.Magnitude
    if spd > CONFIG.MAX_SPEED_HARD then vel = vel * (CONFIG.MAX_SPEED_HARD / spd) end
    hrp.AssemblyLinearVelocity = vel
end
local function startWebPush()
    if State.webPushActive then return end
    State.webPushActive = true
    webPushLastTime = tick()
    webPushNextDelay = CONFIG.WEB_PUSH_DELAY_FAST
    webPushNextHand = "L"
    doWebPushPulse("L")
    webPushNextHand = "R"
    webPushConn = RunService.RenderStepped:Connect(function()
        if not State.webPushActive then return end
        if State.climbActive or State.onBridge or State.bridgeHopActive then stopWebPush(); return end
        local hrp, hum = getHRP(), getHumanoid()
        if not hrp or not hum then stopWebPush(); return end
        if hum.FloorMaterial ~= Enum.Material.Air then stopWebPush(); return end
        local now = tick()
        if now - webPushLastTime >= webPushNextDelay then
            webPushLastTime = now
            doWebPushPulse(webPushNextHand)
            if webPushNextHand == "L" then webPushNextHand = "R" else webPushNextHand = "L" end
            if webPushNextDelay == CONFIG.WEB_PUSH_DELAY_FAST then webPushNextDelay = CONFIG.WEB_PUSH_DELAY_SLOW
            else webPushNextDelay = CONFIG.WEB_PUSH_DELAY_FAST end
        end
    end)
    tween(webPushBtn, {BackgroundColor3 = Color3.fromRGB(80, 30, 30), TextColor3 = CONFIG.ACCENT}, TI_FAST)
    tween(webPushBtnStroke, {Color = CONFIG.ACCENT, Transparency = 0.1}, TI_FAST)
end
local function stopWebPush()
    if not State.webPushActive then return end
    State.webPushActive = false
    if webPushConn then webPushConn:Disconnect(); webPushConn = nil end
    webPushNextHand = "L"; webPushNextDelay = CONFIG.WEB_PUSH_DELAY_FAST
    if not State.webPushEnabled then
        tween(webPushBtn, {BackgroundColor3 = CONFIG.BG2, TextColor3 = CONFIG.TEXT}, TI_FAST)
        tween(webPushBtnStroke, {Color = CONFIG.ACCENT, Transparency = 0.5}, TI_FAST)
    else
        tween(webPushBtn, {BackgroundColor3 = Color3.fromRGB(20, 60, 90), TextColor3 = CONFIG.ACCENT}, TI_FAST)
        tween(webPushBtnStroke, {Color = CONFIG.ACCENT, Transparency = 0.1}, TI_FAST)
    end
end

-- [FOV]
fovDragging = false
function setFOV(value)
    value = math.clamp(value, CONFIG.FOV_MIN, CONFIG.FOV_MAX)
    Camera.FieldOfView = value
    local a = (value - CONFIG.FOV_MIN) / (CONFIG.FOV_MAX - CONFIG.FOV_MIN)
    fovFill.Size = UDim2.new(a, 0, 1, 0)
    fovKnob.Position = UDim2.new(a, 0, 0.5, 0)
    fovLabel.Text = "FOV " .. math.floor(value)
end
function handleFovInput(input)
    local tp = fovTrack.AbsolutePosition
    local ts = fovTrack.AbsoluteSize
    if ts.X <= 0 then return end
    local relX = math.clamp((input.Position.X - tp.X) / ts.X, 0, 1)
    setFOV(CONFIG.FOV_MIN + relX * (CONFIG.FOV_MAX - CONFIG.FOV_MIN))
end
fovTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        fovDragging = true
        handleFovInput(input)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if fovDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        handleFovInput(input)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        fovDragging = false
    end
end)
setFOV(CONFIG.FOV_DEFAULT)

-- [PHYSICS]
RunService.RenderStepped:Connect(function(dt)
    if State.climbActive then updateClimb(dt); return end
    if State.hangActive then
        local hrp = getHRP()
        if not hrp then stopHang(); return end
        if attHangLower and attHangLower.Parent then
            attHangLower.WorldPosition = attHangLower.Parent.Position
        end
        return
    end
    if State.climbEnabled and not State.bridgeHopActive and not State.onBridge
        and not State.active and not State.zipActive and not State.glideActive then
        tryStartClimb()
    end
    local humT = getHumanoid()
    if humT then
        if humT.FloorMaterial == Enum.Material.Air and not State.bridgeHopActive and not State.onBridge then
            if not trailR.Enabled then attachTrails() end
        else
            if trailR.Enabled then detachTrails() end
        end
    end
    local humCheck = getHumanoid()
    local hrpCheck = getHRP()
    if humCheck and hrpCheck and humCheck.FloorMaterial ~= Enum.Material.Air then
        if State.zipActive and (tick() - State.zipStart) > 0.25 and hrpCheck.AssemblyLinearVelocity.Magnitude < 4 then
            endZipToGlide(); stopBodyAlign(); return
        end
        if State.glideActive and (tick() - State.glideStart) > 0.3 and hrpCheck.AssemblyLinearVelocity.Magnitude < 4 then
            endGlide(); stopBodyAlign(); return
        end
    end
    if State.zipActive then
        local hrp = getHRP()
        local hum = getHumanoid()
        if not hrp or not hum then endZipToGlide(); return end
        local origin = getZipOrigin(hrp)
        attZipA1.WorldPosition = origin
        attZipA2.WorldPosition = State.zipA
        attZipB1.WorldPosition = origin
        attZipB2.WorldPosition = State.zipB
        ikTargetR.WorldPosition = State.zipB
        ikTargetL.WorldPosition = State.zipA
        if tick() >= State.zipUntil then endZipToGlide(); return end
        local vel = hrp.AssemblyLinearVelocity
        local toMid = State.zipMid - hrp.Position
        local midDist = toMid.Magnitude
        if midDist > 0.5 then vel = vel + (toMid / midDist) * CONFIG.ZIP_FORCE * dt end
        vel = vel + Vector3.new(0, CONFIG.ZIP_UP_BOOST * dt * 60, 0)
        local spd = vel.Magnitude
        if spd > CONFIG.MAX_SPEED_HARD then vel = vel * (CONFIG.MAX_SPEED_HARD / spd) end
        hrp.AssemblyLinearVelocity = vel
        updateBodyAlign(State.zipFwd, Vector3.new(0, 1, 0))
        return
    end
    if State.glideActive then
        local hrp = getHRP()
        local hum = getHumanoid()
        if not hrp or not hum then endGlide(); return end
        if tick() >= State.glideUntil then endGlide(); return end
        if hum.FloorMaterial ~= Enum.Material.Air then endGlide(); return end
        local v = hrp.AssemblyLinearVelocity
        local speed = v.Magnitude
        local el = tick() - State.glideStart
        local dr
        if el < 0.6 then dr = 0
        elseif el < 1.2 then dr = CONFIG.GLIDE_DRAG * 0.15
        else dr = CONFIG.GLIDE_DRAG end
        local drag = math.max(0, 1 - dr * dt)
        v = Vector3.new(v.X * drag, v.Y, v.Z * drag)
        local cf = math.clamp(1 - speed / CONFIG.AIR_STEER_MAX_SPD, 0, 1)
        local h = horizLook()
        v = v + h * CONFIG.AIR_STEER_GLIDE * cf * dt
        local md = getMoveDirWorld()
        if md.Magnitude > 0.01 then v = v + md * CONFIG.AIR_KEY_FORCE * cf * dt end
        local spd2 = v.Magnitude
        if spd2 > CONFIG.MAX_SPEED_HARD then v = v * (CONFIG.MAX_SPEED_HARD / spd2) end
        hrp.AssemblyLinearVelocity = v
        local hv = Vector3.new(v.X, 0, v.Z)
        local ld = (hv.Magnitude > 2) and hv.Unit or horizLook()
        updateBodyAlign(ld, Vector3.new(0, 1, 0))
        return
    end
    if not State.active then return end
    local hrp = getHRP()
    if not hrp or not State.anchorPos then releaseWeb(); return end
    local toAnchor = State.anchorPos - hrp.Position
    local dist = toAnchor.Magnitude
    if dist < 0.5 then
        attA.WorldPosition = getWebOrigin(hrp)
        attB.WorldPosition = State.anchorPos
        return
    end
    local dir = toAnchor / dist
    local vel = hrp.AssemblyLinearVelocity
    local hDrag = math.max(0, 1 - CONFIG.AIR_DRAG * dt)
    vel = Vector3.new(vel.X * hDrag, vel.Y, vel.Z * hDrag)
    if dist >= State.ropeLength - 1 then
        local vOut = vel:Dot(-dir)
        if vOut > 0 then vel = vel + dir * vOut * CONFIG.RADIAL_DAMP end
    end
    local over = dist - State.ropeLength
    if over > 0 then vel = vel + dir * math.min(over * 10, 60) end
    local h = horizLook()
    local tanFwd = h - dir * h:Dot(dir)
    if tanFwd.Magnitude > 0.01 then vel = vel + tanFwd.Unit * CONFIG.SWING_BOOST * dt end
    local relY = hrp.Position.Y - State.anchorPos.Y
    local phase = math.clamp(-relY / math.max(State.ropeLength, 1), 0, 1)
    local pump = CONFIG.PUMP_AT_BOTTOM * phase + CONFIG.PUMP_AT_TOP * (1 - phase)
    if tanFwd.Magnitude > 0.01 then vel = vel + tanFwd.Unit * pump * dt end
    local md = getMoveDirWorld()
    if md.Magnitude > 0.01 then
        local tMD = md - dir * md:Dot(dir)
        if tMD.Magnitude > 0.01 then vel = vel + tMD.Unit * CONFIG.AIR_STEER_SWING * dt end
    end
    local lookY = Camera.CFrame.LookVector.Y
    if lookY > 0.25 then vel = vel + Vector3.new(0, CONFIG.UP_STEER * lookY * dt, 0) end
    if relY > CONFIG.MAX_ABOVE_ANCHOR then
        if vel.Y > 0 then vel = Vector3.new(vel.X, 0, vel.Z) end
        local d = math.max(0, 1 - CONFIG.ABOVE_CAP_DRAG * dt)
        vel = Vector3.new(vel.X * d, vel.Y, vel.Z * d)
    end
    local spd = vel.Magnitude
    if spd > CONFIG.MAX_SPEED then vel = vel * (CONFIG.MAX_SPEED / spd) end
    hrp.AssemblyLinearVelocity = vel
    State.anchorPos = State.anchorPos + h * CONFIG.ANCHOR_DRIFT * dt + Vector3.new(0, CONFIG.ANCHOR_LIFT * dt, 0)
    attA.WorldPosition = getWebOrigin(hrp)
    attB.WorldPosition = State.anchorPos
    ikTargetR.WorldPosition = State.anchorPos
    ikTargetL.WorldPosition = State.anchorPos
end)

-- [INPUT]
function onJumpStart()
    if not State.enabled or State.hangActive then return end
    if State.onBridge then safe(dismountBridge); return end
    if State.climbActive then
        local hrp = getHRP()
        if hrp and findBestBridge(CONFIG.BRIDGE_HOP_PRIORITY_RANGE) then safe(hopToBridge); return end
        safe(jumpOffClimb); return
    end
    if State.active then safe(releaseWeb); return end
    if State.zipActive then safe(endZipToGlide); return end
    State.holding = true
    safe(function()
        if isOnGround() then startZip()
        elseif State.webPushEnabled then startWebPush()
        else attachWeb() end
    end)
end
function onJumpEnd()
    State.holding = false
    if State.webPushActive then safe(stopWebPush)
    elseif State.active then safe(releaseWeb)
    elseif State.zipActive then safe(endZipToGlide) end
end
safe(function()
    ContextActionService:BindActionAtPriority("SpiderWeb_Jump",
        function(_, state, _)
            if not State.enabled then return Enum.ContextActionResult.Pass end
            if state == Enum.UserInputState.Begin then
                onJumpStart(); return Enum.ContextActionResult.Sink
            elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
                onJumpEnd(); return Enum.ContextActionResult.Sink end
            return Enum.ContextActionResult.Pass
        end,
        false, Enum.ContextActionPriority.High.Value, Enum.PlayerActions.CharacterJump)
end)
function bindJumpButton()
    for _, v in ipairs(PlayerGui:GetDescendants()) do
        if v:IsA("GuiButton") and (v.Name == "JumpButton" or v.Name:lower():find("jump")) then
            v.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch
                or input.UserInputType == Enum.UserInputType.MouseButton1 then safe(onJumpStart) end
            end)
            v.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch
                or input.UserInputType == Enum.UserInputType.MouseButton1 then safe(onJumpEnd) end
            end)
            return true
        end
    end
    return false
end

-- [RESPAWN]
LP.CharacterAdded:Connect(function()
    State.holding = false; State.active = false; State.zipActive = false; State.glideActive = false
    State.hangActive = false; State.climbActive = false; State.climbEnabled = false
    State.climbSuppressUntil = 0; State.webPushActive = false; State.bridgeHopActive = false
    State.bridgeStartTime = 0; State.anchorPos = nil
    stopBridgeWalk(); cleanupBridges(); clearClimb(); clearHang(); stopWebPush()
    setMainBeamsEnabled(false); setZipBeamsEnabled(false)
    detachTrails(); stopBodyAlign(); stopAllAnims(0); clearIK(); detachHandAttachments()
    tracks = {}; animator = nil; bridgeWalkTrack = nil
    climbLastDir = Vector3.new(0, 1, 0)
    climbCurrentNormal = Vector3.new(0, 0, 1)
    climbCurrentKind = "wall"
    climbBtn.Text = "CLIMB: OFF"; climbBtn.BackgroundColor3 = CONFIG.BG2
    climbBtn.TextColor3 = CONFIG.TEXT; climbBtnStroke.Color = CONFIG.ACCENT; climbBtnStroke.Transparency = 0.5
    webPushBtn.Text = "WEB PUSH: OFF"; webPushBtn.BackgroundColor3 = CONFIG.BG2
    webPushBtn.TextColor3 = CONFIG.TEXT; webPushBtnStroke.Color = CONFIG.ACCENT; webPushBtnStroke.Transparency = 0.5
    hangBtn.BackgroundColor3 = CONFIG.BG2; hangBtn.TextColor3 = CONFIG.TEXT
    hangBtnStroke.Color = CONFIG.ACCENT; hangBtnStroke.Transparency = 0.5
    task.wait(0.5)
    setFOV(Camera.FieldOfView)
    safe(bindJumpButton)
end)
if LP.Character then safe(bindJumpButton) end

-- [ENABLE]
function setEnabled(v)
    State.enabled = v
    if not v then
        if State.climbActive then stopClimb() end
        if State.active then releaseWeb() end
        if State.zipActive then endZipToGlide() end
        if State.glideActive then endGlide() end
        if State.hangActive then stopHang() end
        if State.webPushActive then stopWebPush() end
        if State.onBridge then stopBridgeWalk() end
        State.climbEnabled = false; State.webPushEnabled = false; State.holding = false
        State.climbSuppressUntil = 0
        climbBtn.Text = "CLIMB: OFF"; climbBtn.BackgroundColor3 = CONFIG.BG2
        climbBtn.TextColor3 = CONFIG.TEXT; climbBtnStroke.Color = CONFIG.ACCENT; climbBtnStroke.Transparency = 0.5
        webPushBtn.Text = "WEB PUSH: OFF"; webPushBtn.BackgroundColor3 = CONFIG.BG2
        webPushBtn.TextColor3 = CONFIG.TEXT; webPushBtnStroke.Color = CONFIG.ACCENT; webPushBtnStroke.Transparency = 0.5
        hangBtn.BackgroundColor3 = CONFIG.BG2; hangBtn.TextColor3 = CONFIG.TEXT
        hangBtnStroke.Color = CONFIG.ACCENT; hangBtnStroke.Transparency = 0.5
        stopBodyAlign(); stopAllAnims(0); clearIK(); detachTrails()
    end
    if v then
        tween(toggle, {BackgroundColor3 = Color3.fromRGB(20, 60, 90), TextColor3 = CONFIG.ACCENT})
        toggle.Text = "ON"
        tween(toggleStroke, {Color = CONFIG.ACCENT, Transparency = 0.1})
        tween(dot, {BackgroundColor3 = CONFIG.ACCENT})
    else
        tween(toggle, {BackgroundColor3 = CONFIG.BG2, TextColor3 = CONFIG.DIM})
        toggle.Text = "OFF"
        tween(toggleStroke, {Color = CONFIG.DIM, Transparency = 0.4})
        tween(dot, {BackgroundColor3 = CONFIG.DIM})
    end
end

function bindPress(btn, cb)
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then cb() end
    end)
end

bindPress(toggle, function() setEnabled(not State.enabled) end)

bindPress(hangBtn, function()
    if not State.enabled then return end
    if State.hangActive then stopHang() else safe(startHang) end
end)

bindPress(climbBtn, function()
    if not State.enabled then return end
    if State.climbEnabled then
        State.climbEnabled = false
        if State.climbActive then stopClimb() end
        climbBtn.Text = "CLIMB: OFF"
        tween(climbBtn, {BackgroundColor3 = CONFIG.BG2, TextColor3 = CONFIG.TEXT}, TI_FAST)
        tween(climbBtnStroke, {Color = CONFIG.ACCENT, Transparency = 0.5}, TI_FAST)
    else
        State.climbEnabled = true
        climbBtn.Text = "CLIMB: ON"
        tween(climbBtn, {BackgroundColor3 = Color3.fromRGB(20, 60, 90), TextColor3 = CONFIG.ACCENT}, TI_FAST)
        tween(climbBtnStroke, {Color = CONFIG.ACCENT, Transparency = 0.1}, TI_FAST)
    end
end)

bindPress(bridgeBtn, function()
    if not State.enabled then return end
    safe(createWebBridge)
end)

bindPress(webPushBtn, function()
    if not State.enabled then return end
    if State.webPushEnabled then
        State.webPushEnabled = false
        if State.webPushActive then stopWebPush() end
        webPushBtn.Text = "WEB PUSH: OFF"
        tween(webPushBtn, {BackgroundColor3 = CONFIG.BG2, TextColor3 = CONFIG.TEXT}, TI_FAST)
        tween(webPushBtnStroke, {Color = CONFIG.ACCENT, Transparency = 0.5}, TI_FAST)
    else
        State.webPushEnabled = true
        webPushBtn.Text = "WEB PUSH: ON"
        tween(webPushBtn, {BackgroundColor3 = Color3.fromRGB(20, 60, 90), TextColor3 = CONFIG.ACCENT}, TI_FAST)
        tween(webPushBtnStroke, {Color = CONFIG.ACCENT, Transparency = 0.1}, TI_FAST)
    end
end)

bindPress(closeBtn, function()
    local collapsed = body.Visible == false
    body.Visible = collapsed
    tween(main, {Size = UDim2.new(0, 320, 0, collapsed and 220 or 34)}, TI_MED)
    closeBtn.Text = collapsed and "−" or "+"
end)

-- DRAG
local dragging, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- [BOOT]
local genv = getgenv and getgenv() or _G
if genv then genv.SpiderWeb_Loaded = true end
updateBridgeBtn()
setEnabled(false)
print("[SpiderWeb] Loaded — swing + zip + glide + hang + climb + web push + bridge.")
