local Config = {}

Config.StartingCash = 250
Config.MaxEggs = 8
Config.BaseCount = 6
Config.SaveKey = "StealAnEgg_v1"

Config.Eggs = {
	{ id = "Common", name = "Ovo Comum", price = 100, income = 2, color = Color3.fromRGB(245, 245, 220) },
	{ id = "Forest", name = "Ovo da Floresta", price = 350, income = 7, color = Color3.fromRGB(92, 180, 92) },
	{ id = "Ocean", name = "Ovo do Oceano", price = 900, income = 18, color = Color3.fromRGB(70, 150, 255) },
	{ id = "Lava", name = "Ovo de Lava", price = 2500, income = 55, color = Color3.fromRGB(255, 91, 45) },
	{ id = "Golden", name = "Ovo Dourado", price = 8000, income = 190, color = Color3.fromRGB(255, 210, 55) },
}

function Config.GetEgg(id)
	for _, egg in Config.Eggs do
		if egg.id == id then
			return egg
		end
	end
end

return Config
