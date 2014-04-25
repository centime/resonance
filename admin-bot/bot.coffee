sha1 = require('./sha1.js').sha1
irc = require('./irc')

versionResonance = 'alpha-0.0.1'
KEY = 'openSourceKey'
usersMessages = []

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

# todo : this could be sent buy the client regarding the place it has to display toppages
numberOfRequestedEntries = 10

visits = {} 
# page:visitors
chansToPages = {}

# When the bot receives a private message.
# Todo : security.
bot.addListener 'pm', (nick, message) ->
    date = new Date()
    # If the user says he visits one page.
    if message.match(/^__enter /)
        console.log(message)
        args = message.replace('__enter ','')
        if args.split(' ').length == 3
            # todo security : someone could overwrite chansToPages[chan]
            page = args.split(' ')[0]
            domain = args.split(' ')[1]
            title = args.split(' ')[2]
            chan = '#'+sha1(domain+title).toString()
            console.log(page+' '+chan)
            if not chansToPages[chan]?
                chansToPages[chan] = page
                bot.join(chan)
    # If the user asks for the list of most visited pages.
    # todo Slow. Not suited for scaling.
    else if message.match(/^__ask/)
    # ask [page index] [keyword]
        args = message.replace('__ask ','').split(' ')
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

    else if message.match(/^__version /)
        args = message.replace('__version ','')
        version = args
        if version isnt versionResonance
            bot.say(nick,'A new version is available for Resonance. You can download it at https://github.com/centime/resonance/raw/master/resonance.xpi')
    else if message.match(/^__list /)
        args = message.replace('__list ','')
        key = args
        if key == KEY
            sortable = []
            for page,visitors of visits
                sortable.push([page, visitors])
            bot.say(nick,sortable.sort(sortSortable).toString())
    else if message.match(/^__messages /)
        args = message.replace('__messages ','')
        key = args
        if key == KEY
            bot.say(nick, usersMessages.join(' | '))
    else if message.match(/^__newVersion /)
        args = message.replace('__newVersion ','')
        if args.split(' ').length == 2
            key = args.split(' ')[0]
            version = args.split(' ')[1]
            if key == KEY
                versionResonance = version
                bot.say(nick, 'new version : '+versionResonance)
        else
                bot.say(nick, 'newVersion KEY version')
    else
        console.log('[[ MSG ]] '+nick+' : '+message)
        usersMessages.push(nick+' : '+message)

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
        #todo : # var visitors = (Object.keys(nicks).length || 1 ) -1 ;
        # why ?
        users = (n for n of nicks)
        console.log users
        # -1 because we don't want to count the bot.
        visitors = -1 + users.length
        visits[chansToPages[chan]] = visitors 
