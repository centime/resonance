Nick = require("sdk/simple-storage").storage.nick

require("sdk/simple-storage").storage.notificationsHistory ?= []
notificationsHistory = require("sdk/simple-storage").storage.notificationsHistory
for notification in notificationsHistory
    notification.old = 'true'

announce = ''

self = this
init = (workers) ->
    self.workers = workers

initWorker = (worker) ->
  worker.port.emit('notificationsHistory', notificationsHistory)
  worker.port.emit('announce', announce)

sendNotification = (type, message) ->
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
    sendNotification('error', message.command+message.args.join(' '))

  client.addListener 'nicknameinuse', (oldNick, newNick) ->
    Nick.nick = newNick
    sendNotification('error', 'Nickname '+oldNick+' in use, changed to '+newNick)
    workers.emitToAll('nick', newNick)
    
  client.addListener 'pm', (from, message) ->
    if (from == 'Resonance-bot')
        if message.match(/^topPages/)
          return
        if message.match(/^announce /)
          message = message.replace('announce ','')
          announce = message
          workers.emitToAll('announce',announce)

module.exports =
  'init':init
  'initWorker':initWorker
  'bindClient':bindClient