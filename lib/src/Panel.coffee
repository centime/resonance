data = require("sdk/self").data
tabs = require('sdk/tabs')

Nick = require("sdk/simple-storage").storage.nick
{ getRandomName, getChan } = require('./Utils.js')

# env = {Resonance, settings, versionResonance}
createPanel = (env) ->
  panel = require("sdk/panel").Panel({
    'contentURL': data.url("panel.html"),
    'contentScriptFile':[
      data.url("lib/angular.min.js"),
      data.url("settings/panel.js"),
      ],
  })

  widget = require("sdk/widget").Widget({
  # widget = require('sdk/ui/button/action').actionButton({
    'id': "widget-open-settings",
    'label': "Resonance",
    'contentURL': data.url("settings/pencil-off.png"),
    'contentScriptWhen': 'ready',
    'contentScriptFile': data.url('settings/widget.js')
  })
  widget.port.on 'left-click', () ->
    if tabs.activeTab.url.match(/^about:/)
      return
    tabs.activeTab.started ?= false
    start(not tabs.activeTab.started)
    
    
  widget.port.on 'right-click', () ->
      # todo : about:blank & co
      position = {
        top: 0,
        bottom: 0,
        right: 0
      }
      panel.show({'position': position})
      env.settings['domain'] = tabs.activeTab.url.match(/^(https?\:)\/\/(([^:\/?#]*)(?:\:([0-9]+))?)(\/[^?#]*)(\?[^#]*|)(#.*|)$/)?[2] ?= ''
      panel.port.emit('settings',env.settings)
      panel.port.emit('nick', Nick.nick)
      panel.port.emit('chan', getChan(tabs.activeTab.url, tabs.activeTab.title))
      panel.port.emit('started', tabs.activeTab.started ?= false)
  
  panel.port.on 'activate',(value) ->
    # todo : join & display where it should be joined & displayed
    if value
      env.Resonance.startClient()
    else
      env.Resonance.closeClient()

  # Used to start / stop resonance via the widget for the current tab.
  start = (value) ->
    # If start.
    if value
        env.Resonance.start(tabs.activeTab)
    # If stop.
    else
        # Remove the injected html
        tabs.activeTab.worker.port.emit('close')
        # Part from the chan, update the workers & tabs..
        env.Resonance.end(tabs.activeTab)


  panel.port.on 'start',() ->
    start(true)

  panel.port.on 'stop',() ->
    start(false)

  panel.port.on 'nextNick', (nextNick) ->
    Nick.changeNick = nextNick
    
  panel.port.on 'getRandomName', () ->
    panel.port.emit('randomName',getRandomName())

  panel.port.on 'openMaster', () ->
    # If the master is already opened.
    for tab in tabs
      if tab.isMaster
        # Activate it.
        tab.activate()
        return
    # Else, open it.
    env.Resonance.openMaster()


  return panel

module.exports = 
  'createPanel':createPanel