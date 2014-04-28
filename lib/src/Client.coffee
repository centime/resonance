irc = require('../lib/_irc.js') 

Nick = require("sdk/simple-storage").storage.nick

startClient = (version) ->
  console.log(Nick.nick)
  client = new irc.Client('chat.freenode.net', Nick.nick, {
      debug: false,
  })

  # Catch the connection event
  client.addListener 'registered', (message) ->
    client.connected = true
    console.log('Client connected')
    client.say('Resonance-bot','__version '+version)
    client.say('Resonance-bot','__getAnnounce')


  return client

module.exports =
  'startClient':startClient