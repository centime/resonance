window.attached.controller 'AttachedUsersController', ($scope)->
    # List of every present user.
    $scope.users = []
    # Listen for the message sent by the server when entering a chan, with the list of present users.
    self.port.on "names",  (chan, nicks) ->
        if chan == $scope.page.chan
            # Get every nickname. We could maybe use the privileges ?
            $scope.users = ( nick for nick of nicks when  (nick isnt $scope.BOT)).sort()
            # Update the view.
            $scope.$apply()

    # Listen for the message sent by the server when someone enters the chan
    self.port.on "join",  (chan, nick) ->
        if chan == $scope.page.chan
            $scope.users.push(nick) if ((nick isnt $scope.NICK) and (nick isnt $scope.BOT)  and (nick not in $scope.users))
            $scope.users = $scope.users.sort()
            $scope.$apply()


    # Listen for the message sent by the server when someone leaves the chan.
    self.port.on "part",  (chan, nick) ->
        if chan == $scope.page.chan
            $scope.users = ( user for user in $scope.users when user isnt nick ).sort()
            $scope.$apply()

    # Listen for the message sent by the server when someone leaves the chan.
    self.port.on "quit",  (nick) ->
        $scope.users = ( user for user in $scope.users when user isnt nick ).sort()
        $scope.$apply()
