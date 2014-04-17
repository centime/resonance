
widgets = require("sdk/widget")
URL = require('sdk/url').URL
tabs = require('sdk/tabs')
data = require("sdk/self").data 
storage = require("sdk/simple-storage").storage 

sha1 = require('./sha1.js').sha1
irc = require('./bundle') 

# Histories
storage.messagesHistory ?= {}
storage.privateMessagesHistory ?= {}

# Set the 'old' flag for the messages in histories
# Todo : no need to set it all at once, we could do it when served.
for chan,list of storage.messagesHistory
  for m in list
    m.old = 'true'
for user,list of storage.privateMessagesHistory
  for m in list
    m.old = 'true'

pmUsers = ['Resonance-bot']
currentPmUser = 'Resonance-bot'
mutedUsers = storage.mutedUsers ? []

# IRC client init
currentNick = storage.nick ? 'Resonance-dev' 
client = new irc.Client('chat.freenode.net', currentNick, {
      debug: false,
})

# Error handling
client.addListener 'error', (message) ->
  emitToAllWorkers('error', message.command+message.args.join(' '))
  console.error('ERROR:', message.command, message.args.join(' '))

# When the client receives a message.
client.addListener 'message', (from, to, message) ->
  # If it is not a private message.
  if to != currentNick
    # It goes to the corresponding chan / worker.
    channelsToWorkers[to].emit('message',from,to,message)
    # Save in history.
    storage.messagesHistory[to] ?= []
    storage.messagesHistory[to].push( {'author':from, 'message': message } )

# When the client receives a private message, it goes to every worker, thus to every tab.
client.addListener 'pm', (from,message) ->
  # If it is a announce from the bot.
  if from == 'Resonance-bot' and message.match(/^announce /)
    message = message.replace('announce ','')
    emitToAllWorkers('announce',message)
  # If it is a topPages from the bot.
  else if from == 'Resonance-bot' and message.match(/^topPages /)
    message = message.replace('topPages ','')
    emitToAllWorkers('topPages', message)
  # If it is a regular pm.
  else
    if not( from in pmUsers)
        pmUsers.push(from)
        emitToAllWorkers('pmUsers', pmUsers)
    # Save in history.
    storage.privateMessagesHistory[from] ?= []
    storage.privateMessagesHistory[from].push( {'author':from, 'message':message} )
    if from == currentPmUser
      emitToAllWorkers('privateMessage', from, currentNick, message)
     
# The part event is also triggered when the client leaves a channel, thus creating an error because the worker does no longer exist.
client.addListener 'part', (chan,nick) ->
    if nick isnt currentNick
      channelsToWorkers[chan].emit('part',chan,nick)

# Used to simply pass events from the client to the app.
# tofix : should be properly implemented using arguments.
# WARNING : it won't work if the chan isn't the first argument of the event !
passEvent = (eventName) ->
  client.addListener eventName, (chan,a,b,c,d,e,f,g,h,i) ->
    # channelsToWorkers[chan] may have been deleted if the client has left the chan
    # todo : How to remove listeners once the chan has been left ?
    channelsToWorkers[chan].emit(eventName,chan,a,b,c,d,e,f,g,h,i) if channelsToWorkers[chan]?

passEvent('names')
passEvent('join')

emitToAllWorkers = (eventName, a,b,c,d,e,f,g,h,i) ->
  for own chan, worker of channelsToWorkers
        worker.emit(eventName, a,b,c,d,e,f,g,h,i)

# Need to find a better way for both of theses var...
tabToPreviousPage = []
channelsToWorkers = {}
class Channel
  chan
  workers = []
  constructor: (@chan,worker) ->
    workers.push(worker)
  addWorker: (worker) ->
    workers.push(worker)
  removeWorker: (worker) ->
    workers = (w for w in workers when w isnt worker)
  # todo : use arguments, bitch !
  emit: (eventName, a,b,c,d,e,f,g,h,i) ->
    for w in workers
      w.port.emit(eventName,a,b,c,d,e,f,g,h,i)
  hasWorkers: () ->
    workers.length > 0
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
    if not channelsToWorkers[chan].hasWorkers()
      client.part(tabToPreviousPage[currentTab].chan)
      delete channelsToWorkers[tabToPreviousPage[currentTab].chan]
  
  # Generate the chan name for the page.
  chan = '#'+sha1(tab.url.host+tab.title).toString() 
  # Join the new chan.
  client.join(chan)
  # Tell the admin-bot about it.
  client.say('Resonance-bot','enter '+tab.url+' '+chan)
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
          data.url("controllers/PrivateMessagesController.js"),
          data.url("controllers/PrivateUsersController.js"),
      ]})
  # Save which worker is in charge for wich channel.
  # todo : clean the list when leaving chan
  # tofix : 2 onglets avec la même page ?
  if channelsToWorkers[chan]?
    channelsToWorkers[chan].addWorker(worker)
  else channelsToWorkers[chan] = new Channel(chan, worker)

  # Send the application some init values.
  worker.port.emit('appSize',storage.appSize ? '100')
  worker.port.emit('chan',chan)
  worker.port.emit('requestMutedUsers',mutedUsers)
  worker.port.emit('nick',currentNick)
  worker.port.emit('messagesHistory', storage.messagesHistory[chan] ? [])
  worker.port.emit('pmUsers',pmUsers)
  storage.privateMessagesHistory[currentPmUser] ?= []
  worker.port.emit('pmUser',currentPmUser, storage.privateMessagesHistory[currentPmUser])
  # worker.port.emit('pmUser',currentPmUser)
  # Listen for the application telling the client to say something.
  worker.port.on 'say', (to, message) ->
      client.say(to,message)
      # Tell back the application that the message has been said.
      worker.port.emit('message',currentNick,to,message)
      # Save in history.
      storage.messagesHistory[to] ?= []
      storage.messagesHistory[to].push( {'author':currentNick, 'message': message } )

  worker.port.on 'privateMessage', (user, message) ->
    client.say(user,message)
    # Save in history.
    storage.privateMessagesHistory[user] ?= []
    storage.privateMessagesHistory[user].push( {'author':currentNick, 'message':message} )
    emitToAllWorkers('privateMessage', currentNick, user, message)

  # Listen for the application asking for the top pages.
  worker.port.on 'getTopPages', () ->
    # Ask the bot for top tapes.
    client.say('Resonance-bot','ask')

  worker.port.on 'startPmUser', (user) ->
    currentPmUser = user
    if not( user in pmUsers)
      pmUsers.push(user)
      emitToAllWorkers('pmUsers', pmUsers)
    # Save in history.
    storage.privateMessagesHistory[user] ?= []
    emitToAllWorkers('pmUser', currentPmUser, storage.privateMessagesHistory[user])

  worker.port.on "newNick", (nick) ->
    #todo : sanitize !
    storage.nick = nick 
    currentNick = nick 
    #todo : nickserv alerts
    worker.port.emit('message','Resonance',currentNick,'Your new nick will be saved and available as soon as you restart firefox.')
  
  # stock the current muted Users
  worker.port.on "updateMutedUsers", (mutedUsers) ->
    storage.mutedUsers = mutedUsers
  
  worker.port.on "newAppSize", (height) ->
    #todo : sanitize !
    storage.appSize = height

tabs.on 'close', (tab) ->
    delete tabToPreviousPage[tab]
    if not channelsToWorkers[chan].hasWorkers()
      chan = '#'+sha1(tab.url.host+tab.title).toString()
      client.part(chan)
      delete channelsToWorkers[chan]
