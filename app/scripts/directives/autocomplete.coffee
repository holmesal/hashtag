'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:autocomplete
 # @description
 # # autocomplete
###
angular.module('shortwaveApp')
  .directive('autocomplete', ($rootScope) ->
    templateUrl: 'views/partials/autocomplete.html'
    restrict: 'E'
    scope:
      channelName: '='
      query: '='
      members: '='
      completeMention: '&'
    link: (scope, element, attrs) ->
      
      # Watch for changes to the query
      scope.$watch 'query', (query) ->
        # Empty the results array
        scope.results = []
        # Reset the index
        scope.idx = 0
        if query?.text
          # Strip out all @ symbols
          q = query.text.replace '@', ''
          # lowercase
          q = q.toLowerCase()
          # console.log "autocomplete query is now #{q}"

          for member in scope.members when member.profile.firstName and member.profile.lastName and member.profile.photo
            slug = "#{member.profile.firstName}#{member.profile.lastName}".toLowerCase()
            idx = slug.indexOf q
            # Match?
            unless idx is -1
              member.matchPosition = idx
              scope.results.push member

      # Handle clicks on results
      scope.resultClicked = (result) ->
        # mentionString = 
        scope.completeMention
          mentionString: "#{result.profile.firstName}#{result.profile.lastName}"

        # Set the focus back on the compose bar
        $rootScope.$broadcast 'focusOn', 'compose'

      scope.hover = (idx) ->
        scope.idx = idx

      # Listen for arrowkey events
      scope.$on 'autocomplete:move', (ev, direction) ->
        # console.log "autocomplete move #{direction}"
        if direction is 'up'
          scope.idx--
        else
          scope.idx++
        scope.idx = 0 if scope.idx < 0
        scope.idx = scope.results.length - 1 if scope.idx > scope.results.length - 1
        # console.log 'autocomplete scope.idx is now ' + scope.idx

      # Listen for select events
      scope.$on 'autocomplete:select', ->
        if scope.results.length > 0
          # Grab the result
          result = scope.results[scope.idx]
          # Pick it
          scope.resultClicked result

  )
