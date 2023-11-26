local ox_inventory = exports.ox_inventory

RegisterNetEvent('giveInventoryItem', function (item, count)
    if count > 0 then
        ox_inventory:AddItem(source, item, count)
    end
end)