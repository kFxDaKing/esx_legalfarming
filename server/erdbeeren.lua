local playersProcessingErdbeeren = {}

RegisterServerEvent('esx_legalfarming:pickedUpErdbeeren')
AddEventHandler('esx_legalfarming:pickedUpErdbeeren', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.canCarryItem('erdbeeren', 1) then
		xPlayer.addInventoryItem('erdbeeren', 1)
	else
		xPlayer.showNotification(_U('erdbeeren_inventoryfull'))
	end
end)

RegisterServerEvent('esx_legalfarming:processErdbeeren')
AddEventHandler('esx_legalfarming:processErdbeeren', function()
	if not playersProcessingErdbeeren[source] then
		local _source = source

		playersProcessingErdbeeren[_source] = ESX.SetTimeout(Config.Delays.ErdbeerenProcessing, function()
			local xPlayer = ESX.GetPlayerFromId(_source)
			local xErdbeeren = xPlayer.getInventoryItem('erdbeeren')

			if xErdbeeren.count > 3 then
				if xPlayer.canSwapItem('erdbeeren', 3, 'erdbeeren_bag', 1) then
					xPlayer.removeInventoryItem('erdbeeren', 3)
					xPlayer.addInventoryItem('erdbeeren_bag', 1)

					xPlayer.showNotification(_U('erdbeeren_processed'))
				else
					xPlayer.showNotification(_U('erdbeeren_processingfull'))
				end
			else
				xPlayer.showNotification(_U('erdbeeren_processingenough'))
			end

			playersProcessingErdbeeren[_source] = nil
		end)
	else
		print(('esx_legalfarming: %s attempted to exploit erdbeeren processing!'):format(GetPlayerIdentifiers(source)[1]))
	end
end)

function CancelProcessing(playerID)
	if playersProcessingErdbeeren[playerID] then
		ESX.ClearTimeout(playersProcessingErdbeeren[playerID])
		playersProcessingEerdbeeren[playerID] = nil
	end
end

RegisterServerEvent('esx_legalfarming:cancelProcessing')
AddEventHandler('esx_legalfarming:cancelProcessing', function()
	CancelProcessing(source)
end)

AddEventHandler('esx:playerDropped', function(playerID, reason)
	CancelProcessing(playerID)
end)

RegisterServerEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
	CancelProcessing(source)
end)
