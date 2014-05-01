#TODO
# this is the ugly global var !
window.IRC = {} ;
# get the nick from the background script
self.port.on 'nick',(n) ->
    IRC.nick = n 
# get the chan from the background script
self.port.on 'chan',(c) ->
    IRC.chan = c

self.port.on 'bot',(b) ->
    IRC.bot = b

