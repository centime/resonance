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
        angular.element('#resonance_container').height height

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
            angular.element('#resonance_container').height newHeight
            # Tell the background script so it can save the value.
            self.port.emit('newAppSize',newHeight)
