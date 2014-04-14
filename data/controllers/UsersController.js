
app.controller('UsersController', function($scope){
    // List of every present user.
    $scope.users = [];
    // Listen for the message sent by the server when entering a chan, with the list of present users.
    self.port.on("names", function (channel,nicks) {
        console.log("ioluihkjghvb'$")
        console.log($scope.users)
            // Get every nickname. We could maybe use the privileges ?
            for (nick in nicks){
                $scope.users.push(nick);

        console.log('\t'+nick)
            };
        console.log('\t'+$scope.users)
        console.log($scope.users.indexOf(IRC.nick))
            // Remove the client, it will be added again by the 'joined' event.
            $scope.users.splice($scope.users.indexOf(IRC.nick),1); 
            // Update the view.
            $scope.$apply();
        });
    // Listen for the message sent by the server when someone enters the chan
    self.port.on("join", function (channel,nick) {
            $scope.users.push(nick);
            $scope.$apply();
        });
    // Listen for the message sent by the server when someone leaves the chan.
    self.port.on("part", function (channel,nick) {
            $scope.users.splice($scope.users.indexOf(nick),1);
            $scope.$apply();
        });
    $scope.mute =  function(user){
                            $scope.$parent.mutedUser.push(user); //Warning unexpected multipush possible.
                            $scope.$parent.$broadcast('mute',user);
                        };
    $scope.isMute =  function(user){
        return ($scope.$parent.mutedUser.indexOf(user) >= 0);
    };
    $scope.unMute =  function(user){
        $scope.$parent.mutedUser.splice($scope.$parent.mutedUser.indexOf(user),1);
        $scope.$parent.$broadcast('unMute',user);
       

    };
});