var SIZE = '100px';

var container = $(document.createElement('div')).attr({
    id: 'resonance_container',
}).css({
    position: 'fixed',
    bottom: '0px',
    height: SIZE,
    width: '100%',
    background: 'white',
    'z-index': '9999999999999999999999999999999999999999999999' //tofix
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


if ($('#resonance_container').length === 0){
    container.appendTo(document.body);
    var initMargin = $('body').css('margin-bottom')
    $('body').css('margin-bottom',SIZE)

    self.port.on('display',function(cmd){
        if (cmd === 'hide'){
            $('#resonance_container').hide()
            $('body').css('margin-bottom',initMargin)    
        }else if (cmd === 'show'){
            // todo : Will it ever be used ?
            $('#resonance_container').show()
            $('body').css('margin-bottom',SIZE)
        }
    });
    document.getElementById("resonance_container").innerHTML = content ;
}else{
            $('#resonance_container').show()
            $('body').css('margin-bottom',SIZE)
}