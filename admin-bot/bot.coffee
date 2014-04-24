sha1 = require('sha1')
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

# The structure in which are kept the pages visited.
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
            chan = '#'+sha1(domain+title)
            console.log(page+' '+chan)
            if not chansToPages[chan]?
                chansToPages[chan] = page
                bot.join(chan)
    # If the user asks for the list of most visited pages.
    # todo Slow. Not suited for scaling.
    else if message.match(/^__ask/)
        command = message.replace('__ask ','')
        sortable = []  
        #paramètre 'global'
        if command.match(/^global/)
            for page,visitors of visits
                sortable.push([page, visitors])

        #paramètre 'domaine'
        else if command.match(/^domain /)
            domain = command.replace('domain ','')
            domain = new RegExp("(^http:\/\/|^https:\/\/)(www\.|)"+domain)
            for page,visitors of visits
                if page.match(domain)
                    sortable.push([page, visitors])
        #paramètre 'keyword'
        else if command.match(/^keyword /)
            keyword = command.replace('keyword ','')
            keyword = new RegExp(keyword)
            for page,visitors of visits
                if page.match(keyword)
                    sortable.push([page, visitors])
        
        #Sorting and turning into string
        sortSortable = (a,b) -> (b[1] - a[1])
        chunk = 'begin'+sortable.sort(sortSortable).toString()
        #max size of chunk : 446-entete
        tchunk = (chunk.length/446).toFixed(0)
        tchunk += 1
        for i in [0..tchunk-1]
            bot.say(nick,'topPages '+encode(chunk.substr(i*436,(i+1)*436)))
        
    else if message.match(/^ping$/)
        bot.say(nick,'pong')

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
