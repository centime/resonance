irc = require('./irc')

encode = (unencoded) ->
    new Buffer(unencoded || '').toString('base64')
decode = (encoded) ->
    new Buffer(encoded || '', 'base64').toString('utf8')

bot = new irc.Client('chat.freenode.net', 'Resonance-bot2', {
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
        console.log(visits)
        command = message.replace('ask ','')
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
