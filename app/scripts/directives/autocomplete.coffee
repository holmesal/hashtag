'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:autocomplete
 # @description
 # # autocomplete
###
angular.module('shortwaveApp')
  .directive('autocomplete', ($rootScope, $firebase) ->
    templateUrl: 'views/partials/autocomplete.html'
    restrict: 'E'
    scope:
      channelName: '='
      query: '='
    link: (scope, element, attrs) ->

      # Watch for changes to the channel
      scope.$watch 'channelName', (chan) ->
        if chan
          # Clear any existing members references
          if scope.members 
            scope.members.$destroy()

          # Set up a firebase referece to the members of this channel
          membersRef = $rootScope.rootRef.child "channels/#{scope.channelName}/members"
          sync = $firebase membersRef
          scope.members = sync.$asArray()

          # Watch for new members being added
          scope.members.$watch (ev) ->
            if ev.event is 'child_added'
              # console.log "new child added! #{ev.key}"
              # Grab this user's profile
              profileRef = $rootScope.rootRef.child "users/#{ev.key}/profile"
              sync = $firebase profileRef
              # Store this in the members array
              member = scope.members.$getRecord ev.key
              member.profile = sync.$asObject()
      
      # Watch for changes to the query
      scope.$watch 'query', (query) ->
        scope.results = []
        if query
          # Strip out all @ symbols
          q = query.replace '@', ''
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
  )
