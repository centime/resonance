// Generated by CoffeeScript 1.4.0
(function() {

  window.app.controller("PrivateMessagesController", function($scope) {
    var currentPmUser, elmt, scrollDown;
    $scope.messages = [];
    $scope.newMessage = '';
    currentPmUser = 'Resonance-bot';
    self.port.on("pmUser", function(user, history) {
      currentPmUser = user;
      $scope.messages = history;
      return scrollDown();
    });
    $scope.submitNewMessage = function() {
      var msg;
      msg = $scope.newMessage;
      if (msg !== '') {
        self.port.emit('privateMessage', currentPmUser, msg);
      }
      return $scope.newMessage = '';
    };
    self.port.on("privateMessage", function(from, to, message) {
      var entry;
      entry = {
        'author': from,
        'message': message
      };
      $scope.messages.push(entry);
      $scope.$apply();
      return scrollDown();
    });
    $scope.oldMessage = function(message) {
      return {
        'old_message': message.old
      };
    };
    self.port.on('error', function(error) {
      $scope.messages.push({
        'author': 'Error',
        'message': error
      });
      $scope.$apply();
      return scrollDown();
    });
    elmt = angular.element('privatemessages > ul');
    return scrollDown = function() {
      return elmt.animate({
        scrollTop: elmt.prop('scrollHeight')
      }, 1000);
    };
  });

}).call(this);
