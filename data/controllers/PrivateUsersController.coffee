window.app.controller 'PrivateUsersController', ($scope)->
    # List of every present user.
    $scope.users = ['Resonance-bot','Centime']

    $scope.selectPmUser = (user) ->
        $scope.$parent.currentPmUser = user
        $scope.$parent.$broadcast('pmUser',user)
