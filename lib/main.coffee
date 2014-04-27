tabs = require('sdk/tabs')

resonanceOptions = require("sdk/simple-storage").storage.resonanceOptions
resonanceOptions ?= require('./src/DefaultSettings.js').DefaultSettings

getDomain = require('./src/Utils.js').getDomain

versionResonance = 'alpha-0.0.1'

NICK = resonanceOptions.nick

Resonance = require('./src/Resonance.js')
Resonance.init({NICK, versionResonance})

# Create the settings panel.
panel = require('./src/Panel.js').createPanel({Resonance, resonanceOptions, versionResonance})
panel.port.on 'updateOptions',(opt) ->
  for own key,value of opt
    resonanceOptions[key] = value

if resonanceOptions.activated
  Resonance.startClient()

# Listen to events from the browser
tabs.on 'ready', (tab) ->
  # If Resonance was running on the previous page.
  if tab.chan?
    # Leave the chan etc...
    Resonance.end(tab)
  # If Resonance is activated...
  activated = resonanceOptions.activated
  if activated
    # ..and if it should start for this page.
    startByDefault = resonanceOptions.startByDefault
    startForThisDomain = (getDomain(tab.url) in resonanceOptions.startForDomains)
    if startByDefault or startForThisDomain
      # Start it (join chan etc...).
      Resonance.start(tab)
      tab.started = true
    else tab.started = false
  else tab.started = false

tabs.on 'close', (tab) ->    
  Resonance.end(tab)