window.app.controller "TopPagesController", ($scope) ->
    # List of pages {url : visitors}
    $scope.topPages = []
    $scope.nbTopPages = 5
    assemb = ''
    firstDone = false
    self.port.on 'topPages', (topPages)->
        #Pastes the already recieved string with the new part
        assemb = assemb.concat(atob(topPages))
        # Split the string from the bot 'url,visitors,url,visitors,...'
        if assemb.match('^top')
            $scope.chunkfast()    
        if assemb.match('end$')
            assemb = assemb.substr(0,assemb.length-3)
            $scope.chunk()
            
    $scope.chunkfast = () ->
        if assemb.match(',')
            assemb = assemb.replace('top','')
            s = assemb.split(',')
            $scope.topPages = ([[s[0],s[1]]])
            $scope.$apply()

    $scope.chunk = () ->
        s = assemb.split(',')
        # Contrstruct an array of arrays from the array : [[url,visitors],[url,visitors]...]
        pages = (p for p in s by 2)
        visitors = (v for v in s[1..] by 2)
        #Range of topPages displayed : greatest value of index or number asked by user
        x = Math.min($scope.nbTopPages,pages.length)-1
        $scope.topPages = ( [page, visitors[i]] for page,i in pages[0..x])
        $scope.$apply()
        assemb = ''

    $scope.getTopPages = () ->
        $scope.topPages=[]
        self.port.emit('getTopPages',$scope.domain)