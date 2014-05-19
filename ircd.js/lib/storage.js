var Channel = require('./channel').Channel,
    irc = require('./protocol');

function TopPageDatabase(server){
  this.server = server;
  this.pages = {
    'channel1':'#channel1',
    'channel2':'#channel2',
    // 'channel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjis':'#channel2',

    // 'chjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjis':'#channel2',
    // 'channel2sdjidsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjis':'#channel2',
    // 'chnel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjis':'#channel2',
    // 'chl2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjis':'#channel2',
    // 'channedsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjis':'#channel2',
    // 'channejdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjis':'#channel2',
    // 'channejdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjis':'#channel2',
    // 'channeidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjis':'#channel2',
    // 'channejdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjis':'#channel2',
    // 'channeljsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjischannel2sdjidsjidjsdjisjdijsidjisjdjsdjdisjdijsidjis':'#channel2',
    // 'end':'#end',
  };
  this.pagesPerResponse = 10;
}

TopPageDatabase.prototype = {
  add: function(chan, url) {
    this.pages[url] = chan;
  },
  get: function(filter, index) {
    var matchingPages = [];
    registered = this.server.channels.registered ;
    for (page in this.pages){
      if (page.match(new RegExp(filter)) ){
        var chan = this.pages[page];
        matchingPages.push( [page, registered[chan].users.length] );
        //matchingPages.push( [page].join(':') );
      };
    };
    

    sortedPages = matchingPages.sort(function(a,b){ return (b[1] - a[1]) })
    selectedPages = sortedPages.splice(index*this.pagesPerResponse, (index+1)*(this.pagesPerResponse-1))
    strPages = []
    sortedPages.forEach(function(p){
      strPages.push(p.join(':'));
    });
    return strPages.join(',')

        //     sortable = []
        // for page,visitors of visits
        //     console.log page+' '+visitors
        //     if not page?
        //         console.log('[[ Undefined ]]')
        //     else if page == 'undefined'
        //         console.log('UNdef entry')
        //     else if page.match(regexp)
        //         sortable.push([page, visitors])
        // # Sort this array regarding the number of visitors.
        // sortSortable = (a,b) -> (b[1] - a[1])
        // sorted = sortable.sort(sortSortable)

        // # Select only the entries requested
        // i = indexRequestedTopPages
        // n = numberOfRequestedEntries
        // selectedByIndex = sorted[i*n..(i+1)*n-1]

        // # Construct the complete response for the topPages request.
        // # [ ['site1',1], ['site2',2] ]   ----->    'site1,1|site2,2'
        // topPagesResponse = selectedByIndex.join('|')

        // # Send topPages metadata.
        // totalIndices = Math.ceil( sorted.length/numberOfRequestedEntries )
        // bot.say(nick,'topPagesMetaData '+[query, indexRequestedTopPages, totalIndices].join(' '))

        // # Split the response so it wil go through IRC.
        // # todo warning take into account String(i).length
        // packetSize = 200
        // numberOfPackets = Math.ceil( topPagesResponse.length/packetSize )

        // numberOfPackets = 1 if (numberOfPackets==0)
        // # Send every paquet.
        // for i in [0..numberOfPackets-1]
        //     packet=topPagesResponse.substr(i*packetSize,packetSize)
        //     # todo warning : what if 2 toppages are requested at the same time ?
        //     bot.say(nick, 'topPages '+[i, numberOfPackets, packet].join(' '))    

  },

}



function History(server) {
  this.server = server;
  this.config = server.config;
  this.items = [];
}

History.prototype = {
  add: function(user) {
    this.items.unshift({ nick: user.nick,
                         username: user.username,
                         realname: user.realname,
                         host: user.hostname,
                         server: user.serverName,
                         time: new Date() });
    if (this.config) {
      this.items.slice(0, this.config.whoWasLimit);
    }
  },

  find: function(nick) {
    return this.items.filter(function(item) {
      return nick === item.nick;
    });
  }
};

function UserDatabase(server) {
  this.server = server;
  this.config = server.config;
  this.registered = [];
}

UserDatabase.prototype = {
  forEach: function(fn) {
    this.registered.forEach(fn);
  },

  push: function(user) {
    this.registered.push(user);
  },

  register: function(user, username, hostname, servername, realname) {
    user.username = username;
    user.realname = realname;
    this.registered.push(user);
    user.register();
  },

  find: function(nick) {
    nick = this.server.normalizeName(nick);
    for (var i = 0; i < this.registered.length; i++) {
      if (this.registered[i] && this.server.normalizeName(this.registered[i].nick) === nick)
        return this.registered[i];
    }
  },

  remove: function(user) {
    if (this.registered.indexOf(user) !== -1) {
      this.registered.splice(this.registered.indexOf(user), 1);
    }
  }
};

function ChannelDatabase(server) {
  this.server = server;
  this.registered = {};
}

ChannelDatabase.prototype = {
  message: function(user, channel, message) {
    if (!channel) return;
    channel.users.forEach(function(channelUser) {
      if (channelUser !== user) {
        channelUser.send(user.mask, 'PRIVMSG', channel.name, ':' + message);
      }
    });
  },

  expandMask: function(mask) {
    return mask.replace(/\./g, '\\.').
                replace(/\*/g, '.*');
  },

  findWithMask: function(channelMask) {
    channelMask = this.expandMask(this.server.normalizeName(channelMask));
    for (var channelName in this.registered) {
      if (channelMask.match(channelName)) {
        return this.registered[channelName];
      }
    }
  },

  find: function(channelName) {
    return this.registered[this.server.normalizeName(channelName)];
  },

  join: function(user, channelName, key) {
    // TODO: valid channel name?
    // Channels names are strings (beginning with a '&' or '#' character) of
    // length up to 200 characters.  Apart from the the requirement that the
    // first character being either '&' or '#'; the only restriction on a
    // channel name is that it may not contain any spaces (' '), a control G
    // (^G or ASCII 7), or a comma (',' which is used as a list item
    // separator by the protocol).

    var channel = this.find(channelName);

    if (!channel) {
      channel = this.registered[this.server.normalizeName(channelName)] = new Channel(channelName, this.server);
    }

    if (channel.isMember(user)) {
      return;
    }

    if (channel.isInviteOnly && !channel.onInviteList(user)) {
      user.send(this.server.host, irc.errors.inviteOnly, user.nick, channel.name, ':Cannot join channel (+i)');
      return;
    }

    if (channel.isBanned(user)) {
      user.send(this.server.host, irc.errors.banned, user.nick, channel.name, ':Cannot join channel (+b)');
      return;
    }

    if (channel.isLimited && channel.users.length >= channel.userLimit) {
      user.send(this.server.host, irc.errors.channelIsFull, user.nick, channel.name, ':Channel is full.');
      return;
    }

    if (channel.key) {
      if (key !== channel.key) {
        user.send(this.server.host, irc.errors.badChannelKey, user.nick, this.name, ":Invalid channel key");
        return;
      }
    }

    if (channel.users.length === 0) {
      user.op(channel);
    }

    channel.users.push(user);
    user.channels.push(channel);

    channel.users.forEach(function(channelUser) { 
      channelUser.send(user.mask, 'JOIN', channel.name);
    });

    if (channel.topic) {
      user.send(this.server.host, irc.reply.topic, user.nick, channel.name, ':' + channel.topic);
    } else {
      user.send(this.server.host, irc.reply.noTopic, user.nick, channel.name, ':No topic is set');
    }

    user.send(this.server.host, irc.reply.nameReply, user.nick, channel.type, channel.name, ':' + channel.names);
    user.send(this.server.host, irc.reply.endNames, user.nick, channel.name, ':End of /NAMES list.');
  },

  remove: function(channel) {
    delete this.registered[channel.name];
  }
};



exports.History = History;
exports.ChannelDatabase = ChannelDatabase;
exports.UserDatabase = UserDatabase;
exports.TopPageDatabase = TopPageDatabase;
