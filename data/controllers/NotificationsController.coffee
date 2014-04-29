window.resonance.controller "NotificationsController", ($scope) ->
     # List of every notifications.
    $scope.notifications = []
    $scope.announce = ''

    # Get the history from the background.
    self.port.on "notificationsHistory", (notificationsHistory) ->
        $scope.notifications = ({ 'type':notification.type, 'notification':notification.message, 'old':notification.old} for notification in notificationsHistory)
        $scope.$apply()
        scrollDown()

    self.port.on 'notification', (notification) ->
        $scope.notifications.push(notification)
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
        elmt.animate({ scrollTop: elmt.prop('scrollHeight')}, 1000)