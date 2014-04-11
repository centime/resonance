const widgets = require("sdk/widget");
const URL = require('sdk/url').URL;
const tabs = require('sdk/tabs');
const data = require("sdk/self").data ;
const storage = require("sdk/simple-storage").storage ;

const sha1 = require('./sha1.js').sha1;
const irc = require('./bundle') ;

//var currentNick = storage.nick || 'Resonance-dev' ;
currentNick = 'Crap7878'
var client= new irc.Client('chat.freenode.net', currentNick, {
      debug: true,
});

var channelsToWorkers = {};
function emitToAll(msg,a,b,c,d,e,f){ //tofix : it sucks
  for (w in channelsToWorkers){
    channelsToWorkers[w].port.emit(msg,a,b,c,d,e,f);
  };
};

client.addListener('message', function (from, to, message) {
  if (to === currentNick) emitToAll('message',from,to,message) // when you receive a private message, it goes to every worker
  else channelsToWorkers[to].port.emit('message',from,to,message);
});

client.addListener('names', function (channel,nicks) {
  channelsToWorkers[channel].port.emit('names',channel,nicks);
});

client.addListener('join', function (channel,nick) {
  channelsToWorkers[channel].port.emit('joined',channel,nick);
});

client.addListener('part', function (channel,nick) {
  channelsToWorkers[channel].port.emit('left',channel,nick);
});

var widget = widgets.Widget({
  id: "app-link",
  label: "Open the panel",
  contentURL: "http://www.jquery.com/favicon.ico",
  onClick: function() {
    var url = URL(tabs.activeTab.url);
    var chan = '#'+sha1(tabs.activeTab.url.host+tabs.activeTab.title).toString() ;
    var worker = tabs.activeTab.attach({
                                  contentScriptFile: [data.url("lib/jquery.js"),
                                                      data.url("lib/angular.min.js"),
                                                      data.url("controllers/app.js"),
                                                      data.url("controllers/IrcController.js"),
                                                      data.url("controllers/MessagesController.js"),
                                                      data.url("controllers/UsersController.js"),
                                                      data.url("controllers/SettingsController.js"),
                                                      data.url("content-built.js"),
                                                      ]
    });
    
    //some event bindings
    worker.port.on("say", function (to, text) {
        client.say(to,text);
        worker.port.emit('message',currentNick,to,text);
    });

    worker.port.on("join", function (chan) {
      client.join(chan);
      console.log('[[ CHAN ]] : '+chan);
    });
    worker.port.on("newNick", function (nick) {
      //todo : sanitize !
      storage.nick = nick ;
      currentNick = nick ;
      //todo : nickserv alerts
      worker.port.emit('message','Resonance',currentNick,'Your new nick will be saved and available as soon as you restart firefox.');
    });



    // ok, go !
    channelsToWorkers[chan] = worker ; //tofix : 2 onglets avec la même page ?
    client.join(chan);
    worker.port.emit('chan',chan)
    worker.port.emit('nick',currentNick)
    console.log('[[ CHAN ]] : '+chan);
  }
});

