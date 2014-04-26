data = require("sdk/self").data 
getChan = require('./Utils.js').getChan
Channel = require('./Channel.js').Channel


end = (tab,env) ->
  previousChan = tab.chan
  # Get the binded worker.
  # todo : le worker attaché est il le même pour un même tab ?!
  previousWorker = tab.worker
  # Remove it from the list of workers linked to the chan.
  env.workers[previousChan].removeWorker(previousWorker)
  # Leave the previous chan if there are no more workers binded to it.
  if not env.workers[previousChan].hasWorkers()
    env.client.part(previousChan)
    delete env.workers[previousChan]
  tab.chan = undefined
  tab.worker = undefined

start = (tab,env) ->
  # Generate the chan name for the page.
  chan = getChan(tab.url,tab.title)
  # Save it.
  tab.chan = chan
  # Join the new chan.
  env.client.join(chan)
  # Request a list of users.
  env.client.send('NAMES',chan) 

  # Tell the admin-bot about it.
  domain = tab.url.match(/^(https?\:)\/\/(([^:\/?#]*)(?:\:([0-9]+))?)(\/[^?#]*)(\?[^#]*|)(#.*|)$/)?[2] ?= ''
  title = tab.title.replace(/\ /g,'')
  env.client.say('Resonance-bot','__enter '+tab.url+' '+domain+' '+title)
  
  # Inject the application code into the page.
  worker = tab.attach({
      contentScriptFile:[
          data.url("lib/jquery.js"),
          data.url("lib/angular.min.js"),
          data.url("content-built.js"),
          data.url("controllers/app.js"),
          data.url("controllers/ResonanceController.js"),
          data.url("controllers/IrcController.js"),
          data.url("controllers/MessagesController.js"),
          data.url("controllers/UsersController.js"),
          data.url("controllers/TopPagesController.js"),
          data.url("controllers/PrivateMessagesController.js"),
          data.url("controllers/PrivateUsersController.js"),
          # USED FOR TESTS ONLY
          #data.url("tests.js"),
      ]})
  # Save the linked worker.
  tab.worker = worker

  # Save which worker is in charge for wich channel.
  # todo : clean the list when leaving chan
  # tofix : 2 onglets avec la même page ?
  if env.workers[chan]?
    env.workers[chan].addWorker(worker)
  else env.workers[chan] = new Channel(chan, worker)  

  # Send the application some init values.
  worker.port.emit('appSize',env.storage.appSize ? '100')
  worker.port.emit('chan',chan)
  worker.port.emit('requestMutedUsers',env.mutedUsers)
  worker.port.emit('nick',env.NICK)
  worker.port.emit('messagesHistory', env.storage.messagesHistory[chan] ? [])
  worker.port.emit('pmUsers',env.pmUsers)
  env.storage.privateMessagesHistory[env.currentPmUser] ?= []
  worker.port.emit('pmUser',env.currentPmUser, env.storage.privateMessagesHistory[env.currentPmUser])
  # todo : 
  # client.send('name',chan)
  
  MsgEnv = 
    'client' : env.client
    'workers' : env.workers
    'NICK' : env.NICK
    'storage' : env.storage
  env.Messages.bind(worker,MsgEnv)
  
  PmEnv = 
    'client' : env.client
    'workers' : env.workers
    'NICK' : env.NICK
    'storage' : env.storage
    'pmUsers' : env.pmUsers
    'currentPmUser' : env.currentPmUser
    'activePrivateUsers' : env.activePrivateUsers
  env.PrivateMessages.bind(worker,PmEnv)


# Listen for the application asking for the top pages.
  worker.port.on 'getTopPages', (index,query) ->
    #Ask the bot for top tapes.
    env.client.say('Resonance-bot','__ask '+index+' '+query)
    
  # stock the current muted Users
  worker.port.on "updateMutedUsers", (mutedUsers) ->
    env.storage.mutedUsers = mutedUsers
  
  worker.port.on "newAppSize", (height) ->
    #todo : sanitize !
    env.storage.appSize = height
    env.workers.emitToAll('appSize',height)

module.exports =
  'start' : start
  'end' : end