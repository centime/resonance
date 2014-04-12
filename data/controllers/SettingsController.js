app.controller("SettingsController", function($scope){
    $scope.newNick = '';
    // Updates the nick when received from the background script.
    self.port.on('nick',function(n){
        $scope.newNick = n ;
    });
    $scope.saveSettings =  function(){
                        // command the background script to execute 'newNick'
                        self.port.emit('newNick',$scope.newNick);       
                    };   
});