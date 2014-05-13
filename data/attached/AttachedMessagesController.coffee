window.attached.controller "AttachedMessagesController", ($scope) ->

    # $scope.page.chan
    msgTest = 
        'author':'test'
        'message':'msgTest'
    $scope.messages = []
    $scope.newMessage = ''

    # Get the histor from the background.
    self.port.on "messagesHistory", (chan, messagesHistory) ->
        if chan == $scope.page.chan
            $scope.messages = messagesHistory
            $scope.$apply()
            #scrollDown(full=true)

    # Send a new message.
    $scope.submitNewMessage =  () ->
                            msg = $scope.newMessage 
                            # Tell the background script to 'say' 'msg' on channel 'IRC.chan'
                            if (msg != '')
                                self.port.emit('message', $scope.page.chan, msg)
                            # Clear the input.
                            $scope.newMessage = ''

    # Listen for a 'message' event.
    self.port.on "message", (from,to,message) ->
        if to == $scope.page.chan
            # The line will be 'User : Message'.
            entry = 
                'author' : from
                'message' : message
            # Append it to the list of all messages.
            $scope.messages.push(entry)
            # Update the view.
            $scope.$apply()
            #scrollDown(full=false)
        
    # # Set the css class for messages.
    # $scope.class = (message) ->
    #     message.marker ?= ''
    #     classes = {'old_message_resonance': message.old}
    #     switch message.marker
    #         when 'resonanceToMe' then classes['resonanceToMe_resonance'] = true
    #         when 'authorIsMe' then classes['authorIsMe_resonance'] = true
    #         when 'authorToMe' then classes['authorToMe_resonance'] = true
    #     return classes
        

    # # Undisplay the messages of the muted user
    # $scope.$parent.$on "mute", (e,user) ->
    #     for message in $scope.messages
    #         if message.author == user
    #             message.display = false
        
    # # Display the messages of the muted user
    # $scope.$parent.$on "unMute", (e,user) ->
    #     for message in $scope.messages
    #         if message.author == user
    #             message.display = true

    # $scope.displayMessages = (displayMessages) ->
    #     angular.element('messages_resonance input').focus()
    #     return displayMessages

    # # Scroll down the messages list.
    # elmt = angular.element('messages_resonance > ul') 
    # scrollDown = (full)  ->
    #     # todo : 1.25 ? it needs proper checks.
    #     if full or ((elmt.prop('scrollHeight')-elmt.prop('scrollTop'))/parseInt(elmt.css('height')) < 1.25)
    #         elmt.animate({ scrollTop: elmt.prop('scrollHeight')}, 1000)

