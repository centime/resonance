getRandomName = require('./Utils.js').getRandomName

defaultSettings = 
  # Activate resonance on firefox start.
  'activated' : true
  # Join the chan and display Resonance for every page.
  'startByDefault' : true
  # Join the chan and display for the following domains.
  'startForDomains' : []

defaultNick = 
  'nick':getRandomName()

module.exports =
    'settings':defaultSettings
    'nick':defaultNick
    'getRandomName':getRandomName