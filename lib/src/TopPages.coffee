metaData = (message,env) ->
    # Extract the arguments from the message.
    args = message.replace('topPagesMetaData ','').split(' ')
    [ query, indexRequestedTopPages, totalIndices ] = args
    # Pass the topPagesMetaData to the application.
    env.workers.emitToAll('topPagesMetaData', query, indexRequestedTopPages, totalIndices)

# Variable for storing and concatenating the multiple packets of a response.
topPagesResponse = {}
topPages = (message,env) ->
      # todo warning : what if there are multiple concurent requests for various keywords ?
      # Extract the arguments from the message.
      args = message.replace('topPages ','').split(' ')
      [ packetId, totalPackets, packetContent ] = args
      
      # Store the received content at the corresponding index.
      topPagesResponse[packetId] = packetContent

      completeResponse = ''
      receptionCompleted = true
      # Check that all packets have been received.
      for i in [0..totalPackets-1]
        receptionCompleted = topPagesResponse[packetId]?
        # Concat the packets into one string.
        completeResponse += topPagesResponse[packetId]

      # If all have been received.
      if receptionCompleted
        # Construct an array from the string
        # 'site1,1|site2,2'  --->   [ ['site1',1], ['site2',2] ]
        entries = completeResponse.split('|')
        pages = ( entry.split(',') for entry in entries)

        # Pass the topPages to the application.
        env.workers.emitToAll('topPages',pages)
        # Reset.
        topPagesResponse = {}

bindClient = (client,env) ->
  # env = {workers}
  client.addListener 'pm', (from, message) ->
  # If it comes from the bot.
    if from == 'Resonance-bot'
      if message.match(/^topPagesMetaData /)
        metaData(message, env)
      else if message.match(/^topPages /)
        topPages(message, env)

bindWorker = (worker, env) ->
  # Listen for the application asking for the top pages.
  worker.port.on 'getTopPages', (index,query) ->
    #Ask the bot for top tapes.
    env.client.say('Resonance-bot','__ask '+index+' '+query)
    
module.exports =
    'bindClient':bindClient
    'bindWorker':bindWorker
