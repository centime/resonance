window.app = angular.module('panel',[])

window.app.controller 'PanelController', ($scope) ->
    settings = {}
    $scope.nick = ''
    $scope.chan = ''

    self.port.on 'settings', (opt) ->
        ( $scope[key] = value for key,value of opt )
        $scope.startForDomain = (opt['domain'] in opt['startForDomains'])
        $scope.$apply()
        settings = opt

    self.port.on 'nick', (nick) ->
        $scope.nick = nick
        $scope.$apply()

    self.port.on 'chan', (chan) ->
        $scope.chan = chan
        $scope.$apply()

    $scope.toggleStarted = () ->
        $scope.started = not $scope.started
        settings['started'] = $scope.started
        self.port.emit('updateSettings',settings)
        self.port.emit('start',$scope.started)

    $scope.toggleActivated = () ->
        $scope.activated = not $scope.activated
        settings['activated'] = $scope.activated
        self.port.emit('updateSettings',settings)
        self.port.emit('activate',$scope.activated)

    $scope.toggleStartByDefault = () ->
        $scope.startByDefault = not $scope.startByDefault
        settings['startByDefault'] = $scope.startByDefault
        self.port.emit('updateSettings',settings)

    $scope.toggleStartForDomain = () ->
        $scope.startForDomain = not $scope.startForDomain
        if $scope.domain?
            if $scope.startForDomain
                $scope.startForDomains.push($scope.domain)
            else
                $scope.startForDomains = (d for d in $scope.startForDomains when d isnt $scope.domain)

        options['startForDomains'] = $scope.startForDomains
        self.port.emit('updateOptions', options)

    $scope.newNick = () ->
        self.port.emit('nextNick',$scope.nick)
        alert('Your new nick ('+$scope.nick+') will be saved and updated as soon as you restart firefox.')

    $scope.getRandomName = () ->
        self.port.emit('getRandomName')
        
    self.port.on 'randomName', (randomName) ->
        $scope.nick = randomName
        $scope.$apply()
        $scope.newNick()
