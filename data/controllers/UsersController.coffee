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

    $scope.isMute = (user) ->
            user in $scope.$parent.mutedUser
   
    $scope.mute = (user) ->
            #Warning: unexpected multipush possible.
            $scope.$parent.mutedUsers.push(user) 
            #send to MessagesController
            $scope.$parent.$broadcast('mute',user)
            #send the list of muted users to the background
            self.port.emit('updateMutedUsers',$scope.$parent.mutedUsers) 
             
    $scope.unMute = (user) ->
            $scope.$parent.mutedUsers.splice($scope.$parent.mutedUsers.indexOf(user),1)
            #send to MessagesController
            $scope.$parent.$broadcast('unMute',user)
            #send the list of muted users to the background
            self.port.emit('updateMutedUsers',$scope.$parent.mutedUsers) 

    #switch the buttons mute and unMute
    $scope.isMute = (user) ->
            $scope.$parent.mutedUsers.indexOf(user) >= 0

    # Add the user to the list of users with which a private conversation has been started.
    $scope.startPm = (user) ->
            self.port.emit( 'startPmUser', user)
            $scope.$parent.display = 4
