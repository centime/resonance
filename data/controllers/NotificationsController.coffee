window.app.controller "NotificationsController", ($scope) ->
     # List of every notifications.
    $scope.notifications = []

    # Get the history from the background.
    self.port.on "notificationsHistory", (notificationsHistory) ->
        $scope.notifications = ({ 'type':notification.author, 'notification':notification.notification, 'old':notification.old} for notification in notificationsHistory)
        $scope.$apply()
        scrollDown()

    # Hit him in the face.
    self.port.on 'notification', (notification) ->
        $scope.notifications.push(notification)
        $scope.$apply()
        scrollDown()

    # Scroll down the messages list.
    elmt = angular.element('notifications_resonance > ul') 
    scrollDown = ()  ->
        elmt.animate({ scrollTop: elmt.prop('scrollHeight')}, 1000)