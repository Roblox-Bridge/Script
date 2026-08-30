--==================================================
-- ROBLOX ↔ DISCORD BRIDGE (UI IMPROVED - MOBILE FIRST)
--==================================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--==================================================
-- CONFIG (UNCHANGED)
--==================================================

local SERVER_URL = "https://roblox-bridge-production.up.railway.app"
local POLL_INTERVAL = 3

--==================================================
-- HTTP REQUEST (UNCHANGED)
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
-- SAFE CLIPBOARD (UNCHANGED)
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

    local ok = pcall(function()
        fn(tostring(text))
    end)

    return ok
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
-- MOBILE RESPONSIVE SIZING
--==================================================

local Camera = workspace.CurrentCamera
local Viewport = Camera and Camera.ViewportSize or Vector2.new(800, 600)
local IsSmallScreen = Viewport.X < 600 or Viewport.Y < 500

local WindowWidth
local WindowHeight

if IsSmallScreen then
    WindowWidth = math.min(Viewport.X - 24, 380)
    WindowHeight = math.min(Viewport.Y - 32, 390)
else
    WindowWidth = 460
    WindowHeight = 410
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
Main.BackgroundColor3 = Color3.fromRGB(15, 17, 23)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 40, 55)
MainStroke.Thickness = 1
MainStroke.Parent = Main

--==================================================
-- TOP BAR
--==================================================

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 54)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 25, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 16)
TopCorner.Parent = TopBar

local TopCover = Instance.new("Frame")
TopCover.Size = UDim2.new(1, 0, 0, 14)
TopCover.Position = UDim2.new(0, 0, 1, -14)
TopCover.BackgroundColor3 = Color3.fromRGB(22, 25, 35)
TopCover.BorderSizePixel = 0
TopCover.Parent = TopBar

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 16, 0, 10)
Title.Size = UDim2.new(0, 200, 0, 20)
Title.Font = Enum.Font.GothamBold
Title.Text = "Discord Bridge"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = IsSmallScreen and 16 or 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.new(0, 16, 0, 30)
Subtitle.Size = UDim2.new(0, 200, 0, 16)
Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "Roblox ↔ Discord"
Subtitle.TextColor3 = Color3.fromRGB(120, 128, 150)
Subtitle.TextSize = IsSmallScreen and 11 or 12
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = TopBar

--==================================================
-- MINIMIZE / CLOSE
--==================================================

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 36, 0, 36)
Minimize.Position = UDim2.new(1, -80, 0, 9)
Minimize.BackgroundColor3 = Color3.fromRGB(30, 35, 48)
Minimize.Text = "−"
Minimize.Font = Enum.Font.GothamBold
Minimize.TextSize = 20
Minimize.TextColor3 = Color3.fromRGB(180, 188, 208)
Minimize.AutoButtonColor = true
Minimize.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = Minimize

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 36, 0, 36)
Close.Position = UDim2.new(1, -42, 0, 9)
Close.BackgroundColor3 = Color3.fromRGB(45, 25, 30)
Close.Text = "✕"
Close.Font = Enum.Font.GothamBold
Close.TextSize = 14
Close.TextColor3 = Color3.fromRGB(255, 110, 115)
Close.AutoButtonColor = true
Close.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = Close

--==================================================
-- STATUS
--==================================================

local StatusContainer = Instance.new("Frame")
StatusContainer.Position = UDim2.new(0, 14, 0, 62)
StatusContainer.Size = UDim2.new(1, -28, 0, 22)
StatusContainer.BackgroundTransparency = 1
StatusContainer.Parent = Main

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 2, 0.5, -4)
StatusDot.BackgroundColor3 = Color3.fromRGB(255, 190, 70)
StatusDot.BorderSizePixel = 0
StatusDot.Parent = StatusContainer

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(1, 0)
StatusCorner.Parent = StatusDot

local StatusText = Instance.new("TextLabel")
StatusText.BackgroundTransparency = 1
StatusText.Position = UDim2.new(0, 16, 0, 0)
StatusText.Size = UDim2.new(1, -20, 1, 0)
StatusText.Font = Enum.Font.GothamMedium
StatusText.Text = "Connecting..."
StatusText.TextColor3 = Color3.fromRGB(150, 158, 175)
StatusText.TextSize = IsSmallScreen and 11 or 12
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = StatusContainer

--==================================================
-- CHAT AREA
--==================================================

local ChatFrame = Instance.new("Frame")
ChatFrame.Position = UDim2.new(0, 14, 0, 88)
ChatFrame.Size = UDim2.new(1, -28, 1, -145)
ChatFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
ChatFrame.BorderSizePixel = 0
ChatFrame.Parent = Main

local ChatCorner = Instance.new("UICorner")
ChatCorner.CornerRadius = UDim.new(0, 12)
ChatCorner.Parent = ChatFrame

local ChatStroke = Instance.new("UIStroke")
ChatStroke.Color = Color3.fromRGB(25, 28, 38)
ChatStroke.Thickness = 1
ChatStroke.Parent = ChatFrame

local ChatScroll = Instance.new("ScrollingFrame")
ChatScroll.Position = UDim2.new(0, 8, 0, 8)
ChatScroll.Size = UDim2.new(1, -16, 1, -16)
ChatScroll.BackgroundTransparency = 1
ChatScroll.BorderSizePixel = 0
ChatScroll.ScrollBarThickness = 3
ChatScroll.ScrollBarImageColor3 = Color3.fromRGB(50, 55, 70)
ChatScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ChatScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ChatScroll.Parent = ChatFrame

local ChatLayout = Instance.new("UIListLayout")
ChatLayout.Padding = UDim.new(0, 8)
ChatLayout.SortOrder = Enum.SortOrder.LayoutOrder
ChatLayout.Parent = ChatScroll

--==================================================
-- ADD MESSAGE
--==================================================

local function AddMessage(author, content, isOwn)

    local Message = Instance.new("Frame")
    Message.AutomaticSize = Enum.AutomaticSize.Y
    Message.Size = UDim2.new(1, -4, 0, 0)
    Message.BackgroundColor3 =
        isOwn
        and Color3.fromRGB(20, 42, 35)
        or Color3.fromRGB(20, 24, 33)

    Message.BorderSizePixel = 0
    Message.Parent = ChatScroll

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Message

    local MsgStroke = Instance.new("UIStroke")
    MsgStroke.Color = isOwn and Color3.fromRGB(35, 75, 60) or Color3.fromRGB(32, 38, 52)
    MsgStroke.Thickness = 1
    MsgStroke.Parent = Message

    -- AUTHOR

    local Author = Instance.new("TextLabel")
    Author.BackgroundTransparency = 1
    Author.Position = UDim2.new(0, 10, 0, 6)
    Author.Size = UDim2.new(1, -55, 0, 18)
    Author.Font = Enum.Font.GothamBold
    Author.Text = tostring(author)
    Author.TextColor3 =
        isOwn
        and Color3.fromRGB(90, 220, 160)
        or Color3.fromRGB(110, 170, 255)
    Author.TextSize = IsSmallScreen and 12 or 13
    Author.TextXAlignment = Enum.TextXAlignment.Left
    Author.Parent = Message

    -- CLIPBOARD BUTTON (MODERNIZED SYMBOL)

    local Clipboard = Instance.new("TextButton")
    Clipboard.Size = UDim2.new(0, 28, 0, 26)
    Clipboard.Position = UDim2.new(1, -34, 0, 6)
    Clipboard.BackgroundColor3 = Color3.fromRGB(30, 36, 48)
    Clipboard.BorderSizePixel = 0
    Clipboard.Text = "⎘"
    Clipboard.TextSize = 14
    Clipboard.Font = Enum.Font.GothamBold
    Clipboard.TextColor3 = Color3.fromRGB(180, 190, 210)
    Clipboard.AutoButtonColor = true
    Clipboard.Parent = Message

    local ClipboardCorner = Instance.new("UICorner")
    ClipboardCorner.CornerRadius = UDim.new(0, 6)
    ClipboardCorner.Parent = Clipboard

    -- CONTENT

    local Content = Instance.new("TextLabel")
    Content.BackgroundTransparency = 1
    Content.Position = UDim2.new(0, 10, 0, 26)
    Content.Size = UDim2.new(1, -20, 0, 0)
    Content.AutomaticSize = Enum.AutomaticSize.Y
    Content.Font = Enum.Font.Gotham
    Content.Text = tostring(content)
    Content.TextColor3 = Color3.fromRGB(230, 233, 240)
    Content.TextSize = IsSmallScreen and 13 or 14
    Content.TextWrapped = true
    Content.TextXAlignment = Enum.TextXAlignment.Left
    Content.TextYAlignment = Enum.TextYAlignment.Top
    Content.Parent = Message

    local Padding = Instance.new("UIPadding")
    Padding.PaddingBottom = UDim.new(0, 8)
    Padding.Parent = Message

    -- COPY

    Clipboard.MouseButton1Click:Connect(function()

        if CopyToClipboard(content) then

            Clipboard.Text = "✓"
            Clipboard.TextColor3 = Color3.fromRGB(90, 220, 160)

            StatusDot.BackgroundColor3 = Color3.fromRGB(80, 210, 130)
            StatusText.Text = "Copied to clipboard"

            task.delay(1.2, function()
                if Clipboard.Parent then
                    Clipboard.Text = "⎘"
                    Clipboard.TextColor3 = Color3.fromRGB(180, 190, 210)
                end
            end)

        else

            Clipboard.Text = "✕"
            Clipboard.TextColor3 = Color3.fromRGB(235, 85, 90)

            StatusDot.BackgroundColor3 = Color3.fromRGB(235, 85, 90)
            StatusText.Text = "Clipboard unsupported"

            task.delay(1.2, function()
                if Clipboard.Parent then
                    Clipboard.Text = "⎘"
                    Clipboard.TextColor3 = Color3.fromRGB(180, 190, 210)
                end
            end)

        end
    end)

    task.defer(function()
        ChatScroll.CanvasPosition =
            Vector2.new(
                0,
                math.max(0, ChatScroll.AbsoluteCanvasSize.Y)
            )
    end)
end

--==================================================
-- INPUT AREA
--==================================================

local InputFrame = Instance.new("Frame")
InputFrame.Position = UDim2.new(0, 14, 1, -50)
InputFrame.Size = UDim2.new(1, -28, 0, 40)
InputFrame.BackgroundColor3 = Color3.fromRGB(22, 25, 34)
InputFrame.BorderSizePixel = 0
InputFrame.Parent = Main

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 10)
InputCorner.Parent = InputFrame

local InputStroke = Instance.new("UIStroke")
InputStroke.Color = Color3.fromRGB(38, 44, 60)
InputStroke.Thickness = 1
InputStroke.Parent = InputFrame

local Input = Instance.new("TextBox")
Input.BackgroundTransparency = 1
Input.Position = UDim2.new(0, 12, 0, 0)
Input.Size = UDim2.new(1, -85, 1, 0)
Input.Font = Enum.Font.Gotham
Input.PlaceholderText = "Type message..."
Input.PlaceholderColor3 = Color3.fromRGB(100, 108, 125)
Input.Text = ""
Input.TextColor3 = Color3.fromRGB(240, 243, 250)
Input.TextSize = IsSmallScreen and 13 or 14
Input.ClearTextOnFocus = false
Input.TextXAlignment = Enum.TextXAlignment.Left
Input.Parent = InputFrame

local SendButton = Instance.new("TextButton")
SendButton.Position = UDim2.new(1, -68, 0, 4)
SendButton.Size = UDim2.new(0, 64, 0, 32)
SendButton.BackgroundColor3 = Color3.fromRGB(60, 100, 225)
SendButton.BorderSizePixel = 0
SendButton.Text = "SEND"
SendButton.Font = Enum.Font.GothamBold
SendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SendButton.TextSize = IsSmallScreen and 11 or 12
SendButton.AutoButtonColor = true
SendButton.Parent = InputFrame

local SendCorner = Instance.new("UICorner")
SendCorner.CornerRadius = UDim.new(0, 8)
SendCorner.Parent = SendButton

--==================================================
-- MINI BUTTON
--==================================================

local MiniButton = Instance.new("TextButton")
MiniButton.Name = "MiniButton"
MiniButton.Size = UDim2.new(0, 48, 0, 48)
MiniButton.Position = UDim2.new(0, 16, 0.5, -24)
MiniButton.BackgroundColor3 = Color3.fromRGB(22, 25, 35)
MiniButton.BorderSizePixel = 0
MiniButton.Text = "💬"
MiniButton.TextSize = 20
MiniButton.Visible = false
MiniButton.Parent = ScreenGui

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(1, 0)
MiniCorner.Parent = MiniButton

local MiniStroke = Instance.new("UIStroke")
MiniStroke.Color = Color3.fromRGB(60, 100, 225)
MiniStroke.Thickness = 1.5
MiniStroke.Parent = MiniButton

--==================================================
-- DRAG (UNCHANGED)
--==================================================

local dragging = false
local dragStart
local startPos

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

    if dragging and
        (
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
-- SEND (UNCHANGED)
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

    SendButton.Text = "..."
    SendButton.BackgroundColor3 = Color3.fromRGB(50, 60, 80)

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

    if success and response then

        local code = tonumber(response.StatusCode)

        if code == 200 then

            AddMessage(
                Player.Name,
                Message,
                true
            )

            Input.Text = ""

            StatusDot.BackgroundColor3 = Color3.fromRGB(80, 210, 130)

            StatusText.Text = "Connected • Message sent"

        else

            StatusDot.BackgroundColor3 = Color3.fromRGB(235, 85, 90)

            StatusText.Text =
                "Send failed (" ..
                tostring(code) ..
                ")"
        end

    else

        StatusDot.BackgroundColor3 = Color3.fromRGB(235, 85, 90)

        StatusText.Text = "Connection error"
    end

    SendButton.Text = "SEND"
    SendButton.BackgroundColor3 = Color3.fromRGB(60, 100, 225)

    Sending = false
end

SendButton.MouseButton1Click:Connect(SendMessage)

Input.FocusLost:Connect(function(enterPressed)

    if enterPressed then
        SendMessage()
    end

end)

--==================================================
-- RECEIVE (UNCHANGED)
--==================================================

local LastMessageID = nil
local FirstFetch = true

local function FetchDiscordMessage()

    local success, response = pcall(function()

        return httpRequest({
            Url = SERVER_URL .. "/get-from-discord",
            Method = "GET"
        })

    end)

    if not success or
       not response or
       not response.Body then

        StatusDot.BackgroundColor3 = Color3.fromRGB(235, 85, 90)

        StatusText.Text = "Connection failed"

        return
    end

    local code = tonumber(response.StatusCode)

    if code ~= 200 then

        StatusDot.BackgroundColor3 = Color3.fromRGB(235, 85, 90)

        StatusText.Text =
            "Server error (" ..
            tostring(code) ..
            ")"

        return
    end

    local ok, data = pcall(function()

        return HttpService:JSONEncode(response.Body) and HttpService:JSONDecode(response.Body)

    end)

    if not ok or type(data) ~= "table" then

        StatusDot.BackgroundColor3 = Color3.fromRGB(235, 85, 90)

        StatusText.Text = "Invalid server response"

        return
    end

    StatusDot.BackgroundColor3 = Color3.fromRGB(80, 210, 130)

    StatusText.Text = "Connected • Auto Sync"

    if not data.author or not data.content then
        return
    end

    local MessageID = data.id

    if MessageID then

        if MessageID == LastMessageID then
            return
        end

        LastMessageID = MessageID

        if FirstFetch then
            FirstFetch = false
            return
        end

        AddMessage(
            data.author,
            data.content,
            false
        )

    else

        if FirstFetch then
            FirstFetch = false
            return
        end

        AddMessage(
            data.author,
            data.content,
            false
        )
    end
end

--==================================================
-- AUTO SYNC (UNCHANGED)
--==================================================

task.spawn(function()

    while ScreenGui.Parent do

        FetchDiscordMessage()

        task.wait(POLL_INTERVAL)

    end

end)

--==================================================
-- MINIMIZE / RESTORE / CLOSE
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
-- INITIAL STATUS
--==================================================

StatusText.Text = "Connecting to Railway..."
