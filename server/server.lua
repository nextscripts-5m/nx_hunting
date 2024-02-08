local ox_inventory = exports.ox_inventory

RegisterNetEvent('giveInventoryItem', function (animalZone, item, count)
    local source    = source
    local success   = false
    local animals   = Config.Zones[animalZone].Animals
        
    for _, animal in pairs(animals) do
        if CheckLoot(animal.loots, item) then
            success = true
            if count > 0 then
                ox_inventory:AddItem(source, item, count)
                break
            end
        end
    end


    if not success then
        Config.BanFunction()
        print(("%s it's probably a cheater"):format(GetPlayerName(source)))
    end
end)

CheckLoot = function (t, e)
    for k, v in pairs(t) do
        if v == e then
            return true
        end
    end
    return false
end