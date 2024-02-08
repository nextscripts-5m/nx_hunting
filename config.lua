Config = {}

-- You can choose between "esx" or "qb"
Config.Framework = "esx"

Config.Debug = true

--[[
    you can choose between "ox_lib" and "rprogress"
]]
Config.Progress = "rprogress"

Config.MINUTE = 60 * 1000
Config.SECONDS = 1000

Config.MaxEntities = 10

-- in seconds
Config.RadarTime = 5

Config.Item = 'WEAPON_KNIFE'

Config.MaximumItemsPerKill = 4

Config.BanFunction = function ()
    -- you can decide what to do if a cheater try to give items
end

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
    Zone2 = {
        position = vector3(3697.2112, 3989.4673, 64.6255),
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