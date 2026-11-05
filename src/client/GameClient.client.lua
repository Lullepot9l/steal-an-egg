local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "EggHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(300, 94)
panel.Position = UDim2.fromOffset(20, 20)
panel.BackgroundColor3 = Color3.fromRGB(28, 30, 42)
panel.BackgroundTransparency = 0.08
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -24, 0, 34)
title.Position = UDim2.fromOffset(12, 8)
title.BackgroundTransparency = 1
title.Text = "🥚 STEAL AN EGG"
title.TextColor3 = Color3.fromRGB(255, 227, 100)
title.TextScaled = true
title.Font = Enum.Font.GothamBlack
title.Parent = panel

local cashLabel = Instance.new("TextLabel")
cashLabel.Size = UDim2.new(1, -24, 0, 32)
cashLabel.Position = UDim2.fromOffset(12, 48)
cashLabel.BackgroundTransparency = 1
cashLabel.TextColor3 = Color3.new(1, 1, 1)
cashLabel.TextScaled = true
cashLabel.Font = Enum.Font.GothamBold
cashLabel.Parent = panel

local hint = Instance.new("TextLabel")
hint.AnchorPoint = Vector2.new(0.5, 1)
hint.Size = UDim2.fromOffset(650, 42)
hint.Position = UDim2.new(0.5, 0, 1, -20)
hint.BackgroundColor3 = Color3.fromRGB(28, 30, 42)
hint.BackgroundTransparency = 0.15
hint.Text = "Compre ovos no centro • Roube ovos rivais • Leve-os até a área verde da sua base"
hint.TextColor3 = Color3.new(1, 1, 1)
hint.TextScaled = true
hint.Font = Enum.Font.GothamMedium
hint.Parent = gui
Instance.new("UICorner", hint).CornerRadius = UDim.new(0, 12)

local cash = player:WaitForChild("leaderstats"):WaitForChild("Cash")
local function update() cashLabel.Text = string.format("💵 $%d", cash.Value) end
cash:GetPropertyChangedSignal("Value"):Connect(update)
update()
