'use strict'

###*
 # @ngdoc service
 # @name shortwaveApp.focus
 # @description
 # # focus
 # Service in the shortwaveApp.
###
angular.module('shortwaveApp')
  .service 'Focus', ($window) ->
    # AngularJS will instantiate a singleton by calling "new" on this function
    # 
    # Track the window focus state
    class Focus
      constructor: ->
        @focus = document.hasFocus()
        # console.info 'initial focus is '+@focus
        win = angular.element $window
        win.on 'focus', =>
          @focus = true
          # console.log "focus is #{@focus}"
        win.on 'blur', =>
          @focus = false
          # console.log "focus is #{@focus}"
          # 
        
        # Is this a node-webkit app?
        if process?.versions['node-webkit']
          gui = require 'nw.gui'
          nwWin = gui.Window.get()
          nwWin.on 'blur', =>
            @focus = false
          nwWin.on 'focus', =>
            @focus = true

    return new Focus
