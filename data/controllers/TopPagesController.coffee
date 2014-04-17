window.app.controller "TopPagesController", ($scope) ->
    # List of pages {url : visitors}
    $scope.topPages = []

    self.port.on 'topPages', (topPages)->
        # Split the string from the bot 'url,visitors,url,visitors,...'
        s = topPages.split(',')
        # Contrstruct an array of arrays from the array : [[url,visitors],[url,visitors]...]
        pages = (p for p in s by 2)
        visitors = (v for v in s[1..] by 2)
        $scope.topPages = ( [page, visitors[i]] for page,i in pages )

        # Update the view.
        $scope.$apply()
        
    # Execute when TopPages is shown.
    # Have top pages already been asked since TopPgae has been shown ?
    askedAlready = false 
    $scope.getTopPages = (displayTopPages) ->
        # If not
        if displayTopPages and not askedAlready
            self.port.emit('getTopPages')
            askedAlready = true 
        # If TopPage isn't displayed anymore
        else if not displayTopPages and askedAlready
            askedAlready = false 

        return displayTopPages
    