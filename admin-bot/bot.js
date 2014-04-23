#!/usr/bin/env node 
var irc = require('./irc');

function encode(unencoded) {return new Buffer(unencoded || '').toString('base64');};
function decode (encoded) {return new Buffer(encoded || '', 'base64').toString('utf8');};

var bot = new irc.Client('chat.freenode.net', 'Resonance-bot', {
    debug: false,
    channels: ['#resonance'],
});

bot.addListener('error', function(message) {console.error('ERROR: %s: %s', message.command, message.args.join(' '));});
bot.addListener('registered',function(){
    console.log('Connected')
})
// The structure in which are kept the pages visited.
var visits = {}; 
// page:visitors
var chansToPages = {}

// When the bot receives a private message.
// Todo : security.
bot.addListener('pm', function(nick, message) {
    console.log(message);
    var date = new Date();
    // If the user says he visits one page.
    if (message.match(/^enter/)){
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
    if (message.match(/^ask/)){
        console.log(visits)
        var command = message.replace('ask ','')||'';
        var sortable = [];  
        //paramètre 'global'
        if (command.match(/^global/)){
            for (var page in visits)
                sortable.push([page, visits[page]]);
        //paramètre 'domaine'
        }else if(command.match(/^domain /)){
            var domain = command.replace('domain ','')||'';
            domain = new RegExp("(^http:\/\/|^https:\/\/)(www\.|)"+domain);
            for (var page in visits)
                if(page.match(domain))
                    sortable.push([page, visits[page]]);
        //paramètre 'keyword'
        }else if(command.match(/^keyword /)){
            var keyword = command.replace('keyword ','')||'';
            keyword = new RegExp(keyword);
            for (var page in visits)
                if(page.match(keyword))
                    sortable.push([page, visits[page]]);
        }
        //Sorting and turning into string
        var chunk = 'begin'+sortable.sort(function(a, b) {return b[1] - a[1]}).toString();
        //max size of chunk : 446-entete
        var tchunk = (chunk.length/446).toFixed(0);
        tchunk++;
        for (var i = 0; i < tchunk; i++) {
            bot.say(nick,'topPages '+encode(chunk.substr(i*436,(i+1)*436)))
        }
    };
    if (message.match(/^coucou/)){
        bot.say(nick,'hi');
    };
    if (message.match(/^list/)){
        console.log(visits)
    };
});

// Once the bot is ready.
bot.addListener('names#resonance',function(){
    // Listen for ins / outs for every chan where people are.
    bot.addListener('part',function(chan,nick){
        if (typeof(chansToPages[chan]) !== 'undefined'){
                visitors = visits[chansToPages[chan]] -= 1 ;
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
    });
    bot.addListener('names',function(chan,nicks){
        // et si le bot arrive avant le visiteur ?
        var visitors = (Object.keys(nicks).length || 1 ) -1 ;
        visits[chansToPages[chan]] = visitors ;
        
    });
});