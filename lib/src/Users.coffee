mutedUsers = []

initWorker = (worker) ->
  worker.port.emit('requestMutedUsers', mutedUsers)

bindClient = (client,env) ->
  client.addListener 'names', (chan,nicks) ->
      env.workers[chan].emit('names',chan,nicks)
  
  client.addListener 'join', (chan,nick) ->
      env.workers[chan].emit('join',chan,nick)

  # The part event is also triggered when the client leaves a channel, thus creating an error because the worker does no longer exist.
  client.addListener 'part', (chan,nick) ->
      if nick isnt env.NICK
        env.workers[chan].emit('part',chan,nick)

bindWorker = (worker, env) ->
  # stock the current muted Users
  worker.port.on "updateMutedUsers", (users) ->
    mutedUsers = users

module.exports =
  'bindClient':bindClient
  'initWorker':initWorker
  'bindWorker':bindWorker