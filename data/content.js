
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
</style>\
";


container.appendTo(document.body);
var initMargin = $('body').css('margin-bottom')
$('body').css('margin-bottom',SIZE)

document.getElementById("resonance_container").innerHTML = content ;

self.port.on('close',function(){
    $('#resonance_container').remove()
    $('body').css('margin-bottom',initMargin)    
});
