'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:compile
 # @description
 # # compile
###
angular.module('shortwaveApp')
  .directive('compile', ($compile) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      
      # This function recompiles templates
      scope.$watch (scope) ->
        scope.$eval attrs.compile
      , (val) ->
        element.html val
        $compile(element.contents())(scope)

  )
