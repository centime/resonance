
app.controller('UsersController', function($scope){
    // List of every present user.
    $scope.users = [];
    // Listen for the message sent by the server when entering a chan, with the list of present users.
    self.port.on("names", function (channel,nicks) {
            // Get every nickname. We could maybe use the privileges ?
            for (nick in nicks){
                $scope.users.push(nick);
            };
            // Remove the client, it will be added again by the 'joined' event.
            $scope.users.splice($scope.users.indexOf(IRC.nick),1); 
            // Update the view.
            $scope.$apply()
        });
    // Listen for the message sent by the server when someone enters the chan
    self.port.on("join", function (channel,nick) {
            $scope.users.push(nick);
            $scope.$apply()

        });
    // Listen for the message sent by the server when someone leaves the chan.
    self.port.on("part", function (channel,nick) {
            $scope.users.splice($scope.users.indexOf(nick),1);
            $scope.$apply()
        });
});