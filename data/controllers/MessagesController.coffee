window.resonance.controller "MessagesController", ($scope) ->
    # List of every messages that has been sent or received in the current channel (page).
    $scope.messages = []
    $scope.newMessage = ''
    $scope.currentnick = ''
    # Get the histor from the background.
    self.port.on "messagesHistory", (messagesHistory) ->
        $scope.messages = messagesHistory
        for message in $scope.messages
            message.display = not(message.author in $scope.$parent.mutedUsers)
        $scope.$apply()
        scrollDown(true)

    self.port.on "nick", (currentnick) ->
        $scope.currentnick=currentnick
        $scope.$apply()

    # Send a new message.
    $scope.submitNewMessage =  () ->
                            msg = $scope.newMessage 
                            # Tell the background script to 'say' 'msg' on channel 'IRC.chan'
                            if (msg != '')
                                self.port.emit('message',IRC.chan, msg)
                            # Clear the input.
                            $scope.newMessage = ''

    # Listen for a 'message' event.
    self.port.on "message", (from,to,message) ->
        # The line will be 'User : Message'.
        entry = 
            'author' : from
            'message' : message
            'display' : not ( from in $scope.$parent.mutedUsers )
            'marker' : 'standart'
        #class of message 
        wordsInMessage = entry.message.split(new RegExp(' |:','g'))
        if entry.author == 'resonance-bot'
            entry.marker = 'resonanceToMe'
        else if entry.author == $scope.currentnick
            entry.marker = 'authorIsMe'
        else if $scope.currentnick in wordsInMessage
            entry.marker = 'authorToMe'
        # Append it to the list of all messages.
        $scope.messages.push(entry)
        # Update the view.
        $scope.$apply()
        scrollDown()
        
    # Set the css class for messages.
    $scope.class = (message) ->
        message.marker ?= ''
        classes = {'old_message_resonance': message.old}
        switch message.marker
            when 'resonanceToMe' then classes['resonanceToMe_resonance'] = true
            when 'authorIsMe' then classes['authorIsMe_resonance'] = true
            when 'authorToMe' then classes['authorToMe_resonance'] = true
        return classes
        

    # Undisplay the messages of the muted user
    $scope.$parent.$on "mute", (e,user) ->
        for message in $scope.messages
            if message.author == user
                message.display = false
        
    # Display the messages of the muted user
    $scope.$parent.$on "unMute", (e,user) ->
        for message in $scope.messages
            if message.author == user
                message.display = true

    $scope.displayMessages = (displayMessages) ->
        angular.element('messages_resonance input').focus()
        return displayMessages
    # Scroll down the messages list.
    elmt = angular.element('messages_resonance > ul') 
    scrollDown = (full)  ->
        console.log (elmt.prop('scrollHeight')-elmt.prop('scrollTop'))/parseInt(elmt.css('height'))
        if full or ((elmt.prop('scrollHeight')-elmt.prop('scrollTop'))/parseInt(elmt.css('height')) < 1.25)
            elmt.animate({ scrollTop: elmt.prop('scrollHeight')}, 1000)

