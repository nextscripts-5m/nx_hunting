RegisterNetEvent('giveInventoryItem', function (item, count)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem(item, count)
end)