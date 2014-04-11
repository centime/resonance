
app.controller("MessagesController", function($scope){
    
    $scope.messages = [];
    $scope.newMessage = '';
    var elmt = angular.element('#messages .list') ;
    
    $scope.submitNewMessage =  function(){
                            self.port.emit('say',IRC.chan, $scope.newMessage);
                        };

    self.port.on("message", function (from,to,message) {
        var text = from+' : '+message;
        $scope.messages.push(text)
        $scope.$apply()
        // scroll down
        elmt.animate({ scrollTop: elmt.prop('scrollHeight')}, 1000);
        
        
    });

});