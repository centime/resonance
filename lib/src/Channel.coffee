class Channel
  constructor: (chan,worker) ->    
    @chan = chan
    @linkedWorkers = [worker]
  addWorker: (worker) ->    
    @linkedWorkers.push(worker)
  removeWorker: (worker) ->
    @linkedWorkers = (w for w in @linkedWorkers when w isnt worker)
  # todo : use arguments, bitch !
  emit: (eventName, a,b,c,d,e,f,g,h,i) ->
    for w in @linkedWorkers
      w.port.emit(eventName,a,b,c,d,e,f,g,h,i)
  hasWorkers: () ->
    @linkedWorkers.length > 0
  numWorkers: () ->
    @linkedWorkers.length
  
module.exports =
  'Channel':Channel