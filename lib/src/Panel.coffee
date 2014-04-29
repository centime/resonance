data = require("sdk/self").data
tabs = require('sdk/tabs')

Nick = require("sdk/simple-storage").storage.nick
getRandomName = require('./Utils.js').getRandomName

# env = {Resonance, settings, versionResonance}
createPanel = (env) ->
  panel = require("sdk/panel").Panel({
    'width':800,
    'height':200,
    'contentURL': data.url("panel.html"),
    'contentScriptFile':[
      data.url("lib/angular.min.js"),
      data.url("lib/jquery.js"),
      data.url("panel_controllers/panel.js"),
      ],
  })

  require("sdk/widget").Widget({
    'id': "widget-open-settings",
    'label': "Resonance",
    'contentURL': data.url("Resonance.png"),
    'panel': panel,
    'onClick': () ->
      # todo : about:blank & co
      env.settings['domain'] = tabs.activeTab.url.match(/^(https?\:)\/\/(([^:\/?#]*)(?:\:([0-9]+))?)(\/[^?#]*)(\?[^#]*|)(#.*|)$/)?[2] ?= ''
      env.settings['started'] = tabs.activeTab.started ?= 'false'
      panel.port.emit('settings',env.settings)
      panel.port.emit('nick', Nick.nick)
  })
  
  panel.port.on 'activate',(value) ->
    # todo : join & display where it should be joined & displayed
    if value
      env.Resonance.startClient()
    else
      env.Resonance.closeClient()

  panel.port.on 'start',(value) ->
    if value
      if not tabs.activeTab.started
        env.Resonance.start(tabs.activeTab)
        tabs.activeTab.started = true
    else
      tabs.activeTab.worker.port.emit('close')
      env.Resonance.end(tabs.activeTab)
      tabs.activeTab.started = false

  panel.port.on 'nextNick', (nextNick) ->
    Nick.changeNick = nextNick
    
  panel.port.on 'getRandomName', () ->
    panel.port.emit('randomName',getRandomName())

  return panel

module.exports = 
  'createPanel':createPanel