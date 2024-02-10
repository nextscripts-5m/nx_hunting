local loaded    = false

AddEventHandler('onClientResourceStart', function (resource)
    if GetCurrentResourceName() == resource then
        if not loaded then return end
        ConfigureZones(Config.Zones)
        ConfigureBlips(Config.Debug, Config.Zones)
        loaded = true
    end
end)

PlayerLoaded = function()

    if loaded then return end
    ConfigureZones(Config.Zones)
    ConfigureBlips(Config.Debug, Config.Zones)
    loaded = true
end

if Config.Framework == "esx" then
    RegisterNetEvent("esx:playerLoaded", PlayerLoaded)
elseif Config.Framework == "qb" then
    RegisterNetEvent("QBCore:Client:OnPlayerLoaded", PlayerLoaded)
else
    print("Unsopported Framework")
    return
end


local isInArea              = false
-- it contains zone animals
local Animals               = {}
-- it contains animal npc's spawned
local AnimalsNPC            = {}
local ox_options            = {}
local animalID              = ''
local animalZone            = nil
local displayRadar          = not IsRadarHidden()
local charmedAnimals        = {}


---Get a random coord in a specific area
---@param _radius number the radius of the area
---@param _center vector3 the center of the area
---@param debug boolean shall we need the debug print now?
---@return vector3 safePosition the positiion in the world
local getRandomCoord = function (_radius, _center, debug)

    local reducedRadius = _radius - (_radius * 0.25)
    reducedRadius = math.min(80, reducedRadius)
    local radius = math.random(reducedRadius * 0.35, reducedRadius)
    local coords = _center

    local x = coords.x + math.random(-radius, radius)
    local y = coords.y + math.random(-radius, radius)
    local _, safeZ, safePosition

    _, safeZ = GetGroundZFor_3dCoord(x, y, coords.z, true)

    safePosition = vector3(x, y, safeZ)

    if Config.Debug and debug then
        print(Lang["spawning"]:format(safePosition, radius))
    end

   return safePosition
end

---Remove one element from table by key
---@param Table table table
---@param Key string the index in the table
local removeFromTable = function (Table, Key)
    for k, v in pairs(Table) do
        if v.npcEntity == Key then
            if Config.Debug then
                print(Lang["delete"]:format(v.npcEntity))
            end
            table.remove(Table, k)
        end
    end
end

---Handle the hunting
---@param data table
Hunt = function (data)

    for k, v in pairs(AnimalsNPC) do
        if v.npcEntity == data.entity then
            animalID = v.name
            RemoveBlip(v.blip)
        end
    end
    -- remove the ox_option
    exports.ox_target:removeLocalEntity(data.entity, ox_options.name)
    -- remove from the spawned animal npc's table
    removeFromTable(AnimalsNPC, data.entity)

    if Config.Progress == "ox_lib" then
        LibProgressConfiguration(data.entity)
    elseif Config.Progress == "rprogress" then
        RProgressConfiguration(data.entity)
    end


end

---Create the map blip for the entity
---@param entity number model entity
---@param scale number the scale of the blip
---@return number blip the created blip
local createBlipForEntity = function (entity, scale)
    local blip = AddBlipForEntity(entity)
    SetBlipScale(blip, scale)
    return blip
end

---Handle rarity
---@param rarity number
---@return boolean true if can spawn, else false
local handleRarity = function (rarity)
    local random = math.random(100)

    if random < rarity then
        return false
    end

    return true
end

---Handle the animal spawn
---@param huntZones table the table containing the hunt Zones
---@param zone string the index (key) in the Config.Zones table
local spawnAnimals = function (huntZones, zone)

    Animals = huntZones[zone].Animals

    Citizen.CreateThread(function ()

        local sleep = Config.SECONDS * 1
        while isInArea do

            if not (#AnimalsNPC > Config.MaxEntities) then

                for k, v in pairs(Animals) do

                    if handleRarity(v.rarity) then

                        if Config.Debug then
                            print(Lang["not-spawning"]:format(v.model))
                        end

                        sleep = Config.SECONDS * 5
                        Wait(sleep)
                        goto continue
                    end

                    local hashKey = GetHashKey(v.model)
                    RequestModel(hashKey)
                    while not HasModelLoaded(hashKey) do
                        Wait(1)
                    end

                    if not isInArea then return end

                    local animalNPC = CreatePed(4, hashKey, getRandomCoord(huntZones[zone].radius, huntZones[zone].position, true), 0.0, true, true)

                    local blip = createBlipForEntity(animalNPC, .65)

                    local coords = getRandomCoord(huntZones[zone].radius, huntZones[zone].position, false)

                    if Config.Debug then
                        print(Lang["moving-to"]:format(coords))
                    end

                    -- si muovono verso coords nell'area
                    TaskWanderInArea(animalNPC, coords.x, coords.y, coords.z ,  100, 10, 10)
                    -- si muovono a casa
                    --TaskWanderStandard(animalNPC, 6, 6)
                    SetBlockingOfNonTemporaryEvents(animalNPC, true)

                    table.insert(AnimalsNPC, {
                        npcEntity   = animalNPC,
                        npcCoords   = coords,
                        blip        = blip,
                        name        = k
                    })

                    -- animalID = k
                    animalZone = zone

                    exports.ox_target:addLocalEntity(animalNPC, {
                        label = 'Hunt',
                        name = 'hunt',
                        icon = 'fa-solid fa-eye',
                        distance = 1.7,
                        item = Config.Item,
                        onSelect = Hunt,
                        canInteract = function (entity, distance, coords, name, bone)
                            -- 1 - melee, 2 - explosive, 3 - any other
                            return IsPedArmed(PlayerPedId(), 1) and IsEntityDead(entity)
                        end,
                    })

                    Wait(Config.SECONDS * 15)
                    ::continue::
                end

            else

                sleep = Config.SECONDS * 5

                if Config.Debug then
                    print(Lang["max-entity"]:format(Config.MaxEntities))
                end
            end

            Wait(sleep)
        end
    end)
end

--- Remove options from the remaining animals
---@param Table table the table with npc Animals
---@param Name string the name of the ox option
local removeOptions = function (Table, Name)
    for k, v in pairs(Table) do
        exports.ox_target:removeLocalEntity(v.npcEntity, Name)
    end
end

---Remove animal map blips
---@param Table table animals npc table
local removeBlips = function (Table)
    for k, v in pairs(Table) do
        RemoveBlip(v.blip)
    end
end

---Handle the distance between hunting zones
---@param huntZones table table containing hunting zones
ConfigureZones = function (huntZones)

    for zone, postalCode in pairs(huntZones) do
        lib.zones.sphere({
            coords = postalCode.position,
            radius = postalCode.radius,
            onEnter = function(self, data)

                isInArea = true
                spawnAnimals(huntZones, zone)
                if Config.Debug then
                    print(Lang["we-are"]:format(zone))
                end

            end,
            onExit = function(self, data)

                if Config.Debug then
                    print(Lang["we-are-not"])
                end

                isInArea = false
                removeBlips(AnimalsNPC)
                removeOptions(AnimalsNPC, ox_options.name)
                AnimalsNPC = {}

            end,
            debug = false
        })
    end
end

---Blip configuraton
---@param configureBlip boolean debug mode
---@param huntZones table 
ConfigureBlips = function (configureBlip, huntZones)

    if configureBlip then
        for k, zone in pairs(huntZones) do

            local blip = AddBlipForRadius(zone.position, zone.radius)

            SetBlipColour(blip, zone.Blip.color)
            SetBlipAlpha (blip, 128)

            local blip = AddBlipForCoord(zone.position)

            SetBlipSprite(blip, zone.Blip.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale  (blip, 0.9)
            SetBlipColour (blip, zone.Blip.color)
            SetBlipAsShortRange(blip, true)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('Hunting Zone')
            EndTextCommandSetBlipName(blip)
        end
    end
end

---Pick random elements from a table
---@param Table table the table to iterate
---@param Count number number of elements
---@return table
local pickRandomElements = function (Table, Count)

    local count = 0
    local _table = {}

    if Config.Debug then
        print(Lang["charming"]:format(Count))
    end

    while count < Count do

        local animal = Table[math.random(#Table)].npcEntity

        table.insert(_table, animal)

        count = count + 1
        Wait(Config.SECONDS)
    end

    return _table
end

---ox_lib configuration
---@param entity number entity number
LibProgressConfiguration = function (entity)
    if OnStart(entity) then
        if lib.progressCircle({
            duration = 4000,
            label = "Hunting..",
            canCancel = true,
            useWhileDead = false,
            allowCuffed = false,
        }) then
            Complete(entity)
        end
    end
end

---rprogress configuration
---@param entity number entity number
RProgressConfiguration = function (entity)
    exports.rprogress:Custom({
        canCancel = true,
        cancelKey = 178,
        Duration = 4000,
        y = 0.7,
        Label = 'Hunting..',
        Color = "rgba(255, 255, 255, 1.0)",
        onStart = function ()
            OnStart(entity)
        end,

        onComplete = function ()
            Complete(entity)
        end
    })
end

OnStart = function (entity)
    -- animal
    if IsEntityDead(entity) then
        -- ClearPedTasksImmediately(entity)
        -- FreezeEntityPosition(entity, true)
    else
        return false
    end

    -- hunter
    FreezeEntityPosition(PlayerPedId(), true)
    DisableControlAction(2, 32, true )
    DisableControlAction(2, 33, true )
    DisableControlAction(2, 34, true )
    DisableControlAction(2, 35, true )

    local dict = 'mini@repair'
    local flag = 'fixing_a_ped'

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end

    RequestAnimSet( "move_ped_crouched" )
    while ( not HasAnimSetLoaded( "move_ped_crouched" ) ) do
        Wait(0)
    end

    SetPedMovementClipset(PlayerPedId(), "move_ped_crouched", 1)
    TaskPlayAnim(PlayerPedId(), dict, flag, 8.0, 8.0 , 8000, 16, 1, false, false, false)

    return true
end

---On Complete Function
---@param entity number entity number
Complete = function (entity)
    -- animal
    SetEntityHealth(entity, 0)
    -- FreezeEntityPosition(entity, false)

    --hunter
    ClearPedTasks(PlayerPedId())
    DisableControlAction(2, 32, false ) -- W
    DisableControlAction(2, 33, false ) -- A
    DisableControlAction(2, 34, false ) -- S
    DisableControlAction(2, 35, false ) -- D
    FreezeEntityPosition(PlayerPedId(), false)
    ResetPedMovementClipset(PlayerPedId(), 0)

    if Config.Debug then
        print(Lang["hunted"]:format(entity))
    end
    
    -- get the loots for that specific animal
    local loots =  Config.Zones[animalZone].Animals[animalID].loots
    -- we choose a random loot
    local loot = loots[math.random(1, #loots)]
    -- get a random quantity
    local count = math.random(0, Config.MaximumItemsPerKill)
    TriggerServerEvent('giveInventoryItem', animalZone, loot, count)
end

--- Commands

RegisterCommand('charm', function ()
    if isInArea then
        charmedAnimals = pickRandomElements(AnimalsNPC, math.random(0, #AnimalsNPC))
        for k, v in pairs(charmedAnimals) do

            ClearPedTasksImmediately(v)
            TaskGoToEntity(v, PlayerPedId(), -1, 1.0, 1.49, 0, 0)

            if Config.Debug then
                print(Lang["charmed"]:format(v))
            end
        end
        charmedAnimals = {}
    end
end, false)
RegisterKeyMapping('charm', 'Charm animals', 'keyboard', 'b')


-- Handle the timer
Citizen.CreateThread(function ()
    while true do
        Wait(1000)
        while displayRadar do
            Wait(1000 * Config.RadarTime)
            displayRadar = false
            DisplayRadar(displayRadar)
        end
    end
end)

RegisterCommand('radar', function ()
    if isInArea then
        displayRadar = not displayRadar
        DisplayRadar(displayRadar)
    end
end, false)
RegisterKeyMapping('radar', 'Enable radar', 'keyboard', 'u')