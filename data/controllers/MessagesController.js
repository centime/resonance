
app.controller("MessagesController", function($scope){
    
    $scope.messages = [];
    $scope.newMessage = '';
    $scope.submitNewMessage =  function(){
                            $scope.messages.push($scope.newMessage);
                        };

});