announce = (message, worker) ->
      message = message.replace('announce ','')
      worker.emit('announce',message)

# When the client receives a private message, it goes to every worker, thus to every tab.
receive = (from, message, env) ->
    if not( from in env.pmUsers)
      env.pmUsers.push(from)
      env.workers.emitToAll('pmUsers', env.pmUsers)
    # Save in history.
    env.storage.privateMessagesHistory[from] ?= []
    env.storage.privateMessagesHistory[from].push( {'author':from, 'message':message} )

    env.activePrivateUsers[from] = true
    env.workers.emitToAll('activePrivateUsers',env.activePrivateUsers)

    if from == env.currentPmUser    
        env.workers.emitToAll('privateMessage', from, env.NICK, message)   

privateMessage = (to, message, env) ->
    env.client.say(user,message)
    # Save in history.
    env.storage.privateMessagesHistory[user] ?= []
    env.storage.privateMessagesHistory[user].push( {'author':env.NICK, 'message':message} )
    env.workers.emitToAll('privateMessage', env.NICK, user, message)

startPmUser = (user,env) ->
    env.currentPmUser = user
    if not( user in env.pmUsers)
      env.pmUsers.push(user)
      env.workers.emitToAll('pmUsers', env.pmUsers)
    # Save in history.
    env.storage.privateMessagesHistory[user] ?= []
    env.workers.emitToAll('pmUser', env.currentPmUser, env.storage.privateMessagesHistory[user])

unactivePmUser = (user,env) ->
    env.activePrivateUsers[user] = false
    env.workers.emitToAll('activePrivateUsers',env.activePrivateUsers)

bind = (worker,env) ->
  worker.port.on 'privateMessage', (user, message) ->
    privateMessage(to, message, env)
  
  worker.port.on 'startPmUser', (user) ->
    startPmUser(user,env)

  worker.port.on 'unactivePmUser', (user) ->
    unactivePmUser(user,env)
    
module.exports =
  'announce':announce
  'receive':receive
  'bind':bind