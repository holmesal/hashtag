'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:focusOn
 # @description
 # # sets focus on this element
###
angular.module('shortwaveApp')
  .directive('focusOn', ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      scope.$on 'focusOn', (e, name) ->
        if name is attrs.focusOn
          console.log "focusing #{name}"
          element[0].focus()
  )
