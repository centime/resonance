
var emit = addon.port.emit;
var on = addon.port.on;


var messagesListArea = document.getElementById('messages-list');
var newMessageArea = document.getElementById('new-message');  
var usersListArea = document.getElementById('users-list');

var chans = {};
var currentChan = '';

newMessageArea.onkeyup = function(event) {
    if (event.keyCode == 13) {
      text = newMessageArea.value.replace(/(\r\n|\n|\r)/gm,"");
      emit("say", currentChan, text);
      newMessageArea.value = '';
    }
  };

function showMsg(text){
  var newLi = document.createElement('li');
  newLi.innerHTML = text;
  messagesListArea.appendChild(newLi);
}

function showUser(nick){
    var newLi = document.createElement('li');
    newLi.innerHTML = nick;
    usersListArea.appendChild(newLi);
}

on("open", function (chan) {
  newMessageArea.focus();

  messagesListArea.innerHTML = '';
  usersListArea.innerHTML = '';
  
  currentChan = chan ;

  if (chans[chan] !== undefined) {
    for (var i=0;i<chans[chan].history.length;i++){
      showMsg(chans[chan].history[i]);
    };
    //scroll down
    messagesListArea.scrollTop = messagesListArea.scrollHeight;
    for (i=0;i<chans[chan].users.length;i++)
      showUser(chans[chan].users[i]);

  }else{
    emit('join',chan);
    chans[chan] = {'history':[], 'users':[]};
  }

});

on("message", function (from,to,message) {
  var text = from+' : '+message;
  showMsg(text);
  chans[currentChan].history.push(text)
  //scroll down
  messagesListArea.scrollTop = messagesListArea.scrollHeight;
});

on("names", function (channel,nicks) {
  for (nick in nicks){
      showUser(nick);
      chans[currentChan].users.push(nick)
  }
});
