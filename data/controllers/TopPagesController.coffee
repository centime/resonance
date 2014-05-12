window.resonance.controller "TopPagesController", ($scope) ->
    # List of pages {url : visitors}
    $scope.topPages = []
    $scope.TP.query = ''
    $scope.index = 0
    $scope.total = 0

    $scope.categories = []
    $scope.selectedCategory = ''
    $scope.newCategory = ''

    self.port.on 'categories', (categories) ->
        $scope.categories = categories
        $scope.$apply()

    self.port.on 'topPages', (topPages) ->
        #Pastes the already recieved string with the new part
        $scope.topPages = topPages
        $scope.$apply()
    
    self.port.on 'topPagesMetaData', (query, index, total) ->
        # What has been requested.
        $scope.TP.query = query
        # Which page
        $scope.index = Number(index)
        # Total of pages
        $scope.total = Number(total)
        $scope.$apply()

    $scope.getTopPages = () ->
        self.port.emit('getTopPages',$scope.index,$scope.TP.query)
                
    # Execute when TopPages is shown.
    done = false
    $scope.displayTopPages = (displayTopPages) ->
        if displayTopPages
            if (not done)
                self.port.emit('getTopPages',$scope.index,$scope.TP.query)
                done = true

                #focus the input
                angular.element('toppages_resonance input').focus()
        else done = false
        return displayTopPages

    $scope.selectCategory = (category) ->
        $scope.TP.query = category.query
        $scope.index = 0
        $scope.getTopPages()
        $scope.selectedCategory = category.name

    $scope.setCategoryQuery = (category) ->
        self.port.emit('setCategory', category, $scope.TP.query)
        $scope.selectedCategory = ''

    $scope.deleteCategory = (category) ->
        self.port.emit('deleteCategory', category)

    $scope.addCategory = () ->
        category = 
            'name' : $scope.newCategory
            'query' : 'keyword1|keyword2|keyword3'
        self.port.emit('newCategory', category)

    $scope.previous = () ->
        if $scope.index > 0
            $scope.index--
            self.port.emit('getTopPages',$scope.index,$scope.TP.query)
    $scope.next = () ->
        if $scope.index+1 < $scope.total
            $scope.index++
            self.port.emit('getTopPages',$scope.index,$scope.TP.query)

    # It works, but is it really a good feature ?
    numberOfLines = () ->
        divheight = $('toppages_resonance > ul').height()
        lineheight = $('toppages_resonance li').css('line-height')
        Math.floor(divheight/parseInt(lineheight))-2
