// Generated by CoffeeScript 1.4.0
(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  window.app.controller('UsersController', function($scope) {
    $scope.users = [];
    self.port.on("names", function(channel, nicks) {
      var nick;
      $scope.users = ((function() {
        var _results;
        _results = [];
        for (nick in nicks) {
          if (nick !== 'Resonance-bot') {
            _results.push(nick);
          }
        }
        return _results;
      })()).sort();
      return $scope.$apply();
    });
    self.port.on("join", function(channel, nick) {
      if ((nick !== IRC.nick) && (nick !== 'Resonance-bot')) {
        $scope.users.push(nick);
      }
      $scope.users = $scope.users.sort();
      return $scope.$apply();
    });
    self.port.on("part", function(channel, nick) {
      var user;
      $scope.users = ((function() {
        var _i, _len, _ref, _results;
        _ref = $scope.users;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          user = _ref[_i];
          if (user !== nick) {
            _results.push(user);
          }
        }
        return _results;
      })()).sort();
      return $scope.$apply();
    });
    $scope.displayActions = {};
    $scope.isMute = function(user) {
      return __indexOf.call($scope.$parent.mutedUsers, user) >= 0;
    };
    $scope.mute = function(user) {
      $scope.$parent.mutedUsers.push(user);
      $scope.$parent.$broadcast('mute', user);
      return self.port.emit('updateMutedUsers', $scope.$parent.mutedUsers);
    };
    $scope.unMute = function(user) {
      $scope.$parent.mutedUsers.splice($scope.$parent.mutedUsers.indexOf(user), 1);
      $scope.$parent.$broadcast('unMute', user);
      return self.port.emit('updateMutedUsers', $scope.$parent.mutedUsers);
    };
    $scope.startPm = function(user) {
      self.port.emit('startPmUser', user);
      $scope.$parent.display = 4;
      return $scope.displayActions[user] = false;
    };
    return $scope.isClient = function(user) {
      return user === IRC.nick;
    };
  });

}).call(this);
