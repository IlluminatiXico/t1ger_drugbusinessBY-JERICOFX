----------------------- [ DRUGLAB ] -----------------------
--JERICOFX 
fx_version 'adamant'
game 'gta5'


client_scripts {
    '@menuv/menuv.lua',
    'client/utils.lua',
    'language.lua',
	'config.lua',

    'client/client.lua'

}
server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'language.lua',
	'config.lua',
	'server/*.lua'
}

dependencies {
    'menuv'
}