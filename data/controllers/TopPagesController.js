app.controller("TopPagesController", function($scope){
    $scope.topPages = [];
    self.port.on('topPages', function(topPages){
        var s = topPages.split(',');
        for (var i=0;i<s.length;i+=2){
            $scope.topPages.push([ s[i],s[i+1] ]) ;
        };
        // Update the view.
        $scope.$apply();
        console.log($scope.topPages);
    })
    var askedAlready = false ;
    $scope.getTopPages = function(displayTopPages){
        if (displayTopPages && !askedAlready){
            self.port.emit('getTopPages');
            askedAlready = true ;
        }else if (!displayTopPages){
            askedAlready = false ;
        }
        return displayTopPages;
    };
    
    
});