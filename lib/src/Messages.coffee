# When the client receives a message.
receive = (from, to, message, env) ->
    # If it is not a private message.
    # (If 'to' is one of the registered chans)
    if to in ( c for own c,C of env.workers)
      # It goes to the corresponding chan / worker.
      env.workers[to].emit('message',from,to,message)
      # Save in history.
      env.storage.messagesHistory[to] ?= []
      env.storage.messagesHistory[to].push( {'author':from, 'message': message } )


say = (to, message, env) ->
      env.client.say(to,message)
      # Tell back the application that the message has been said.
      env.workers[to].emit('message',env.NICK,to,message)
      # Save in history.
      env.storage.messagesHistory[to] ?= []
      env.storage.messagesHistory[to].push( {'author':env.NICK, 'message': message } )

bind = (worker,env) ->
  worker.port.on 'message', (to, message) ->
    say(to, message, env)

module.exports =
  'receive':receive
  'bind':bind