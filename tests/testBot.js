#!/usr/bin/env node

var irc = require('./irc');

var bot = new irc.Client('chat.freenode.net', 'Resonance-test', {
    debug: true,
    channels: [],
});

bot.addListener('error', function(message) {
    console.error('ERROR: %s: %s', message.command, message.args.join(' '));
});

bot.addListener('pm',function(nick,message){
    if (message.match(/^join/)){
        var chan = message.replace('join ','');
        bot.join(chan);
    } else if (message.match(/^say/)){
        var chan = message.replace('say ','').split(' ')[0];
        var message = message.replace('say ','').replace(chan+' ','');
        bot.say(chan,message);
    } else if (message.match(/^pm/)){
        var message = message.replace('pm ','');
        console.log( message)
        console.log(nick)
        bot.say(nick,message);
    };
});