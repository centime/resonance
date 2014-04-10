
app.controller("MainController", function($scope){
    
    $scope.todos = ['Try the todo.'];
    $scope.newTodo = "New todo...";
    $scope.addNew =  function(){
                            $scope.todos.push($scope.newTodo);
                        };
    $scope.del =  function(todo){
                            var index = $scope.todos.indexOf(todo);
                            $scope.todos.splice(index,1);
                        };

});