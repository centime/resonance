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
visits = {['test':0, 'TEST1':1, 
'Lorem ipsum dolor sit amet consectetur adipiscing elit. Aliquam non fermentum lacus et vehicula purus. Aenean fringilla nibh sapien sed auctor orci fermentum in. Sed cursus at magna et vulputate. Duis mauris lacus adipiscing et justo ac congue gravida nibh. Aliquam luctus magna et ligula tristique bibendum. Duis at venenatis neque. Mauris non risus sed tellus molestie placerat sed sit amet metus. Sed luctus semper imperdiet. Quisque pulvinar tortor est nec dictum lacus feugiat a. Sed interdum urna quis lacus sodales':10,
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1':5,
'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2':5,
'ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc':6,
'test':0, 'TEST1':1]
}
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
        command = message.replace('ask ','')
        indexTopPages = command.match('^[0-9]+ ')[0]
        command = command.replace(indexTopPages.toString(),'')
        sortable = []
        #paramètre 'global'
        if command.match(/^global/)
            i = Number(indexTopPages)
            j = Math.min(visits.length,(i+10))
            range = [i..j]
            console.log('visits '+j+'visits.length'+visits.length+'i'+i)
            for page,visitors in visits
                console.log('HERE')
                sortable.push([page, visitors])
                console.log(sortable.toString())
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
            reg = new RegExp(keyword);
            for page,visitors of visits
                if page.match(reg)
                    sortable.push([page, visitors])
        
        #Sorting and turning into string        
        sortSortable = (a,b) -> (b[1] - a[1])
        raw = 'top'+sortable.sort(sortSortable).toString()+'end'
        #max size of chunk : 446-entete
        tchunk = (raw.length/200).toFixed(0)
        for i in [0..tchunk]
            chunk=raw.substr(i*200,200)
            bot.say(nick,'topPages '+encode(chunk))    
    

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