tabs = require('sdk/tabs')
data = require('sdk/self').data 

getDomain = require('./src/Utils.js').getDomain

VERSION = 0.01
version = require("sdk/simple-storage").storage.version ?= 0
if version == 0
  require("sdk/simple-storage").storage = {}
require("sdk/simple-storage").storage.version = VERSION

require("sdk/simple-storage").storage.settings ?= require('./src/Default.js').settings
settings = require("sdk/simple-storage").storage.settings

# Nick is an Object with a string property nick. This way it stays up to date when manipulated by multiple entities.

require("sdk/simple-storage").storage.nick ?= require('./src/Default.js').nick
Nick = require("sdk/simple-storage").storage.nick
# The user changed is nickname the last time.
if Nick.changeNick?
  Nick.nick = Nick.changeNick
  delete Nick.changeNick

Resonance = require('./src/Resonance.js')
Resonance.init(VERSION)


# Create the settings panel.
panel = require('./src/Panel.js').createPanel({Resonance, settings, VERSION})
panel.port.on 'updateSettings',(opt) ->
  for own key,value of opt
    settings[key] = value


#if false
# Start the irc client and join the server.
if settings.activated
  Resonance.startClient()

  # If the master page isn't already opened.
  setTimeout = require('sdk/timers').setTimeout
  openMaster = () ->
    masterIsOpened = false
    for tab in tabs
      if tab.url.match(/^resource:\/\/.*\/resonance\/data\/attached\.html$/)
        masterIsOpened = true
    if not masterIsOpened
      tabs.open({
        'url':data.url('attached.html'),inBackground:true
      })
  setTimeout(openMaster,1000)

# Listen to events from the browser
tabs.on 'ready', (tab) ->
  if tab.url.match(/^resource:\/\/.*\/resonance\/data\/attached\.html$/)
    Resonance.openMaster(tab)
  else
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
    
tabs.on 'close', (tab) ->
  # If the tab isn't the master tab.
  if not tab.isMaster
    Resonance.end(tab)