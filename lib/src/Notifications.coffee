getDate = require('./Utils.js').getDate

Nick = require("sdk/simple-storage").storage.nick

require("sdk/simple-storage").storage.notificationsHistory ?= []
notificationsHistory = require("sdk/simple-storage").storage.notificationsHistory

for notification in notificationsHistory
    notification.old = 'true'

notificationActive = false

announce = ''

self = this
init = (workers, BOT) ->
    self.workers = workers
    self.BOT = BOT

initWorker = (worker) ->
  worker.port.emit('notificationsHistory', notificationsHistory)
  worker.port.emit('announce', announce)

bindWorker = (worker) ->
  worker.port.on 'notificationActive',(bool) ->
    notificationActive = bool
    workers.emitToAll('notificationActive',bool)

updateNotifications = (type, message) ->
    date = getDate()
    notification = 
        'date':date
        'type':type
        'message':message
    notificationsHistory.push(notification)
    notificationActive = true
    workers.emitToAll('notificationsHistory', notificationsHistory)
    workers.emitToAll('notificationActive', notificationActive)

bindClient = (client) ->
    # Error handling
  client.addListener 'error', (message) ->
    if message.command == 'err_nosuchnick'
      if message.args[1] == BOT
        updateNotifications('Resonance', 'Unable to connect to the bot. TopPages will probably be broken. Maybe your Resonance needs to be updated, or maybe we are just down.')
      else
        updateNotifications('Message not sent', message.args[1]+' isn\'t connected')
    else  
      console.log('ERROR: '+message.command+message.args.join(' '))
      # todo : target only the current active, but can't do it via tab.worker since the error may pop before having assigned a chan to a tab (pm to bot)
      updateNotifications('error', message.command+message.args.join(' '))

  client.addListener 'nicknameinuse', (oldNick, newNick) ->
    Nick.nick = newNick
    updateNotifications('Nickname already in use',oldNick+' changed to '+newNick)
    workers.emitToAll('nick', newNick)
    
  client.addListener 'pm', (from, message) ->
    if (from == BOT)
        if message.match(/^topPages/)
          return
        if message.match(/^announce /)
          message = message.replace('announce ','')
          announce = message
          workers.emitToAll('announce',announce)
        if message.match(/^version /)
          message = message.replace('version ','')
          updateNotifications('New Version',message)

module.exports =
  'init':init
  'initWorker':initWorker
  'bindWorker':bindWorker
  'bindClient':bindClient