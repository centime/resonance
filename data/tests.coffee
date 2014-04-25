self.port.on 'test',(msg,param) ->
    if msg == 'Test port communication'
        self.port.emit('test',msg+' : '+document.title)

    if msg == 'App displayed, ~full ?'
        displayed = $('#resonance_container')?
        fullSize = ($('#resonance_container').width() > window.innerWidth*9/10)
        self.port.emit('test',msg+' : '+(displayed and fullSize))
        
    if msg == 'Send message'
        angular.element($('messages')).scope().newMessage = 'coucou'
        angular.element($('messages')).scope().submitNewMessage()

    if msg == 'Are messages in history really displayed ?'
        ok = true
        messages = angular.element($('messages')).scope().messages
        for m in param
            ok_ = false
            for d in messages
                if (d.author == m.author) and (d.message == m.message) and (d.display)
                    ok_ = true
            if not ok_
                ok = false
        self.port.emit('test',msg+' : '+ok)

    if msg == 'Updated pm users list ?'
        pmUsers = angular.element($('privateusers')).scope().pmUsers
        self.port.emit('test',msg+' : '+(param in pmUsers))

            

    # console.log angular.element($('resonance')).scope().display
    # console.log $('resonance').hasClass('flex')