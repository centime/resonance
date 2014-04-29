Nick = require("sdk/simple-storage").storage.nick

require("sdk/simple-storage").storage.mutedUsers ?= []
mutedUsers =require("sdk/simple-storage").storage.mutedUsers

self = this
init = (workers) ->
  self.workers = workers

initWorker = (worker) ->
  worker.port.emit('requestMutedUsers', mutedUsers)

bindClient = (client) ->
  client.addListener 'names', (chan,nicks) ->
      workers[chan].emit('names',chan,nicks)
  
  client.addListener 'join', (chan,nick) ->
      workers[chan].emit('join',chan,nick)

  # The part event is also triggered when the client leaves a channel, thus creating an error because the worker does no longer exist.
  client.addListener 'part', (chan,nick) ->
      if nick isnt Nick.nick
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