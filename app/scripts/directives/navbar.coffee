'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:navbar
 # @description
 # # navbar
###
angular.module('shortwaveApp')
  .directive('navbar', ->
    template: '#{{currentChannel}}'
    restrict: 'E'
    link: (scope, element, attrs) ->
      # element.text 'this is the navbar directive'
  )