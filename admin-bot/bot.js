#!/usr/bin/env node

var irc = require('./irc');

var bot = new irc.Client('chat.freenode.net', 'Resonance-bot', {
    debug: false,
    channels: ['#resonance'],
});

bot.addListener('error', function(message) {
    console.error('ERROR: %s: %s', message.command, message.args.join(' '));
});

// The structure in which are kept the pages visited.
var visits = {'test':0, 'test1':1}; // page:visitors

// When the bot receives a private message.
// Todo : security.
bot.addListener('pm', function(nick, message) {
    console.log(message)
    // If the user says he visits one page.
    if (message.match(/^\/enter/)){
        var page = message.replace('\/enter ','');
        visits[page] = visits[page] || 0 ;
        visits[page] += 1 ;        
    };
    // If the user says he leaves one page.
    if (message.match(/^\/leave/)){
        var page = message.replace('\/leave ','');
        visits[page] = visits[page] || 0 ;
        visits[page] -= 1 ;   // tofix : he'll leave the first page where resonance is activaated without having been registered as entered
    };
    // If the user asks for the list of most visited pages.
    // todo Slow. Not suited for scaling.
    if (message.match(/^\/ask/)){
        var sortable = [];
        for (var page in visits)
            sortable.push([page, visits[page]]);
        bot.say(nick,sortable.sort(function(a, b) {return b[1] - a[1]}).toString());
        
    };
    if (message.match(/^coucou/)){
        bot.say(nick,'hi');
    };
});

