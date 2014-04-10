
app.controller('UsersController', function($scope){
    $scope.users = [];
    self.port.on("names", function (channel,nicks) {
        if (channel !== IRC.chan) return //tofix
            for (nick in nicks){
                $scope.users.push(nick);
            };
            $scope.users.splice($scope.users.indexOf(IRC.nick),1); //it will be added by the 'joined' event
            $scope.$apply()
        });
    self.port.on("joined", function (channel,nick) {
        if (channel !== IRC.chan) return //tofix
            $scope.users.push(nick);
            $scope.$apply()

        });
    self.port.on("left", function (channel,nick) {
        if (channel !== IRC.chan) return //tofix
            $scope.users.splice($scope.users.indexOf(nick),1);
            $scope.$apply()
        });
});