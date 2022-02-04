--[[ FX Information ]]--
fx_version   'cerulean'
use_fxv2_oal 'yes'
lua54        'yes'
game         'gta5'

--[[ Resource Information ]]--
name         'ox_accounts'
author       'Overextended'
version      '0.0.1'
repository   'https://github.com/overextended/ox_accounts'
description  'Standalone accounts management'

--[[ Manifest ]]--
server_scripts {
	'@oxmysql/lib/MySQL.lua',
    'server.lua'
}