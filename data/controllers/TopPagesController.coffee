window.app.controller "TopPagesController", ($scope) ->
    # List of pages {url : visitors}
    $scope.topPages = []

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
        
    # Execute when TopPages is shown.
    lastDom = ''
    $scope.getTopPages = (displayTopPages) ->
    # If not
        domain = $scope.domain
        if displayTopPages
            if (lastDom!=domain)
                self.port.emit('getTopPages',domain)
                lastDom = domain 
        
        return displayTopPages