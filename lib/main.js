const widgets = require("sdk/widget");
const URL = require('sdk/url').URL;
const tabs = require('sdk/tabs');
const data = require("sdk/self").data ;

const sha1 = require('./sha1.js').sha1;
const irc = require('./bundle') ;

var NICK = 'Resonance-dev' ;

var client= new irc.Client('chat.freenode.net', NICK, {
      debug: true,
});
// TODO
var workers = [];
function emit(msg,a,b,c,d,e,f){
  for (w in workers){
    workers[w].port.emit(msg,a,b,c,d,e,f);
  };
};

client.addListener('message', function (from, to, message) {
  emit('message',from,to,message);
});

client.addListener('names', function (channel,nicks) {
  emit('names',channel,nicks);
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
                                                      //data.url("directives/angular-directive-autoscroll.js"),
                                                      data.url("controllers/app.js"),
                                                      data.url("controllers/IrcController.js"),
                                                      data.url("controllers/MessagesController.js"),
                                                      data.url("controllers/UsersController.js"),
                                                      data.url("content-built.js"),
                                                      ]
    });
    
    workers.push(worker);

    worker.port.on("say", function (to, text) {
        client.say(to,text);
        worker.port.emit('message',NICK,to,text);
    });

    worker.port.on("join", function (chan) {
      client.join(chan);
      console.log('[[ CHAN ]] : '+chan);
    });

    client.join(chan);
    worker.port.emit('chan',chan)
    worker.port.emit('nick',NICK)
    console.log('[[ CHAN ]] : '+chan);
  }
});

