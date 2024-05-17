fx_version 'adamant'
game 'gta5'

author 'GreenGhost'
version '1.0.1'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

server_scripts {
	'server/*.lua'
}

client_scripts {
	'client/*.lua',
}

ui_page 'html/ui.html'

files {
	'html/ui.html',
	'html/*.otf',
	'html/styles.css',
	'html/questions.js',
	'html/scripts.js',
}

lua54 'yes'