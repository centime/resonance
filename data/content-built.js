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
controls > button {\
    height: 100%;\
    min-width: 30px;\
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
<resonance ng-app='resonance' ng-controller='ResonanceController' class='flex column'>\
    <div id='border' ng-mousedown='startResize($event)' ng-mousemove='resize($event)' ng-mouseup='stopResize'></div>\
    <div id='main' class='flex row'>\
        <div id='resonance_left' class='bordered'>\
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
                <ul class='list'>\
                    <li ng-repeat='page in topPages track by $index'>\
                          {{page}}\
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
            <controls class='bordered'>\
                <button ng-click='display=(display==2)?1:2'>T</button>\
                <button ng-click='display=(display==3)?1:3'>S</button>\
            </controls>\
            <users ng-controller='UsersController' class='bordered'>\
                <ul class='list'>\
                    <li ng-repeat='user in users track by $index'>\
                          {{user}}\
                    </li>\
                </ul>\
            </users>\
        </div>\
    </div>\
</resonance>\
\
  \
";

document.getElementById("resonance_container").innerHTML = content ;