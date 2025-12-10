fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'

lua54 'yes'

game 'rdr3'

author 'Omni Frontier Dev Team'
description 'Ranch System Omni Frontier core resource'
version '0.1.0'

shared_scripts {
    'shared/config.lua',
    'shared/utils.lua'
}

client_scripts {
    'client/main.lua',
    'client/zoning.lua',
    'client/vegetation.lua',
    'client/props.lua',
    'client/ui.lua'
}

server_scripts {
    'server/storage.lua',
    'server/ranch_manager.lua',
    'server/environment.lua',
    'server/livestock.lua',
    'server/workforce.lua',
    'server/economy.lua',
    'server/progression.lua',
    'server/admin.lua'
}

files {
    'data/*.json',
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js'
}

ui_page 'html/index.html'

provides {
    'ranch-system-omni'
}
