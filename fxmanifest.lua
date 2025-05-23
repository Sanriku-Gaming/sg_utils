fx_version 'cerulean'
game 'gta5'

name 'sg_utils'
author 'Nicky'
description 'Framework agnostic utility functions'
version '1.0.5'

lua54 'yes'
use_experimental_fxv2_oal 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/sh_utils.lua',
    'shared/exports.lua'
}

server_scripts {
    'server/sv_utils.lua',
    'server/version_check.lua'
}

client_scripts {
    'client/cl_utils.lua',
}

exports {
    'GetUtils'
}

server_exports {
    'GetUtils'
}