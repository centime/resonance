Nick = require("sdk/simple-storage").storage.nick

require("sdk/simple-storage").storage.privateMessagesHistory ?= {}
privateMessagesHistory = require("sdk/simple-storage").storage.privateMessagesHistory

setUpHistory = require('./Utils.js').setUpHistory
setUpHistory(privateMessagesHistory)

activePrivateUsers = {}
pmUsers = [BOT]
currentPmUser = BOT

self = this
init = (workers, BOT) ->
  self.workers = workers
  self.BOT = BOT

# When the client receives a private message, it goes to every worker, thus to every tab.
receive = (from, message) ->
    if not( from in pmUsers)
      pmUsers.push(from)
      workers.emitToAll('pmUsers', pmUsers)
    # Save in history.
    privateMessagesHistory[from] ?= []
    privateMessagesHistory[from].push( {'author':from, 'message':message} )

    activePrivateUsers[from] = true
    workers.emitToAll('activePrivateUsers',activePrivateUsers)

    if from == currentPmUser    
        workers.emitToAll('privateMessage', from, message)

bindClient = (client) ->
  # When the client receives a private message, it goes to every worker, thus to every tab.
  client.addListener 'pm', (from, message) ->
    # todo : pm from the bot ?      
    if (from == BOT)
      return
    else
      receive(from, message)


privateMessage = (client, to, message) ->
    client.say(to,message)
    # Save in history.
    privateMessagesHistory[to] ?= []
    privateMessagesHistory[to].push( {'author':Nick.nick, 'message':message} )
    workers.emitToAll('privateMessage', Nick.nick, message)

startPmUser = (user) ->
    currentPmUser = user
    if not( user in pmUsers)
      pmUsers.push(user)
      workers.emitToAll('pmUsers', pmUsers)
    # Save in history.
    privateMessagesHistory[user] ?= []
    workers.emitToAll('pmUser', currentPmUser, privateMessagesHistory[user])

unactivePmUser = (user) ->
    activePrivateUsers[user] = false
    workers.emitToAll('activePrivateUsers',activePrivateUsers)

initWorker = (worker) ->
  worker.port.emit('pmUsers',pmUsers)
  privateMessagesHistory[currentPmUser] ?= []
  worker.port.emit('pmUser',currentPmUser, privateMessagesHistory[currentPmUser])
  worker.port.emit('activePrivateUsers',activePrivateUsers)
  

bindWorker = (worker, client) ->
  worker.port.on 'privateMessage', (to, message) ->
    privateMessage(client, to, message)
  
  worker.port.on 'startPmUser', (user) ->
    startPmUser(user)

  worker.port.on 'unactivePmUser', (user) ->
    unactivePmUser(user)
    
module.exports =
  'init':init
  'bindClient':bindClient
  'initWorker':initWorker
  'bindWorker':bindWorker