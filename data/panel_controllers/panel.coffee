window.app = angular.module('panel',[])

window.app.controller 'PanelController', ($scope) ->
    options = {}
    self.port.on 'initOptions', (opt) ->
        ( $scope[key] = value for key,value of opt )
        $scope.startForDomain = (opt['domain'] in opt['startForDomains'])
        $scope.$apply()
        options = opt

    $scope.toggleStarted = () ->
        $scope.started = not $scope.started
        options['started'] = $scope.started
        self.port.emit('updateOptions',options)
        self.port.emit('start',$scope.started)

    $scope.toggleActivated = () ->
        $scope.activated = not $scope.activated
        options['activated'] = $scope.activated
        self.port.emit('updateOptions',options)
        self.port.emit('activate',$scope.activated)

    $scope.toggleStartByDefault = () ->
        $scope.startByDefault = not $scope.startByDefault
        options['startByDefault'] = $scope.startByDefault
        self.port.emit('updateOptions',options)

    $scope.toggleStartForDomain = () ->
        $scope.startForDomain = not $scope.startForDomain
        if $scope.domain?
            if $scope.startForDomain
                $scope.startForDomains.push($scope.domain)
            else
                $scope.startForDomains = (d for d in $scope.startForDomains when d isnt $scope.domain)
        options['startForDomains'] = $scope.startForDomains
        self.port.emit('updateOptions',options)
        
    $scope.newNick = () ->
        options['nick'] = $scope.nick
        self.port.emit('updateOptions',options)
        alert('Your new nick ('+$scope.nick+') will be saved and updated as soon as you restart firefox.')