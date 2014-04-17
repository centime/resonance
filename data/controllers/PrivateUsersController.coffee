window.app.controller 'PrivateUsersController', ($scope)->
    # List of every present user.
    $scope.currentPmUser = 'Resonance-bot'
    $scope.pmUsers = []

    $scope.selectPmUser = (user) ->
        self.port.emit( 'startPmUser', user)
        
    self.port.on "pmUser", (user, history) ->
        $scope.currentPmUser = user
        $scope.$apply()
    
    self.port.on "pmUsers", (users) ->
        $scope.pmUsers = users
        $scope.$apply()