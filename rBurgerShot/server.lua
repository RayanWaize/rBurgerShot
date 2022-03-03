local ESX
local societyName = "society_burgershot"

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
TriggerEvent('esx_society:registerSociety', 'burgershot', 'Burger Shot', 'society_burgershot', 'society_burgershot', 'society_burgershot', {type = 'private'})

RegisterServerEvent('rBurgerShot:deliveryAdd')
AddEventHandler('rBurgerShot:deliveryAdd', function(price, itemNmae)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	TriggerEvent('esx_addonaccount:getSharedAccount', societyName, function(account)
        if account then
            if account.money >= price then
                xPlayer.addInventoryItem(itemNmae, 1)
                account.removeMoney(price)
            else
                TriggerClientEvent('esx:showAdvancedNotification', _src, 'Burger Shot', '~r~Erreur', 'Votre entreprise n\'a pas assez d\'argent ~r~!', 'CHAR_DREYFUSS', 9)
            end
        end
    end)
end)

RegisterServerEvent('rBurgerShot:createBurger')
AddEventHandler('rBurgerShot:createBurger', function(itemName, ingredients)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	if xPlayer.getInventoryItem(ingredients[1].name).count >= ingredients[1].amout and xPlayer.getInventoryItem(ingredients[2].name).count >= ingredients[2].amout and xPlayer.getInventoryItem(ingredients[3].name).count >= ingredients[3].amout and xPlayer.getInventoryItem(ingredients[4].name).count >= ingredients[4].amout then
		TriggerClientEvent('rBurgerShot:animationCreateFood', _src)
		Citizen.Wait(21000)
		for k,v in pairs(ingredients) do
			xPlayer.removeInventoryItem(v.name, v.amout)
		end
		xPlayer.addInventoryItem(itemName, 1)
	else
		TriggerClientEvent('esx:showAdvancedNotification', _src, 'Burger Shot', '~r~Erreur', "Il vous manque de(s) ingrédient(s) ~r~!", 'CHAR_DREYFUSS', 9)
	end
end)


ESX.RegisterServerCallback('rBurgerShot:getStockItems', function(source, cb)
	TriggerEvent('esx_addoninventory:getSharedInventory', societyName, function(inventory)
		cb(inventory.items)
	end)
end)

RegisterNetEvent('rBurgerShot:getStockItem')
AddEventHandler('rBurgerShot:getStockItem', function(itemName, count)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)

	TriggerEvent('esx_addoninventory:getSharedInventory', societyName, function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- is there enough in the society?
		if count > 0 and inventoryItem.count >= count then

			-- can the player carry the said amount of x item?
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				TriggerClientEvent('esx:showAdvancedNotification', _src, 'Coffre', '~o~Informations~s~', 'Vous avez retiré ~r~'..inventoryItem.label.." x"..count, 'CHAR_MP_FM_CONTACT', 8)
		else
			TriggerClientEvent('esx:showAdvancedNotification', _src, 'Coffre', '~o~Informations~s~', "Quantité ~r~invalide", 'CHAR_MP_FM_CONTACT', 9)
		end
	end)
end)

ESX.RegisterServerCallback('rBurgerShot:getPlayerInventory', function(source, cb)
    local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	local items   = xPlayer.inventory

	cb({items = items})
end)

RegisterNetEvent('rBurgerShot:putStockItems')
AddEventHandler('rBurgerShot:putStockItems', function(itemName, count)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', societyName, function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- does the player have enough of the item?
		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('esx:showAdvancedNotification', _src, 'Coffre', '~o~Informations~s~', 'Vous avez déposé ~g~'..inventoryItem.label.." x"..count, 'CHAR_MP_FM_CONTACT', 8)
		else
			TriggerClientEvent('esx:showAdvancedNotification', _src, 'Coffre', '~o~Informations~s~', "Quantité ~r~invalide", 'CHAR_MP_FM_CONTACT', 9)
		end
	end)
end)