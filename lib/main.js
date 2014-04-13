const widgets = require("sdk/widget");
const URL = require('sdk/url').URL;
const tabs = require('sdk/tabs');
const data = require("sdk/self").data ;
const storage = require("sdk/simple-storage").storage ;

const sha1 = require('./sha1.js').sha1;
const irc = require('./bundle') ;


// IRC client init
var currentNick = storage.nick || 'Resonance-dev' ;
var client = new irc.Client('chat.freenode.net', currentNick, {
      debug: false,
});

client.addListener('message', function (from, to, message) {
  // If it is a topPages annonce from the bot
  if ((to === currentNick) && (from === 'Resonance-bot')){
    // tofix : it's useless to dispatch to all workers.
    for (w in channelsToWorkers){
      channelsToWorkers[w].port.emit('topPages',message);
    };
  }
  // If it is a private message, it goes to every worker, thus to every tab.
  else if (to === currentNick){
    for (w in channelsToWorkers){
      channelsToWorkers[w].port.emit('message',from,to,message);
    };
  }
  else channelsToWorkers[to].port.emit('message',from,to,message);
});
// The part event is also triggered when the client leaves a channel, thus creating an error because the worker does no longer exist.
client.addListener('part', function (chan,nick) {
    if (nick !== currentNick)
      channelsToWorkers[chan].port.emit('part',chan,nick);
});
// Used to simply pass events from the client to the app.
// tofix : should be properly implemented using arguments.
// WARNING : it won't work if the chan isn't the first argument of the event !
function passEvent(eventName){
  client.addListener(eventName, function (chan,a,b,c,d,e,f,g,h,i) {
    // channelsToWorkers[chan] may have been deleted if the client has left the chan
    // todo : How to remove listeners once the chan has been left ? 
    if (typeof(channelsToWorkers[chan]) !== 'undefined')
      channelsToWorkers[chan].port.emit(eventName,chan,a,b,c,d,e,f,g,h,i);
  });
}
passEvent('names');
passEvent('join');

// Need to find a better way for both of theses var...
var tabToPreviousPage = [] ;
var channelsToWorkers = {};
// Listen to events from the browser
tabs.on('ready', function(tab) {
  // Find which tab is active.
  var currentTab = -1 ;
  for (var i=0;i<tabs.length;i++){
    if (tab == tabs[i]) {
      currentTab = i ;
    }
  };
  // Part from the previous chan.
  if (typeof(tabToPreviousPage[currentTab]) !== 'undefined'){
    // Leave the chan.
    client.part(tabToPreviousPage[currentTab].chan);
    // Remove the chan form the list.
    // WARNING
    // tofix : what if the same page is on different tabs ?
    delete channelsToWorkers[tabToPreviousPage[currentTab].chan]; 
    // Tell the admin-bot about it
    client.say('Resonance-bot','/leave '+tabToPreviousPage[currentTab].url);
  }
  // Generate the chan name for the page.
  var chan = '#'+sha1(tab.url.host+tab.title).toString() ;
  // Join the new chan.
  client.join(chan);
  // Tell the admin-bot about it.
  client.say('Resonance-bot','/enter '+tab.url);
  // Save which page is currently displayed in the current tab.
  tabToPreviousPage[currentTab] = {'url':tab.url,'chan':chan};

  
  // Inject the application code into the page.
  var worker = tab.attach({
      contentScriptFile:[
          data.url("lib/jquery.js"),
          data.url("lib/angular.min.js"),
          data.url("controllers/app.js"),
          data.url("controllers/ResonanceController.js"),
          data.url("controllers/IrcController.js"),
          data.url("controllers/MessagesController.js"),
          data.url("controllers/UsersController.js"),
          data.url("controllers/TopPagesController.js"),
          data.url("controllers/SettingsController.js"),
          data.url("content-built.js"),
      ]});
  // Save which worker is in charge for wich channel.
  // todo : clean the list when leaving chan
  // tofix : 2 onglets avec la même page ?
  channelsToWorkers[chan] = worker ; 

  // Send the application some init values.
  worker.port.emit('chan',chan);
  worker.port.emit('nick',currentNick);
  // Listen for the application telling the client to say something.
  worker.port.on('say', function (to, text) {
      client.say(to,text);
      // Tell back the application that the message has been said.
      worker.port.emit('message',currentNick,to,text);
  });
  // Listen for the application asking for the top pages.
  worker.port.on('getTopPages', function (){
      // Ask the bot for top tapes.
      client.say('Resonance-bot','/ask');
  });
  worker.port.on("newNick", function (nick) {
    //todo : sanitize !
    storage.nick = nick ;
    currentNick = nick ;
    //todo : nickserv alerts
    worker.port.emit('message','Resonance',currentNick,'Your new nick will be saved and available as soon as you restart firefox.');
  });
  worker.port.emit('nick',currentNick)

    console.log()
    console.log('[[CTW]] ')
    for (c in channelsToWorkers){console.log(c)}
    console.log()
});
