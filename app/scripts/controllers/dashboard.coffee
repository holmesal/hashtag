'use strict'

###*
 # @ngdoc function
 # @name shortwaveApp.controller:DashboardCtrl
 # @description
 # # DashboardCtrl
 # Controller of the shortwaveApp
###
angular.module('shortwaveApp')
  .controller 'DashboardCtrl', ($scope, $rootScope, $timeout, $filter, $firebase, $firebaseSimpleLogin, $location, user, Channels, Message, FileUploader) ->

    # Information about current uploads

    $rootScope.$on 'updateChannel', (ev, newChannel) =>
      $scope.currentChannel = newChannel
      $scope.focusInput()

    $scope.showCreate = ->
      $scope.createVisible = true

    $scope.hideCreate = ->
      $scope.createVisible = false

    $scope.logout = ->
      auth = new FirebaseSimpleLogin $rootScope.rootRef, (err) ->
        alert 'logged out'
      auth.logout()

      $location.path '/'

    $scope.focusInput = ->
      $timeout -> $rootScope.$broadcast 'focusOn', 'compose'



    # Init

    # Focus on the compose bar when the controller loads
    $scope.focusInput()

    # Initialize the uploader
    imgur = '5ee37787905afcd'
    $scope.uploader = new FileUploader
      url: 'https://api.imgur.com/3/image'
      headers:
        'Authorization': "Client-ID #{imgur}"
      autoUpload: true
      alias: 'image'

    console.log $scope.uploader

    # Only accept images
    $scope.uploader.filters.push
      name: 'imageFilter'
      fn: (item, opts) ->
        type =  item.type.slice(item.type.lastIndexOf('/') + 1)
        type in ['jpg','png','jpg','jpeg','bmp','gif']

    # Callbacks
    $scope.uploader.onWhenAddingFileFailed = (item, filter, options) ->
      console.error 'error adding file', item, filter, options

    $scope.uploader.onAfterAddingFile = (fileItem) ->
      # console.log 'uploading item', fileItem
      $scope.uploader.uploadAll()

    # $scope.uploader.onBeforeUploadItem = (fileItem) ->
    #   console.log 'preparing to upload item', fileItem

    # $scope.uploader.onProgressItem = (fileItem, progress) ->
    #   console.log 'got progess for item', fileItem, progress

    $scope.uploader.onProgressAll = (progress) ->
      console.info "upload progress: #{progress}"


    $scope.uploader.onSuccessItem = (fileItem, res, status, headers) ->
      console.info 'successfully uploaded item - sending message'
      # File upload was a success, post an image message with this url
      Message.text res.data.link, $scope.currentChannel

    $scope.uploader.onErrorItem = (fileItem, res, status, headers) ->
      console.error 'error uploading item', fileItem, res, status, headers

    # $scope.uploader.onCompleteItem = (fileItem, res, status, headers) ->
    #   console.log 'finished uploading item', fileItem, res, status, headers

    $scope.uploader.onCompleteAll = ->
      console.info 'all uploads done'



    # Handle user pastes
    $scope.paste = (ev) ->
      # Get the pasted items
      items = ev.clipboardData or ev.originalEvent.clipboardData.items
      console.info 'user pasted something', JSON.stringify items

      for item in items
        if item.type in ['image/png','image/jpeg','image/gif']
          console.info 'uploading user-pasted image'
          blob = items[0].getAsFile()

          # Make a new file uploader item with this data
          $scope.uploader.addToQueue blob
