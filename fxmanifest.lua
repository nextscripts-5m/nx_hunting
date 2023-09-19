fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_scripts {
	'@es_extended/imports.lua',
	'config.lua',
	'@ox_lib/init.lua',
	'locales.lua'
}

client_scripts {
	'client/client.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/server.lua'
}
