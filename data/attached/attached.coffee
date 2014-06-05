window.attached = angular.module('attached',[])
window.attached.config( [
        '$compileProvider',( $compileProvider ) ->
            $compileProvider.imgSrcSanitizationWhitelist(/^resource:/)
            #compileProvider.imgSrcSanitizationWhitelist(/r/)
    ]);
window.attached.controller 'AttachedController', ($scope) ->
    $scope.pages = []
    $scope.display = 1
    $scope.NICK = ''
    $scope.BOT = ''
    self.port.on 'pages', (pages) ->
        $scope.pages = pages
        $scope.$apply()

    self.port.on 'nick', (nick) ->
        $scope.NICK = nick

    self.port.on 'bot', (bot) ->
        $scope.BOT = bot

    self.port.emit('ready')

    $scope.detach = (page) ->
        self.port.emit('detach',page)

    # The logo url
    $scope.logoUrl = self.options.testUrl