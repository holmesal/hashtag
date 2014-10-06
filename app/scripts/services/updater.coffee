'use strict'

###*
 # @ngdoc service
 # @name shortwaveApp.updater
 # @description
 # # updater
 # Service in the shortwaveApp.
###
angular.module('shortwaveApp')
  .service 'Updater', ($http, $timeout, $interval, version, NodeWebkit) ->

    # Grab the current version
    console.info "running hashtag version #{version}"

    showUpdatePopup = (newVersion) ->
      features = [
        'a third eye'
        'a really good sense of smell'
        'a really really ridiculously good-looking UI'
        'improved crash avoidance'
        'openable windows'
        'the ability to jump reallllly high'
        'the first glimmers of abstract thought'
      ]
      randFeature = features[Math.floor(Math.random()*features.length)]
      swal
        type: 'success'
        title: 'Shiny new stuff!'
        text: "A new version (#{newVersion}) of Hashtag is available. This update includes features like #{randFeature}."
        confirmButtonText: 'Update Hashtag'
        showCancelButton: true
        cancelButtonText: 'Maybe later'
      , ->
        # Restart the app to update
        NodeWebkit.restart()

    checkVersion = ->

      $http.get 'https://shortwave-releases.s3-us-west-1.amazonaws.com/package.json'
      .success (data, status, headers, config) ->
        console.info "hashtag version on s3 is #{data.version}"
        if data.version isnt version
          console.info "version #{data.version} now available!"
          # Show the update popup
          showUpdatePopup data.version
        else
          console.info 'running newest version'
      .error (data, status, headers, config) ->
        console.error 'failed to get newest version from bucket', data

    checkVersion()

    # Check the version again every half hour
    $interval checkVersion, 1000*60*30
