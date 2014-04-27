
activePrivateUsers = {}
pmUsers = ['Resonance-bot']
currentPmUser = 'Resonance-bot'

announce = (message, worker) ->
      # message = message.replace('announce ','')
      # worker.emit('announce',message)
      console.log 'Not implemented'

# When the client receives a private message, it goes to every worker, thus to every tab.
receive = (from, message, env) ->
  # env = { workers, storage, NICK}
    if not( from in pmUsers)
      pmUsers.push(from)
      env.workers.emitToAll('pmUsers', pmUsers)
    # Save in history.
    env.storage.privateMessagesHistory[from] ?= []
    env.storage.privateMessagesHistory[from].push( {'author':from, 'message':message} )

    activePrivateUsers[from] = true
    env.workers.emitToAll('activePrivateUsers',activePrivateUsers)

    if from == currentPmUser    
        env.workers.emitToAll('privateMessage', from, env.NICK, message)

bindClient = (client,env) ->
  # When the client receives a private message, it goes to every worker, thus to every tab.
  client.addListener 'pm', (from, message) ->
    # todo : pm from the bot ?      
    if (from == 'Resonance-bot') and message.match(/^topPages/)
      return
    if (from == 'Resonance-bot') and message.match(/^announce /)
      announce(message)
    else
      receive(from, message, env)


privateMessage = (to, message, env) ->
    env.client.say(to,message)
    # Save in history.
    env.storage.privateMessagesHistory[to] ?= []
    env.storage.privateMessagesHistory[to].push( {'mauthor':env.NICK, 'message':message} )
    env.workers.emitToAll('privateMessage', env.NICK, to, message)

startPmUser = (user,env) ->
    currentPmUser = user
    if not( user in pmUsers)
      pmUsers.push(user)
      env.workers.emitToAll('pmUsers', pmUsers)
    # Save in history.
    env.storage.privateMessagesHistory[user] ?= []
    env.workers.emitToAll('pmUser', currentPmUser, env.storage.privateMessagesHistory[user])

unactivePmUser = (user,env) ->
    activePrivateUsers[user] = false
    env.workers.emitToAll('activePrivateUsers',activePrivateUsers)

initWorker = (worker,env) ->
  worker.port.emit('pmUsers',pmUsers)
  env.storage.privateMessagesHistory[currentPmUser] ?= []
  worker.port.emit('pmUser',currentPmUser, env.storage.privateMessagesHistory[currentPmUser])
  

bindWorker = (worker,env) ->
  worker.port.on 'privateMessage', (to, message) ->
    privateMessage(to, message, env)
  
  worker.port.on 'startPmUser', (user) ->
    startPmUser(user,env)

  worker.port.on 'unactivePmUser', (user) ->
    unactivePmUser(user,env)
    
module.exports =
  'bindClient':bindClient
  'initWorker':initWorker
  'bindWorker':bindWorker