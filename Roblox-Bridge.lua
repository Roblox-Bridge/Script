```lua
--==================================================
-- ROBLOX ↔ DISCORD BRIDGE
-- ADVANCED MOBILE UI + CLIPBOARD
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

local httpRequest =
    (syn and syn.request)
    or (http and http.request)
    or http_request
    or request

if not httpRequest then
    warn("HTTP request function is not available.")
    return
end

--==================================================
-- CLIPBOARD FUNCTION
--==================================================

local function CopyToClipboard(text)

    local clipboardFunction =
        setclipboard
        or toclipboard
        or (syn and syn.write_clipboard)

    if not clipboardFunction then
        return false
    end

    local success = pcall(function()
        clipboardFunction(text)
    end)

    return success
end

--==================================================
-- CLEAN OLD UI
--==================================================

local OldGui = PlayerGui:FindFirstChild("DiscordBridgeUI")

if OldGui then
    OldGui:Destroy()
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
-- MAIN WINDOW
--==================================================

local Main = Instance.new("Frame")
Main.Name = "MainWindow"
Main.Size = UDim2.new(0, 500, 0, 430)
Main.Position = UDim2.new(0.5, -250, 0.5, -215)
Main.BackgroundColor3 = Color3.fromRGB(18, 20, 27)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

--==================================================
-- TOP BAR
--==================================================

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 62)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 28, 37)
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 14)
TopCorner.Parent = TopBar

local TopCover = Instance.new("Frame")
TopCover.Size = UDim2.new(1, 0, 0, 18)
TopCover.Position = UDim2.new(0, 0, 1, -18)
TopCover.BackgroundColor3 = Color3.fromRGB(25, 28, 37)
TopCover.BorderSizePixel = 0
TopCover.Parent = TopBar

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 18, 0, 8)
Title.Size = UDim2.new(0, 300, 0, 27)
Title.Font = Enum.Font.GothamBold
Title.Text = "Discord Bridge"
Title.TextColor3 = Color3.fromRGB(245, 245, 250)
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.new(0, 19, 0, 36)
Subtitle.Size = UDim2.new(0, 300, 0, 19)
Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "Roblox  ↔  Discord"
Subtitle.TextColor3 = Color3.fromRGB(150, 155, 170)
Subtitle.TextSize = 13
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = TopBar

--==================================================
-- WINDOW BUTTONS
--==================================================

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 45, 0, 42)
Minimize.Position = UDim2.new(1, -96, 0, 10)
Minimize.BackgroundTransparency = 1
Minimize.Text = "−"
Minimize.Font = Enum.Font.GothamBold
Minimize.TextSize = 28
Minimize.TextColor3 = Color3.fromRGB(195, 200, 210)
Minimize.AutoButtonColor = false
Minimize.Parent = TopBar

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 45, 0, 42)
Close.Position = UDim2.new(1, -48, 0, 10)
Close.BackgroundTransparency = 1
Close.Text = "×"
Close.Font = Enum.Font.GothamMedium
Close.TextSize = 29
Close.TextColor3 = Color3.fromRGB(235, 100, 105)
Close.AutoButtonColor = false
Close.Parent = TopBar

--==================================================
-- STATUS
--==================================================

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 10, 0, 10)
StatusDot.Position = UDim2.new(0, 20, 0, 76)
StatusDot.BackgroundColor3 = Color3.fromRGB(255, 190, 70)
StatusDot.BorderSizePixel = 0
StatusDot.Parent = Main

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(1, 0)
StatusCorner.Parent = StatusDot

local StatusText = Instance.new("TextLabel")
StatusText.BackgroundTransparency = 1
StatusText.Position = UDim2.new(0, 37, 0, 69)
StatusText.Size = UDim2.new(1, -55, 0, 25)
StatusText.Font = Enum.Font.GothamMedium
StatusText.Text = "Connecting..."
StatusText.TextColor3 = Color3.fromRGB(175, 180, 190)
StatusText.TextSize = 14
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = Main

--==================================================
-- CHAT AREA
--==================================================

local ChatFrame = Instance.new("Frame")
ChatFrame.Position = UDim2.new(0, 16, 0, 103)
ChatFrame.Size = UDim2.new(1, -32, 0, 215)
ChatFrame.BackgroundColor3 = Color3.fromRGB(13, 15, 21)
ChatFrame.BorderSizePixel = 0
ChatFrame.Parent = Main

local ChatCorner = Instance.new("UICorner")
ChatCorner.CornerRadius = UDim.new(0, 10)
ChatCorner.Parent = ChatFrame

local ChatScroll = Instance.new("ScrollingFrame")
ChatScroll.Position = UDim2.new(0, 10, 0, 10)
ChatScroll.Size = UDim2.new(1, -20, 1, -20)
ChatScroll.BackgroundTransparency = 1
ChatScroll.BorderSizePixel = 0
ChatScroll.ScrollBarThickness = 5
ChatScroll.ScrollBarImageTransparency = 0.25
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
    Message.Size = UDim2.new(1, -5, 0, 0)

    Message.BackgroundColor3 =
        isOwn
        and Color3.fromRGB(31, 55, 47)
        or Color3.fromRGB(28, 31, 40)

    Message.BorderSizePixel = 0
    Message.Parent = ChatScroll

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 9)
    Corner.Parent = Message

    --==================================================
    -- AUTHOR
    --==================================================

    local Author = Instance.new("TextLabel")
    Author.BackgroundTransparency = 1
    Author.Position = UDim2.new(0, 12, 0, 8)
    Author.Size = UDim2.new(1, -70, 0, 21)
    Author.Font = Enum.Font.GothamBold
    Author.Text = tostring(author)

    Author.TextColor3 =
        isOwn
        and Color3.fromRGB(100, 220, 160)
        or Color3.fromRGB(120, 175, 255)

    Author.TextSize = 14
    Author.TextXAlignment = Enum.TextXAlignment.Left
    Author.Parent = Message

    --==================================================
    -- CLIPBOARD BUTTON
    --==================================================

    local Clipboard = Instance.new("TextButton")
    Clipboard.Size = UDim2.new(0, 34, 0, 30)
    Clipboard.Position = UDim2.new(1, -44, 0, 5)
    Clipboard.BackgroundColor3 = Color3.fromRGB(42, 46, 58)
    Clipboard.BorderSizePixel = 0
    Clipboard.Text = "📋"
    Clipboard.TextSize = 16
    Clipboard.Font = Enum.Font.GothamBold
    Clipboard.TextColor3 = Color3.fromRGB(220, 225, 235)
    Clipboard.AutoButtonColor = false
    Clipboard.Parent = Message

    local ClipboardCorner = Instance.new("UICorner")
    ClipboardCorner.CornerRadius = UDim.new(0, 7)
    ClipboardCorner.Parent = Clipboard

    --==================================================
    -- MESSAGE CONTENT
    --==================================================

    local Content = Instance.new("TextLabel")
    Content.BackgroundTransparency = 1
    Content.Position = UDim2.new(0, 12, 0, 32)
    Content.Size = UDim2.new(1, -24, 0, 0)
    Content.AutomaticSize = Enum.AutomaticSize.Y
    Content.Font = Enum.Font.Gotham
    Content.Text = tostring(content)
    Content.TextColor3 = Color3.fromRGB(230, 232, 238)
    Content.TextSize = 16
    Content.TextWrapped = true
    Content.TextXAlignment = Enum.TextXAlignment.Left
    Content.TextYAlignment = Enum.TextYAlignment.Top
    Content.Parent = Message

    local Padding = Instance.new("UIPadding")
    Padding.PaddingBottom = UDim.new(0, 11)
    Padding.Parent = Message

    --==================================================
    -- CLIPBOARD CLICK
    --==================================================

    Clipboard.MouseButton1Click:Connect(function()

        local copied = CopyToClipboard(tostring(content))

        if copied then

            Clipboard.Text = "✓"

            StatusDot.BackgroundColor3 =
                Color3.fromRGB(80, 210, 130)

            StatusText.Text = "Copied to clipboard"

            task.delay(1.2, function()

                if Clipboard and Clipboard.Parent then
                    Clipboard.Text = "📋"
                end

            end)

        else

            Clipboard.Text = "!"

            StatusDot.BackgroundColor3 =
                Color3.fromRGB(235, 85, 90)

            StatusText.Text =
                "Clipboard not supported"

            task.delay(1.2, function()

                if Clipboard and Clipboard.Parent then
                    Clipboard.Text = "📋"
                end

            end)

        end
    end)

    --==================================================
    -- SCROLL TO BOTTOM
    --==================================================

    task.defer(function()

        ChatScroll.CanvasPosition =
            Vector2.new(
                0,
                math.max(
                    0,
                    ChatScroll.AbsoluteCanvasSize.Y
                )
            )

    end)
end

--==================================================
-- INPUT
--==================================================

local InputFrame = Instance.new("Frame")
InputFrame.Position = UDim2.new(0, 16, 0, 328)
InputFrame.Size = UDim2.new(1, -32, 0, 56)
InputFrame.BackgroundColor3 = Color3.fromRGB(27, 30, 39)
InputFrame.BorderSizePixel = 0
InputFrame.Parent = Main

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 10)
InputCorner.Parent = InputFrame

local Input = Instance.new("TextBox")
Input.BackgroundTransparency = 1
Input.Position = UDim2.new(0, 15, 0, 0)
Input.Size = UDim2.new(1, -120, 1, 0)
Input.Font = Enum.Font.Gotham
Input.PlaceholderText = "Type a message..."
Input.PlaceholderColor3 = Color3.fromRGB(115, 120, 135)
Input.Text = ""
Input.TextColor3 = Color3.fromRGB(235, 238, 245)
Input.TextSize = 16
Input.ClearTextOnFocus = false
Input.TextXAlignment = Enum.TextXAlignment.Left
Input.Parent = InputFrame

local SendButton = Instance.new("TextButton")
SendButton.Position = UDim2.new(1, -98, 0, 7)
SendButton.Size = UDim2.new(0, 88, 0, 42)
SendButton.BackgroundColor3 = Color3.fromRGB(70, 110, 220)
SendButton.BorderSizePixel = 0
SendButton.Text = "SEND"
SendButton.Font = Enum.Font.GothamBold
SendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SendButton.TextSize = 14
SendButton.AutoButtonColor = false
SendButton.Parent = InputFrame

local SendCorner = Instance.new("UICorner")
SendCorner.CornerRadius = UDim.new(0, 8)
SendCorner.Parent = SendButton

--==================================================
-- FOOTER
--==================================================

local Footer = Instance.new("TextLabel")
Footer.BackgroundTransparency = 1
Footer.Position = UDim2.new(0, 18, 1, -34)
Footer.Size = UDim2.new(1, -36, 0, 20)
Footer.Font = Enum.Font.Gotham
Footer.Text = "Auto-sync enabled"
Footer.TextColor3 = Color3.fromRGB(110, 115, 130)
Footer.TextSize = 12
Footer.TextXAlignment = Enum.TextXAlignment.Left
Footer.Parent = Main

--==================================================
-- MINIMIZED BUTTON
--==================================================

local MiniButton = Instance.new("TextButton")
MiniButton.Name = "MiniButton"
MiniButton.Size = UDim2.new(0, 62, 0, 62)
MiniButton.Position = UDim2.new(0, 20, 0.5, -31)
MiniButton.BackgroundColor3 = Color3.fromRGB(25, 28, 37)
MiniButton.BorderSizePixel = 0
MiniButton.Text = "💬"
MiniButton.TextSize = 27
MiniButton.Visible = false
MiniButton.Parent = ScreenGui

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(1, 0)
MiniCorner.Parent = MiniButton

--==================================================
-- DRAG SYSTEM
--==================================================

local dragging = false
local dragStart
local startPos

local function MakeDraggable(object)

    object.InputBegan:Connect(function(input)

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
end

MakeDraggable(TopBar)

--==================================================
-- SEND
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
    SendButton.BackgroundColor3 =
        Color3.fromRGB(55, 65, 90)

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

        local statusCode =
            tonumber(response.StatusCode)

        if statusCode == 200 then

            AddMessage(
                Player.Name,
                Message,
                true
            )

            Input.Text = ""

            StatusDot.BackgroundColor3 =
                Color3.fromRGB(80, 210, 130)

            StatusText.Text =
                "Connected • Message sent"

        else

            StatusDot.BackgroundColor3 =
                Color3.fromRGB(235, 85, 90)

            StatusText.Text =
                "Send failed (" ..
                tostring(statusCode) ..
                ")"
        end

    else

        StatusDot.BackgroundColor3 =
            Color3.fromRGB(235, 85, 90)

        StatusText.Text =
            "Connection error"
    end

    SendButton.Text = "SEND"

    SendButton.BackgroundColor3 =
        Color3.fromRGB(70, 110, 220)

    Sending = false
end

SendButton.MouseButton1Click:Connect(SendMessage)

Input.FocusLost:Connect(function(enterPressed)

    if enterPressed then
        SendMessage()
    end

end)

--==================================================
-- RECEIVE
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

        StatusDot.BackgroundColor3 =
            Color3.fromRGB(235, 85, 90)

        StatusText.Text =
            "Connection failed"

        return
    end

    local statusCode =
        tonumber(response.StatusCode)

    if statusCode ~= 200 then

        StatusDot.BackgroundColor3 =
            Color3.fromRGB(235, 85, 90)

        StatusText.Text =
            "Server error (" ..
            tostring(statusCode) ..
            ")"

        return
    end

    local decodedSuccess, data =
        pcall(function()

            return HttpService:JSONDecode(
                response.Body
            )

        end)

    if not decodedSuccess or not data then

        StatusDot.BackgroundColor3 =
            Color3.fromRGB(235, 85, 90)

        StatusText.Text =
            "Invalid server response"

        return
    end

    StatusDot.BackgroundColor3 =
        Color3.fromRGB(80, 210, 130)

    StatusText.Text =
        "Connected • Auto Sync"

    if not data.author or
       not data.content then

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
-- AUTOMATIC POLLING
--==================================================

task.spawn(function()

    while ScreenGui.Parent do

        FetchDiscordMessage()

        task.wait(POLL_INTERVAL)

    end

end)

--==================================================
-- MINIMIZE
--==================================================

Minimize.MouseButton1Click:Connect(function()

    Main.Visible = false
    MiniButton.Visible = true

end)

--==================================================
-- RESTORE
--==================================================

MiniButton.MouseButton1Click:Connect(function()

    MiniButton.Visible = false
    Main.Visible = true

end)

--==================================================
-- CLOSE / DESTROY
--==================================================

Close.MouseButton1Click:Connect(function()

    ScreenGui:Destroy()

end)

--==================================================
-- BUTTON EFFECTS
--==================================================

SendButton.MouseEnter:Connect(function()

    TweenService:Create(
        SendButton,
        TweenInfo.new(0.15),
        {
            BackgroundColor3 =
                Color3.fromRGB(85, 125, 235)
        }
    ):Play()

end)

SendButton.MouseLeave:Connect(function()

    TweenService:Create(
        SendButton,
        TweenInfo.new(0.15),
        {
            BackgroundColor3 =
                Color3.fromRGB(70, 110, 220)
        }
    ):Play()

end)

Close.MouseEnter:Connect(function()

    Close.TextColor3 =
        Color3.fromRGB(255, 70, 75)

end)

Close.MouseLeave:Connect(function()

    Close.TextColor3 =
        Color3.fromRGB(235, 100, 105)

end)

Minimize.MouseEnter:Connect(function()

    Minimize.TextColor3 =
        Color3.fromRGB(255, 255, 255)

end)

Minimize.MouseLeave:Connect(function()

    Minimize.TextColor3 =
        Color3.fromRGB(195, 200, 210)

end)

--==================================================
-- START
--==================================================

StatusText.Text =
    "Connecting to Railway..."
```
