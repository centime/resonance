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
/* Just run the build.sh script.
/***************************************************************************/
var content = "\
<style>\
messages > ul {background: blue}\
controls {background: red}\
users {background: green}\
settings {background: yellow}\
topPages {background: purple}\
\
resonance {\
    height: 100% ;\
    width: 100% ;\
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
}\
messages > form {\
    flex: 1 6 20%;\
    order: 2;\
}\
messages input {\
    width: 100% ;\
    height: 100% ;\
}\
controls{\
    flex: 1 6 30px;\
    order: 1;\
}\
users{\
    flex: 1 6 80%;\
    order: 2;\
}\
.list{\
    overflow: auto;\
}\
\
</style>\
<resonance ng-app='resonance' ng-controller='ResonanceController' class='flex row'>\
    <div id='resonance_left'>\
        <messages ng-controller='MessagesController' ng-show='display==1' class='flex column'>\
            <ul class='list'>\
                <li ng-repeat='message in messages track by $index'>\
                      {{message}}\
                </li>\
            </ul>\
            <form ng-submit='submitNewMessage()'>\
                <input type='text' ng-model='newMessage'/>\
            </form>\
        </messages>\
        <topPages ng-controller='TopPagesController' ng-show='getTopPages(display==2)' class='flex'>\
            <form ng-submit='getTopPages(display==2)'>\
                <input type='radio' ng-model='typeSearch' value='dom'/>Recherche par domaine<br>\
                <input type='radio' ng-model='typeSearch' value='key'/>Recherche par mot clé<br>\
                <input type='text' ng-model='domain'/>\
            </form>\
            <ul class='list'>\
                <li ng-repeat='page in topPages track by $index'>\
                      {{page[1]}}:{{page[0]}}\
                </li>\
            </ul>\
        </topPages>\
        <settings ng-controller='SettingsController' ng-show='display==3' class='flex'>\
            <form >\
                <input type='text' ng-model='newNick'></input>\
                <br>\
                <button ng-click='saveSettings();$parent.display=1'>save</button>\
            </form>\
       </settings>\
\
    </div>\
    <div id='resonance_right' class='flex column'>\
        <controls>\
            <button ng-click='display=(display==2)?1:2'>top pages</button>\
            <button ng-click='display=(display==3)?1:3'>settings</button>\
        </controls>\
        <users ng-controller='UsersController'>\
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

document.getElementById("resonance_container").innerHTML = content ;