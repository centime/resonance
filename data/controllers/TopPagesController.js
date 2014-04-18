app.controller("TopPagesController", function($scope){
    // List of pages {url : visitors}
    $scope.topPages = [];
    self.port.on('topPages', function(topPages){
        // Split the string from the bot 'url,visitors,url,visitors,...'
        var s = topPages.split(',');
        // Contrstruct an array of arrays from the array : [[url,visitors],[url,visitors]...]
        for (var i=0;i<s.length;i+=2){
            $scope.topPages.push([ s[i],s[i+1] ]) ;
        };
        // Update the view.
        $scope.$apply();
    });
    // Execute when TopPages is shown.
    // Have top pages already been asked since TopPgae has been shown ?
    var lastDom = null ;
    var lastKey = null ;
    $scope.getTopPages = function(displayTopPages){
        // If not
        var domain = $scope.domain;
        var ts = $scope.typeSearch;
        if (displayTopPages ){
            if ((ts=='dom') && (lastDom!=domain)){
                self.port.emit('getTopPagesDom',domain);
                lastDom = domain ;
            }
            if ((lastKey!=domain) && (ts=='key')){
                self.port.emit('getTopPagesKey',domain);
                lastKey = domain ;
            }
        }
        return displayTopPages;
    };
});