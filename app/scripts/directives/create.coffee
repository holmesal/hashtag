'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:create
 # @description
 # # create
###
angular.module('shortwaveApp')
  .directive('create', ->
    templateUrl: 'views/partials/create.html'
    restrict: 'E'
    scope:
      cancel: '&'
    link: (scope, element, attrs) ->
      # element.text 'this is the create directive'
  )
