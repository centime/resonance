data = require("sdk/self").data
URL = require('sdk/url').URL
tabs = require('sdk/tabs')
data = require("sdk/self").data 
storage = require("sdk/simple-storage").storage 

sha1 = require('./sha1.js').sha1
irc = require('./_irc.js') 

resonanceIsActivated = false
resonanceOptions = {
  # Activate resonance on firefox start.
  'activateByDefault' : true,
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
})

panel.port.emit('initOptions',resonanceOptions)

panel.port.on 'test',(msg) ->
  console.log msg

# Listen to events from the browser
tabs.on 'ready', (tab) ->
  # If a page was displayed.
  console.log('Tab ready')
  if resonanceIsActivated
    console.log('app started')
