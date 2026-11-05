local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local store
pcall(function()
	store = DataStoreService:GetDataStore(Config.SaveKey)
end)

local world = Instance.new("Folder")
world.Name = "EggWorld"
world.Parent = workspace

local bases = {}
local profiles = {}
local carried = {}
local layoutBase

local function part(name, size, cframe, color, parent)
	local object = Instance.new("Part")
	object.Name = name
	object.Size = size
	object.CFrame = cframe
	object.Color = color
	object.Anchored = true
	object.TopSurface = Enum.SurfaceType.Smooth
	object.BottomSurface = Enum.SurfaceType.Smooth
	object.Parent = parent
	return object
end

local function label(adornee, text, offset)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(240, 60)
	gui.StudsOffset = offset or Vector3.new(0, 4, 0)
	gui.AlwaysOnTop = true
	gui.Adornee = adornee
	gui.Parent = adornee
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextStrokeTransparency = 0
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = gui
	return textLabel
end

local function makeEggModel(eggId, ownerId, position, parent)
	local info = Config.GetEgg(eggId)
	if not info then return end
	local model = Instance.new("Model")
	model.Name = info.name
	model:SetAttribute("EggId", eggId)
	model:SetAttribute("OwnerId", ownerId)
	model.Parent = parent
	local shell = Instance.new("Part")
	shell.Name = "Shell"
	shell.Shape = Enum.PartType.Ball
	shell.Size = Vector3.new(2.5, 3.2, 2.5)
	shell.CFrame = CFrame.new(position)
	shell.Color = info.color
	shell.Material = eggId == "Golden" and Enum.Material.Metal or Enum.Material.SmoothPlastic
	shell.Anchored = true
	shell.CanCollide = false
	shell.Parent = model
	model.PrimaryPart = shell
	label(shell, string.format("%s\n+$%d/s", info.name, info.income), Vector3.new(0, 2.7, 0))
	return model
end

local function getProfile(player)
	return profiles[player]
end

local function syncCash(player)
	local profile = getProfile(player)
	if profile and player:FindFirstChild("leaderstats") then
		player.leaderstats.Cash.Value = math.floor(profile.cash)
	end
end

local function cancelCarry(player)
	local item = carried[player]
	if not item then return end
	if item.visual then item.visual:Destroy() end
	local sourceProfile = item.source and getProfile(item.source)
	if sourceProfile and #sourceProfile.eggs < Config.MaxEggs then
		table.insert(sourceProfile.eggs, item.id)
		local sourceBase = sourceProfile.baseIndex and bases[sourceProfile.baseIndex]
		if sourceBase then layoutBase(sourceBase) end
	end
	carried[player] = nil
end

local function eggIncome(profile)
	local total = 0
	for _, id in profile.eggs do
		local info = Config.GetEgg(id)
		total += info and info.income or 0
	end
	return total
end

layoutBase = function(base)
	for _, child in base.eggsFolder:GetChildren() do child:Destroy() end
	local owner = base.owner
	if not owner then return end
	local profile = getProfile(owner)
	if not profile then return end
	for index, eggId in profile.eggs do
		local row = math.floor((index - 1) / 4)
		local column = (index - 1) % 4
		local position = (base.origin * CFrame.new(-7.5 + column * 5, 2, 3 + row * 6)).Position
		local model = makeEggModel(eggId, owner.UserId, position, base.eggsFolder)
		if model then
			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = "Roubar"
			prompt.ObjectText = model.Name
			prompt.HoldDuration = 1.5
			prompt.MaxActivationDistance = 10
			prompt.Parent = model.PrimaryPart
			prompt.Triggered:Connect(function(thief)
				if thief == owner or carried[thief] or not model.Parent then return end
				local thiefProfile = getProfile(thief)
				if not thiefProfile or #thiefProfile.eggs >= Config.MaxEggs then return end
				local char = thief.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				if not root then return end
				local sourceIndex = table.find(profile.eggs, eggId)
				if not sourceIndex then return end
				table.remove(profile.eggs, sourceIndex)
				carried[thief] = { id = eggId, source = owner }
				model:Destroy()
				local visual = makeEggModel(eggId, thief.UserId, root.Position + Vector3.new(0, 3, 2), char)
				if visual then
					visual.PrimaryPart.Anchored = false
					local weld = Instance.new("WeldConstraint")
					weld.Part0 = root
					weld.Part1 = visual.PrimaryPart
					weld.Parent = visual.PrimaryPart
					visual.PrimaryPart.CFrame = root.CFrame * CFrame.new(0, 2.8, 2)
					carried[thief].visual = visual
				end
				layoutBase(base)
			end)
		end
	end
end

local function buildWorld()
	part("Ground", Vector3.new(180, 1, 180), CFrame.new(0, -0.5, 0), Color3.fromRGB(86, 170, 74), world)
	local shop = part("Shop", Vector3.new(54, 1, 16), CFrame.new(0, 0.5, 0), Color3.fromRGB(55, 55, 68), world)
	label(shop, "LOJA DE OVOS", Vector3.new(0, 6, 0))
	for index, info in Config.Eggs do
		local x = (index - (#Config.Eggs + 1) / 2) * 9
		local pedestal = part(info.id, Vector3.new(6, 2, 6), CFrame.new(x, 1.5, 0), info.color, world)
		label(pedestal, string.format("%s\n$%d", info.name, info.price), Vector3.new(0, 3.5, 0))
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Comprar"
		prompt.ObjectText = info.name
		prompt.HoldDuration = 0.3
		prompt.Parent = pedestal
		prompt.Triggered:Connect(function(player)
			local profile = getProfile(player)
			local base = profile and bases[profile.baseIndex]
			if not profile or not base or profile.cash < info.price or #profile.eggs >= Config.MaxEggs then return end
			profile.cash -= info.price
			table.insert(profile.eggs, info.id)
			syncCash(player)
			layoutBase(base)
		end)
	end

	for index = 1, Config.BaseCount do
		local angle = (index - 1) * math.pi * 2 / Config.BaseCount
		local position = Vector3.new(math.cos(angle) * 62, 0, math.sin(angle) * 62)
		local origin = CFrame.lookAt(position, Vector3.new(0, 0, 0))
		local folder = Instance.new("Folder")
		folder.Name = "Base" .. index
		folder.Parent = world
		local floor = part("Floor", Vector3.new(28, 1, 24), origin * CFrame.new(0, 0.5, 0), Color3.fromRGB(86, 110, 155), folder)
		local ownerLabel = label(floor, "BASE LIVRE", Vector3.new(0, 5, -8))
		local deposit = part("Deposit", Vector3.new(24, 1, 5), origin * CFrame.new(0, 1.1, -8), Color3.fromRGB(80, 255, 130), folder)
		deposit.Transparency = 0.25
		label(deposit, "ENTREGUE O OVO AQUI", Vector3.new(0, 2, 0))
		local spawn = Instance.new("SpawnLocation")
		spawn.Name = "BaseSpawn"
		spawn.Size = Vector3.new(6, 1, 6)
		spawn.CFrame = origin * CFrame.new(0, 1.1, 8)
		spawn.Anchored = true
		spawn.Neutral = true
		spawn.Parent = folder
		local eggsFolder = Instance.new("Folder")
		eggsFolder.Name = "Eggs"
		eggsFolder.Parent = folder
		bases[index] = { folder = folder, floor = floor, deposit = deposit, spawn = spawn, origin = origin, ownerLabel = ownerLabel, eggsFolder = eggsFolder }
	end
end

buildWorld()

local function loadProfile(player)
	local data
	local ok = store ~= nil and pcall(function() data = store:GetAsync(tostring(player.UserId)) end)
	if not ok or type(data) ~= "table" then data = {} end
	local eggs = {}
	for _, id in data.eggs or {} do
		if Config.GetEgg(id) and #eggs < Config.MaxEggs then table.insert(eggs, id) end
	end
	return { cash = tonumber(data.cash) or Config.StartingCash, eggs = eggs, baseIndex = nil }
end

local function saveProfile(player)
	local profile = getProfile(player)
	if not profile or not store then return end
	pcall(function()
		store:UpdateAsync(tostring(player.UserId), function()
			return { cash = math.floor(profile.cash), eggs = profile.eggs }
		end)
	end)
end

local function claimBase(player)
	local profile = getProfile(player)
	for index, base in bases do
		if not base.owner then
			base.owner = player
			profile.baseIndex = index
			base.ownerLabel.Text = player.DisplayName .. "\n" .. #profile.eggs .. "/" .. Config.MaxEggs .. " ovos"
			player.RespawnLocation = base.spawn
			layoutBase(base)
			return
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	profiles[player] = loadProfile(player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Parent = stats
	claimBase(player)
	syncCash(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.Died:Connect(function() cancelCarry(player) end)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	cancelCarry(player)
	saveProfile(player)
	local profile = profiles[player]
	if profile and profile.baseIndex then
		local base = bases[profile.baseIndex]
		base.owner = nil
		base.ownerLabel.Text = "BASE LIVRE"
		for _, child in base.eggsFolder:GetChildren() do child:Destroy() end
	end
	profiles[player] = nil
end)

task.spawn(function()
	while true do
		task.wait(1)
		for player, profile in profiles do
			profile.cash += eggIncome(profile)
			syncCash(player)
			local base = profile.baseIndex and bases[profile.baseIndex]
			if base then base.ownerLabel.Text = player.DisplayName .. "\n" .. #profile.eggs .. "/" .. Config.MaxEggs .. " ovos" end
		end
	end
end)

RunService.Heartbeat:Connect(function()
	for player, item in carried do
		local profile = getProfile(player)
		local base = profile and profile.baseIndex and bases[profile.baseIndex]
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if base and root and (root.Position - base.deposit.Position).Magnitude < 9 then
			table.insert(profile.eggs, item.id)
			if item.visual then item.visual:Destroy() end
			carried[player] = nil
			layoutBase(base)
		end
	end
end)

game:BindToClose(function()
	for _, player in Players:GetPlayers() do saveProfile(player) end
end)
