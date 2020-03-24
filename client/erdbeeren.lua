local spawnedErdbeerens = 0
local erdbeerenPlants = {}
local isPickingUp, isProcessing = false, false


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		local coords = GetEntityCoords(PlayerPedId())

		if GetDistanceBetweenCoords(coords, Config.CircleZones.ErdbeerenField.coords, true) < 50 then
			SpawnerdbeerenPlants()
			Citizen.Wait(500)
		else
			Citizen.Wait(500)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)

		if GetDistanceBetweenCoords(coords, Config.CircleZones.ErdbeerenProcessing.coords, true) < 5 then
			if not isProcessing then
				ESX.ShowHelpNotification(_U('erdbeeren_processprompt'))
			end

			if IsControlJustReleased(0, Keys['E']) and not isProcessing then

				if Config.LicenseEnable then
					ESX.TriggerServerCallback('esx_license:checkLicense', function(hasProcessingLicense)
						if hasProcessingLicense then
							ProcessErdbeeren()
						else
							OpenBuyLicenseMenu('erdbeeren_processing')
						end
					end, GetPlayerServerId(PlayerId()), 'erdbeeren_processing')
				else
					ProcessErdbeeren()
				end

			end
		else
			Citizen.Wait(500)
		end
	end
end)

function ProcessErdbeeren()
	isProcessing = true

	ESX.ShowNotification(_U('erdbeeren_processingstarted'))
	TriggerServerEvent('esx_legalfarming:processErdbeeren')
	local timeLeft = Config.Delays.ErdbeerenProcessing / 1000
	local playerPed = PlayerPedId()

	while timeLeft > 0 do
		Citizen.Wait(1000)
		timeLeft = timeLeft - 1

		if GetDistanceBetweenCoords(GetEntityCoords(playerPed), Config.CircleZones.ErdbeerenProcessing.coords, false) > 5 then
			ESX.ShowNotification(_U('erdbeeren_processingtoofar'))
			TriggerServerEvent('esx_legalfarming:cancelProcessing')
			break
		end
	end

	isProcessing = false
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)
		local nearbyObject, nearbyID

		for i=1, #erdbeerenPlants, 1 do
			if GetDistanceBetweenCoords(coords, GetEntityCoords(erdbeerenPlants[i]), false) < 1 then
				nearbyObject, nearbyID = erdbeerenPlants[i], i
			end
		end

		if nearbyObject and IsPedOnFoot(playerPed) then

			if not isPickingUp then
				ESX.ShowHelpNotification(_U('erdbeeren_pickupprompt'))
			end

			if IsControlJustReleased(0, Keys['E']) and not isPickingUp then
				isPickingUp = true

				ESX.TriggerServerCallback('esx_legalfarming:canPickUp', function(canPickUp)

					if canPickUp then
						TaskStartScenarioInPlace(playerPed, 'world_human_gardener_plant', 0, false)

						Citizen.Wait(2000)
						ClearPedTasks(playerPed)
						Citizen.Wait(1500)
		
						ESX.Game.DeleteObject(nearbyObject)
		
						table.remove(erdbeerenPlants, nearbyID)
						spawnedErdbeerens = spawnedErdbeerens - 1
		
						TriggerServerEvent('esx_legalfarming:pickedUpErdbeeren')
					else
						ESX.ShowNotification(_U('erdbeeren_inventoryfull'))
					end

					isPickingUp = false

				end, 'erdbeeren')
			end

		else
			Citizen.Wait(500)
		end

	end

end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in pairs(erdbeerenPlants) do
			ESX.Game.DeleteObject(v)
		end
	end
end)

function SpawnerdbeerenPlants()
	while spawnedErdbeerens < 15 do
		Citizen.Wait(0)
		local erdbeerenCoords = GenerateErdbeerenCoords()

		ESX.Game.SpawnLocalObject('prop_weed_01', erdbeerenCoords, function(obj)
			PlaceObjectOnGroundProperly(obj)
			FreezeEntityPosition(obj, true)

			table.insert(erdbeerenPlants, obj)
			spawnedErdbeerens = spawnedErdbeerens + 1
		end)
	end
end

function ValidateErdbeerenCoord(plantCoord)
	if spawnedErdbeerens > 0 then
		local validate = true

		for k, v in pairs(erdbeerenPlants) do
			if GetDistanceBetweenCoords(plantCoord, GetEntityCoords(v), true) < 5 then
				validate = false
			end
		end

		if GetDistanceBetweenCoords(plantCoord, Config.CircleZones.ErdbeerenField.coords, false) > 50 then
			validate = false
		end

		return validate
	else
		return true
	end
end

function GenerateErdbeerenCoords()
	while true do
		Citizen.Wait(1)

		local erdbeerenCoordX, erdbeerenCoordY

		math.randomseed(GetGameTimer())
		local modX = math.random(-20, 20)

		Citizen.Wait(100)

		math.randomseed(GetGameTimer())
		local modY = math.random(-20, 20)

		erdbeerenCoordX = Config.CircleZones.ErdbeerenField.coords.x + modX
		erdbeerenCoordY = Config.CircleZones.ErdbeerenField.coords.y + modY

		local coordZ = GetCoordZErdbeeren(erdbeerenCoordX, erdbeerenCoordY)
		local coord = vector3(erdbeerenCoordX, erdbeerenCoordY, coordZ)

		if ValidateErdbeerenCoord(coord) then
			return coord
		end
	end
end

function GetCoordZErdbeeren(x, y)
	local groundCheckHeights = { 50, 51.0, 52.0, 53.0, 54.0, 55.0, 56.0, 57.0, 58.0, 59.0, 60.0, 61.0, 62.0, 63.0, 64.0, 65.0, 66.0, 67.0, 68.0, 69.0, 70.0, 71.0, 72.0, 73.0, 74.0, 75.0, 76.0, 77.0, 78.0, 79.0, 80.0, 81.0, 82.0, 83.0, 84.0, 85.0, 86.0, 87.0, 88.0, 89.0, 90.0, 91.0, 92.0, 93.0, 94.0, 95.0, 96.0, 97.0, 98.0, 99.0, 100.0, 101.0, 102.0, 103.0, 104.0, 105.0, 106.0, 107.0, 108.0, 109.0, 110.0, 111.0, 112.0, 113.0, 114.0, 115.0, 116.0, 117.0, 118.0, 119.0, 120.0, 121.0, 122.0, 123.0, 124.0, 125.0, 126.0, 127.0, 128.0, 129.0, 130.0, 131.0, 132.0, 134.0, 135.0, 136.0, 137.0, 138.0, 139.0, 140.0 }

	for i, height in ipairs(groundCheckHeights) do
		local foundGround, z = GetGroundZFor_3dCoord(x, y, height)

		if foundGround then
			return z
		end
	end

	return 53.85
end