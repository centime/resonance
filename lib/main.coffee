data = require("sdk/self").data
tabs = require('sdk/tabs')
storage = require("sdk/simple-storage").storage 


Messages = require('./src/Messages.js')
PrivateMessages = require('./src/PrivateMessages.js')
TopPages = require('./src/TopPages.js')
{ setUpHistory } = require('./src/Utils.js')

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

# Create the settings panel.
panelEnv = 
  'storage' : storage
  'tabs' : tabs
  'client' : client
  'workers' : workers
  'startClient' : startClient
  'clientEnv':clientEnv
  'Resonance' : Resonance
  'ResoEnv':ResoEnv
  'data':data
panel = require('./src/Panel.js').createPanel(panelEnv)


if storage.resonanceOptions.activated
  client = startClient(clientEnv)

ResoEnv = 
  'workers':workers
  'client':client
  'NICK':NICK
  'storage':storage
  'mutedUsers':mutedUsers
  'pmUsers':pmUsers
  'currentPmUser':currentPmUser
  'Messages':Messages
  'PrivateMessages':PrivateMessages
  'activePrivateUsers':activePrivateUsers
Resonance = require('./src/Resonance.js')

# Listen to events from the browser
tabs.on 'ready', (tab) ->
  # If Resonance was running on the previous page.
  if tab.chan?
    # Leave the chan etc...
    Resonance.end(tab, ResoEnv)
  # If Resonance is activated...
  if storage.resonanceOptions.activated
    domain = tab.url.match(/^(https?\:)\/\/(([^:\/?#]*)(?:\:([0-9]+))?)(\/[^?#]*)(\?[^#]*|)(#.*|)$/)?[2] ?= ''
    # ..and if it should start for this page.
    if storage.resonanceOptions.startByDefault or (domain in storage.resonanceOptions.startForDomains)
      # Start it (join chan etc...).
      Resonance.start(tab, ResoEnv)
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