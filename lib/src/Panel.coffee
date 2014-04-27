data = require("sdk/self").data


# env = {storage, tabs, NICK, versionResonance}
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
    'contentURL': data.url("History.png"),
    'panel': panel,
    'onClick': () ->
      # todo : about:blank & co
      env.storage.resonanceOptions['domain'] = env.tabs.activeTab.url.match(/^(https?\:)\/\/(([^:\/?#]*)(?:\:([0-9]+))?)(\/[^?#]*)(\?[^#]*|)(#.*|)$/)?[2] ?= ''
      env.storage.resonanceOptions['started'] = env.tabs.activeTab.started ?= 'false'
      panel.port.emit('initOptions',env.storage.resonanceOptions)
  })

  panel.port.on 'updateOptions',(opt) ->
    env.storage.resonanceOptions = opt
  
  panel.port.on 'activate',(value) ->
    # todo : join & display where it should be joined & displayed
    if value
      Env = 
        'NICK':env.NICK
        'versionResonance':env.versionResonance
        'storage':env.storage
      env.Resonance.startClient(Env)
    else
      env.Resonance.closeClient()

  panel.port.on 'start',(value) ->
    if value
      if not env.tabs.activeTab.started
        Env = 
          'NICK':env.NICK
          'storage':env.storage
        env.Resonance.start(env.tabs.activeTab, Env)
        env.tabs.activeTab.started = true
    else
      env.tabs.activeTab.worker.port.emit('close')
      env.Resonance.end(env.tabs.activeTab)
      env.tabs.activeTab.started = false
  panel

module.exports = 
  'createPanel':createPanel