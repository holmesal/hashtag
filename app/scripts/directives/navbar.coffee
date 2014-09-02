'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:navbar
 # @description
 # # navbar
###
angular.module('shortwaveApp')
  .directive('actionbar', ->
    templateUrl: 'views/partials/actionbar.html'
    restrict: 'E'
    link: (scope, element, attrs) ->
      # element.text 'this is the navbar directive'
  )
