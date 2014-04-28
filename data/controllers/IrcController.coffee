#TODO
# this is the ugly global var !
window.IRC = {} ;
# get the nick from the background script
self.port.on 'nick',(n) ->
    IRC.nick = n 
# get the chan from the background script
self.port.on 'chan',(n) ->
    IRC.chan = n
    

