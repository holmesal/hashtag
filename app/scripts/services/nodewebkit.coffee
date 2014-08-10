'use strict'

###*
 # @ngdoc service
 # @name shortwaveApp.NodeWebkit
 # @description
 # # NodeWebkit
 # Service in the shortwaveApp.
###
angular.module('shortwaveApp')
  .service 'NodeWebkit', ->
    # AngularJS will instantiate a singleton by calling "new" on this function

    class NodeWebkit 

      constructor: ->
        # Is this a node-webkit app?
        if process?.versions['node-webkit']

          @isDesktop = true

          @gui = require 'nw.gui'

          # Hooray.
          # Celebrate by making a menu.
          win = @gui.Window.get()
          nativeMenuBar = new @gui.Menu type: 'menubar'
          nativeMenuBar.createMacBuiltin 'ShortwaveApp'
          win.menu = nativeMenuBar

      open: (url) ->
        @gui.Shell.openExternal url

    return new NodeWebkit
      
