window.app.controller 'PrivateUsersController', ($scope)->
    # List of every present user.

    $scope.selectPmUser = (user) ->
        $scope.$parent.currentPmUser = user
        $scope.$parent.$broadcast('pmUser',user)
