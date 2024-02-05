local ox_inventory = exports.ox_inventory

RegisterNetEvent('giveInventoryItem', function (item, count)
    for _, i in pairs(Config.Items) do
        if Config.Cheater.Ban then
            if count == nil then print(GetPlayerName(source).." is a cheater (count is nil)") Config.Cheater.BanFunction(source) return end
            if count > Config.MaximumItemsPerKill then print(GetPlayerName(source).." is a cheater (tried to give more items then "..Config.MaximumItemsPerKill..")") Config.Cheater.BanFunction(source) return end
            if item == nil then print(GetPlayerName(source).." is a cheater (item is nil)") Config.Cheater.BanFunction(source) return end
        else
            if count == nil then print(GetPlayerName(source).." is a cheater (count is nil)") return end
            if count > Config.MaximumItemsPerKill then print(GetPlayerName(source).." is a cheater (tried to give more items then "..Config.MaximumItemsPerKill..")") return end
            if item == nil then print(GetPlayerName(source).." is a cheater (item is nil)")  return end
        end
        if count > 0 and item == i then
            ox_inventory:AddItem(source, item, count)
        end
    end
end)
