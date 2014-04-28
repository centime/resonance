window.resonance.controller "SettingsController", ($scope) ->
    $scope.newNick = ''
    # Updates the nick when received from the background script.
    self.port.on 'nick',(n) ->
        $scope.newNick = n 

    $scope.saveSettings =  () ->
                        # command the background script to execute 'newNick'
                        self.port.emit('newNick',$scope.newNick)       
                    