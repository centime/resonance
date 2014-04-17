app.controller("TopPagesController", function($scope){
    // List of pages {url : visitors}
    $scope.topPages = [];
    self.port.on('topPages', function(topPages){
        // Splir the string from the bot 'url,visitors,url,visitors,...'
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
    var askedAlready = false ;
    $scope.getTopPages = function(displayTopPages){
        // If not
        if (displayTopPages && !askedAlready){
            self.port.emit('getTopPages');
            askedAlready = true ;
        // If TopPage isn't displayed anymore
        }else if (!displayTopPages && askedAlready){
            askedAlready = false ;
        }
        return displayTopPages;
    };
    
    
});