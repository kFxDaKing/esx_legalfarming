Config = {}

Config.Locale = 'de'

Config.Delays = {
	ErdbeerenProcessing = 1000 * 10,
}

Config.DealerItems = {
	erdbeeren_bag = 588,
}

Config.LicensePrices = {
	erdbeeren_processing = {label = _U('license_erdbeeren'), price = 15000}
}

Config.GiveBlack = false -- if you want for some reason blackmoney set it to True

Config.CircleZones = {
	--Erdbeeren
	ErdbeerenField = {coords = vector3(-1817.38, 2005.71, 126.37), name = _U('blip_ErdbeerenFarm'), color = 25, sprite = 496, radius = 100.0},
	ErdbeerenProcessing = {coords = vector3(-52.16, 1947.71, 190.19), name = _U('blip_Erdbeerenprocessing'), color = 25, sprite = 496, radius = 100.0},
	
	--Selling Point
	Dealer = {coords = vector3(230.38, -901.26, 30.69), name = _U('blip_dealer'), color = 6, sprite = 378, radius = 25.0},
	
}
