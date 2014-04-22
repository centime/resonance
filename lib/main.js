(function() {
  var URL, chan, channelsToWorkers, client, currentNick, currentPmUser, data, emitToAllWorkers, irc, list, m, mutedUsers, passEvent, pmUsers, sha1, storage, tabToPreviousPage, tabs, user, widgets, _i, _j, _len, _len2, _ref, _ref2, _ref3, _ref4,
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __hasProp = Object.prototype.hasOwnProperty;

  widgets = require("sdk/widget");

  URL = require('sdk/url').URL;

  tabs = require('sdk/tabs');

  data = require("sdk/self").data;

  storage = require("sdk/simple-storage").storage;

  sha1 = require('./sha1.js').sha1;

  irc = require('./bundle');

  if (storage.messagesHistory == null) storage.messagesHistory = {};

  if (storage.privateMessagesHistory == null) storage.privateMessagesHistory = {};

  _ref = storage.messagesHistory;
  for (chan in _ref) {
    list = _ref[chan];
    for (_i = 0, _len = list.length; _i < _len; _i++) {
      m = list[_i];
      m.old = 'true';
    }
  }

  _ref2 = storage.privateMessagesHistory;
  for (user in _ref2) {
    list = _ref2[user];
    for (_j = 0, _len2 = list.length; _j < _len2; _j++) {
      m = list[_j];
      m.old = 'true';
    }
  }

  pmUsers = ['Resonance-bot'];

  currentPmUser = 'Resonance-bot';

  mutedUsers = (_ref3 = storage.mutedUsers) != null ? _ref3 : [];

  currentNick = (_ref4 = storage.nick) != null ? _ref4 : 'Resonance-dev';

  client = new irc.Client('chat.freenode.net', currentNick, {
    debug: false
  });

  client.addListener('error', function(message) {
    emitToAllWorkers('error', message.command + message.args.join(' '));
    return console.error('ERROR:', message.command, message.args.join(' '));
  });

  client.addListener('message', function(from, to, message) {
    var _base;
    if (to !== currentNick) {
      channelsToWorkers[to].port.emit('message', from, to, message);
      if ((_base = storage.messagesHistory)[to] == null) _base[to] = [];
      return storage.messagesHistory[to].push({
        'author': from,
        'message': message
      });
    }
  });

  client.addListener('pm', function(from, message) {
    var _base;
    if (from === 'Resonance-bot' && message.match(/^announce /)) {
      message = message.replace('announce ', '');
      return emitToAllWorkers('announce', message);
    } else if (from === 'Resonance-bot' && message.match(/^topPages /)) {
      message = message.replace('topPages ', '');
      return emitToAllWorkers('topPages', message);
    } else {
      if (!(__indexOf.call(pmUsers, from) >= 0)) {
        pmUsers.push(from);
        emitToAllWorkers('pmUsers', pmUsers);
      }
      if ((_base = storage.privateMessagesHistory)[from] == null) _base[from] = [];
      storage.privateMessagesHistory[from].push({
        'author': from,
        'message': message
      });
      if (from === currentPmUser) {
        return emitToAllWorkers('privateMessage', from, currentNick, message);
      }
    }
  });

  client.addListener('part', function(chan, nick) {
    if (nick !== currentNick) {
      return channelsToWorkers[chan].port.emit('part', chan, nick);
    }
  });

  passEvent = function(eventName) {
    return client.addListener(eventName, function(chan, a, b, c, d, e, f, g, h, i) {
      if (channelsToWorkers[chan] != null) {
        return channelsToWorkers[chan].port.emit(eventName, chan, a, b, c, d, e, f, g, h, i);
      }
    });
  };

  passEvent('names');

  passEvent('join');

  emitToAllWorkers = function(eventName, a, b, c, d, e, f, g, h, i) {
    var chan, worker, _results;
    _results = [];
    for (chan in channelsToWorkers) {
      if (!__hasProp.call(channelsToWorkers, chan)) continue;
      worker = channelsToWorkers[chan];
      _results.push(worker.port.emit(eventName, a, b, c, d, e, f, g, h, i));
    }
    return _results;
  };

  tabToPreviousPage = [];

  channelsToWorkers = {};

  tabs.on('ready', function(tab) {
    var currentTab, i, worker, _base, _ref5, _ref6;
    currentTab = -1;
    i = 0;
    while (i < tabs.length) {
      if (tab === tabs[i]) currentTab = i;
      i++;
    }
    if (tabToPreviousPage[currentTab] != null) {
      client.part(tabToPreviousPage[currentTab].chan);
      delete channelsToWorkers[tabToPreviousPage[currentTab].chan];
    }
    chan = '#' + sha1(tab.url.host + tab.title).toString();
    if (chan === '#84642551eb26c07c7895b86e3fb0b7d70fd6ff97') {
      console.log('########################################################\n error ?');
    }
    console.log(tab.url);
    console.log(tab.title);
    client.join(chan);
    client.say('Resonance-bot', 'enter ' + tab.url + ' ' + chan);
    tabToPreviousPage[currentTab] = {
      'url': tab.url,
      'chan': chan
    };
    worker = tab.attach({
      contentScriptFile: [data.url("lib/jquery.js"), data.url("lib/angular.min.js"), data.url("content-built.js"), data.url("controllers/app.js"), data.url("controllers/ResonanceController.js"), data.url("controllers/IrcController.js"), data.url("controllers/MessagesController.js"), data.url("controllers/UsersController.js"), data.url("controllers/TopPagesController.js"), data.url("controllers/SettingsController.js"), data.url("controllers/PrivateMessagesController.js"), data.url("controllers/PrivateUsersController.js")]
    });
    channelsToWorkers[chan] = worker;
    worker.port.emit('appSize', (_ref5 = storage.appSize) != null ? _ref5 : '100');
    worker.port.emit('chan', chan);
    worker.port.emit('requestMutedUsers', mutedUsers);
    worker.port.emit('nick', currentNick);
    worker.port.emit('messagesHistory', (_ref6 = storage.messagesHistory[chan]) != null ? _ref6 : []);
    worker.port.emit('pmUsers', pmUsers);
    if ((_base = storage.privateMessagesHistory)[currentPmUser] == null) {
      _base[currentPmUser] = [];
    }
    worker.port.emit('pmUser', currentPmUser, storage.privateMessagesHistory[currentPmUser]);
    worker.port.on('say', function(to, message) {
      var _base2;
      client.say(to, message);
      worker.port.emit('message', currentNick, to, message);
      if ((_base2 = storage.messagesHistory)[to] == null) _base2[to] = [];
      return storage.messagesHistory[to].push({
        'author': currentNick,
        'message': message
      });
    });
    worker.port.on('privateMessage', function(user, message) {
      var _base2;
      client.say(user, message);
      if ((_base2 = storage.privateMessagesHistory)[user] == null) {
        _base2[user] = [];
      }
      storage.privateMessagesHistory[user].push({
        'author': currentNick,
        'message': message
      });
      return emitToAllWorkers('privateMessage', currentNick, user, message);
    });
    worker.port.on('getTopPages', function(domain) {
      if (domain !== null && domain !== '') {
        return client.say('Resonance-bot', 'ask keyword ' + domain);
      } else {
        return client.say('Resonance-bot', 'ask global');
      }
    });
    worker.port.on('startPmUser', function(user) {
      var _base2;
      currentPmUser = user;
      if (!(__indexOf.call(pmUsers, user) >= 0)) {
        pmUsers.push(user);
        emitToAllWorkers('pmUsers', pmUsers);
      }
      if ((_base2 = storage.privateMessagesHistory)[user] == null) {
        _base2[user] = [];
      }
      return emitToAllWorkers('pmUser', currentPmUser, storage.privateMessagesHistory[user]);
    });
    worker.port.on("newNick", function(nick) {
      storage.nick = nick;
      currentNick = nick;
      return worker.port.emit('message', 'Resonance', currentNick, 'Your new nick will be saved and available as soon as you restart firefox.');
    });
    worker.port.on("updateMutedUsers", function(mutedUsers) {
      return storage.mutedUsers = mutedUsers;
    });
    return worker.port.on("newAppSize", function(height) {
      return storage.appSize = height;
    });
  });

  tabs.on('close', function(tab) {
    chan = '#' + sha1(tab.url.host + tab.title).toString();
    client.part(chan);
    delete tabToPreviousPage[tab];
    return delete channelsToWorkers[chan];
  });

}).call(this);
