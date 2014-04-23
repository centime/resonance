var SIZE = '100px';

var app = $(document.createElement('div')).attr({
    id: 'resonance_container',
}).css({
    position: 'fixed',
    bottom: '0px',
    height: SIZE,
    width: '100%',
    background: 'white',
    'z-index': '9999999999999999999999999999999999999999999999' //tofix
})
.appendTo(document.body);

$('body').css('margin-bottom',SIZE)

/***************************************************************************/
/* The following will get generated from :
/*          resonance.html
/*          resonance.css
/* Just run the concat.py script.
/***************************************************************************/
var content = "\
<style>\
resonance {\
    height: 100% ;\
    width: 100% ;\
    background-color: \
}\
resonance * {\
    border : 0px;\
    padding : 0px;\
    margin : 0px;\
}\
.flex {\
    display: flex;\
}\
.row {\
    flex-direction: row;\
}\
.column {\
    flex-flow: column;\
    flex-direction: column;\
}\
.bordered{\
    border:3px solid gray;\
    background-color: #DAE5E6 ;\
}\
.border_gradient {\
    border: 5px solid #000;\
    -moz-border-bottom-colors:#897048 #917953 #a18a66 #b6a488 #c5b59b #d4c5ae #e2d6c4 #eae1d2;\
    -moz-border-top-colors:  #897048 #917953 #a18a66 #b6a488 #c5b59b #d4c5ae #e2d6c4 #eae1d2;\
    -moz-border-left-colors: #897048 #917953 #a18a66 #b6a488 #c5b59b #d4c5ae #e2d6c4 #eae1d2;\
    -moz-border-right-colors:#897048 #917953 #a18a66 #b6a488 #c5b59b #d4c5ae #e2d6c4 #eae1d2;\
}\
.test_box_shadow{\
    -webkit-box-shadow: inset -33px 44px 146px -47px rgba(31,31,31,1);\
    -moz-box-shadow: inset -33px 44px 146px -47px rgba(31,31,31,1);\
    box-shadow: inset -33px 44px 146px -47px rgba(31,31,31,1);\
}\
#border {\
    flex: 1 6 5px;\
    order: 1;\
    background: gray ;\
    cursor: n-resize;\
}\
#main {\
    flex: 1 6 100%;\
    order: 2;\
    width: 100%;\
}\
#resonance_left {\
    flex: 1 6 80%;\
    order: 1;\
}\
#resonance_right {\
    flex: 1 6 20%;\
    order: 2;\
}\
#resonance_left > * {\
    height: 100% ;\
}\
messages > ul {\
    flex: 1 6 80%;\
    order: 1;\
    color: #000000;\
}\
messages > form {\
    flex: 1 6 20%;\
    order: 2;\
    max-height: 30px ;\
}\
messages input {\
    width: 100% ;\
    height: 100% ;\
}\
controls{\
    flex: 1 6 30px;\
    order: 1;\
}\
controls > button {\
    height: 100%;\
    min-width: 30px;\
}\
users{\
    flex: 1 6 80%;\
    order: 2;\
}\
users li{\
    border-bottom: 1px solid;\
    border-bottom-color: gray;\
}\
privatemessages > ul {\
    flex: 1 6 80%;\
    order: 1;\
}\
privatemessages > form {\
    flex: 1 6 20%;\
    order: 2;\
    max-height: 30px ;\
}\
privatemessages input {\
    width: 100% ;\
    height: 100% ;\
}\
privateusers{\
    flex: 1 6 80%;\
    order: 3;\
}\
privateusers li{\
    border-bottom: 1px solid;\
    border-bottom-color: gray;\
}\
.list{\
    overflow: auto;\
    height: 100%;\
}\
.selected {\
    background: white; \
}\
.old_message {\
    color : gray;\
}\
/* Blink */\
@keyframes blink { 50% { background-color: gray; }  }\
.active{\
    animation: blink .5s step-end infinite alternate; \
}\
.authorIsMe{\
    font-weight: 600;\
}\
.authorToMe{\
    text-decoration : underline;\
}\
toppages > form {\
    flex: 1 6 15%;\
    order: 1;\
}\
toppages > ul {\
    flex: 1 6 85%;\
    order: 2;\
}\
toppages input {\
    height: 100%;\
    width: 91.8%;\
}\
toppages button {\
    height: 100%;\
    min-width: 30px;\
}\
\
</style>\
<resonance ng-app='resonance' ng-controller='ResonanceController' class='flex column'>\
    <div id='border' ng-click='resizing = !resizing'></div>\
    <div id='main' class='flex row'>\
        <div id='resonance_left' class='bordered'>\
            <messages ng-controller='MessagesController' ng-show='display==1' class='flex column'>\
                <ul class='list'>\
                    <li ng-repeat='message in messages track by $index' ng-if='message.display' ng-class='class(message)'>\
                          {{message.author}}: {{message.message}}\
                    </li>\
                </ul>\
                <form ng-submit='submitNewMessage()'>\
                    <input type='text' ng-model='newMessage'/>\
                </form>\
            </messages>\
            <toppages ng-controller='TopPagesController' ng-show='displayTopPages(display==2)' class='flex column'>\
                <form ng-submit='getTopPages()'>\
                    <input type='text' ng-model='regexp'/>\
                    <button>P</button>\
                    <button>N</button>\
                </form>\
                <ul class='list'>\
                    <li ng-repeat='page in topPages track by $index'>\
                          <a href={{page[0]}} target='_newtab'>{{page[1]}}: {{page[0]}}</a>\
                    </li>\
                </ul>\
            </toppages>\
            <settings ng-controller='SettingsController' ng-show='display==3' class='flex'>\
                <form >\
                    <input type='text' ng-model='newNick'></input>\
                    <br>\
                    <button ng-click='saveSettings();$parent.display=1'>Save settings</button>\
                </form>\
           </settings>\
           <privatemessages ng-controller='PrivateMessagesController' ng-show='display==4' class='flex column'>\
                <ul class='list'>\
                    <li ng-repeat='message in messages track by $index' ng-class='oldMessage(message)'>\
                          {{message.author}}: {{message.message}}\
                    </li>\
                </ul>\
                <form ng-submit='submitNewMessage()'>\
                    <input type='text' ng-model='newMessage'/>\
                </form>\
            </privatemessages>\
        </div>\
        <div id='resonance_right' class='flex column'>\
            <controls class='bordered'>\
                <button ng-click='display=(display==2)?1:2'>T</button>\
                <button ng-click='display=(display==4)?1:4' ng-class='active()'>P</button>\
                <button ng-click='display=(display==3)?1:3'>S</button>\
            </controls>\
            <users ng-controller='UsersController' ng-show='display!=4' class='bordered'>\
                <ul class='list'>\
                    <li ng-repeat='user in users track by $index'>\
                        <div ng-click='displayActions[user]=!displayActions[user]'>{{user}}</div>\
                        <actions ng-show='displayActions[user]'>\
                            <button ng-click='mute(user)' ng-hide='isMute(user)'>mute</button>\
                            <button ng-click='unMute(user)' ng-hide='!isMute(user)'>unMute</button>\
                            <button ng-click='startPm(user)' ng-hide='isClient(user)'>private message</button>\
                        </actions>\
                    </li>\
                </ul>\
            </users>\
            <privateusers ng-controller='PrivateUsersController' ng-show='display==4' class='bordered'>\
                <ul class='list'>\
                    <li ng-repeat='user in pmUsers track by $index'>\
                        <div ng-click='selectPmUser(user)' ng-class='class(user)'>{{user}}</div>\
                    </li>\
                </ul>\
            </privateusers>\
        </div>\
    </div>\
</resonance>\
\
";

document.getElementById("resonance_container").innerHTML = content ;