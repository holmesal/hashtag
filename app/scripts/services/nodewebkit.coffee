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

          @pack = require './package.json'

          # Hooray.
          # Celebrate by making a menu.
          win = @gui.Window.get()
          nativeMenuBar = new @gui.Menu type: 'menubar'
          nativeMenuBar.createMacBuiltin 'Hashtag'
          win.menu = nativeMenuBar

        else
          @isDesktop = false

      open: (url) ->
        if @isDesktop
          @gui.Shell.openExternal url

      clearCache: ->
        if @isDesktop
          @gui.App.clearCache()

      restart: ->
        if @isDesktop
          # Restart by setting the location back to the launcher
          window.location = @pack.main
        else
          # Restart by just reloading the page and forcing a GET
          window.location.reload true

    return new NodeWebkit
      
