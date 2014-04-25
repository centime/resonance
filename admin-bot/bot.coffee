irc = require('./irc')

encode = (unencoded) ->
    new Buffer(unencoded || '').toString('base64')
decode = (encoded) ->
    new Buffer(encoded || '', 'base64').toString('utf8')

bot = new irc.Client('chat.freenode.net', 'Resonance-bot', {
    debug: false,
    channels: ['#resonance'],
})

bot.addListener 'error', (message) ->
    console.error('ERROR: %s: %s', message.command, message.args.join(' '))
bot.addListener 'registered',() ->
    console.log('Connected')

# The structure in which are kept the pages visited.
visits = {'test':0, 'TEST1':1, 
'Lorem ipsum dolor sit amet consectetur adipiscing elit. Aliquam non fermentum lacus et vehicula purus. Aenean fringilla nibh sapien sed auctor orci fermentum in. Sed cursus at magna et vulputate. Duis mauris lacus adipiscing et justo ac congue gravida nibh. Aliquam luctus magna et ligula tristique bibendum. Duis at venenatis neque. Mauris non risus sed tellus molestie placerat sed sit amet metus. Sed luctus semper imperdiet. Quisque pulvinar tortor est nec dictum lacus feugiat a. Sed interdum urna quis lacus sodales':10,
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1':5,
'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2':5,
'ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc':6,
'test':0, 'TEST1':1
}
# page:visitors
chansToPages = {}

# todo : this could be sent buy the client regarding the place it has to display toppages
numberOfRequestedEntries = 10

# When the bot receives a private message.
# Todo : security.
bot.addListener 'pm', (nick, message) ->
    console.log(message)
    date = new Date()
    # If the user says he visits one page.
    if message.match(/^enter/)
        page = message.replace('enter ','').split(' ')[0]
        # Need to get title instead, and regenerate the hash.
        # for security reason
        chan = message.replace('enter ','').split(' ')[1]
        if not chansToPages[chan]?
            chansToPages[chan] = page
            bot.join(chan)
    # If the user asks for the list of most visited pages.
    # todo Slow. Not suited for scaling.
    if message.match(/^ask/)
        # ask [page index] [keyword]
        args = message.replace('ask ','').split(' ')
        indexRequestedTopPages = Number(args[0])
        regexp = new RegExp(args[1])

        # Construct an array with every page requested.
        # [ [page1,visitors1],[page2,visitors2] ]
        sortable = []
        for page,visitors of visits
            if page.match(regexp)
                sortable.push([page, visitors])

        # Sort this array regarding the number of visitors.
        sortSortable = (a,b) -> (b[1] - a[1])
        sorted = sortable.sort(sortSortable)

        # Select only the entries requested
        i = indexRequestedTopPages
        n = numberOfRequestedEntries
        selectedByIndex = sorted[i*n..(i+1)*n-1]

        # Construct the complete response for the topPages request.
        # [ ['site1',1], ['site2',2] ]   ----->    'site1,1|site2,2'
        topPagesResponse = selectedByIndex.join('|')

        # Split the response so it wil go through IRC.
        numberOfPackets = Math.ceil(topPagesResponse.length / packetSize)
        # todo warning take into account String(i).length
        packetSize = 200

        # Send topPages metadata.
        totalIndices = Math.ceil(sorted.length / numberOfRequestedEntries)
        bot.say(nick,'topPagesMetaData '+[regexp, indexRequestedTopPages, totalIndices].join(' '))

        # Send every paquet.
        for i in [0..numberOfPackets-1]
            packet=topPagesResponse.substr(i*packetSize,packetSize)
            # todo warning : what if 2 toppages are requested at the same time ?
            bot.say('topPages '+[i, numberOfPackets, packet].join(' '))    

    

    if message.match(/^coucou/)
        bot.say(nick,'hi')

    if message.match(/^list/)
        console.log(visits)
    
# Once the bot is ready.
bot.addListener 'names#resonance', () ->
    # Listen for ins / outs for every chan where people are.
    bot.addListener 'part',(chan,nick) ->
        if chansToPages[chan]?
            visitors = (visits[chansToPages[chan]] -= 1)
            if visitors == 0
                bot.part(chan)
                delete visits[chansToPages[chan]]
                delete chansToPages[chan]
            
    bot.addListener 'quit', (nick, reason, channels, message) ->
        for chan in channels
            if chansToPages[chan]?
                visitors = (visits[chansToPages[chan]] -= 1)
                if visitors == 0
                    bot.part(chan)
                    delete visits[chansToPages[chan]]
                    delete chansToPages[chan]
    
    # todo : break loop
    bot.addListener 'kill', (nick, reason, channels, message) ->
        for chan in channels
            if chansToPages[chan]?
                visitors = (visits[chansToPages[chan]] -= 1)
                if visitors == 0
                    bot.part(chan)
                    delete visits[chansToPages[chan]]
                    delete chansToPages[chan]

    bot.addListener 'join', (chan,nick) ->
        visitors = visits[chansToPages[chan]] += 1

    bot.addListener 'names', (chan,nicks) ->
        # et si le bot arrive avant le visiteur ?

        #todo : # var visitors = (Object.keys(nicks).length || 1 ) -1 ;
        # why ?
        visitors = ( (n for n of nicks).length -1 )
        visits[chansToPages[chan]] = visitors 