window.resonance.controller "NotificationsController", ($scope) ->
     # List of every notifications.
    $scope.notifications = []
    $scope.announce = ''

    # Get the history from the background.
    self.port.on "notificationsHistory", (notificationsHistory) ->
        $scope.notifications = notificationsHistory
        $scope.$apply()
        scrollDown()
    
    self.port.on 'announce', (announce) ->
        $scope.announce = announce
        $scope.$apply()
    
    $scope.class = (notification) ->
        {'old_message_resonance': notification.old}
        
    # Scroll down the notifications list.
    elmt = angular.element('notifications_resonance > ul') 
    scrollDown = ()  ->
        if (elmt.prop('scrollHeight')-elmt.prop('scrollTop'))/parseInt(elmt.css('height')) < 1.2
            elmt.animate({ scrollTop: elmt.prop('scrollHeight')}, 1000)