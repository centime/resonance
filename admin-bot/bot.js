#!/usr/bin/env node

var irc = require('./irc');

var bot = new irc.Client('chat.freenode.net', 'Resonance-bot', {
    debug: true,
    channels: ['#resonance'],
});

bot.addListener('error', function(message) {
    console.error('ERROR: %s: %s', message.command, message.args.join(' '));
});

// The structure in which are kept the pages visited.
var visits = {}; // page:visitors
var chansToPages = {}

// When the bot receives a private message.
// Todo : security.
bot.addListener('pm', function(nick, message) {
    console.log('\t\t\t\t\t'+message)
    var date = new Date();
    // If the user says he visits one page.
    if (message.match(/^enter/)){
        console.log('[[new page] '+date+' ] '+message)
        var page = message.replace('enter ','').split(' ')[0];
        // Need to get title instead, and regenerate the hash.
        // for security reason
        var chan = message.replace('enter ','').split(' ')[1];
        if ( typeof(chansToPages[chan]) === 'undefined'){
            chansToPages[chan] = page;
            bot.join(chan);
        }
        
    }
    // If the user asks for the list of most visited pages.
    // todo Slow. Not suited for scaling.
    else if (message.match(/^ask/)){
        console.log('[[ask] '+date+' ] '+message)
        var sortable = [];
        for (var page in visits)
            sortable.push([page, visits[page]]);
        bot.say(nick,'topPages '+sortable.sort(function(a, b) {return b[1] - a[1]}).toString());
        
    }else console.log('[[pm] '+date+' ] '+message)
});
bot.addListener('names#resonance',function(){
    bot.addListener('part',function(chan,nick){
        if (typeof(chansToPages[chan]) !== 'undefined'){
                visitors = visits[chansToPages[chan]] -= 1 ;
                console.log('part : '+visitors+' : '+chansToPages[chan])
                if (visitors == 0){
                    bot.part(chan);
                    delete visits[chansToPages[chan]] ;
                    delete chansToPages[chan] ;
                }
        };
    });
    bot.addListener('quit',function(nick, reason, channels, message){
        for (i in channels){
            var chan = channels[i];
            if (typeof(chansToPages[chan]) !== 'undefined'){
                    visitors = visits[chansToPages[chan]] -= 1 ;
                    console.log('quit : '+visitors+' : '+chansToPages[chan])
                    if (visitors == 0){
                        bot.part(chan);
                        delete visits[chansToPages[chan]] ;
                        delete chansToPages[chan] ;
                    };
            };
        };
    });
    bot.addListener('kill',function(nick, reason, channels, message){
        for (i in channels){
            var chan = channels[i];
            if (typeof(chansToPages[chan]) !== 'undefined'){
                    visitors = visits[chansToPages[chan]] -= 1 ;
                    console.log('kill : '+visitors+' : '+chansToPages[chan])
                    if (visitors == 0){
                        bot.part(chan);
                        delete visits[chansToPages[chan]] ;
                        delete chansToPages[chan] ;
                    };
            };
        };
    });
    bot.addListener('join',function(chan,nick){
        visitors = visits[chansToPages[chan]] += 1 ;
        console.log('join : '+visitors+' : '+chansToPages[chan])
    });
    bot.addListener('names',function(chan,nicks){
        // et si le bot arrive avant le visiteur ?
        var visitors = (Object.keys(nicks).length || 1 ) -1 ;
        console.log('new : '+visitors+' : '+chansToPages[chan])
        visits[chansToPages[chan]] = visitors ;
        
    });
});
