
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
                                self.port.emit('pm',$scope.$parent.currentPmUser, msg)
                            # Clear the input.
                            $scope.newMessage = ''
                            # Save the new message.
                            entry = 
                                'author' : IRC.nick
                                'discutionWith' : $scope.$parent.currentPmUser
                                'message' : msg
                                'display' : true
                            # Append it to the list of all messages.
                            $scope.messages.push(entry)
                            # Scroll down the view.
                            # WARNING : raises an exception, but works. ?!?
                            # elmt.animate({ scrollTop: elmt.prop('scrollHeight')}, 1000)

    # Listen for a 'pm' event :when the client receives a pm.
    self.port.on "pm", (from,message) ->
        if not ( from in $scope.$parent.pmUsers )
            $scope.$parent.pmUsers.push(from)
        # The line will be 'User : Message'.
        entry = 
            'author' : from
            'discutionWith' : from
            'message' : message
            'display' : (from == $scope.$parent.currentPmUser)
        # Append it to the list of all messages.
        $scope.messages.push(entry)
        # Update the view.
        $scope.$apply()
        # Scroll down the view.
        elmt.animate({ scrollTop: elmt.prop('scrollHeight')}, 1000)


    $scope.$parent.$on "pmUser", (e,user) ->
        for message in $scope.messages
            message.display = ( message.discutionWith == user )
        elmt.animate({ scrollTop: elmt.prop('scrollHeight')}, 1000)