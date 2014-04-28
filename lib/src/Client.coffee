irc = require('../lib/_irc.js') 

Nick = require("sdk/simple-storage").storage.nick

startClient = (version,workers) ->
  console.log(Nick.nick)
  client = new irc.Client('chat.freenode.net', Nick.nick, {
      debug: true,
  })
  # Error handling
  client.addListener 'error', (message) ->
    # todo : target only the current active, but can't do it via tab.worker since the error may pop before having assigned a chan to a tab (pm to bot)
    # workers.emitToAll('error', message.command+message.args.join(' '))
    console.error('ERROR:', message.command, message.args.join(' '))
  
  # Catch the connection event
  client.addListener 'registered', (message) ->
    client.connected = true
    console.log('Client connected')
    client.say('Resonance-bot','__version '+version)

  client.addListener 'nicknameinuse', (oldNick, newNick) ->
    workers.emitToAll('nick',newNick)
    console.log(oldNick+' > '+newNick)
    Nick.nick = newNick

  return client

module.exports =
  'startClient':startClient