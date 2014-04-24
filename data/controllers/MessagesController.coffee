
window.app.controller "MessagesController", ($scope) ->
    # List of every messages that has been sent or received in the current channel (page).
    $scope.messages = []
    $scope.newMessage = ''
    $scope.currentnick = ''
    # Get the histor from the background.
    self.port.on "messagesHistory", (messagesHistory) ->
        $scope.messages = ({ 'author':message.author, 'message':message.message, 'old':message.old, 'display':not(message.author in $scope.$parent.mutedUsers)} for message in messagesHistory)
        scrollDown()

    self.port.on "nick", (currentnick) ->
        $scope.currentnick=currentnick
        scrollDown()

    # Send a new message.
    $scope.submitNewMessage =  () ->
                            msg = $scope.newMessage 
                            # Tell the background script to 'say' 'msg' on channel 'IRC.chan'
                            if (msg != '')
                                self.port.emit('say',IRC.chan, msg)
                            # Clear the input.
                            $scope.newMessage = ''

    # Listen for a 'message' event.
    self.port.on "message", (from,to,message) ->
        # The line will be 'User : Message'.
        entry = 
            'author' : from
            'message' : message
            'display' : not ( from in $scope.$parent.mutedUsers )

        # Append it to the list of all messages.
        $scope.messages.push(entry)
        # Update the view.
        $scope.$apply()
        scrollDown()
        
    # Set the css class for old messages (history).
    $scope.class = (message) ->
        classes = {'old_message_resonance': message.old}
        wordsInMessage = message.message.split(new RegExp(' |:','g'))
        if message.author == $scope.currentnick
            classes['authorIsMe_resonance'] = true
        else if $scope.currentnick in wordsInMessage
            classes['authorToMe_resonance'] = true
        return classes

    # Undisplay the messages of the muted user
    $scope.$parent.$on "mute", (e,user) ->
        for message in $scope.messages
            if message.author == user
                message.display = false
        scrollDown()
        
    # Display the messages of the muted user
    $scope.$parent.$on "unMute", (e,user) ->
        for message in $scope.messages
            if message.author == user
                message.display = true

    # Scroll down the messages list.
    elmt = angular.element('messages_resonance > ul') 
    scrollDown = ()  ->
        elmt.animate({ scrollTop: elmt.prop('scrollHeight')}, 1000)

