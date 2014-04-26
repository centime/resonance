metaData = (message,env) ->
    # Extract the arguments from the message.
    args = message.replace('topPagesMetaData ','').split(' ')
    [ query, indexRequestedTopPages, totalIndices ] = args
    # Pass the topPagesMetaData to the application.
    env.workers.emitToAll('topPagesMetaData', query, indexRequestedTopPages, totalIndices)
  
topPages = (message,env) ->
      # todo warning : what if there are multiple concurent requests for various keywords ?
      # Extract the arguments from the message.
      args = message.replace('topPages ','').split(' ')
      [ packetId, totalPackets, packetContent ] = args
      
      # Variable for storing and concatenating the multiple packets of a response.
      env.client.topPagesResponse ?= {}
      # Store the received content at the corresponding index.
      env.client.topPagesResponse[packetId] = packetContent

      completeResponse = ''
      receptionCompleted = true
      # Check that all packets have been received.
      for i in [0..totalPackets-1]
        receptionCompleted = env.client.topPagesResponse[packetId]?
        # Concat the packets into one string.
        completeResponse += env.client.topPagesResponse[packetId]

      # If all have been received.
      if receptionCompleted
        # Construct an array from the string
        # 'site1,1|site2,2'  --->   [ ['site1',1], ['site2',2] ]
        entries = completeResponse.split('|')
        topPages = ( entry.split(',') for entry in entries)

        # Pass the topPages to the application.
        env.workers.emitToAll('topPages',topPages)
        # Reset.
        env.client.topPagesResponse = {}
      # todo : is the traffic / page refresh overhead really worth this 'optimisation' ?
      # If not all packets have been received, but the first yes.
      else if client.topPagesResponse[0]?
        partialResponse = env.client.topPagesResponse[0]
        # Remove the last incomplete page.
        lastIndex = partialResponse.lastIndexOf('|')
        # If at least one entry is complete.
        if lastIndex != -1
          partialResponse = env.client.topPagesResponse[0..lastIndex-1]

          # Construct an array from the string
          # 'site1,1|site2,2'  --->   [ ['site1',1], ['site2',2] ]
          entries = partialResponse.split('|')
          topPages = ( entry.split(',') for entry in entries)

          # Pass the topPages to the application.
          env.workers.emitToAll('topPages',topPages)
    
module.exports =
    'metaData':metaData
    'topPages':topPages
