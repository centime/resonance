
app.controller("MessagesController", function($scope){
    
    $scope.messages = [];
    $scope.newMessage = '';
    var elmt = angular.element('#messages .list') ;
    
    $scope.submitNewMessage =  function(){
                            // command the BG script to execute 'say'
                            self.port.emit('say',IRC.chan, $scope.newMessage);
                            // Clear the input.
                            $scope.newMessage = '';
                        };

    self.port.on("message", function (from,to,message) {
        //if ((to !== IRC.chan) && (to !== IRC.nick)) return//tofix
        var text = from+' : '+message;
        $scope.messages.push(text)
        $scope.$apply()
        // scroll down
        elmt.animate({ scrollTop: elmt.prop('scrollHeight')}, 1000);
        
        
    });

});