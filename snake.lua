local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("SnakeUI") then
    playerGui.SnakeUI:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "SnakeUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local delayValue = 0.30
local active = false
local segments = {}
local positions = {}

local function makeDraggable(frame)
    local dragging = false
    local dragStart
    local startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart

            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 150, 0, 58)
main.Position = UDim2.new(0, 20, 0, 20)
main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1.5
stroke.Parent = main

makeDraggable(main)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -45, 0, 27)
title.Position = UDim2.new(0, 8, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Snake"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local kill = Instance.new("TextButton")
kill.Size = UDim2.new(0, 35, 0, 27)
kill.Position = UDim2.new(1, -40, 0, 0)
kill.BackgroundTransparency = 1
kill.Text = "Kill"
kill.TextColor3 = Color3.fromRGB(255, 255, 255)
kill.Font = Enum.Font.GothamBold
kill.TextSize = 11
kill.AutoButtonColor = false
kill.Parent = main

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -16, 0, 27)
toggle.Position = UDim2.new(0, 8, 0, 27)
toggle.BackgroundTransparency = 1
toggle.Text = "OFF"
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 12
toggle.AutoButtonColor = false
toggle.Parent = main

for i = 1, 40 do
    local segment = Instance.new("Frame")
    segment.Size = UDim2.new(0, 7, 0, 7)
    segment.AnchorPoint = Vector2.new(0.5, 0.5)
    segment.BorderSizePixel = 0
    segment.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    segment.Visible = false
    segment.Parent = gui

    local segmentCorner = Instance.new("UICorner")
    segmentCorner.CornerRadius = UDim.new(1, 0)
    segmentCorner.Parent = segment

    segments[i] = segment
    positions[i] = Vector2.new(mouse.X, mouse.Y)
end

toggle.MouseButton1Click:Connect(function()
    active = not active

    if active then
        toggle.Text = "ON"

        for _, segment in ipairs(segments) do
            segment.Visible = true
        end
    else
        toggle.Text = "OFF"

        for _, segment in ipairs(segments) do
            segment.Visible = false
        end
    end
end)

kill.MouseButton1Click:Connect(function()
    active = false

    for _, segment in ipairs(segments) do
        segment:Destroy()
    end

    gui:Destroy()
end)

player.CharacterAdded:Connect(function()
    task.wait(0.5)

    if not gui.Parent then
        gui.Parent = player:WaitForChild("PlayerGui")
    end

    if active then
        for _, segment in ipairs(segments) do
            if segment.Parent then
                segment.Visible = true
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not active then
        return
    end

    local target = Vector2.new(mouse.X, mouse.Y)

    positions[1] = positions[1]:Lerp(target, 0.55)

    for i = 2, #positions do
        positions[i] = positions[i]:Lerp(
            positions[i - 1],
            math.clamp(delayValue + 0.25, 0.01, 1)
        )
    end

    for i, segment in ipairs(segments) do
        if segment.Parent then
            segment.Position = UDim2.new(
                0,
                positions[i].X,
                0,
                positions[i].Y
            )
        end
    end
end)
