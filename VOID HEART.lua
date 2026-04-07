--// =========================
--// VOID HEART
--// =========================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// CLEAR OLD UI
if PlayerGui:FindFirstChild("VOIDHEART") then
    PlayerGui.VOIDHEART:Destroy()
end

--// =========================
--// NETWORK & LOGIC
--// =========================
if not getgenv().Network then
    getgenv().Network = {
        BaseParts = {},
        Velocity = Vector3.new(14.4626, 14.4626, 14.4626)
    }

    RunService.Heartbeat:Connect(function()
        pcall(function()
            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
        end)
        for _, p in ipairs(getgenv().Network.BaseParts) do
            if p:IsDescendantOf(workspace) then
                p.Velocity = getgenv().Network.Velocity
            end
        end
    end)
end

--// VARIABLES
local OrbitEnabled = false
local ScriptRunning = true
local PlayerState = {}
local parts = {}
local currentRadius = 50

local function valid(p)
    return p:IsA("BasePart") and not p.Anchored and not p:IsDescendantOf(LocalPlayer.Character)
end

for _, d in ipairs(workspace:GetDescendants()) do if valid(d) then table.insert(parts, d) end end
workspace.DescendantAdded:Connect(function(p) if valid(p) then table.insert(parts, p) end end)

--// =========================
--// GUI ROOT
--// =========================
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "VOIDHEART"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 320, 0, 420) 
main.Position = UDim2.new(0.5, -160, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Active = true

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Color3.fromRGB(255, 255, 255)
mainStroke.Thickness = 1

--// TITLE BAR (NEGRA) - ZONA DE DRAG
local title = Instance.new("Frame", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
title.BorderSizePixel = 0
title.Active = true -- Necesario para detectar inputs de arrastre

local titleText = Instance.new("TextLabel", title)
titleText.Size = UDim2.new(1, -100, 1, 0)
titleText.Position = UDim2.new(0, 15, 0, 0)
titleText.Text = "VOID HEART"
titleText.Font = Enum.Font.Code
titleText.TextSize = 16
titleText.TextColor3 = Color3.new(1, 1, 1)
titleText.BackgroundTransparency = 1
titleText.TextXAlignment = Enum.TextXAlignment.Left

--// RAYA BLANCA DIVISORA
local separator = Instance.new("Frame", title)
separator.Size = UDim2.new(1, 0, 0, 2)
separator.Position = UDim2.new(0, 0, 1, 0)
separator.BackgroundColor3 = Color3.new(1, 1, 1)
separator.BorderSizePixel = 0

--// SISTEMA DE DRAG (IMPLEMENTACIÓN)
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

title.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = true
        dragStart = input.Position
        startPos = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

--// BOTÓN X (BLANCO)
local closeBtn = Instance.new("TextButton", title)
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -35, 0, 2)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.Code
closeBtn.TextColor3 = Color3.new(1, 1, 1) 
closeBtn.BackgroundTransparency = 1
closeBtn.TextSize = 20

closeBtn.MouseButton1Click:Connect(function()
    ScriptRunning = false
    gui:Destroy()
end)

--// BOTÓN - (MINIMIZAR)
local miniBtn = Instance.new("TextButton", title)
miniBtn.Size = UDim2.new(0, 35, 0, 35)
miniBtn.Position = UDim2.new(1, -70, 0, 2)
miniBtn.Text = "-"
miniBtn.Font = Enum.Font.Code
miniBtn.TextColor3 = Color3.new(1, 1, 1)
miniBtn.BackgroundTransparency = 1
miniBtn.TextSize = 25

local isMinimized = false
miniBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        main:TweenSize(UDim2.new(0, 320, 0, 42), "Out", "Quad", 0.2, true)
    else
        main:TweenSize(UDim2.new(0, 320, 0, 420), "Out", "Quad", 0.2, true)
    end
end)

--// CONTENT CONTAINER
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, 0, 1, -42)
content.Position = UDim2.new(0, 0, 0, 42)
content.BackgroundTransparency = 1

--// SEARCH BAR
local search = Instance.new("TextBox", content)
search.Size = UDim2.new(0.9, 0, 0, 30)
search.Position = UDim2.new(0.05, 0, 0.05, 0)
search.PlaceholderText = "[ SEARCH PLAYER ]"
search.Text = ""
search.Font = Enum.Font.Code
search.TextSize = 14
search.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
search.TextColor3 = Color3.new(1, 1, 1)
search.BorderColor3 = Color3.new(1, 1, 1)

--// PLAYER LIST
local list = Instance.new("ScrollingFrame", content)
list.Position = UDim2.new(0.05, 0, 0.16, 0)
list.Size = UDim2.new(0.9, 0, 0, 180)
list.BackgroundTransparency = 1
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0, 3)

--// RADIUS CONTROLS
local radFrame = Instance.new("Frame", content)
radFrame.Size = UDim2.new(0.9, 0, 0, 40)
radFrame.Position = UDim2.new(0.05, 0, 0.68, 0)
radFrame.BackgroundTransparency = 1

local radiusInput = Instance.new("TextBox", radFrame)
radiusInput.Size = UDim2.new(0.4, 0, 1, 0)
radiusInput.Position = UDim2.new(0.3, 0, 0, 0)
radiusInput.Text = tostring(currentRadius)
radiusInput.Font = Enum.Font.Code
radiusInput.TextColor3 = Color3.new(1, 1, 1)
radiusInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
radiusInput.BorderColor3 = Color3.new(1, 1, 1)

local inc = Instance.new("TextButton", radFrame)
inc.Size = UDim2.new(0, 40, 1, 0)
inc.Position = UDim2.new(0.75, 0, 0, 0)
inc.Text = "+"
inc.TextColor3 = Color3.new(1, 1, 1)
inc.BackgroundColor3 = Color3.new(0, 0, 0)
inc.BorderColor3 = Color3.new(1, 1, 1)

local dec = Instance.new("TextButton", radFrame)
dec.Size = UDim2.new(0, 40, 1, 0)
dec.Position = UDim2.new(0.1, 0, 0, 0)
dec.Text = "-"
dec.TextColor3 = Color3.new(1, 1, 1)
dec.BackgroundColor3 = Color3.new(0, 0, 0)
dec.BorderColor3 = Color3.new(1, 1, 1)

radiusInput.FocusLost:Connect(function() currentRadius = tonumber(radiusInput.Text) or currentRadius end)
inc.MouseButton1Click:Connect(function() currentRadius = currentRadius + 5 radiusInput.Text = tostring(currentRadius) end)
dec.MouseButton1Click:Connect(function() currentRadius = math.max(5, currentRadius - 5) radiusInput.Text = tostring(currentRadius) end)

--// MASTER SWITCH (BLANCO PERPETUO)
local toggle = Instance.new("TextButton", content)
toggle.Size = UDim2.new(0.8, 0, 0, 45)
toggle.Position = UDim2.new(0.1, 0, 0.85, 0)
toggle.Text = "ORBIT: OFF"
toggle.Font = Enum.Font.Code
toggle.TextSize = 18
toggle.TextColor3 = Color3.new(0, 0, 0) 
toggle.BackgroundColor3 = Color3.new(1, 1, 1) -- Blanco
toggle.BorderSizePixel = 0

toggle.MouseButton1Click:Connect(function()
    OrbitEnabled = not OrbitEnabled
    toggle.Text = OrbitEnabled and "ORBIT: ON" or "ORBIT: OFF"
end)

--// LIST LOGIC
local function rebuild(filter)
    for _, v in pairs(list:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local name = (plr.DisplayName.." "..plr.Name):lower()
            if filter and not name:find(filter) then continue end

            local btn = Instance.new("TextButton", list)
            btn.Size = UDim2.new(1, -5, 0, 35)
            btn.Text = "  " .. plr.DisplayName:upper()
            btn.Font = Enum.Font.Code
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            btn.BorderColor3 = Color3.fromRGB(60, 60, 60)
            
            btn.MouseButton1Click:Connect(function()
                PlayerState[plr] = (PlayerState[plr] == "Orbiting") and "Idle" or "Orbiting"
                btn.BackgroundColor3 = (PlayerState[plr] == "Orbiting") and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(20, 20, 20)
            end)
        end
    end
    list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end

search:GetPropertyChangedSignal("Text"):Connect(function() rebuild(search.Text:lower()) end)
Players.PlayerAdded:Connect(rebuild)
Players.PlayerRemoving:Connect(rebuild)
rebuild()

--// ORBIT LOOP
RunService.Heartbeat:Connect(function()
    if not OrbitEnabled or not ScriptRunning then return end
    for plr, state in pairs(PlayerState) do
        if state == "Orbiting" and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local center = plr.Character.HumanoidRootPart.Position
            for _, part in ipairs(parts) do
                if part.Parent and part:IsA("BasePart") then
                    local pos = part.Position
                    local angle = math.atan2(pos.Z - center.Z, pos.X - center.X) + 0.02
                    local target = Vector3.new(
                        center.X + math.cos(angle) * currentRadius,
                        center.Y,
                        center.Z + math.sin(angle) * currentRadius
                    )
                    part.Velocity = (target - pos).Unit * 1200
                end
            end
        end
    end
end)

StarterGui:SetCore("SendNotification", {Title = "VOID HEART", Text = "Creditos a: NULL | Drag añadido", Duration = 5})
