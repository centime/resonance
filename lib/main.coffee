data = require("sdk/self").data
URL = require('sdk/url').URL
tabs = require('sdk/tabs')
data = require("sdk/self").data 
storage = require("sdk/simple-storage").storage 
sha1 = require('./sha1.js').sha1
irc = require('./_irc.js') 

resonanceOptions = {
  # Activate resonance on firefox start.
  'activated' : true,
  # Join the chan for every page.
  'joinByDefault': true,
  # Display the app for every page.
  'displayByDefault' : true,
  # Join the chan for the following domains.
  'joinForDomains' : [],
  # Display the app for the following domains.
  'displayForDomains' : [],
  'nick' : 'zob_du_test',  
}

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
    resonanceOptions['domain'] = tabs.activeTab.url.match(/^(https?\:)\/\/(([^:\/?#]*)(?:\:([0-9]+))?)(\/[^?#]*)(\?[^#]*|)(#.*|)$/)[2] ?= ''
    panel.port.emit('initOptions',resonanceOptions)
})

panel.port.on 'updateOptions',(opt) ->
  resonanceOptions = opt
  console.log opt

# Listen to events from the browser
tabs.on 'ready', (tab) ->
  # If a page was displayed.
  console.log('Tab ready')
  if resonanceOptions.activated
    console.log('app started')
