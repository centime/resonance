#!/usr/bin/env node 

var irc = require('./irc');

function encode(unencoded) {
    return new Buffer(unencoded || '').toString('base64');
};

var bot = new irc.Client('chat.freenode.net', 'Resonance-bot', {
    debug: false,
    channels: ['#resonance'],
});

bot.addListener('error', function(message) {
    console.error('ERROR: %s: %s', message.command, message.args.join(' '));
});

// The structure in which are kept the pages visited.
var visits = {'test':0, 'TEST1':1, 
'Lorem ipsum dolor sit amet consectetur adipiscing elit. Aliquam non fermentum lacus et vehicula purus. Aenean fringilla nibh sapien sed auctor orci fermentum in. Sed cursus at magna et vulputate. Duis mauris lacus adipiscing et justo ac congue gravida nibh. Aliquam luctus magna et ligula tristique bibendum. Duis at venenatis neque. Mauris non risus sed tellus molestie placerat sed sit amet metus. Sed luctus semper imperdiet. Quisque pulvinar tortor est nec dictum lacus feugiat a. Sed interdum urna quis lacus sodales':10,
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1':5,
'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2':5,
'ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc':6,
}; 
// page:visitors

// When the bot receives a private message.
// Todo : security.
bot.addListener('pm', function(nick, message) {
    //console.log(message)
    // If the user says he visits one page.
    if (message.match(/^enter/)){
        var page = message.replace('enter ','');
        visits[page] = visits[page] || 0 ;
        visits[page] += 1 ;        
    };
    // If the user says he leaves one page.
    if (message.match(/^leave/)){
        var page = message.replace('leave ','');
        visits[page] = visits[page] || 0 ;
        visits[page] -= 1 ;   // tofix : he'll leave the first page where resonance is activaated without having been registered as entered
    };
    // If the user asks for the list of most visited pages.
    // todo Slow. Not suited for scaling.
    if (message.match(/^ask/)){
        var command = message.replace('ask ','')||'';
        var indexTopPages = Number(command.match('^[0-9]+ ')[0]);
        var sortable = [];
        //paramètre 'global'
        if (command.match(/^global/)){
            for (var page in visits)//needs splice(indexTopPages, 10)
                sortable.push([page, visits[page]]);
                console.log('step 1 : '+sortable.toString())
        }else if(command.match(/^keyword /)){
            var keyword = command.replace('keyword ','')||'';
            reg = new RegExp(keyword);
            for (var page in visits[0..indexTopPages])
                if(page.match(reg))
                    sortable.push([page, visits[page]]);
        }
        console.log(sortable.toString())
        //Sorting and turning into string
        var raw = 'top'+sortable.sort(function(a, b) {return b[1] - a[1]}).toString()+'end';
        //max size of chunk : 446-entete
        var tchunk = (raw.length/200).toFixed(0);
        tchunk++;
        for (var i = 0; i < tchunk; i++) {
            chunk=raw.substr(i*200,200);
            bot.say(nick,'topPages '+encode(chunk));
        }
    };
    if (message.match(/^coucou/)){
        bot.say(nick,'hi');
    };
});

