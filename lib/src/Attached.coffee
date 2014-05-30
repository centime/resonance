tabs = require('sdk/tabs')
data = require('sdk/self').data 
getChan = require('./Utils.js').getChan

require("sdk/simple-storage").storage.attachedPages ?= []
pages = require("sdk/simple-storage").storage.attachedPages

Nick = require("sdk/simple-storage").storage.nick

require("sdk/simple-storage").storage.messagesHistory ?= {}
messagesHistory = require("sdk/simple-storage").storage.messagesHistory

isAttached = {}
for p in pages
  isAttached[p.chan] = true

tab = undefined
masterWorker = undefined

openMaster = (t) ->
  tab = t
  #if not tab.isPinned
  #  tab.pin()

  tab.isMaster = true
  masterWorker = tab.attach({
                      contentScriptFile:[
                        data.url("lib/angular.min.js"),
                        data.url("attached/attached.js"),
                        data.url("attached/AttachedMessagesController.js"),
                        data.url("attached/AttachedUsersController.js"),
                      ]
                  })
  masterWorker.port.on 'detach', (page) ->
    detach(page.chan)

  masterWorker.port.on 'message', (to, message) ->
     say(to, message)

  masterWorker.port.on 'ready', () ->
    masterWorker.port.emit('nick',Nick.nick)
    masterWorker.port.emit('bot',BOT)
    masterWorker.port.emit('pages',pages) 
    for page in pages
      masterWorker.port.emit('messagesHistory', page.chan, messagesHistory[page.chan] ? [])    

self = this
init = (workers, BOT, say) ->
  self.workers = workers
  self.BOT = BOT
  self.say = say

attach = (url, title) ->
  chan = getChan(url,title) 
  page = 
   'url' : url
   'title' : title
   'chan' : chan
  pages.push(page)
  masterWorker?.port.emit('pages',pages)
  masterWorker.port.emit('nick',Nick.nick)
  masterWorker.port.emit('bot',BOT)
  #todo warning asynchronous, what if pages arrives after messagesHistory ?
  masterWorker?.port.emit('messagesHistory', chan, messagesHistory[chan] ? [])
  workers[chan]?.emit('attached')
  isAttached[chan] = true
  client.send('names',chan)

detach = (chan) ->
     # part from chan ?
  for p,i in pages
    if (p.chan == chan)
      pages.splice(i,1)
      break
  masterWorker?.port.emit('pages',pages)
  workers[chan]?.emit('detached')
  isAttached[chan] = false
  if not workers[chan]?.hasWorkers()
    client.part(chan)

# When the client receives a message.
receive = (from, to, message) ->
    # todo : refactor history, same structure for pm / chans ? (same 'to')
    if to[0] == '#'
      # It goes to the corresponding chan / masterWorker.
      masterWorker?.port.emit('message',from,to,message)
      # Save in history.
      # todo refactor : where should messagesHistory be updated ?
      # messagesHistory[to] ?= []
      # messagesHistory[to].push( {'author':from, 'message': message } )

onSay = (to, message) ->
      # Tell back the application that the message has been said.
      masterWorker?.port.emit('message',Nick.nick,to,message)
     
self = this
bindClient = (client) ->
  # todo : hy this global ?
  self.client = client
  
  client.addListener 'message', (from, to, message) ->
    receive(from, to, message)
  
  client.addListener 'registered', () ->
    for page in pages
      client.join(page.chan)
      client.say(BOT,'__enter '+page.url+' '+page.chan)

  client.addListener 'names', (chan,nicks) ->
    masterWorker?.port.emit('names',chan, nicks)

  
  client.addListener 'join', (chan,nick) ->
    masterWorker?.port.emit('join',chan, nick)

  # The part event is also triggered when the client leaves a channel, thus creating an error because the worker does no longer exist.
  client.addListener 'part', (chan,nick) ->
    if nick isnt Nick.nick
      masterWorker?.port.emit('part',chan, nick)



bindWorker = (worker) ->
  worker.port.on 'attach',(url, title)->
    attach(url,title)
  worker.port.on 'detach',(chan)->
    detach(chan)

initWorker = (worker, chan) ->
  for p,i in pages
    if (p.chan == chan)
      worker.port.emit('attached')
      break

module.exports = 
    'init':init
    'attach':attach
    'bindClient':bindClient
    'onSay':onSay
    'bindWorker':bindWorker
    'initWorker':initWorker
    'isAttached':isAttached
    'openMaster':openMaster