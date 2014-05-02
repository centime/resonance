// Generated by CoffeeScript 1.4.0
(function() {

  window.resonance.controller('PrivateUsersController', function($scope) {
    $scope.currentPmUser = 'Resonance-bot';
    $scope.pmUsers = [];
    $scope.selectPmUser = function(user) {
      self.port.emit('startPmUser', user);
      return self.port.emit('unactivePmUser', user);
    };
    self.port.on("pmUser", function(user, history) {
      $scope.currentPmUser = user;
      return $scope.$apply();
    });
    self.port.on("pmUsers", function(users) {
      $scope.pmUsers = users;
      return $scope.$apply();
    });
    $scope["class"] = function(user) {
      return {
        'selected_resonance': user === $scope.currentPmUser,
        'active_resonance': $scope.activePrivateUsers[user]
      };
    };
    $scope.activePrivateUsers = {};
    return self.port.on('activePrivateUsers', function(users) {
      $scope.activePrivateUsers = users;
      return $scope.$apply();
    });
  });

}).call(this);