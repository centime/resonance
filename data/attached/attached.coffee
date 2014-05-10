window.attached = angular.module('attached',[])

window.attached.controller 'AttachedController', ($scope) ->
    $scope.pages = []

    self.port.on 'pages', (pages) ->
        $scope.pages = pages
        $scope.$apply()

    $scope.detach = (page) ->
        self.port.emit('detach',page)