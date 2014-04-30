irc = require('../lib/_irc.js') 

Nick = require("sdk/simple-storage").storage.nick

startClient = (VERSION, BOT) ->
  client = new irc.Client('chat.freenode.net', Nick.nick, {
      debug: false,
  })

  # Catch the connection event
  client.addListener 'registered', (message) ->
    client.connected = true
    console.log('Client connected')
    client.say(BOT,'__version '+VERSION)
    client.say(BOT,'__getAnnounce')


  return client

module.exports =
  'startClient':startClient