
app.controller("MessagesController", function($scope){
    
    $scope.messages = [];
    $scope.newMessage = '';
    $scope.submitNewMessage =  function(){
                            self.port.emit('say',IRC.chan, $scope.newMessage);
                        };

    self.port.on("message", function (from,to,message) {
        var text = from+' : '+message;
        $scope.messages.push(text)
        $scope.$apply()
        //TODO : scroll down
        //messagesListArea.scrollTop = messagesListArea.scrollHeight;
    });

});