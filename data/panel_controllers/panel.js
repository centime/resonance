// Generated by CoffeeScript 1.4.0
(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  window.app = angular.module('panel', []);

  window.app.controller('PanelController', function($scope) {
    var settings;
    settings = {};
    $scope.nick = '';
    self.port.on('settings', function(opt) {
      var key, value, _ref;
      for (key in opt) {
        value = opt[key];
        $scope[key] = value;
      }
      $scope.startForDomain = (_ref = opt['domain'], __indexOf.call(opt['startForDomains'], _ref) >= 0);
      $scope.$apply();
      return settings = opt;
    });
    self.port.on('nick', function(nick) {
      $scope.nick = nick;
      return $scope.$apply();
    });
    $scope.toggleStarted = function() {
      $scope.started = !$scope.started;
      settings['started'] = $scope.started;
      self.port.emit('updateSettings', settings);
      return self.port.emit('start', $scope.started);
    };
    $scope.toggleActivated = function() {
      $scope.activated = !$scope.activated;
      settings['activated'] = $scope.activated;
      self.port.emit('updateSettings', settings);
      return self.port.emit('activate', $scope.activated);
    };
    $scope.toggleStartByDefault = function() {
      $scope.startByDefault = !$scope.startByDefault;
      settings['startByDefault'] = $scope.startByDefault;
      return self.port.emit('updateSettings', settings);
    };
    $scope.toggleStartForDomain = function() {
      var d;
      $scope.startForDomain = !$scope.startForDomain;
      if ($scope.domain != null) {
        if ($scope.startForDomain) {
          $scope.startForDomains.push($scope.domain);
        } else {
          $scope.startForDomains = (function() {
            var _i, _len, _ref, _results;
            _ref = $scope.startForDomains;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              d = _ref[_i];
              if (d !== $scope.domain) {
                _results.push(d);
              }
            }
            return _results;
          })();
        }
      }
      options['startForDomains'] = $scope.startForDomains;
      return self.port.emit('updateOptions', options);
    };
    $scope.newNick = function() {
      self.port.emit('nextNick', $scope.nick);
      return alert('Your new nick (' + $scope.nick + ') will be saved and updated as soon as you restart firefox.');
    };
    $scope.getRandomName = function() {
      return self.port.emit('getRandomName');
    };
    return self.port.on('randomName', function(randomName) {
      $scope.nick = randomName;
      $scope.$apply();
      return $scope.newNick();
    });
  });

}).call(this);
