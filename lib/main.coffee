tabs = require('sdk/tabs')
storage = require("sdk/simple-storage").storage 


storage.resonanceOptions ?= require('./src/DefaultSettings.js').DefaultSettings

Resonance = require('./src/Resonance.js')
{ setUpHistory, getDomain } = require('./src/Utils.js')

# Globals
NICK = storage.resonanceOptions.nick
versionResonance = 'alpha-0.0.1'
storage.messagesHistory ?= {}
storage.privateMessagesHistory ?= {}

# Create the settings panel.
panel = require('./src/Panel.js').createPanel({Resonance, storage, tabs, NICK, versionResonance})


setUpHistory(storage.messagesHistory)
setUpHistory(storage.privateMessagesHistory)

if storage.resonanceOptions.activated
  Resonance.startClient({NICK, versionResonance, storage})


# Listen to events from the browser
tabs.on 'ready', (tab) ->
  # If Resonance was running on the previous page.
  if tab.chan?
    # Leave the chan etc...
    Resonance.end(tab)
  # If Resonance is activated...
  activated = storage.resonanceOptions.activated
  if activated
    # ..and if it should start for this page.
    startByDefault = storage.resonanceOptions.startByDefault
    startForThisDomain = (getDomain(tab.url) in storage.resonanceOptions.startForDomains)
    if startByDefault or startForThisDomain
      # Start it (join chan etc...).
      Resonance.start(tab, {NICK, storage})
      tab.started = true
    else tab.started = false
  else tab.started = false

tabs.on 'close', (tab) ->    
  Resonance.end(tab)