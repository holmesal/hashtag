'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:message
 # @description
 # # message
###
angular.module('shortwaveApp')
  .directive('message', ($rootScope, $firebase, $sce, $window, NodeWebkit) ->
    templateUrl: 'views/partials/message.html'
    restrict: 'E'
    scope:
      message: '='
      rolling: '='
      last: '='
    link: (scope, element, attrs) ->

      ownerRef = $rootScope.rootRef.child "users/#{scope.message.owner}/profile"
      sync = $firebase ownerRef
      scope.owner = sync.$asObject()

      # Hacky till this gets moved out into it's own template
      scope.$watch 'message.content.src', (updated) ->
        if updated
          scope.vidurls = 
            mp4: $sce.trustAsResourceUrl(updated.mp4)
            webm: $sce.trustAsResourceUrl(updated.webm)

      scope.navigate = (url) ->

        if NodeWebkit.isDesktop
          NodeWebkit.open url 
        else
          # Open in a new tab
          $window.open url

        console.log "got navigate request for #{url}"

      # Watch the window scroll
      # windowEl = element.parent()

      # windowEl.on 'scroll', ->
      #   console.log "window scrolled to #{windowEl.scrollTop()}"
      #   scope.offsetTop = windowEl.scrollTop()
      # scope.offsetTop = 100
  )
