
app.controller('UsersController', function($scope){
    self.port.on("names", function (channel,nicks) {
            console.log(nicks)
        });
    $scope.users = ['NoOne','Really'];
});