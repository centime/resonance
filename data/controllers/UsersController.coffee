window.app.controller 'UsersController', ($scope)->
    # List of every present user.
    $scope.users = []
    # Listen for the message sent by the server when entering a chan, with the list of present users.
    self.port.on "names",  (channel,nicks) ->
            # Get every nickname. We could maybe use the privileges ?
            $scope.users = ( nick for nick of nicks if nick isnt 'Resonance-bot')
            # Update the view.
            $scope.$apply()

    # Listen for the message sent by the server when someone enters the chan
    self.port.on "join",  (channel,nick) ->
            $scope.users.push(nick) if ((nick isnt IRC.nick) and (nick isnt 'Resonance-bot'))
            $scope.$apply()


    # Listen for the message sent by the server when someone leaves the chan.
    self.port.on "part",  (channel,nick) ->
            $scope.users = ( user for user in $scope.users when user isnt nick )
            $scope.$apply()

    $scope.mute = (user) ->
            $scope.$parent.mutedUser.push(user) #Warning unexpected multipush possible.
            $scope.$parent.$broadcast('mute',user)
                        
    $scope.isMute = (user) ->
            user in $scope.$parent.mutedUser
    
    $scope.unMute = (user) ->
            $scope.$parent.mutedUser.splice($scope.$parent.mutedUser.indexOf(user),1)
            $scope.$parent.$broadcast('unMute',user)

