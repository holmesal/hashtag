'use strict'

###*
 # @ngdoc service
 # @name shortwaveApp.notifications
 # @description
 # # notifications
 # Service in the shortwaveApp.
###
angular.module('shortwaveApp')
  .service 'Notifications', ->
    

    # Is this a node-webkit app?
    console.log parent.window.hello
    # if typeof process == "object"
    #   alert 'node-webkit!'
