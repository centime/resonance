window.resonance.controller "PrivateMessagesController", ($scope) ->
    # List of every messages that has been sent or received in the current channel (page).
    $scope.messages = []
    $scope.newMessage = ''
    currentPmUser = 'Resonance-bot'

    self.port.on "pmUser", (user, history) ->
        currentPmUser = user
        $scope.messages = history
        $scope.$apply()
        scrollDown(true)
    
    # Send a new message.
    $scope.submitNewMessage =  () ->
                            msg = $scope.newMessage 
                            # Tell the background script to 'say' 'msg' on channel 'IRC.chan'
                            if (msg != '')
                                self.port.emit('privateMessage', currentPmUser, msg)
                            # Clear the input.
                            $scope.newMessage = ''

    # Listen for a 'pm' event : when the client receives or sends a pm.
    self.port.on "privateMessage", (from,message) ->
        # create the new entry for the message
        entry = 
            'author' : from
            'message' : message
        # Append it to the list of all messages.
        $scope.messages.push(entry)
        # Update the view.
        $scope.$apply()
        scrollDown()

    # Set the css class for old messages (history).
    $scope.oldMessage = (message) ->
        {'old_message_resonance': message.old}

    # Scroll down the messages list.
    elmt = angular.element('privatemessages_resonance > ul') 
    scrollDown = (full)  ->
        # todo : 1.25 ? it needs proper checks.
        if full or ((elmt.prop('scrollHeight')-elmt.prop('scrollTop'))/parseInt(elmt.css('height')) < 1.25)
            elmt.animate({ scrollTop: elmt.prop('scrollHeight')}, 1000)
    #focus the input
    $scope.displayPrivateMessage = (displayPrivateMessage) ->
        angular.element('privatemessages_resonance input').focus()
        return(displayPrivateMessage)
