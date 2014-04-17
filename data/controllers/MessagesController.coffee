
window.app.controller "MessagesController", ($scope) ->
    # List of every messages that has been sent or received in the current channel (page).
    $scope.messages = []
    $scope.newMessage = ''

    # Get the histor from the background.
    self.port.on "messagesHistory", (messagesHistory) ->
        $scope.messages = ({ 'author':message.author, 'message':message.message, 'display':not(message.author in $scope.$parent.mutedUser)} for message in messagesHistory)

    # Select the DOM element for messages.
    elmt = angular.element('messages > ul') 
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
            'display' : not ( from in $scope.$parent.mutedUser )

        # Append it to the list of all messages.
        $scope.messages.push(entry)
        # Update the view.
        $scope.$apply()
        # Scroll down the view.
        elmt.animate({ scrollTop: elmt.prop('scrollHeight')}, 1000)
    # Undisplay the messages of the muted user
    $scope.$parent.$on "mute", (e,user) ->
        for message in $scope.messages
            if message.author == user
                message.display = false
        elmt.animate({ scrollTop: elmt.prop('scrollHeight')}, 1000)
        
    # Display the messages of the muted user
    $scope.$parent.$on "unMute", (e,user) ->
        for message in $scope.messages
            if message.author == user
                message.display = true
        elmt.animate({ scrollTop: elmt.prop('scrollHeight')}, 1000)