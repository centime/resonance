window.resonance.controller "NotificationsController", ($scope) ->
     # List of every notifications.
    $scope.notifications = []
    $scope.announce = ''

    # Get the history from the background.
    self.port.on "notificationsHistory", (notificationsHistory) ->
        $scope.notifications = notificationsHistory
        scrollDown()
        $scope.$apply()
    
    self.port.on 'announce', (announce) ->
        $scope.announce = announce
        $scope.$apply()
    
    # Execute when Notifications is shown.
    alreadyUnactivated = false
    $scope.displayNotifications = (displayNotifications) ->
        if displayNotifications
            if (not alreadyUnactivated)
                self.port.emit('notificationActive',false)  
                alreadyUnactivated = true
        else alreadyUnactivated = false
        return displayNotifications

    $scope.class = (notification) ->
        {'old_message_resonance': notification.old}
        
    # Scroll down the notifications list.
    elmt = angular.element('notifications_resonance > ul') 
    scrollDown = ()  ->       
        elmt.animate({ scrollTop: elmt.prop('scrollHeight')}, 1000)