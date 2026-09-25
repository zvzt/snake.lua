local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local Workspace=game:GetService("Workspace")
local GuiService=game:GetService("GuiService")
local TweenService=game:GetService("TweenService")

local player=Players.LocalPlayer
local mouse=player:GetMouse()
local playerGui=player:WaitForChild("PlayerGui")
local env=getgenv and getgenv() or _G
local targetParent=playerGui

pcall(function()
	if gethui then
		targetParent=gethui()
	end
end)

if env.SnakeCleanup then
	pcall(env.SnakeCleanup)
end

for _,parent in ipairs({targetParent,playerGui}) do
	local old=parent:FindFirstChild("SnakeUI")
	if old then old:Destroy() end
end

local WINDOW=Color3.fromRGB(0,0,0)
local WINDOW_STROKE=Color3.fromRGB(45,45,50)
local PANEL=Color3.fromRGB(18,18,22)
local PANEL_STROKE=Color3.fromRGB(32,32,36)
local BUTTON=Color3.fromRGB(24,24,28)
local BUTTON_HOVER=Color3.fromRGB(32,32,38)
local BUTTON_ACTIVE=Color3.fromRGB(48,48,58)
local BUTTON_STROKE=Color3.fromRGB(40,40,48)
local TEXT=Color3.fromRGB(240,240,245)
local BUTTON_TEXT=Color3.fromRGB(225,225,232)
local MUTED=Color3.fromRGB(120,120,130)

local connections={}
local segments={}
local positions={}
local active=false
local destroyed=false
local rainbowMode=false
local delayValue=.30
local currentColor=Color3.fromRGB(255,255,255)
local h,s,v=Color3.toHSV(currentColor)
local updatingUI=false
local colorSpaceDragging=false
local hueDragging=false

local function connect(signal,callback)
	local connection=signal:Connect(callback)
	table.insert(connections,connection)
	return connection
end

local function corner(object,radius)
	local c=Instance.new("UICorner",object)
	c.CornerRadius=UDim.new(0,radius)
	return c
end

local function stroke(object,color,thickness)
	local s=Instance.new("UIStroke",object)
	s.Color=color
	s.Thickness=thickness
	s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
	return s
end

local gui=Instance.new("ScreenGui")
gui.Name="SnakeUI"
gui.ResetOnSpawn=false
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.Parent=targetParent

local function cleanup()
	if destroyed then return end
	destroyed=true
	active=false
	rainbowMode=false

	for _,connection in ipairs(connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end

	table.clear(connections)

	if gui then
		pcall(function()
			gui:Destroy()
		end)
	end

	if env.SnakeCleanup==cleanup then
		env.SnakeCleanup=nil
	end
end

env.SnakeCleanup=cleanup

local function makeDraggable(dragHandle,targetFrame)
	targetFrame=targetFrame or dragHandle
	local dragging=false
	local dragStart
	local startPos

	connect(dragHandle.InputBegan,function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
			dragging=true
			dragStart=input.Position
			startPos=Vector2.new(
				targetFrame.Position.X.Offset,
				targetFrame.Position.Y.Offset
			)
		end
	end)

	connect(UIS.InputChanged,function(input)
		if not dragging then return end
		if input.UserInputType~=Enum.UserInputType.MouseMovement and input.UserInputType~=Enum.UserInputType.Touch then return end

		local camera=Workspace.CurrentCamera
		if not camera then return end

		local delta=input.Position-dragStart
		local size=targetFrame.AbsoluteSize
		local viewport=camera.ViewportSize
		local topOffset=-57
		local bottomOffset=57

		local x=math.clamp(
			startPos.X+delta.X,
			0,
			math.max(0,viewport.X-size.X)
		)

		local y=math.clamp(
			startPos.Y+delta.Y,
			topOffset,
			math.max(topOffset,viewport.Y-size.Y-bottomOffset)
		)

		targetFrame.Position=UDim2.fromOffset(x,y)
	end)

	connect(UIS.InputEnded,function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
			dragging=false
		end
	end)
end

local main=Instance.new("Frame",gui)
main.Name="SlateWindow_Snake"
main.Size=UDim2.fromOffset(360,235)
main.BackgroundColor3=WINDOW
main.BorderSizePixel=0
main.ClipsDescendants=true
main.Active=true
corner(main,10)
stroke(main,WINDOW_STROKE,1.2)

local camera=Workspace.CurrentCamera

if camera then
	local viewport=camera.ViewportSize
	main.Position=UDim2.fromOffset(
		math.floor((viewport.X-360)/2),
		math.floor((viewport.Y-235)/2)
	)
else
	main.Position=UDim2.new(.5,-180,.5,-118)
end

local header=Instance.new("Frame",main)
header.Name="HeaderBar"
header.Size=UDim2.new(1,0,0,38)
header.BackgroundTransparency=1
header.BorderSizePixel=0
header.Active=true

local title=Instance.new("TextLabel",header)
title.Text="Snake"
title.TextSize=20
title.TextColor3=TEXT
title.FontFace=Font.new(
	"rbxasset://fonts/families/SourceSansPro.json",
	Enum.FontWeight.Bold,
	Enum.FontStyle.Normal
)
title.Position=UDim2.fromOffset(12,0)
title.Size=UDim2.new(0,140,1,0)
title.BackgroundTransparency=1
title.TextXAlignment=Enum.TextXAlignment.Left

local switchHolder=Instance.new("TextButton",header)
switchHolder.Size=UDim2.fromOffset(95,24)
switchHolder.Position=UDim2.new(1,-173,0,7)
switchHolder.BackgroundTransparency=1
switchHolder.Text=""
switchHolder.AutoButtonColor=false

local switchLabel=Instance.new("TextLabel",switchHolder)
switchLabel.Size=UDim2.fromOffset(50,24)
switchLabel.BackgroundTransparency=1
switchLabel.Text="Disabled"
switchLabel.TextSize=11
switchLabel.TextColor3=MUTED
switchLabel.FontFace=Font.new(
	"rbxasset://fonts/families/SourceSansPro.json",
	Enum.FontWeight.Bold,
	Enum.FontStyle.Normal
)
switchLabel.TextXAlignment=Enum.TextXAlignment.Right

local switchTrack=Instance.new("Frame",switchHolder)
switchTrack.Size=UDim2.fromOffset(30,16)
switchTrack.Position=UDim2.new(1,-34,.5,-8)
switchTrack.BackgroundColor3=Color3.fromRGB(32,32,38)
switchTrack.BorderSizePixel=0
corner(switchTrack,8)

local trackStroke=stroke(
	switchTrack,
	Color3.fromRGB(50,50,58),
	1
)

local switchThumb=Instance.new("Frame",switchTrack)
switchThumb.Size=UDim2.fromOffset(12,12)
switchThumb.Position=UDim2.new(0,2,.5,-6)
switchThumb.BackgroundColor3=Color3.fromRGB(130,130,140)
switchThumb.BorderSizePixel=0
corner(switchThumb,6)

local minimizeBtn=Instance.new("TextButton",header)
minimizeBtn.Text="—"
minimizeBtn.TextSize=16
minimizeBtn.TextColor3=Color3.fromRGB(150,150,160)
minimizeBtn.Font=Enum.Font.GothamBold
minimizeBtn.Size=UDim2.fromOffset(20,20)
minimizeBtn.Position=UDim2.new(1,-52,0,9)
minimizeBtn.BackgroundTransparency=1
minimizeBtn.BorderSizePixel=0
minimizeBtn.AutoButtonColor=false
minimizeBtn.ZIndex=20

local closeBtn=Instance.new("TextButton",header)
closeBtn.Text="X"
closeBtn.TextSize=14
closeBtn.TextColor3=Color3.fromRGB(150,150,160)
closeBtn.Font=Enum.Font.GothamBold
closeBtn.Size=UDim2.fromOffset(20,20)
closeBtn.Position=UDim2.new(1,-28,0,9)
closeBtn.BackgroundTransparency=1
closeBtn.BorderSizePixel=0
closeBtn.AutoButtonColor=false
closeBtn.ZIndex=20

local function headerHover(button)
	connect(button.MouseEnter,function()
		TweenService:Create(
			button,
			TweenInfo.new(.15),
			{TextColor3=TEXT}
		):Play()
	end)

	connect(button.MouseLeave,function()
		TweenService:Create(
			button,
			TweenInfo.new(.15),
			{TextColor3=Color3.fromRGB(150,150,160)}
		):Play()
	end)
end

headerHover(minimizeBtn)
headerHover(closeBtn)

connect(closeBtn.MouseButton1Click,cleanup)

makeDraggable(header,main)

local function animateToggle(state)
	if state then
		TweenService:Create(
			switchTrack,
			TweenInfo.new(.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
			{BackgroundColor3=Color3.fromRGB(255,255,255)}
		):Play()

		TweenService:Create(
			trackStroke,
			TweenInfo.new(.2),
			{Color=Color3.fromRGB(220,220,225)}
		):Play()

		TweenService:Create(
			switchThumb,
			TweenInfo.new(.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
			{
				Position=UDim2.new(1,-14,.5,-6),
				BackgroundColor3=Color3.fromRGB(18,18,22)
			}
		):Play()

		switchLabel.Text="Active"
		switchLabel.TextColor3=TEXT
	else
		TweenService:Create(
			switchTrack,
			TweenInfo.new(.2),
			{BackgroundColor3=Color3.fromRGB(32,32,38)}
		):Play()

		TweenService:Create(
			trackStroke,
			TweenInfo.new(.2),
			{Color=Color3.fromRGB(50,50,58)}
		):Play()

		TweenService:Create(
			switchThumb,
			TweenInfo.new(.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
			{
				Position=UDim2.new(0,2,.5,-6),
				BackgroundColor3=Color3.fromRGB(130,130,140)
			}
		):Play()

		switchLabel.Text="Disabled"
		switchLabel.TextColor3=MUTED
	end
end

connect(switchHolder.MouseButton1Click,function()
	active=not active
	animateToggle(active)

	for _,segment in ipairs(segments) do
		if segment.Parent then
			segment.Visible=active
		end
	end
end)

local content=Instance.new("Frame",main)
content.Position=UDim2.new(0,10,0,42)
content.Size=UDim2.new(1,-20,1,-50)
content.BackgroundTransparency=1

local pickerContainer=Instance.new("Frame",content)
pickerContainer.Size=UDim2.new(1,0,0,145)
pickerContainer.BackgroundColor3=PANEL
pickerContainer.BorderSizePixel=0
corner(pickerContainer,9)
stroke(pickerContainer,PANEL_STROKE,1)

local colorSpace=Instance.new("Frame",pickerContainer)
colorSpace.Position=UDim2.new(0,8,0,8)
colorSpace.Size=UDim2.new(1,-48,0,129)
colorSpace.BackgroundColor3=Color3.fromHSV(h,1,1)
colorSpace.BorderSizePixel=0
colorSpace.ClipsDescendants=true
corner(colorSpace,7)

local satOverlay=Instance.new("Frame",colorSpace)
satOverlay.Position=UDim2.fromOffset(1,1)
satOverlay.Size=UDim2.new(1,-2,1,-2)
satOverlay.BackgroundColor3=Color3.fromRGB(255,255,255)
satOverlay.BorderSizePixel=0
satOverlay.ClipsDescendants=true
corner(satOverlay,6)

local satGrad=Instance.new("UIGradient",satOverlay)
satGrad.Color=ColorSequence.new(Color3.fromRGB(255,255,255))
satGrad.Transparency=NumberSequence.new({
	NumberSequenceKeypoint.new(0,0),
	NumberSequenceKeypoint.new(1,1)
})

local valOverlay=Instance.new("Frame",colorSpace)
valOverlay.Position=UDim2.fromOffset(1,1)
valOverlay.Size=UDim2.new(1,-2,1,-2)
valOverlay.BackgroundColor3=Color3.fromRGB(0,0,0)
valOverlay.BorderSizePixel=0
valOverlay.ClipsDescendants=true
corner(valOverlay,6)

local valGrad=Instance.new("UIGradient",valOverlay)
valGrad.Color=ColorSequence.new(Color3.fromRGB(0,0,0))
valGrad.Transparency=NumberSequence.new({
	NumberSequenceKeypoint.new(0,1),
	NumberSequenceKeypoint.new(1,0)
})
valGrad.Rotation=90

local cursor=Instance.new("Frame",colorSpace)
cursor.Size=UDim2.fromOffset(10,10)
cursor.AnchorPoint=Vector2.new(.5,.5)
cursor.Position=UDim2.new(s,0,1-v,0)
cursor.BackgroundColor3=Color3.fromRGB(255,255,255)
cursor.BackgroundTransparency=.5
cursor.BorderSizePixel=0
cursor.ZIndex=5
corner(cursor,5)

local cursorGlow=stroke(
	cursor,
	Color3.fromRGB(0,0,0),
	2
)
cursorGlow.Transparency=.35

local cursorStroke=Instance.new("UIStroke",cursor)
cursorStroke.Color=Color3.fromRGB(255,255,255)
cursorStroke.Thickness=1.2

local hueBar=Instance.new("Frame",pickerContainer)
hueBar.Position=UDim2.new(1,-34,0,8)
hueBar.Size=UDim2.fromOffset(26,129)
hueBar.BackgroundColor3=Color3.fromRGB(255,255,255)
hueBar.BorderSizePixel=0
hueBar.ClipsDescendants=true
corner(hueBar,7)

local hueGrad=Instance.new("UIGradient",hueBar)
hueGrad.Rotation=90
hueGrad.Color=ColorSequence.new({
	ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
	ColorSequenceKeypoint.new(.17,Color3.fromRGB(255,255,0)),
	ColorSequenceKeypoint.new(.33,Color3.fromRGB(0,255,0)),
	ColorSequenceKeypoint.new(.5,Color3.fromRGB(0,255,255)),
	ColorSequenceKeypoint.new(.67,Color3.fromRGB(0,0,255)),
	ColorSequenceKeypoint.new(.83,Color3.fromRGB(255,0,255)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))
})

local hueKnob=Instance.new("Frame",hueBar)
hueKnob.Size=UDim2.new(1,0,0,5)
hueKnob.AnchorPoint=Vector2.new(.5,.5)
hueKnob.Position=UDim2.new(.5,0,h,0)
hueKnob.BackgroundColor3=Color3.fromRGB(255,255,255)
hueKnob.BorderSizePixel=0
corner(hueKnob,3)

local inputs=Instance.new("Frame",content)
inputs.Position=UDim2.new(0,0,0,151)
inputs.Size=UDim2.new(1,0,0,22)
inputs.BackgroundTransparency=1

local function makeInput(name,x,width)
	local box=Instance.new("TextBox",inputs)
	box.Name=name
	box.Size=UDim2.fromOffset(width,22)
	box.Position=UDim2.fromOffset(x,0)
	box.BackgroundColor3=BUTTON
	box.BorderSizePixel=0
	box.ClearTextOnFocus=false
	box.PlaceholderText=name
	box.PlaceholderColor3=Color3.fromRGB(115,115,125)
	box.Text=""
	box.TextColor3=BUTTON_TEXT
	box.TextSize=10
	box.Font=Enum.Font.GothamMedium
	box.TextXAlignment=Enum.TextXAlignment.Center
	corner(box,4)
	stroke(box,BUTTON_STROKE,1)
	return box
end

local rInput=makeInput("R",0,78)
local gInput=makeInput("G",86,78)
local bInput=makeInput("B",172,78)

local rgbButton=Instance.new("TextButton",inputs)
rgbButton.Size=UDim2.new(1,-258,0,22)
rgbButton.Position=UDim2.fromOffset(258,0)
rgbButton.BackgroundColor3=BUTTON
rgbButton.BorderSizePixel=0
rgbButton.AutoButtonColor=false
rgbButton.Text="RGB"
rgbButton.TextColor3=BUTTON_TEXT
rgbButton.TextSize=10
rgbButton.Font=Enum.Font.GothamMedium
corner(rgbButton,4)

local rgbStroke=stroke(
	rgbButton,
	BUTTON_STROKE,
	1
)

local function applyTrailColor(color)
	currentColor=color

	for _,segment in ipairs(segments) do
		if segment.Parent then
			segment.BackgroundColor3=color
		end
	end
end

local function stopRGB()
	rainbowMode=false
	rgbButton.BackgroundColor3=BUTTON
	rgbStroke.Color=BUTTON_STROKE
end

local function syncInputs(color)
	local r=math.round(color.R*255)
	local g=math.round(color.G*255)
	local b=math.round(color.B*255)

	if not rInput:IsFocused() then
		rInput.Text=tostring(r)
	end

	if not gInput:IsFocused() then
		gInput.Text=tostring(g)
	end

	if not bInput:IsFocused() then
		bInput.Text=tostring(b)
	end
end

local function updateVisuals(apply)
	if updatingUI then return end
	updatingUI=true

	colorSpace.BackgroundColor3=Color3.fromHSV(h,1,1)
	cursor.Position=UDim2.new(s,0,1-v,0)
	hueKnob.Position=UDim2.new(.5,0,h,0)

	local color=Color3.fromHSV(h,s,v)
	syncInputs(color)

	updatingUI=false

	if apply then
		applyTrailColor(color)
	end
end

local function manualHSV(newH,newS,newV)
	stopRGB()
	h=newH
	s=newS
	v=newV
	updateVisuals(true)
end

local function getRelative(frame)
	local inset=GuiService:GetGuiInset()
	local position=UIS:GetMouseLocation()-inset

	local x=math.clamp(
		(position.X-frame.AbsolutePosition.X)/frame.AbsoluteSize.X,
		0,
		1
	)

	local y=math.clamp(
		(position.Y-frame.AbsolutePosition.Y)/frame.AbsoluteSize.Y,
		0,
		1
	)

	return x,y
end

connect(colorSpace.InputBegan,function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
		colorSpaceDragging=true
		local x,y=getRelative(colorSpace)
		manualHSV(h,x,1-y)
	end
end)

connect(hueBar.InputBegan,function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
		hueDragging=true
		local _,y=getRelative(hueBar)
		manualHSV(y,s,v)
	end
end)

connect(UIS.InputChanged,function(input)
	if input.UserInputType~=Enum.UserInputType.MouseMovement and input.UserInputType~=Enum.UserInputType.Touch then
		return
	end

	if colorSpaceDragging then
		local x,y=getRelative(colorSpace)
		manualHSV(h,x,1-y)
	elseif hueDragging then
		local _,y=getRelative(hueBar)
		manualHSV(y,s,v)
	end
end)

connect(UIS.InputEnded,function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
		colorSpaceDragging=false
		hueDragging=false
	end
end)

local function updateRGBInputs()
	if updatingUI then return end

	local r=tonumber(rInput.Text)
	local g=tonumber(gInput.Text)
	local b=tonumber(bInput.Text)

	if not r or not g or not b then
		return
	end

	r=math.clamp(math.floor(r+.5),0,255)
	g=math.clamp(math.floor(g+.5),0,255)
	b=math.clamp(math.floor(b+.5),0,255)

	stopRGB()

	local color=Color3.fromRGB(r,g,b)
	h,s,v=Color3.toHSV(color)
	updateVisuals(true)
end

connect(rInput:GetPropertyChangedSignal("Text"),updateRGBInputs)
connect(gInput:GetPropertyChangedSignal("Text"),updateRGBInputs)
connect(bInput:GetPropertyChangedSignal("Text"),updateRGBInputs)

connect(rgbButton.MouseEnter,function()
	if not rainbowMode then
		TweenService:Create(
			rgbButton,
			TweenInfo.new(.1),
			{BackgroundColor3=BUTTON_HOVER}
		):Play()
	end
end)

connect(rgbButton.MouseLeave,function()
	if not rainbowMode then
		TweenService:Create(
			rgbButton,
			TweenInfo.new(.1),
			{BackgroundColor3=BUTTON}
		):Play()
	end
end)

connect(rgbButton.MouseButton1Click,function()
	rainbowMode=not rainbowMode

	if rainbowMode then
		rgbButton.BackgroundColor3=BUTTON_ACTIVE
		rgbStroke.Color=Color3.fromRGB(70,70,82)
	else
		stopRGB()
	end
end)

for i=1,40 do
	local segment=Instance.new("Frame",gui)
	segment.Name="Segment"..i
	segment.Size=UDim2.fromOffset(7,7)
	segment.AnchorPoint=Vector2.new(.5,.5)
	segment.BorderSizePixel=0
	segment.BackgroundColor3=currentColor
	segment.Visible=false
	segment.Parent=gui
	corner(segment,4)

	segments[i]=segment
	positions[i]=Vector2.new(mouse.X,mouse.Y)
end

local collapsed=false
local sizeTween=nil
local FULL_WIDTH=360
local FULL_HEIGHT=235
local COLLAPSED_HEIGHT=38

local function clampMain(height)
	local camera=Workspace.CurrentCamera
	if not camera then
		return
	end

	local viewport=camera.ViewportSize
	local topOffset=-57
	local bottomOffset=57

	local x=math.clamp(
		main.Position.X.Offset,
		0,
		math.max(0,viewport.X-FULL_WIDTH)
	)

	local y=math.clamp(
		main.Position.Y.Offset,
		topOffset,
		math.max(topOffset,viewport.Y-height-bottomOffset)
	)

	main.Position=UDim2.fromOffset(x,y)
end

local function setCollapsed(state)
	if collapsed==state then
		return
	end

	collapsed=state

	if sizeTween then
		sizeTween:Cancel()
		sizeTween=nil
	end

	if collapsed then
		content.Visible=false

		sizeTween=TweenService:Create(
			main,
			TweenInfo.new(.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
			{Size=UDim2.fromOffset(FULL_WIDTH,COLLAPSED_HEIGHT)}
		)

		sizeTween:Play()
	else
		clampMain(FULL_HEIGHT)

		sizeTween=TweenService:Create(
			main,
			TweenInfo.new(.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
			{Size=UDim2.fromOffset(FULL_WIDTH,FULL_HEIGHT)}
		)

		local thisTween=sizeTween

		connect(thisTween.Completed,function()
			if destroyed then
				return
			end

			if not collapsed and sizeTween==thisTween and main.Parent then
				content.Visible=true
			end
		end)

		thisTween:Play()
	end
end

connect(minimizeBtn.MouseButton1Click,function()
	setCollapsed(not collapsed)
end)

connect(player.CharacterAdded,function()
	if destroyed then return end

	task.wait(.5)

	if destroyed then return end

	if active then
		for _,segment in ipairs(segments) do
			if segment.Parent then
				segment.Visible=true
			end
		end
	end
end)

connect(RunService.RenderStepped,function()
	if destroyed then return end

	if rainbowMode then
		h=(os.clock()*.08)%1
		s=1
		v=1
		updateVisuals(true)
	end

	if not active then
		return
	end

	local target=Vector2.new(mouse.X,mouse.Y)

	positions[1]=positions[1]:Lerp(target,.55)

	for i=2,#positions do
		positions[i]=positions[i]:Lerp(
			positions[i-1],
			math.clamp(delayValue+.25,.01,1)
		)
	end

	for i,segment in ipairs(segments) do
		if segment.Parent then
			segment.Position=UDim2.fromOffset(
				positions[i].X,
				positions[i].Y
			)
		end
	end
end)

animateToggle(false)
updateVisuals(true)
