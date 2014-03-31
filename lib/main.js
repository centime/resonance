const widgets = require("sdk/widget");
const panels = require("sdk/panel");
const URL = require('sdk/url').URL;
const tabs = require('sdk/tabs');
const wutils = require('sdk/window/utils');
const data = require("sdk/self").data ;

const sha1 = require('./sha1.js').sha1;
const irc = require('./bundle') ;


var panel = panels.Panel({
    height: 120,
    position: {
      right: 0,
      left: 0,
      bottom: 0
    },
    contentURL: data.url("panel.html"),
});

var widget = widgets.Widget({
  id: "app-link",
  label: "Open the panel",
  contentURL: "http://www.jquery.com/favicon.ico",
  onClick: function() {
    panel.show();
  }
});

var client;

function start_client(){ 
  var emit = panel.port.emit ;
  var on = panel.port.on ;
  // create and connect the client
  client= new irc.Client('chat.freenode.net', 'wutwut', {
      debug: true,
  });


  client.addListener('message', function (from, to, message) {
    emit('message',from,to,message);
  });

  client.addListener('names', function (channel,nicks) {
    emit('names',channel,nicks);     
  });
  
  on("say", function (to, text) {
      client.say(to,text);
      emit('message','wutwut',to,text)
  });  

  on("join", function (chan) {
    console.log('[[ CHAN ]] : '+chan);
    client.join(chan)
  });  


};

start_client()

panel.on("show", function() {
   var url = URL(tabs.activeTab.url);
   chan = '#'+sha1(tabs.activeTab.url.host+tabs.activeTab.title).toString() ;
   panel.port.emit('open',chan);
});
