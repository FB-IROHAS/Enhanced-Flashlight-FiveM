fx_version 'cerulean'
game 'gta5'

author 'IROHAS'
description 'FiveM Rappelling System for QBCore'
version '1.0.0'

client_scripts {
    'client/main.lua',
    'module/*.lua'
}

server_scripts {
    'server/server.lua'
}

shared_scripts {
    'config.lua',
}

dependencies {
    'qb-core'
}