window.resonance.controller "ResonanceController", ($scope) ->
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
    $scope.private_active_or_selected = () ->
        {'active_resonance':$scope.privateActive, 'selected_resonance':($scope.display==4)}
    
    $scope.nocitificationActive = false
    self.port.on 'notificationActive', (bool) ->
        $scope.notificationActive = bool
        $scope.$apply()
    $scope.notification_active = () ->
        {'active_resonance':$scope.notificationActive, 'selected_resonance':($scope.display==5)}

    $scope.isAttached = false
    $scope.attach = () ->
        $scope.isAttached = not $scope.isAttached
        if $scope.isAttached
            self.port.emit('attach', document.URL, document.title)
        else
            self.port.emit('detach', IRC.chan)
    
    self.port.on 'attached', () ->
        $scope.isAttached = true

    self.port.on 'detached', () ->
        $scope.isAttached = false
        $scope.$apply()

    $scope.attached = () ->
        { 'selected_resonance':$scope.isAttached }

    $scope.selected = (display) ->
        { 'selected_resonance':($scope.display==display) }

    # Hack for the ng-model binding of topPages
    $scope.TP = {}


    # The logo url
    $scope.logoUrl = self.options.testUrl