'use strict'

###*
 # @ngdoc filter
 # @name shortwaveApp.filter:parseUrl
 # @function
 # @description
 # # parseUrl
 # Filter in the shortwaveApp.
###
angular.module('shortwaveApp')
  .filter 'parseUrl', ->
    (text) ->
      replacePattern1 = /(\b(https?|ftp):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/gim
      replacePattern2 = /(^|[^\/])(www\.[\S]+(\b|$))/gim
      replacePattern3 = /(\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,6})/gim

      if text
        angular.forEach text.match(replacePattern1), (url) ->
          text = text.replace replacePattern1, "<a ng-click='navigate(\"$1\")'>$1</a>"
          # text = text.replace replacePattern1, "<a href=\"$1\" target=\"_blank\">$1</a>"

        angular.forEach text.match(replacePattern2), (url) ->
          text = text.replace replacePattern2, "$1<a ng-click='navigate(\"$2\")'>$2</a>"
          # text = text.replace replacePattern2, "$1<a href=\"http://$2\" target=\"_blank\">$2</a>"

        angular.forEach text.match(replacePattern3), (url) ->
          text = text.replace replacePattern3, "<a ng-click='navigate(\"mailto:$1\")'>$1</a>"
          # text = text.replace replacePattern3, "<a href=\"mailto:$1\">$1</a>"

      text
