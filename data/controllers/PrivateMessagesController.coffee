
window.app.controller "PrivateMessagesController", ($scope) ->
    # List of every messages that has been sent or received in the current channel (page).
    $scope.messages = []
    $scope.newMessage = ''
    # Select the DOM element for messages.
    elmt = angular.element('privatemessages > ul') 
    # Send a new message.
    $scope.submitNewMessage =  () ->
                            msg = $scope.newMessage 
                            # Tell the background script to 'say' 'msg' on channel 'IRC.chan'
                            if (msg != '')
                                self.port.emit('pm','Resonance-bot', msg)
                            # Clear the input.
                            $scope.newMessage = ''

    # Listen for a 'message' event.
    self.port.on "pm", (from,message) ->
        # The line will be 'User : Message'.
        text = from+' : '+message
        # Append it to the list of all messages.
        $scope.messages.push(text)
        # Update the view.
        $scope.$apply()
        # Scroll down the view.
        elmt.animate({ scrollTop: elmt.prop('scrollHeight')}, 1000)
