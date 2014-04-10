
app.controller('UsersController', function($scope){
    $scope.users = [];
    self.port.on("names", function (channel,nicks) {
            for (nick in nicks){
                $scope.users.push(nick);
            };
            $scope.users.splice($scope.users.indexOf(IRC.nick),1); //it will be added by the 'joined' event
            $scope.$apply()
        });
    self.port.on("joined", function (channel,nick) {
            $scope.users.push(nick);
            $scope.$apply()

        });
    self.port.on("left", function (channel,nick) {
            $scope.users.splice($scope.users.indexOf(nick),1);
            $scope.$apply()
        });
});