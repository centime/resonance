data = require("sdk/self").data
URL = require('sdk/url').URL
tabs = require('sdk/tabs')
data = require("sdk/self").data 
storage = require("sdk/simple-storage").storage 
sha1 = require('./lib/sha1.js').sha1


Channel = require('./src/Channel.js').Channel
Messages = require('./src/Messages.js')
PrivateMessages = require('./src/PrivateMessages.js')
TopPages = require('./src/TopPages.js')
{ setUpHistory, getChan } = require('./src/Utils.js')

storage.resonanceOptions ?= require('./src/DefaultSettings.js').DefaultSettings

# Globals
NICK = storage.resonanceOptions.nick
versionResonance = 'alpha-0.0.1'
storage.messagesHistory ?= {}
storage.privateMessagesHistory ?= {}
activePrivateUsers = {}
mutedUsers = storage.mutedUsers ? []
pmUsers = ['Resonance-bot']
currentPmUser = 'Resonance-bot'
client = {}
workers = {}
workers.__proto__.emitToAll = () ->
  for own chan, worker of this
        worker.emit.apply(worker,arguments)


setUpHistory(storage.messagesHistory)
setUpHistory(storage.privateMessagesHistory)

# Create the irc client.
clientEnv = 
  'workers' : workers
  'NICK' : NICK
  'versionResonance' : versionResonance
  'Messages' : Messages
  'PrivateMessages' : PrivateMessages
  'TopPages' : TopPages
  'tabs' : tabs
  'storage' : storage
  'pmUsers' : pmUsers
  'currentPmUser' :  currentPmUser
  'activePrivateUsers' : activePrivateUsers
startClient = require('./src/Client.js').startClient


# todo

closePage = (tab) ->
  previousChan = tab.chan
  # Get the binded worker.
  # todo : le worker attaché est il le même pour un même tab ?!
  previousWorker = tab.worker
  # Remove it from the list of workers linked to the chan.
  workers[previousChan].removeWorker(previousWorker)
  # Leave the previous chan if there are no more workers binded to it.
  if not workers[previousChan].hasWorkers()
    client.part(previousChan)
    delete workers[previousChan]
  tab.chan = undefined
  tab.worker = undefined

openPage = (tab) ->
  # Generate the chan name for the page.
  chan = getChan(tab.url,tab.title)
  # Save it.
  tab.chan = chan
  # Join the new chan.
  client.join(chan)
  # Request a list of users.
  client.send('NAMES',chan) 

  # Tell the admin-bot about it.
  domain = tab.url.match(/^(https?\:)\/\/(([^:\/?#]*)(?:\:([0-9]+))?)(\/[^?#]*)(\?[^#]*|)(#.*|)$/)?[2] ?= ''
  title = tab.title.replace(/\ /g,'')
  client.say('Resonance-bot','__enter '+tab.url+' '+domain+' '+title)
  
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
          data.url("controllers/PrivateMessagesController.js"),
          data.url("controllers/PrivateUsersController.js"),
          # USED FOR TESTS ONLY
          data.url("tests.js"),
      ]})
  # Save the linked worker.
  tab.worker = worker

  # Save which worker is in charge for wich channel.
  # todo : clean the list when leaving chan
  # tofix : 2 onglets avec la même page ?
  if workers[chan]?
    workers[chan].addWorker(worker)
  else workers[chan] = new Channel(chan, worker)  

  # Send the application some init values.
  worker.port.emit('appSize',storage.appSize ? '100')
  worker.port.emit('chan',chan)
  worker.port.emit('requestMutedUsers',mutedUsers)
  worker.port.emit('nick',NICK)
  worker.port.emit('messagesHistory', storage.messagesHistory[chan] ? [])
  worker.port.emit('pmUsers',pmUsers)
  storage.privateMessagesHistory[currentPmUser] ?= []
  worker.port.emit('pmUser',currentPmUser, storage.privateMessagesHistory[currentPmUser])
  # todo : 
  # client.send('name',chan)
  

  Messages.bind(worker,{client, workers, NICK, storage})

  PrivateMessages.bind(worker,{client, workers, NICK, storage, pmUsers, currentPmUser,activePrivateUsers})


# Listen for the application asking for the top pages.
  worker.port.on 'getTopPages', (index,query) ->
    #Ask the bot for top tapes.
    client.say('Resonance-bot','__ask '+index+' '+query)
    
  # stock the current muted Users
  worker.port.on "updateMutedUsers", (mutedUsers) ->
    storage.mutedUsers = mutedUsers
  
  worker.port.on "newAppSize", (height) ->
    #todo : sanitize !
    storage.appSize = height
    workers.emitToAll('appSize',height)

  # USED FOR TESTS ONLY
  worker.port.on 'test', (response) ->
    testPortReplies[response] = true

# Create the settings panel.
panelEnv = 
  'storage' : storage
  'tabs' : tabs
  'client' : client
  'workers' : workers
  'startClient' : startClient
  'clientEnv':clientEnv
  'openPage' : openPage
  'closePage' : closePage
  'data':data
panel = require('./src/Panel.js').createPanel(panelEnv)


if storage.resonanceOptions.activated
  client = startClient(clientEnv)

# Listen to events from the browser
tabs.on 'ready', (tab) ->
  # If Resonance was running on the previous page.
  if tab.chan?
    # Leave the chan etc...
    closePage(tab)
  # If Resonance is activated...
  if storage.resonanceOptions.activated
    domain = tab.url.match(/^(https?\:)\/\/(([^:\/?#]*)(?:\:([0-9]+))?)(\/[^?#]*)(\?[^#]*|)(#.*|)$/)?[2] ?= ''
    # ..and if it should start for this page.
    if storage.resonanceOptions.startByDefault or (domain in storage.resonanceOptions.startForDomains)
      # Start it (join chan etc...).
      openPage(tab)
      tab.started = true
    else tab.started = false
  else tab.started = false

tabs.on 'close', (tab) ->    
  # Unlink the worker 
  workers[tab.chan].removeWorker(tab.worker)  
  # Check for the remaining workers linked to the same chan.
  if not workers[tab.chan].hasWorkers()    
    # Part from the chan.
    client.part(tab.chan)
    # Deletes the chan entry.
    delete workers[tab.chan]