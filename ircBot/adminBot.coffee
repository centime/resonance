sha1 = require('./sha1.js').sha1
irc = require('./irc')

version = 'alpha-0.0.1'
KEY = 'openSourceKey'
usersMessages = [] 
abuses = []
announce = 'Welcome to the alpha of Resonance ! Feel free to make any feedback via a private message to "Resonance-bot" or to quelques.centimes@gmail.com'

console.log [version, KEY, announce].join('\n\n')

encode = (unencoded) ->
    new Buffer(unencoded || '').toString('base64')
b64decode = (encoded) ->
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
numberOfRequestedEntries = 11


# todo : pages -> chan ?
visits = {} 
# page:visitors
chansToPages = {}

# When the bot receives a private message.
# Todo : security.
bot.addListener 'pm', (nick, message) ->
    date = new Date()
    # If the user says he visits one page.
    if message.match(/^__enter /)
        args = message.replace('__enter ','').split(' ')
        if args.length == 2
            # todo security : someone could overwrite chansToPages[chan]
            [ page, chan ] = args
            # domain = args.split(' ')[1]
            # title = b64decode(args.split(' ')[2])
            # console.log 'domain '+domain+' title '+title
            # chan = '#'+sha1(domain+title).toString()
            console.log ['__enter',page,chan].join(' ')
            # todo warnig tofix security abuse
            if not chansToPages[chan]?
                chansToPages[chan] = page
                bot.join(chan)
            else 
                if chansToPages[chan] isnt page
                    abuses.push(nick+' : '+message)
                    console.log('[[ Abuse ? ]] '+nick+' : '+message)
    # If the user asks for the list of most visited pages.
    # todo Slow. Not suited for scaling.
    else if message.match(/^__ask/)
    # ask [page index] [keyword]
        args = message.replace('__ask ','').split(' ')
        indexRequestedTopPages = Number(args[0])
        query = args[1]
        regexp = new RegExp(query)

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

        # Send topPages metadata.
        totalIndices = Math.ceil( sorted.length/numberOfRequestedEntries )
        bot.say(nick,'topPagesMetaData '+[query, indexRequestedTopPages, totalIndices].join(' '))

        # Split the response so it wil go through IRC.
        # todo warning take into account String(i).length
        packetSize = 200
        numberOfPackets = Math.ceil( topPagesResponse.length/packetSize )

        numberOfPackets = 1 if (numberOfPackets==0)
        # Send every paquet.
        for i in [0..numberOfPackets-1]
            packet=topPagesResponse.substr(i*packetSize,packetSize)
            # todo warning : what if 2 toppages are requested at the same time ?
            bot.say(nick, 'topPages '+[i, numberOfPackets, packet].join(' '))    
    else if message.match(/^__getAnnounce/)
        bot.say(nick, 'announce '+announce)
    else if message.match(/^__version /)
        args = message.replace('__version ','')
        clientVersion = args
        if clientVersion isnt version
            bot.say(nick,'A new version is available for Resonance. You can download it at https://github.com/centime/resonance/raw/master/resonance.xpi')
    else if message.match(/^__list /)
        args = message.replace('__list ','')
        key = args
        if key == KEY
            sortable = []
            for page,visitors of visits
                sortable.push([page, visitors])
            sortSortable = (a,b) -> (b[1] - a[1])
            bot.say(nick,sortable.sort(sortSortable).toString())
    else if message.match(/^__messages /)
        args = message.replace('__messages ','')
        key = args
        if key == KEY
            bot.say(nick, usersMessages.join(' | '))
    else if message.match(/^__abuses /)
        args = message.replace('__abuses ','')
        key = args
        if key == KEY
            bot.say(nick, abuses.join(' | '))
    else if message.match(/^__newVersion /)
        args = message.replace('__newVersion ','')
        if args.split(' ').length == 2
            key = args.split(' ')[0]
            version = args.split(' ')[1]
            if key == KEY
                version = version
                bot.say(nick, 'new version : '+version)
        else
                bot.say(nick, 'newVersion KEY version')
    else if message.match(/^__newAnnounce /)
        args = message.replace('__newAnnounce ','').split(' ')
        [key, newAnnounce] = args
        if key == KEY
            announce = newVersion
            bot.say(nick, 'new announce : '+announce)
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
        # -1 because we don't want to count the bot.
        visitors = users.length-1
        visits[chansToPages[chan]] = visitors 
