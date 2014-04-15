
widgets = require("sdk/widget")
URL = require('sdk/url').URL
tabs = require('sdk/tabs')
data = require("sdk/self").data 
storage = require("sdk/simple-storage").storage 

sha1 = require('./sha1.js').sha1
irc = require('./bundle') 

# IRC client init
currentNick = storage.nick ? 'Resonance-dev' 
client = new irc.Client('chat.freenode.net', currentNick, {
      debug: false,
})
# When the client receives a message.
client.addListener 'message', (from, to, message) ->
  # If it is not a private message.
  if to != currentNick
    # It goes to the corresponding chan / worker.
    channelsToWorkers[to].port.emit('message',from,to,message)

# When the client receives a private message, it goes to every worker, thus to every tab.
client.addListener 'pm', (from,message) ->
  # If it is a topPages annonce from the bot
  if from == 'Resonance-bot'
    worker.port.emit('topPages',message) for own chan, worker in channelsToWorkers
  else
    worker.port.emit('message',message) for own chan, worker in channelsToWorkers
    
# The part event is also triggered when the client leaves a channel, thus creating an error because the worker does no longer exist.
client.addListener 'part', (chan,nick) ->
    if nick isnt currentNick
      channelsToWorkers[chan].port.emit('part',chan,nick)

# Used to simply pass events from the client to the app.
# tofix : should be properly implemented using arguments.
# WARNING : it won't work if the chan isn't the first argument of the event !
passEvent = (eventName) ->
  client.addListener eventName, (chan,a,b,c,d,e,f,g,h,i) ->
    # channelsToWorkers[chan] may have been deleted if the client has left the chan
    # todo : How to remove listeners once the chan has been left ?
    channelsToWorkers[chan].port.emit(eventName,chan,a,b,c,d,e,f,g,h,i) if channelsToWorkers[chan]?

passEvent('names')
passEvent('join')

# Need to find a better way for both of theses var...
tabToPreviousPage = [] 
channelsToWorkers = {}
# Listen to events from the browser
tabs.on 'ready', (tab) ->
  # Find which tab is active.
  currentTab = -1 
  i = 0
  while i < tabs.length
    currentTab = i  if tab is tabs[i]
    i++
  # Part from the previous chan.
  if tabToPreviousPage[currentTab]?
    # Leave the chan.
    client.part(tabToPreviousPage[currentTab].chan)
    # Remove the chan form the list.
    # WARNING
    # tofix : what if the same page is on different tabs ?
    delete channelsToWorkers[tabToPreviousPage[currentTab].chan] 
    # Tell the admin-bot about it
    client.say('Resonance-bot','/leave '+tabToPreviousPage[currentTab].url)
  
  # Generate the chan name for the page.
  chan = '#'+sha1(tab.url.host+tab.title).toString() 
  # Join the new chan.
  client.join(chan)
  # Tell the admin-bot about it.
  client.say('Resonance-bot','/enter '+tab.url)
  # Save which page is currently displayed in the current tab.
  tabToPreviousPage[currentTab] = 
    'url' : tab.url
    'chan' : chan

  
  # Inject the application code into the page.
  worker = tab.attach({
      contentScriptFile:[
          data.url("lib/jquery.js"),
          data.url("lib/angular.min.js"),
          data.url("content-built.js"),
          data.url("controllers/app.js"),
          data.url("controllers/ResonanceController.js"),
          data.url("controllers/IrcController.js"),
          data.url("controllers/MessagesController.js"),
          data.url("controllers/UsersController.js"),
          data.url("controllers/TopPagesController.js"),
          data.url("controllers/SettingsController.js"),
      ]})
  # Save which worker is in charge for wich channel.
  # todo : clean the list when leaving chan
  # tofix : 2 onglets avec la même page ?
  channelsToWorkers[chan] = worker  

  # Send the application some init values.
  worker.port.emit('chan',chan)
  worker.port.emit('nick',currentNick)
  # Listen for the application telling the client to say something.
  worker.port.on 'say', (to, text) ->
      client.say(to,text)
      # Tell back the application that the message has been said.
      worker.port.emit('message',currentNick,to,text)
  
  # Listen for the application asking for the top pages.
  worker.port.on 'getTopPages', () ->
      # Ask the bot for top tapes.
      client.say('Resonance-bot','/ask')
  
  worker.port.on "newNick", (nick) ->
    #todo : sanitize !
    storage.nick = nick 
    currentNick = nick 
    #todo : nickserv alerts
    worker.port.emit('message','Resonance',currentNick,'Your new nick will be saved and available as soon as you restart firefox.')
  
