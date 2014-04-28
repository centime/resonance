require("sdk/simple-storage").storage.notificationsHistory ?= {}
notificationsHistory = require("sdk/simple-storage").storage.notificationsHistory
for notification in notificationsHistory
    notification.old = 'true'

self = this
init = (workers) ->
    self.workers = workers

initWorker = (worker) ->
  worker.port.emit('notificationsHistory',notificationsHistory)
  
notification = (type, message) ->
    notification = 
        'type':type
        'message':message
    notificationsHistory.push(notification)
    workers.emitToAll('notification', notification)

bindClient = (client) ->
    # Error handling
  client.addListener 'error', (message) ->
    console.error('ERROR:', message.command, message.args.join(' '))
    # todo : target only the current active, but can't do it via tab.worker since the error may pop before having assigned a chan to a tab (pm to bot)
    notification('error', message.command+message.args.join(' '))

  client.addListener 'nicknameinuse', (oldNick, newNick) ->
    console.log(oldNick+' > '+newNick)
    Nick.nick = newNick
    notification('error', message.command+message.args.join(' '))
    workers.emitToAll('nick', newNick)
    
  client.addListener 'pm', (from, message) ->
    if (from == 'Resonance-bot')
        if message.match(/^topPages/)
            return
      notification('announce', message)

module.exports =
  'init':init
  'initWorker':initWorker
  'bindClient':bindClient