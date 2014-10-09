'use strict'

###*
 # @ngdoc service
 # @name shortwaveApp.analytics
 # @description
 # # analytics
 # Service in the shortwaveApp.
###
angular.module('shortwaveApp')
  .service 'Analytics', (version) ->
    # AngularJS will instantiate a singleton by calling "new" on this function

    class Analytics 

      constructor: ->
        # Automatically, grab the platform and version
        @context = {}

      addContext: (extraContext) ->
        # console.log 'got props', extraContext
        @context = $.extend true, extraContext, @context
        # console.log 'context is now', @context

      track: (ev, props={}, extraContext={}) ->
        # Track, with the context
        con = $.extend true, extraContext, @context
        analytics.track ev, props, con
        # console.info "tracked #{ev} with properties", props," and context", con

      identify: (userId, traits, extraContext={}) ->
        # Track, with the context
        con = $.extend true, extraContext, @context
        analytics.identify userId, traits, con
        # console.log "identified #{userId} with traits", traits, "and context", con

    return new Analytics
