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
<style>\div, ul, li {\
    border:0px;\
    margin:0px;\
    padding: 0;\
}\
#messages {\
    float: left;\
    width: 80%;\
    height: 100%;\
    background-color: blue;\
}\
#messages .list {\
    height: 70%;\
}\
#messages input {\
    height: 30%;\
    width: 100%;\
}\
#users {\
    float: right;\
    width: 20%;\
    height: 100%;\
    background-color: red;\
\
}\
.list {\
    overflow: auto;\
}\
\
</style>\
<div ng-app='resonance' id='content'>\
    <div ng-controller='MessagesController' id='messages' >\
        <ul class='list'>\
            <li ng-repeat='message in messages track by $index'>\
                  {{message}}\
            </li>\
        </ul>\
        <form ng-submit='submitNewMessage()'>\
            <input type='text' ng-model='newMessage'/>\
        </form>\
    </div>\
    <div ng-controller='SettingsController' id='settings'>\
        <form ng-submit='changeNick()'>\
            <input type='text' ng-model='newNick'/>\
        </form>\
    </div>\
    <div ng-controller='UsersController' id='users'>\
        <ul class='list'>\
            <li ng-repeat='user in users track by $index'>\
                  {{user}}\
            </li>\
        </ul>\
    </div>\
</div>\
";

document.getElementById("app").innerHTML = content ;