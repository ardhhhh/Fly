-- Load Kavo UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local Window = Library.CreateLib("Fly GUI BY akurawr7", "Ocean")

-- Basic Character
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")
player.CharacterAdded:Connect(function(c)
    char = c
    hrp = c:WaitForChild("HumanoidRootPart")
    humanoid = c:WaitForChild("Humanoid")
end)

-- ========== TAB 1: FLY ==========
local flyTab = Window:NewTab("Fly")
local flySection = flyTab:NewSection("Joystick Fly")

local flying = false
local flySpeed = 60
local bv, bg

flySection:NewButton("🛸 Toggle Fly", "Aktif/nonaktif fly", function()
    flying = not flying
    if flying then
        bv = Instance.new("BodyVelocity", hrp)
        bg = Instance.new("BodyGyro", hrp)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bv.P = 1250
        bg.P = 3000
    else
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
        bv, bg = nil, nil
    end
end)

flySection:NewButton("⚡ Speed +", "Tambah kecepatan", function()
    flySpeed = math.min(flySpeed + 10, 300)
end)
flySection:NewButton("🐢 Speed -", "Kurangi kecepatan", function()
    flySpeed = math.max(flySpeed - 10, 10)
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if flying and bv and bg and hrp and humanoid then
        local moveDir = humanoid.MoveDirection
        if moveDir.Magnitude > 0 then
            local dir = camera.CFrame:VectorToWorldSpace(moveDir)
            bv.Velocity = dir.Unit * flySpeed
        else
            bv.Velocity = Vector3.zero
        end
        bg.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z))
    end
end)

-- ========== TAB 2: CONTROL ==========
local controlTab = Window:NewTab("Control")
local controlSection = controlTab:NewSection("Speed & Noclip")

controlSection:NewButton("🏃 WalkSpeed +", "Tambah speed jalan", function()
    humanoid.WalkSpeed = math.min(humanoid.WalkSpeed + 5, 100)
end)
controlSection:NewButton("🐌 WalkSpeed -", "Kurangi speed jalan", function()
    humanoid.WalkSpeed = math.max(humanoid.WalkSpeed - 5, 5)
end)
controlSection:NewButton("🔁 Reset Speed", "16 normal", function()
    humanoid.WalkSpeed = 16
end)

local noclip = false
controlSection:NewToggle("🚧 Noclip", "Lewat tembok", function(state)
    noclip = state
end)
game:GetService("RunService").Stepped:Connect(function()
    if noclip and char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide == true then
                v.CanCollide = false
            end
        end
    end
end)

-- ========== TAB 3: TELEPORT ==========
local tpTab = Window:NewTab("Teleport")
local tpSection = tpTab:NewSection("Ke Player")

local playerList = {}
for _, p in pairs(game.Players:GetPlayers()) do
    if p ~= player then table.insert(playerList, p.Name) end
end
game.Players.PlayerAdded:Connect(function(p)
    table.insert(playerList, p.Name)
end)
game.Players.PlayerRemoving:Connect(function(p)
    for i, name in pairs(playerList) do
        if name == p.Name then table.remove(playerList, i) break end
    end
end)

tpSection:NewDropdown("Pilih Player", "Teleport ke mereka", playerList, function(name)
    local target = game.Players:FindFirstChild(name)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(2, 0, 0)
    end
end)

-- ========== 🕶️ SAMPING X ==========
local core = game:GetService("CoreGui")
local mainGui
for _, gui in ipairs(core:GetChildren()) do
    if gui:IsA("ScreenGui") and gui:FindFirstChild("MainFrame", true) then
        mainGui = gui
        break
    end
end

local showBtn = Instance.new("TextButton")
showBtn.Size = UDim2.new(0, 120, 0, 40)
showBtn.Position = UDim2.new(0, 10, 1, -60)
showBtn.Text = "📂 Show GUI"
showBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
showBtn.TextColor3 = Color3.new(1, 1, 1)
showBtn.Font = Enum.Font.GothamBold
showBtn.TextSize = 16
showBtn.Visible = false
showBtn.ZIndex = 999999
showBtn.Parent = PlayerGui
Instance.new("UICorner", showBtn).CornerRadius = UDim.new(0, 8)

showBtn.MouseButton1Click:Connect(function()
    if mainGui then
        mainGui.Enabled = true
        showBtn.Visible = false
    end
end)

task.delay(2, function()
    if not mainGui then return end
    local header = mainGui:FindFirstChild("MainFrame", true):FindFirstChildWhichIsA("Frame", true)
    if header then
        local hideBtn = Instance.new("TextButton")
        hideBtn.Size = UDim2.new(0, 40, 0, 30)
        hideBtn.Position = UDim2.new(1, -95, 0, 5)
        hideBtn.Text = "🕶️"
        hideBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        hideBtn.TextColor3 = Color3.new(1, 1, 1)
        hideBtn.Font = Enum.Font.GothamBold
        hideBtn.TextSize = 18
        hideBtn.ZIndex = 999999
        hideBtn.Parent = header
        Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0, 8)

        hideBtn.MouseButton1Click:Connect(function()
            mainGui.Enabled = false
            showBtn.Visible = true
        end)
    end
end)

task.delay(2, function()
    local UIS = game:GetService("UserInputService")
    for _, frame in pairs(core:GetDescendants()) do
        if frame:IsA("Frame") and frame.Visible and frame.AbsoluteSize.X > 200 then
            local dragging, dragInput, dragStart, startPos
            frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    dragStart = input.Position
                    startPos = frame.Position
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragging = false
                        end
                    end)
                end
            end)
            frame.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
                    dragInput = input
                end
            end)
            UIS.InputChanged:Connect(function(input)
                if input == dragInput and dragging then
                    local delta = input.Position - dragStart
                    frame.Position = UDim2.new(
                        startPos.X.Scale,
                        startPos.X.Offset + delta.X,
                        startPos.Y.Scale,
                        startPos.Y.Offset + delta.Y
                    )
                end
            end)
            break
        end
    end
end)
