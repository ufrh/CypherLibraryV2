local Framework = {}
Framework.__index = Framework

function Framework.new(Name)

    if game:GetService("CoreGui"):FindFirstChild("Screen") then 
        game:GetService("CoreGui"):FindFirstChild("Screen"):Destroy() 
    end

	local tself = setmetatable({}, Framework)

	tself.PrimaryColor = Color3.new(45, 147, 255)
	tself.HideKey = Enum.KeyCode.E
	tself.HubText = Name
	tself.Enum = {
		Button = 1,
		TextBox = 2, 
		Toggle = 3, 
		Dropdown = 4,
		ColorPicker = 5,
		ButtonStyle = {
			Filled = "ButtonFilled", 
			Tinted = "ButtonTinted", 
			DarkGrey = "ButtonDarkGrey",
			Transparent = "ButtonBGGone"
		};
	}

	local GUI_ID = "rbxassetid://10904971836"
	local ASSET_ID = "rbxassetid://10907112176"
	local Internal = {}

	function Internal:Get(Id)
		local Return
		local Success,Error = pcall(function()
			Return = game:GetObjects(Id)[1]
		end)
		if Return then 
			return Return 
		end
	end
	
	function Internal:TweenAsset(Asset, Time, Style, Dir, Goals)
		return game.TweenService:Create(Asset, TweenInfo.new(Time, Enum.EasingStyle[Style], Enum.EasingDirection[Dir]), Goals)
	end

	local CoreUI = Internal:Get(GUI_ID)
	local UI = CoreUI.Main
	
	CoreUI.Parent = game:GetService("CoreGui")

	local Pages = {}

	UI.HubName.Text = tself.HubText 

	local UIS = game:GetService("UserInputService")

	UIS.InputBegan:Connect(function(Input, GPE)
		if not GPE and Input.KeyCode == tself.HideKey then
			UI.Visible = not UI.Visible
		end
	end)

    local UserInputService = game:GetService("UserInputService")
    local runService = (game:GetService("RunService"));

    local gui = UI

    local dragging
    local dragInput
    local dragStart
    local startPos

    function Lerp(a, b, m)
        return a + (b - a) * m
    end;

    local lastMousePos
    local lastGoalPos
    local DRAG_SPEED = (8);
    function Update(dt)
        if not (startPos) then return end;
        if not (dragging) and (lastGoalPos) then
            gui.Position = UDim2.new(startPos.X.Scale, Lerp(gui.Position.X.Offset, lastGoalPos.X.Offset, dt * DRAG_SPEED), startPos.Y.Scale, Lerp(gui.Position.Y.Offset, lastGoalPos.Y.Offset, dt * DRAG_SPEED))
            return 
        end;

        local delta = (lastMousePos - UserInputService:GetMouseLocation())
        local xGoal = (startPos.X.Offset - delta.X);
        local yGoal = (startPos.Y.Offset - delta.Y);
        lastGoalPos = UDim2.new(startPos.X.Scale, xGoal, startPos.Y.Scale, yGoal)
        gui.Position = UDim2.new(startPos.X.Scale, Lerp(gui.Position.X.Offset, xGoal, dt * DRAG_SPEED), startPos.Y.Scale, Lerp(gui.Position.Y.Offset, yGoal, dt * DRAG_SPEED))
    end;

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            lastMousePos = UserInputService:GetMouseLocation()

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    runService.Heartbeat:Connect(Update)

    local ThisPage 

    UI.SearchFrame.ZIndex = 4

    UI.SearchFrame.TextBoxCore:GetPropertyChangedSignal("Text"):Connect(function() 
        if UI.SearchFrame.TextBoxCore.Text ~= "" and UI.SearchFrame.TextBoxCore.Text ~= "" and ThisPage then 
            for _, v in pairs(ThisPage:GetChildren()) do 
                if not string.find(v.Name, UI.SearchFrame.TextBoxCore.Text) then 
                    if not v:IsA("UIListLayout") and not v:IsA("UIPadding") and v.Name ~= "DropdownMenu" then
                        v.Visible = false 
                    end
                elseif v.Name ~= "DropdownMenu" then
                    v.Visible = true 
                end
            end
        elseif ThisPage then
            for _,v in pairs(ThisPage:GetChildren()) do 
                if not v:IsA("UIListLayout") and not v:IsA("UIPadding") and v.Name ~= "DropdownMenu" then
                    v.Visible = true 
                end
            end
        end
    end)

	local Assets = Internal:Get(ASSET_ID)
	
	function tself.new(Name)
		
		local self = setmetatable({}, TabFramework)
		
		self.TabText = Name or "Tab"
		
		local TabButton, Page = Assets.TabButton:Clone(), Assets.Page:Clone()
		
		TabButton.Parent = UI.TabFrame
		
		Page.Parent = UI

        Page.Visible = false

        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		
		TabButton.Text = self.TabText

        TabButton.AutoButtonColor = false

        local RRGGBB1 = TabButton.BackgroundColor3
        
        TabButton.MouseEnter:Connect(function()
            
            local R,G,B
            
            R = 35
            G = 35
            B = 35
            
            local RGB = Color3.fromRGB(R,G,B)
            
            Internal:TweenAsset(TabButton, 0.5, "Quad", "InOut", {BackgroundColor3 = RGB}):Play()
            
        end)
        
        TabButton.MouseLeave:Connect(function() 
            
            Internal:TweenAsset(TabButton, 0.5, "Quad", "InOut", {BackgroundColor3 = RRGGBB1}):Play()
            
        end)

        TabButton.MouseButton1Click:Connect(function()
            for i,v in pairs(UI:GetChildren()) do 
                if v.Name == "Page" then 
                    v.Visible = false
                end
            end
            Page.Visible = true
            ThisPage = Page
        end)
		
		local ElementFramework = {}
		ElementFramework.__index = ElementFramework
		
		function ElementFramework.new(Class, ...)
			
			local Args = {...} 
			
			if Class == tself.Enum.Button then 
				
				local Text,Style,Callback,Tip = Args[1], Args[2], Args[3], Args[4]
				
				if Assets[Style] then
					
					local Button = Assets[Style]:Clone()
					Button.Parent = Page 
					Button.Name = Text
					Button.MouseButton1Click:Connect(function()
						Callback()
					end)
					
					Button:FindFirstChild("Text").Text = Text 
					
					local RRGGBB = Button.BackgroundColor3
					
					Button.MouseEnter:Connect(function()
						
						local R,G,B
						
						R = 35
						G = 35
						B = 35
						
						local RGB = Color3.fromRGB(R,G,B)
						
						Internal:TweenAsset(Button, 0.5, "Quad", "InOut", {BackgroundColor3 = RGB}):Play()
						
					end)
					
					Button.MouseLeave:Connect(function() 
						
						Internal:TweenAsset(Button, 0.5, "Quad", "InOut", {BackgroundColor3 = RRGGBB}):Play()
						
					end)

				end
			elseif Class == tself.Enum.Dropdown then 
                
                local Options,Text,Callback = Args[1], Args[2], Args[3]

                if #Options == 2 then 
                    return tself:Notify("[CYPHER ERROR] 2 Options is not supported for this Lib!", 5)
                end

                local DropButton = Assets["Drop"]:Clone() 
                local DropMenu = Assets["DropdownMenu"]:Clone() 

                local function Update()
                    local function getAbsoluteSize(frame)
                        local totalSize = Vector2.new()
                        
                        for _, Child in pairs(frame:GetChildren()) do
                            if Child:IsA("GuiBase2d") then
                                totalSize += Child.AbsoluteSize
                            end
                        end
                        
                        return totalSize
                    end
                    DropMenu.Size = UDim2.fromOffset(getAbsoluteSize(DropMenu).X, getAbsoluteSize(DropMenu).Y)
                end

                DropMenu.ChildAdded:Connect(Update)

                DropMenu.Visible = false 
                
                DropButton.Parent = Page 
                DropMenu.Parent = Page
                DropButton:FindFirstChild("Text").Text = Text
                DropButton.Name = Text

                local OptionStart = Assets["Top"]:Clone()
                local OptionEnd = Assets["Bottom"]:Clone()

                if #Options == 1 then 

                    OptionStart.Parent = DropMenu 
                    OptionStart:FindFirstChild("Text").Text = ""

                    local OptionMid = Assets["Mid"]:Clone() 

                    OptionMid.Parent = DropMenu
                    OptionMid:FindFirstChild("Text").Text = Options[1]

                    OptionMid.MouseButton1Click:Connect(function()
                        Callback(Options[1])
                        DropButton.Text = Options[1]
                    end)

                    OptionEnd.Parent = DropMenu
                    OptionEnd:FindFirstChild("Text").Text = ""
                
                else 

                    OptionStart.Parent = DropMenu
                    OptionStart:FindFirstChild("Text").Text = Options[1]

                    OptionStart.MouseButton1Click:Connect(function()
                        Callback(Options[1])
                        DropButton.Text = Options[1]
                    end)

                    for i,v in pairs(Options) do 
                        if i ~= 1 and i ~= #Options then 
                            local OptionMid = Assets["Mid"]:Clone() 

                            OptionMid.Parent = DropMenu
                            OptionMid:FindFirstChild("Text").Text = v

                            OptionMid.MouseButton1Click:Connect(function()
                                Callback(v)
                                DropButton.Text = v
                            end)
                        end
                    end

                    OptionEnd.Parent = DropMenu
                    OptionEnd:FindFirstChild("Text").Text = Options[#Options]

                    OptionEnd.MouseButton1Click:Connect(function()
                        Callback(Options[#Options])
                        DropButton.Text = Options[#Options]
                    end)
                end
                local Enabled = false
                DropButton.MouseButton1Click:Connect(function() 
                    Enabled = not Enabled 
                    if Enabled == true then 
                        Internal:TweenAsset(DropButton.chevron_left, 0.5, "Quad", "InOut", {Rotation = 90}):Play() 
                        DropMenu.Visible = false 
                    elseif Enabled == false then 
                        Internal:TweenAsset(DropButton.chevron_left, 0.5, "Quad", "InOut", {Rotation = -90}):Play() 
                        DropMenu.Visible = true 
                    end
                end)

                local DropSettings = {}

                function DropSettings:Update(Options) 
                    DropMenu:ClearAllChildren()
                    local OptionStart = Assets["Top"]:Clone()
                    local OptionEnd = Assets["Bottom"]:Clone()

                    if #Options == 1 then 

                        OptionStart.Parent = DropMenu 
                        OptionsStart:FindFirstChild("Text").Text = ""

                        local OptionMid = Assets["Mid"]:Clone() 

                        OptionMid.Parent = DropMenu
                        OptionMid:FindFirstChild("Text").Text = Options[1]

                        OptionMid.MouseButton1Click:Connect(function()
                            Callback(Options[1])
                        end)

                        OptionEnd.Parent = DropMenu
                        OptionEnd:FindFirstChild("Text").Text = ""
                    
                    else 

                        OptionStart.Parent = DropMenu
                        OptionStart:FindFirstChild("Text").Text = Options[1]

                        OptionStart.MouseButton1Click:Connect(function()
                            Callback(Options[1])
                            DropButton.Text = Options[1]
                        end)

                        for i,v in pairs(Options) do 
                            if i ~= 1 and i ~= #Options then 
                                local OptionMid = Assets["Mid"]:Clone() 

                                OptionMid.Parent = DropMenu
                                OptionMid:FindFirstChild("Text").Text = v

                                OptionMid.MouseButton1Click:Connect(function()
                                    Callback(v)
                                    DropButton.Text = v
                                end)
                            end
                        end

                        OptionEnd.Parent = DropMenu
                        OptionEnd:FindFirstChild("Text").Text = Options[#Options]

                        OptionEnd.MouseButton1Click:Connect(function()
                            Callback(Options[#Options])
                            DropButton.Text = Options[#Options]
                        end)
                    end
                end

                return DropSettings

            elseif Class == tself.Enum.ColorPicker then 

                local Text,Callback = Args[1], Args[2]
                local Button = Assets["ButtonFilled"]:Clone()
                Button.Parent = Page 
                Button.Name = Text

                local PickerFrame = Assets["ColorPicker"]:Clone() 
                PickerFrame.Parent = UI 
                PickerFrame.ZIndex = 4
                PickerFrame.Visible = false   
                PickerFrame.Position = UDim2.fromScale(.3,.1)
                PickerFrame.ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

                local InPickerFrame = false 

                PickerFrame.MouseEnter:Connect(function() InPickerFrame = true end)     
                PickerFrame.MouseLeave:Connect(function() InPickerFrame = false end) 
                
                Button.MouseButton1Click:Connect(function()
                    PickerFrame.Visible = true 
                    UI.Blinder.Visible = true 
                    UI.Blinder.ZIndex = 4
                    Internal:TweenAsset(UI.Blinder, 0.5, "Quad", "InOut", {BackgroundTransparency = 0.5}):Play()
                    for _,v in pairs(ThisPage:GetDescendants()) do 
                        if v:IsA("TextButton") or v:IsA("Frame") then        
                            v.Active = false 
                        end
                    end   
                end)

                UI.Blinder.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then  
                        if not InPickerFrame then
                            Internal:TweenAsset(UI.Blinder, 0.5, "Quad", "InOut", {BackgroundTransparency = 1}):Play()
                            PickerFrame.Visible = false
                            for _,v in pairs(ThisPage:GetDescendants()) do 
                                if v:IsA("TextButton") or v:IsA("Frame") then        
                                    v.Active = true 
                                end
                            end   
                        end
                    end
                end)

                local ColorsList = {} do
                    for i = 1,126 do 
                        if BrickColor.palette(i) then
                            table.insert(ColorsList, {name = BrickColor.palette(i).Name, color = BrickColor.palette(i).Color})
                        end
                    end
                end

                for _,v in pairs(ColorsList) do 
                    local NewColor = Assets["AColor"]:Clone() 
                    NewColor.Parent = PickerFrame.ScrollingFrame
                    NewColor:FindFirstChild("Color").BackgroundColor3 = v["color"]
                    NewColor.TextLabel.Text = v["name"]
                    NewColor.InputBegan:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 then  
                            if InPickerFrame then 
                                Callback(v["color"])
                            end
                        end
                    end)
                end
                
                Button:FindFirstChild("Text").Text = Text 
                
                local RRGGBB = Button.BackgroundColor3
                
                Button.MouseEnter:Connect(function()
                    
                    local R,G,B
                    
                    R = 35
                    G = 35
                    B = 35
                    
                    local RGB = Color3.fromRGB(R,G,B)
                    
                    Internal:TweenAsset(Button, 0.5, "Quad", "InOut", {BackgroundColor3 = RGB}):Play()
                    
                end)
                
                Button.MouseLeave:Connect(function() 
                    
                    Internal:TweenAsset(Button, 0.5, "Quad", "InOut", {BackgroundColor3 = RRGGBB}):Play()
                    
                end)

            elseif Class == tself.Enum.Toggle then 

                local Text,Callback = Args[1], Args[2] 

                local ToggleThing = Assets["Toggle"]:Clone()

                ToggleThing.Parent = Page

                ToggleThing.Name = Text

                local Enabled = false

                ToggleThing.MouseButton1Click:Connect(function() 
                    Enabled = not Enabled
                    Callback(Enabled)
                    if not Enabled then 
                        Internal:TweenAsset(ToggleThing.ToggleFrame.FrameToggleCore, 0.5, "Quad", "InOut", {BackgroundColor3 = Color3.fromRGB(46, 204, 113)}):Play() 
                        Internal:TweenAsset(ToggleThing.ToggleFrame.FrameToggleCore, 0.5, "Quad", "InOut", {Position = UDim2.fromScale(0.303,0.2)}):Play()
                    elseif Enabled then
                        Internal:TweenAsset(ToggleThing.ToggleFrame.FrameToggleCore, 0.5, "Quad", "InOut", {BackgroundColor3 = Color3.fromRGB(192, 57, 43)}):Play() 
                        Internal:TweenAsset(ToggleThing.ToggleFrame.FrameToggleCore, 0.5, "Quad", "InOut", {Position = UDim2.fromScale(0.1,0.2)}):Play()
                    end
                end)

            elseif Class == tself.Enum.TextBox then 

                local Text,Callback,PlaceholderText = Args[1], Args[2], Args[3]

                local TextBox = Assets["Textbox"]:Clone() 

                TextBox.Name = Text

                TextBox.Parent = Page 

                TextBox.TextboxFrame.TextBoxCore.PlaceholderText = PlaceholderText

                TextBox:FindFirstChild("Text").Text = Text 

                TextBox.TextboxFrame.TextBoxCore.FocusLost:Connect(function(Enterpressed)
                    if Enterpressed then 
                        if TextBox.TextboxFrame.TextBoxCore.Text ~= ' ' and TextBox.TextboxFrame.TextBoxCore.Text ~= '' then
                            Callback(TextBox.TextboxFrame.TextBoxCore.Text) 
                        end
                    end
                end)

            end
		end
		return ElementFramework
	end

    function tself:Notify(Text,Duration)
        local Notify = Assets["Notif"]:Clone() 
        Notify.Parent = UI 
        Notify.TextLabel.Text = Text 
        Notify.TextLabel.TextTransparency = 1 
        Notify.BackgroundTransparency = 1 
        Notify.Visible = true
        Notify.ZIndex = 4
        UI.NotifBlinder.Visible = true 
        UI.NotifBlinder.BackgroundTransparency = 1
        UI.NotifBlinder.ZIndex = 4
        
        Internal:TweenAsset(Notify, 0.5, "Quad", "InOut", {BackgroundTransparency = 0}):Play()
        Internal:TweenAsset(Notify.TextLabel, 0.5, "Quad", "InOut", {TextTransparency = 0}):Play()
        Internal:TweenAsset(UI.NotifBlinder, 0.5, "Quad", "InOut", {BackgroundTransparency = 0}):Play()

        wait(0.5)

        wait(Duration) 

        Internal:TweenAsset(Notify, 0.5, "Quad", "InOut", {BackgroundTransparency = 1}):Play()
        Internal:TweenAsset(Notify.TextLabel, 0.5, "Quad", "InOut", {TextTransparency = 1}):Play()
        Internal:TweenAsset(UI.NotifBlinder, 0.5, "Quad", "InOut", {BackgroundTransparency = 1}):Play()

        wait(0.5)

        Notify:Destroy()
    end

	return tself
end
return Framework
