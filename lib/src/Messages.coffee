Nick = require("sdk/simple-storage").storage.nick

require("sdk/simple-storage").storage.messagesHistory ?= {}
messagesHistory = require("sdk/simple-storage").storage.messagesHistory

setUpHistory = require('./Utils.js').setUpHistory
setUpHistory(messagesHistory)


self = this
init = (workers, say) ->
    self.workers = workers
    self.say = say
    
# When the client receives a message.
receive = (from, to, message) ->
    # If it is not a private message.
    # (If 'to' is one of the registered chans)
    if to in ( c for own c,C of workers)
      # It goes to the corresponding chan / worker.
      workers[to]?.emit('message',from,to,message)
      # Save in history.
      messagesHistory[to] ?= []
      messagesHistory[to].push( {'author':from, 'message': message } )


bindClient = (client) ->
  client.addListener 'message', (from, to, message) ->
    receive(from, to, message)

onSay = (to, message) ->
  console.log('in msg')
  # Tell back the application that the message has been said.
  workers[to]?.emit('message',Nick.nick,to,message)
  # Save in history.
  messagesHistory[to] ?= []
  messagesHistory[to].push( {'author':Nick.nick, 'message': message } )

initWorker = (worker, chan) ->
  worker.port.emit('messagesHistory', messagesHistory[chan] ? [])

# You need to Messages.init({workers}) first.
bindWorker = (worker, client) ->
  worker.port.on 'message', (to, message) ->
    say(to, message)

module.exports =
  'init':init
  'bindClient':bindClient
  'initWorker':initWorker
  'bindWorker':bindWorker
  'onSay':onSay