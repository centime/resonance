
self = this
# env = {workers, NICK}
init = (env) ->
  for varName,varValue of env
    self[varName] = varValue

mutedUsers = require("sdk/simple-storage").storage.mutedUsers
mutedUsers ?= []

initWorker = (worker) ->
  worker.port.emit('requestMutedUsers', mutedUsers)

bindClient = (client) ->
  client.addListener 'names', (chan,nicks) ->
      workers[chan].emit('names',chan,nicks)
  
  client.addListener 'join', (chan,nick) ->
      workers[chan].emit('join',chan,nick)

  # The part event is also triggered when the client leaves a channel, thus creating an error because the worker does no longer exist.
  client.addListener 'part', (chan,nick) ->
      if nick isnt NICK
        workers[chan].emit('part',chan,nick)

bindWorker = (worker) ->
  # stock the current muted Users
  worker.port.on "updateMutedUsers", (users) ->
    mutedUsers = users

module.exports =
  'init':init
  'bindClient':bindClient
  'initWorker':initWorker
  'bindWorker':bindWorker