tabs = require('sdk/tabs')

getDomain = require('./src/Utils.js').getDomain

VERSION = 'alpha-0.0.1'

require("sdk/simple-storage").storage.settings ?= require('./src/Default.js').settings
settings = require("sdk/simple-storage").storage.settings

# Nick is an Object with a string property nick. This way it stays up to date when manipulated by multiple entities.

require("sdk/simple-storage").storage.nick ?= require('./src/Default.js').nick
Nick = require("sdk/simple-storage").storage.nick

Resonance = require('./src/Resonance.js')
Resonance.init(VERSION)

# Create the settings panel.
panel = require('./src/Panel.js').createPanel({Resonance, settings, VERSION})
panel.port.on 'updateOptions',(opt) ->
  for own key,value of opt
    settings[key] = value

# Start the irc client and join the server.
if settings.activated
  Resonance.startClient()

# Listen to events from the browser
tabs.on 'ready', (tab) ->
  # If Resonance was running on the previous page.
  if tab.chan?
    # Leave the chan etc...
    Resonance.end(tab)
  # If Resonance is activated...
  activated = settings.activated
  if activated
    # ..and if it should start for this page.
    startByDefault = settings.startByDefault
    startForThisDomain = (getDomain(tab.url) in settings.startForDomains)
    if startByDefault or startForThisDomain
      # Start it (join chan etc...).
      Resonance.start(tab)
      tab.started = true
    else tab.started = false
  else tab.started = false

tabs.on 'close', (tab) ->    
  Resonance.end(tab)