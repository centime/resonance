//TODO
// this is the ugly global var !
var IRC = {} ;
// get the nick from the background script
self.port.on('nick',function(n){
    IRC.nick = n ;
});
// get the chan from the background script
self.port.on('chan',function(n){
    IRC.chan = n ;
});