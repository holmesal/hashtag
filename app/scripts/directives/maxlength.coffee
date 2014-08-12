'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:maxLength
 # @description
 # # maxLength
###
angular.module('shortwaveApp')
  .directive('maxLength', ->
    require: 'ngModel'
    scope:
      maxLength: '='
    link: (scope, element, attrs, modelCtrl) ->
      # Get the max length
      Number maxlength = scope.maxLength

      # Add to the parser pipeling
      modelCtrl.$parsers.push (input) ->

        # Cap the length
        parsed = input
        if parsed.length > maxlength
          parsed = parsed.substring 0, maxlength

        # Re-render if changed
        unless parsed is input
          modelCtrl.$setViewValue parsed
          modelCtrl.$render()

        # Return new value
        parsed
  )
