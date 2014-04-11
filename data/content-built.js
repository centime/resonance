var SIZE = '100px';

var app = $(document.createElement('div')).attr({
    id: 'app',
}).css({
    position: 'fixed',
    bottom: '0px',
    height: SIZE,
    width: '100%',
    background: 'white',
    'z-index': '10000'
})
.appendTo(document.body);

$('body').css('margin-bottom',SIZE)

/***************************************************************************/
/* The following will get generated from :
/*          resonance.html
/*          resonance.css
/* Just run the build.sh script.
/***************************************************************************/
var content = "\
<style>\\
messageslist {background: blue}\
newmessage {background: yellow}\
controls {background: red}\
users {background: green}\
\
.flex\
   {\
      /* flexbox setup */\
      display: -webkit-flex;\
      display: flex;\
   }\
.row\
    {\
        -webkit-flex-direction: row;\
        flex-direction: row;\
    }\
.column\
    {\
    -webkit-flex-flow: column;\
            flex-flow: column;\
            flex-direction: column;\
    }\
#resonance_left {\
    -webkit-flex: 1 6 80%;\
    flex: 1 6 80%;\
    -webkit-order: 1;\
    order: 1;\
}\
#resonance_left > * {\
    height: 100% ;\
}\
#resonance_right {\
    -webkit-flex: 1 6 20%;\
    flex: 1 6 20%;\
    -webkit-order: 2;\
    order: 2;\
}\
controls{\
    -webkit-flex: 1 6 20%;\
    flex: 1 6 20%;\
    -webkit-order: 1;\
    order: 1;\
}\
users{\
    -webkit-flex: 1 6 80%;\
    flex: 1 6 80%;\
    -webkit-order: 2;\
    order: 2;\
}\
messages > ul {\
    -webkit-flex: 1 6 80%;\
    flex: 1 6 80%;\
    -webkit-order: 1;\
    order: 1;\
}\
messages > form {\
    -webkit-flex: 1 6 20%;\
    flex: 1 6 20%;\
    -webkit-order: 2;\
    order: 2;\
}\
</style>\
<resonance ng-app='resonance' class='flex row'>\
    <div id='resonance_left'>\
        <messages ng-controller='MessagesController' class='flex column'>\
            <ul class='list'>\
                <li ng-repeat='message in messages track by $index'>\
                      {{message}}\
                </li>\
            </ul>\
            <form ng-submit='submitNewMessage()'>\
                <input type='text' ng-model='newMessage'/>\
            </form>\
        </messages>\
    </div>\
    <div id='resonance_right' class='flex column'>\
        <controls ng-controller='SettingsController' id='settings'>\
            <form ng-submit='changeNick()'>\
                <input type='text' ng-model='newNick'/>\
            </form>\
        </controls>\
        <users ng-controller='UsersController' id='users'>\
            <ul class='list'>\
                <li ng-repeat='user in users track by $index'>\
                      {{user}}\
                </li>\
            </ul>\
        </users>\
    </div>\
</resonance>\
\
  \
";

document.getElementById("app").innerHTML = content ;