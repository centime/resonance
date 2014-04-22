// Generated by CoffeeScript 1.6.2
(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  window.app.controller("ResonanceController", function($scope) {
    $scope.display = 1;
    $scope.mutedUsers = [];
    self.port.on('requestMutedUsers', function(n) {
      return $scope.mutedUsers = n;
    });
    self.port.on('appSize', function(height) {
      return angular.element('#resonance_container').height(height);
    });
    $scope.resizing = false;
    angular.element('body').on('mousemove', function(e) {
      var newHeight;

      if ($scope.resizing) {
        newHeight = window.innerHeight - e.clientY;
        angular.element('#resonance_container').height(newHeight);
        return self.port.emit('newAppSize', newHeight);
      }
    });
    $scope.privateActive = false;
    self.port.on('activePrivateUsers', function(users) {
      var active, user;

      $scope.privateActive = (__indexOf.call((function() {
        var _results;

        _results = [];
        for (user in users) {
          active = users[user];
          _results.push(active);
        }
        return _results;
      })(), true) >= 0);
      console.log('RC actv ' + $scope.privateActive);
      return $scope.$apply();
    });
    return $scope.active = function() {
      return {
        'active': $scope.privateActive
      };
    };
  });

}).call(this);
