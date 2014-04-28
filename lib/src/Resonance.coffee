data = require("sdk/self").data 
storage = require("sdk/simple-storage").storage
Nick = require("sdk/simple-storage").storage.nick

{ getDomain, getChan } = require('./Utils.js')
Channel = require('./Channel.js').Channel

client = {}
workers = {}
workers.__proto__.emitToAll = () ->
  for own chan, worker of this
        worker.emit.apply(worker,arguments)


Messages = require('./Messages.js')
PrivateMessages = require('./PrivateMessages.js')
TopPages = require('./TopPages.js')
Users = require('./Users.js')


self = this
# env = {VERSION}
init = (VERSION) ->
  self.VERSION = VERSION
    
  Messages.init(workers)
  PrivateMessages.init(workers)
  TopPages.init(workers)
  Users.init(workers)

# You need to Resonance.init({VERSION}) first
startClient = () ->

  client = require('./Client.js').startClient(VERSION,workers)

  Users.bindClient(client)
  Messages.bindClient(client)
  PrivateMessages.bindClient(client)
  TopPages.bindClient(client)

closeClient = () ->
  workers.emitToAll('close')
  client.disconnect()


start = (tab) ->
  # Generate the chan name for the page.
  chan = getChan(tab.url,tab.title)
  # Save it.
  tab.chan = chan
  # Join the new chan.
  client.join(chan)
  # Request a list of users.
  client.send('NAMES',chan) 

  # Tell the admin-bot about it.
  domain = getDomain(tab.url)
  title = tab.title.replace(/\ /g,'')
  client.say('Resonance-bot','__enter '+tab.url+' '+domain+' '+title)
  
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
  if workers[chan]?
    workers[chan].addWorker(worker)
  else workers[chan] = new Channel(chan, worker)  

  # Send the application some init values.
  worker.port.emit('appSize', storage.appSize ? '100')
  worker.port.emit('chan',chan)
  worker.port.emit('nick',Nick.nick)
  
  Users.initWorker(worker)
  Messages.initWorker(worker, chan)
  PrivateMessages.initWorker(worker)

  Messages.bindWorker(worker, client)
  PrivateMessages.bindWorker(worker, client)
  TopPages.bindWorker(worker, client)
  Users.bindWorker(worker)

  
  worker.port.on "newAppSize", (height) ->
    #todo : sanitize !
    storage.appSize = height
    workers.emitToAll('appSize',height)


end = (tab) ->
  previousChan = tab.chan
  # Get the binded worker.
  # todo : le worker attaché est il le même pour un même tab ?!
  previousWorker = tab.worker
  # Remove it from the list of workers linked to the chan.
  workers[previousChan].removeWorker(previousWorker)
  # Leave the previous chan if there are no more workers binded to it.
  if not workers[previousChan].hasWorkers()
    client.part(previousChan)
    delete workers[previousChan]
  tab.chan = undefined
  tab.worker = undefined


module.exports =
  'init':init
  'startClient':startClient
  'closeClient':closeClient
  'start' : start
  'end' : end