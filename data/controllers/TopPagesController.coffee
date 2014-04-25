window.app.controller "TopPagesController", ($scope) ->
    # List of pages {url : visitors}
    $scope.topPages = []
    $scope.query = ''

    self.port.on 'topPages', (topPages)->
        #Pastes the already recieved string with the new part
        $scope.topPages = topPages
        $scope.$apply()
    $scope.getTopPages = () ->
        self.port.emit('getTopPages',0,$scope.query)
                
    # Execute when TopPages is shown.
    alreadyRequestedTopPage = false
    $scope.displayTopPages = (displayTopPages) ->
        if displayTopPages
            if (not alreadyRequestedTopPage)
                self.port.emit('getTopPages',0,$scope.query)
                alreadyRequestedTopPage = true
        else alreadyRequestedTopPage = false
        return displayTopPages
