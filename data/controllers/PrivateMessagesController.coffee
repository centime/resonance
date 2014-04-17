window.app.controller "PrivateMessagesController", ($scope) ->
    # List of every messages that has been sent or received in the current channel (page).
    $scope.messages = []
    $scope.newMessage = ''
    currentPmUser = 'Resonance-bot'
    #self.port.emit('requestPrivateMessagesHistory',currentPmUser)

    self.port.on "pmUser", (user, history) ->
        currentPmUser = user
        $scope.messages = history
    
    # Select the DOM element for messages.
    elmt = angular.element('privatemessages > ul') 
    # Send a new message.
    $scope.submitNewMessage =  () ->
                            msg = $scope.newMessage 
                            # Tell the background script to 'say' 'msg' on channel 'IRC.chan'
                            if (msg != '')
                                self.port.emit('privateMessage', currentPmUser, msg)
                            # Clear the input.
                            $scope.newMessage = ''

    # Listen for a 'pm' event : when the client receives or sends a pm.
    self.port.on "privateMessage", (from,to,message) ->
        # create the new entry for the message
        entry = 
            'author' : from
            'message' : message
        # Append it to the list of all messages.
        $scope.messages.push(entry)
        # Update the view.
        $scope.$apply()
        # Scroll down the view.
        elmt.animate({ scrollTop: elmt.prop('scrollHeight')}, 1000)

    # Set the css class for old messages (history).
    $scope.oldMessage = (message) ->
        {'old_message': message.old}

    # Catch errors.
    self.port.on 'error', (error) ->
        # Append it to the list of all messages.
        # todo : what if a user is called Error ?
        $scope.messages.push({'author':'Error','message':error})
        # Update the view.
        $scope.$apply()
