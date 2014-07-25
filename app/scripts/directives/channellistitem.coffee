'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:channelListItem
 # @description
 # # One of the list items that appears in the 
###
angular.module('shortwaveApp')
  .directive('channellistitem', ->
    template: '<div></div>'
    restrict: 'E'
    link: (scope, element, attrs) ->
      # element.text 'this is the channelListItem directive'
  )
