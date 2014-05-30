window.panel = angular.module('panel',[])

window.panel.controller 'PanelController', ($scope) ->
    settings = {}
    $scope.nick = ''
    $scope.chan = ''
    $scope.started = false
    $scope.nickMessage = ''
    $scope.clearMessage = ''

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

    self.port.on 'started', (started) ->
        $scope.started = started
        $scope.$apply()

    $scope.toggleStarted = () ->
        if $scope.started
            $scope.started = false
            self.port.emit('stop')
        else
            $scope.started = true
            self.port.emit('start')

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

        settings['startForDomains'] = $scope.startForDomains
        self.port.emit('updateSettings', settings)

    $scope.newNick = () ->
        self.port.emit('nextNick',$scope.nick)
        $scope.nickMessage = $scope.nick+' will be saved and updated as soon as you restart firefox.'
        $scope.$apply()
        
    $scope.getRandomName = () ->
        self.port.emit('getRandomName')
        
    self.port.on 'randomName', (randomName) ->
        $scope.nick = randomName
        $scope.$apply()
        $scope.newNick()

    $scope.openMaster = () ->
        self.port.emit('openMaster')

    $scope.class = (param) ->
        {'green':$scope[param],'red':not $scope[param]}

    $scope.clearNotifications = () ->
        self.port.emit('clearNotifications')
        $scope.clearMessage = 'Your history will be cleared as soon as your restart Firefox'
    
    $scope.clearMessages = () ->
        self.port.emit('clearMessages')
        $scope.clearMessage = 'Your history will be cleared as soon as your restart Firefox'
    
    $scope.clearPrivate = () ->
        self.port.emit('clearPrivate')
        $scope.clearMessage = 'Your history will be cleared as soon as your restart Firefox'
    