//TODO
// this is the ugly global var !
var IRC = {} ;
// get the chan from the background script
self.port.on('chan',function(c){
    IRC.chan = c ;
});
// get the nick from the background script
self.port.on('nick',function(n){
    IRC.nick = n ;
});