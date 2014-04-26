createPanel = (env) ->
  panel = require("sdk/panel").Panel({
    'width':800,
    'height':200,
    'contentURL': env.data.url("panel.html"),
    'contentScriptFile':[
      env.data.url("lib/angular.min.js"),
      env.data.url("lib/jquery.js"),
      env.data.url("panel_controllers/panel.js"),
      ],
  })

  require("sdk/widget").Widget({
    'id': "widget-open-settings",
    'label': "Resonance",
    'contentURL': env.data.url("History.png"),
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
      env.client = env.startClient(env.clientEnv)
    else
      env.workers.emitToAll('close')
      env.client.disconnect()
      # for tab in tabs
      #   tab.started = false
      #panel.port.emit('desactivated')

  panel.port.on 'start',(value) ->
    if value
      if not env.tabs.activeTab.started
        env.Resonance.start(tabs.activeTab)
        env.tabs.activeTab.started = true
    else
      env.tabs.activeTab.worker.port.emit('close')
      env.Resonance.end(env.tabs.activeTab, env.ResoEnv)
      env.tabs.activeTab.started = false
  panel

module.exports = 
  'createPanel':createPanel