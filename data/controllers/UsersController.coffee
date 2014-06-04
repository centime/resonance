window.resonance.controller 'UsersController', ($scope)->
    # List of every present user.
    $scope.users = []
    # Listen for the message sent by the server when entering a chan, with the list of present users.
    self.port.on "names",  (channel,nicks) ->
        # Get every nickname. We could maybe use the privileges ?
        $scope.users = ( nick for nick of nicks when (nick isnt IRC.bot)).sort()
        # Update the view.
        $scope.$apply()

    # Listen for the message sent by the server when someone enters the chan
    self.port.on "join",  (channel,nick) ->
        $scope.users.push(nick) if ((nick isnt IRC.nick) and (nick isnt IRC.bot) and (nick not in $scope.users))
        $scope.users = $scope.users.sort()
        $scope.$apply()


    # Listen for the message sent by the server when someone leaves the chan.
    self.port.on "part",  (channel,nick) ->
        $scope.users = ( user for user in $scope.users when user isnt nick ).sort()
        $scope.$apply()

    $scope.displayActions = {}

    $scope.isMute = (user) ->
        user in $scope.$parent.mutedUsers
   
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

    # Add the user to the list of users with which a private conversation has been started.
    $scope.startPm = (user) ->
        self.port.emit('startPmUser', user)
        $scope.$parent.display = 4
        $scope.displayActions[user] = false

    $scope.isClient = (user) ->
        user == IRC.nick