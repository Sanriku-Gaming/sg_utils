fx_version 'cerulean'
game 'gta5'

name 'sg_utils'
author 'Nicky'
description 'Framework agnostic utility functions'
version '1.0.0'

lua54 'yes'
use_experimental_fxv2_oal 'yes'

shared_scripts {
    'config.lua',
    'shared/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua',
    'server/version_check.lua'
}

exports {
    'GetUtils',
    'GetModule'
}

server_exports {
    'GetUtils',
    'GetModule'
}