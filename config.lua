Config = {}

Config.Debug = true

Config.MINUTE = 60 * 1000
Config.SECONDS = 1000

Config.MaxEntities = 10

-- in seconds
Config.RadarTime = 5

Config.Item = 'WEAPON_KNIFE'

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