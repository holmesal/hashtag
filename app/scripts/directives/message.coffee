'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:message
 # @description
 # # message
###
angular.module('shortwaveApp')
  .directive('message', ($rootScope, $firebase, $sce, $window, $http, $timeout, NodeWebkit) ->
    templateUrl: 'views/partials/message.html'
    restrict: 'E'
    scope:
      message: '='
      rolling: '='
      separated: '='
      last: '='
      preurl: '='
      channelName: '='
    link: (scope, element, attrs) ->

      ownerRef = $rootScope.rootRef.child "users/#{scope.message.owner}/profile"
      sync = $firebase ownerRef
      scope.owner = sync.$asObject()

      # console.log scope.message

      # Hacky till this gets moved out into it's own template
      scope.$watch 'message.content.gfycat', (updated) ->
        if updated
          # $http.get ''
          # Make a request to GFYCAT to convert these
          scope.vidurls = 
            mp4: $sce.trustAsResourceUrl(updated.mp4)
            webm: $sce.trustAsResourceUrl(updated.webm)

      # Watch for unconverted GIFs and convert them
      scope.$watch 'message.content.converted', (converted) ->
        if converted is false
          # console.log 'got unconverted gif!'
          gfycatConvert()

      gfycatConvert = ->
        $http.get "http://upload.gfycat.com/transcode?fetchUrl=#{scope.message.content.src}"
        .success (data, status, headers, config) ->
          # console.info 'got request back', data
          if data.task is 'complete'
            # Update the gif
            gifRef = $rootScope.rootRef.child "messages/#{scope.channelName}/#{scope.message.$id}/content"
            gifRef.update
              converted: true
              gfycat:
                mp4: data.mp4Url
                webm: data.webmUrl
                website: "http://gfycat.com/#{data.gfyName}"
          else
            # Try again in 35 seconds
            $timeout gfycatConvert, 35000
        .error (data, status, headers, config) ->
          console.error 'error from gfycat', data, status

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
