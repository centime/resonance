window.resonance.controller "TopPagesController", ($scope) ->
    # List of pages {url : visitors}
    $scope.topPages = []
    $scope.query = ''
    $scope.index = 0
    $scope.total = 0

    $scope.categories = [
        {'name':'Informatique','query':'sebsauvage|news.ycombinator'},
        {'name':'France','query':'lemonde|rue89'},
        {'name':'Web comics','query':'xkcd|commitstrip'},
        ]

    self.port.on 'topPages', (topPages) ->
        #Pastes the already recieved string with the new part
        $scope.topPages = topPages
        $scope.$apply()
    
    self.port.on 'topPagesMetaData', (query, index, total) ->
        # What has been requested.
        $scope.query = query
        # Which page
        $scope.index = Number(index)
        # Total of pages
        $scope.total = Number(total)
        $scope.$apply()

    $scope.getTopPages = () ->
        self.port.emit('getTopPages',$scope.index,$scope.query)
                
    # Execute when TopPages is shown.
    alreadyRequestedTopPage = false
    $scope.displayTopPages = (displayTopPages) ->
        if displayTopPages
            if (not alreadyRequestedTopPage)
                self.port.emit('getTopPages',$scope.index,$scope.query)
                alreadyRequestedTopPage = true
        else alreadyRequestedTopPage = false
        #focus the input
        angular.element('toppages_resonance input').focus()
        return displayTopPages


    $scope.selectCategory = (category) ->
        $scope.query = category.query
        $scope.index = 0
        $scope.getTopPages()

    $scope.previous = () ->
        if $scope.index > 0
            $scope.index--
            self.port.emit('getTopPages',$scope.index,$scope.query)
    $scope.next = () ->
        if $scope.index+1 < $scope.total
            $scope.index++
            self.port.emit('getTopPages',$scope.index,$scope.query)

    # It works, but is it really a good feature ?
    numberOfLines = () ->
        divheight = $('toppages_resonance > ul').height()
        lineheight = $('toppages_resonance li').css('line-height')
        Math.floor(divheight/parseInt(lineheight))-2
