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
    'client/props.lua'
}

server_scripts {
    'server/storage.lua',
    'server/ranch_manager.lua',
    'server/admin.lua'
}

files {
    'data/*.json'
}

provides {
    'ranch-system-omni'
}
