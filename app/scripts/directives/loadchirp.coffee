'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:loadchirp
 # @description
 # # loadchirp
###
angular.module('shortwaveApp')
  .directive('loadchirp', ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      element.bind 'load loadeddata', ->
        # Emit upwards to the stream
        scope.$emit 'heightUpdate'
  )
