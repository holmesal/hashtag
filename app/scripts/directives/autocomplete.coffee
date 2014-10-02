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
        scope.results = []
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
  )
