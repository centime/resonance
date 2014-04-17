window.app.controller 'PrivateUsersController', ($scope)->
    # List of every present user.
    $scope.currentPmUser = 'Resonance-bot'
    $scope.pmUsers = []

    $scope.selectPmUser = (user) ->
        self.port.emit( 'startPmUser', user)
        
    self.port.on "pmUser", (user, history) ->
        $scope.currentPmUser = user
        # Update the notifications
        $scope.privateUsersActive[user] = false
        $scope.$parent.privateActive = false
        for user, active of $scope.privateUsersActive
            if active
                $scope.$parent.privateActive = true
        
        $scope.$apply()
    
    self.port.on "pmUsers", (users) ->
        $scope.pmUsers = users
        $scope.$apply()

    # Set the css class
    $scope.class = (user)->
        { 'selected': user == $scope.currentPmUser, 'active':$scope.privateUsersActive[user]}

    # Raise the notification when a new private message is waiting.
    $scope.privateUsersActive = {}
    self.port.on 'newPM', (user) ->
        $scope.$parent.privateActive = true
        $scope.$parent.$apply()
        $scope.privateUsersActive[user] = true