window.app.controller "ResonanceController", ($scope) ->
    # Indicates which element of the application has to be displayed.
    # 1 for messages.
    # 2 for features.
    # 3 fot settings.
    # Initialized with messages.
    $scope.display = 1

    # Updates the list of muted users when received from the background script.
    $scope.mutedUsers = []

    self.port.on 'requestMutedUsers',(n) ->
        $scope.mutedUsers = n        

    self.port.on 'appSize',(height) ->
        # Set the size of the app.
        angular.element('#resonance_container').height(height)
        angular.element('body').css('margin-bottom',height)

    # Resizing feature.
    $scope.resizing = false
    # This event is binded to body, but I can"t find the way to unbind it !
    # .off raises an angularjs error, and this resizing var is the only workaround I found.
    # WARNING todo : performance cost of a test on mousemove ?
    angular.element('body').on 'mousemove', (e) ->
        # If the user is currentl resizing.
        if $scope.resizing
            # Get the desired height from where is the mouse on the screen.
            newHeight = window.innerHeight-e.clientY
            # Update the DOM element.
            angular.element('#resonance_container').height(newHeight)
            angular.element('body').css('margin-bottom',newHeight)
            # Tell the background script so it can save the value.
            self.port.emit('newAppSize',newHeight)

    # Notification when a private message has been received and not yet been readen.
    $scope.privateActive = false
    self.port.on 'activePrivateUsers', (users) ->
        $scope.privateActive = ( true in ( active for user, active of users ))
        $scope.$apply()
    $scope.active = () ->
        {'active_resonance':$scope.privateActive}


    # Catch errors.
    self.port.on 'error', (error) ->
        # Append it to the list of all messages.
        # todo : what if a user is called Error ?
        console.log('IRC error : '+error)
