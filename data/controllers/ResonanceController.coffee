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
    
