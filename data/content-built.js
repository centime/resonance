
var SIZE = '100px';

var container = $(document.createElement('div')).attr({
    id: 'resonance_container',
}).css({
    position: 'fixed',
    bottom: '0px',
    height: SIZE,
    width: '100%',
    background: 'white',
    'z-index': '9999999999999999999999999999999999999999999999',
})

/***************************************************************************/
/* The following will get generated from :
/*          resonance.html
/*          resonance.css
/* Just run the concat.py script.
/***************************************************************************/
var content = "\
<style>\
/* Main layout */\
#resonance_container {\
    /* See content.js for all the css of #resonance_container */\
    left:0px;\
}\
resonance_resonance {\
    height: 100% ;\
    width: 100% ;\
    color: black;\
}\
resonance_resonance * {\
    border : 0px;\
    padding : 0px;\
    margin : 0px;\
}\
/* Various properties */\
    .flex_resonance {\
        display: flex;\
    }\
    .row_resonance {\
        flex-direction: row;\
    }\
    .column_resonance {\
        flex-flow: column;\
        flex-direction: column;\
    }\
    .list_resonance{\
        overflow: auto;\
        height: 100%;\
    }\
    .bordered_resonance{\
        border:3px solid gray;\
        background-color: #DAE5E6 ;\
    }\
\
/* Main elements / panels layout */\
#border_resonance {\
    flex: 1 6 5px;\
    order: 1;\
    background: gray ;\
    cursor: n-resize;\
}\
#main_resonance {\
    flex: 1 6 100%;\
    order: 2;\
    width: 100%;\
}\
#left_resonance {\
    flex: 1 6 80%;\
    order: 1;\
}\
#right_resonance {\
    flex: 1 6 20%;\
    order: 2;\
}\
\
/* Left panel elements */\
#left_resonance > * {\
    height: 100% ;\
}\
\
/* Messages & private messages */\
    messages_resonance > ul {\
        flex: 1 6 80%;\
        order: 1;\
        color: #000000;\
    }\
    messages_resonance > form {\
        flex: 1 6 20%;\
        order: 2;\
        max-height: 30px ;\
    }\
    messages_resonance input {\
        width: 100% ;\
        height: 100% ;\
    }\
    privatemessages_resonance > ul {\
        flex: 1 6 80%;\
        order: 1;\
    }\
    privatemessages_resonance > form {\
        flex: 1 6 20%;\
        order: 2;\
        max-height: 30px ;\
    }\
    privatemessages_resonance input {\
        width: 100% ;\
        height: 100% ;\
    }\
/* TopPages */\
    toppages_resonance > div {\
        height: 30px;\
        width: 100%;\
    }\
    toppages_resonance > ul {\
        height: 100%;\
        width: 100%;\
    }\
    toppages_resonance form {\
        flex: 1 6 80%;\
        order: 0;\
    }\
    toppages_resonance input {\
        height: 100%;\
        width: 99.8%;\
    }\
    toppages_resonance button {\
        flex: 1 6 10%;\
        height: 100%;\
        min-width: 30px;\
    }\
    toppages_resonance div {\
        min-width: 30px;\
    }\
    toppages_resonance li {\
        white-space: nowrap;\
        overflow: hidden;\
        text-overflow: ellipsis;\
    }\
\
/* Right panel elements */\
#right_resonance > * {\
    height: 100%;\
    width: 100%;\
    display: flex ;\
}\
/* Controls */\
    #right_resonance > controls_resonance{\
        height: 30px;\
    }\
    controls_resonance > button {\
        height: 100%;\
        min-width: 30px;\
        margin-right: 2px;\
    }\
/* Users & private users */\
    #right_resonance ul{\
        width: 100%;\
    }\
    #right_resonance li{\
        border-bottom: 1px solid;\
        border-bottom-color: gray;\
    }\
\
\
/* Colors & co */\
\
/* Private message notification */\
    .selected_resonance {\
        background: white;\
    }\
    /* Blink */\
    @keyframes blink_resonance { 50% { background-color: gray; } }\
    .active_resonance{\
        animation: blink_resonance .5s step-end infinite alternate;\
    }\
/* Messages colors */\
    .old_message_resonance {\
        color : gray;\
    }\
    .authorIsMe_resonance{\
        font-weight: 600;\
    }\
    .authorToMe_resonance{\
        text-decoration : underline;\
    }\
</style>\
<resonance_resonance ng-app='resonance' ng-controller='ResonanceController' class='flex_resonance column_resonance'>\
    <div id='border_resonance' ng-click='resizing = !resizing'></div>\
    <div id='main_resonance' class='flex_resonance row_resonance'>\
        <div id='left_resonance' class='bordered_resonance'>\
            <messages_resonance ng-controller='MessagesController' ng-show='displayMessages(display==1)' class='flex_resonance column_resonance'>\
                <ul class='list_resonance'>\
                    <li ng-repeat='message in messages track by $index' ng-if='message.display' ng-class='class(message)'>\
                          {{message.author}}: {{message.message}}\
                    </li>\
                </ul>\
                <form ng-submit='submitNewMessage()'>\
                    <input type='text' ng-model='newMessage' autofocus/>\
                </form>\
            </messages_resonance>\
            <toppages_resonance ng-controller='TopPagesController' ng-show='displayTopPages(display==2)'>\
                <div class='flex_resonance row_resonance'>\
                    <form ng-submit='getTopPages()'>\
                        <input type='text' ng-model='query'/>\
                    </form>\
                    <button ng-click='previous()'>&lt</button>\
                    <div>{{index+1}}/{{total}}</div>\
                    <button ng-click='next()'>&gt</button>\
                </div>\
                <ul class='list_resonance'>\
                    <li ng-repeat='page in topPages track by $index'>\
                        <span>{{page[1]}} </span>\
                        <a href={{page[0]}} target='_newtab'>{{page[0]}}</a>\
                    </li>\
                </ul>\
            </toppages_resonance>\
           <privatemessages_resonance ng-controller='PrivateMessagesController' ng-show='displayPrivateMessage(display==4)' class='flex_resonance column_resonance'>\
                <ul class='list_resonance'>\
                    <li ng-repeat='message in messages track by $index' ng-class='oldMessage(message)'>\
                          {{message.author}}: {{message.message}}\
                    </li>\
                </ul>\
                <form ng-submit='submitNewMessage()'>\
                    <input type='text' ng-model='newMessage'/>\
                </form>\
            </privatemessages_resonance>\
            <notifications_resonance ng-controller='NotificationsController' ng-show='display==5' class='flex_resonance column_resonance'>\
                <ul class='list_resonance'>\
                    <li ng-repeat='notification in notifications track by $index' ng-class='class(notification)'>\
                          {{notification.type}}: {{notification.message}}\
                    </li>\
                </ul>\
            </notifications_resonance>\
            <follow_resonance ng-controller='FollowController' ng-show='display==6' class='flex_resonance column_resonance'>\
            </follow_resonance>\
        </div>\
        <div id='right_resonance'>\
            <controls_resonance class='bordered_resonance'>\
                <button ng-click='display=(display==2)?1:2'  >TopPages</button>\
                <button ng-click='display=(display==4)?1:4' ng-class='active()'>PrivateMessages</button>\
                <button ng-click='display=(display==5)?1:5'>Notifications</button>\
                <button ng-click='display=(display==6)?1:6'>Follow</button>\
            </controls_resonance>\
            <users_resonance ng-controller='UsersController' ng-show='display<3' class='bordered_resonance'>\
                <ul class='list_resonance'>\
                    <li ng-repeat='user in users track by $index'>\
                        <div ng-click='displayActions[user]=!displayActions[user]'>{{user}}</div>\
                        <actions ng-show='displayActions[user]'>\
                            <button ng-click='mute(user)' ng-hide='isMute(user)'>mute</button>\
                            <button ng-click='unMute(user)' ng-hide='!isMute(user)'>unMute</button>\
                            <button ng-click='startPm(user)' ng-hide='isClient(user)'>private message</button>\
                        </actions>\
                    </li>\
                </ul>\
            </users_resonance>\
            <privateusers_resonance ng-controller='PrivateUsersController' ng-show='display==4' class='bordered_resonance'>\
                <ul class='list_resonance'>\
                    <li ng-repeat='user in pmUsers track by $index'>\
                        <div ng-click='selectPmUser(user)' ng-class='class(user)'>{{user}}</div>\
                    </li>\
                </ul>\
            </privateusers_resonance>\
            <announce_resonance ng-controller='NotificationsController' ng-show='display==5' class='bordered_resonance list_resonance'>\
                {{announce}}\
            </announce_resonance>\
        </div>\
    </div>\
</resonance_resonance>\
\
";


container.appendTo(document.body);
var initMargin = $('body').css('margin-bottom')
$('body').css('margin-bottom',SIZE)

document.getElementById("resonance_container").innerHTML = content ;

self.port.on('close',function(){
    $('#resonance_container').remove()
    $('body').css('margin-bottom',initMargin)    
});
