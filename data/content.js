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
</style>\
";

document.getElementById("resonance_container").innerHTML = content ;