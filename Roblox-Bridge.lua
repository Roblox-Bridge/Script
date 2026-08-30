--==================================================
-- ROBLOX ↔ DISCORD BRIDGE
-- ADVANCED CUSTOM UI
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

local SERVER_URL = "roblox-bridge-production.up.railway.app"

local POLL_INTERVAL = 3

-- Executor HTTP request
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
-- CLEAN OLD GUI
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
Main.Size = UDim2.new(0, 520, 0, 390)
Main.Position = UDim2.new(0.5, -260, 0.5, -195)
Main.BackgroundColor3 = Color3.fromRGB(18, 20, 27)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

--==================================================
-- TOP BAR
--==================================================

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 52)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 28, 37)
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopBar

-- Cover bottom corners
local TopCover = Instance.new("Frame")
TopCover.Size = UDim2.new(1, 0, 0, 15)
TopCover.Position = UDim2.new(0, 0, 1, -15)
TopCover.BackgroundColor3 = Color3.fromRGB(25, 28, 37)
TopCover.BorderSizePixel = 0
TopCover.Parent = TopBar

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 18, 0, 7)
Title.Size = UDim2.new(0, 300, 0, 23)
Title.Font = Enum.Font.GothamBold
Title.Text = "Discord Bridge"
Title.TextColor3 = Color3.fromRGB(245, 245, 250)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.new(0, 19, 0, 29)
Subtitle.Size = UDim2.new(0, 300, 0, 16)
Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "Roblox  ↔  Discord"
Subtitle.TextColor3 = Color3.fromRGB(145, 150, 165)
Subtitle.TextSize = 11
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = TopBar

--==================================================
-- WINDOW BUTTONS
--==================================================

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 38, 0, 34)
Minimize.Position = UDim2.new(1, -84, 0, 9)
Minimize.BackgroundTransparency = 1
Minimize.Text = "−"
Minimize.Font = Enum.Font.GothamBold
Minimize.TextSize = 24
Minimize.TextColor3 = Color3.fromRGB(190, 195, 205)
Minimize.AutoButtonColor = false
Minimize.Parent = TopBar

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 38, 0, 34)
Close.Position = UDim2.new(1, -45, 0, 9)
Close.BackgroundTransparency = 1
Close.Text = "×"
Close.Font = Enum.Font.GothamMedium
Close.TextSize = 24
Close.TextColor3 = Color3.fromRGB(235, 100, 105)
Close.AutoButtonColor = false
Close.Parent = TopBar

--==================================================
-- STATUS
--==================================================

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 20, 0, 65)
StatusDot.BackgroundColor3 = Color3.fromRGB(255, 190, 70)
StatusDot.BorderSizePixel = 0
StatusDot.Parent = Main

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(1, 0)
StatusCorner.Parent = StatusDot

local StatusText = Instance.new("TextLabel")
StatusText.BackgroundTransparency = 1
StatusText.Position = UDim2.new(0, 34, 0, 59)
StatusText.Size = UDim2.new(0, 250, 0, 20)
StatusText.Font = Enum.Font.Gotham
StatusText.Text = "Connecting..."
StatusText.TextColor3 = Color3.fromRGB(170, 175, 185)
StatusText.TextSize = 12
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = Main

--==================================================
-- CHAT AREA
--==================================================

local ChatFrame = Instance.new("Frame")
ChatFrame.Position = UDim2.new(0, 16, 0, 88)
ChatFrame.Size = UDim2.new(1, -32, 0, 190)
ChatFrame.BackgroundColor3 = Color3.fromRGB(13, 15, 21)
ChatFrame.BorderSizePixel = 0
ChatFrame.Parent = Main

local ChatCorner = Instance.new("UICorner")
ChatCorner.CornerRadius = UDim.new(0, 9)
ChatCorner.Parent = ChatFrame

local ChatScroll = Instance.new("ScrollingFrame")
ChatScroll.Position = UDim2.new(0, 10, 0, 10)
ChatScroll.Size = UDim2.new(1, -20, 1, -20)
ChatScroll.BackgroundTransparency = 1
ChatScroll.BorderSizePixel = 0
ChatScroll.ScrollBarThickness = 3
ChatScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ChatScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ChatScroll.Parent = ChatFrame

local ChatLayout = Instance.new("UIListLayout")
ChatLayout.Padding = UDim.new(0, 7)
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
    Corner.CornerRadius = UDim.new(0, 7)
    Corner.Parent = Message

    local Author = Instance.new("TextLabel")
    Author.BackgroundTransparency = 1
    Author.Position = UDim2.new(0, 10, 0, 6)
    Author.Size = UDim2.new(1, -20, 0, 18)
    Author.Font = Enum.Font.GothamBold
    Author.Text = author
    Author.TextColor3 =
        isOwn
        and Color3.fromRGB(100, 220, 160)
        or Color3.fromRGB(120, 175, 255)
    Author.TextSize = 12
    Author.TextXAlignment = Enum.TextXAlignment.Left
    Author.Parent = Message

    local Content = Instance.new("TextLabel")
    Content.BackgroundTransparency = 1
    Content.Position = UDim2.new(0, 10, 0, 27)
    Content.Size = UDim2.new(1, -20, 0, 0)
    Content.AutomaticSize = Enum.AutomaticSize.Y
    Content.Font = Enum.Font.Gotham
    Content.Text = content
    Content.TextColor3 = Color3.fromRGB(225, 228, 235)
    Content.TextSize = 13
    Content.TextWrapped = true
    Content.TextXAlignment = Enum.TextXAlignment.Left
    Content.TextYAlignment = Enum.TextYAlignment.Top
    Content.Parent = Message

    local Padding = Instance.new("UIPadding")
    Padding.PaddingBottom = UDim.new(0, 9)
    Padding.Parent = Message
end

--==================================================
-- INPUT
--==================================================

local InputFrame = Instance.new("Frame")
InputFrame.Position = UDim2.new(0, 16, 0, 290)
InputFrame.Size = UDim2.new(1, -32, 0, 48)
InputFrame.BackgroundColor3 = Color3.fromRGB(27, 30, 39)
InputFrame.BorderSizePixel = 0
InputFrame.Parent = Main

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 9)
InputCorner.Parent = InputFrame

local Input = Instance.new("TextBox")
Input.BackgroundTransparency = 1
Input.Position = UDim2.new(0, 13, 0, 0)
Input.Size = UDim2.new(1, -105, 1, 0)
Input.Font = Enum.Font.Gotham
Input.PlaceholderText = "Type a message..."
Input.PlaceholderColor3 = Color3.fromRGB(110, 115, 130)
Input.Text = ""
Input.TextColor3 = Color3.fromRGB(235, 238, 245)
Input.TextSize = 13
Input.ClearTextOnFocus = false
Input.TextXAlignment = Enum.TextXAlignment.Left
Input.Parent = InputFrame

local SendButton = Instance.new("TextButton")
SendButton.Position = UDim2.new(1, -88, 0, 6)
SendButton.Size = UDim2.new(0, 78, 0, 36)
SendButton.BackgroundColor3 = Color3.fromRGB(70, 110, 220)
SendButton.BorderSizePixel = 0
SendButton.Text = "SEND"
SendButton.Font = Enum.Font.GothamBold
SendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SendButton.TextSize = 12
SendButton.AutoButtonColor = false
SendButton.Parent = InputFrame

local SendCorner = Instance.new("UICorner")
SendCorner.CornerRadius = UDim.new(0, 7)
SendCorner.Parent = SendButton

--==================================================
-- FOOTER
--==================================================

local Footer = Instance.new("TextLabel")
Footer.BackgroundTransparency = 1
Footer.Position = UDim2.new(0, 18, 1, -36)
Footer.Size = UDim2.new(1, -36, 0, 20)
Footer.Font = Enum.Font.Gotham
Footer.Text = "Messages are synchronized automatically"
Footer.TextColor3 = Color3.fromRGB(105, 110, 125)
Footer.TextSize = 10
Footer.TextXAlignment = Enum.TextXAlignment.Left
Footer.Parent = Main

--==================================================
-- MINIMIZED BUTTON
--==================================================

local MiniButton = Instance.new("TextButton")
MiniButton.Name = "MiniButton"
MiniButton.Size = UDim2.new(0, 55, 0, 55)
MiniButton.Position = UDim2.new(0, 20, 0.5, -27)
MiniButton.BackgroundColor3 = Color3.fromRGB(25, 28, 37)
MiniButton.BorderSizePixel = 0
MiniButton.Text = "💬"
MiniButton.TextSize = 23
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
            (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then

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
-- SEND FUNCTION
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
    SendButton.BackgroundColor3 = Color3.fromRGB(55, 65, 90)

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

        local statusCode = tonumber(response.StatusCode)

        if statusCode == 200 then

            AddMessage(
                Player.Name,
                Message,
                true
            )

            Input.Text = ""

            StatusDot.BackgroundColor3 =
                Color3.fromRGB(80, 210, 130)

            StatusText.Text = "Connected • Message sent"

        else

            StatusDot.BackgroundColor3 =
                Color3.fromRGB(235, 85, 90)

            StatusText.Text = "Send failed"
        end

    else

        StatusDot.BackgroundColor3 =
            Color3.fromRGB(235, 85, 90)

        StatusText.Text = "Connection error"
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
-- RECEIVE SYSTEM
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

    if not success or not response or not response.Body then

        StatusDot.BackgroundColor3 =
            Color3.fromRGB(235, 85, 90)

        StatusText.Text = "Connection failed"

        return
    end

    local statusCode = tonumber(response.StatusCode)

    if statusCode ~= 200 then

        StatusDot.BackgroundColor3 =
            Color3.fromRGB(235, 85, 90)

        StatusText.Text = "Server error"

        return
    end

    local decodedSuccess, data =
        pcall(function()

            return HttpService:JSONDecode(response.Body)

        end)

    if not decodedSuccess or not data then

        StatusDot.BackgroundColor3 =
            Color3.fromRGB(235, 85, 90)

        StatusText.Text = "Invalid server response"

        return
    end

    StatusDot.BackgroundColor3 =
        Color3.fromRGB(80, 210, 130)

    StatusText.Text = "Connected • Auto Sync"

    if data.author and data.content then

        local MessageID = data.id

        -- New message only
        if MessageID and MessageID ~= LastMessageID then

            LastMessageID = MessageID

            -- Don't add initial existing message twice
            if not FirstFetch then

                AddMessage(
                    data.author,
                    data.content,
                    false
                )

            else

                FirstFetch = false

            end

        elseif not MessageID and not FirstFetch then

            AddMessage(
                data.author,
                data.content,
                false
            )

        elseif not MessageID then

            FirstFetch = false

        end
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
-- BUTTON HOVER EFFECTS
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
        Color3.fromRGB(190, 195, 205)

end)

--==================================================
-- START
--==================================================

StatusText.Text = "Connecting to Railway..."
