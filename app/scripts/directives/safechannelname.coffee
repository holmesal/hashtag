'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:safeChannelName
 # @description
 # # safeChannelName
###
angular.module('shortwaveApp')
  .directive('safeChannelName', ->
    require: 'ngModel'
    link: (scope, element, attrs, modelCtrl) ->
      
      # Add to the parser pipeling
      modelCtrl.$parsers.push (input) ->

        # Lower-case only
        parsed = input.toLowerCase()

        # No spaces allowed
        parsed = parsed.replace /\ /g, '-'

        # No character codes
        parsed = parsed.replace /[\x00-\x1F\x7F]/g, ''

        # Firebase doesn't allow these characters
        parsed = parsed.replace /[\/,$,\[,\]]/g, ''

        # Re-render if changed
        unless parsed is input
          modelCtrl.$setViewValue parsed
          modelCtrl.$render()

        # Return new value
        parsed
  )
