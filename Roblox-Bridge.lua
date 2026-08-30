```lua
--==================================================
-- ROBLOX ↔ DISCORD BRIDGE
-- PREMIUM PROFESSIONAL UI
-- MOBILE + PC
-- FUNCTIONALITY PRESERVED
--==================================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================

local SERVER_URL = "https://roblox-bridge-production.up.railway.app"
local POLL_INTERVAL = 3

--==================================================
-- HTTP REQUEST CHECK
--==================================================

local httpRequest =
    (syn and syn.request)
    or (http and http.request)
    or http_request
    or request

if not httpRequest then
    warn("HTTP request is not supported by this executor.")
    return
end

--==================================================
-- SAFE CLIPBOARD
--==================================================

local function CopyToClipboard(text)
    local fn = nil

    pcall(function()
        fn = setclipboard
    end)

    if not fn then
        pcall(function()
            fn = toclipboard
        end)
    end

    if not fn and syn then
        pcall(function()
            fn = syn.write_clipboard
        end)
    end

    if not fn then
        return false
    end

    return pcall(function()
        fn(tostring(text))
    end)
end

--==================================================
-- REMOVE OLD UI
--==================================================

local OldUI = PlayerGui:FindFirstChild("DiscordBridgeUI")

if OldUI then
    OldUI:Destroy()
end

--==================================================
-- SCREEN GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DiscordBridgeUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

--==================================================
-- RESPONSIVE SIZE
--==================================================

local Camera = workspace.CurrentCamera
local Viewport = Camera and Camera.ViewportSize or Vector2.new(800, 600)

local IsSmallScreen = Viewport.X < 600

local WindowWidth =
    IsSmallScreen
    and math.min(Viewport.X - 24, 520)
    or 520

local WindowHeight =
    IsSmallScreen
    and math.min(Viewport.Y - 35, 455)
    or 455

--==================================================
-- COLORS
--==================================================

local C = {
    Background = Color3.fromRGB(10, 12, 17),
    Surface = Color3.fromRGB(17, 20, 28),
    Surface2 = Color3.fromRGB(22, 25, 34),
    Surface3 = Color3.fromRGB(27, 30, 40),

    Border = Color3.fromRGB(48, 53, 67),

    Text = Color3.fromRGB(245, 247, 252),
    TextSoft = Color3.fromRGB(170, 176, 190),
    TextDim = Color3.fromRGB(112, 119, 135),

    Accent = Color3.fromRGB(88, 101, 242),
    AccentHover = Color3.fromRGB(105, 117, 255),

    Green = Color3.fromRGB(75, 210, 135),
    Red = Color3.fromRGB(235, 82, 90),
    Yellow = Color3.fromRGB(255, 190, 70),

    OwnMessage = Color3.fromRGB(24, 43, 37),
    OtherMessage = Color3.fromRGB(24, 27, 36),
}

--==================================================
-- UTILITY FUNCTIONS
--==================================================

local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function Stroke(parent, color, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or C.Border
    s.Transparency = transparency or 0
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

local function Tween(object, properties, duration)
    return TweenService:Create(
        object,
        TweenInfo.new(
            duration or 0.15,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        ),
        properties
    )
end

local function MakeButtonHover(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        Tween(button, {
            BackgroundColor3 = hoverColor
        }, 0.15):Play()
    end)

    button.MouseLeave:Connect(function()
        Tween(button, {
            BackgroundColor3 = normalColor
        }, 0.15):Play()
    end)
end

--==================================================
-- MAIN WINDOW
--==================================================

local Main = Instance.new("Frame")
Main.Name = "MainWindow"
Main.Size = UDim2.new(0, WindowWidth, 0, WindowHeight)
Main.Position = UDim2.new(
    0.5,
    -WindowWidth / 2,
    0.5,
    -WindowHeight / 2
)
Main.BackgroundColor3 = C.Background
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui

Corner(Main, 18)
Stroke(Main, Color3.fromRGB(55, 60, 76), 0.25, 1)

--==================================================
-- TOP BAR
--==================================================

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 72)
TopBar.BackgroundColor3 = C.Surface
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

Corner(TopBar, 18)

-- Bottom cover so top bar corner doesn't affect lower area
local TopBarCover = Instance.new("Frame")
TopBarCover.Size = UDim2.new(1, 0, 0, 20)
TopBarCover.Position = UDim2.new(0, 0, 1, -20)
TopBarCover.BackgroundColor3 = C.Surface
TopBarCover.BorderSizePixel = 0
TopBarCover.Parent = TopBar

--==================================================
-- APP ICON
--==================================================

local AppIcon = Instance.new("Frame")
AppIcon.Size = UDim2.new(0, 42, 0, 42)
AppIcon.Position = UDim2.new(0, 15, 0, 15)
AppIcon.BackgroundColor3 = C.Accent
AppIcon.BorderSizePixel = 0
AppIcon.Parent = TopBar

Corner(AppIcon, 12)

local AppIconInner = Instance.new("Frame")
AppIconInner.Size = UDim2.new(0, 25, 0, 17)
AppIconInner.Position = UDim2.new(0.5, -12.5, 0.5, -8)
AppIconInner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
AppIconInner.BorderSizePixel = 0
AppIconInner.Parent = AppIcon

Corner(AppIconInner, 8)

local Eye1 = Instance.new("Frame")
Eye1.Size = UDim2.new(0, 5, 0, 5)
Eye1.Position = UDim2.new(0, 6, 0, 6)
Eye1.BackgroundColor3 = C.Accent
Eye1.BorderSizePixel = 0
Eye1.Parent = AppIconInner
Corner(Eye1, 3)

local Eye2 = Eye1:Clone()
Eye2.Position = UDim2.new(1, -11, 0, 6)
Eye2.Parent = AppIconInner

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 68, 0, 13)
Title.Size = UDim2.new(1, -210, 0, 25)
Title.Font = Enum.Font.GothamBold
Title.Text = "Discord Bridge"
Title.TextColor3 = C.Text
Title.TextSize = 19
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.new(0, 69, 0, 38)
Subtitle.Size = UDim2.new(1, -220, 0, 18)
Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "Roblox  •  Discord"
Subtitle.TextColor3 = C.TextDim
Subtitle.TextSize = 12
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = TopBar

--==================================================
-- WINDOW BUTTONS
--==================================================

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 38, 0, 38)
Minimize.Position = UDim2.new(1, -88, 0, 17)
Minimize.BackgroundColor3 = C.Surface2
Minimize.BorderSizePixel = 0
Minimize.Text = "—"
Minimize.Font = Enum.Font.GothamBold
Minimize.TextSize = 18
Minimize.TextColor3 = C.TextSoft
Minimize.AutoButtonColor = false
Minimize.Parent = TopBar

Corner(Minimize, 10)

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 38, 0, 38)
Close.Position = UDim2.new(1, -45, 0, 17)
Close.BackgroundColor3 = Color3.fromRGB(48, 29, 34)
Close.BorderSizePixel = 0
Close.Text = "×"
Close.Font = Enum.Font.GothamMedium
Close.TextSize = 23
Close.TextColor3 = Color3.fromRGB(255, 120, 128)
Close.AutoButtonColor = false
Close.Parent = TopBar

Corner(Close, 10)

MakeButtonHover(
    Minimize,
    C.Surface2,
    C.Surface3
)

MakeButtonHover(
    Close,
    Color3.fromRGB(48, 29, 34),
    Color3.fromRGB(75, 34, 40)
)

--==================================================
-- STATUS BAR
--==================================================

local StatusContainer = Instance.new("Frame")
StatusContainer.Size = UDim2.new(1, -30, 0, 38)
StatusContainer.Position = UDim2.new(0, 15, 0, 82)
StatusContainer.BackgroundColor3 = C.Surface
StatusContainer.BorderSizePixel = 0
StatusContainer.Parent = Main

Corner(StatusContainer, 11)
Stroke(StatusContainer, C.Border, 0.55, 1)

-- Status indicator
local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 9, 0, 9)
StatusDot.Position = UDim2.new(0, 14, 0.5, -4.5)
StatusDot.BackgroundColor3 = C.Yellow
StatusDot.BorderSizePixel = 0
StatusDot.Parent = StatusContainer

Corner(StatusDot, 9)

-- subtle glow
local StatusGlow = Instance.new("Frame")
StatusGlow.Size = UDim2.new(0, 17, 0, 17)
StatusGlow.Position = UDim2.new(0, 10, 0.5, -8.5)
StatusGlow.BackgroundColor3 = C.Yellow
StatusGlow.BackgroundTransparency = 0.88
StatusGlow.BorderSizePixel = 0
StatusGlow.ZIndex = 0
StatusGlow.Parent = StatusContainer

Corner(StatusGlow, 20)

local StatusText = Instance.new("TextLabel")
StatusText.BackgroundTransparency = 1
StatusText.Position = UDim2.new(0, 35, 0, 0)
StatusText.Size = UDim2.new(1, -50, 1, 0)
StatusText.Font = Enum.Font.GothamMedium
StatusText.Text = "Connecting..."
StatusText.TextColor3 = C.TextSoft
StatusText.TextSize = 12
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = StatusContainer

--==================================================
-- CHAT AREA
--==================================================

local ChatFrame = Instance.new("Frame")
ChatFrame.Position = UDim2.new(0, 15, 0, 130)
ChatFrame.Size = UDim2.new(1, -30, 0, WindowHeight - 208)
ChatFrame.BackgroundColor3 = C.Background
ChatFrame.BorderSizePixel = 0
ChatFrame.Parent = Main

Corner(ChatFrame, 13)
Stroke(ChatFrame, C.Border, 0.55, 1)

-- Chat header
local ChatHeader = Instance.new("Frame")
ChatHeader.Size = UDim2.new(1, 0, 0, 34)
ChatHeader.BackgroundTransparency = 1
ChatHeader.Parent = ChatFrame

local ChatTitle = Instance.new("TextLabel")
ChatTitle.BackgroundTransparency = 1
ChatTitle.Position = UDim2.new(0, 14, 0, 8)
ChatTitle.Size = UDim2.new(1, -28, 0, 20)
ChatTitle.Font = Enum.Font.GothamBold
ChatTitle.Text = "Messages"
ChatTitle.TextColor3 = C.TextSoft
ChatTitle.TextSize = 12
ChatTitle.TextXAlignment = Enum.TextXAlignment.Left
ChatTitle.Parent = ChatHeader

-- Scrolling area
local ChatScroll = Instance.new("ScrollingFrame")
ChatScroll.Position = UDim2.new(0, 9, 0, 35)
ChatScroll.Size = UDim2.new(1, -18, 1, -44)
ChatScroll.BackgroundTransparency = 1
ChatScroll.BorderSizePixel = 0
ChatScroll.ScrollBarThickness = 3
ChatScroll.ScrollBarImageColor3 = Color3.fromRGB(67, 72, 88)
ChatScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ChatScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ChatScroll.Parent = ChatFrame

local ChatLayout = Instance.new("UIListLayout")
ChatLayout.Padding = UDim.new(0, 8)
ChatLayout.SortOrder = Enum.SortOrder.LayoutOrder
ChatLayout.Parent = ChatScroll

--==================================================
-- MESSAGE LOGIC
--==================================================

local function AddMessage(author, content, isOwn)

    local Message = Instance.new("Frame")
    Message.AutomaticSize = Enum.AutomaticSize.Y
    Message.Size = UDim2.new(1, -4, 0, 58)
    Message.BackgroundColor3 =
        isOwn and C.OwnMessage or C.OtherMessage
    Message.BorderSizePixel = 0
    Message.Parent = ChatScroll

    Corner(Message, 11)
    Stroke(
        Message,
        isOwn
        and Color3.fromRGB(43, 78, 64)
        or Color3.fromRGB(43, 47, 60),
        0.55,
        1
    )

    -- Author
    local Author = Instance.new("TextLabel")
    Author.BackgroundTransparency = 1
    Author.Position = UDim2.new(0, 13, 0, 9)
    Author.Size = UDim2.new(1, -68, 0, 19)
    Author.Font = Enum.Font.GothamBold
    Author.Text = tostring(author)
    Author.TextColor3 =
        isOwn
        and Color3.fromRGB(105, 225, 160)
        or Color3.fromRGB(125, 175, 255)
    Author.TextSize = 12
    Author.TextXAlignment = Enum.TextXAlignment.Left
    Author.Parent = Message

    --==================================================
    -- PROFESSIONAL CLIPBOARD BUTTON
    --==================================================

    local Clipboard = Instance.new("TextButton")
    Clipboard.Size = UDim2.new(0, 32, 0, 32)
    Clipboard.Position = UDim2.new(1, -43, 0, 7)
    Clipboard.BackgroundColor3 = Color3.fromRGB(33, 37, 48)
    Clipboard.BorderSizePixel = 0
    Clipboard.Text = ""
    Clipboard.AutoButtonColor = false
    Clipboard.Parent = Message

    Corner(Clipboard, 9)
    Stroke(Clipboard, C.Border, 0.55, 1)

    -- clipboard body
    local ClipBody = Instance.new("Frame")
    ClipBody.Size = UDim2.new(0, 13, 0, 16)
    ClipBody.Position = UDim2.new(0.5, -6.5, 0.5, -7)
    ClipBody.BackgroundTransparency = 1
    ClipBody.BorderSizePixel = 0
    ClipBody.Parent = Clipboard

    local ClipOutline = Instance.new("UIStroke")
    ClipOutline.Color = Color3.fromRGB(195, 201, 215)
    ClipOutline.Thickness = 1.5
    ClipOutline.Parent = ClipBody

    Corner(ClipBody, 2)

    -- clipboard top clip
    local ClipTop = Instance.new("Frame")
    ClipTop.Size = UDim2.new(0, 7, 0, 4)
    ClipTop.Position = UDim2.new(0.5, -3.5, 0, -2)
    ClipTop.BackgroundColor3 = Color3.fromRGB(195, 201, 215)
    ClipTop.BorderSizePixel = 0
    ClipTop.Parent = ClipBody

    Corner(ClipTop, 2)

    -- copy lines
    for i = 1, 2 do
        local Line = Instance.new("Frame")
        Line.Size = UDim2.new(0, 7, 0, 1)
        Line.Position = UDim2.new(0, 3, 0, 7 + ((i - 1) * 4))
        Line.BackgroundColor3 = Color3.fromRGB(130, 137, 152)
        Line.BorderSizePixel = 0
        Line.Parent = ClipBody
    end

    Clipboard.MouseEnter:Connect(function()
        Tween(Clipboard, {
            BackgroundColor3 = Color3.fromRGB(47, 52, 66)
        }, 0.12):Play()
    end)

    Clipboard.MouseLeave:Connect(function()
        Tween(Clipboard, {
            BackgroundColor3 = Color3.fromRGB(33, 37, 48)
        }, 0.12):Play()
    end)

    --==================================================
    -- MESSAGE CONTENT
    --==================================================

    local Content = Instance.new("TextLabel")
    Content.BackgroundTransparency = 1
    Content.Position = UDim2.new(0, 13, 0, 32)
    Content.Size = UDim2.new(1, -26, 0, 0)
    Content.AutomaticSize = Enum.AutomaticSize.Y
    Content.Font = Enum.Font.Gotham
    Content.Text = tostring(content)
    Content.TextColor3 = Color3.fromRGB(225, 228, 236)
    Content.TextSize = 14
    Content.TextWrapped = true
    Content.TextXAlignment = Enum.TextXAlignment.Left
    Content.TextYAlignment = Enum.TextYAlignment.Top
    Content.Parent = Message

    local Padding = Instance.new("UIPadding")
    Padding.PaddingBottom = UDim.new(0, 13)
    Padding.Parent = Message

    --==================================================
    -- COPY ACTION
    --==================================================

    Clipboard.MouseButton1Click:Connect(function()

        if CopyToClipboard(content) then

            -- hide icon
            ClipBody.Visible = false

            local Check = Instance.new("TextLabel")
            Check.BackgroundTransparency = 1
            Check.Size = UDim2.new(1, 0, 1, 0)
            Check.Font = Enum.Font.GothamBold
            Check.Text = "✓"
            Check.TextColor3 = C.Green
            Check.TextSize = 17
            Check.Parent = Clipboard

            Tween(Clipboard, {
                BackgroundColor3 = Color3.fromRGB(28, 57, 45)
            }, 0.12):Play()

            task.delay(1.2, function()
                if Clipboard.Parent then
                    if Check then
                        Check:Destroy()
                    end

                    ClipBody.Visible = true

                    Tween(Clipboard, {
                        BackgroundColor3 = Color3.fromRGB(33, 37, 48)
                    }, 0.12):Play()
                end
            end)

        else

            ClipBody.Visible = false

            local Error = Instance.new("TextLabel")
            Error.BackgroundTransparency = 1
            Error.Size = UDim2.new(1, 0, 1, 0)
            Error.Font = Enum.Font.GothamBold
            Error.Text = "!"
            Error.TextColor3 = C.Red
            Error.TextSize = 17
            Error.Parent = Clipboard

            task.delay(1.2, function()
                if Clipboard.Parent then
                    if Error then
                        Error:Destroy()
                    end

                    ClipBody.Visible = true
                end
            end)
        end
    end)
end

--==================================================
-- INPUT AREA
--==================================================

local InputFrame = Instance.new("Frame")
InputFrame.Position = UDim2.new(0, 15, 1, -65)
InputFrame.Size = UDim2.new(1, -30, 0, 50)
InputFrame.BackgroundColor3 = C.Surface
InputFrame.BorderSizePixel = 0
InputFrame.Parent = Main

Corner(InputFrame, 12)
Stroke(InputFrame, C.Border, 0.4, 1)

-- Input icon
local InputIcon = Instance.new("TextLabel")
InputIcon.BackgroundTransparency = 1
InputIcon.Position = UDim2.new(0, 12, 0, 0)
InputIcon.Size = UDim2.new(0, 25, 1, 0)
InputIcon.Font = Enum.Font.GothamBold
InputIcon.Text = "›"
InputIcon.TextColor3 = C.TextDim
InputIcon.TextSize = 25
InputIcon.Parent = InputFrame

local Input = Instance.new("TextBox")
Input.BackgroundTransparency = 1
Input.Position = UDim2.new(0, 34, 0, 0)
Input.Size = UDim2.new(1, -122, 1, 0)
Input.Font = Enum.Font.Gotham
Input.PlaceholderText = "Type a message..."
Input.PlaceholderColor3 = C.TextDim
Input.Text = ""
Input.TextColor3 = C.Text
Input.TextSize = 14
Input.TextXAlignment = Enum.TextXAlignment.Left
Input.ClearTextOnFocus = false
Input.Parent = InputFrame

--==================================================
-- SEND BUTTON
--==================================================

local SendButton = Instance.new("TextButton")
SendButton.Position = UDim2.new(1, -93, 0, 6)
SendButton.Size = UDim2.new(0, 87, 0, 38)
SendButton.BackgroundColor3 = C.Accent
SendButton.BorderSizePixel = 0
SendButton.Text = ""
SendButton.AutoButtonColor = false
SendButton.Parent = InputFrame

Corner(SendButton, 9)

-- Send text
local SendText = Instance.new("TextLabel")
SendText.BackgroundTransparency = 1
SendText.Position = UDim2.new(0, 8, 0, 0)
SendText.Size = UDim2.new(1, -25, 1, 0)
SendText.Font = Enum.Font.GothamBold
SendText.Text = "SEND"
SendText.TextColor3 = Color3.fromRGB(255, 255, 255)
SendText.TextSize = 11
SendText.Parent = SendButton

-- Send arrow
local SendArrow = Instance.new("TextLabel")
SendArrow.BackgroundTransparency = 1
SendArrow.Position = UDim2.new(1, -24, 0, 0)
SendArrow.Size = UDim2.new(0, 20, 1, 0)
SendArrow.Font = Enum.Font.GothamBold
SendArrow.Text = "›"
SendArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
SendArrow.TextSize = 20
SendArrow.Parent = SendButton

MakeButtonHover(
    SendButton,
    C.Accent,
    C.AccentHover
)

--==================================================
-- MINI RESTORE BUTTON
--==================================================

local MiniButton = Instance.new("TextButton")
MiniButton.Size = UDim2.new(0, 58, 0, 58)
MiniButton.Position = UDim2.new(0, 20, 0.5, -29)
MiniButton.BackgroundColor3 = C.Surface
MiniButton.BorderSizePixel = 0
MiniButton.Text = ""
MiniButton.Visible = false
MiniButton.AutoButtonColor = false
MiniButton.Parent = ScreenGui

Corner(MiniButton, 18)
Stroke(MiniButton, C.Border, 0.2, 1)

-- Mini icon
local MiniIcon = Instance.new("Frame")
MiniIcon.Size = UDim2.new(0, 25, 0, 20)
MiniIcon.Position = UDim2.new(0.5, -12.5, 0.5, -11)
MiniIcon.BackgroundColor3 = C.Accent
MiniIcon.BorderSizePixel = 0
MiniIcon.Parent = MiniButton

Corner(MiniIcon, 7)

local MiniDot1 = Instance.new("Frame")
MiniDot1.Size = UDim2.new(0, 4, 0, 4)
MiniDot1.Position = UDim2.new(0, 5, 0.5, -2)
MiniDot1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MiniDot1.BorderSizePixel = 0
MiniDot1.Parent = MiniIcon
Corner(MiniDot1, 4)

local MiniDot2 = MiniDot1:Clone()
MiniDot2.Position = UDim2.new(1, -9, 0.5, -2)
MiniDot2.Parent = MiniIcon

MakeButtonHover(
    MiniButton,
    C.Surface,
    C.Surface3
)

--==================================================
-- DRAG SYSTEM
--==================================================

local dragging, dragStart, startPos

TopBar.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = Main.Position

        input.Changed:Connect(function()

            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end

        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)

    if dragging
        and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then

        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

--==================================================
-- SEND MESSAGE METHOD
--==================================================

local Sending = false

local function SendMessage()

    if Sending then
        return
    end

    local Message = Input.Text

    if not Message or Message:match("^%s*$") then
        return
    end

    Sending = true
    SendText.Text = "..."
    SendArrow.Visible = false

    task.spawn(function()

        local payload = HttpService:JSONEncode({
            username = Player.Name,
            message = Message
        })

        local success, response = pcall(function()

            return httpRequest({
                Url = SERVER_URL .. "/send-to-discord",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = payload
            })

        end)

        if success
            and response
            and tonumber(response.StatusCode) == 200 then

            AddMessage(
                Player.Name,
                Message,
                true
            )

            Input.Text = ""

            StatusDot.BackgroundColor3 = C.Green
            StatusGlow.BackgroundColor3 = C.Green
            StatusText.Text = "Connected  •  Message sent"

        else

            StatusDot.BackgroundColor3 = C.Red
            StatusGlow.BackgroundColor3 = C.Red
            StatusText.Text = "Send failed"

        end

        SendText.Text = "SEND"
        SendArrow.Visible = true
        Sending = false

    end)
end

SendButton.MouseButton1Click:Connect(SendMessage)

Input.FocusLost:Connect(function(enter)

    if enter then
        SendMessage()
    end

end)

--==================================================
-- RECEIVE SYSTEM
--==================================================

local LastMessageID = nil
local FirstFetch = true

local function FetchDiscordMessage()

    task.spawn(function()

        local success, response = pcall(function()

            return httpRequest({
                Url = SERVER_URL .. "/get-from-discord",
                Method = "GET"
            })

        end)

        if success
            and response
            and tonumber(response.StatusCode) == 200 then

            local ok, data = pcall(function()

                return HttpService:JSONDecode(
                    response.Body
                )

            end)

            if ok
                and type(data) == "table"
                and data.author
                and data.content then

                StatusDot.BackgroundColor3 = C.Green
                StatusGlow.BackgroundColor3 = C.Green
                StatusText.Text = "Connected  •  Auto Sync"

                if data.id ~= LastMessageID then

                    LastMessageID = data.id

                    if not FirstFetch then

                        AddMessage(
                            data.author,
                            data.content,
                            false
                        )

                    end

                    FirstFetch = false
                end
            end

        else

            StatusDot.BackgroundColor3 = C.Red
            StatusGlow.BackgroundColor3 = C.Red
            StatusText.Text = "Server connection offline"

        end
    end)
end

--==================================================
-- THREAD LOOP
--==================================================

task.spawn(function()

    while ScreenGui.Parent do

        FetchDiscordMessage()

        task.wait(POLL_INTERVAL)

    end

end)

--==================================================
-- WINDOW STATE
--==================================================

Minimize.MouseButton1Click:Connect(function()

    Main.Visible = false
    MiniButton.Visible = true

end)

MiniButton.MouseButton1Click:Connect(function()

    MiniButton.Visible = false
    Main.Visible = true

end)

Close.MouseButton1Click:Connect(function()

    ScreenGui:Destroy()

end)

--==================================================
-- OPEN ANIMATION
--==================================================

Main.Size = UDim2.new(
    0,
    WindowWidth - 25,
    0,
    WindowHeight - 25
)

Main.Position = UDim2.new(
    0.5,
    -(WindowWidth - 25) / 2,
    0.5,
    -(WindowHeight - 25) / 2
)

Tween(
    Main,
    {
        Size = UDim2.new(0, WindowWidth, 0, WindowHeight),
        Position = UDim2.new(
            0.5,
            -WindowWidth / 2,
            0.5,
            -WindowHeight / 2
        )
    },
    0.25
):Play()
```
