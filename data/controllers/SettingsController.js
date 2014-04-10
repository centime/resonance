
app.controller("SettingsController", function($scope){
    
    $scope.newNick = '';
    $scope.changeNick =  function(){
                            // command the BG script to execute 'newNick'
                            self.port.emit('newNick',$scope.newNick);            
                        };
        
});
