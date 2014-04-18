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
var visits = {'test':0, 'test1':1, 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam non fermentum lacus, et vehicula purus. Aenean fringilla nibh sapien, sed auctor orci fermentum in. Sed cursus at magna et vulputate. Duis mauris lacus, adipiscing et justo ac, congue gravida nibh. Aliquam luctus magna et ligula tristique bibendum. Duis at venenatis neque. Mauris non risus sed tellus molestie placerat sed sit amet metus. Sed luctus semper imperdiet. Quisque pulvinar tortor est, nec dictum lacus feugiat a. Sed interdum urna quis lacus sodales, in rhoncus dolor elementum. Praesent at posuere justo. Mauris imperdiet tristique tortor, a viverra ipsum placerat nec. Quisque ultricies urna vitae libero interdum fringilla. Sed eu ullamcorper turpis, eget bibendum magna. In mattis felis mattis ornare ullamcorper. Donec tristique, tellus quis dignissim condimentum, lectus lorem iaculis urna, sit amet congue velit tortor vitae est. Suspendisse ac dui tincidunt, ultricies justo sit amet, auctor lorem. Curabitur quis fermentum neque. Ut posuere tincidunt turpis, nec interdum nisl malesuada ac. Morbi ac faucibus augue, at cursus ligula. Phasellus at augue quis quam porttitor aliquet in a nisi. Aliquam sodales lectus dui, tristique dictum nunc facilisis sed. ':2
}; // page:visitors

// When the bot receives a private message.
// Todo : security.
bot.addListener('pm', function(nick, message) {
    console.log(message)
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
        bot.say(nick,'top'+sortable.sort(function(a, b) {return b[1] - a[1]}).toString());
    };
    if (message.match(/^coucou/)){
        bot.say(nick,'hi');
    };
});

