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
<style>\html, body,div,ul {\
    margin: 0;\
    padding: 0;\
    border:0;\
}\
\
#messages {\
    float: left;\
    width: 85%;\
    height: 90%;\
}\
#users-list {\
    float: right;\
    overflow: auto;\
    width: 10%;\
    height: 80%;\
}\
#messages-list {\
    height: 90%;\
    overflow: auto;\
}\
#new-message {\
    width: 100%\
}#app {\
    border:0px;\
    margin:0px;\
}\
li {\
    border-bottom : 1px groove ;\
    margin : 3px;\
}\
button {\
    float : right;\
}\
#new {\
    background-color: #FFFFFF;\
    border: 5px solid;\
    width: 100%;\
}\
</style>\
<div id='content' ng-app='todoApp' ng-controller='MainController'>\
    <ul>\
        <li ng-repeat='todo in todos'>\
              {{todo}}\
            <button ng-click='del(todo)'>X</button>\
        </li>\
    </ul>\
    <br>\
    <form ng-submit='addNew()'>\
        <input id='new' type='text' ng-model='newTodo' />\
    </form>\
</div>\
";

document.getElementById("app").innerHTML = content ;