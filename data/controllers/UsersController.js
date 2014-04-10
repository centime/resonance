
app.controller('UsersController', function($scope){
    $scope.users = [];
    self.port.on("names", function (channel,nicks) {
            for (nick in nicks){
                $scope.users.push(nick);
            };
            $scope.$apply()
        });
});