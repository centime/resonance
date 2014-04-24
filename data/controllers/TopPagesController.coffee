window.app.controller "TopPagesController", ($scope) ->
    # List of pages {url : visitors}
    $scope.topPages = []
    $scope.indexTopPages = 10
    self.port.on 'topPages', (topPages)->
        #Pastes the already recieved string with the new part
        $scope.topPages = topPages
        $scope.$apply()
    
    $scope.getTopPages = () ->
        $scope.topPages=[]
        self.port.emit('getTopPages',$scope.domain, $scope.indexTopPages)