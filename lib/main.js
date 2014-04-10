const widgets = require("sdk/widget");
const URL = require('sdk/url').URL;
const tabs = require('sdk/tabs');
const data = require("sdk/self").data ;

const sha1 = require('./sha1.js').sha1;
const irc = require('./bundle') ;

var client;

var chans_to_workers = {} ;
var workers_to_chans = {} ;

function start_client(){ 
  var emit = worker.port.emit ;
  // create and connect the client
  client= new irc.Client('chat.freenode.net', 'resoDev', {
      debug: true,
  });

  client.addListener('message', function (from, to, message) {
    emit('message',from,to,message);
  });

  client.addListener('names', function (channel,nicks) {
    emit('names',channel,nicks);     
  });
  
};
start_client()

var worker ;
var widget = widgets.Widget({
  id: "app-link",
  label: "Open the panel",
  contentURL: "http://www.jquery.com/favicon.ico",
  onClick: function() {
    var url = URL(tabs.activeTab.url);
    chan = '#'+sha1(tabs.activeTab.url.host+tabs.activeTab.title).toString() ;
    worker = tabs.activeTab.attach({
                                  contentScriptFile: [data.url("lib/jquery.js"),
                                                      data.url("lib/angular.min.js"),
                                                      data.url("controllers/app.js"),
                                                      data.url("controllers/MessagesController.js"),
                                                      data.url("controllers/UsersController.js"),
                                                      data.url("content-built.js"),
                                                      ]
    });
    worker.port.emit('open',chan);
    worker.port.on("say", function (to, text) {
        client.say(to,text);
        emit('message','resoDev',to,text);
        console.log('[[ MSG ]] : '+text);
    });  

    worker.port.on("join", function (chan) {
      client.join(chan);
      console.log('[[ CHAN ]] : '+chan);
    });  
  }
});

