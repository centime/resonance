//TODO
var IRC = {} ;
self.port.on('chan',function(c){
    IRC.chan = c ;
});
self.port.on('nick',function(n){
    IRC.nick = n ;
});