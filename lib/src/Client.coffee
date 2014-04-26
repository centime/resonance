irc = require('../lib/_irc.js') 

startClient = (env) ->
  client = new irc.Client('chat.freenode.net', env.NICK, {
      debug: true,
      channels: ['#resonance']
  })
  # Error handling
  client.addListener 'error', (message) ->
    # todo : target only the current active, but can't do it via tab.worker since the error may pop before having assigned a chan to a tab (pm to bot)
    env.workers.emitToAll('error', message.command+message.args.join(' '))
    console.error('ERROR:', message.command, message.args.join(' '))
  # Catch the connection event
  client.addListener 'registered', (message) ->
    client.connected = true
    client.say('Resonance-bot','__version '+env.versionResonance)

  client.addListener 'names', (chan,nicks) ->
    if chan != '#resonance'
      env.workers[chan].emit('names',chan,nicks)
  
  client.addListener 'join', (chan,nick) ->
    if chan != '#resonance'
      env.workers[chan].emit('join',chan,nick)

  # When the client receives a message.
  client.addListener 'message', (from, to, message) ->
    msgEnv = 
      'storage':env.storage
      'workers':env.workers
    env.Messages.receive(from,to,message, msgEnv)

  # When the client receives a private message, it goes to every worker, thus to every tab.
  client.addListener 'pm', (from, message) ->
    # If it comes from the bot.
    if from == 'Resonance-bot'
      if message.match(/^announce /)
        env.PrivateMessages.announce(message, env.tabs.activeTab.worker)
      else if message.match(/^topPagesMetaData /)
        tpPageMetaEnv = 
          'workers':env.workers
        env.TopPages.metaData(message, tpPageMetaEnv)
      else if message.match(/^topPages /)
        # todo : is client really needed ?
        tpPageEnv = 
          'client' : client
          'workers' : env.workers
        env.TopPages.topPages(message,tpPageEnv)
    # Else.
    else
      mpEnv = 
        'workers' : env.workers
        'storage' : env.storage
        'pmUsers' : env.pmUsers
        'currentPmUser' : env.currentPmUser
        'activePrivateUsers' : env.activePrivateUsers
        'NICK' : env.NICK
      env.PrivateMessages.receive(from, message, mpEnv)

       
  # The part event is also triggered when the client leaves a channel, thus creating an error because the worker does no longer exist.
  client.addListener 'part', (chan,nick) ->
      if nick isnt env.NICK
        env.workers[chan].emit('part',chan,nick)
  return client

module.exports =
  'startClient':startClient