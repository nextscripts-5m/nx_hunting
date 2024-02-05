Config = {}

-- You can choose between "esx" or "qb"
Config.Framework = "esx"

Config.Debug = true

--[[
    you can choose between "ox_lib" and "rprogress"
--]]
Config.Progress = "rpprogress"

Config.MINUTE = 60 * 1000
Config.SECONDS = 1000

Config.MaxEntities = 10

-- in seconds
Config.RadarTime = 5

Config.Item = 'WEAPON_KNIFE'

Config.MaximumItemsPerKill = 4

Config.Cheater = { -- this will ban the player if enabled for triggering a giveitem trigger
    Ban = false,
    BanFunction = function(src)
        -- server side
        -- TriggerEvent("ban", src)
    end,
}

Config.Items = { -- this is  for protection, add every item that the script can add to the player
'water',    
'burger',
}

Config.Zones = {
    Zone1 = {
        position = vector3(3097.5112, 3515.7256, 123.4812),
        radius = 200.0,
        Blip = {
            color = 33,
            sprite = 273,
        },
        Animals = {
            ['puma'] = {
                model = 'a_c_boar',
                loots = {
                    'burger',
                    'water',
                },
                rarity = 90
            },
            ['lupo'] = {
                model = 'a_c_coyote',
                loots = {
                    'burger',
                    'water',
                },
                rarity = 20
            },

        },
    },
}
