window.app.controller "TopPagesController", ($scope) ->
    # List of pages {url : visitors}
    $scope.topPages = []
    $scope.regexp = ''

    self.port.on 'topPages', (topPages)->
        topPages = atob(topPages)
        # Split the string from the bot 'url,visitors,url,visitors,...'
        s = topPages.split(',')
        # Contrstruct an array of arrays from the array : [[url,visitors],[url,visitors]...]
        pages = (p for p in s by 2)
        visitors = (v for v in s[1..] by 2)
        if pages[0][0..4]=='begin'
            $scope.topPages=[]
            pages[0]=pages[0].substring(5)
        $scope.topPages = $scope.topPages.concat( [page, visitors[i]] for page,i in pages )
        
        # Update the view.
        $scope.$apply()
        
    $scope.getTopPages = () ->
        self.port.emit('getTopPages',$scope.regexp)
                
    # Execute when TopPages is shown.
    alreadyRequestedTopPage = false
    $scope.displayTopPages = (displayTopPages) ->
        if displayTopPages
            if (not alreadyRequestedTopPage)
                self.port.emit('getTopPages',$scope.regexp)
                alreadyRequestedTopPage = true
        else alreadyRequestedTopPage = false
        #focus the input
        angular.element('toppages_resonance input').focus()
        return displayTopPages
