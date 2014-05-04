tabs = require('sdk/tabs')
data = require('sdk/self').data 
getChan = require('./Utils.js').getChan

require("sdk/simple-storage").storage.attachedPages ?= []
pages = require("sdk/simple-storage").storage.attachedPages

Nick = require("sdk/simple-storage").storage.nick

require("sdk/simple-storage").storage.messagesHistory ?= {}
messagesHistory = require("sdk/simple-storage").storage.messagesHistory

tab = undefined
worker = undefined

tabs.open({
    'url':data.url('attached.html')
    'onReady': (t) ->
        tab = t
        worker = tab.attach({
                            contentScriptFile:[
                              data.url("lib/angular.min.js"),
                              data.url("attached/attached.js"),
                              data.url("attached/AttachedMessagesController.js"),
                            ]
                        })
        worker.port.emit('pages',pages)
        for page in pages
          worker.port.emit('messagesHistory', page.chan, messagesHistory[page.chan] ? [])

        worker.port.on 'detach', (page) ->
            # part from chan ?
            for p,i in pages
              if (p.chan == page.chan)
                pages.splice(i,1)
                break
            worker.port.emit('pages',pages)

        worker.port.on 'message', (to, message) ->
           say(client, to, message)
    })

attach = (url, title) ->
  chan = getChan(url,title) 
  page = 
   'url' : url
   'title' : title
   'chan' : chan
  pages.push(page)
  worker.port.emit('pages',pages)
  #todo warning asynchronous, what if pages arrives after messagesHistory ?
  worker.port.emit('messagesHistory', chan, messagesHistory[chan] ? [])

    
# When the client receives a message.
receive = (from, to, message) ->
    # todo : refactor history, same structure for pm / chans ? (same 'to')
    if to[0] == '#'
      # It goes to the corresponding chan / worker.
      worker.port.emit('message',from,to,message)
      # Save in history.
      # todo refactor : where should messagesHistory be updated ?
      # messagesHistory[to] ?= []
      # messagesHistory[to].push( {'author':from, 'message': message } )

say = (client, to, message) ->
      client.say(to,message)
      # Tell back the application that the message has been said.
      worker.port.emit('message',Nick.nick,to,message)
      # Save in history.
      messagesHistory[to] ?= []
      messagesHistory[to].push( {'author':Nick.nick, 'message': message } )

self = this
bindClient = (client) ->
  client.addListener 'message', (from, to, message) ->
    receive(from, to, message)
  # todo
  self.client = client
  # worker.port.on 'message', (to, message) ->
  #   say(client, to, message)


module.exports = 
    'attach':attach
    'bindClient':bindClient