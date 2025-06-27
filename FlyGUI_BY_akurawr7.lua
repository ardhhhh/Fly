-- Load Kavo UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera
local Window = Library.CreateLib("Fly GUI BY akurawr7", "Ocean")

-- References
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")
player.CharacterAdded:Connect(function(c)
    char = c
    hrp = c:WaitForChild("HumanoidRootPart")
    humanoid = c:WaitForChild("Humanoid")
end)

-- TAB 1: Fly
local flyTab = Window:NewTab("Fly")
local flySection = flyTab:NewSection("Joystick Fly")
local flying, flySpeed, bv, bg = false, 60

flySection:NewButton("🛸 Toggle Fly", "Aktif/nonaktif fly", function()
    flying = not flying
    if flying then
        bv = Instance.new("BodyVelocity", hrp)
        bg = Instance.new("BodyGyro", hrp)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bv.P = 1250; bg.P = 3000
    else
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
end)
flySection:NewButton("⚡ Speed +", "", function() flySpeed = math.min(flySpeed + 10, 300) end)
flySection:NewButton("🐢 Speed -", "", function() flySpeed = math.max(flySpeed - 10, 10) end)

game:GetService("RunService").RenderStepped:Connect(function()
    if flying and bv and bg then
        local dir = humanoid.MoveDirection
        if dir.Magnitude > 0 then
            local v = camera.CFrame:VectorToWorldSpace(dir.Unit * flySpeed)
            bv.Velocity = v
        else bv.Velocity = Vector3.zero end
        bg.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z))
    end
end)

-- TAB 2: Control
local controlTab = Window:NewTab("Control")
local ctrl = controlTab:NewSection("Speed & Noclip")
ctrl:NewButton("🏃 WalkSpeed +", "", function() humanoid.WalkSpeed = math.min(humanoid.WalkSpeed + 5, 100) end)
ctrl:NewButton("🐌 WalkSpeed -", "", function() humanoid.WalkSpeed = math.max(humanoid.WalkSpeed - 5, 5) end)
ctrl:NewButton("🔁 Reset Speed", "", function() humanoid.WalkSpeed = 16 end)
local noclip = false
ctrl:NewToggle("🚧 Noclip", "", function(s) noclip = s end)
game:GetService("RunService").Stepped:Connect(function()
    if noclip then
        for _,v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- TAB 3: Teleport
local tpTab = Window:NewTab("Teleport")
tpTab:NewSection("Ke Player"):NewDropdown("Pilih Player", "", (function()
    local t = {}
    for _, p in pairs(game.Players:GetPlayers()) do if p~=player then table.insert(t, p.Name) end end
    return t
end)(), function(plr)
    local t = game.Players:FindFirstChild(plr)
    if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
        hrp.CFrame = t.Character.HumanoidRootPart.CFrame + Vector3.new(2,0,0)
    end
end)

-- GUI Show/Hide
local core = game:GetService("CoreGui")
local mainGui
for _, gui in ipairs(core:GetChildren()) do
    if gui:IsA("ScreenGui") and gui:FindFirstChild("MainFrame", true) then mainGui = gui break end
end
local showBtn = Instance.new("TextButton")
showBtn.Size = UDim2.new(0,120,0,40); showBtn.Position = UDim2.new(0,10,1,-60)
showBtn.Text = "📂 Show GUI"; showBtn.Parent = PlayerGui; showBtn.Visible = false
showBtn.BackgroundColor3,showBtn.TextColor3 = Color3.fromRGB(40,40,40),Color3.new(1,1,1)
showBtn.Font,showBtn.TextSize = Enum.Font.GothamBold,16
Instance.new("UICorner",showBtn).CornerRadius = UDim.new(0,8)
showBtn.MouseButton1Click:Connect(function()
    mainGui.Enabled = true; showBtn.Visible = false
end)
task.delay(2, function()
    if mainGui then
        local hdr = mainGui:FindFirstChild("MainFrame", true):FindFirstChildWhichIsA("Frame",true)
        if hdr then
            local hideBtn = Instance.new("TextButton")
            hideBtn.Size = UDim2.new(0,40,0,30); hideBtn.Position = UDim2.new(1,-95,0,5)
            hideBtn.Text="🕶️"; hideBtn.Parent=hdr
            hideBtn.BackgroundColor3,hideBtn.TextColor3 = Color3.fromRGB(50,50,50),Color3.new(1,1,1)
            hideBtn.Font,hideBtn.TextSize = Enum.Font.GothamBold,18
            Instance.new("UICorner",hideBtn).CornerRadius=UDim.new(0,8)
            hideBtn.MouseButton1Click:Connect(function()
                mainGui.Enabled=false; showBtn.Visible=true
            end)
        end
    end
end)

-- FIX: Allow Drag on Mobile
task.delay(2, function()
    local UIS = game:GetService("UserInputService")
    for _,frame in pairs(core:GetDescendants()) do
        if frame:IsA("Frame") and frame.Name=="MainFrame" and frame.Visible and frame.AbsoluteSize.X>200 then
            frame.Active = true
            local dragging, dragStart, startPos = false
            frame.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
                    dragging=true; dragStart=i.Position; startPos=frame.Position
                    i.Changed:Connect(function()
                        if i.UserInputState==Enum.UserInputState.End then dragging=false end
                    end)
                end
            end)
            UIS.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then
                    local delta = i.Position - dragStart
                    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
            break
        end
    end
end)
